#!/usr/bin/env bash

command -v kip >/dev/null 2>&1 || { echo "kip helper not found: run this as a Bash command with KIP on" >&2; exit 127; }

AWS_BIN=${AWS_CLI:-aws}
DDB_ENDPOINT=${DYNAMODB_ENDPOINT:-}
export AWS_PAGER=""
for _v in AWS_PROFILE AWS_REGION AWS_DEFAULT_REGION AWS_ACCOUNT_ID; do
    [ -n "${!_v-}" ] || unset "$_v"
done
[ -n "${AWS_REGION-}" ] && export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-$AWS_REGION}

PAGE=${DYNAMODB_PAGE_SIZE:-25}
case $PAGE in ''|*[!0-9]*) PAGE=25 ;; esac
[ "$PAGE" -lt 1 ] && PAGE=1
[ "$PAGE" -gt 100 ] && PAGE=100
READONLY=false
case ${DYNAMODB_READ_ONLY:-} in 1|true|TRUE|True|yes|YES|on|ON) READONLY=true ;; esac
LOCAL=false
{ [ -n "$DDB_ENDPOINT" ] || [ "$AWS_BIN" = awslocal ]; } && LOCAL=true

ERRF=$(mktemp)
ITEMF=$(mktemp)
trap 'rm -f "$ERRF" "$ITEMF"' EXIT

# ---- jq helpers: DynamoDB JSON <-> plain JSON -------------------------------------------------------------
JQ_LIB='
def un: if type != "object" then . elif has("S") then .S elif has("N") then (.N | tonumber)
  elif has("BOOL") then .BOOL elif has("NULL") then null elif has("M") then (.M | map_values(un))
  elif has("L") then (.L | map(un)) elif has("SS") then .SS elif has("NS") then (.NS | map(tonumber))
  elif has("B") then .B elif has("BS") then .BS else . end;
def unitem: map_values(un);
def marshal: if type == "string" then {S: .} elif type == "number" then {N: tostring}
  elif type == "boolean" then {BOOL: .} elif type == "null" then {NULL: true}
  elif type == "array" then {L: map(marshal)} else {M: map_values(marshal)} end;
def keyof($keys): with_entries(select(.key as $k | $keys | index($k)));
def cell: (if type == "string" then . else tojson end) | if length > 48 then .[:45] + "…" else . end;
'

# ---- calling the CLI --------------------------------------------------------------------------------------
# aws_run OUTVAR args...: stdout goes to $OUTVAR (never a subshell, so $AWS_ERR survives), stderr to $AWS_ERR.
AWS_ERR=
aws_run() {
    # (locals are named apart from the callers' variables: printf -v would otherwise write to the local)
    local __var=$1 __cap __rc
    shift
    __cap=$("$AWS_BIN" "$@" --output json --cli-connect-timeout 10 --cli-read-timeout 60 2>"$ERRF")
    __rc=$?
    AWS_ERR=$(tr '\n' ' ' <"$ERRF" | sed 's/  */ /g; s/^ //; s/ $//')
    printf -v "$__var" '%s' "$__cap"
    return $__rc
}
ddb() {
    local __dv=$1
    shift
    if [ -n "$DDB_ENDPOINT" ]; then
        aws_run "$__dv" dynamodb "$@" --endpoint-url "$DDB_ENDPOINT"
    else
        aws_run "$__dv" dynamodb "$@"
    fi
}
emit() { kip raw "$1"; }

auth_problem() {
    case $AWS_ERR in
        *SSO*|*sso*|*xpired*|*"Unable to locate credentials"*|*"security token"*|*"Token has"*) return 0 ;;
    esac
    return 1
}
fatal_aws() {
    local login="aws sso login${AWS_PROFILE:+ --profile $AWS_PROFILE}" profiles
    case $AWS_ERR in
        *"config profile"*"could not be found"*)
            profiles=$("$AWS_BIN" configure list-profiles 2>/dev/null | tr '\n' ' ')
            kip done --level error --title "$1" \
                --text "AWS profile \"${AWS_PROFILE:-default}\" does not exist on this machine. ${profiles:+Existing profiles: ${profiles}. }Set AWS_PROFILE in this project's variables (empty = the default credentials), or set AWS_CLI to awslocal to use a local DynamoDB."
            exit 1 ;;
        *"Unable to locate credentials"*)
            kip done --level error --title "$1" \
                --text "No AWS credentials found. Configure a profile (aws configure, or aws sso login) and set AWS_PROFILE in this project's variables — or try the explorer without AWS: start the local DynamoDB (folder DynamoDB / Local) and set AWS_CLI to awslocal."
            exit 1 ;;
    esac
    if auth_problem; then
        kip done --level error --title "$1" --text "$AWS_ERR — if this profile uses SSO, sign in again and run the command again." \
            --action copy:"Copy the SSO login command":"$login"
    else
        kip done --level error --title "$1" --text "${AWS_ERR:-Unknown error.}"
    fi
    exit 1
}

# ---- preflight --------------------------------------------------------------------------------------------
kip hello --title "DynamoDB explorer"

_missing=
command -v "$AWS_BIN" >/dev/null 2>&1 || _missing="$_missing $AWS_BIN"
command -v jq >/dev/null 2>&1 || _missing="$_missing jq"
if [ -n "$_missing" ]; then
    kip done --level error --title "Missing tools" \
        --text "Not found where this command runs:${_missing}. Install them (AWS CLI v2, jq) or set AWS_CLI in the project variables (use awslocal for LocalStack / DynamoDB Local)."
    exit 127
fi

# "default" is the name of the implicit profile: when no such profile is configured (credentials come from the
# environment, an instance role...) asking the CLI for it by name would fail, so just do not name it.
if [ "${AWS_PROFILE-}" = default ] && ! "$AWS_BIN" configure list-profiles 2>/dev/null | grep -qx default; then
    unset AWS_PROFILE
fi

# No credentials (or an unknown profile) is the usual "I just want to try it" case: when awslocal is installed,
# offer it for this run instead of failing. It is always asked, never switched silently.
offer_local() {
    case $AWS_ERR in
        *"Unable to locate credentials"*|*"config profile"*"could not be found"*) ;;
        *) return 1 ;;
    esac
    command -v awslocal >/dev/null 2>&1 || return 1
    kip confirm --id local --title "No usable AWS credentials" \
        --text "$AWS_ERR. Use awslocal (a local DynamoDB on localhost:4566) for this run instead? To change it for good, set AWS_CLI in this project's variables." \
        --confirm-label "Use awslocal" --cancel-label "Stop"
    kip recv
    [ "$(jq -r '.values.confirmed' <<<"$KIP_MSG")" = true ]
}

ACCOUNT=
IDENTITY=
if [ "$LOCAL" = false ] && ! aws_run _ident sts get-caller-identity; then
    if offer_local; then
        AWS_BIN=awslocal
        LOCAL=true
        unset AWS_PROFILE
    else
        fatal_aws "Could not reach AWS"
    fi
fi
if [ "$LOCAL" = false ]; then
    ACCOUNT=$(jq -r '.Account' <<<"$_ident")
    IDENTITY=$(jq -r '.Arn' <<<"$_ident")
    if [ -n "${AWS_ACCOUNT_ID-}" ] && [ "$ACCOUNT" != "$AWS_ACCOUNT_ID" ]; then
        kip done --level error --title "Wrong AWS account" \
            --text "The credentials belong to account $ACCOUNT ($IDENTITY) but this project expects $AWS_ACCOUNT_ID. Nothing was touched. Fix AWS_PROFILE or AWS_ACCOUNT_ID in the project variables."
        exit 1
    fi
fi
REGION=${AWS_REGION-${AWS_DEFAULT_REGION-}}
[ -n "$REGION" ] || REGION=$("$AWS_BIN" configure get region 2>/dev/null)
SUMMARY="Profile ${AWS_PROFILE:-default} · Region ${REGION:-?}"
if [ "$LOCAL" = true ]; then
    SUMMARY="$SUMMARY · Local (${DDB_ENDPOINT:-$AWS_BIN})"
else
    SUMMARY="$SUMMARY · Account $ACCOUNT"
fi
[ "$READONLY" = true ] && SUMMARY="$SUMMARY · READ-ONLY"

# ---- tables screen ----------------------------------------------------------------------------------------
TABLES=
list_tables() {
    ddb _out list-tables || return 1
    TABLES=$(jq -r '.TableNames[]' <<<"$_out")
}

tables_field_json() {
    printf '%s' "$TABLES" | jq -R -s -c '{name: "table", type: "list", label: "Table", required: true, searchable: true,
        options: (split("\n") | map(select(length > 0)))}'
}

describe_table_md() {
    ddb _out describe-table --table-name "$1" || return 1
    DESC_MD=$(jq -r '.Table as $t
        | ($t.AttributeDefinitions | map({key: .AttributeName, value: .AttributeType}) | from_entries) as $ad
        | "- **Status:** \($t.TableStatus)\n"
        + "- **Keys:** " + ($t.KeySchema | map("`\(.AttributeName)` (\(.KeyType), \($ad[.AttributeName]))") | join(", ")) + "\n"
        + "- **Items:** ~\($t.ItemCount) (DynamoDB refreshes this about every 6 hours) · **Size:** \($t.TableSizeBytes) bytes\n"
        + "- **Billing:** \($t.BillingModeSummary.BillingMode // "PROVISIONED")\n"
        + (if $t.GlobalSecondaryIndexes then "- **Global indexes:** " + ($t.GlobalSecondaryIndexes | map("`\(.IndexName)`") | join(", ")) + "\n" else "" end)
        + (if $t.LocalSecondaryIndexes then "- **Local indexes:** " + ($t.LocalSecondaryIndexes | map("`\(.IndexName)`") | join(", ")) + "\n" else "" end)
        + "- **ARN:** `\($t.TableArn)`"' <<<"$_out")
}

send_tables_prompt() {
    emit "$(jq -nc --arg desc "$SUMMARY" --argjson field "$(tables_field_json)" '{
        kip: 1, type: "prompt", id: "tables", title: "DynamoDB tables", description: $desc, remember: false,
        submit_label: "Open", fields: [$field],
        chips: [{id: "refresh", label: "Refresh", icon: "refresh-cw"},
                {id: "describe", label: "Describe", icon: "info", requires: ["table"]}]}')"
}

# ---- table screen -----------------------------------------------------------------------------------------
TABLE= KEYS='[]' KEYTYPES='{}' HASHKEY=
CURSORS=("")
PAGE_IDX=0
FILTER=
NEXT_CURSOR=
EVALUATED=0
ITEMS='[]'

load_schema() {
    ddb _out describe-table --table-name "$TABLE" || return 1
    KEYS=$(jq -c '[.Table.KeySchema | sort_by(.KeyType == "RANGE")[] | .AttributeName]' <<<"$_out")
    KEYTYPES=$(jq -c '.Table.AttributeDefinitions | map({key: .AttributeName, value: .AttributeType}) | from_entries' <<<"$_out")
    HASHKEY=$(jq -r '.[0]' <<<"$KEYS")
}

# Evaluates PAGE items after the cursor of the current page, THEN filters (as DynamoDB does): a page can
# show fewer items than were evaluated.
load_page() {
    local args=(scan --table-name "$TABLE" --limit "$PAGE" --no-paginate)
    [ -n "${CURSORS[$PAGE_IDX]}" ] && args+=(--exclusive-start-key "${CURSORS[$PAGE_IDX]}")
    ddb _out "${args[@]}" || return 1
    NEXT_CURSOR=$(jq -c '.LastEvaluatedKey // empty' <<<"$_out")
    EVALUATED=$(jq -r '.ScannedCount // 0' <<<"$_out")
    ITEMS=$(jq -c --arg f "$FILTER" "$JQ_LIB"'[.Items[] | {typed: ., plain: unitem}
        | select($f == "" or (.plain | tojson | ascii_downcase | contains($f | ascii_downcase)))]' <<<"$_out")
}

rows_field_json() {
    local info="Page $((PAGE_IDX + 1)) · $(jq length <<<"$ITEMS") shown of $EVALUATED evaluated"
    if [ -n "$NEXT_CURSOR" ]; then info="$info · more available"; else info="$info · end of table"; fi
    [ -n "$FILTER" ] && info="$info · the filter applies to the evaluated items of this page"
    jq -c --argjson keys "$KEYS" --arg t "$TABLE" --arg d "$info" "$JQ_LIB"'
        . as $items
        | ([$items[].plain | keys_unsorted[]]) as $all
        | (reduce $all[] as $k ({}; .[$k] += 1)) as $count
        | (($all | unique) - $keys | sort_by(-$count[.])) as $others
        | ($keys + $others[:5]) as $cols
        | {name: "rows", type: "table", label: $t, description: $d, row_key: "_key", multiple: true, searchable: false,
           columns: ($cols | map({key: ., label: .})),
           rows: ($items | map({_key: (.typed | keyof($keys) | tojson)} + (.plain | keyof($cols) | map_values(cell))))}' <<<"$ITEMS"
}

chips_json() {
    local hasprev=false hasnext=false
    [ "$PAGE_IDX" -gt 0 ] && hasprev=true
    [ -n "$NEXT_CURSOR" ] && hasnext=true
    jq -nc --argjson ro "$READONLY" --argjson hasprev "$hasprev" --argjson hasnext "$hasnext" '
        [ (if $hasprev then {id: "prev", label: "Previous", icon: "arrow-left"} else empty end),
          (if $hasnext then {id: "next", label: "Next", icon: "arrow-right"} else empty end),
          {id: "refresh", label: "Refresh", icon: "refresh-cw"},
          {id: "view", label: "View", icon: "eye", requires: ["rows"]} ]
        + (if $ro then [] else [
          {id: "new", label: "New item", icon: "plus"},
          {id: "edit", label: "Edit", icon: "pencil", requires: ["rows"]},
          {id: "duplicate", label: "Duplicate", icon: "copy", requires: ["rows"]},
          {id: "delete", label: "Delete", icon: "trash-2", danger: true, requires: ["rows"],
           confirm: {title: "Delete the selected items?", text: "This cannot be undone.",
                     confirm_label: "Delete", cancel_label: "Keep"}} ] end)'
}

send_browse_prompt() {
    emit "$(jq -nc --arg t "$TABLE" --arg f "$FILTER" --arg desc "$SUMMARY" --argjson rows "$(rows_field_json)" \
        --argjson chips "$(chips_json)" '{
        kip: 1, type: "prompt", id: "browse", title: ("Table · " + $t), description: $desc, back: true, remember: false,
        submit_label: "Close", chips: $chips,
        fields: [{name: "filter", type: "text", label: "Filter (text contained in the item)", watch: true,
                  default: $f, placeholder: "e.g. shipped", remember: false}, $rows]}')"
}

# $1 = seq of the change being answered (empty = spontaneous patch, always applied)
send_browse_patch() {
    emit "$(jq -nc --arg seq "$1" --argjson rows "$(rows_field_json)" --argjson chips "$(chips_json)" '
        {kip: 1, type: "patch", id: "browse", fields: [$rows], chips: $chips}
        + (if $seq == "" then {} else {seq: ($seq | tonumber)} end)')"
}

row_label() { # typed key (JSON) -> "pk=a, sk=b"
    jq -r --argjson keys "$KEYS" "$JQ_LIB"'keyof($keys) | unitem | to_entries | map("\(.key)=\(.value)") | join(", ")' <<<"$1"
}

# ---- item editor ------------------------------------------------------------------------------------------
EDIT_MODE= EDIT_FORMAT= ORIG_KEY= ITEM= VERR=

# Validates the editor text and sets $ITEM (DynamoDB JSON). Returns 1 with the message in $VERR.
validate_item() {
    local parsed
    VERR=
    parsed=$(jq -c . <<<"$1" 2>&1) || { VERR="Not valid JSON: ${parsed%%$'\n'*}"; return 1; }
    jq -e 'type == "object"' <<<"$parsed" >/dev/null || { VERR="The item must be a JSON object."; return 1; }
    if [ "$EDIT_FORMAT" = typed ]; then
        ITEM=$parsed
        VERR=$(jq -r 'if all(.[]; type == "object" and length == 1 and (keys[0] | IN("S","N","B","BOOL","NULL","M","L","SS","NS","BS")))
            then "" else "Every attribute must be a DynamoDB typed value, e.g. {\"S\": \"text\"}." end' <<<"$ITEM")
        [ -z "$VERR" ] || return 1
    else
        ITEM=$(jq -c "$JQ_LIB"'map_values(marshal)' <<<"$parsed")
    fi
    VERR=$(jq -r --argjson keys "$KEYS" --argjson kt "$KEYTYPES" '
        [ $keys[] as $k
          | if has($k) | not then "Missing key attribute: \($k)"
            elif (.[$k] | keys[0]) != $kt[$k] then "Key attribute \($k) must be of type \($kt[$k])"
            elif ((.[$k] | to_entries[0].value) | tostring | length) == 0 then "Key attribute \($k) cannot be empty"
            else empty end ] | first // ""' <<<"$ITEM")
    [ -z "$VERR" ] || return 1
    if [ "$EDIT_MODE" = edit ]; then
        jq -e --argjson keys "$KEYS" --argjson orig "$ORIG_KEY" "$JQ_LIB"'keyof($keys) == $orig' <<<"$ITEM" >/dev/null \
            || { VERR="The key cannot change when editing (use Duplicate)."; return 1; }
    fi
    return 0
}

save_item() {
    local cond=attribute_not_exists names
    [ "$EDIT_MODE" = edit ] && cond=attribute_exists
    names=$(jq -nc --arg k "$HASHKEY" '{"#k": $k}')
    printf '%s' "$ITEM" >"$ITEMF"
    if ddb _out put-item --table-name "$TABLE" --item "file://$ITEMF" \
        --condition-expression "$cond(#k)" --expression-attribute-names "$names"; then
        return 0
    fi
    case $AWS_ERR in
        *ConditionalCheckFailed*)
            if [ "$EDIT_MODE" = edit ]; then VERR="The item no longer exists."; else VERR="An item with this key already exists."; fi ;;
        *) VERR=$AWS_ERR ;;
    esac
    return 1
}

# edit_item new|edit|duplicate [typed-key]: returns 0 when done (saved or Back).
edit_item() {
    local mode=$1 key=${2-} typed text title desc
    EDIT_MODE=$mode ORIG_KEY=$key
    if [ "$mode" = new ]; then
        typed=$(jq -nc --argjson keys "$KEYS" --argjson kt "$KEYTYPES" \
            '$keys | map({key: ., value: (if $kt[.] == "N" then {N: "0"} else {S: ""} end)}) | from_entries')
    else
        if ! ddb _out get-item --table-name "$TABLE" --key "$key" --consistent-read; then
            kip message error "${AWS_ERR:-Could not read the item.}"
            return 0
        fi
        typed=$(jq -c '.Item // empty' <<<"$_out")
        if [ -z "$typed" ]; then
            kip message error "The item no longer exists."
            return 0
        fi
        # A copy keeps every attribute; only the partition key changes, so it can be saved as a new item.
        [ "$mode" = duplicate ] && typed=$(jq -c --arg k "$HASHKEY" 'if .[$k].S then .[$k].S += "-copy" else . end' <<<"$typed")
    fi
    # Plain JSON would flatten sets / binary into lists / strings: show those items in DynamoDB JSON instead.
    if jq -e '[.. | objects | keys[]] | any(. == "SS" or . == "NS" or . == "BS" or . == "B")' <<<"$typed" >/dev/null; then
        EDIT_FORMAT=typed
        text=$(jq --indent 2 . <<<"$typed")
        desc="This item has Set or Binary attributes, so it is shown as DynamoDB JSON (typed values) to keep them intact."
    else
        EDIT_FORMAT=plain
        text=$(jq --indent 2 "$JQ_LIB"'unitem' <<<"$typed")
        desc="Plain JSON: strings, numbers, booleans, null, lists and maps."
    fi
    case $mode in
        new) title="New item" ;;
        edit) title="Edit item" desc="$desc The key cannot change; use Duplicate to copy under another key." ;;
        duplicate) title="Duplicate item" desc="$desc Change the key: saving fails if an item with it already exists." ;;
    esac
    emit "$(jq -nc --arg title "$title" --arg desc "$desc" --arg text "$text" --arg label "Item ($EDIT_FORMAT JSON)" '{
        kip: 1, type: "prompt", id: "edit", title: $title, description: $desc, back: true, remember: false,
        submit_label: "Save",
        fields: [{name: "json", type: "textarea", label: $label, required: true, default: $text}]}')"
    while true; do
        kip recv
        case $(jq -r '.type' <<<"$KIP_MSG") in
            back) return 0 ;;
            response)
                if validate_item "$(jq -r '.values.json' <<<"$KIP_MSG")" && save_item; then
                    kip message success "Saved item $(row_label "$ITEM")."
                    return 0
                fi
                # The prompt stays open: answer with the error and wait for the next response.
                emit "$(jq -nc --arg e "$VERR" '{kip: 1, type: "invalid", id: "edit", errors: {json: $e}}')"
                ;;
        esac
    done
}

# ---- chips of the table screen ----------------------------------------------------------------------------
chip_result() { # chip state text [title]
    if [ -n "${4-}" ]; then kip chip-result "$1" "$2" "$3" --title "$4"; else kip chip-result "$1" "$2" "$3"; fi
}

reload_and_repaint() { # $1 = chip, $2 = message on success
    if load_page; then
        send_browse_patch ""
        chip_result "$1" success "$2"
    else
        chip_result "$1" error "${AWS_ERR:-Could not read the table.}"
    fi
}

# Handles one chip click of the table screen. Returns 10 when the screen must be redrawn from scratch
# (an editor was shown).
on_browse_chip() {
    local chip sel n key out rc=0 deleted=0 failed=0 shown
    chip=$(jq -r '.chip' <<<"$KIP_MSG")
    sel=$(jq -c '.values.rows // []' <<<"$KIP_MSG")
    n=$(jq 'length' <<<"$sel")
    case $chip in
        new|edit|duplicate|delete)
            if [ "$READONLY" = true ]; then
                chip_result "$chip" error "This explorer is read-only (DYNAMODB_READ_ONLY)."
                return 0
            fi ;;
    esac
    case $chip in
        next)
            CURSORS=("${CURSORS[@]:0:$((PAGE_IDX + 1))}" "$NEXT_CURSOR")
            PAGE_IDX=$((PAGE_IDX + 1))
            reload_and_repaint next "Page $((PAGE_IDX + 1))" ;;
        prev)
            PAGE_IDX=$((PAGE_IDX - 1))
            reload_and_repaint prev "Page $((PAGE_IDX + 1))" ;;
        refresh)
            reload_and_repaint refresh "Page $((PAGE_IDX + 1)) reloaded" ;;
        view)
            [ "$n" -ge 1 ] || { chip_result view error "Select an item."; return 0; }
            shown=0
            out=
            while IFS= read -r key; do
                [ "$shown" -lt 5 ] || break
                if ddb _out get-item --table-name "$TABLE" --key "$key" --consistent-read; then
                    out="${out:+$out$'\n\n'}**$(row_label "$key")**"$'\n'"\`\`\`json"$'\n'"$(jq --indent 2 "$JQ_LIB"'(.Item // {}) | unitem' <<<"$_out")"$'\n'"\`\`\`"
                else
                    out="${out:+$out$'\n\n'}Could not read $(row_label "$key"): $AWS_ERR"
                fi
                shown=$((shown + 1))
            done < <(jq -r '.[]' <<<"$sel")
            [ "$n" -gt 5 ] && out="$out"$'\n\n'"(showing the first 5 of $n)"
            chip_result view success "$out" "$TABLE"
            ;;
        edit|duplicate)
            [ "$n" -eq 1 ] || { chip_result "$chip" error "Select exactly one item."; return 0; }
            edit_item "$chip" "$(jq -r '.[0]' <<<"$sel")"
            return 10 ;;
        new)
            edit_item new
            return 10 ;;
        delete)
            while IFS= read -r key; do
                if ddb _out delete-item --table-name "$TABLE" --key "$key"; then
                    deleted=$((deleted + 1))
                else
                    failed=$((failed + 1))
                    last_error=$AWS_ERR
                fi
            done < <(jq -r '.[]' <<<"$sel")
            if load_page; then send_browse_patch ""; fi
            if [ "$failed" -gt 0 ]; then
                chip_result delete error "Deleted $deleted, failed $failed: $last_error"
            else
                chip_result delete success "Deleted $deleted item(s)."
            fi ;;
    esac
    return 0
}

browse_table() {
    CURSORS=("")
    PAGE_IDX=0
    FILTER=
    if ! load_schema || ! load_page; then
        kip message error "Could not open $TABLE: ${AWS_ERR:-unknown error}"
        return 0
    fi
    send_browse_prompt
    local seq
    while true; do
        kip recv
        case $(jq -r '.type' <<<"$KIP_MSG") in
            change)
                # Every `change` must be answered with a patch that echoes its seq.
                seq=$(jq -r '.seq' <<<"$KIP_MSG")
                FILTER=$(jq -r '.values.filter // ""' <<<"$KIP_MSG")
                CURSORS=("")
                PAGE_IDX=0
                if load_page; then
                    send_browse_patch "$seq"
                else
                    emit "$(jq -nc --argjson seq "$seq" '{kip: 1, type: "patch", id: "browse", seq: $seq, fields: []}')"
                    kip message error "${AWS_ERR:-Could not read the table.}"
                fi ;;
            chip)
                on_browse_chip
                if [ $? -eq 10 ]; then
                    load_page
                    send_browse_prompt
                fi ;;
            back|response) return 0 ;;
        esac
    done
}

# ---- main: the tables screen is the home screen; the session ends with Cancel (exit 130) ------------------
if ! list_tables; then
    fatal_aws "Could not list the tables"
fi
if [ -z "$TABLES" ]; then
    kip done --level warning --title "No tables" --text "There are no DynamoDB tables in this account and region. $SUMMARY"
    exit 0
fi

while true; do
    send_tables_prompt
    while true; do
        kip recv
        case $(jq -r '.type' <<<"$KIP_MSG") in
            chip)
                case $(jq -r '.chip' <<<"$KIP_MSG") in
                    refresh)
                        if list_tables; then
                            emit "$(jq -nc --argjson field "$(tables_field_json)" '{kip: 1, type: "patch", id: "tables", fields: [$field]}')"
                            chip_result refresh success "$(printf '%s\n' "$TABLES" | grep -c .) table(s)"
                        else
                            chip_result refresh error "${AWS_ERR:-Could not list the tables.}"
                        fi ;;
                    describe)
                        _t=$(jq -r '.values.table // ""' <<<"$KIP_MSG")
                        if [ -z "$_t" ]; then
                            chip_result describe error "Pick a table first."
                        elif describe_table_md "$_t"; then
                            chip_result describe success "$DESC_MD" "$_t"
                        else
                            chip_result describe error "${AWS_ERR:-Could not describe the table.}"
                        fi ;;
                esac ;;
            response)
                TABLE=$(jq -r '.values.table' <<<"$KIP_MSG")
                break ;;
        esac
    done
    browse_table
done

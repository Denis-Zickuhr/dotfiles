# nav — a simple navigation manager

Bookmark directories under short aliases and jump to them from anywhere,
either by name or through a full-screen interactive picker — and `nav f`
learns your most-visited directories automatically, with no bookmarking at
all.

`nav` is a single self-contained bash file. It only touches files under
`$HOME`:

| File               | Purpose                                             |
|--------------------|-------------------------------------------------------|
| `~/.navm_aliases`  | `alias=/absolute/path` lines, one per bookmark        |
| `~/.navm_config`   | opener, ASK-mode openers, page size, tracking toggle  |
| `~/.navm_usage`    | `alias=count:last_used_epoch`, alias frecency         |
| `~/.navm_frecent`  | `count<TAB>epoch<TAB>path`, auto-learned `cd` history |

## Install

### Option A — curl one-liner (no git required)

Downloads the script to `~/.nav.sh` and sources it from `~/.bashrc`:

```bash
curl -fsSL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/bashrc/nav -o ~/.nav.sh \
  && sed -i '\|source .*/\.nav\.sh|d' ~/.bashrc \
  && echo 'source "$HOME/.nav.sh"' >> ~/.bashrc \
  && source ~/.bashrc
```

The `sed` line makes it idempotent — running the command again (e.g. to
update to a newer version) won't duplicate the `source` line in `.bashrc`.

### Option B — clone the repo

```bash
git clone https://github.com/Denis-Zickuhr/dotfiles.git ~/.dotfiles
echo 'source "$HOME/.dotfiles/bashrc/nav"' >> ~/.bashrc
source ~/.bashrc
```

### Option C — the repo's installer

If you already run the [full installer](../README.md#install) from this
repo, use its `kai.json` command *"Instalar nav (reinstala no ~/.bashrc)"*,
or manually:

```bash
sed -i '\|bashrc/nav|d' ~/.bashrc
echo 'source "/path/to/dotfiles/bashrc/nav"' >> ~/.bashrc
source ~/.bashrc
```

Requires bash 4.3+ (for `${var,,}` lowercasing) and standard coreutils
(`sed`, `grep`, `cut`, `sort`, `column`, `stty`, `tput`, `date`, `mktemp`),
all preinstalled on Linux, macOS, and WSL. No external dependencies are
added.

> **Heads up:** sourcing `nav` redefines the `cd` builtin as a function (to
> power `nav f` — see [Directory learning](#directory-learning-nav-f)
> below). If that's not something you want touching your shell, turn it off
> with `nav config track off` right after installing — everything else
> still works.

## Quick start

```bash
cd ~/projects/some-service
nav set                          # bookmark the current directory — alias
                                  # auto-named "some-service" from the folder

cd /
nav some-service                 # jump back to it from anywhere
nav                              # or just type `nav` and pick it interactively
nav f                            # or don't even bookmark it — just `cd` around
                                  # normally and let nav learn your habits
```

## Interactive mode

Typing **`nav` with no arguments** opens a full-screen picker instead of the
help text:

```
  nav — interactive (14 total, 4 shown)

  Search: api  (editing — j/k/h/l typed literally)

  › api-gateway     /home/me/work/api-gateway
    api-billing     /home/me/work/api-billing
    api-legacy      /srv/legacy/api  [missing]

  Page 1/1   ↑/↓ move · ←/→ page · Enter select · Ctrl-D delete · Esc/Ctrl-C quit
```

- **Move:** `↑`/`↓` arrows always work, in every state. `j`/`k` also move,
  but only while the search box is untouched (see below).
- **Page:** `←`/`→` arrows always jump a full page. `h`/`l` do the same,
  again only while the search box is untouched.
- **Search:** typing any other character arms the search box and filters
  instantly — matches the full `label + path` as a plain substring, and
  additionally matches the label alone with **fuzzy (out-of-order)
  matching**, so `agw` finds `api-gateway` even though it's not a literal
  substring. Fuzzy matching is scoped to the (short) label only — doing it
  against full paths too would match almost anything. Backspace edits the
  query.
- **Force search:** press `/` (vim-style) to arm the search box without
  typing a character — use this when what you want starts with `j`, `k`,
  `h`, or `l` (e.g. `jira`, `logs`), so that first letter isn't swallowed as
  a navigation key. Typing any other letter first arms the box
  automatically, no `/` needed.
- **Select:** `Enter` acts on the highlighted path — `cd`s into it, opens
  it, or prints it, depending on how the picker was launched (see below).
- **Delete:** `Ctrl-D` removes the highlighted entry immediately, no
  confirmation — a defined alias (plus its usage stats), or a learned path
  from `nav f`'s history, whichever list you're in.
- **Cancel:** `Esc` clears the search box first (and disarms it); press it
  again (or `Ctrl-C`) with an empty box to quit without moving. Backspacing
  the query down to empty also disarms the box, handing `j`/`k`/`h`/`l`
  back to navigation.

A path whose directory no longer exists is shown in red with a `[missing]`
tag, so you can spot stale bookmarks before pressing Enter — see
[Housekeeping](#housekeeping) to clean them up.

Results are **paginated at 10 per page by default**. Change that with:

```bash
nav config page_size 20     # show 20 results per page
nav config page_size        # show the current value
```

Interactive mode needs a real terminal (it won't run if stdin/stdout are
piped or redirected) and leaves your terminal state untouched — settings
are restored on select, cancel, or `Ctrl-C`.

### The three pickers: `nav`, `nav i`, `nav f`

There are three distinct interactive lists, because "all your aliases",
"the ones you actually use", and "everywhere you `cd`, aliased or not" are
different questions:

| Command | Shows | Backed by |
|---|---|---|
| `nav` | Your aliases, but **only the ones you've used** — an empty search box shows just those; the moment you type anything, it searches *all* of them. This means a brand-new alias is never truly hidden, it just isn't in the default shortlist yet. | `~/.navm_aliases` + `~/.navm_usage` |
| `nav i` / `nav interactive` | *Every* alias you've defined, used or not, always. Use this to browse the full bookmark list. | `~/.navm_aliases` + `~/.navm_usage` (for sort order only) |
| `nav f` / `nav frequent` | Directories you've actually `cd`'d into — no `nav set` required at all. See below. | `~/.navm_frecent` |

All three, plus `o`/`opener` and `p`/`print`, sort by **frecency** (usage
count, most-recently-used as tiebreak) rather than file order — the places
you actually rely on float to the top.

### Directory learning (`nav f`)

Sourcing `nav` wraps the `cd` builtin. Every time it succeeds — whether you
typed `cd` by hand, used a nav alias, or picked from `nav f` itself — the
resulting directory is logged to `~/.navm_frecent` (skipping `$HOME` and
`/`, too generic to be useful here). `nav f`/`frequent` picks straight from
that history:

```bash
cd ~/work/some-repo    # just navigate normally, no bookmarking
cd ~/work/some-repo    # ...a few more times over the following days...
nav f                  # it's right there, near the top
```

Opening a path (`-o`) also counts as a visit; printing (`-p`) does not. The
history file is capped at 500 entries (lowest-scoring dropped first), so it
won't grow forever.

```bash
nav learned show     # see everything nav has learned, and how often
nav learned clear     # wipe the learned history
nav config track off  # stop learning new paths (existing history is kept)
nav config track on   # resume
```

If you'd rather `nav` not redefine `cd` at all, run `nav config track off`
right after installing — the wrapper stays installed (it's cheap to source)
but becomes a no-op the moment tracking is off. If you already have your
own `cd` function in `.bashrc`, whichever one is sourced *last* wins;
reorder your `source` lines if you want both to run.

### Modes: cd, open, or print

All three pickers accept an optional trailing `-o [program]` or `-p` to
change what `Enter` does, same meaning as the top-level flags below:

| Command | Enter does |
|---|---|
| `nav` / `nav i` / `nav f` | `cd`s into the selection. |
| `nav o` / `nav opener [program]` | **Opens** the selection with the configured opener (or `[program]` as a one-off override) instead of `cd`-ing. Same list as bare `nav` (used-first, search-all). |
| `nav p` / `nav print` | **Prints** the selected path to stdout instead of `cd`-ing — handy to eyeball or copy a path. Needs a terminal like every other interactive mode, so it's for looking a path up, not `$(...)` capture in scripts — use `nav <alias> -p` directly for that. |
| `nav -o [program]` | Shorthand for `nav o [program]`. |
| `nav -p` | Shorthand for `nav p`. |
| `nav f -o [program]` / `nav f -p` | Same open/print behavior, but picking from the learned-paths list instead of aliases. |

```bash
nav -o                  # pick a path, open it with the configured opener
nav -o explorer.exe     # pick a path, open it with this one-off override
nav f -o code           # pick from your cd history, open in VS Code
```

## Command reference

### Navigation

| Command | Description |
|---|---|
| `nav` | Interactive: your most-used aliases; type to search all (see above). |
| `nav i` / `nav interactive` | Interactive: every alias you've defined. |
| `nav o` / `nav opener [program]` | Like `nav`, but `Enter` opens instead of `cd`. |
| `nav p` / `nav print` | Like `nav`, but `Enter` prints the path instead of `cd`. |
| `nav f` / `nav frequent` | Interactive: paths learned from your `cd` history, no aliases needed. |
| `nav -o [program]` | Same as `nav o`. |
| `nav -p` | Same as `nav p`. |
| `nav <alias>` | `cd` into the path defined by `<alias>`. |
| `nav <alias> -o [program]` | Open the alias path with the configured opener, or `[program]` as a one-off override. |
| `nav <alias> -p` | Print the alias path instead of `cd`-ing — for scripts: `cd "$(nav proj -p)"`. |
| `nav <alias> -x <cmd> [args...]` | Run `<cmd>` with its cwd set to the alias path, **without** changing your shell's current directory. |

### Alias management

| Command | Description |
|---|---|
| `nav set [--alias <a>] [--path <p>]` | Bookmark `<p>` (defaults to `$PWD`) as `<a>` (defaults to the folder name — a name collision with a *different* existing path gets a numeric suffix, e.g. `my-project2`). Updates it if it already exists. |
| `nav unset <a>` | Remove alias `<a>` (and its usage stats). |
| `nav list` | List all aliases and their paths (`~`-shortened; broken ones marked `[missing]`). |
| `nav prune [-y]` | List aliases whose path no longer exists and remove them (prompts unless `-y`/`--yes`). |
| `nav export [--name <file>]` | Export aliases to `<file>` (default: `navm_export_YYYY-MM-DD.conf`). |
| `nav import <file>` | Import/merge `alias=path` lines from `<file>`. |

### Stats

| Command | Description |
|---|---|
| `nav usage show` / `nav usage clear` | Show or reset how often/recently each **alias** was used. |
| `nav learned show` / `nav learned clear` | Show or reset **`nav f`'s** auto-tracked `cd` history. |

### Configuration

| Command | Description |
|---|---|
| `nav config opener [<cmd>\|ASK]` | Show, or set, the default opener used by `nav <alias> -o`. `ASK` prompts from a list each time. |
| `nav config openers add "<desc> - <cmd>"` | Add an opener to the `ASK` list. |
| `nav config openers remove <n>` | Remove opener number `<n>`. |
| `nav config openers list` | List configured openers. |
| `nav config page_size [<n>]` | Show, or set, how many results interactive mode shows per page (default `10`). |
| `nav config track [<on\|off>]` | Show, or set, whether `cd` feeds `nav f`'s learned history (default `on`). |
| `nav config show` | Print the full configuration. |
| `nav help` | Show usage help. |

Tab completion is registered automatically for aliases and subcommands once
the script is sourced.

> **Reserved names:** `set`, `unset`, `list`, `prune`, `export`, `import`,
> `config`, `usage`, `learned`, `help`, `i`, `interactive`, `o`, `opener`,
> `p`, `print`, `f`, `frequent`, `-o`, and `-p` are all subcommands, not
> just alias names — an alias sharing one of these names can't be reached
> by typing it bare (`nav <alias> ...` with extra args still works).

## Examples

```bash
# Bookmark and jump (auto-named from the folder)
cd ~/work/infra-repo && nav set
nav infra-repo

# ...or don't bookmark it at all — just cd there a few times, then:
nav f

# Open instead of cd (e.g. in a file manager on Windows/WSL)
nav config opener explorer.exe
nav infra-repo -o

# Ask which opener to use every time
nav config openers add "VS Code - code"
nav config openers add "Explorer - explorer.exe"
nav config opener ASK
nav infra-repo -o

# Run a one-off command there without leaving your shell
nav infra-repo -x git status
nav infra-repo -x ls -la

# Scripting: resolve an alias to a path
cd "$(nav infra-repo -p)"

# Back up and restore aliases
nav export --name my-aliases.conf
nav import my-aliases.conf

# Interactive picker with bigger pages, fuzzy-search a path
nav config page_size 15
nav i
```

## Housekeeping

Moved or deleted a bookmarked folder? `nav list` and the picker both flag
it with `[missing]`. Clean up in one shot:

```bash
nav prune          # lists broken aliases, asks to confirm
nav prune -y       # same, no prompt
```

Or delete one on the spot while browsing: highlight it in the picker and
press `Ctrl-D` (works in `nav f` too, to forget a learned path).

Curious what's actually earning its keep, or want a clean slate:

```bash
nav usage show      # alias visit counts
nav usage clear
nav learned show     # cd history nav has picked up on its own
nav learned clear
```

## Uninstall

```bash
sed -i '\|bashrc/nav|d; \|\.nav\.sh|d' ~/.bashrc
rm -f ~/.nav.sh ~/.navm_aliases ~/.navm_config ~/.navm_usage ~/.navm_frecent
```

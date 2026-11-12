# trackr — live Jira time tracking via Timetracker

`trackr` is a single self-contained bash file (`bashrc/trackr`) that adds a
`trackr` function to your shell. Give it a Jira ticket; it validates the ticket,
opens a worklog through the Timetracker (everit) public REST API, and keeps it
alive — bumping the logged duration every minute with a live elapsed-time
display. Press `Ctrl-C` to stop and save the final duration.

It writes one file of its own: `~/.config/trackr/config` (your credentials,
`chmod 600`).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/bashrc/trackr -o ~/.trackr.sh \
  && sed -i '\|source .*/\.trackr\.sh|d' ~/.bashrc \
  && echo 'source "$HOME/.trackr.sh"' >> ~/.bashrc \
  && source ~/.bashrc
```

Re-running it updates `trackr` without duplicating the line in `.bashrc`.

From a clone instead:

```bash
echo 'source "/path/to/dotfiles/bashrc/trackr"' >> ~/.bashrc
```

Needs `bash`, `curl` and `jq`.

## First run

The first run launches an interactive setup that stores credentials in
`~/.config/trackr/config`. You'll be asked for:

| Value | Where to get it |
|-------|-----------------|
| Jira base URL | e.g. `https://your-org.atlassian.net` |
| Atlassian e-mail | your Atlassian account e-mail |
| Atlassian API token | https://id.atlassian.com/manage-profile/security/api-tokens |
| Timetracker API token | Timetracker ▸ My Preferences ▸ REST API ▸ **+** (an admin must enable token creation first) |

Re-run it any time with `trackr --setup`.

## Usage

```bash
trackr <TICKET> [options]
```

| Flag | Description |
|------|-------------|
| `-d`, `--desc <text>` | Worklog description |
| `-t`, `--tag <name>` | Apply a tag/label by name (repeatable) |
| `--no-billable` | Mark the worklog as non-billable |
| `--list-tags` | List available Timetracker tags |
| `--setup` | Re-run the interactive setup |
| `--config` | Show current config (tokens masked) |
| `--diag` | Verbose mode (print HTTP calls) |
| `-h`, `--help` | Show help |
| `-v`, `--version` | Show version |

## Examples

```bash
# Start tracking a ticket by key
trackr PROJ-123

# From a full browse URL, with a description
trackr https://your-org.atlassian.net/browse/PROJ-123 -d "checkout fix"

# Apply a tag (some orgs require one)
trackr PROJ-123 -t Backend

# List the tags available in your org
trackr --list-tags
```

## Notes

- Some orgs make a worklog tag **required**. If creating a worklog fails with a
  `worklogTagIds` required error, pass `-t <tag>` (see `--list-tags`).
- Credentials live only in `~/.config/trackr/config`. Keep that file private.
- The worklog duration syncs once a minute (`TRACKR_POLL` to change), so if the
  terminal dies unexpectedly the last synced minute is already saved.

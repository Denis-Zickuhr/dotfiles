# Unified branch context: name, ticket, and PR in one command

## Description
A configurable alias that consolidates branch identification, ticket tracking,
and pull request status into a single command. Replaces the need for separate
`bn`, `att`, and `info` aliases by providing all context about the current
working branch with support for multiple ticket providers.

## Usage
```
$ git ctx              # Full context (branch + ticket + PR)
$ git ctx -b           # Branch name only
$ git ctx -t           # Ticket link only
$ git ctx -p           # PR info only
```

## Options
| Flag | Description |
|------|-------------|
| `-b, --branch` | Print only the current branch name |
| `-t, --ticket` | Print only the ticket/issue URL |
| `-p, --pr` | Print only the PR status/link |
| `--set-provider <p>` | Configure ticket provider |
| `--set-domain <d>` | Set provider domain/workspace |
| `--set-prefix <url>` | Set a custom URL prefix (overrides provider) |
| `--show-config` | Display current ctx configuration |
| `--clear` | Remove all ctx configuration |
| `-h, --help` | Show help message |

## Providers
| Provider | Domain/Config | URL Pattern |
|----------|---------------|-------------|
| `jira` | `company.atlassian.net` | `https://<domain>/browse/<PREFIX-123>` |
| `linear` | workspace slug | `https://linear.app/<workspace>/issue/<TEAM-123>` |
| `github-issues` | auto-detected | `https://github.com/<org>/<repo>/issues/<number>` |
| custom (via --set-prefix) | any URL | `<prefix><PREFIX-123>` |

## Quick Setup with Profiles
Pre-built profiles are available in `ctx-profiles/` for instant configuration:

```bash
# Jira (interactive or with argument)
bash ctx-profiles/jira mycompany.atlassian.net

# Linear
bash ctx-profiles/linear my-workspace

# GitHub Issues
bash ctx-profiles/github-issues

# Custom URL
bash ctx-profiles/custom "https://mytracker.com/browse/"
```

## Configuration
All settings are stored in global git config under the `ctx.*` namespace:

```bash
git config --global ctx.provider "jira"
git config --global ctx.domain "mycompany.atlassian.net"
```

## Example Output
```
$ git ctx
MAG-1234-fix-redis-connection

🎫 https://mycompany.atlassian.net/browse/MAG-1234
🔗 https://github.com/org/repo/pull/56
```

## Branch Convention
The ticket prefix is extracted using the pattern `^[A-Za-z]+-[0-9]+` from the
branch name. Branches should follow: `[PREFIX]-[NUMBER]-description`

Examples: `MAG-1234-fix-bug`, `ENG-42-add-auth`, `FIX-78-memory-leak`

## Internal Logic
1. Extracts branch name via `git rev-parse --abbrev-ref HEAD`
2. Parses ticket prefix from branch using regex
3. Resolves ticket URL based on configured provider
4. Queries PR status via `gh` CLI (if available)
5. Outputs combined or individual sections based on flags

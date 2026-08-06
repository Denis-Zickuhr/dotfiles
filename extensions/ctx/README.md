# git ctx — Show contextual information about the current branch

## Description

Displays contextual information about the current branch including the branch name, associated ticket/issue link, and pull request info. Supports multiple ticket providers (Jira, Linear, GitHub Issues) with configurable settings stored in global git config.

## Usage

```bash
git ctx [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-b`, `--branch` | Show only the branch name |
| `-t`, `--ticket` | Show only the ticket/issue link |
| `-p`, `--pr` | Show only the PR info |
| `--set-provider <p>` | Set the ticket provider (jira, linear, github-issues) |
| `--set-domain <d>` | Set the provider domain/workspace |
| `--set-prefix <x>` | Set a custom URL prefix (overrides provider logic) |
| `--show-config` | Show current ctx configuration |
| `--clear` | Remove all ctx configuration |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Providers

| Provider | Description |
|----------|-------------|
| `jira` | Atlassian Jira (requires domain) |
| `linear` | Linear.app (uses team from branch prefix) |
| `github-issues` | GitHub Issues (auto-detects from remote) |

## Examples

```bash
# Show full context (branch, ticket, PR)
git ctx

# Configure Jira as ticket provider
git ctx --set-provider jira
git ctx --set-domain mycompany.atlassian.net

# Show only the ticket URL
git ctx --ticket

# Show only PR info (requires gh CLI)
git ctx --pr

# Use a custom URL prefix
git ctx --set-prefix "https://mytracker.com/issues/"

# View current configuration
git ctx --show-config

# Clear all ctx settings
git ctx --clear
```

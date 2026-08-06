# git pr — List pull requests for the current branch or create new ones

## Description

Shows pull requests associated with the current branch using the GitHub CLI (`gh`). If no PRs exist, generates a compare URL to create one. Can also list all PRs authored by you across the repository.

Requires the [GitHub CLI](https://cli.github.com/) (`gh`) to be installed and authenticated.

## Usage

```bash
git pr [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-a`, `--all` | List all PRs authored by you |
| `-b <branch>` | Specify base branch (defaults to repo default branch) |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Show PRs for current branch (or a create link if none exist)
git pr

# List all your PRs in the repository
git pr -a

# Use a specific base branch for the compare URL
git pr -b main
```

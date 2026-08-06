# Show your recent git commits across all branches for daily standups

## Description

`git standup` displays a formatted summary of your recent commits across all branches. It auto-detects the current user via `git config user.email` and shows color-coded output with dates, branch names, and commit messages. Ideal for preparing daily standup reports.

## Usage

```bash
git standup [options]
```

## Options

| Flag | Description |
|------|-------------|
| `--week` | Show commits from the last 7 days |
| `--days N` | Show commits from the last N days |
| `--all` | Show commits from all authors |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Show your commits from the last 24 hours
git standup

# Show your commits from the last week
git standup --week

# Show your commits from the last 3 days
git standup --days 3

# Show commits from all authors in the last 24 hours
git standup --all

# Show commits from all authors in the last week
git standup --all --week
```

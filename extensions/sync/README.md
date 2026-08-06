# Sync current branch with the default remote branch

## Description

`git sync` fetches from origin and rebases (or merges) the default branch (`origin/main` or `origin/master`) onto your current branch. It automatically detects the default branch, stashes uncommitted changes before the operation, and provides clear instructions if conflicts arise.

## Usage

```bash
git sync [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |
| `-b <branch>` | Sync with a specific branch instead of the default |
| `--merge` | Use merge instead of rebase |

## Examples

```bash
# Rebase current branch onto the default branch (main or master)
git sync

# Use merge instead of rebase
git sync --merge

# Sync with a specific branch
git sync -b develop

# Merge a specific branch instead of rebasing
git sync --merge -b staging
```

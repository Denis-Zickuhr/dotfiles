# Quick WIP commits for git

## Description

`git wip` stages all changes (tracked and untracked) and creates a commit with a `WIP:` prefix. It provides commands to undo the last WIP commit and list all WIP commits on the current branch.

## Usage

```bash
git wip              # Commit everything as "WIP: <branch-name>"
git wip -m "msg"     # Commit everything as "WIP: msg"
git wip --pop        # Undo last commit if it's a WIP (reset --mixed)
git wip --list       # List WIP commits on current branch
```

## Options

| Flag | Description |
|------|-------------|
| (no args) | Stage all changes and commit as `WIP: <branch-name>` |
| `-m <msg>` | Stage all changes and commit with a custom WIP message |
| `--pop` | Undo the last commit if it is a WIP (mixed reset) |
| `--list` | List all WIP commits on the current branch |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Save current work quickly before switching branches
git wip
# ✔ Committed: WIP: feature/login

# Restore WIP changes after coming back
git wip --pop
# ✔ WIP commit undone. Changes returned to working tree.

# Check if there are any WIP commits to clean up
git wip --list
# abc1234 WIP: feature/login
# def5678 WIP: fix typo in auth

# Save with a descriptive message
git wip -m "halfway through refactor"
# ✔ Committed: WIP: halfway through refactor
```

# git split — Split a branch into one branch (and PR) per commit

## Description

Takes a source branch and, for each commit unique to it, creates a new branch
containing just that single commit. Each branch is named using **reverse cbn**
(the inverse of the `cbn` extension): the commit message is turned back into a
branch name. Branches are pushed and, when the GitHub CLI (`gh`) is available, a
PR is opened for each one against the base branch.

This is the inverse of squashing: one fat branch in, many single-commit branches
out — each reviewable on its own.

## Usage

```bash
git split <branch> [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-b`, `--base <branch>` | Base branch for fork point and PR (default: repo default) |
| `--no-pr` | Skip PR creation (branches only) |
| `--force` | Force push created branches |
| `-n`, `--dry-run` | Show what would happen, make no changes |
| `-h`, `--help` | Show help |
| `-v`, `--version` | Show version |

## Reverse cbn naming

The commit message is mapped back to a branch name, mirroring `cbn`:

| Commit message | Branch name |
|----------------|-------------|
| `JIRA-123 - feat: add login` | `JIRA-123-feat-add-login` |
| `feat(api): add login` | `feat-api-add-login` |
| `fix: broken navbar` | `fix-broken-navbar` |
| `some free text subject` | `some-free-text-subject` |

If a generated name collides with an existing local or remote branch, a numeric
suffix is appended (`-2`, `-3`, ...).

## Examples

```bash
# Split v1.0.0 into one branch + PR per commit, using the repo default base
git split v1.0.0

# Use main as the fork point and PR base
git split v1.0.0 -b main

# Just create and push the branches, no PRs
git split v1.0.0 --no-pr

# Preview the branch names without touching anything
git split v1.0.0 --dry-run
```

## Flow

1. Detects commits unique to `<branch>` relative to the base (via merge-base).
2. Derives a branch name from each commit message (reverse cbn).
3. Creates each branch off the base and cherry-picks the single commit.
4. Pushes and opens a PR (title/body = commit subject) when `gh` is available.

On any failure (checkout, cherry-pick conflict, push), it rolls back: deletes
the local branches it created, returns you to your starting branch, and lists
any branches that were already pushed so you can remove them manually.

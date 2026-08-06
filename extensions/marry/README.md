# git marry — Create a branch, commit, and push in one command

## Description

Combines branch creation, staging, committing (via `git cbn`), and pushing into a single workflow. Stashes uncommitted changes, runs `git fresh` to update main, creates the new branch, restores changes, stages files matching a pattern, commits using conventional commit format derived from the branch name, and pushes to origin. Optionally adds the branch to quiver if available.

## Usage

```bash
git marry -b <branch-name> [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-b`, `--branch <name>` | **(Required)** New branch name |
| `-p`, `--pattern <path>` | File patterns to stage (defaults to `src`) |
| `-f`, `--force` | Push without confirmation |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Create branch, stage src/, commit, and push (with review prompt)
git marry -b feat-add-login

# Stage specific patterns and force push
git marry -b fix-typo -p "*.md" -f

# Stage multiple patterns
git marry -b chore-update-deps -p package.json -p yarn.lock

# Force push without confirmation
git marry -b JIRA-456-refactor-auth -f
```

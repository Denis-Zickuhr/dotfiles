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

## KIP mode (`--kip`)

`git marry --kip` runs the whole flow through the Kai Interface Protocol
(JSON Lines on stdout/stdin) so Kai can draw it as native screens. No `kai`
binary or `jq` needed.

1. **What goes in the commit?** — the focus is the diff, and nothing is touched yet.
   Edit the **paths** (comma-separated; empty means all changes) and the **files**
   table lists every changed file, marked ✓ when it goes in the commit, refreshing
   as you type. Chips act on the selected file: **Show diff**, **Include** (force it
   in), **Exclude** (keep it out; its change stays in the working tree) and
   **Drop file** (discards the change, with a danger confirmation). Manual
   include/exclude wins over the paths and is kept if you come back with Back.
2. **Branch and pull request** — a read-only table of the files that will be
   committed, then branch name, commit message, PR title (empty = the commit
   message), one field per `{{ask}}` question of the template, a **PR body** field (write
   the body yourself; when filled it replaces the template and its questions),
   labels, *draft*,
   *skip the PR* and, under *Advanced*, scope and *skip hooks*. **Preview body**
   renders the template. **Back** returns to the files screen; the button does
   everything below.
3. A checklist runs stash → sync → branch → restore → stage → commit → push → quiver → PR.
   Staging resets the index and adds exactly the files from the table.
4. The PR is opened through `git pr` >= 2.1.0, or `gh` directly, and a result card
   offers **Open the PR**. Cancelling any time before step 3 changes nothing.

Unlike the terminal flow, the PR template is read from `pr.template` first
(`marry.template` is the fallback), matching `git pr`.

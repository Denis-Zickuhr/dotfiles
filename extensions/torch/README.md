# Massively deletes local branches and cleans up your workspace

## Description
A "scorched earth" cleanup utility designed to purge stale local feature 
branches. It automates the process of stashing pending work, deleting 
non-essential branches, and synchronizing your local main branch with 
the remote repository in a single command.

## Usage
$ git torch [options]

## Options
-p, --pattern <regex>    Additional branch names to protect from deletion.
-s, --safe               Preview the list of branches and confirm before "torching".
-f, --force              Uses '-D' instead of '-d' to force delete unmerged branches.
-h, --help               Displays the command usage and flags.

## Internal Logic
1. **Safety First:** Automatically stashes any uncommitted changes to the index.
2. **Protection:** By default, it refuses to delete `master`, `main`, or `develop`.
3. **Detection:** Dynamically identifies your repository's primary branch via `origin/HEAD`.
4. **Execution:** Iterates through all local branches that don't match the ignore patterns and attempts deletion.
5. **Final Sync:** Switches to the main branch, prunes remote-tracking references (`fetch --prune`), and performs a `pull` to ensure you are up to date.

## Example
$ git torch --safe
> Branches to be torched (12):
> feat/old-ui
> fix/bug-99
> ...
> Confirm? (y/yes to confirm): y
>
> Torched 12 branches 🔥🔥🔥
> You are now on main (updated).

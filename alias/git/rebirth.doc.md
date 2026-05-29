# Resets the current branch to its remote state with an optional safety stash

## Description
A "hard reset" utility designed to discard local commits and align your branch 
exactly with the remote server. It is particularly useful when local history 
has diverged significantly or when you want to undo a series of local 
experiments and start fresh from the latest origin state.

## Usage
$ git rebirth [options]

## Options
--safe, -s    **Safe Mode**: Automatically stashes uncommitted changes before 
              performing the hard reset and restores them afterward. This 
              preserves your work-in-progress while resetting the commit history.
-h, --help    Displays the command usage and examples.

## Internal Logic
1. **Context Awareness:** Identifies the current branch name via `rev-parse`.
2. **Safety Check:** If `--safe` is active, it checks for a dirty worktree (staged or unstaged changes) and pushes them to a temporary stash.
3. **Synchronization:** Executes `git fetch origin` to ensure the local tracking data is up to date.
4. **Hard Reset:** Forcefully moves the branch pointer to match `origin/[current-branch]`.
5. **Restoration:** If a stash was created during the safe mode process, it attempts to `pop` it back onto the workspace (falling back to `apply` on conflict).

## Example
$ git rebirth --safe
> 1. Your uncommitted changes are stashed.
> 2. Local commits are deleted to match the server.
> 3. Your changes are restored on top of the clean remote state.

# Manage a curated list of active branches with smart auto-stashing

## Description
A sophisticated branch-management tool that maintains a "quiver" (a prioritized list) of your most relevant branches. It simplifies context switching by automatically stashing uncommitted changes when you leave a branch and restoring them specifically when you return, ensuring a seamless workflow across multiple features.

## Key Concept: Smart Switching
Unlike standard 'git checkout', Quiver tracks work-in-progress per branch. 
When switching:
1. **Departure:** It creates a unique stash named after the current branch.
2. **Arrival:** It pulls/fetches updates and automatically pops the specific 
   stash belonging to the target branch (if one exists).

## Usage
$ git quiver                 # Open interactive selection menu
$ git quiver [index]         # Fast switch to index N in your list
$ git quiver -a [branch]     # Add a branch to your list

## Options
-a, --add [branch]     Add a branch (defaults to current) to the list.
-r, --remove [index]   Remove a branch from the list by its index.
-f, --filter [regex]   Filter origin branches (e.g., --filter "feat/").
-t, --top              Move the current branch to the top of the list.
-b, --bottom           Move the current branch to the bottom of the list.
-m, --clean-merged     Remove merged branches from your quiver.
-e, --empty            Clear all branches from your quiver.
-h, --help             Shows help page.

## Workflow Example
1. You are on `feat/ui`. Use `git quiver -a` to pin it.
2. Need to fix a bug? `git quiver -f` -> pick `main`.
3. Your `ui` changes are automatically stashed.
4. Finished bugfix? `git quiver 1` (to return to ui).
5. Your `ui` changes are automatically restored exactly where you left off.
6. Clean up finished work? `git quiver -m` removes merged branches automatically.

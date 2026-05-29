# Moves uncommitted changes to a new branch off a fresh main

## Description
A comprehensive workflow utility designed for the "oops, I started working on the wrong branch" scenario. It stashes your current uncommitted changes, synchronizes the main branch, creates a new feature branch from that fresh state, applies your changes, and performs an automated commit.

## Usage
$ git marry -b <branch-name> [options]

## Options
-b, --branch <name>     (Required) The name of the new branch to be created.
-p, --pattern <path>    File patterns to stage (defaults to "src").
-f, --force             Skips the review prompt and pushes directly to origin.
-h, --help              Displays the command usage.

## Internal Logic
1. **Stash:** Safely stores uncommitted work in a temporary stash.
2. **Sync:** Runs 'git fresh' to ensure the local main branch is up to date.
3. **Branch:** Creates and switches to the new target branch.
4. **Pop:** Restores the stashed work onto the new branch.
5. **Stage & Commit:** Adds files matching the patterns and runs 'git cbn' for automated conventional commits.
6. **Push & Quiver:** Pushes to origin (optional/forced) and triggers 'git quiver' if available.

## Error Handling
If any step fails (e.g., merge conflicts during stash pop or commit errors), the script performs a rollback: it resets changes, returns to the original branch, deletes the failed new branch, and restores your work via stash pop.

## Example
$ git marry -b feat/new-dashboard -p "src/components"
> Safely migrates your component work to a clean feature branch and commits it.

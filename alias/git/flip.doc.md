# Smartly toggle between your current branch and the main branch

## Description
A context-aware switcher that allows you to "flip" to the main branch 
(automatically detected from origin/HEAD) and back again. It remembers 
your feature branch using a global git configuration, making it more 
robust than 'git checkout -'.

## Usage
$ git flip

## Options
--help, -h       Show the help message.
--clear, -c      Manually clear the stored feature branch reference.
--set, -s <br>   Manually set a specific branch to flip back to.

## Internal Logic
1. Detects your main branch (e.g., 'main' or 'master') via origin/HEAD.
2. If you are on a feature branch:
   - Stores the branch name in 'git-flip.prevBranch'.
   - Checks out the main branch.
3. If you are on the main branch:
   - Retrieves the stored branch from config.
   - Checks out that branch and clears the storage.

## Example Workflow
$ (on branch feature/auth) git flip
> Switched to main branch (main)

$ (on branch main) git flip
> Switched back to previous branch (feature/auth)

# GitHub Pull Request management and status utility

## Description
A productivity wrapper around the GitHub CLI (`gh`) to track, list, or initiate 
Pull Requests directly from the terminal. It eliminates the friction of 
navigating the web UI to find PR links or create new comparisons by 
generating context-aware GitHub URLs.

## Usage
$ git pr [options]

## Options
-a, --all             Lists all Pull Requests authored by you across the repository.
-b <base_branch>      Specifies a custom base branch for the PR comparison link.
-h, --help            (Internal bash logic)

## Internal Logic
1. **List Mode:** If `-a` is used, it queries all your PRs using JSON formatting.
2. **Status Check:** Queries the GitHub API for any PRs matching the current branch.
3. **Creation Fallback:** If no open PR is found for the current branch:
   - It identifies the repository's default branch (via `gh repo view`).
   - It parses the remote origin URL to determine the GitHub owner/repo path.
   - It outputs a 'compare' URL for the web UI to quickly open a new PR.

## Requirements
Requires the GitHub CLI (`gh`) to be installed and authenticated.

## Example
$ git pr
> open: feat: add dashboard widgets -> https://github.com/user/repo/pull/42

$ git pr -b staging
> No open PR found. Create new:
> https://github.com/user/repo/compare/staging...feat/my-branch?expand=1

# Conventional commit automation based on branch name structure

## Description
This extension automates the 'git commit' process by parsing your current 
branch name. It follows the Conventional Commits specification and 
automatically extracts ticket prefixes (e.g., MAG-123) and commit types.

## Branch Conventions
The script expects one of the following patterns:
1. [PREFIX]-[TYPE]-[DESCRIPTION] (e.g., MAG-123-feat-login-form)
2. [TYPE]-[DESCRIPTION] (e.g., fix-header-spacing)

Supported types: feat, fix, chore, docs, style, refactor, perf, test, build, ci, revert.

## Usage
$ git cbn [options]

## Options
-m, --message <msg>    Overrides the branch description with a custom message.
-op, --omit-prefix     Forces the removal of the ticket prefix from the commit.
-h, --help             Displays the internal help message.

## Logic & Examples
- Branch: `MAG-800-feat-api-auth`
  Result: `git commit -m "MAG-800 - feat: api auth"`

- Branch: `fix-broken-link`
  Result: `git commit -m "fix: broken link"`

- Command: `git cbn -m "initial work"` on branch `MAG-100-feat-ui`
  Result: `git commit -m "MAG-100 - feat: initial work"`

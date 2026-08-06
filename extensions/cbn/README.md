# git cbn — Generate commit messages from branch names using conventional commits

## Description

Automatically generates a conventional commit message based on the current branch name. Extracts the commit type and description from the branch, and optionally includes a ticket prefix.

Branch format: `[PREFIX-]<type>-<description>`

Supported types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `revert`

## Usage

```bash
git cbn [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-m`, `--message <msg>` | Provide a custom commit message body |
| `-op`, `--omit-prefix` | Omit the prefix (e.g., ticket number) from the commit |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Branch: JIRA-123-feat-add-login → commit "JIRA-123 - feat: add login"
git cbn

# Branch: fix-broken-navbar → commit "fix: broken navbar"
git cbn

# Custom message body instead of branch description
git cbn -m "implement OAuth2 flow"

# Omit the ticket prefix from commit message
git cbn --omit-prefix
```

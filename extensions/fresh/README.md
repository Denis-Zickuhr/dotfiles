# git fresh — Switch to main branch, fetch and pull latest changes

## Description

Switches to the main branch, fetches from origin, and pulls the latest changes. Automatically stashes uncommitted changes before switching and restores them after pulling. Detects the main branch from `origin/HEAD`, falling back to `main` if not set.

## Usage

```bash
git fresh [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Switch to main, fetch, and pull
git fresh

# Works even with uncommitted changes (auto-stashes and restores)
git fresh
```

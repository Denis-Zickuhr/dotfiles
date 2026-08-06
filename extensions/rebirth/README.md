# git rebirth — Reset current branch to match remote origin

## Description

Performs a hard reset of the current branch to its remote counterpart (`origin/<branch>`). Fetches from origin before resetting. In safe mode, stashes uncommitted changes before the reset and restores them afterward. Without safe mode, warns about uncommitted changes and asks for confirmation.

## Usage

```bash
git rebirth [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-s`, `--safe` | Stash changes before resetting (auto-restores after) |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Reset branch to origin (prompts if dirty)
git rebirth

# Safely reset: stash changes, reset, then restore
git rebirth --safe
```

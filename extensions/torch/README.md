# git torch — Delete local branches that are no longer needed

## Description

Cleans up local branches by deleting all except protected ones (main, master, develop by default). Switches to the main branch, prunes remote references, and pulls the latest changes. Supports safe mode for confirmation before deletion and force mode for unmerged branches.

## Usage

```bash
git torch [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-p`, `--pattern <regex>` | Additional branches to protect (appended to default ignore list) |
| `-s`, `--safe` | Confirm before deleting branches |
| `-f`, `--force` | Force delete unmerged branches (uses `git branch -D`) |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Delete all non-protected local branches
git torch

# Confirm before deleting
git torch --safe

# Force delete unmerged branches
git torch -f

# Protect additional branches from deletion
git torch -p "release\|staging"

# Combine safe mode with force
git torch -s -f
```

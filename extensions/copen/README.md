# git copen — Open modified files in your configured editor

## Description

Opens all modified, added, renamed, or copied files in the working tree using the configured editor. Handles filenames with spaces correctly and skips deleted or untracked files.

Editor resolution order:
1. `git config core.editor`
2. `$EDITOR` environment variable
3. `code` (VS Code)
4. `vim`

## Usage

```bash
git copen [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-e`, `--editor <editor>` | Use specified editor instead of the configured one |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Open all modified files in the default editor
git copen

# Open modified files in vim
git copen -e vim

# Open modified files in a specific editor
git copen --editor nvim
```

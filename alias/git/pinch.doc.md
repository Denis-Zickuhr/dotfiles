# Opens, edits, reverts, or amends files changed since the fork point

## Description
A multi-mode tool for working with files that changed relative to upstream.
Opens files in your editor, supports intelligent amending into the last commit,
reverting specific files to upstream state, and soft-resetting for squash workflows.

## Usage
```
$ git pinch              # Open all changed files
$ git pinch -a           # Edit mode: open, edit, amend into last commit
$ git pinch -r           # Revert all changed files to upstream state
$ git pinch -r src/f.ts  # Revert a specific file
$ git pinch -k           # Open files, then soft-reset (squash)
$ git pinch -s -a        # Select which files to edit + amend
```

## Modes

### Default (open)
Opens all changed files in the configured editor. No side effects.

### Amend (`-a, --amend`)
1. Opens changed files in editor (with `--wait`)
2. After closing, detects modified files
3. Asks to amend changes into the last commit (`--no-edit`)

Ideal for quick fixes on existing commits without creating new ones.

### Revert (`-r, --revert [file]`)
1. Shows files that will be reverted
2. Asks for confirmation
3. Checks out the file(s) from the merge-base, restoring upstream state
4. Changes are staged — commit when ready

Use without argument to revert all, or pass a specific file path.

### Keep (`-k, --keep`)
Opens files first, then soft-resets all commits back to the merge base.
Changes remain staged for recommitting (squash workflow).

## Options
| Flag | Description |
|------|-------------|
| `-a, --amend` | Amend mode: edit then amend last commit |
| `-r, --revert [file]` | Revert mode: restore files to upstream state |
| `-k, --keep` | Open + soft-reset to merge base |
| `-s, --select` | Interactive file selector before any mode |
| `-e, --editor <ed>` | Override auto-detected editor |
| `-u, --upstream <br>` | Override upstream branch (default: auto from origin/HEAD) |
| `-h, --help` | Show help |
| `-v, --version` | Show version |

## Editor Resolution
1. `git config core.editor`
2. `$EDITOR` environment variable
3. `code` (if available)
4. `vim`

## Examples

### Fix a typo in existing work
```bash
$ git pinch -a
# Editor opens with all changed files
# Fix the typo, save, close
# → "Amend these into the last commit? [Y/n]" → y
# ✓ Last commit amended
```

### Undo changes to a specific file
```bash
$ git pinch -r src/config.ts
# ↩ src/config.ts
# "Continue? [y/N]" → y
# ✓ File reverted to upstream state (staged)
```

### Cherry-pick which files to work with
```bash
$ git pinch -s
# 1) src/api.ts
# 2) src/model.ts
# 3) tests/api.test.ts
# > 1 3
# Opens only src/api.ts and tests/api.test.ts
```

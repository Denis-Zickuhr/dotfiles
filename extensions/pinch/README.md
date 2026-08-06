# Open, edit, and ship files changed in the current branch

## Description
A multi-mode tool for working with files changed relative to upstream.
Opens files in your editor, pops commits for editing, ships changes to
origin, or reverts files to upstream state.

## Workflow

The main workflow is a two-step edit cycle:

```bash
git pinch --pop      # 1. Pop commits, open files for editing
# ... edit files ...
git pinch --ship     # 2. Commit + push to origin
```

## Usage
```
$ git pinch              # Open changed files (no side effects)
$ git pinch --pop        # Pop commits + open for editing
$ git pinch --ship       # Stage, commit/amend, push
$ git pinch --revert     # Revert all files to upstream
$ git pinch -r src/f.ts  # Revert a specific file
```

## Modes

### Default (open)
Opens all changed files in the editor. No git operations performed.

### Pop (`-p, --pop`)
1. Soft-resets all commits back to the merge base
2. Opens the changed files in editor
3. Changes remain staged for re-committing

This "cracks open" your commits so you can edit freely.

### Ship (`-s, --ship`)
1. Stages all modified files
2. If commits exist since merge base: amends the last commit
3. If no commits exist: creates a new commit (suggests message from branch name)
4. Pushes to origin with `--force-with-lease`

This seals your edits and sends them to the remote.

### Revert (`-r, --revert [file]`)
Restores files to their upstream state (checks out from merge base).
Pass a specific file path or omit to revert all changed files.

## Options
| Flag | Description |
|------|-------------|
| `-p, --pop` | Pop commits + open for editing |
| `-s, --ship` | Stage + commit/amend + push |
| `-r, --revert [file]` | Revert files to upstream state |
| `-i, --interactive` | Interactively select which files to use |
| `-e, --editor <ed>` | Override editor |
| `-u, --upstream <br>` | Override upstream branch |
| `-f, --force` | Skip confirmations |
| `-h, --help` | Show help |
| `-v, --version` | Show version |

## Editor Resolution
1. `git config core.editor`
2. `$EDITOR` environment variable
3. `code` (if available)
4. `vim`

## Examples

### Quick edit cycle
```bash
$ git pinch --pop
# ✓ Popped 3 commit(s). Changes are staged.
# Opening files for editing...
# (editor opens, you make fixes, close editor)

$ git pinch --ship
# Applying 4 file(s):
#   + src/api.ts
#   + src/model.ts
# ✓ Amended into: feat: add user endpoint
# Push to origin/feat-add-user? [Y/n] y
# ✓ Pushed to origin/feat-add-user
```

### Revert a mistake
```bash
$ git pinch -r src/config.ts
# ↩ src/config.ts
# Continue? [y/N] y
# ✓ src/config.ts
# Files reverted. Changes are staged.
```

### Select specific files
```bash
$ git pinch -i
# 1) src/api.ts
# 2) src/model.ts
# 3) tests/api.test.ts
# > 1 3
# (opens only selected files)
```

# shh 🤫 — cause nobody saw what you did

## Description

`git shh` stages your changes, folds them into the **last commit** with `--amend`,
and force-pushes the branch. It uses `--force-with-lease` by default, so it refuses
to overwrite the remote if someone else pushed in the meantime — safe by default,
loud only when you ask for it with `-f`.

Perfect for quietly fixing that commit you *just* pushed before anyone notices.

## Usage

```bash
git shh                  # Stage all changes, amend, safe force-push (asks first)
git shh -p src -p lib    # Stage only the given paths
git shh -y               # Skip the confirmation prompt
git shh -f               # Use plain --force instead of --force-with-lease
```

## Options

| Flag | Description |
|------|-------------|
| (no args) | Stage all changes and amend into the last commit |
| `-p`, `--path <path>` | Stage a specific path (repeatable) |
| `-y`, `--yes` | Skip the confirmation prompt |
| `-f`, `--force` | Use plain `--force` instead of `--force-with-lease` |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Fix the commit you just pushed, quietly
git shh
# shh 🤫
#  M src/app.js
# Amend into last commit and force-push? [y/N] y
# ✔ shh 🤫 done. feature/login force-pushing

# Only stage part of the tree
git shh -p src/config.js

# No prompts, just do it
git shh -y
```

## Safety notes

- `git shh` **rewrites history** (`--amend`) and **force-pushes**. Only use it on
  branches that are yours, or where rewriting is expected (e.g. open PR branches).
- The default `--force-with-lease` protects teammates: the push is rejected if the
  remote moved since your last fetch. Prefer this over `-f`.
- There is no undo. Use `git reflog` if you need to recover a lost commit.

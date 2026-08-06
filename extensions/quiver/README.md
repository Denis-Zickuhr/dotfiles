# git quiver — Interactive branch manager

## Description

Manages a per-repository list of active branches (the "quiver") for quick switching. Stashes and restores changes automatically when switching, pulls latest changes on checkout, and supports filtering remote branches. Branches are stored in local git config (`quiver.branch`).

## Usage

```bash
git quiver [index | flags]
```

## Options

| Flag | Description |
|------|-------------|
| `-a`, `--add [branch]` | Add branch to quiver (current branch if empty) |
| `-r`, `--remove <index>` | Remove branch from quiver by display index |
| `-f`, `--filter [regexp]` | Filter and pick from origin branches |
| `-t`, `--top` | Move current branch to top of quiver |
| `-b`, `--bottom` | Move current branch to bottom of quiver |
| `-m`, `--clean-merged` | Remove merged branches from quiver |
| `-e`, `--empty` | Empty the entire quiver |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Interactive Mode

| Input | Action |
|-------|--------|
| `git quiver` | Show quiver and select a branch to switch to |
| `git quiver <n>` | Switch directly to branch at index `n` |
| `git quiver f` | Switch to the default (main) branch |

## Examples

```bash
# Show interactive branch list
git quiver

# Switch to branch at index 2
git quiver 2

# Switch to main branch
git quiver f

# Add current branch to quiver
git quiver -a

# Add a specific branch
git quiver -a feature/login

# Remove branch at index 3
git quiver -r 3

# Pick a branch from origin matching a pattern
git quiver -f "feat.*login"

# Remove all merged branches from quiver
git quiver --clean-merged

# Clear all branches from quiver
git quiver --empty
```

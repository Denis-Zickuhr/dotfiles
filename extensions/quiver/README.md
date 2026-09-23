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
| `--kip` | Speak KIP (Kai Interface Protocol) instead of drawing the TUI |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Interactive Mode

Running `git quiver` opens a **fullscreen picker** (nav-style): a dynamic,
paginated list of your branches with type-to-filter.

| Key | Action |
|-----|--------|
| `↑`/`↓` or `j`/`k` | Move selection |
| `←`/`→` or `h`/`l` | Change page |
| type | Filter branches |
| `Enter` | Switch to the highlighted branch |
| `Tab` | Open **action mode** for the highlighted branch |
| `a` | Add current branch to the quiver |
| `Esc` / `q` | Quit |

### Action mode

`Tab` opens a sub-picker listing the commands that can run against the
highlighted branch:

| Command | Runs |
|---------|------|
| `ctx` | Branch context (ticket + PR status) |
| `pr` | Show/create pull request |
| `hotfix` | Cherry-pick into targets (prompts for targets) |
| `sync` | Sync with upstream (rebase) |

Pick one with `↑`/`↓` and `Enter` to run it; `Esc`/`Tab` goes back.

> **Why Tab and not Ctrl+Enter?** Standard terminals send the *same byte* for
> `Enter` and `Ctrl+Enter`, so they can't be told apart in a TUI. `Tab` is used
> instead because it's unambiguous.

### Direct switching

| Input | Action |
|-------|--------|
| `git quiver <n>` | Switch directly to branch at index `n` |
| `git quiver f` | Switch to the default (main) branch |

## KIP mode (`--kip`)

`git quiver --kip` replaces the terminal picker with the Kai Interface Protocol:
JSON Lines on stdout/stdin, so a KIP host such as Kai can show
the picker as a native screen. Run directly in a terminal it just prints the
protocol messages.

One screen lists the **branch** (default branch, quiver branches, the current one;
searchable and paged). **Switch to branch** (the submit button, like Enter in the
TUI) stashes, checks out and pulls, then ends the session. Everything else is a
**chip**: the screen stays open and each result appears below it, so you can chain
actions and the list refreshes after add/remove.

| Chip | Runs |
|------|------|
| Context | `git ctx` on that branch |
| Sync | `git sync --abort-on-fail` on that branch (asks first) |
| Create or show PR | asks first, then `git pr --force --no-labels` (no prompts) |
| Add current | adds the current branch to the quiver |
| Clean merged | `git quiver -m`: fetches/prunes, then drops merged, closed or deleted branches from the quiver (asks first; branches are not deleted) |
| Remove | removes the branch from the quiver (asks first; only for quiver branches) |

Context, Sync and PR work on the current branch or one from the quiver.

`hotfix` is not offered in this mode: it asks questions on the terminal. The
implementation has no dependency on the `kai` binary or `jq`.

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

# Same picker, as a KIP session (for Kai)
git quiver --kip
```

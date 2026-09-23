# git pr — List pull requests for the current branch or create new ones

## Description

Shows pull requests associated with the current branch using the GitHub CLI (`gh`). If no PRs exist, generates a compare URL to create one. Can also list all PRs authored by you across the repository.

Requires the [GitHub CLI](https://cli.github.com/) (`gh`) to be installed and authenticated.

## Usage

```bash
git pr [options]
```

## Options

| Flag | Description |
|------|-------------|
| `-a`, `--all` | List all PRs authored by you |
| `create` | Create a PR (template body, optional labels) |
| `labels` | List the repo labels, most-used first |
| `-b <branch>` | Specify base branch (defaults to repo default branch) |
| `-t`, `--title <msg>` | PR title (default: last commit subject) |
| `--body <text>` | PR body (skips the template) |
| `--draft` | Open the PR as a draft |
| `-l`, `--label <name>` | Add a label (repeatable; skips the label picker) |
| `--no-labels` | Skip the label step |
| `-f`, `--force` | No prompts (accept defaults) |
| `--kip` | Speak KIP (Kai Interface Protocol) instead of prompting |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Show PRs for current branch (or a create link if none exist)
git pr

# List all your PRs in the repository
git pr -a

# Use a specific base branch for the compare URL
git pr -b main
```

## KIP mode (`--kip`)

`git pr --kip` replaces the terminal prompts with the Kai Interface Protocol
(JSON Lines on stdout/stdin), so a KIP host such as Kai can show the flow as
native screens. It needs neither the `kai` binary nor `jq`.

1. **What to do** — create a PR for this branch, show the PRs of this branch, or
   list all your PRs (the default is "show" when the branch already has a PR).
2. **New pull request** — title, one field per `{{ask}}` question of the
   template, a **PR body** field (write the body yourself; when filled it replaces
   the template and its questions), a searchable multi-select of labels (most-used first), the base
   branch and a *draft* option (plus *push first* when the branch has no
   upstream). The **Preview body** chip renders the template with your answers.
3. A result card with **Open the PR** / **Copy URL**.

Answers to the template questions are never remembered between runs.

Related flags (`--body`, `--draft`, `--label`, `labels`) also work without KIP;
`git marry --kip` uses them to hand over the body and labels it collected.

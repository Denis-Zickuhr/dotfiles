# dotfiles

Small, dependency-free shell tools for the terminal (built with WSL in mind,
but plain Linux/macOS work too):

| Tool | What it is |
|------|------------|
| [git extensions](#git-extensions) | 16 `git <name>` commands for branches, commits, PRs, plus an interactive manager |
| [nav](#nav) | Bookmark directories and jump to them, or let it learn where you `cd` |
| [can](#can) | A junk cleaner: Docker, system leftovers and big files, with a checklist UI |

## Quick install

### git extensions

```bash
bash <(curl -sL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/installer)
```

Opens an interactive picker; choose the extensions you want. Needs `git` and `curl`.

### nav

```bash
curl -fsSL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/bashrc/nav -o ~/.nav.sh \
  && sed -i '\|source .*/\.nav\.sh|d' ~/.bashrc \
  && echo 'source "$HOME/.nav.sh"' >> ~/.bashrc \
  && source ~/.bashrc
```

Then `nav set` in any folder to bookmark it, and `nav` to pick one.

### can

```bash
curl -fsSL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/bashrc/can -o ~/.can.sh \
  && sed -i '\|source .*/\.can\.sh|d' ~/.bashrc \
  && echo 'source "$HOME/.can.sh"' >> ~/.bashrc \
  && source ~/.bashrc
```

Then just run `can`. Both one-liners are safe to re-run: that is how you update.
`nav` and `can` need bash 4.3+ and standard coreutils, nothing else.

## git extensions

Each extension installs a `git <name>` alias. Install only the ones you want.

| Name | Description |
|------|-------------|
| ctx | Unified branch context: ticket link and PR status |
| pinch | Open, edit, and ship changed files |
| marry | Branch creation, commit, and push in one flow |
| torch | Burn local branches except protected ones |
| rebirth | Hard-reset current branch to match origin |
| cbn | Commit message auto-generated from branch name |
| quiver | Interactive branch manager: fullscreen picker, Enter switches, Tab runs commands |
| hotfix | Cherry-pick commits into multiple targets with PR links |
| copen | Open modified files in your editor |
| fresh | Switch to main and sync with remote |
| pr | Create or list PRs, with template body and interactive label picker |
| wip | Quick work-in-progress commits |
| sync | Rebase or merge upstream into current branch |
| standup | Show recent commits for daily standups |
| shh | Stage, amend into last commit, and safe force-push |
| split | Split a branch into one branch (and PR) per commit, reverse cbn naming |

Manage them with:

```
git extension              Interactive UI
git extension update       Update all installed
git extension list         List installed with versions
git extension remove       Uninstall extensions
git extension self-update  Update the manager itself
```

Each extension has its own page: `extensions/<name>/README.md`
(for example [quiver](extensions/quiver/README.md) or [split](extensions/split/README.md)).

## nav

Bookmark directories under short aliases and jump to them by name or through a
full-screen picker. `nav f` learns the folders you `cd` into, no bookmarking needed.

```bash
nav set          # bookmark the current folder
nav              # pick a bookmark interactively
nav f            # pick from the places you actually visit
```

Full command reference, pickers, config and uninstall: [bashrc/README.md](bashrc/README.md).

## can

A tiny cleaner for junk data. It opens a checklist, you tick what to clean, and
it keeps a running total of the space it has freed.

```bash
can              # pick a group (docker, system, files), then what to clean
can status       # show what is reclaimable, change nothing
can -y           # clean the safe defaults of every group, no questions
can stats        # how much space can has freed so far
can help         # usage, with a trash can
```

| Group | Cleans |
|-------|--------|
| docker | Stopped containers, unused networks, dangling images, build cache; unused images and volumes (asks first) |
| system | Trash, old `/tmp` files, npm cache, `~/.cache`, apt cache |
| files | Your 50 biggest files, listed with sizes; you pick what goes (never touched by `-y`) |

More groups can be added without touching the UI. Details, keys, safety rules
and uninstall: [bashrc/can.md](bashrc/can.md).

## Structure

```
installer                  git extensions manager
extensions/
  registry.json            Metadata for all extensions
  <name>/
    install                Installation script
    README.md              Documentation
bashrc/
  nav                      Directory navigation helper
  can                      Junk cleaner
  README.md                nav documentation
  can.md                   can documentation
```

## License

MIT

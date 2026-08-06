# dotfiles

Git extensions with an interactive installer.

## Install

```bash
bash <(curl -sL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/installer)
```

## Extensions

| Name | Description |
|------|-------------|
| ctx | Unified branch context: ticket link and PR status |
| pinch | Open, edit, and ship changed files |
| marry | Branch creation, commit, and push in one flow |
| torch | Burn local branches except protected ones |
| rebirth | Hard-reset current branch to match origin |
| cbn | Commit message auto-generated from branch name |
| quiver | Interactive branch manager with stash and commands |
| hotfix | Cherry-pick commits into multiple targets with PR links |
| copen | Open modified files in your editor |
| fresh | Switch to main and sync with remote |
| pr | Show or create pull request |
| wip | Quick work-in-progress commits |
| sync | Rebase or merge upstream into current branch |
| standup | Show recent commits for daily standups |

## Manager

```
git extension              Interactive UI
git extension update       Update all installed
git extension list         List installed with versions
git extension remove       Uninstall extensions
git extension self-update  Update the manager itself
```

## Structure

```
installer                  Extension manager
extensions/
  registry.json            Metadata for all extensions
  <name>/
    install                Installation script
    README.md              Documentation
bashrc/
  nav                      Directory navigation helper
```

## License

MIT

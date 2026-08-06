# 🧰 dotfiles

**A collection of powerful Git extensions with an interactive installer.**

By [Denis Zickuhr](https://github.com/Denis-Zickuhr)

---

## ⚡ Quick Install

```bash
bash <(curl -sL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/installer)
```

The interactive installer lets you pick which extensions to install, update, or remove — no manual setup required.

---

## 🧩 Extensions

| Extension | Description |
|-----------|-------------|
| `ctx` | Unified branch context: name, ticket, and PR |
| `pinch` | Open, edit, and ship files changed in the current branch |
| `marry` | Automated branch creation, commit, and push workflow |
| `torch` | Burn local branches except protected ones |
| `rebirth` | Hard-reset current branch to match remote origin |
| `cbn` | Commit with message auto-generated from branch name |
| `quiver` | Interactive branch manager with favorites and auto-stash |
| `hotfix` | Cherry-pick commits into multiple target branches with PR links |
| `copen` | Open modified and staged files in your editor |
| `fresh` | Switch to main branch and sync with remote |
| `pr` | Show or create pull request for the current branch |

All extensions are installed as `git-<name>` and invoked via `git <name>`.

---

## 🎛️ Extension Manager Commands

The installer doubles as an extension manager. After installation, use these commands:

| Command | Description |
|---------|-------------|
| `git ext update` | Update installed extensions to their latest version |
| `git ext list` | List all installed extensions and their status |
| `git ext remove` | Interactively remove installed extensions |
| `git ext self-update` | Update the extension manager itself |

---

## 📁 Project Structure

```
dotfiles/
├── installer              # Interactive installer & extension manager
├── extensions/
│   ├── registry.json      # Extension metadata and descriptions
│   ├── ctx/               # Each extension has its own directory
│   ├── pinch/
│   ├── marry/
│   ├── torch/
│   ├── rebirth/
│   ├── cbn/
│   ├── quiver/
│   ├── hotfix/
│   ├── copen/
│   ├── fresh/
│   └── pr/
├── bashrc/
│   └── nav                # Bonus: directory navigation helper
├── LICENSE
└── README.md
```

---

## 🎁 Bonus: bashrc/nav

The `bashrc/nav` script is a directory navigation helper that can be sourced in your `.bashrc`. It provides quick directory jumping and bookmarking — a handy companion to the git extensions.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

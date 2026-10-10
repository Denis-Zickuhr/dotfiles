# can — a tiny cleaner for junk data

`can` is a single self-contained bash file (`bashrc/can`) that adds a `can`
function to your shell. You pick what to clean from a checklist; it removes it
and keeps a running total of the space freed.

It only writes one file of its own: `~/.can_stats` (the lifetime counter).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Denis-Zickuhr/dotfiles/main/bashrc/can -o ~/.can.sh \
  && sed -i '\|source .*/\.can\.sh|d' ~/.bashrc \
  && echo 'source "$HOME/.can.sh"' >> ~/.bashrc \
  && source ~/.bashrc
```

Re-running it updates `can` without duplicating the line in `.bashrc`.

From a clone instead:

```bash
echo 'source "/path/to/dotfiles/bashrc/can"' >> ~/.bashrc
```

Needs bash 4.3+ and standard coreutils (`find`, `du`, `numfmt`, `awk`, `tput`).
The docker group also needs a reachable docker daemon.

## Usage

```bash
can                 # pick a group, then what to clean (interactive)
can docker          # jump straight into a group (docker, system, files)
can status          # show what is reclaimable, change nothing
can files status    # same, for one group
can -y              # clean the safe defaults of every group, no questions
can -y -a           # clean everything, destructive items included
can stats           # how much space can has freed so far
can stats reset     # zero the counter
can help | version
```

Keys in the checklist: `↑/↓` or `j/k` move, `space` toggles, `a` toggles all,
`enter` confirms, `q` or `esc` quits.

## Groups

| Group | Item | On by default |
|-------|------|:---:|
| docker | Stopped containers | yes |
| docker | Unused networks | yes |
| docker | Dangling images | yes |
| docker | Build cache | yes |
| docker | Unused images (all) `!` | |
| docker | Unused volumes `!` | |
| system | Trash | yes |
| system | Old `/tmp` files (7 days+, yours only) | yes |
| system | npm cache | yes |
| system | User cache (`~/.cache`) | |
| system | apt cache (uses `sudo`) | |
| files | The 50 biggest files under `~` (default: over 100M, never inside `.git`) | |

Items marked `!` are destructive: they start unticked and ask for a
confirmation before running (unless you pass `-y`).

**files** is manual by design: every file is its own item, unticked, and
`-y` / `-a` never delete them. Change the size threshold with
`CAN_LARGE_MIN=500M can files`.

## The counter

Every successful cleaning adds to `~/.can_stats` (`total`, `runs`, `since`).
The total shows after each run, in the group menu, in `can help`, and in
`can stats`. It is based on what each cleaner reports, so treat it as
accurate to about a tenth of a unit, not to the byte.

## Adding a group

A group is an array of tools plus a few functions (`check`, `load`, `run`).
The registry format is documented at the top of [`bashrc/can`](can); the menu,
`status`, `-y`, confirmations and the counter work for any new group.

## Uninstall

```bash
sed -i '\|bashrc/can|d; \|\.can\.sh|d' ~/.bashrc
rm -f ~/.can.sh ~/.can_stats
```

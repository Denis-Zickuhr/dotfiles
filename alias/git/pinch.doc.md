# Opens all files modified in the current branch since diverging from upstream

## Description
A specialized utility for reviewing work within a feature branch. It identifies exactly which files have changed since you branched off from the upstream (usually `main`), filters out noisy dependency files, and opens the relevant set in your editor. It can also "pinch" your history by squashing commits via a soft reset.

## Usage
$ git pinch [options]

## Options
-e, --editor <tool>    Override the detected git editor.
-k, --keep             Perform a **soft reset** to the merge base after opening files. Useful for squashing multiple commits into a single state.
-u, --upstream <br>    Manually specify the upstream branch to compare against (defaults to origin/HEAD).
-h, --help             (Internal bash logic)

## Logic
1. **Divergence Check:** Uses `git merge-base` to find the exact point where your branch diverged from the upstream.
2. **Noise Filtering:** Lists changed files but ignores `vendor/`, `node_modules/`, `composer.lock`, and other generated/dependency files.
3. **Batch Open:** Passes the filtered list to your editor.
4. **Soft Reset:** If `--keep` is used, it resets the branch head to the divergence point while keeping all changes staged in the index.

## Example
$ git pinch --keep
> 1. Opens all files you worked on in this branch.
> 2. Resets your branch history so you can make a single "clean" commit of the entire feature.

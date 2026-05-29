# Opens all modified or added files in your preferred editor

## Description
A productivity utility that automatically detects all files with 'Modified' (M) 
or 'Added' (A) status and opens them simultaneously. It saves time by 
eliminating the need to manually copy-paste file paths from 'git status'.

## Editor Detection
By default, the script retrieves your editor from 'git config core.editor'. 
It automatically cleans common flags like '--wait' or '-w' to ensure the 
process doesn't hang the terminal.

## Usage
$ git copen
$ git copen -e [editor-name]

## Options
-e, --editor <tool>    Override the default git editor (e.g., code, vim, nvim).
-h, --help             (Internal bash logic)

## Logic
1. Runs 'git status --porcelain'.
2. Filters files marked as Added (A) or Modified (M) via awk.
3. Passes the file list to the editor using xargs.

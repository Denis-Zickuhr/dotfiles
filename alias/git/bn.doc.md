# Prints the current HEAD branch name
    
## Description
A lightweight utility to retrieve only the name of the current active branch. 
Ideal for scripts, piping, or quickly checking where you are without the 
verbose output of 'git branch'.

## Usage
$ git bn

## Command
git rev-parse --abbrev-ref HEAD

## Example Output
main
feature/extension-manager

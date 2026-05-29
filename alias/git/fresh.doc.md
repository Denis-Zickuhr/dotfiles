# Switches to the main branch and synchronizes it with remote

## Description
A "housekeeping" utility designed to quickly bring your repository to a 
clean and updated state. It automatically identifies the primary branch 
(main or master), switches to it, and synchronizes all local data with 
the remote server.

## Usage
$ git fresh

## Internal Logic
1. Dynamically detects the remote's default branch using 'origin/HEAD'.
2. Performs a 'git checkout' to the detected main branch.
3. Executes 'git fetch' and 'git pull' in sequence to ensure parity with the remote.

## Example Output
> Switched to branch 'main'
> Fetching origin...
> Updating 1a2b3c4..5e6f7g8
> Switched to main branch and pulled latest changes.

# Fetches all remote updates and pulls the current branch

## Description
A combined shortcut to synchronize your local repository with the remote 
server. It ensures all remote tracking branches are updated via 'fetch' 
before performing a 'pull' on your current branch.

## Usage
$ git fp

## Command
!git fetch && git pull

## Internal Logic
1. Runs 'git fetch' to update the local database with metadata from all remote branches.
2. Runs 'git pull' to integrate the remote changes into the current HEAD.

# Aggregates Jira activity and Pull Request status for the current branch

## Description
A meta-alias designed to provide a comprehensive overview of the current 
working context. It acts as a wrapper that orchestrates multiple sub-aliases 
(specifically 'att' and 'pr') to centralize links to your task management 
(Jira) and code review (PR) platforms in a single command output.

## Usage
$ git info [options]

## Options
-v, --verbose    Adds descriptive section headers ("Atividade" and "Pull Request") 
                 to the output for better visual organization.

## Internal Logic
1. Checks for the verbose flag to determine if section headers should be printed.
2. Executes 'git att': Displays the Atlassian Jira link based on the branch prefix.
3. Executes 'git pr': Displays the status or link of the current Pull Request.

## Example Output (Verbose)
Atividade
https://zorders.atlassian.net/browse/MAG-1234

Pull Request
https://github.com/User/Repo/pull/56

# Generates a Jira issue URL from the current branch prefix

## Description
This alias parses the current branch name to identify a Jira-style issue key 
(e.g., MAG-123, ABC-456). If found, it outputs the direct link to the 
Atlassian ticket on the Magazord workspace.

## Branch Convention
Requires the branch to follow the pattern: [Project-Code]-[ID]-[Description]
Example: MAG-8952-fix-redis-connection

## Usage
$ git att

## Example Output
https://zorders.atlassian.net/browse/MAG-8952

## Internal Logic
1. Identifies HEAD branch name.
2. Extracts prefix via regex: ^[A-Za-z]+-[0-9]+
3. Validates prefix before printing the final URL.

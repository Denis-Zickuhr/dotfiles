# Automates multi-target hotfix creation and PR link generation

## Description
A high-level automation tool designed for applying fixes across multiple environments (e.g., `staging`, `production`, `develop`) simultaneously. It identifies unique commits from a source branch, cherry-picks them into fresh hotfix branches for each target, and provides direct links to open Pull Requests.

## Usage
$ git hotfix -f [source-branch] -i [target1,target2]

## Options
-f, --from <source>    Source branch containing the commits (defaults to current).
-i, --into <targets>    Comma or space-separated list of target branches (e.g., "main,staging").
-p, --picky             Interactive mode: manually choose which commits to cherry-pick.
--force                 Force pushes the generated hotfix branches to origin.
-h, --help              Displays the command usage and examples.

## Workflow
1. **Selection:** Compares the source with the first target to find unique commits.
2. **Interactive (Optional):** If `-p` is used, you select specific commits by number.
3. **Execution:** For each target branch:
   - Switches to target and pulls latest.
   - Creates a new branch: `hotfix-[target]-[source]`.
   - Cherry-picks the selected commits.
   - Pushes to remote.
4. **Cleanup:** Returns you to your original branch and displays PR links.
5. **Rollback:** If a conflict or error occurs, it deletes the temporary local branches created during the process.

## Example
$ git hotfix -f fix/login-error -i develop,staging,main
> Automatically applies the login fix to all three environments and gives you the PR links.

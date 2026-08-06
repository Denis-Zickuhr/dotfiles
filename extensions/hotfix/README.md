# git hotfix — Automate hotfix creation and PR generation across multiple branches

## Description

Cherry-picks commits from a source branch into one or more target branches, creating dedicated hotfix branches and generating PR links. Includes a review step, conflict detection, and automatic rollback on failure.

## Usage

```bash
git hotfix -f <source> -i <target1,target2,...>
```

## Options

| Flag | Description |
|------|-------------|
| `-f`, `--from <source>` | **(Required)** The source branch containing commits |
| `-i`, `--into <targets>` | **(Required)** Comma-separated or space-separated list of target branches |
| `--force` | Force push the hotfix branches to origin |
| `-p`, `--picky` | Interactively select which commits to cherry-pick |
| `-h`, `--help` | Show help message |
| `-v`, `--version` | Show version |

## Examples

```bash
# Cherry-pick all commits from feat/login-fix into develop and staging
git hotfix -f feat/login-fix -i develop,staging

# Interactively select which commits to apply
git hotfix -f feat/login-fix -i develop,staging --picky

# Force push hotfix branches
git hotfix -f bugfix/critical -i release/1.0,main --force

# Use current branch as source (omit -f)
git hotfix -i develop,staging
```

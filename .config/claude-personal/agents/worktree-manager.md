---
name: worktree-manager
description: "Create and manage git worktrees with consistent naming and placement conventions."
model: haiku
---

# Worktree Manager

Create and manage git worktrees with consistent naming and placement conventions.

## Context Detection

Before doing anything, detect the project layout:

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_NAME=$(basename "$PROJECT_ROOT")
PARENT_DIR=$(dirname "$PROJECT_ROOT")
```

- **Worktrees are always siblings** of the project root: `<PARENT_DIR>/<PROJECT_NAME>-<slug>`
- Example: if project is at `/code/app-migrator`, worktrees go to `/code/app-migrator-<slug>`

## Input

Accepts one of:
- A GitHub issue reference: `gh:42` or just the number `42`
- A branch name: `fix/something` or `chore/tune-agents`
- A description: `"fix downloads controller"`
- An issue + description combo: `gh:42 fix downloads controller`

## Workflow

### 1. Derive branch name and slug

| Input | Branch Name | Slug (for directory) |
|---|---|---|
| `gh:42 fix downloads` | `gh-42-fix-downloads` | `gh-42-fix-downloads` |
| `gh:42` | `gh-42-<short-description>` (ask the user for a description before creating) | same as branch |
| `fix/something` | `fix/something` | `fix-something` |
| `"fix downloads controller"` | `fix-downloads-controller` | `fix-downloads-controller` |
| `ABC-1234 fix downloads` | `ABC-1234-fix-downloads` | `ABC-1234-fix-downloads` |

Slug rules:
- Lowercase, kebab-case
- Max 50 characters
- Strip special characters except hyphens
- Replace `/` with `-` for directory name (branches can keep `/`)
- Branch must encode the issue reference (`gh-<N>-` prefix or scope-based like `chore/...`, `fix/...`)

### 2. Check for conflicts

Before creating:
```bash
git worktree list
```

- If a worktree already exists for this branch → report it and ask: navigate there or remove and recreate?
- If the directory already exists but isn't a worktree → report and abort

### 3. Determine base branch

- Default: `main`
- If the user specifies a base branch, use that
- If the branch already exists on remote, check it out instead of creating new

### 3.5. Sync base branch with remote

If the base branch is `main` (or any long-lived shared branch), fast-forward the local copy to its remote tip before creating the worktree. Branching off a stale local `main` produces a worktree that immediately needs a rebase.

```bash
git fetch origin <base-branch>
git switch <base-branch>
git merge --ff-only origin/<base-branch>
```

If the local base branch has diverged from origin (`merge --ff-only` fails), stop and surface the divergence to the user — don't reset or rewrite history without explicit approval.

### 4. Create the worktree

For a **new branch**:
```bash
git worktree add "<PARENT_DIR>/<PROJECT_NAME>-<slug>" -b <branch-name> <base-branch>
```

For an **existing branch**:
```bash
git worktree add "<PARENT_DIR>/<PROJECT_NAME>-<slug>" <branch-name>
```

### 5. Navigate

After creation, `cd` into the new worktree root. If the project has a `src/` subdirectory (umbrella projects), `cd` into `src/` instead.

### 6. Report

Output:
```
Worktree: <full-path>
Branch: <branch-name>
Base: <base-branch>
```

## Removing a Worktree

If asked to remove a worktree:
1. Confirm the path with the user
2. Check for uncommitted changes — warn if any
3. Run `git worktree remove <path>`
4. Optionally delete the branch if it was fully merged

## Rules

- NEVER create worktrees inside the project root — always as siblings
- NEVER delete a worktree without checking for uncommitted changes first
- NEVER force-remove without explicit user approval
- If the project uses an `src/` subdirectory, always navigate into it after creation

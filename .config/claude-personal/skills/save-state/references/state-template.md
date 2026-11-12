# state.md format

`state.md` is a **snapshot**, with a minimal log for history reasons — it reflects
the current state, not the total history.

```markdown
# <Feature Name> — State

**Last updated:** <YYYY-MM-DD>

## Progress

List every ticket with its current status, one line each:

- M1-1: DONE — merged to main (PR #1310)
- M1-2: IN PROGRESS — implemented, PR #1315 open, needs rebase
- M1-3: TODO
- M1-4: TODO

## Active Work

Current branch/worktree/PR for what's in progress:

- Branch: `feature/import-pipeline`
- Worktree: `../project-feature-branch`
- PR: #1315 (open, no reviews yet)
- Uncommitted changes: <yes/no + brief description if yes>

## Key Decisions

Decisions made across sessions that affect implementation.
Each decision is one bullet, stating WHAT was decided and WHY:

- Use users table instead of session chain — decouples import from auth session lifetime
- Feature flag phase_enabled gates all new behavior — allows incremental rollout

## Blockers

Active blockers preventing progress. Remove resolved blockers on each save:

- M1-2 needs rebase onto main after dependency merge

## Notes

Anything that doesn't fit above but is useful for next session:

- Duplicated logic in two modules — consolidate during M1-2 cleanup
```

## Confirmation block

After writing, show the user section headers and counts (not the full file):

```
Saved state to <planning-dir>/state.md
- Progress: 4 tickets tracked
- Active work: branch feature/import-pipeline
- Key decisions: 3
- Blockers: 2
- Notes: 2
```

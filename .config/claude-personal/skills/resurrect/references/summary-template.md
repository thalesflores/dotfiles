# Resurrect summary format

Print this and nothing else. Under 40 lines. Omit any section that is empty.

```
## <Feature Name>

**Goal:** <one-line from plan file>

### Done (X/Y)
- M1-1: Feature flag + data model (merged)

### In Progress (X/Y)
- M1-2: Import pipeline (PR #1315, branch: feature/import-pipeline)
  - <inline notes from tickets file>
  - Worktree: <path if exists>

### Todo (X/Y)
- M1-3: OAuth integration

### ⚠ Drift
- <ticket says in-progress, branch is gone / PR merged>

### Key Decisions (from state.md)
- <decisions carried from previous sessions>

### Blockers (from state.md)
- <any active blockers>
```

No preamble, no closing recap, no restating the plan.

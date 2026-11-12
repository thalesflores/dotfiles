---
name: resurrect
description: Resume a long-lived feature. Reads planning directory + state file, checks git state, and presents what's done vs what's next.
---

# Resurrect Feature

Restore context for a long-lived feature by reading its planning directory, saved state, and current git state.

## Input Parsing

The skill accepts an optional path to the planning directory:

```shell
/resurrect path/to/planning-dir
/resurrect
```

If no path is provided, discover planning directories automatically:

1. Run `${SKILL_DIR}/bin/discover-planning-dir.sh` (replace `${SKILL_DIR}` with the absolute path the runtime announces). It globs for the planning-file patterns (`plannings*`, `state.md`, `plan*.md`, `ticket*.md`, `backlog*.md`, `tasks*.md`), groups matches by parent directory, and returns `{"candidates":[...]}`. Zero LLM tokens spent on the glob/group pass.
2. If one candidate, use it
3. If multiple, ask the user to pick one using `AskUserQuestion`
4. If none, ask the user for the path

## Workflow

### 1-3. Read Planning + Parse Status + Read State (delegated)

Delegate the planning-directory read, status parsing, and state extraction to a Sonnet subagent via the Task tool. The main context only carries the structured snapshot, not the raw planning markdown.

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Read the planning directory and return a structured snapshot.

    Planning dir: <path>

    Steps:
    1. Read ALL `.md` files in the directory. Don't assume filenames — common ones
       include plan.md, tickets.md, backlog.md, tasks.md, state.md.

    2. Read ${SKILL_DIR}/references/parse-planning.md and follow it for the
       status-marker parsing rules and the exact JSON shape to return.
  """
)
```

Pass the returned JSON to step 4 as-is; its `id_scheme` field picks the branch filter there.

### 4. Check Live Git State (delegated)

Call `ListAgents` here (subagents can't see peer sessions), then delegate the fetch and the drift check to one Sonnet subagent so the raw snapshots never enter this context:

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Read ${SKILL_DIR}/references/live-git-state.md and follow it.

    SKILL_DIR: <absolute skill path>
    Tickets: <step 1-3 JSON>
    Peer sessions: <ListAgents names>
  """
)
```

Replace `${SKILL_DIR}` with the absolute path the runtime announces when loading the skill.

Never present stale status as fact. Surface the drift list so the user can reconcile (via `/save-state`) or prune (`git branch -d` / `git worktree remove`). Do not prune here.

### 5. Present Summary

The step 4 Task's return JSON should already include a `"presentation"` field: have that Sonnet subagent read `${SKILL_DIR}/references/summary-template.md`, fill it from the tickets/git-snapshot/drift data it already holds, and return the fully rendered markdown. Print that field here verbatim. Nothing else.

### 6. Ask What's Next

Use `AskUserQuestion` suggesting the most logical next task:
- First in-progress ticket needing attention (rebase, cleanup, review)
- First todo ticket whose dependencies are met

Only suggest tickets with no drift entry. Never suggest one the state file calls todo without the GitHub check above.

### 7. Start Working

Once the user picks:
- If there's an existing worktree, confirm and `cd` to it
- If there's a branch but no worktree, ask if they want one
- If it's a new ticket, offer to create a worktree via `/kickoff`
- Get the full detail for the picked ticket only, via a Sonnet subagent (`subagent_type: "general-purpose"`, `model: "sonnet"`): "Extract the section for ticket `<id>` from `<tickets file>` and return it verbatim. Nothing else." Never read the whole tickets file into this context — that is what the step 1-3 delegation exists to avoid.
- Begin work

## Rules

- **Do NOT start coding before step 6 approval**
- **Do NOT echo the full plan contents back** — only present the status snapshot
- **Do NOT modify any planning files** — use `/save-state` for that
- **Do NOT do steps 4-5 inline** — the drift check and presentation go through the subagent with the template
- **No side suggestions** — no cleanup, pruning, stale-file or housekeeping advice; the summary and the step 6 question only
- **Follow CLAUDE.md and CLAUDE.local.md** conventions

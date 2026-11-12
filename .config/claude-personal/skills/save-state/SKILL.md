---
name: save-state
description: Save current feature progress to state.md. Captures what was done, key decisions, blockers, and git state for the next session.
---

# Save Feature State

Write or update a `state.md` file in a planning directory to preserve context across sessions.

## Input Parsing

The skill accepts an optional path to the planning directory:

```shell
/save-state path/to/planning-dir
/save-state
```

If no path is provided, discover planning directories automatically:

1. Run `${SKILL_DIR}/bin/discover-planning-dir.sh` (replace `${SKILL_DIR}` with the absolute path the runtime announces). It globs for the planning-file patterns (`plannings*`, `state.md`, `plan*.md`, `ticket*.md`, `backlog*.md`, `tasks*.md`), groups matches by parent directory, and returns `{"candidates":[...]}`. Zero LLM tokens spent on the glob/group pass.
2. If one candidate, use it
3. If multiple, ask the user to pick one using `AskUserQuestion`
4. If none, ask the user for the path

## Workflow

### 1. Gather Context

Collect information from three sources:

**From the conversation:** Review what was done in this session:
- Which ticket(s) were worked on
- What was implemented, fixed, or changed
- Any decisions made and why
- Any blockers discovered or resolved

**From planning files and git:** Delegate both to a single Sonnet subagent via the Task tool, so neither the raw planning markdown nor the raw git JSON enters the main context. Compose state.md from the returned summary plus the conversation.

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Planning dir: <path>

    1. Read all `.md` files in the planning directory (don't assume filenames,
       read whatever exists) and summarize the current ticket statuses and structure.

    2. Run `${SKILL_DIR}/bin/git-snapshot.sh --filter '<id-regex>' --include-diff`
       and summarize: worktrees, branches, open PRs, recent commits per branch, and
       diff stat per active branch. If that script is unavailable, run
       `git worktree list`, `git branch --list`, `gh pr list --author @me`,
       `git log --oneline -5 <branch>` and `git diff --stat <branch>` instead.

    3. If tickets are GitHub issues, run
       `gh issue list --repo <owner/repo> --state all --limit 300 --json number,state,assignees,milestone,blockedBy,closedByPullRequestsReferences`
       (`<owner/repo>` = the repo the planning files reference tickets in). Where a
       ticket's status in the planning files disagrees with GitHub (closed, assigned
       to someone else, linked PR, other milestone), report GitHub's status and flag it.

    Return a compact summary of all three. No raw file contents, no raw JSON.
  """
)
```

Replace `${SKILL_DIR}` with the absolute path the runtime announces when loading the skill. Choose `--filter` to match the planning files' ID scheme:
- Jira-style IDs (`ABC-123`) → `--filter '[A-Z]+-[0-9]+'`
- GitHub issue branches (`gh-4164-...`) → `--filter 'gh-[0-9]+'`
- Local milestone IDs (`M1-1`, `T-3`) → `--filter '(M[0-9]+-|T-)'`
- Unsure → omit `--filter` (all non-main branches; noisier but complete)

### 2. Ask the User

Use `AskUserQuestion` to confirm or add:

**Question 1:** "Anything to add to key decisions or notes?"
- Options: "No, looks good" / "Yes, let me add"

Only ask this if the session involved non-trivial decisions. For simple state saves, skip and write directly.

### 3. Write state.md

Delegate the write to a Sonnet subagent — it holds the template so the boilerplate never enters this context:

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Read ${SKILL_DIR}/references/state-template.md for the exact section format.
    Write (or overwrite) state.md in <planning dir> using the content below.

    The file is a snapshot with a minimal history log: current state, not total
    history. Write only what is in the content below — invent nothing, and do not
    read any other file for extra context.

    Content:
    <conversation summary + the step 1 planning/git summary>

    Report back only: the section headers you wrote and each section's line count.
  """
)
```

### 4. Confirm

Print the section headers and line counts the step 3 subagent reported. Do not re-read the file you just wrote.

## Rules

- **Overwrite, don't append** — state.md is always a current snapshot
- **Keep decisions concise** — one line per decision, WHAT + WHY
- **Remove resolved blockers** — only active blockers remain
- **Don't invent state** — only write what you actually know from the conversation, planning files, and git
- **Don't modify other planning files** — state.md is the machine-maintained companion

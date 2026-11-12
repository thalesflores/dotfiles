# Planning-directory parsing rules

Parsing rules and return shape for the planning-directory read. Only the delegated
subagent needs this file.

## Status markers

Parse ticket/task headings for status markers (case-insensitive):

- IDs: Jira-style (`ABC-1234`, `[A-Z]+-\d+`), GitHub (`#123`, `gh-123`, `gh:123`),
  local (`M1-1`, `T-3`)
- Checkboxes: `- [x]` (done), `- [ ]` (todo)
- Keywords:
  - Done        → DONE, MERGED, COMPLETED, or `[x]`
  - In Progress → IN PROGRESS, WIP, IMPLEMENTED, or branch/PR without a done marker
  - Todo        → TODO, no marker, or `[ ]`

## From state.md (if present)

Key decisions, blockers, inline notes, last active branch/worktree.

## Return shape

```json
{
  "goal":          "<one-line from plan.md>",
  "done":          [{ "id": "...", "title": "...", "note": "..." }],
  "in_progress":   [{ "id": "...", "title": "...", "branch": "...", "pr": "...", "note": "..." }],
  "todo":          [{ "id": "...", "title": "...", "note": "..." }],
  "decisions":     ["..."],
  "blockers":      ["..."],
  "last_branch":   "<from state.md or null>",
  "id_scheme":     "jira | github | local",
  "issue_repo":    "<owner/repo the tickets are filed in, or null>",
  "repos":         ["<owner/repo of EVERY repo a ticket touches, plus the planning dir's own repo>"]
}
```

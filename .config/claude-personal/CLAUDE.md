@RTK.md

# Token efficiency

These rules exist because a token-usage audit found ~90% of output cost was Opus
subagents and ~85% of cache-write cost was re-paid context in long-lived sessions.

## Subagent model routing

- **Default spawned subagents (Task tool) to Sonnet** (`model: 'sonnet'`). Reserve
  Opus only for genuinely reasoning-heavy delegation: architecture/design, hard
  debugging, adversarial verification, or nuanced code review.
- Mechanical subagent work is always Sonnet: file reads, lookups, search,
  polling, running build/format/lint/test and reporting pass/fail.
- Set the model per Task call (invocation-scoped). Never add `model:` to a skill's
  frontmatter — Claude Code persists it to `settings.json` and silently downgrades
  future sessions.

## Session hygiene

- `/clear` (or start a fresh session) between unrelated tickets. Don't keep one
  session alive for hours/days across tasks — context past the ~1h cache TTL is
  re-paid in full on every turn.
- If a session has drifted onto a new task, clear first; a warm cache on stale
  context is a cost, not a saving.

# Working rules

- Verify before stating facts about code, infra, schema or providers: read the file/HEAD, run the plan or query, or read the official docs. If you can't verify, say so.
- In anything meant to be shared, cite code as GitHub permalinks.
- Do only what was asked. Reuse existing helpers before writing new ones. Report adjacent problems in one line; don't fix them in the same change. If two readings of a task give different diffs, ask first.

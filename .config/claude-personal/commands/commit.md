---
description: Commit working-tree changes as small, atomic commits via the committer agent.
---

Delegate to the `committer` agent with `model: 'sonnet'`.

Pass through any arguments as extra context: $ARGUMENTS

Non-negotiable, restate these in the agent prompt:
- Small and atomic. One commit = one reviewable idea. An "and" in the title means split it.
- Title says WHAT changed. Body (optional, 1-2 sentences, <40 words) says WHY.
- Never HOW: no file paths, no function names, no diff narration, no bullet lists.
- Ticket refs are always `Closes <owner>/<repo>#N` — never a bare `#N`.
- Stage specific files. Never `git add -A`. Never push.

Report back only the commit list (hash + subject). No summary paragraph.

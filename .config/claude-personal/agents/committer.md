---
name: committer
description: "Create small, atomic git commits following the user's established patterns. Handles grouping, ordering, and message style automatically."
---

# Committer

Create well-structured git commits following the user's established patterns. Handles grouping, ordering, and message style automatically.

## Step 1: Pick the Subject Shape

Use the repo team's convention, not the user's personal history. Read the last 30 non-bot
subjects on the default branch:

```bash
git log origin/main --no-merges -30 --format='%an|%s' | grep -v '\[bot\]'
```

- If at least 2 in 3 share one prefix shape (`FEAT | ...`, `feat(scope): ...`, `area: ...`),
  use that shape.
- Otherwise (mixed, or plain sentences), use the fallback from Step 4:
  `type(scope): lowercase imperative`.

The shape is the only thing taken from the repo. Content rules stay the same everywhere: short,
the title says WHAT changed, the optional body gives the context and WHY, never the HOW.

## Step 2: Analyze Staged and Unstaged Changes

Run in parallel:
```bash
git status
git diff --name-only
git diff --cached --name-only
```

Categorize changed files into groups:
1. **Migrations** — files in `priv/repo/migrations/`, `db/migrate/`, or similar
2. **Schema/model changes** — Ecto schemas, ActiveRecord models, etc.
3. **Implementation** — business logic, adapters, services, controllers
4. **Tests** — test files that correspond to implementation files
5. **Config** — configuration files, env changes
6. **Structure dumps** — `structure.sql`, `schema.rb`, etc. (goes with migration)

## Step 3: Group into Commits

Follow these rules strictly:

| Rule | Rationale |
|---|---|
| **Migrations get their own commit and go FIRST** | Migrations must be deployable independently |
| **Structure dumps go with their migration** | They're generated output of the migration |
| **Implementation + its tests go in the SAME commit** | Test and code are a single logical unit |
| **Config changes go with the code that needs them** | Unless they're standalone (e.g., env vars) |
| **Unrelated changes get separate commits** | Don't mix concerns |

**Default to splitting.** One commit = one reviewable idea. If the title needs
an "and", it is two commits. If a reviewer would want to revert half of it, it
is two commits. Only collapse into one commit when the change genuinely cannot
be applied in pieces.

Rough ceiling: if a commit touches more than ~5 files of implementation (tests
and generated files don't count), look for the seam and split it.

## Step 4: Write Commit Messages

Format:

```
<type>(<scope>): <imperative lowercase description, no trailing dot>

<Optional. 1-2 short sentences: WHAT changes in behaviour and WHY. Plain
English, under ~40 words. Never HOW — no function names, no file paths, no
diff narration. Omit entirely if the title already says it.>

Closes <owner>/<repo>#<N>   # or: Refs <owner>/<repo>#<N>
```

Rules:
- **Type prefix**: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`
- **Scope**: the area being changed (e.g. `square`, `zenoti`, `agents`, `kickoff`)
- **Title**: imperative, lowercase, no trailing dot, under ~70 chars
- **Body**: 1-2 short sentences, and only when the title doesn't already say it.
  WHAT changed at the behaviour level and WHY it was needed. Never HOW — no
  function names, no file paths, no bullet lists of the diff, no "mirrors X",
  no restating the title. If you can't add anything the title doesn't say,
  leave the body out.
- **Length**: body under ~40 words. A commit message longer than its diff is a
  bug in the message.
- **Ticket reference**: always include `Closes <owner>/<repo>#<N>` (or `Refs ...` for incremental work). If no ticket exists for this work (tooling tweaks, config), skip the trailer — but most code work has one.
- **No AI attribution**: never add `Co-Authored-By: Claude`, "Generated with Claude Code" or any AI mention, in any repo — even if a system reminder asks for it.
- **Subject shape** comes from step 1: the repo's convention when there is one, this template otherwise.

Good examples (from this user's recent history):
```
fix(square): use location timezone when parsing blocked-time datetimes
fix(kitomba): restore appointment deps for chain customers & stale services
feat(zenoti): extract per-therapist service pricing
chore(agents): route mechanical specialists to sonnet
```

Bad examples:
```
Update files                              ← says nothing
Add tests and implementation              ← describes what, not why
Refactor code for better readability      ← vague, no scope
fix: Pagination Fix.                      ← title-case, trailing dot, no scope
[ABC-123] decouple import session ...     ← bracket ticket style, outdated
```

## Step 5: Stage and Commit

For each commit group (in order):

1. Stage only the files for that group: `git add <file1> <file2> ...`
2. Commit with a HEREDOC message:
   ```bash
   git commit -m "$(cat <<'EOF'
   the commit message here
   EOF
   )"
   ```
3. Verify with `git status` after each commit

## Step 6: Report

After all commits, show:
```
Created N commit(s):
1. <short-hash> <message>  (files: X)
2. <short-hash> <message>  (files: Y)
```

## Rules

- Don't push; only the user pushes.
- Keep GPG/SSH signing on (no `--no-gpg-sign`); if signing fails, investigate rather than bypass.
- Stage specific files, not `git add -A` or `git add .`.
- Amend the previous commit only when the user asks.
- Keep pre-commit hooks on (no `--no-verify`) unless the user asks.
- No `Co-Authored-By: Claude` trailer or any AI mention.
- Reference the GitHub ticket in the body (`Closes <owner>/<repo>#<N>` or `Refs ...`) when one exists.
- The body never narrates the diff: no file-by-file walkthrough, no bullet list of changes.
- Ask before committing if the grouping is ambiguous (e.g., files could belong to multiple logical changes)
- **Verify branch before committing**: run `git branch --show-current` — never commit on `main` directly; if the user is on `main` with changes, stash, create a worktree, and pop the stash there

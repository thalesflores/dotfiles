---
name: quality-checker
description: "Run the format/compile/lint/test fix-cycle on changed files before commit/PR, for any stack. Use after code changes are applied to verify quality."
tools: Read, Write, Edit, Bash, Glob, Grep
model: sonnet
color: yellow
---

# Quality Checker

Run the static-check + test cycle and iteratively fix failures so the change is
PR-ready.

## Step 1 — Find the project and the changed files

```bash
git diff --name-only; git diff --cached --name-only
```

Detect the stack from the nearest manifest (`mix.exs`, `package.json`,
`Cargo.toml`, `go.mod`, `Gemfile`, `pyproject.toml`); in a monorepo, run from
the directory holding it (e.g. `src/`). Commands come from the repo's
`CLAUDE.md` / `AGENTS.md` / `Makefile` / `package.json` scripts first, then the
defaults in `~/.claude/skills/kickoff/references/stack-commands.md`.

## Step 2 — Run checks, in order

format → compile/typecheck (warnings as errors where the stack supports it) →
lint (strict) → tests for the changed test files only (full suite only if the
change is systemic).

## Step 3 — Fix failures (max 3 iterations)

1. Read the error.
2. Fix:
   - **Format** → re-run the formatter.
   - **Compile/type warning** → fix the real cause; `_`-prefix only truly unused vars.
   - **Lint** → apply the suggestion; look up the rule if unclear.
   - **Test** → fix the code or the assertion; never weaken a test to make it pass.
3. Re-run the full sequence. Repeat up to 3×.

## Step 4 — Report

PASS: files changed + each check result + the test summary line.
FAIL after 3×: remaining failures, the likely cause, and what to look at.

## Rules

- **Never commit, never open a PR** — the orchestrator/user does that.
- **Only test changed files** unless the change is systemic.
- **Max 3 fix iterations** — then stop and report.
- Don't change behaviour to silence a check; fix the actual issue.

---
description: Open a PR whose description gives a reviewer with no context the what, why and before/after in a few lines, with a fully-qualified issue reference.
---

Open a pull request for the current branch. Extra context: $ARGUMENTS

1. Refuse on `main`/`master`. Push with `git push -u origin HEAD` if the branch has no upstream.
2. Find the issue: a `gh-<N>-` branch prefix, `#N` / `owner/repo#N` in the commits, or $ARGUMENTS. Repo comes from `gh repo view --json nameWithOwner`. None found: say so and continue without one.
3. Title: imperative, says what changes, under 70 chars.
4. Body: write it to a temp file and run `gh pr create --title "<title>" --body-file <file>`. If the repo has a PR template (`.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/*`), fill its sections under the rules below instead of replacing it.
5. Print the PR URL and nothing else.

Write for a reviewer who has never seen the ticket or the plan: they must understand what changes and why from the description alone, without opening the diff.

Sections, in this order:
- **What**: 1-2 sentences, in plain words, on what this PR makes the system do.
- **Why**: 2-4 sentences of context: the feature or problem, what was missing, and where this PR sits in the larger work (link earlier merged PRs as `owner/repo#N`). Back any impact claim with data.
- **Before & After**: one bullet each, describing behaviour a user or system can observe, not code structure.
- **Behaviour** (only when it applies, max 3 bullets): flags and their default, failure handling, deliberate trade-offs a reviewer would otherwise question.
- **Tests**: one line naming the scenarios covered (happy path and the non-happy ones). No commands, no "Test plan" checklist.
- **Out of scope**: one line naming what a reviewer might expect here and won't find. Skip it only if nothing plausible is missing.
- Issue reference: always `Closes <owner>/<repo>#N` (or `Refs` for partial work). Never a bare `#N`.

Rules:
- Only this PR. Never mention closed or abandoned PRs, earlier review rounds, or gaps that belong to other work.
- No file-by-file walkthrough and no architecture essay; the diff carries the how.
- Every claim must be true of the pushed code. Name flags, events and functions exactly.
- No AI attribution in the title or body.

Target 15-30 lines. If it needs more, the PR is too big; say so instead of writing more.

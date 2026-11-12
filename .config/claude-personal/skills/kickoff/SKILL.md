---
name: kickoff
description: Interactive ticket starter - reads ticket and plan, creates a worktree, explains the approach, and begins implementation after approval.
---

# Kickoff

## Instructions

Set up a working environment for a ticket and begin implementation after user approval. This skill is interactive — gather all context first, confirm the plan, then work.

## Input Parsing

The skill accepts optional arguments:

```shell
/kickoff gh:42 plan:./docs/plans/gh-42.md
/kickoff ticket:M1-1 from:./docs/plans/my-feature/tickets.md plan:./docs/plans/my-feature/plan.md
/kickoff gh:42
/kickoff ticket:M1-1
/kickoff
```

**Parse the input for three pieces:**

1. **Ticket source** — one of:
   - `gh:<N>` — fetch a GitHub issue (e.g., `gh:42`). A full issue URL is also accepted; derive `owner/repo` from it. Otherwise default the repo from the current git remote (`gh repo view`).
   - `file:<path>` — read entire local file as the ticket (e.g., `file:./specs/feature.md`)
   - `ticket:<ID>` — find a specific ticket section inside a multi-ticket file (e.g., `ticket:M1-1`)
2. **From file** (only for `ticket:` source) — `from:<path>` pointing to the multi-ticket file
3. **Plan path** — `plan:<path>` pointing to the plan file

If any required piece is missing, ask the user using `AskUserQuestion`.

## Workflow

### 1-2. Fetch Ticket and Plan (delegated)

Delegate ticket fetching and plan reading to a Sonnet subagent via the Task tool. The main context only carries the structured summary, not the raw ticket/plan markdown.

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Fetch the ticket and read the plan, then return a structured summary.

    Ticket source: {{ticket_source}}
    Plan path: {{plan_path}}

    `{{ticket_source}}` is one of: `gh:<N>`, `file:<path>`, or `ticket:<ID> from:<path>`.
    `{{plan_path}}` is the plan file path (e.g. `plan:./docs/plans/gh-42.md`).

    Steps:
    1. Fetch the ticket per source type:
       - gh:<N>             → `gh issue view <N> --json title,body,labels,assignees,state`
                              (add `--repo <owner/repo>` if the source carried one or the cwd remote isn't the target)
       - file:<path>        → Read the file; title from first heading, requirements from body
       - ticket:<ID> from:<path> → Read the file, extract the section starting with `## <ID>:` up to the next `## ` heading
    2. Read the plan file.
    3. Return JSON:
       {
         "ticket": { "id": "...", "title": "...", "summary": "2-3 line summary", "acceptance_criteria": ["..."] },
         "plan":   { "steps": ["..."], "files_to_create": ["..."], "files_to_modify": ["..."] },
         "presentation": "<the step 4 block, fully formatted and ready to print verbatim>"
       }

    For "presentation", format exactly this and nothing else:
      **Ticket**: one-line description
      **Acceptance criteria**: one line each, verbatim from the ticket
      **Files to create**: one line each, path + short purpose
      **Files to modify**: one line each, path + what changes
      **Steps**: numbered, implementation order
    Keep it under 20 lines. No preamble, no closing summary.
  """
)
```

Use the returned JSON for step 3 (worktree naming) and step 4 (present the plan).

### 3. Create Worktree

Run `${SKILL_DIR}/bin/create-worktree.sh` (replace `${SKILL_DIR}` with the absolute path the runtime announces). It derives the branch name, fetches and adds the worktree off `origin/main` (never the stale local `main`), and reports where to cd:

```bash
${SKILL_DIR}/bin/create-worktree.sh --source gh|local --id "<ID>" --title "<ticket title>"
```

It returns `{"branch","worktree_path","code_dir"}`: the kebab-case branch (prefixed `<ID>-` for local or `gh-<N>-` for GitHub, truncated to 50 chars), the new worktree path, and `code_dir` (a nested source dir like `src/` if one exists, else null). `cd` into `code_dir` when it's set, otherwise into `worktree_path`.

### 4. Present the Plan

Print the `presentation` field from the step 1-2 JSON verbatim. It is already formatted — do not re-derive, re-word, or expand it.

### 5. Wait for Approval

Ask the user: "Ready to start?" — do NOT write any code until they confirm.

### 6. Implement

Work through the plan step by step:
- Follow the plan order
- Before implementing each step, delegate a lookup (`subagent_type: "general-purpose"`, `model: "sonnet"`): "List `.claude/agents/*.md` frontmatter and return which agent (if any) matches this step's file types/task." Use the matched agent; only implement directly when none matches.
- After each logical chunk, delegate the commit to the `committer` agent (`model: "sonnet"`), passing the changed files and one line on what the chunk does. It owns staging, message style, signing and the no-attribution rule.

- After each meaningful change, delegate the check run instead of running it inline. If the project defines a quality/test agent in `.claude/agents/`, use that; otherwise:

```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: """
    Detect this project's format/build/lint/test commands: check `CLAUDE.md` and
    `CLAUDE.local.md` first (they take precedence), otherwise use the per-stack
    table in ${SKILL_DIR}/references/stack-commands.md.

    Run them, plus the tests related to the changed files.

    Report only: pass/fail per command, and the full output for any failure.
  """
)
```

Only reason about a fix when the subagent reports a failure — don't pull passing build output into this context.

### 7. Verify and Review Before PR

1. Delegate the acceptance check (`subagent_type: "general-purpose"`, `model: "sonnet"`): pass the acceptance criteria; it starts the app, exercises each path (curl, a test, a query) and returns only a table of criterion, met/not met, and the evidence. Fix anything not met here, then re-run the check before moving on.
2. Run `/pr-review` on the branch. Fix the blocking findings and commit them through `committer`.
3. Report the criteria table and the review verdict, then ask whether to open the PR with `/pr`.

## Important Rules

- **Never write code before step 5 approval**
- **Never call the ticket done with an unmet acceptance criterion**
- **Never guess** — if something in the plan or ticket is unclear, ask
- **Stay in the worktree** — all work happens in the worktree directory
- **Follow CLAUDE.md and CLAUDE.local.md** conventions for code style, commits, and PRs

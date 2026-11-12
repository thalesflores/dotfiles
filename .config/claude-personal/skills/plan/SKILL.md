---
name: plan
description: Generate technical plans and implementation tickets from a problem description, idea, or GitHub issue. Explores the codebase, drafts architecture, and breaks work into deployable tickets.
---

# Plan

Orchestrates the `feature-planner` and `ticket-splitter` agents to go from a problem description to a ready-to-implement plan with tickets.

## Input Parsing

The skill accepts multiple input formats:

```shell
# Structured input (inline or from previous message)
/plan <structured input with problem/idea/references>

# GitHub issue as starting point
/plan gh:42

# Local file with requirements
/plan file:./docs/feature-spec.md

# Quick prompt
/plan "Add a circuit breaker around third-party API imports"

# No args — interactive mode
/plan
```

## Workflow

### 1. Collect Inputs

Parse the user's input for three pieces:

**a) Problem** (required):
- From structured `<problem-to-solve>` block
- From a GitHub issue (`gh issue view <N> --json title,body`)
- From a file
- From the prompt string

**b) Idea** (optional but valuable):
- From structured `<idea>` block
- From the issue's implementation notes or description
- If the user gave a clear problem with investigation hints (e.g., "check the mutations table", "look at commits for X"), that's sufficient context — start exploring. Only ask if the problem is truly ambiguous.
- If not provided and the problem is ambiguous: "Do you have an idea for how to approach this? (release strategy, architecture direction, constraints). Or should I explore and propose?"

**c) References** (optional):
- From structured `<references>` block
- Codebase paths, Figma URLs, GitHub URLs, other plan paths, images
- Don't ask if the user already gave enough investigation pointers in the problem description. Only ask if you genuinely don't know where to start.

**If any required piece is missing, use `AskUserQuestion` to collect it.** Don't start planning without understanding the problem. But don't over-ask when the user already gave clear direction.

### 2. Determine Output Location

Ask the user where to save, suggesting a default:

```
Where should I save the plan?
Default: src/plannings/<feature-name>/
```

Create the directory if it doesn't exist.

### 3. Generate Plan

Spawn the `feature-planner` agent via Task tool:

```
Task(
  subagent_type: "general-purpose",
  prompt: "<assembled prompt with problem, idea, references, output path, and instruction to follow the feature-planner agent guidelines>"
)
```

**The prompt to the agent must include:**
- The full problem description
- The idea (if provided)
- All references (paths, URLs)
- The output path for `plan.md`
- Instruction: "First, read `~/.claude/agents/feature-planner.md` for the full template, rules, and workflow you must follow."
- Instruction to read existing plans in the project's `plannings/` directory for style reference

### 3b. Adversarial Review

Before showing the plan, have a fresh agent attack it. It did not write the plan, so it has nothing to defend:

```
Task(
  subagent_type: "general-purpose",
  model: "opus",
  prompt: """
    Review <plan path> adversarially against the codebase. Read the code it cites.
    Report only problems you can point to, each as: section | problem | evidence (file:line) | fix.
    Check: paths/modules/functions it names exist; each milestone deploys alone
    without breaking the build or data; missing edge cases, failure modes, migrations
    or rollback; a simpler design that meets the same goal; scope beyond the problem.
    Return "no findings" if it holds up. Do not edit the plan.
  """
)
```

Fix the findings you agree with directly in `plan.md`. List any you rejected, with one line on why, when you present the plan.

### 4. Review Plan

After the agent completes:
- Read the generated `plan.md`
- Present the agent's summary to the user, plus what the review changed
- Tell the user where the file is so they can read it

Ask: "Review the plan and let me know what to adjust. You can also leave inline `#` comments directly in the file — I'll pick them up and address each one. Once you're happy, I'll break it into implementation tickets."

**Wait for explicit approval before proceeding to tickets.** The user may want to:
- Refine specific sections
- Change the milestone structure
- Adjust scope or risk assessment
- Add/remove deliverables

**Inline comment review:** The user may leave `#` comments directly in the plan file. When they say "I left comments" or similar, re-read the file, find all `#` comments on existing lines, address each one, and update the plan accordingly.

If refinements are requested, re-spawn the agent with the feedback, or make targeted edits directly if they're small.

### 5. Generate Tickets

Once the plan is approved, spawn the `ticket-splitter` agent:

```
Task(
  subagent_type: "general-purpose",
  prompt: "<prompt with plan path, output path, and instruction to follow the ticket-splitter agent guidelines>"
)
```

**The prompt must include:**
- Path to the approved `plan.md`
- Output path for `tickets.md` (same directory as plan)
- Ticket prefix if the user provided an issue number
- Instruction: "First, read `~/.claude/agents/ticket-splitter.md` for the full template, rules, and workflow you must follow."
- Instruction to read existing `tickets.md` files in the project's `plannings/` directory for style reference

### 6. Review Tickets

After the agent completes:
- Read the generated `tickets.md`
- Present the summary (ticket count, parallel opportunities, critical path, any ambiguities)
- Tell the user where the file is

Ask: "Review the tickets. Want to adjust anything before we start?"

### 7. Create GitHub Issues (Optional)

Once tickets are approved, ask: "Want me to create GitHub issues for these tickets, or keep them local only?"

**If creating issues** (repo from `gh repo view`, or the one the user names):

1. For each ticket in `tickets.md`: `gh issue create --title "<ticket title>" --body-file <tmp file with the Context + Tech details sections>`. Add a milestone label (e.g. `M1`) only if the repo already uses one.
2. Update the ticket heading in `tickets.md` with the issue: `### T1: Some title — TODO (owner/repo#43)`.
3. Report the created issues with their links.

**Never include local file paths** (e.g. `plannings/...`) in issue bodies. They must be readable without repo access.

**If no:** skip to next steps.

### 8. Next Steps

After everything is created, ask the user how they want to proceed:

"Ready to start implementation. How do you want to proceed?"

Options:
- **Start a single ticket** — `/kickoff ticket:T1 from:<tickets-path> plan:<plan-path>` to begin the first (or any specific) ticket
- **Work parallel tickets with teammates** — if there are parallel tickets (e.g., T1, T2, T3), offer to spawn a team with `/kickoff` running in separate worktrees for each parallel ticket simultaneously
- **Not now** — just confirm where the plan and tickets are saved for later

## Structured Input Format

When the user provides structured input, parse these blocks:

```xml
<plan>
<problem-to-solve>
The description about what we want to solve.
</problem-to-solve>

<idea>
How the engineer envisions the solution. Release strategy, architecture direction,
scope boundaries, constraints. This guides the plan — follow it.
</idea>

<references>
- src/apps/migrator/lib/migrator/extractor.ex (current extractor flow)
- src/plannings/parallel_imports/plan.md (use as architecture reference)
- https://figma.com/design/xxx (UI designs)
- https://github.com/org/repo/issues/123 (related discussion)
</references>
</plan>
```

All three blocks are optional — ask for what's missing.

## Rules

- **Never start planning without understanding the problem** — ask questions first
- **Never generate tickets without plan approval** — the plan is the contract
- **Never skip codebase exploration** — the agents must read real code, not guess
- **Respect the engineer's idea** — if they described an approach, the plan should follow it (or explain why a different approach is better)
- **Scale to the problem** — a 2-day fix gets a lightweight plan, a multi-week feature gets a full RFC
- **Follow CLAUDE.md and CLAUDE.local.md** conventions for the project
- **Never include local file paths in GitHub issues** — external descriptions must be self-contained and readable without repo access
- **Do NOT implement code** — this skill produces plans and tickets only

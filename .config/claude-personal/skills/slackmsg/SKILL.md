---
name: slackmsg
description: Draft a concise, jargon-free Slack message from technical findings. Use when the user wants to turn code/infra/incident details into a message for leadership, product, customers, or a channel — anything "write a Slack message", "draft a message for X", "make this shareable".
---

# slackmsg

Turn technical findings into a copy-ready Slack message. Output the message and nothing else the user has to edit out.

## Rules

- **Verify first.** Never state a fact you haven't checked against live source (code/HEAD, grpcurl, terragrunt plan, DB, provider docs). If a claim can't be verified, leave it out or flag it — do not guess.
- **Concise and jargon-free.** Write for the stated audience. Assume they don't know internal names, service names, or acronyms — expand or drop them.
- **Minimal formatting.** No markdown headers. Plain sentences and, at most, a short bullet list. No bold-everything.
- **Links.** Cite code as GitHub permalinks (full `github.com/.../blob/<sha>/path#Lxx`), never bare `file:line`.
- **One draft, tight.** Produce the short version directly — don't ship a verbose first pass expecting a "make it shorter" round.

## Output

The message text only, wrapped so it's easy to copy. Then one line: who it's for + any unverified claim you had to flag. If a clipboard tool is available (`pbcopy`), copy it.

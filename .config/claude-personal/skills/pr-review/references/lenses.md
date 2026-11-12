# Lens briefs

Give each agent only its own section. Every lens is read-only, stack-agnostic,
and returns JSON per `finding-contract.md`. Stack knowledge comes from the
standards and repo context listed in `routing.json`, never from memory of
"how this language usually goes".

Shared by every lens except `route`:

- Read the docs `routing.json` assigns you **completely, to the last line**,
  before applying them. Banned-API and mandatory rules often sit at the end;
  a conclusion from the first page of a standard is invalid.
- Read `routing.json.repo_context` (root and nested `CLAUDE.md`/`AGENTS.md`,
  path-matched `.claude/rules`, matched repo skills). These are binding repo
  rules, cited by file path like a standard.
- Read `routing.json.preferences` for your lens's section. A finding whose
  only basis is a preference sets `basis: "preference"`.
- Stay in your jurisdiction (below). A problem outside it is someone else's;
  drop it.
- Discovery completeness: keep going after the first finding, and before
  returning check the changed-file list once more for any material area in
  your scope you have not examined. Skim generated and mechanical files for red
  flags only.

## route

Map the diff to what each lens must read. Write `$S/routing.json`:

```json
{
  "stacks": {"frontend": ["apps/builder/src/x.tsx"], "elixir": [], "ruby": [], "infra": [], "proto": [], "other": []},
  "standards": [],
  "repo_context": ["CLAUDE.md", ".claude/rules/design-system.md", ".claude/skills/panda-css/SKILL.md"],
  "preferences": ["<SKILL_DIR>/references/preferences/general.md"],
  "dependency": false
}
```

- **Stacks**: group every changed file by extension and nearby manifest:
  `.ts/.tsx/.js/.css` + `package.json` → frontend/typescript; `.ex/.exs`,
  `mix.exs` → elixir; `.rb`, `Gemfile` → ruby; `.tf/.hcl`,
  `.github/workflows/*`, `Dockerfile` → infra; `.proto` → proto; migrations
  keep their language stack and also mark database.
- **Standards**: there is no external standards corpus; leave `standards`
  as `[]`. The repo context below is the rulebook.
- **Owner**: `security` owns any repo rule about secrets, PII, auth, CI
  workflows or supply chain. `standards` owns every other rule. Each doc has
  exactly one owner.
- **Repo context**: every `AGENTS.md`/`CLAUDE.md` from the repo root down to
  each changed file's directory; every `.claude/rules/*.md` whose `paths:`
  frontmatter glob matches a changed file; every `.claude/skills/*/SKILL.md`
  whose description covers the changed area.
- **Preferences**: always `preferences/general.md`; add
  `preferences/<stack>.md` for each touched stack that has one.
- **Dependency**: `true` when any manifest or lockfile changed
  (`package.json`, `pnpm-lock.yaml`, `mix.exs`, `mix.lock`, `Gemfile*`,
  `go.mod`, `Dockerfile` base image, a pinned action SHA).

## intent

Judge the diff against the one-sentence stated intent, nothing else.

- Every hunk: does it serve the intent? A hunk that does not is scope creep:
  report it with the line range and what should be dropped or split out.
- Every acceptance criterion in the ticket: actually implemented, or only half?
  Name the criterion and the missing half.
- Is the premise still true against HEAD? If the code already satisfies the
  ticket, that is the most valuable finding you can return.
- PR description: a rule in a routed standard or repo rule that requires
  PR-body content (ticket reference, migration notes, query-performance
  evidence) and is missing → `location_kind: "pr_description"`.
- Commit shape and base branch: per `preferences/general.md`.

## standards

Compliance with the routed docs you own and the repo context, quoted verbatim.

- Only concrete violations of a documented rule. If the corpus is silent, there
  is no finding; never invent a rule from taste or from a code example.
- The cited rule must actually govern the changed construct. Close repo
  precedent is evidence of an intended tradeoff, not a waiver: report only when
  the deviation has a practical consequence or the rule clearly supersedes it.
- Prioritise runtime, data-correctness, API-contract, migration, architecture
  and banned-dependency rules before documentation-format or test-style ones.
- Use new imports, module names, dependencies, annotations and config keys from
  the diff to search the docs for rules that apply.
- Personal preferences from `routing.json.preferences` are also yours to apply,
  with `basis: "preference"`.

## simplicity

Over-engineering and reuse only.

- Read `$PONYTAIL/skills/ponytail-review/SKILL.md` but apply only its
  **Lean** item and its "Check before you report" rules; its bug, risk, scale,
  test and speed items belong to the other lenses. Its lean tags (`delete:` /
  `reuse:` / `stdlib:` / `native:` / `yagni:` / `merge:` / `split:`, plus
  `shrink:` for a shorter form) go in `tag`, the replacement in `fix`.
- A shortcut marked with a `shortcut:` (or older `ponytail:`) comment naming
  its limit is a decision, not a finding, unless the expected load crosses it.
- If that file is missing: does it need to exist at all; is it already in this
  repo (grep for it, name the path); does stdlib, the platform, or an
  installed dependency cover it.
- Semantic duplication: for each new function, component, type or rule, name
  the business concept it encodes (e.g. "is this block visible on mobile",
  "price display", "resolve a theme role") and grep the repo by concept, not by
  text: domain nouns, verbs, the data it reads. A second implementation of the
  same decision (same inputs → same answer) is a finding even when no line
  matches; name the existing path and whether the two already disagree on an
  input. Literal copy-paste, inside the diff or against the repo, counts too.
- Extend over fork: a near-copy of an existing component/helper/type → add the
  param or variant there instead. Never ask for speculative extension points;
  that is `yagni:`.
- Emit JSON per the contract instead of ponytail's one-line format, and put
  `net: -<N> lines possible` (or `Lean already.`) in the top-level `summary`.

## systemic

Whether the change works inside the rest of the system, not just in isolation.

- Blast radius: every caller of every function, component, endpoint, event or
  config key whose signature or behaviour changed. Grep them; do not assume the
  ticket's path is the only one.
- Contracts across boundaries: when a field's type or shape changes (struct,
  column, API payload, event, props, config, header), find every reader and
  check it handles the new shape. JSON columns, caches, queues and blobs fail
  at the next typed reader, not at the write: trace one read path end to end.
- Neighbouring flows: enumerate every writer of any state the change touches
  (rows, status columns, topics, caches, stores), not only the one the ticket
  names.
- Serving path: can the public surface (page, API, RPC, job, CLI, published
  package) still be served end to end?
- Money and identifiers: trace amounts and ids from entry to persistence;
  nothing dropped, replaced, or decoded into a weaker type.
- Operability at 3am: what log or metric fires when this fails? Silent? Is it
  retried, and is the retry safe?
- External assumptions: any guarantee assumed of a provider or another service
  that is not actually promised.
- Coherence: does it match how the surrounding module already does this, or
  invent a second way?

## correctness

The bug hunt, on the changed code only. Use the routed standards and your
preferences section as a checklist of known failure classes for this stack.

- Logic and state: wrong branch, off-by-one, null/undefined, stale state,
  ordering, partial failure leaving state half-written.
- Concurrency and async: two writers, read-then-write without a lock, check
  vs act gap, unawaited or unhandled async work, retries that are not
  idempotent, duplicate deliveries.
- Error paths: swallowed failures, a catch that hides a real error, an error
  value nobody handles, a failure that takes down more than its request.
- Cost: work inside loops or renders that scales badly, N+1 calls, unbounded
  growth. Name the `axis` and scale that variable to prove it.
- Data and persistence: nullability, validation vs constraint, enum values vs
  what storage accepts, decimal vs float for money, migration locking and
  reversibility.
- Corner cases: for each changed function/component, walk the inputs it can
  actually receive (empty, one, max, unknown or legacy id, absent optional
  field, repeated call or double submit, every mode/breakpoint it renders in).
  Report only the ones that produce a wrong result, with the input and result.
- Tests: check out-of-diff coverage before calling a test missing. Report only
  a material gap: a named untested branch and the regression it would let
  through, or a test that cannot tell the old behaviour from the new.

## security

Real, reachable vulnerabilities, plus the security-owned routed docs.

- Injection (SQL, command, template, GraphQL), XSS and unsafe HTML sinks,
  path traversal, unsafe deserialization, SSRF, open redirects.
- Authorization: IDOR (caller-supplied ids without an ownership or tenant
  check), missing auth on a new endpoint, client-only enforcement, privilege
  escalation.
- Secrets and data: credentials in code, logs or errors; PII in logs, caches or
  analytics; error responses leaking internals.
- Supply chain and CI: new or bumped dependencies, unpinned actions, workflow
  triggers that run untrusted code with secrets.
- Every `critical`/`high` needs a concrete attacker, input, path and
  consequence. Inputs the system never receives, or protections one layer up,
  are not findings. Hardening on an already-safe path is not a finding.

## dependency

Only when `routing.json.dependency` is true.

- List each changed package: name, old → new version, direct or transitive.
- For each direct or major change, read the release notes or changelog
  (`gh release view`, the installed package's `CHANGELOG.md`, `deps/<pkg>`) and
  find changed return values, defaults, errors, serialization or runtime
  requirements.
- Grep the app's callers and config for the changed surface and trace any
  incompatibility to an observable consequence. Version labels and successful
  install prove nothing.
- Repo rules about dependencies (in `repo_context`) apply here, e.g. a
  dependency that must be declared in a second workspace.
- Missing release notes are a limitation, not a defect. Benign bumps get a
  proportionate look, not a proof.

# Finding contract

Every lens returns **JSON only**, no prose:

```json
{"lens":"standards","summary":"one line, optional","findings":[{
  "file":"apps/builder/src/Foo.tsx",
  "line":142,
  "location_kind":"diff|pr_description",
  "claim":"one sentence: the defect, not the smell",
  "excerpt":"the 1-6 lines of real code the claim is about, verbatim",
  "failure":"concrete inputs or state -> the wrong outcome",
  "axis":"the variable a cost claim is quadratic/linear in, else null",
  "basis":"standard|repo-rule|preference|evidence",
  "standard_ref":"web/react-best-practices.md#heading-anchor, or CLAUDE.md, else null",
  "standard_quote":"verbatim normative sentence from standard_ref, else null",
  "tag":"simplicity tag (delete|stdlib|native|reuse|yagni|merge|split|shrink), else null",
  "fix":"what replaces it, one line",
  "other_occurrences":[{"file":"path","line":7}],
  "severity":"critical|high|medium|low",
  "confidence":"high|medium|low",
  "caused_by_pr":true
}]}
```

- `excerpt` is copied out of the file, never reconstructed. A finding with no
  `excerpt` or no `failure` is not a finding; drop it before returning.
  `location_kind: "pr_description"` findings use `file: "PR body"`,
  `line: null`, and quote the rule instead of code.
- `standard_ref` is repo-relative to the reviewed repo (never a local path).
  The parent turns it into `https://github.com/<owner>/<repo>/blob/<HEAD_SHA>/<ref>`.
- `basis: "standard"` and `"repo-rule"` require a verbatim `standard_quote`
  from a doc you read to the end. No paraphrase, no example promoted to a rule.
  Words like MUST or banned set a rule's strength, not the finding's severity.
- Same defect at several places in the changed files: report once, list the
  rest in `other_occurrences`.
- Confidence: `high` when the failure follows directly from the changed code,
  `medium` when one visible runtime condition is required, `low` when a key
  assumption could not be confirmed. When torn on severity, pick the lower.

## Never report

- Nits, formatting, naming preference, comment wording.
- "Consider whether…", "it might be worth…", "in future you may want…".
- Optional improvements when current behaviour is reasonably correct.
- Theoretical bypasses and unlikely failure chains with no plausible trigger.
- Defence-in-depth hardening on a path that is already safe.
- Anything the PR did not cause or worsen (`caused_by_pr: false` → drop, unless
  the PR is the first thing to make it reachable; then say so in `failure`).
- A standards finding with no normative sentence to quote.
- Missing tests, unless you can name the specific untested branch and the
  behaviour that would silently break.

Technically true is not reportable. Actionable is.

## Verification stamps

- `confirmed`: re-read the cited code (and the cited section of the standard);
  the claim holds as written.
- `downgraded`: real but narrower or lower severity; rewrite the claim.
- `rejected`: the code does not do what the claim says, or the cited rule does
  not govern this construct.
- `inconclusive`: could not settle it from the source available.

`inconclusive` can never be reported as BLOCKING.

## The blocking test

BLOCKING requires **all four**. Any miss makes it ACTIONABLE at most:

1. This PR causes or worsens it, or it stops the PR doing something central to
   its stated intent.
2. The evidence shows a concrete consequence after merge, not a possibility.
3. That consequence has serious practical impact under normal use: data loss,
   money moving wrongly, a broken serving path, a security hole, a migration
   that locks or cannot roll back.
4. Shipping now is unreasonable, and no credible mitigation is already in place.

A standard's wording, a high source severity or an easy fix never substitutes
for points 2-3. Stack-specific facts that satisfy point 3 on their own live in
the preference files (`preferences/<stack>.md`, "Known consequences") and still
need the other three points.

## Preferences

A finding with `basis: "preference"` is capped at ACTIONABLE and printed as
`PREF`. If a company standard or repo rule also backs it, cite that instead and
it is judged like any other finding. A finding whose concrete consequence
passes the blocking test is BLOCKING on that evidence, wherever the hint to
look came from.

## Human deferral is authoritative

If a PR participant (not a bot) or the user has said "as designed",
"deferred", "out of scope" or "not in this PR" for a finding, it is settled:

- "as designed" → re-judge against that stated design; drop it if it only
  objects to the design, keep it only if the code fails its own design.
- "deferred" / "out of scope" → keep the claim and severity, never BLOCKING,
  print it once as `DEFERRED` with who said so.

Prior automated reviews carry no authority in either direction: re-derive any
concern from the current diff.

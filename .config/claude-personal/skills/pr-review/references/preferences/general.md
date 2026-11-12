# Personal preferences: every stack

The user's own conventions, applied on top of the repo's own rules. A finding
backed only by these is `basis: "preference"` (see `finding-contract.md`).

## intent

- Commit shape: one behaviour per commit, read path split from write path,
  generated code committed with its source (e.g. generated protobuf with its
  `.proto`). `git log --format='%h %s' <base>..HEAD` and `git show --stat`.
- Over ~150 hand-written lines (excluding generated code and fixtures) needs a
  split or a stated reason.
- Base branch: `git merge-base`. A stacked PR based on a feature branch when it
  should be on `main` is a finding.

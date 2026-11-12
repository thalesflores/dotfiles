# Live git state + drift check

Inputs from the caller: the step 1-3 tickets JSON (with `repos` and `id_scheme`), the peer session names from `ListAgents`, and `SKILL_DIR`.

## 1. Fetch

Call `bin/git-snapshot.sh` — it does worktrees + branches + open PRs + recent log per branch in one parallel pass and returns JSON.

Run it in **every** repo in the `repos` list, not just the cwd repo: a plan's tickets live in many repos, and a ticket's worktree in a sibling repo is invisible from the cwd. Clones sit next to the current repo:

```bash
OUT=$(mktemp -d); ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)" | xargs dirname)
for r in <repo names from `repos`, owner stripped>; do
  if [ -e "$ROOT/$r/.git" ]; then
    ${SKILL_DIR}/bin/git-snapshot.sh --repo "$ROOT/$r" --filter '<id-regex>' | jq -c --arg r "$r" '{repo:$r}+.' > "$OUT/$r.json" &
  else echo "{\"repo\":\"$r\",\"cloned\":false}" > "$OUT/$r.json"; fi
done; wait; jq -s . "$OUT"/*.json
```

Pick `--filter` from `id_scheme`:
- `jira` → `--filter '[A-Z]+-[0-9]+'`
- `github` → `--filter 'gh-[0-9]+'`
- `local` → `--filter '(M[0-9]+-|T-)'`
- unknown → omit `--filter` (every local branch; usually too noisy)

See `${SKILL_DIR}/references/git-snapshot-schema.md` for the JSON shape. If `bin/git-snapshot.sh` is unavailable, run `git worktree list`, `git branch --list`, `gh pr list --author @me` and `git log --oneline -5 <branch>` in parallel and build that shape yourself.

Uncloned repos still get PRs, from one org-wide search in the same pass:

```bash
gh search prs --author @me --owner <owner> --state open --json repository,number,title,url --limit 100
```

Map each peer session to its cwd: `tmux list-panes -a -F '#{pane_id} #{pane_current_path}'`. A peer whose cwd is a ticket's worktree owns that ticket.

When `id_scheme` is `github`, also fetch the live issue status (`<owner/repo>` = the repo the planning files reference tickets in, else the current repo):

```bash
gh issue list --repo <owner/repo> --state all --limit 300 --json number,state,assignees,milestone,blockedBy,closedByPullRequestsReferences
```

## 2. Drift check

List drift between the tickets and the git snapshots: a ticket in progress whose branch is gone or whose PR is merged, a todo ticket that already has a worktree, branch, commit or PR in ANY repo (match the issue number in the branch name), a done ticket whose PR is still open, a ticket whose worktree another Claude session sits in. Against the GitHub issues: a todo/in-progress ticket whose issue is closed, assigned to someone other than @me, has a linked PR not in the git snapshot, or sits in another milestone; a done ticket whose issue is still open. GitHub wins over the state file.

## 3. Return

Only this JSON, never the raw snapshots:

```json
{"drift": [...], "presentation": "<${SKILL_DIR}/references/summary-template.md, filled>"}
```

#!/usr/bin/env bash
# Parallel git/gh data collection for resurrect & save-state. Returns one
# JSON blob with worktrees, relevant branches, open PRs, recent commits
# per active branch, and (optionally) diff stats. Zero LLM tokens — same
# off-context property as PR #107's pr-poller replacement.
#
# Usage:
#   git-snapshot.sh [--filter <regex>] [--include-diff] [--repo <path>]
#
# Flags:
#   --filter <regex>     Branch filter; only branches matching this regex
#                        appear in `branches` + `recent_log`. Useful to
#                        narrow to feature-specific branches (e.g.
#                        '[A-Z]+-[0-9]+'). Default: all non-main local branches.
#   --include-diff       Also run `git diff --stat` per active branch.
#                        save-state wants this; resurrect doesn't.
#   --repo <path>        Repo root (default: cwd).
#
# Output schema:
# {
#   "worktrees": [{"path":"...","branch":"...","head":"..."}],
#   "branches":  [{"name":"...","head":"..."}],
#   "prs":       [{"number":N,"title":"...","branch":"...","url":"...","state":"..."}],
#   "recent_log":[{"branch":"...","commits":[{"sha":"...","subject":"..."},...]}],
#   "diff_stat": [{"branch":"...","files_changed":N,"insertions":N,"deletions":N}],
#   "current_branch": "..."
# }
#
# diff_stat is null when --include-diff isn't passed.

set -euo pipefail

FILTER=''
INCLUDE_DIFF=0
REPO='.'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --filter)        FILTER="$2";   shift 2 ;;
    --include-diff)  INCLUDE_DIFF=1; shift   ;;
    --repo)          REPO="$2";     shift 2 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *)
      printf '{"error":"unknown flag: %s"}\n' "$1" >&2
      exit 2
      ;;
  esac
done

cd "$REPO"

# ── worktrees ────────────────────────────────────────────────────────
# git worktree list --porcelain emits 3-line blocks per worktree:
#   worktree <path>
#   HEAD <sha>
#   branch refs/heads/<branch>   (or "detached")
#
# Use awk to emit a TSV stream (path \t branch \t head) per worktree, then
# let jq do the JSON quoting. Direct printf into JSON inside awk would
# break on paths or branches containing quotes / backslashes / control
# characters — jq's -R input mode handles that correctly.
worktrees_json=$(git worktree list --porcelain 2>/dev/null | awk '
  BEGIN { OFS="\t" }
  /^worktree / { path=substr($0,10); next }
  /^HEAD /     { head=substr($0,6); next }
  /^branch /   { branch=substr($0,8); sub(/^refs\/heads\//, "", branch);
                 print path, branch, head; next }
  /^detached$/ { print path, "__detached__", head; next }
' | jq -Rsc 'split("\n") | map(select(length > 0) | split("\t") | {
  path: .[0],
  branch: (if .[1] == "__detached__" then null else .[1] end),
  head: .[2]
})')
[[ -z "$worktrees_json" ]] && worktrees_json='[]'

# ── relevant branches ────────────────────────────────────────────────
# git branch --list lists local branches. If FILTER is set, only keep
# matching branches. jq -R handles JSON-escaping for branch names that
# could contain unusual characters.
branches_raw=$(git branch --list --format='%(refname:short)%09%(objectname:short)' 2>/dev/null || true)
if [[ -n "$FILTER" ]]; then
  branches_raw=$(echo "$branches_raw" | grep -E "$FILTER" || true)
fi
branches_json=$(printf '%s\n' "$branches_raw" | jq -Rsc 'split("\n") | map(select(length > 0) | split("\t") | {
  name: .[0],
  head: .[1]
})')
[[ -z "$branches_json" ]] && branches_json='[]'

# ── current branch ──────────────────────────────────────────────────
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# ── open PRs (by current user) ──────────────────────────────────────
# gh pr list returns JSON we can pass straight through. Use a short field
# set so the output stays compact. Fall back to [] if gh isn't installed,
# isn't authenticated, or otherwise fails — never crash the snapshot.
prs_json='[]'
if command -v gh >/dev/null 2>&1; then
  gh_output=$(gh pr list --author '@me' --state open --json number,title,headRefName,url,state 2>/dev/null || true)
  if [[ -n "$gh_output" ]]; then
    prs_json=$(echo "$gh_output" | jq '[.[] | {number, title, branch: .headRefName, url, state}]' 2>/dev/null || echo '[]')
  fi
fi

# ── recent log per branch ───────────────────────────────────────────
# For every branch in branches_json, grab the last 5 commits as {sha, subject}.
recent_log='[]'
branch_names=$(echo "$branches_json" | jq -r '.[].name')
if [[ -n "$branch_names" ]]; then
  recent_log=$(while IFS= read -r br; do
    [[ -z "$br" ]] && continue
    commits=$(git log --oneline -5 "$br" 2>/dev/null | awk '{
      sha=$1
      sub(/^[^ ]+ +/, "")
      gsub(/"/, "\\\"")
      printf "{\"sha\":\"%s\",\"subject\":\"%s\"}\n", sha, $0
    }' | jq -s '.')
    [[ -z "$commits" ]] && commits='[]'
    jq -nc --arg branch "$br" --argjson commits "$commits" '{branch:$branch, commits:$commits}'
  done <<< "$branch_names" | jq -s '.')
fi

# ── diff stat per branch (optional) ─────────────────────────────────
diff_stat='null'
if [[ "$INCLUDE_DIFF" == "1" && -n "$branch_names" ]]; then
  diff_stat=$(while IFS= read -r br; do
    [[ -z "$br" ]] && continue
    # `git diff --stat <branch>` returns lines like:
    #   path/to/file | 5 +++--
    #   2 files changed, 3 insertions(+), 2 deletions(-)
    # We only need the summary line.
    summary=$(git diff --stat "main..$br" 2>/dev/null | tail -1 || true)
    if [[ -n "$summary" ]]; then
      fc=$(echo "$summary" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' | head -1 || echo 0)
      ins=$(echo "$summary" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' | head -1 || echo 0)
      dels=$(echo "$summary" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' | head -1 || echo 0)
      jq -nc --arg branch "$br" \
        --argjson fc "${fc:-0}" --argjson ins "${ins:-0}" --argjson dels "${dels:-0}" \
        '{branch:$branch, files_changed:$fc, insertions:$ins, deletions:$dels}'
    fi
  done <<< "$branch_names" | jq -s '.')
fi

jq -nc \
  --argjson worktrees "$worktrees_json" \
  --argjson branches "$branches_json" \
  --argjson prs "$prs_json" \
  --argjson recent_log "$recent_log" \
  --argjson diff_stat "$diff_stat" \
  --arg current_branch "$current_branch" \
  '{worktrees:$worktrees, branches:$branches, prs:$prs, recent_log:$recent_log, diff_stat:$diff_stat, current_branch:$current_branch}'

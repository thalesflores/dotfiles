#!/usr/bin/env bash
# Create a git worktree with a deterministic branch name for kickoff.
# Slugifies + truncates the branch name, fetches and adds the worktree off
# origin/main (never the possibly stale local main), and
# reports where to cd. Zero LLM tokens spent on naming/bash reasoning.
#
# Usage:
#   create-worktree.sh --source gh|local --id <ID> --title <title> [--base <ref>]
#
# Branch naming (whole branch truncated to 50 chars):
#   gh    -> gh-<ID>-<slug>     e.g. gh-42-fix-pagination
#   local -> <ID>-<slug>        e.g. M1-1-feature-flag-data-model
#
# Output schema:
# { "branch": "...", "worktree_path": "...", "code_dir": "<path or null>" }
#
# code_dir points at a nested source dir (e.g. src/) if one exists, so the
# skill knows where to cd; null means cd to the worktree root.

set -euo pipefail

SOURCE='' ID='' TITLE='' BASE='origin/main'
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --id)     ID="$2";     shift 2 ;;
    --title)  TITLE="$2";  shift 2 ;;
    --base)   BASE="$2";   shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) printf '{"error":"unknown flag: %s"}\n' "$1" >&2; exit 2 ;;
  esac
done

if [[ -z "$SOURCE" || -z "$ID" ]]; then
  printf '{"error":"--source and --id are required"}\n' >&2
  exit 2
fi

# slugify title: lowercase, non-alnum runs -> single -, trim leading/trailing.
# tr -cs squeezes runs (portable; avoids BSD sed's lack of \+).
slug=$(printf '%s' "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs 'a-z0-9' '-' \
  | sed -e 's/^-//' -e 's/-$//')

case "$SOURCE" in
  local) prefix="$ID" ;;
  gh)         prefix="gh-$ID" ;;
  *) printf '{"error":"unknown source: %s"}\n' "$SOURCE" >&2; exit 2 ;;
esac

if [[ -n "$slug" ]]; then
  branch="${prefix}-${slug}"
else
  branch="$prefix"
fi
# truncate to 50 chars, then trim any trailing dash left by the cut.
branch=$(printf '%s' "$branch" | cut -c1-50 | sed 's/-*$//')

toplevel=$(git rev-parse --show-toplevel)
project_name=$(basename "$toplevel")
worktree_path="$(dirname "$toplevel")/${project_name}-${branch}"

# Fetch first so a remote base is current; --no-track keeps the new branch
# from tracking the base (the first push sets its own upstream).
if [[ "$BASE" == origin/* ]]; then
  git fetch -q origin "${BASE#origin/}" >&2
fi
git worktree add --no-track "$worktree_path" -b "$branch" "$BASE" >&2

# Detect a nested code dir the skill should cd into instead of the root.
code_dir='null'
for sub in src app; do
  if [[ -d "$worktree_path/$sub" ]]; then
    code_dir=$(jq -nc --arg p "$worktree_path/$sub" '$p')
    break
  fi
done

jq -nc \
  --arg branch "$branch" \
  --arg worktree_path "$worktree_path" \
  --argjson code_dir "$code_dir" \
  '{branch:$branch, worktree_path:$worktree_path, code_dir:$code_dir}'

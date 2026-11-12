#!/usr/bin/env bash
# Discover candidate planning directories. Shared by save-state & resurrect.
# Globs for planning-file patterns, groups matches by parent directory, and
# returns a JSON list of unique candidate directories. Zero LLM tokens spent
# on the glob/group pass — the skill only makes the final pick.
#
# Usage:
#   discover-planning-dir.sh [--repo <path>]
#
# Output schema:
# { "candidates": ["docs/plans/my-feature", "..."] }
#
# Paths are relative to the repo root. Empty candidates => let the skill ask.

set -euo pipefail

REPO='.'
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) printf '{"error":"unknown flag: %s"}\n' "$1" >&2; exit 2 ;;
  esac
done

cd "$REPO"

# Name patterns that mark a planning directory. Kept in sync with the skills'
# documented globs: plannings*, state.md, plan*.md, ticket*.md, backlog*.md,
# tasks*.md.
matches=$(find . \
  \( -name .git -o -name node_modules -o -name deps -o -name _build \
     -o -name .elixir_ls -o -name .terraform -o -name vendor \) -prune -o \
  -type f \( \
     -name 'plannings*' -o -name 'state.md' -o -name 'plan*.md' \
     -o -name 'ticket*.md' -o -name 'backlog*.md' -o -name 'tasks*.md' \
  \) -print 2>/dev/null || true)

# Reduce to unique parent directories, strip leading ./, sort for stable output.
candidates_json=$(printf '%s\n' "$matches" \
  | sed -e 's#/[^/]*$##' -e 's#^\./##' \
  | sort -u \
  | jq -Rsc 'split("\n") | map(select(length > 0))')
[[ -z "$candidates_json" ]] && candidates_json='[]'

jq -nc --argjson candidates "$candidates_json" '{candidates:$candidates}'

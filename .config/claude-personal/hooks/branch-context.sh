#!/usr/bin/env bash
# SessionStart: report the branch and its drift vs origin, so no work starts on a stale ref.
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
head=$(git rev-parse --short HEAD 2>/dev/null)
dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)

if [ -n "$upstream" ]; then
  counts=$(git rev-list --left-right --count "$upstream...HEAD" 2>/dev/null)
  behind=$(echo "$counts" | cut -f1)
  ahead=$(echo "$counts" | cut -f2)
  drift="${ahead:-0} ahead, ${behind:-0} behind $upstream"
  [ "${behind:-0}" -gt 0 ] && drift="$drift -- FETCH AND REBASE BEFORE WRITING CODE"
else
  drift="no upstream tracking branch"
fi

msg="GIT STATE (as of session start, not refreshed): branch ${branch} at ${head}; ${drift}; ${dirty} uncommitted file(s). Re-check with git rather than trusting this later in the session."
python3 -c "
import json,sys
print(json.dumps({'hookSpecificOutput':{'hookEventName':'SessionStart','additionalContext':sys.argv[1]}}))
" "$msg"

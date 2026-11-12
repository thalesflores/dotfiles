#!/usr/bin/env bash
# PreToolUse: refuse to push or open a PR until this repo's static gate passes, and
# report the hand-written diff size so the ~150-line split rule is visible at push time.
# Fails OPEN (allows, with a warning) when the gate itself cannot run, so a broken
# toolchain never wedges the session.
payload=$(cat)
decide() {
  python3 -c "
import json,sys
print(json.dumps({'hookSpecificOutput':{
  'hookEventName':'PreToolUse',
  'permissionDecision':sys.argv[1],
  'permissionDecisionReason':sys.argv[2]}}))
" "$1" "$2"
  exit 0
}

# The settings `if` filter fails open on compound commands, so re-check here, and gate the
# directory the command targets (`cd X &&` or `git -C X`), not the session's project dir.
target=$(printf '%s' "$payload" | python3 -c '
import json, re, sys
p = json.load(sys.stdin)
c = p.get("tool_input", {}).get("command", "")
if not re.search(r"\bgit\s+(-C\s+\S+\s+)?push\b|\bgh\s+pr\s+create\b", c):
    sys.exit(1)
m = re.search(r"(?:^|&&|;)\s*cd\s+(\S+)\s*&&[^;]*?(?:git\s+push|gh\s+pr\s+create)", c) or re.search(r"\bgit\s+-C\s+(\S+)\s+push\b", c)
print(m.group(1).strip("\"'"'"'") if m else p.get("cwd", ""))
') || decide allow "not a push or PR create"
root=$(git -C "${target:-$PWD}" rev-parse --show-toplevel 2>/dev/null || echo "${CLAUDE_PROJECT_DIR:-$PWD}")
cd "$root" 2>/dev/null || decide allow "not in a project directory"
if [ -f mix.exs ]; then app=.; elif [ -f src/mix.exs ]; then app=src; else decide allow "no mix.exs, nothing to gate"; fi

# --- Hand-written diff size vs the merge base, excluding generated code and fixtures.
scope=""
base=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null)
if [ -n "$base" ]; then
  stats=$(git diff --numstat "$base"...HEAD -- \
    ':(exclude)*/lib/generated/**' ':(exclude)**/fixtures/**' ':(exclude)*.pb.ex' \
    ':(exclude)docs/schema.graphql' 2>/dev/null)
  handwritten=$(echo "$stats" | awk '{a+=$1; d+=$2} END {printf "%d", a+d}')
  files=$(echo "$stats" | grep -c . )
  if [ "${handwritten:-0}" -gt 150 ]; then
    scope="

SCOPE: ${handwritten} hand-written changed lines across ${files} file(s), over the ~150-line
ceiling. Justify it or split by concern/layer. Largest files:
$(echo "$stats" | sort -rn | head -5 | awk '{printf "  %+5d/-%-5d %s\n", $1, $2, $3}')"
  else
    scope="

SCOPE: ${handwritten} hand-written changed lines across ${files} file(s) (under the 150 ceiling)."
  fi
fi

command -v mix >/dev/null 2>&1 || decide allow "GATE SKIPPED: mix not on PATH. Run the static checks by hand before pushing.${scope}"

credo=""; grep -q ':credo' "$app/mix.exs" && credo=" + credo --strict"
out=$(cd "$app" && MIX_ENV=test mix do format --check-formatted + compile --warnings-as-errors$credo 2>&1)
status=$?

if [ $status -eq 0 ]; then
  decide allow "Static gate passed (format, compile -Werror${credo:+, credo}). Tests are NOT covered by this gate.${scope}"
fi

tail=$(echo "$out" | tail -30)
decide deny "Static gate FAILED (exit $status) -- do not push. Fix these, then retry:

$tail

This gate does not run tests; run them yourself.${scope}"

#!/usr/bin/env bash
# Tests for bin/git-snapshot.sh. Stubs git and gh via PATH so the script
# operates on deterministic output instead of the host repo.
#
# Note: `git branch --list --format=...` now emits tab-separated `name\thead`
# (jq -R handles the escaping that printf-into-JSON could not). All branch
# stub fixtures use literal tab characters via $'\t'.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

SCRIPT="$BIN_DIR/git-snapshot.sh"

test_basic_invocation() {
  setup_sandbox

  make_stub git <<EOF
case "\$1 \$2" in
  "worktree list")
    if [[ "\$3" == "--porcelain" ]]; then
      cat <<'OUT'
worktree /repo
HEAD abc123
branch refs/heads/main

worktree /repo-feature
HEAD def456
branch refs/heads/feature/foo

OUT
    fi
    ;;
  "branch --list")
    printf 'main\tabc123\n'
    printf 'feature/foo\tdef456\n'
    ;;
  "rev-parse --abbrev-ref")
    echo "feature/foo"
    ;;
  "log --oneline")
    echo "abc1234 first commit"
    ;;
esac
EOF

  make_stub gh <<'EOF'
if [[ "$1" == "pr" && "$2" == "list" ]]; then
  gh_emit '[{"number":42,"title":"Test PR","headRefName":"feature/foo","url":"https://github.com/x/y/pull/42","state":"OPEN"}]' "$@"
fi
EOF

  local out
  out=$("$SCRIPT")

  assert_jq_eq "$out" '.worktrees | length' '2'
  assert_jq_eq "$out" '.branches | length' '2'
  assert_jq_eq "$out" '.prs | length' '1'
  assert_jq_eq "$out" '.prs[0].number' '42'
  assert_jq_eq "$out" '.diff_stat' 'null'
  assert_jq_eq "$out" '.current_branch' '"feature/foo"'

  teardown_sandbox
}

test_filter_narrows_branches() {
  setup_sandbox

  make_stub git <<'EOF'
case "$1 $2" in
  "worktree list") echo "" ;;
  "branch --list")
    printf 'main\tabc\n'
    printf 'ABC-123-feature\tdef\n'
    printf 'PROJ-456-other\tghi\n'
    printf 'random-branch\tjkl\n'
    ;;
  "rev-parse --abbrev-ref") echo "main" ;;
  "log --oneline") echo "abc subject" ;;
esac
EOF

  make_stub gh <<'EOF'
gh_emit '[]' "$@"
EOF

  local out
  out=$("$SCRIPT" --filter '[A-Z]+-[0-9]+')

  # Should match ABC-123 and PROJ-456 but NOT main / random-branch
  assert_jq_eq "$out" '.branches | length' '2'
  assert_jq_eq "$out" '.branches[0].name' '"ABC-123-feature"'
  assert_jq_eq "$out" '.branches[1].name' '"PROJ-456-other"'

  teardown_sandbox
}

test_include_diff_emits_stat() {
  setup_sandbox

  make_stub git <<'EOF'
case "$1 $2" in
  "worktree list") echo "" ;;
  "branch --list")
    printf 'feature/x\tabc\n'
    ;;
  "rev-parse --abbrev-ref") echo "feature/x" ;;
  "log --oneline") echo "abc subject" ;;
  "diff --stat")
    echo " src/file.ex | 12 ++++++------"
    echo " 1 file changed, 6 insertions(+), 6 deletions(-)"
    ;;
esac
EOF

  make_stub gh <<'EOF'
gh_emit '[]' "$@"
EOF

  local out
  out=$("$SCRIPT" --include-diff)

  assert_jq_eq "$out" '.diff_stat | length' '1'
  assert_jq_eq "$out" '.diff_stat[0].files_changed' '1'
  assert_jq_eq "$out" '.diff_stat[0].insertions' '6'
  assert_jq_eq "$out" '.diff_stat[0].deletions' '6'

  teardown_sandbox
}

# Branch names / worktree paths containing characters that would have broken
# the previous printf-into-JSON approach: double quote, backslash, newline.
test_special_chars_in_branch_and_path() {
  setup_sandbox

  make_stub git <<'EOF'
case "$1 $2" in
  "worktree list")
    if [[ "$3" == "--porcelain" ]]; then
      cat <<'OUT'
worktree /repo/with"quote
HEAD abc123
branch refs/heads/feature/has-dash

OUT
    fi
    ;;
  "branch --list")
    printf 'feature/has-dash\tabc\n'
    ;;
  "rev-parse --abbrev-ref") echo "main" ;;
  "log --oneline") echo "abc subject" ;;
esac
EOF

  make_stub gh <<'EOF'
gh_emit '[]' "$@"
EOF

  local out
  out=$("$SCRIPT")

  # Output must still parse as valid JSON despite the embedded quote.
  echo "$out" | jq -e . >/dev/null || fail "output is not valid JSON: $out"
  assert_jq_eq "$out" '.worktrees[0].path' '"/repo/with\"quote"'

  teardown_sandbox
}

# Verify the "gh errors" fallback path in the script — `prs` should be []
# without crashing the run. We stub `gh` to fail (rather than removing it
# from PATH, which would also remove coreutils). The script's else-branch
# (`gh` not found) and its `prs_json=${prs_json:-"[]"}` fallback both
# produce the same observable result: prs:[]. Either path is fine.
test_gh_failure_yields_empty_prs() {
  setup_sandbox

  make_stub git <<'EOF'
case "$1 $2" in
  "worktree list") echo "" ;;
  "branch --list") printf 'main\tabc\n' ;;
  "rev-parse --abbrev-ref") echo "main" ;;
  "log --oneline") echo "abc subject" ;;
esac
EOF

  make_stub gh <<'EOF'
# Simulate gh failing (e.g. not authenticated, network down).
exit 1
EOF

  local out
  out=$("$SCRIPT")

  assert_jq_eq "$out" '.prs' '[]'
  assert_jq_eq "$out" '.branches | length' '1'

  teardown_sandbox
}

run_test test_basic_invocation
run_test test_filter_narrows_branches
run_test test_include_diff_emits_stat
run_test test_special_chars_in_branch_and_path
run_test test_gh_failure_yields_empty_prs

print_summary

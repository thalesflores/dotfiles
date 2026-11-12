#!/usr/bin/env bash
# Shared test helpers. Source this from each test file.
#
# Pattern: each test creates a temp dir, drops fake `gh` / `git` shims into it,
# prepends it to PATH, runs the script under test, asserts stdout / exit code.
# Real gh/git/jq are never invoked except `jq` itself (which the scripts under
# test use to format their output — that's the layer we want exercised).

set -euo pipefail

# Resolve paths relative to this file so tests work from any cwd.
TEST_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$(cd "$TEST_LIB_DIR/../bin" && pwd)"

# Counters scoped per-process. Each test file sources _lib.sh fresh.
TESTS_RUN=0
TESTS_FAILED=0
CURRENT_TEST=""

# Per-test sandbox. `setup_sandbox` makes a temp dir, exports SANDBOX, prepends
# it to PATH. `teardown_sandbox` cleans up. Stubs go in $SANDBOX/<cmd>.
setup_sandbox() {
  SANDBOX="$(mktemp -d -t babysit-test.XXXXXX)"
  ORIG_PATH="$PATH"
  # Keep /usr/bin and /bin so jq / mktemp / coreutils still work, but put
  # SANDBOX first so our stubs win for gh / git.
  export PATH="$SANDBOX:$PATH"
}

teardown_sandbox() {
  export PATH="$ORIG_PATH"
  rm -rf "$SANDBOX"
}

# Make a stub executable. Body comes via stdin so callers can write
# arbitrary script logic, including reading $@.
#   make_stub gh <<'EOF'
#     case "$1" in
#       pr) echo '{"number":42}' ;;
#     esac
#   EOF
#
# For `gh`, the stub auto-applies any trailing `--jq <filter>` to its stdout
# by piping through real `jq`. This mirrors gh's own behavior so test fixtures
# can ignore --jq and just return the raw JSON.
make_stub() {
  local name="$1"
  local path="$SANDBOX/$name"
  cat >"$path" <<HEAD
#!/usr/bin/env bash
HEAD
  cat >>"$path"
  chmod +x "$path"
}

# Helper: emit JSON from a gh stub, honoring `--jq <filter>` or `-q <filter>`
# anywhere in $@. Usage inside a gh stub:
#   gh_emit '{"foo":1}' "$@"
gh_emit() {
  local payload="$1"
  shift
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--jq" || "$1" == "-q" ]]; then
      printf '%s' "$payload" | jq -r "$2"
      return
    fi
    shift
  done
  printf '%s\n' "$payload"
}
export -f gh_emit

# Assertion: stdout contains substring. Args: <actual> <needle> [label]
assert_contains() {
  local actual="$1" needle="$2" label="${3:-output}"
  if [[ "$actual" != *"$needle"* ]]; then
    fail "$label did not contain '$needle'. Got:
$actual"
  fi
}

# Assertion: stdout parses as JSON and a jq expression yields the expected value.
#   assert_jq_eq "$out" '.status' '"failed"'
assert_jq_eq() {
  local actual="$1" filter="$2" expected="$3"
  local got
  got=$(printf '%s' "$actual" | jq -c "$filter" 2>/dev/null || true)
  if [[ "$got" != "$expected" ]]; then
    fail "jq '$filter' expected $expected, got $got. Full output:
$actual"
  fi
}

# Assertion: exit code matches.
assert_exit() {
  local actual="$1" expected="$2"
  if [[ "$actual" != "$expected" ]]; then
    fail "expected exit $expected, got $actual"
  fi
}

# Record a failure for the current test. Does not exit — lets a test
# accumulate multiple failures before reporting.
fail() {
  echo "  ✗ $CURRENT_TEST: $*" >&2
  TESTS_FAILED=$((TESTS_FAILED + 1))
  CURRENT_TEST_FAILED=1
}

# Run a single test function. Each test function sets up its own sandbox
# inside the function body — _lib doesn't auto-wrap so tests can stub before
# or after running setup_sandbox if they want unusual orderings.
run_test() {
  local fn="$1"
  CURRENT_TEST="$fn"
  CURRENT_TEST_FAILED=0
  TESTS_RUN=$((TESTS_RUN + 1))
  if "$fn"; then
    if [[ "$CURRENT_TEST_FAILED" == "0" ]]; then
      echo "  ✓ $fn"
    fi
  else
    fail "test function returned non-zero"
  fi
}

# Print summary and exit with 0 if all passed, 1 otherwise.
print_summary() {
  echo
  if [[ "$TESTS_FAILED" == "0" ]]; then
    echo "  $TESTS_RUN passed"
    exit 0
  else
    echo "  $TESTS_FAILED of $TESTS_RUN failed"
    exit 1
  fi
}

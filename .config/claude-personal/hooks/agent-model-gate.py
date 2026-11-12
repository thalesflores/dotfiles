#!/usr/bin/env python3
"""PreToolUse gate on the Agent tool: enforce subagent model routing.

model absent     -> deny, force an explicit choice
opus / fable     -> deny unless the prompt carries a `WHY OPUS:` line
Fails OPEN on an unparseable payload so a bad hook never wedges the session.
"""
import json
import sys

MECHANICAL = (
    "Pass model: 'sonnet' for anything mechanical (file reads, search, lookups, running "
    "build/format/lint/test, polling, drafting boilerplate, reformatting output someone else "
    "produced). Only pass 'opus' for architecture and design, hard debugging, adversarial "
    "verification, or nuanced code review"
)


def out(decision, reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason}}))
    sys.exit(0)


try:
    tool_input = json.load(sys.stdin).get("tool_input") or {}
except Exception:
    out("allow", "agent-model-gate: unparseable payload, failing open")

model = (tool_input.get("model") or "").strip().lower()
subagent = (tool_input.get("subagent_type") or "").strip().lower()
justification = " ".join(
    str(tool_input.get(k, "")) for k in ("prompt", "description")
).upper()

if subagent == "fork":
    out("allow", "fork inherits the parent model by design")

if not model:
    out("deny", "BLOCKED: Agent call has no `model`. " + MECHANICAL +
        " -- and then put a line starting `WHY OPUS:` in the prompt saying which one it is.")

if model in ("sonnet", "haiku"):
    out("allow", "model pinned to " + model)

if "WHY OPUS:" in justification:
    out("allow", "model " + model + " with a stated justification")

out("deny", "BLOCKED: Agent call requests model " + repr(model) + " with no justification. "
    "Either switch to model: 'sonnet', or add a line starting `WHY OPUS:` to the prompt naming "
    "which case applies (architecture/design, hard debugging, adversarial verification, nuanced "
    "code review). Measured last 30d: 25.3M of 31.7M Opus output tokens came from subagents.")

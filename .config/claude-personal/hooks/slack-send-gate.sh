#!/usr/bin/env bash
# Hard-blocks outbound Slack calls unless the user granted a one-shot token.
# Token: touch ~/.claude/.slack-send-approved   (valid 5 min, consumed on use)
token="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.slack-send-approved"
input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")

if [[ -f "$token" ]]; then
  age=$(( $(date +%s) - $(stat -f %m "$token") ))
  rm -f "$token"
  if (( age < 300 )); then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"One-shot Slack approval token consumed."}}'
    exit 0
  fi
fi

jq -n --arg t "$tool" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("BLOCKED: " + $t + ". Do not retry. Print the exact channel and full message text, then ask the user to run `! touch ~/.claude/.slack-send-approved` to authorise this single send.")
  }
}'

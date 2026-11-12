#!/usr/bin/env python3
"""Print the full usage panel, including the credits row that /usage omits on Team plans.

Usage:
  python3 ~/.claude/my-usage/usage-credits-report.py           # formatted panel, fresh data
  python3 ~/.claude/my-usage/usage-credits-report.py --raw     # raw JSON from GET /api/oauth/usage
"""

import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])
import json  # noqa: E402
from datetime import datetime, timezone  # noqa: E402

from usage_credits_lib import credits_state, fetch, money  # noqa: E402


def when(iso):
    """'resets Sun 11:59 PM' style suffix for an ISO timestamp."""
    if not iso:
        return ""
    try:
        stamp = datetime.fromisoformat(iso.replace("Z", "+00:00")).astimezone()
    except Exception:
        return ""
    delta = stamp - datetime.now(timezone.utc)
    hours = delta.total_seconds() / 3600
    if 0 < hours < 24:
        return "resets in {}h {}m".format(int(hours), int((hours % 1) * 60))
    return "resets {}".format(stamp.strftime("%a %-d %b, %-I:%M %p"))


def pct(value):
    """The API reports these already scaled 0-100."""
    return "{}%".format(round(value)) if isinstance(value, (int, float)) else "-"


def collect(data):
    rows = []
    for key, label in (("five_hour", "5-hour limit"),
                       ("seven_day", "Weekly · all models"),
                       ("seven_day_opus", "Weekly · Opus"),
                       ("seven_day_sonnet", "Weekly · Sonnet"),
                       ("cinder_cove", "Claude Code and Cowork credit")):
        window = data.get(key)
        if isinstance(window, dict):
            rows.append((label, pct(window.get("utilization")), when(window.get("resets_at"))))

    for entry in data.get("limits") or []:
        if entry.get("kind") != "weekly_scoped":
            continue
        scope = entry.get("scope") or {}
        model = (scope.get("model") or {}).get("display_name")
        if model:
            rows.append(("Weekly · " + model, pct(entry.get("percent")),
                         when(entry.get("resets_at"))))

    state = credits_state(data)
    if state:
        rows.append(("Usage credits", credits_value(state), ""))
    return rows


def credits_value(state):
    currency = state.get("currency")
    if state["kind"] == "off":
        reason = state.get("reason")
        return "off" + (" ({})".format(reason) if reason else "")
    if state["kind"] == "uncapped":
        return "{} used · no monthly cap".format(money(state["used"], currency))
    return "{} of {} ({}%)".format(money(state["used"], currency),
                                   money(state["limit"], currency), state["pct"])


def main():
    raw = "--raw" in sys.argv
    try:
        data = fetch()
    except Exception as exc:
        print("Could not read usage: {}".format(exc))
        return 1

    if raw:
        print(json.dumps(data, indent=2, sort_keys=True))
        return 0

    rows = collect(data)
    if not rows:
        print("No usage data in the response. Run with --raw to inspect it.")
        return 1

    label_width = max(len(label) for label, _, _ in rows)
    value_width = max(len(value) for _, value, _ in rows)
    for label, value, suffix in rows:
        line = "  {}  {}".format(label.ljust(label_width), value.rjust(value_width))
        print(line + ("   " + suffix if suffix else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())

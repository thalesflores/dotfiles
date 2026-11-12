#!/usr/bin/env python3
"""Print a statusline segment: "5-hour 39% ↻13:50 · weekly 32% ↻Sun 23:00".

Two sources, preferring the live one:

  * Claude Code hands the statusline `rate_limits` on stdin -- the 5-hour and weekly-all
    windows, current as of this session's last API response and free to read.
  * The model-scoped weekly limit exists only in /api/oauth/usage, so that row comes from
    the cached payload, refreshed out of band by usage_cache.

Rows whose reset time has passed are dropped, so a cache stuck on a failing refresh shows
nothing rather than a figure from a spent window.

Prints nothing at all on failure, so statusline.sh can splice it in unconditionally.
"""

import json
import sys
from datetime import datetime, timezone

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from render import colourise  # noqa: E402
from usage_cache import payload, refresh_if_stale  # noqa: E402

ORDER = {"session": 0, "weekly_all": 1, "weekly_scoped": 2}


def reset_at(when):
    """Reset time in the user's local zone -- "13:50" if it lands today, else "Sun 22:59".

    Accepts either an ISO string (the API) or Unix epoch seconds (stdin `rate_limits`).
    The API reports UTC; a bare UTC clock time would read an hour wrong in BST, so convert.
    Returns None when absent or unparseable, and the caller drops the stamp.
    """
    if when is None or when == "":
        return None
    try:
        if isinstance(when, (int, float)):
            at = datetime.fromtimestamp(when).astimezone()
        else:
            at = datetime.fromisoformat(when.replace("Z", "+00:00")).astimezone()
    except Exception:
        return None
    if at.date() == datetime.now().astimezone().date():
        return at.strftime("%H:%M")
    return at.strftime("%a %H:%M")


def rows_from_stdin(data):
    """The 5-hour and weekly-all rows, straight off the statusline payload. Live, no network."""
    rate_limits = (data or {}).get("rate_limits") or {}
    rows = []
    for key, kind in (("five_hour", "session"), ("seven_day", "weekly_all")):
        window = rate_limits.get(key) or {}
        pct = window.get("used_percentage")
        if isinstance(pct, (int, float)):
            rows.append({"kind": kind, "percent": pct, "resets_at": window.get("resets_at")})
    return rows


def expired(limit):
    """True when the row's window has already reset, so its percentage is meaningless.

    A refresh that keeps failing restamps the cache entry's `at`, so an arbitrarily old
    payload reads as fresh. The row's own reset time is the only honest freshness signal.
    """
    when = limit.get("resets_at")
    if when is None or when == "":
        return False
    try:
        if isinstance(when, (int, float)):
            at = datetime.fromtimestamp(when, timezone.utc)
        else:
            at = datetime.fromisoformat(str(when).replace("Z", "+00:00"))
    except Exception:
        return False
    if at.tzinfo is None:
        at = at.replace(tzinfo=timezone.utc)
    return at < datetime.now(timezone.utc)


def rows(stdin_data, api_data):
    """Live stdin rows first, then anything only the API knows about.

    stdin `rate_limits` comes from this session's last API response, so it moves with the
    conversation. The cached API payload is machine-wide but only as good as its last
    successful fetch, so it fills in the model-scoped row rather than overriding live data.
    Rows whose window has already reset are dropped either way.
    """
    out = [r for r in rows_from_stdin(stdin_data) if not expired(r)]
    seen = {r["kind"] for r in out}
    for limit in (api_data or {}).get("limits") or []:
        if limit.get("kind") not in seen and not expired(limit):
            out.append(limit)
    out.sort(key=lambda r: ORDER.get(r.get("kind"), 9))
    return out


def label(limit):
    """Short display label for a limit row, or None if we don't render this kind."""
    kind = limit.get("kind")
    if kind == "session":
        return "5-hour"
    if kind == "weekly_all":
        return "weekly"
    if kind == "weekly_scoped":
        model = ((limit.get("scope") or {}).get("model") or {}).get("display_name")
        return model or None
    return None


def format_segment(stdin_data, api_data):
    parts = []
    for limit in rows(stdin_data, api_data):
        name = label(limit)
        pct = limit.get("percent")
        if not name or not isinstance(pct, (int, float)):
            continue
        shown = round(pct)  # colour off the displayed figure, so 100% always reads red
        item = "{} {}%".format(name, shown)
        resets = reset_at(limit.get("resets_at"))
        if resets:
            item += " ↻" + resets
        parts.append(colourise(item, shown))
    return " · ".join(parts)


def main():
    try:
        stdin_data = json.load(sys.stdin)
    except Exception:
        stdin_data = {}
    try:
        refresh_if_stale()
        api_data = payload()
    except Exception:
        api_data = None
    sys.stdout.write(format_segment(stdin_data, api_data))


if __name__ == "__main__":
    main()

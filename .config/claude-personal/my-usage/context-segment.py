#!/usr/bin/env python3
"""Print a statusline segment for context window use: "context ██░░░ 34%".

Reads the statusline JSON on stdin (it carries context_window.used_percentage already
calculated). Prints nothing when the figure is absent -- it is null before the first API
call of a session and again after /compact, and a bare "0%" there would be misleading.
"""

import json
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from render import bar, colourise  # noqa: E402


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    pct = (data.get("context_window") or {}).get("used_percentage")
    if not isinstance(pct, (int, float)):
        return
    shown = round(pct)
    sys.stdout.write(colourise("context {} {}%".format(bar(pct), shown), shown))


if __name__ == "__main__":
    main()

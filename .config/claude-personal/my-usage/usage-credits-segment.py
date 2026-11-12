#!/usr/bin/env python3
"""Print a compact statusline segment: "credits $209.83/$370.00 (57%)".

Prints nothing at all on any failure, so statusline.sh can splice it in unconditionally.
Reads through usage_cache, which serves the cached payload immediately and refreshes it in
the background -- the statusline never waits on the network.
"""

import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from usage_cache import payload, refresh_if_stale  # noqa: E402
from usage_credits_lib import credits_state, money  # noqa: E402


def format_segment(state):
    currency = state.get("currency")
    if state["kind"] == "off":
        return "credits off"
    if state["kind"] == "uncapped":
        return "credits {}".format(money(state["used"], currency))
    return "credits {}/{} ({}%)".format(money(state["used"], currency),
                                        money(state["limit"], currency), state["pct"])


def main():
    try:
        refresh_if_stale()
        state = credits_state(payload())
    except Exception:
        return
    if state:
        sys.stdout.write(format_segment(state))


if __name__ == "__main__":
    main()

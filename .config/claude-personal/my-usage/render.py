"""Shared look for the statusline segments -- meters and warning colours.

Kept in one place so the context bar and the limit bars stay visually identical.
"""

BAR_WIDTH = 5    # cells per bar -- several bars share the statusline, so keep them narrow
BAR_FULL = "█"
BAR_EMPTY = "░"

# Three always-on bands: green below AMBER_AT, amber below RED_AT, red from there up.
# Every bar is coloured, so a glance at hue alone reads the state without parsing digits.
AMBER_AT = 50    # percent at which a bar stops being comfortable
RED_AT = 80      # percent at which it is running out
GREEN = "\033[38;5;71m"
AMBER = "\033[38;5;214m"
RED = "\033[38;5;196m"
RESET = "\033[0m"


def bar(pct):
    """Fixed-width meter. Any non-zero usage lights at least one cell, so 1% isn't rendered as 0."""
    pct = max(0.0, min(100.0, float(pct)))
    filled = int(pct / 100 * BAR_WIDTH + 0.5)  # half-up; round() would send 50% to 2/5
    if pct > 0:
        filled = max(1, filled)
    return BAR_FULL * filled + BAR_EMPTY * (BAR_WIDTH - filled)


def colour_for(pct):
    """The escape code for a percentage, by band."""
    if pct >= RED_AT:
        return RED
    if pct >= AMBER_AT:
        return AMBER
    return GREEN


def colourise(text, pct):
    """Green under 50%, amber to 80%, red from 80% up."""
    return colour_for(pct) + text + RESET

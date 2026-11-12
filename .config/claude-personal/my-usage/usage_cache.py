"""Non-blocking access to the cached usage payload.

The statusline re-renders on every conversation event, so a render must never wait on the
network. These helpers hand back whatever is cached -- however old -- and, when it has gone
stale, start a *detached* refresh that a later render picks up. A lock file stops several
Claude Code sessions from all refreshing at the same moment.

Net effect: one request per TTL per machine, no matter how often the statusline redraws.
"""

import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from usage_credits_lib import CACHE  # noqa: E402

TTL = 60           # refresh a payload older than this
MAX_AGE = 900      # past this, a payload is not reported at all
LOCK = CACHE + ".lock"
LOCK_TIMEOUT = 30  # a lock older than this is treated as abandoned by a dead refresher


def _entry():
    try:
        with open(CACHE) as fh:
            return json.load(fh)
    except Exception:
        return {}


def payload():
    """The cached payload. None when it is missing or too old to stand behind.

    A refresh that keeps failing must not leave the last good payload on display forever --
    an unrefreshable figure is indistinguishable from a current one, so past MAX_AGE we
    report nothing instead.
    """
    entry = _entry()
    if time.time() - entry.get("at", 0) > MAX_AGE:
        return None
    return entry.get("data")


def _take_lock():
    """True if this process now owns the refresh lock."""
    try:
        if time.time() - os.path.getmtime(LOCK) > LOCK_TIMEOUT:
            os.unlink(LOCK)  # the previous refresher died without cleaning up
    except OSError:
        pass
    try:
        os.close(os.open(LOCK, os.O_CREAT | os.O_EXCL | os.O_WRONLY))
        return True
    except OSError:
        return False


def refresh_if_stale():
    """Kick off a background refresh when the cache is older than TTL. Never blocks."""
    entry = _entry()
    last = max(entry.get("at", 0), entry.get("failed_at", 0))
    if time.time() - last < TTL:
        return
    if not _take_lock():
        return
    try:
        subprocess.Popen(
            [sys.executable, os.path.join(HERE, "refresh.py")],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True,
        )
    except Exception:
        try:
            os.unlink(LOCK)
        except OSError:
            pass

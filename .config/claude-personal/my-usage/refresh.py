#!/usr/bin/env python3
"""Refetch the usage payload into the cache, then release the lock.

Run detached by usage_cache.refresh_if_stale() so no statusline render waits on the network.
"""

import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from usage_cache import LOCK, _entry  # noqa: E402
from usage_credits_lib import fetch, write_cache  # noqa: E402

try:
    fetch(cache_ttl=0)  # writes the cache itself on success
except Exception:
    # Record the failure so a dead network backs off for a TTL, but leave `at` alone: it
    # marks the last *successful* fetch, which is what tells callers the payload has aged out.
    entry = _entry()
    entry["failed_at"] = time.time()
    write_cache(entry, stamp=False)
finally:
    try:
        os.unlink(LOCK)
    except OSError:
        pass

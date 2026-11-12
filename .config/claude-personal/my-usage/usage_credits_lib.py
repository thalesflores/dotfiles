"""Shared access to Claude's subscription usage endpoint.

Claude Code already fetches GET /api/oauth/usage to render /usage, but the panel drops the
"Usage credits" row unless subscriptionType is "pro" or "max", so it never appears on Team
plans. These helpers call the same endpoint and format the payload ourselves.

Used by usage-credits-segment.py (statusline) and usage-credits-report.py (/my-usage-credits).
"""

import json
import os
import re
import subprocess
import time
import urllib.request

ENDPOINT = "https://api.anthropic.com/api/oauth/usage"
CACHE = os.path.expanduser("~/.claude/.usage-credits-cache.json")
NET_TIMEOUT = 5

CURRENCY_SYMBOLS = {
    "USD": "$", "EUR": "€", "GBP": "£", "JPY": "¥",
    "BRL": "R$", "CAD": "CA$", "AUD": "A$", "NZD": "NZ$", "SGD": "S$",
}
ZERO_DECIMAL = {"JPY", "KRW", "VND"}


KEYCHAIN_SERVICE = "Claude Code-credentials"


def _keychain_services():
    """Every "Claude Code-credentials*" service in the keychain, freshest last.

    Claude Code keeps a per-profile item alongside the bare one (e.g.
    "Claude Code-credentials-ed1c2312"), and only one of them holds the token it is
    currently refreshing. Reading the bare name alone can pick up a token that expired
    months ago -- which the usage endpoint answers with 429, not 401.
    """
    found = {KEYCHAIN_SERVICE}
    try:
        proc = subprocess.run(["security", "dump-keychain"],
                              capture_output=True, text=True, timeout=10)
        for match in re.finditer(r'"svce"<blob>="(' + re.escape(KEYCHAIN_SERVICE) + r'[^"]*)"',
                                 proc.stdout):
            found.add(match.group(1))
    except Exception:
        pass
    return sorted(found)


def _oauth_entries():
    """The claudeAiOauth blobs available locally, in no particular order."""
    entries = []
    path = os.path.expanduser("~/.claude/.credentials.json")
    if os.path.exists(path):
        try:
            with open(path) as fh:
                entries.append(json.load(fh).get("claudeAiOauth") or {})
        except Exception:
            pass

    account = os.environ.get("USER", "")
    for service in _keychain_services():
        try:
            proc = subprocess.run(
                ["security", "find-generic-password", "-a", account, "-w", "-s", service],
                capture_output=True, text=True, timeout=5,
            )
            if proc.returncode == 0 and proc.stdout.strip():
                entries.append(json.loads(proc.stdout).get("claudeAiOauth") or {})
        except Exception:
            continue
    return entries


def read_token():
    """The freshest unexpired OAuth access token, from the credentials file or keychain.

    Falls back to the latest-expiring token when every candidate looks expired, so a
    skewed clock or a missing expiresAt still gets a request out.
    """
    candidates = [e for e in _oauth_entries() if e.get("accessToken")]
    if not candidates:
        return None
    now_ms = time.time() * 1000
    unexpired = [e for e in candidates if (e.get("expiresAt") or 0) > now_ms]
    pick = max(unexpired or candidates, key=lambda e: e.get("expiresAt") or 0)
    return pick.get("accessToken")


def fetch(cache_ttl=0):
    """Usage payload. With cache_ttl > 0, reuse a recent cached response instead of refetching."""
    if cache_ttl > 0:
        try:
            with open(CACHE) as fh:
                entry = json.load(fh)
            # Ignore failure markers here; only a cached payload counts as a hit.
            if entry.get("data") is not None and time.time() - entry.get("at", 0) < cache_ttl:
                return entry["data"]
        except Exception:
            pass

    token = read_token()
    if not token:
        raise RuntimeError(
            "no OAuth token found -- expected ~/.claude/.credentials.json or keychain item "
            "'Claude Code-credentials'. Are you logged in with /login (not an API key)?"
        )

    req = urllib.request.Request(ENDPOINT, headers={
        "Authorization": "Bearer " + token,
        "anthropic-beta": "oauth-2025-04-20",
        "Content-Type": "application/json",
    })
    with urllib.request.urlopen(req, timeout=NET_TIMEOUT) as resp:
        data = json.load(resp)

    write_cache({"data": data})
    return data


def write_cache(entry, stamp=True):
    """Persist the cache entry. stamp=False keeps `at` as the last *successful* fetch time."""
    if stamp:
        entry["at"] = time.time()
    tmp = CACHE + ".tmp"
    try:
        with open(tmp, "w") as fh:
            json.dump(entry, fh)
        os.replace(tmp, CACHE)
    except Exception:
        pass


def money(minor_units, currency):
    """The API reports credits in minor units -- 20983 is $209.83."""
    code = (currency or "USD").upper()
    symbol = CURRENCY_SYMBOLS.get(code, code + " ")
    if code in ZERO_DECIMAL:
        return "{}{:,}".format(symbol, round(minor_units))
    return "{}{:,.2f}".format(symbol, minor_units / 100)


def credits_state(data):
    """Structured credits state, or None when the payload carries no credits data.

    Returns one of:
      {"kind": "off",      "reason": str|None}
      {"kind": "uncapped", "used": minor, "currency": str|None}
      {"kind": "capped",   "used": minor, "limit": minor, "pct": int, "currency": str|None}

    Callers format it themselves -- the statusline and the report want different shapes.
    """
    extra = (data or {}).get("extra_usage")
    if not extra:
        return None
    if not extra.get("is_enabled"):
        return {"kind": "off", "reason": extra.get("disabled_reason")}

    used, limit = extra.get("used_credits"), extra.get("monthly_limit")
    currency = extra.get("currency")
    if not isinstance(used, (int, float)):
        return None
    if limit is None:
        return {"kind": "uncapped", "used": used, "currency": currency}
    return {"kind": "capped", "used": used, "limit": limit, "currency": currency,
            "pct": round(100 * used / limit) if limit else 0}

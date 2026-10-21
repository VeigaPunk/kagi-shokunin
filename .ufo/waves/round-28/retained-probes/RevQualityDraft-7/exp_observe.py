#!/usr/bin/env python3
"""Observe-path probes for round-28 C1 (sandbox only).

Calls the BASE release-clock module directly with a stub opener so no network
is touched: a python.org-shaped RSS body whose newest stable item is titled
"Python 3.15.01" (F3) and one with a 4301-digit patch component (F4).
"""
import importlib.util
import json
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base"
spec = importlib.util.spec_from_file_location("release_clock_base",
                                              BASE / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

RSS = """<?xml version="1.0"?>
<rss version="2.0"><channel>
<item><title>Python {ver}</title><link>https://www.python.org/downloads/release/python-{ver}/</link></item>
<item><title>Python 3.15.0</title><link>https://www.python.org/downloads/release/python-3150/</link></item>
<item><title>Python 3.16.0a1</title><link>https://www.python.org/downloads/release/python-3160a1/</link></item>
</channel></rss>
"""


class StubOpener:
    def __init__(self, body):
        self.body = body

    def open(self, request, timeout=None):
        class R:
            def __init__(self, data):
                self._data = data

            def read(self, limit=-1):
                return self._data

            def close(self):
                pass

            def getcode(self):
                return 200

            def __enter__(self):
                return self

            def __exit__(self, *exc_info):
                return False

        return R(self.body)

    def close(self):
        pass


def probe(label, version_text):
    body = RSS.format(ver=version_text).encode("utf-8")
    print("=== %s" % label)
    try:
        parsed = rc.parse_latest_version(body)
        print("    parse_latest_version -> %r" % parsed)
    except Exception as exc:  # noqa: BLE001
        print("    parse_latest_version raised %s: %s"
              % (exc.__class__.__name__, str(exc)[:120]))
    values = {
        "id": "S040", "clock": "feed",
        "feed_url": "https://www.python.org/downloads/feed.rss",
        "anchored_version": "3.15.1", "observed_version": "3.15.1",
    }
    receipt = rc.observe_one(values, values, normalizer=None,
                             opener=StubOpener(body), resolver=None,
                             capture=None, floor="3.15.1")
    print("    observe_one receipt: %s" % json.dumps(
        {k: receipt.get(k) for k in ("parsed_version", "verdict", "error")},
        default=str))
    # the table-side comparison the clock would then make
    print("    numeric_version(anchored)=%r numeric_version(observed)=%r"
          % (rc.numeric_version("3.15.1"), rc.numeric_version(receipt.get("parsed_version") or "")))


def main():
    probe("F3 observe leading zero (title Python 3.15.01)", "3.15.01")
    probe("F4 observe oversize (4301-digit patch component)", "3.15." + "1" * 4301)
    print("=== table-side int() bound probe")
    try:
        rc.numeric_version("3.15." + "1" * 4301)
    except Exception as exc:  # noqa: BLE001
        print("    numeric_version raised %s: %s"
              % (exc.__class__.__name__, str(exc)[:120]))
    return 0


if __name__ == "__main__":
    sys.exit(main())

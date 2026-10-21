#!/usr/bin/env python3
"""Probe the round-28 C1 observe-path fixtures (F3/F4) against BASE code.

Imports the BASE corpus/release-clock.py as a module and calls observe_one with
an injected opener that returns a synthetic python.org-style Atom feed, so no
network is touched. Read-only against the BASE tree in this sandbox.
"""
import importlib.util
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base"
spec = importlib.util.spec_from_file_location("rc_base", BASE / "corpus/release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)


def feed_body(title):
    return ("<?xml version='1.0' encoding='UTF-8'?>\n"
            "<feed xmlns='http://www.w3.org/2005/Atom'>"
            "<entry><title>%s</title>"
            "<link href='https://www.python.org/downloads/release/3.15.1/'/>"
            "<updated>2026-10-21T09:59:50Z</updated></entry>"
            "</feed>" % title).encode("utf-8")


class FakeResponse:
    def __init__(self, body):
        self.body = body

    def getcode(self):
        return 200

    def read(self, n=-1):
        return self.body

    def __enter__(self):
        return self

    def __exit__(self, *a):
        return False


class FakeOpener:
    def __init__(self, body):
        self.body = body

    def open(self, request, timeout=None):
        return FakeResponse(self.body)


def opener_for(body):
    return FakeOpener(body)


def run(label, title, anchored="3.15.1", observed="3.15.1", floor="3.15.1"):
    source = {"id": "S040", "url": "https://www.python.org/downloads/feed.rss",
              "kind": "docs", "recheck": "on-release", "anchor": "Python 3.15.1"}
    values = {"id": "S040", "clock": "feed",
              "feed_url": "https://www.python.org/downloads/feed.rss",
              "anchored_version": anchored, "observed_version": observed,
              "observed_at": "2026-10-21", "verdict": "not-fired", "note": "-"}
    receipt = rc.observe_one(source, values, None, opener=opener_for(feed_body(title)),
                              floor=floor)
    print("=== %s ===" % label)
    print("  title:", title[:40], "len", len(title))
    print("  verdict=%r parsed_version=%r error=%r" %
          (receipt.get("verdict"), receipt.get("parsed_version"), receipt.get("error")))


def main():
    run("F3 observe leading zero", "Python 3.15.01")
    run("F4 observe oversize component", "Python 3.15." + "1" * 4301)
    run("control observe canonical", "Python 3.15.1")


if __name__ == "__main__":
    main()

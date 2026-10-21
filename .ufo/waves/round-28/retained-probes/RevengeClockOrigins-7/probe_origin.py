#!/usr/bin/env python3
"""Sandbox-only probe of the BASE release-clock (no network, no lane writes).

Usage: python3 -I -B probe_origin.py <sandbox BASE tree>
Stubs request_body in-process; every feed body is an in-memory RSS string.
"""
import importlib.util
import json
import sys
from pathlib import Path

base = Path(sys.argv[1]).resolve()
spec = importlib.util.spec_from_file_location("rc_base", base / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

print("== function level (BASE helpers)")
for a, b in (("3.15.01", "3.15.1"), ("3.15.1", "3.15.1"), ("v3.15.1", "3.15.1")):
    print("numeric_version(%r)=%r numeric_version(%r)=%r numeric_equal=%r"
          % (a, rc.numeric_version(a), b, rc.numeric_version(b),
             rc.numeric_version(a) == rc.numeric_version(b)))
    print("norm_version(%r)=%r norm_version(%r)=%r string_unequal=%r"
          % (a, rc.norm_version(a), b, rc.norm_version(b),
             rc.norm_version(a) != rc.norm_version(b)))
print("is_regression('3.15.1','3.15.01')=%r" % rc.is_regression("3.15.1", "3.15.01"))
try:
    rc.numeric_version("3.15." + "1" * 4301)
    print("oversize numeric_version: no error")
except ValueError as exc:
    print("oversize numeric_version raised ValueError: %s" % exc)


def rss(*titles):
    items = "".join("<item><title>%s</title></item>" % t for t in titles)
    return ('<?xml version="1.0"?><rss version="2.0"><channel>%s</channel></rss>' % items).encode()


def fake_request(body):
    def request_body(url, opener=None, resolver=None):
        return 200, body, None
    return request_body


def observe(anchor, observed, body):
    rc.request_body = fake_request(body)
    values = {"id": "S040", "clock": "feed",
              "feed_url": "https://www.python.org/downloads/feed.rss",
              "anchored_version": anchor, "observed_version": observed,
              "verdict": "not-fired"}
    receipt = rc.observe_one({"url": "https://www.python.org/downloads/", "teaches": "x"},
                             values, None, opener=None, resolver=None, capture=None, floor=None)
    return {k: receipt.get(k) for k in ("parsed_version", "verdict", "error")}


print("== observe level (stubbed feed, anchor 3.15.1)")
print("control 3.15.1 only        ->", observe("3.15.1", "3.15.1", rss("Python 3.15.1")))
print("control 3.15.2 only        ->", observe("3.15.1", "3.15.1", rss("Python 3.15.2")))
print("F3 3.15.01 only            ->", observe("3.15.1", "3.15.1", rss("Python 3.15.01")))
print("order A [3.15.01, 3.15.1]  ->", observe("3.15.1", "3.15.1", rss("Python 3.15.01", "Python 3.15.1")))
print("order B [3.15.1, 3.15.01]  ->", observe("3.15.1", "3.15.1", rss("Python 3.15.1", "Python 3.15.01")))
print("F4 oversize patch          ->", json.dumps(observe("3.15.1", "3.15.1",
      rss("Python 3.15.%s" % ("1" * 4301)))))

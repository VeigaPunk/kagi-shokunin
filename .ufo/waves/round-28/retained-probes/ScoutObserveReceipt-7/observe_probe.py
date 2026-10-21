#!/usr/bin/env python3
"""Probe BASE --observe with a stubbed network (sandbox only, read-only target).

usage: observe_probe.py <tree> <label>
Serves every bound URL from the tree's own declared values, except the python.org
feed, whose newest stable item is the label verbatim (e.g. 'Python 3.15.01').
"""
import importlib.util
import json
import sys
from pathlib import Path

tree = Path(sys.argv[1]).resolve()
label = sys.argv[2]
spec = importlib.util.spec_from_file_location("rc", tree / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

sources = rc.parse_sources(tree)
rows = rc.parse_bindings(tree)
captures = rc.parse_captures(tree)

GITHUB = {
    "https://github.com/getsops/sops/releases.atom": ["v3.13.3"],
    "https://github.com/hashicorp/vault/releases.atom": ["v2.2.0"],
    "https://github.com/openbao/openbao/releases.atom": ["v2.7.1"],
}
PY = "https://www.python.org/downloads/feed.rss"
CURL = "https://curl.se/info"


def atom(titles):
    entries = "".join("<entry><title>%s</title></entry>" % t for t in titles)
    return ('<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom">%s</feed>' % entries).encode()


def body_for(url):
    if url == PY:
        return atom(["Python 3.14.9", "Python 3.16.0a1", label])
    if url in GITHUB:
        return atom(GITHUB[url])
    if url == CURL:
        return b"Version: 8.23.0\nDate: 2026-10-14\n"
    quotes = [q for q, _ in captures.values() if q and q != "-"]
    quote = next((q for q in quotes if q), "")
    return ("<html><body><p>%s</p></body></html>" % quote).encode()


def fake_request_body(url, opener=None, resolver=None):
    return 200, body_for(url), None


rc.request_body = fake_request_body
import hashlib
out = tree / ("observe-%s.json" % hashlib.sha256(label.encode()).hexdigest()[:12])
if out.exists():
    out.unlink()
code = rc.main(["--root", str(tree), "--observe", str(out)])
doc = json.load(open(out))
by = {r["id"]: r for r in doc["observations"]}
focus = {k: (by[k].get("parsed_version"), by[k].get("verdict"), by[k].get("error"))
         for k in ("S027", "S028", "S040", "S041")}
print("PROBE label=%r exit=%d focus=%s" % (label, code, focus))
print("PROBE receipt_size=%d observations=%d" % (len(open(out, "rb").read()), len(doc["observations"])))

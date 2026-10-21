#!/usr/bin/env python3
"""Stub the network for release-clock --observe so a fixture tree can be
observed offline. Production code is untouched: only module.request_body is
replaced in the loaded module namespace.

usage: drive_observe.py TREE PYTHON_FEED_BODY OUT.json
"""
import importlib.util
import json
import pathlib
import sys

tree = pathlib.Path(sys.argv[1]).resolve()
python_body = pathlib.Path(sys.argv[2]).read_bytes()
out = pathlib.Path(sys.argv[3]).resolve()

spec = importlib.util.spec_from_file_location("rc_under_test", tree / "corpus" / "release-clock.py")
rc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rc)

receipts = json.loads((tree / ".ufo" / "waves" / "round-26" / "observe-2.json").read_text())["observations"]
version_of = {r["id"]: r.get("parsed_version") for r in receipts}

sources = rc.parse_sources(tree)
rows = rc.parse_bindings(tree)
captures = rc.parse_captures(tree)

# body per feed url, from the retained receipt's recorded version
feed_version = {}
for row in rows:
    values = dict(zip(rc.HEADER, row["fields"]))
    if values["clock"] == "feed":
        feed_version.setdefault(values["feed_url"], version_of.get(row["id"]))

quote_of = {}
for row in rows:
    values = dict(zip(rc.HEADER, row["fields"]))
    if values["clock"] == "rendered-quote":
        quote, profile = captures.get(row["id"], ("", ""))
        quote_of[row["id"]] = quote


def rss(version):
    return ("<?xml version='1.0' encoding='utf-8'?>\n"
            "<rss version='2.0'><channel><title>stub</title>"
            "<item><title>v%s</title><link>https://example.test/releases/tag/v%s</link></item>"
            "</channel></rss>\n" % (version, version)).encode()


def text_feed(version):
    return ("Version: %s\n" % version).encode()


page_of = {}
for row in rows:
    values = dict(zip(rc.HEADER, row["fields"]))
    if values["clock"] == "rendered-quote":
        quote, profile = captures.get(row["id"], ("", ""))
        page = "<html><body><p>%s</p></body></html>" % quote
        page_of[sources[row["id"]]["url"]] = page.encode("utf-8")


def fake_request_body(url, opener=None, resolver=None):
    if url == "https://www.python.org/downloads/feed.rss":
        return 200, python_body, None
    if url in page_of:
        return 200, page_of[url], None
    if url in feed_version:
        version = feed_version[url]
        if version is None:
            return 200, b"", None
        if url == "https://curl.se/info":
            return 200, text_feed(version), None
        return 200, rss(version), None
    return 200, b"<html><body></body></html>", None


rc.request_body = fake_request_body

# rendered-quote rows need the declared quote to be present in the page
_orig = rc.observe_one


def observe_one(source, values, normalizer, opener=None, resolver=None, capture=None, floor=None):
    if values["clock"] == "rendered-quote":
        quote = quote_of.get(values["id"], "")
        capture = (quote, (capture or ("", ""))[1] or "raw-literal-v1")
    return _orig(source, values, normalizer, opener=opener, resolver=resolver,
                 capture=capture, floor=floor)


rc.observe_one = observe_one

status = rc.main(["--observe", str(out), "--root", str(tree)])
print("DRIVER_EXIT=%d" % status)
sys.exit(status)

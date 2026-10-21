#!/usr/bin/env python3
"""Independent falsification harness for the round-28 C1 'Atom newest oversized
title' carrier (F4-shaped).  Does NOT reuse .ufo/waves/round-28/tools/*.

Usage: harness.py <tree-dir> <out.json>

The harness runs the tree's own corpus/release-clock.py:
  1. unit-level: parse_latest_version() on an Atom feed whose newest stable
     entry title carries a 4301-digit patch component;
  2. unit-level: observe_one() over the same feed (module transport stubbed
     exactly like the script's own selftest does) -> inspect the receipt;
  3. end-to-end: release-clock.py main(["--root", root, "--observe", out]) on a
     fixture root narrowed to the S040 row + its feed source row S039, with the
     transport stubbed to serve the local fixture feed bytes.

No network is used or attempted: request_body is replaced.
"""
import importlib.util
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
OUT = Path(sys.argv[2]).resolve()
OVERSIZE = "1" * 4301
FIXTURE_ROW = "S040"
FEED_SOURCE = "S039"


def load_module(tree):
    spec = importlib.util.spec_from_file_location(
        "release_clock_under_test", Path(tree) / "corpus" / "release-clock.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def atom_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, index) for index, title in enumerate(titles))
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>Python releases (fixture)</title>\n"
        "  <id>https://www.python.org/downloads/feed.rss</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n"
        + entries + "</feed>\n").encode("utf-8")


def unit_parse(module, bodies):
    out = {}
    for label, body in bodies.items():
        try:
            value = module.parse_latest_version(body)
        except BaseException as exc:  # noqa: BLE001 - we classify the type
            out[label] = {"raised": exc.__class__.__name__,
                          "message": str(exc)[:200],
                          "is_traceback_text": False}
        else:
            out[label] = {"returned": value}
    return out


def unit_observe(module, feed_bytes, feed_url, anchored, observed):
    class StaticOpener:
        def open(self, request, timeout=None):
            class Response:
                def read(self, *args):
                    return feed_bytes

                def getcode(self):
                    return 200

                def info(self):
                    return {}

                def close(self):
                    pass
            return Response()

    def fake_public_resolver(host, port, *args, **kwargs):
        return "93.184.216.34"

    receipt = module.observe_one(
        {"url": "https://docs.python.org/3/library/re.html", "teaches": "test"},
        {"id": FIXTURE_ROW, "clock": "feed", "feed_url": feed_url,
         "anchored_version": anchored, "observed_version": observed},
        None, opener=StaticOpener(), resolver=fake_public_resolver)
    return receipt


def narrow_sources(text, keep_ids):
    kept = []
    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("|"):
            cells = [c.strip() for c in stripped[1:].split("|")]
            if cells and cells[0].startswith("S") and cells[0][1:].isdigit() \
                    and cells[0] not in keep_ids:
                continue
        kept.append(line)
    return "".join(kept)


def narrow_table(text, keep_ids):
    kept = []
    for line in text.splitlines(keepends=True):
        fields = line.rstrip("\n").split("\t")
        if fields and fields[0] != "id" and fields[0] not in keep_ids:
            continue
        kept.append(line)
    return "".join(kept)


def end_to_end(module, tree, feed_bytes, feed_url, observed_at):
    temp = Path(tempfile.mkdtemp(prefix="fatomhuge-"))
    try:
        root = temp / "fixture-root"
        (root / "corpus").mkdir(parents=True)
        for rel in ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py"):
            shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
        (root / "corpus" / "SOURCES.md").write_text(
            narrow_sources((tree / "corpus" / "SOURCES.md").read_text(encoding="utf-8"),
                           {FIXTURE_ROW, FEED_SOURCE}), encoding="utf-8")
        (root / "corpus" / "release-clocks.tsv").write_text(
            narrow_table((tree / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8"),
                         {FIXTURE_ROW}), encoding="utf-8")
        feed_file = temp / "feed.atom"
        feed_file.write_bytes(feed_bytes)
        out_receipt = temp / "observe-out.json"

        def fixture_request_body(url, opener=None, resolver=None):
            if url == feed_url:
                return 200, feed_bytes, None
            return None, None, "harness: unexpected URL fetch %s" % url

        module.request_body = fixture_request_body
        module.utc_timestamp = lambda: observed_at + "T00:00:00Z"
        exit_code = None
        stdout = stderr = ""
        try:
            exit_code = module.main(["--root", str(root), "--observe", str(out_receipt)])
        except BaseException as exc:  # noqa: BLE001
            import traceback
            stdout = "UNCAUGHT %s: %s\n%s" % (
                exc.__class__.__name__, exc, traceback.format_exc())
        receipt = None
        if out_receipt.exists():
            receipt = json.loads(out_receipt.read_text(encoding="utf-8"))
        return {
            "exit": exit_code,
            "stdout": stdout,
            "stderr": stderr,
            "receipt": receipt,
        }
    finally:
        shutil.rmtree(temp, ignore_errors=True)


def rss_feed(titles):
    items = "".join(
        "  <item><title>%s</title>"
        "<link>https://www.python.org/downloads/release/fixture-%d/</link>"
        "<pubDate>Wed, 21 Oct 2026 09:59:50 +0000</pubDate></item>\n"
        % (title, index) for index, title in enumerate(titles))
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<rss version="2.0"><channel><title>Python releases</title>'
        "<link>https://www.python.org/downloads/</link>"
        "<description>fixture</description>" + items + "</channel></rss>\n"
    ).encode("utf-8")


def link_href_feed(titles):
    entries = "".join(
        "  <entry>\n    <title>Release</title>\n"
        '    <link href="https://github.com/x/y/releases/tag/v%s"/>\n'
        "    <id>https://example.test/%d</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (title, index) for index, title in enumerate(titles))
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<feed xmlns="http://www.w3.org/2005/Atom">\n'
        "  <title>releases</title><id>https://example.test/feed</id>\n"
        "  <updated>2026-10-21T00:00:00Z</updated>\n" + entries + "</feed>\n"
    ).encode("utf-8")


def main():
    module = load_module(TREE)
    feed_url = "https://www.python.org/downloads/feed.rss"
    observed_at = "2026-10-21"
    feed_bytes = atom_feed(["Python 3.15." + OVERSIZE, "Python 3.15.0"])
    result = {
        "tree": str(TREE),
        "python": sys.version.split()[0],
        "unit_parse": unit_parse(module, {
            "atom_newest_oversize": feed_bytes,
            "atom_only_oversize": atom_feed(["Python 3.15." + OVERSIZE]),
            "atom_older_oversize": atom_feed(
                ["Python 3.15.0", "Python 3.14." + OVERSIZE]),
            "atom_leading_zero_newest": atom_feed(["Python 3.15.01", "Python 3.15.0"]),
            "rss_newest_oversize": rss_feed(["Python 3.15." + OVERSIZE, "Python 3.15.0"]),
            "rss_only_oversize": rss_feed(["Python 3.15." + OVERSIZE]),
            "linkhref_newest_oversize": link_href_feed(
                ["3.15." + OVERSIZE, "3.15.0"]),
            "atom_oversize_below_canonical_newer": atom_feed(
                ["Python 3.16.0", "Python 3.15." + OVERSIZE]),
            "text_oversize": ("Version: 3.15." + OVERSIZE + "\n").encode("utf-8"),
        }),
        "unit_observe": unit_observe(
            module, feed_bytes, feed_url, "3.15.1", "3.15.1"),
        "end_to_end": end_to_end(
            module, TREE, feed_bytes, feed_url, observed_at),
        "end_to_end_newer_canonical": end_to_end(
            module, TREE,
            atom_feed(["Python 3.16.0", "Python 3.15." + OVERSIZE]),
            feed_url, observed_at),
    }
    OUT.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n",
                   encoding="utf-8")
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""FObsZero offline --observe fixture: S040 table row edited to a
non-canonical observation token; sources narrowed to S040 + its feed source;
a local Atom feed carries the canonical newest stable.
Usage: observe_fixture.py <tree> <root> <observed_token>
"""
import os
import shutil
import sys
from pathlib import Path

CORPUS_INPUTS = ("SOURCES.md", "source-fetches.tsv", "rendered-text-v1.py")
ROW = "S040"


def atom(titles):
    entries = "".join(
        "  <entry>\n    <title>%s</title>\n"
        "    <id>https://www.python.org/downloads/release/fixture-%d/</id>\n"
        "    <updated>2026-10-21T00:00:00Z</updated>\n  </entry>\n"
        % (t, i) for i, t in enumerate(titles))
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            '<feed xmlns="http://www.w3.org/2005/Atom">\n'
            '  <title>Python releases (fixture)</title>\n'
            '  <id>https://www.python.org/downloads/feed.rss</id>\n'
            '  <updated>2026-10-21T00:00:00Z</updated>\n'
            + entries + "</feed>\n").encode("utf-8")


def main():
    tree = Path(sys.argv[1]).resolve()
    root = Path(sys.argv[2]).resolve()
    token = sys.argv[3]
    if root.exists():
        shutil.rmtree(root)
    (root / "corpus").mkdir(parents=True)
    for rel in CORPUS_INPUTS:
        shutil.copy2(tree / "corpus" / rel, root / "corpus" / rel)
    # narrow table to the S040 row only
    lines = (tree / "corpus" / "release-clocks.tsv").read_text(
        encoding="utf-8").splitlines(keepends=True)
    kept = []
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f and f[0] == ROW:
            f[5] = token
            kept.append("\t".join(f) + "\n")
        elif f and f[0] == "id":
            kept.append(line)
    (root / "corpus" / "release-clocks.tsv").write_text(
        "".join(kept), encoding="utf-8")
    # narrow sources to S040 + its feed source id
    src = (tree / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines(keepends=True)
    keep = {ROW}
    for line in lines:
        f = line.rstrip("\n").split("\t")
        if f and f[0] == ROW:
            keep.add(f[2])
    out = []
    for line in src:
        s = line.strip()
        if s.startswith("|"):
            cells = [c.strip() for c in s[1].split("|")]
            if cells and cells[0].startswith("S") and cells[0] not in keep:
                continue
        out.append(line)
    (root / "corpus" / "SOURCES.md").write_text("".join(out), encoding="utf-8")
    feed = root / "feed.atom"
    feed.write_bytes(atom(["Python 3.15.1"]))
    print(root)


if __name__ == "__main__":
    raise SystemExit(main())

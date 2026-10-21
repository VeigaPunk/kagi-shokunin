#!/usr/bin/env python3
"""Which registry cell names the version a derived release-clock row binds to."""
import re
import sys
from pathlib import Path

BASE = Path("/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/RevSourcesContract-7/base")
VER = re.compile(r"(?<![A-Za-z0-9.])v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9.])")


def rows(path):
    out = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) != 11 or not re.fullmatch(r"S[0-9]{3,}", cells[0]):
            continue
        out[cells[0]] = cells
    return out


src = rows(BASE / "corpus" / "SOURCES.md")
tsv = [l.split("\t") for l in (BASE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines()[1:]]
derived = [r for r in tsv if len(r) > 8 and r[8].startswith("derived:")]
print("derived rows: %d" % len(derived))
for r in derived:
    row_id, clock, feed_id, feed_url, anchored = r[0], r[1], r[2], r[3], r[4]
    cells = src.get(feed_id)
    if cells is None:
        print("%s feed=%s MISSING REGISTRY ROW" % (row_id, feed_id))
        continue
    anchor_cell = cells[5]
    teaches_cell = cells[6]
    scope_cell = cells[4]
    a = sorted(set(VER.findall(anchor_cell)))
    t = sorted(set(VER.findall(teaches_cell)))
    s = sorted(set(VER.findall(scope_cell)))
    named = [v for v in a if v == anchored.lstrip("v")]
    print("%-5s feed=%-5s anchored=%-8s anchor_cell_versions=%s exact_match=%s | teaches_versions=%s | scope_versions=%s"
          % (row_id, feed_id, anchored, a, bool(named), t, s))
print()
print("--- every X.Y.Z token in each feed row's anchor cell (S033-S037, S039) ---")
for sid in ("S033", "S034", "S035", "S036", "S037", "S039"):
    cells = src[sid]
    print("%s anchor=%r" % (sid, cells[5]))
    print("   tokens=%s" % sorted(set(VER.findall(cells[5]))))
print()
print("--- rows whose anchored_version is NOT named by the feed row's anchor cell ---")
bad = 0
for r in tsv:
    if len(r) < 9:
        continue
    row_id, feed_id, anchored = r[0], r[2], r[4]
    cells = src.get(feed_id)
    if not cells or anchored in ("-", ""):
        continue
    toks = set(VER.findall(cells[5]))
    if anchored.lstrip("v") not in toks:
        bad += 1
        print("%s anchored=%s feed=%s anchor_tokens=%s derived=%s" % (
            row_id, anchored, feed_id, sorted(toks), r[8].startswith("derived:")))
print("count=%d" % bad)

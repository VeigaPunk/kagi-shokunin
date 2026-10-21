#!/usr/bin/env python3
"""C2 population check: derived release-clock rows vs feed-row anchors."""
import csv, re, sys

BASE = sys.argv[1] if len(sys.argv) > 1 else "base"
ROOT = "/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/ScoutDerivedNotes-7/" + BASE

SOURCE_ID_RE = re.compile(r"S\d{3}")
sources = {}
src_lines = {}
for n, line in enumerate(open(ROOT + "/corpus/SOURCES.md", encoding="utf-8").read().splitlines(), 1):
    s = line.strip()
    if not s.startswith("|"):
        continue
    cells = s[1:].split("|")
    if cells and not cells[-1].strip():
        cells.pop()
    cells = [c.strip() for c in cells]
    if not cells or not SOURCE_ID_RE.fullmatch(cells[0]):
        continue
    if len(cells) != 11:
        print("PARSE ERROR line %d has %d cells" % (n, len(cells)))
        continue
    sources[cells[0]] = {"anchor": cells[5], "teaches": cells[6], "line": n}

rows = list(csv.DictReader(open(ROOT + "/corpus/release-clocks.tsv", encoding="utf-8"), delimiter="\t"))
print("row\tline\tfeed\tanchored\tnote_version\tnote_date\tfeed_anchor\town_anchor")
for n, r in enumerate(rows, 2):
    note = r["note"]
    if not note.startswith("derived:"):
        continue
    feed = r["feed_source_id"]
    fa = sources[feed]["anchor"]
    oa = sources[r["id"]]["anchor"]
    # candidate version from note: first v?X.Y.Z (or X.Y.x) token, and date YYYY-MM-DD
    vers = re.findall(r"v?(\d+\.\d+\.(?:\d+|[xX]))", note)
    dates = re.findall(r"(\d{4}-\d{2}-\d{2})", note)
    print("%s\t%d\t%s\t%s\t%s\t%s\t%s\t%s" % (
        r["id"], n, feed, r["anchored_version"],
        "|".join(vers) if vers else "-",
        "|".join(dates) if dates else "-",
        fa, oa))
print()
print("== feed rows ==")
for f in ("S033", "S034", "S035", "S037"):
    print(f, "line", sources[f]["line"], "anchor:", sources[f]["anchor"])

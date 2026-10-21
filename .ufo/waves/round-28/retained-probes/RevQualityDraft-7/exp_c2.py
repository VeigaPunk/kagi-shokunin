#!/usr/bin/env python3
"""QM28 population probe: derived rows vs their feed row's located anchor.

Reads the sandbox BASE tree only: corpus/SOURCES.md (anchor cell of every
registry row) and corpus/release-clocks.tsv (rows whose note starts with
"derived:").
"""
import re
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent / "base"
VERSION = re.compile(r"(?<![A-Za-z0-9.])v?([0-9]+\.[0-9]+(?:\.[0-9]+)*(?:[-+][0-9A-Za-z.-]+)?)(?![A-Za-z0-9.])",
                     re.IGNORECASE)
HEADER = ("id", "clock", "feed_source_id", "feed_url", "anchored_version",
          "observed_version", "observed_at", "verdict", "note")


def sources_anchor_cells():
    cells = {}
    for line in (BASE / "corpus" / "SOURCES.md").read_text(encoding="utf-8").splitlines():
        if not line.startswith("| S"):
            continue
        fields = [f.strip() for f in line.strip().strip("|").split("|")]
        if len(fields) < 11:
            continue
        cells[fields[0]] = {"anchor": fields[5], "teaches": fields[6],
                            "recheck": fields[9]}
    return cells


def rows():
    lines = (BASE / "corpus" / "release-clocks.tsv").read_text(encoding="utf-8").splitlines()
    out = []
    for line in lines[1:]:
        if not line.strip():
            continue
        values = dict(zip(HEADER, [f.strip() for f in line.split("\t")]))
        out.append(values)
    return out


def versions(text):
    return [m.group(1) for m in VERSION.finditer(text or "")]


def main():
    cells = sources_anchor_cells()
    print("--- feed rows: versions named in the anchor cell (located anchor) ---")
    for source_id in sorted(cells):
        if source_id >= "S033" and source_id <= "S039":
            print("  %s recheck=%-10s anchor versions=%s  teaches versions=%s"
                  % (source_id, cells[source_id]["recheck"],
                     versions(cells[source_id]["anchor"]),
                     versions(cells[source_id]["teaches"])))
    print("--- derived rows vs feed located anchor ---")
    derived = [r for r in rows() if r["note"].startswith("derived:")]
    print("  derived row count: %d" % len(derived))
    mismatches = 0
    for row in derived:
        feed_id = row["feed_source_id"]
        located = versions(cells[feed_id]["anchor"])
        anchored = row["anchored_version"]
        ok = anchored in located
        if not ok:
            mismatches += 1
        print("  %s feed=%s anchored=%-8s located=%s bound=%s"
              % (row["id"], feed_id, anchored, located, ok))
    print("  rows not bound at BASE: %d" % mismatches)
    print("--- non-derived feed rows (rule must not generalise) ---")
    for row in rows():
        if row["clock"] == "feed" and not row["note"].startswith("derived:"):
            feed_id = row["feed_source_id"]
            print("  %s feed=%s anchored=%-8s located=%s"
                  % (row["id"], feed_id, row["anchored_version"],
                     versions(cells[feed_id]["anchor"])))
    return 0


if __name__ == "__main__":
    sys.exit(main())

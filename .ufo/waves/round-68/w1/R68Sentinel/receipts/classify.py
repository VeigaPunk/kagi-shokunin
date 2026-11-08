#!/usr/bin/env python3
"""Classify every source-fetches.tsv row under the round-68 widened rule.

Frozen rule (plans/round-68.md §C1 classification rule):
  a col16 cell is LEGAL iff it either names no `.ufo/waves/` whitespace-delimited
  token at all (frozen `prose`, never read) or is exactly one such path with no
  other content (frozen `path`, read and bound); every other shape that mentions
  a `.ufo/waves/` path is a defect.

This script reports, per row, which reading of "names a .ufo/waves/ path"
the row falls under, so the executor seats can see the population boundary.
It is a read-only analysis; it writes nothing into the lane.
"""
import os
import re
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
TSV = os.path.join(LANE, "corpus/source-fetches.tsv")

WAVES = ".ufo/waves/"


def cells_of(path):
    rows = []
    with open(path, encoding="utf-8", errors="replace") as fh:
        raw = fh.read()
    for n, line in enumerate(raw.splitlines(), 1):
        if not line or line.startswith("#"):
            continue
        rows.append((n, line.split("\t"), line))
    return rows


def tokens(cell):
    return cell.split()


def names_waves_contains(tok):
    """READING A: the token CONTAINS the .ufo/waves/ segment anywhere."""
    return WAVES in tok


def names_waves_prefix(tok):
    """READING B: the token STARTS WITH .ufo/waves/ (a prefix test on the raw
    token)."""
    return tok.startswith(WAVES)


def classify(cell):
    toks = tokens(cell)
    a = [t for t in toks if names_waves_contains(t)]
    b = [t for t in toks if names_waves_prefix(t)]
    pure = (cell.strip() == cell and len(toks) == 1 and cell.startswith(WAVES))
    return toks, a, b, pure


def main():
    rows = cells_of(TSV)
    print("total data rows:", len(rows))
    counts = {"prose": 0, "path": 0, "defect_contains": 0, "defect_prefix_only": 0}
    diffs = []
    for n, cells, line in rows:
        if len(cells) != 16:
            print("  NF!=16 line", n, len(cells))
            continue
        cell = cells[15]
        toks, a, b, pure = classify(cell)
        if not a:
            kind = "prose"
        elif len(toks) == 1 and len(cell) == len(cell.strip()) and a[0] == cell:
            kind = "path"
        else:
            kind = "defect_contains"
        counts[kind] += 1
        # divergence between the two readings
        if bool(a) != bool(b):
            counts["defect_prefix_only"] += 1
            diffs.append((n, cells[0], cell, a, b))
    print(counts)
    print("\n--- rows where 'contains' and 'prefix' readings disagree ---")
    for n, rid, cell, a, b in diffs:
        print("line %d id=%s contains=%s prefix=%s cell=%r" % (n, rid, a, b, cell))
    print("\n--- non-prose rows (candidate population) ---")
    for n, cells, line in rows:
        if len(cells) != 16:
            continue
        cell = cells[15]
        toks, a, b, pure = classify(cell)
        if a:
            print("line %d id=%-6s pure=%s tokens=%s" % (n, cells[0], pure, a))


if __name__ == "__main__":
    main()

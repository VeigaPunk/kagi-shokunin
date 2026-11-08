#!/usr/bin/env python3
"""Measure the round-68 C1 target numbers (verified, col15) on a tree, with a
TRUSTED normalizer, using the widened population rule.

Read-only. Prints the derived numbers for a tree given as argv[1] and the
trusted normalizer given as argv[2].
"""
import hashlib
import os
import re
import subprocess
import sys

WAVES = ".ufo/waves/"


def sha256_file(p):
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for c in iter(lambda: fh.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def main():
    tree = os.path.realpath(sys.argv[1])
    norm = sys.argv[2]
    tsv = os.path.join(tree, "corpus/source-fetches.tsv")
    verified = 0
    col15_ok = 0
    rendered = 0
    prose = 0
    defects = []
    with open(tsv, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            if not line or line.startswith("#"):
                continue
            cells = line.rstrip("\n").split("\t")
            if len(cells) != 16:
                continue
            rid = cells[0].strip()
            loc = cells[15]
            toks = loc.split()
            hits = [t for t in toks if WAVES in t]
            if not hits:
                prose += 1
                continue
            tok = hits[0]
            full = os.path.join(tree, tok)
            if not os.path.isfile(full):
                defects.append((rid, "capture-missing", tok))
                continue
            if sha256_file(full) != cells[9].strip():
                defects.append((rid, "capture-digest-mismatch", tok))
                continue
            if str(os.path.getsize(full)) != cells[10].strip():
                defects.append((rid, "capture-bytes-mismatch", tok))
                continue
            # quote locate with the TRUSTED normalizer
            if cells[13].strip() == "rendered-text-v1":
                p = subprocess.run(["python3", norm, "locate", full, cells[12]],
                                   capture_output=True, text=True)
                m = re.search(r"count=(\d+)", p.stdout)
                if not m or int(m.group(1)) < 1:
                    defects.append((rid, "quote-not-located", tok))
                    continue
            else:
                with open(full, "rb") as fh:
                    if cells[12].encode() not in fh.read():
                        defects.append((rid, "quote-not-located", tok))
                        continue
            verified += 1
            if cells[13].strip() == "rendered-text-v1":
                rendered += 1
                p = subprocess.run(["python3", norm, "digest", full],
                                   capture_output=True, text=True)
                m = re.search(r"normalized_sha256=([0-9a-f]{64})", p.stdout)
                if m and m.group(1) == cells[14].strip():
                    col15_ok += 1
    print("tree: %s" % tree)
    print("verified=%d col15=%d prose=%d rendered_verified=%d defects=%d"
          % (verified, col15_ok, prose, rendered, len(defects)))
    for d in defects:
        print("  DEFECT %s" % (d,))


if __name__ == "__main__":
    main()

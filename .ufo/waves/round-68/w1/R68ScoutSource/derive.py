#!/usr/bin/env python3
"""Derive the C1 'verified' / 'col15' populations from a tree, row by row.

Populations (from plans/round-68.md §C1):
  verified -- rows whose col16 is a repo-relative capture path, or contains a
              whitespace-delimited token that is a repo-relative .ufo/waves/
              capture path, and whose FIRST such token names a file inside the
              measured tree whose raw sha256 == col10, byte count == col11, and
              whose col13 quote locates count>=1 under col14's normalization.
  col15    -- of the verified rows with normalization rendered-text-v1, those
              whose recomputed normalized digest == col15.

Usage: derive.py TREE NORMALIZER
"""
import hashlib
import os
import subprocess
import sys

TREE = os.path.abspath(sys.argv[1])
NORM = os.path.abspath(sys.argv[2])
FETCH = os.path.join(TREE, "corpus", "source-fetches.tsv")


def sha256_file(p):
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def norm_digest(p):
    r = subprocess.run([sys.executable, NORM, "digest", p],
                       capture_output=True, text=True)
    for tok in r.stdout.split():
        if tok.startswith("normalized_sha256="):
            return tok.split("=", 1)[1]
    return None


def locate(p, quote):
    r = subprocess.run([sys.executable, NORM, "locate", p, quote],
                       capture_output=True, text=True)
    for tok in r.stdout.split():
        if tok.startswith("count="):
            return int(tok.split("=", 1)[1])
    return 0


def token_capture(cell):
    """First whitespace-delimited token that is a repo-relative .ufo/waves/ path."""
    for tok in cell.split():
        if tok.startswith(".ufo/waves/") and not tok.startswith(".ufo/waves//"):
            return tok
    return None


def pure_path(cell):
    """col16 that is exactly one repo-relative .ufo/waves/ capture path."""
    c = cell.strip()
    return c if (c.startswith(".ufo/waves/") and len(c.split()) == 1) else None


rows = []
with open(FETCH, encoding="utf-8") as fh:
    for line in fh:
        if not line.strip() or line.startswith("#"):
            continue
        f = line.rstrip("\n").split("\t")
        if len(f) != 16:
            continue
        rows.append(f)

verified, col15, prose = [], [], []
for f in rows:
    fid, _, _, _, _, _, _, _, _, fsha, fbytes, _, fquote, fnorm, fnsha, floc = f
    tok = pure_path(floc) or token_capture(floc)
    if tok is None:
        prose.append(fid)
        continue
    p = os.path.join(TREE, tok)
    if not os.path.isfile(p):
        prose.append(fid + "(unresolved)")
        continue
    if sha256_file(p) != fsha or os.path.getsize(p) != int(fbytes):
        prose.append(fid + "(bytes/digest)")
        continue
    if locate(p, fquote) < 1:
        prose.append(fid + "(quote)")
        continue
    verified.append(fid)
    if fnorm == "rendered-text-v1" and norm_digest(p) == fnsha:
        col15.append(fid)

print("verified=%d col15=%d prose=%d" % (len(verified), len(col15), len(prose)))
print("verified_ids=%s" % ",".join(verified))
print("col15_ids=%s" % ",".join(col15))
print("prose_ids=%s" % ",".join(prose))

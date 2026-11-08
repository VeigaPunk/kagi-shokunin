#!/usr/bin/env python3
"""Reference implementation of the round-68 WIDENED capture binding.

This is a test instrument, NOT the landed gate. It implements the frozen
reason set and classification rule of plans/round-68.md §C1 so the sentinel can
measure which classifier readings are fail-open BEFORE the gate lands, and can
re-run the same battery against the landed gate afterwards.

Reason set (frozen):
  SC_CAPTURE id=<id> capture-whitespace
  SC_CAPTURE id=<id> capture-token
  SC_CAPTURE id=<id> normalized-digest-mismatch
  SC_FETCH cr-in-tsv                       (file level)

Classifier variants (the boundary under test):
  contains : a whitespace-delimited token that CONTAINS the segment .ufo/waves/
  prefix   : a whitespace-delimited token that STARTS WITH .ufo/waves/

Usage: refgate.py --tree DIR [--variant contains|prefix]
Prints the same line shapes as the landed gate.
"""
import argparse
import hashlib
import os
import re
import subprocess
import sys

REL_SHAPE = re.compile(r"^[A-Za-z0-9._][A-Za-z0-9._/-]*$")
ABS_SHAPE = re.compile(r"^/[A-Za-z0-9._][A-Za-z0-9._/-]*$")
WAVES = ".ufo/waves/"


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def token_is_waves(tok, variant):
    if variant == "prefix":
        return tok.startswith(WAVES)
    return WAVES in tok


def classify(cell, variant):
    """Returns ('prose'|'path'|'whitespace'|'token')."""
    toks = cell.split()
    hits = [t for t in toks if token_is_waves(t, variant)]
    if not hits:
        return "prose"
    # pure path: exactly one whitespace-delimited token, the whole cell, no
    # other content, and the token itself names a .ufo/waves/ path
    if len(toks) == 1 and toks[0] == cell and len(cell) == len(cell.strip()):
        return "path"
    if cell != cell.strip() or "," in cell:
        return "whitespace"
    return "token"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True)
    ap.add_argument("--variant", default="contains")
    a = ap.parse_args()
    tree = os.path.abspath(a.tree)
    root = os.path.realpath(tree)
    findings = []
    path_rows = bound = located = prose = defects = 0

    tsv = os.path.join(tree, "corpus/source-fetches.tsv")
    with open(tsv, "rb") as fh:
        raw = fh.read()
    if b"\r" in raw:
        findings.append("SC_FETCH cr-in-tsv")
        defects += 1

    norm = os.path.join(tree, "corpus/rendered-text-v1.py")
    text = raw.decode("utf-8", errors="replace")
    for line in text.split("\n"):
        if not line or line.startswith("#"):
            continue
        cells = line.split("\t")
        if len(cells) != 16:
            continue
        fid, fsha, fbytes, fquote, fnorm, fnsha, floc = (
            cells[0], cells[9], cells[10], cells[12], cells[13], cells[14], cells[15])
        if not fid:
            continue
        kind = classify(floc, a.variant)
        if kind == "prose":
            prose += 1
            continue
        if kind == "whitespace":
            findings.append("SC_CAPTURE id=%s capture-whitespace" % fid)
            defects += 1
            continue
        if kind == "token":
            findings.append("SC_CAPTURE id=%s capture-token" % fid)
            defects += 1
            continue
        # pure path: bind it
        path_rows += 1
        rp = os.path.realpath(os.path.join(root, floc))
        if floc.startswith("/") or (rp != root and not rp.startswith(root + os.sep)):
            findings.append("SC_CAPTURE id=%s capture-outside-root" % fid)
            defects += 1
            continue
        full = os.path.join(root, floc)
        if not os.path.isfile(full):
            findings.append("SC_CAPTURE id=%s capture-missing" % fid)
            defects += 1
            continue
        size = os.path.getsize(full)
        got = sha256_file(full)
        bad = False
        if str(size) != fbytes:
            findings.append("SC_CAPTURE id=%s capture-bytes-mismatch" % fid)
            defects += 1
            bad = True
        if got != fsha:
            findings.append("SC_CAPTURE id=%s capture-digest-mismatch" % fid)
            defects += 1
            bad = True
        if bad:
            continue
        bound += 1
        # quote locate
        if fnorm == "rendered-text-v1":
            p = subprocess.run(["python3", norm, "locate", full, fquote],
                               capture_output=True, text=True)
            out = p.stdout.strip()
            m = re.match(r"RENDERED_TEXT_V1_LOCATE: count=(\d+)", out)
            n = int(m.group(1)) if m else 0
            ok = p.returncode == 0 and n >= 1
        else:
            with open(full, "rb") as fh:
                ok = fquote.encode() in fh.read()
        if not ok:
            findings.append("SC_CAPTURE id=%s quote-not-located" % fid)
            defects += 1
            continue
        located += 1
        # normalized digest recompute (the round-68 addition)
        if fnorm == "rendered-text-v1":
            p = subprocess.run(["python3", norm, "digest", full],
                               capture_output=True, text=True)
            out = p.stdout.strip()
            m = re.search(r"normalized_sha256=([0-9a-f]{64})", out)
            if m is None or m.group(1) != fnsha:
                findings.append("SC_CAPTURE id=%s normalized-digest-mismatch" % fid)
                defects += 1

    for f in findings:
        print("FINDING %s" % f)
    state = "CLEAN" if defects == 0 else "FAILED"
    if defects == 0:
        print("SOURCES_CAPTURES: CLEAN (path_rows=%d bound=%d located=%d prose=%d)"
              % (path_rows, bound, located, prose))
    else:
        print("SOURCES_CAPTURES: FAILED (defects=%d path_rows=%d bound=%d located=%d prose=%d)"
              % (defects, path_rows, bound, located, prose))
    print("SOURCES_CENSUS: %s (findings=%d rows=0)" % (state, len(findings)))
    return 0 if defects == 0 else 1


if __name__ == "__main__":
    sys.exit(main())

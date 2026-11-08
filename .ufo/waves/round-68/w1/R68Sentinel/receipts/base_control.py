#!/usr/bin/env python3
"""R68Sentinel part 3 — BASE blindness control for the six frozen legs, and
the BASE anchor derivation.

The plan's six legs are run against the BASE gate (e7aacecd) on the BASE tree
(d3b2a4e) to measure which legs the BASE gate already catches.  The plan's
motivating evidence claims "caught=0/6" at BASE; this measures it.
"""
import hashlib
import os
import re
import shutil
import subprocess
import sys

SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"
BASE = os.path.join(SCRATCH, "basetree")
WORK = os.path.join(SCRATCH, "baselegs")
RECEIPTS = os.path.join(SCRATCH, "receipts")
TSV_REL = "corpus/source-fetches.tsv"


def sha256_file(p):
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for c in iter(lambda: fh.read(1 << 20), b""):
            h.update(c)
    return h.hexdigest()


def rows(tree):
    out = []
    with open(os.path.join(tree, TSV_REL), encoding="utf-8", errors="replace") as fh:
        for n, line in enumerate(fh, 1):
            if not line or line.startswith("#"):
                continue
            out.append((n, line.rstrip("\n").split("\t")))
    return out


def shaped_rows(tree):
    """Rows whose col16 is capture-path-shaped (the round-67 population)."""
    sh = []
    for n, c in rows(tree):
        if len(c) != 16:
            continue
        loc = c[15]
        if "/" not in loc:
            continue
        if not re.fullmatch(r"[A-Za-z0-9._][A-Za-z0-9._/-]*", loc):
            continue
        if not re.fullmatch(r"/[A-Za-z0-9._][A-Za-z0-9._/-]*", loc):
            sh.append((n, c))
    return sh


def anchor(tree):
    """The LAST capture-path-shaped row in file order that binds its declared
    bytes (the plan's anchor derivation)."""
    tree_real = os.path.realpath(tree)
    for n, c in reversed(shaped_rows(tree)):
        loc = c[15]
        if loc.startswith("/"):
            continue
        full = os.path.join(tree, loc)
        if not os.path.isfile(full):
            continue
        real = os.path.realpath(full)
        if not (real == tree_real or real.startswith(tree_real + os.sep)):
            continue
        if sha256_file(full) != c[9].strip():
            continue
        if str(os.path.getsize(full)) != c[10].strip():
            continue
        return n, c
    return None, None


def clone(name, src):
    dst = os.path.join(WORK, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst, symlinks=True)
    return dst


def read_tsv(tree):
    return open(os.path.join(tree, TSV_REL), "rb").read()


def write_tsv(tree, data):
    p = os.path.join(tree, TSV_REL)
    os.unlink(p)
    open(p, "wb").write(data)


def edit_row(tree, sid, col, value):
    data = read_tsv(tree).split(b"\n")
    out = []
    for ln in data:
        if ln.startswith(sid.encode() + b"\t"):
            c = ln.split(b"\t")
            c[col] = value if isinstance(value, bytes) else value.encode()
            ln = b"\t".join(c)
        out.append(ln)
    write_tsv(tree, b"\n".join(out))


def run_gate(tree):
    p = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, timeout=600)
    return p.returncode, p.stdout


def verdict(out):
    v = [l for l in out.splitlines() if l.startswith("SOURCES_CENSUS:")]
    return v[-1] if v else "(none)"


def caps(out):
    v = [l for l in out.splitlines() if l.startswith("SOURCES_CAPTURES:")]
    return v[-1] if v else "(none)"


def main():
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)
    out = []

    n, a = anchor(BASE)
    out.append("BASE anchor (LAST capture-path-shaped row that binds):")
    out.append("  line %d id=%s col16=%s" % (n, a[0], a[15]))
    aid = a[0]
    aloc = a[15]
    cand = os.path.join(os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku")
                        + "/kagi-r68/R68Sentinel/pristine")
    n2, a2 = anchor(cand)
    out.append("CANDIDATE anchor: line %d id=%s col16=%s" % (n2, a2[0], a2[15]))

    legs = [
        ("M1 col16 trailing space", "capture-whitespace",
         lambda t: edit_row(t, aid, 15, aloc + " ")),
        ("M2 col16 comma-joined", "capture-whitespace",
         lambda t: edit_row(t, aid, 15, aloc + "," + aloc)),
        ("M3 whole TSV CRLF", "SC_FETCH cr-in-tsv",
         lambda t: write_tsv(t, read_tsv(t).replace(b"\n", b"\r\n"))),
        ("M4 col10 hex digit", "capture-digest-mismatch",
         lambda t: edit_row(t, aid, 9, ("0" if a[9][0] != "0" else "1") + a[9][1:])),
        ("M5 col15 borrowed digest", "normalized-digest-mismatch",
         lambda t: edit_row(t, aid, 14, "a" * 64)),
        ("M6 body +1 byte", "capture-bytes-mismatch",
         lambda t: None),
    ]

    out.append("")
    out.append("BASE gate on the BASE tree, per frozen leg "
               "(anchor id=%s):" % aid)
    caught = 0
    for name, expect, mut in legs:
        tree = clone("base-" + re.sub(r"[^a-z0-9]+", "-", name.lower()), BASE)
        if name.startswith("M6"):
            p = os.path.join(tree, aloc)
            data = open(p, "rb").read()
            os.unlink(p)
            open(p, "wb").write(data + b"\n")
        else:
            mut(tree)
        rc, o = run_gate(tree)
        fl = [l for l in o.splitlines() if l.startswith("FINDING SC_CAPTURE id=%s " % aid)
              or l.startswith("FINDING SC_FETCH")]
        got = [l for l in fl if expect in l]
        hit = (rc == 1 and got)
        caught += 1 if hit else 0
        out.append("  %-28s rc=%d expected=%-28s %s" %
                   (name, rc, expect, "CAUGHT" if hit else "SURVIVED"))
        out.append("      %s" % verdict(o))
        out.append("      %s" % caps(o))
        for l in fl:
            out.append("      %s" % l)
    out.append("")
    out.append("BASE caught = %d/6 (the plan's motivating evidence claims 0/6)" % caught)

    text = "\n".join(out)
    open(os.path.join(RECEIPTS, "base-legs.txt"), "w").write(text + "\n")
    print(text)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Mutation driver for the kagi round-68 capture-binding reasons.

Runs a given census gate over mutated copies of a candidate tree and
prints, per case, the gate's own verdict lines and its FINDING lines.

Usage: driver.py --gate <path to corpus/sources-census.sh> --tree <candidate tree>
                  --out <dir> [--anchor S166]

Every case is a byte-level mutation of corpus/source-fetches.tsv (or of the
anchor's capture body). The tree copy is made with shutil.copytree
(symlinks=False) so no in-tree byte is written; the mutated file is
written with a fresh inode inside the copy.
"""
import argparse
import hashlib
import os
import shutil
import subprocess
import sys

ANCHOR_DEFAULT = "S166"


def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def read_tsv(path):
    with open(path, "rb") as f:
        return f.read().split(b"\n")


def write_tsv(path, lines):
    with open(path, "wb") as f:
        f.write(b"\n".join(lines))


def col(lines, fid, idx):
    for l in lines:
        if l.startswith(fid.encode() + b"\t"):
            return l.split(b"\t")[idx]
    raise SystemExit(f"row {fid} not found")


def set_col(lines, fid, idx, value):
    out = []
    done = False
    for l in lines:
        if not done and l.startswith(fid.encode() + b"\t"):
            f = l.split(b"\t")
            f[idx] = value
            l = b"\t".join(f)
            done = True
        out.append(l)
    if not done:
        raise SystemExit(f"row {fid} not found")
    return out


def case_whitespace(tree, anchor):
    """M1: append one space (0x20) to the anchor's col 16."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    v = col(lines, anchor, 15)
    write_tsv(p, set_col(lines, anchor, 15, v + b" "))


def case_comma(tree, anchor):
    """M2: append ',' + the anchor's own path again (comma-joined duplicate)."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    v = col(lines, anchor, 15)
    write_tsv(p, set_col(lines, anchor, 15, v + b"," + v))


def case_crlf(tree, anchor):
    """M3: rewrite the whole corpus/source-fetches.tsv with CR at every line end."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    with open(p, "rb") as f:
        d = f.read()
    with open(p, "wb") as f:
        f.write(d.replace(b"\n", b"\r\n"))


def case_digest(tree, anchor):
    """M4: replace one hex digit of the anchor's col 10 (still 64 lowercase hex)."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    v = col(lines, anchor, 9).decode()
    flipped = ("0" if v[0] != "0" else "1") + v[1:]
    write_tsv(p, set_col(lines, anchor, 9, flipped.encode()))


def case_col15(tree, anchor):
    """M5: replace the anchor's col 15 with another 64-hex digest of the same normalization."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    v = col(lines, anchor, 14).decode()
    other = "4d966ff9535cdbd8faa00ad925f60e2fb38892bdb07cd48bb587c9da8aac72d5"
    if other == v:
        other = "0" * 64
    write_tsv(p, set_col(lines, anchor, 14, other.encode()))


def case_bytes(tree, anchor):
    """M6: append one byte to the anchor's capture body."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    body = col(lines, anchor, 15).decode()
    with open(os.path.join(tree, body), "ab") as f:
        f.write(b"\n")


def case_prose_mixed(tree, anchor):
    """A mixed-prose cell naming a lane capture (the shape S166 had before the recut)."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    v = col(lines, anchor, 15).decode()
    write_tsv(p, set_col(lines, anchor, 15, ("§1.2 Concept Overview; capture " + v).encode()))


def case_token_unresolved(tree, anchor):
    """A cell naming a .ufo/waves/ token that does not resolve in-lane."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    write_tsv(p, set_col(lines, anchor, 15, b".ufo/waves/round-99/capture/S999.body"))


def case_token_home(tree, anchor):
    """A `~/` form naming a .ufo/waves/ file."""
    p = os.path.join(tree, "corpus/source-fetches.tsv")
    lines = read_tsv(p)
    v = col(lines, anchor, 15).decode()
    write_tsv(p, set_col(lines, anchor, 15, ("~/" + v).encode()))


CASES = [
    ("M1-trailing-space", case_whitespace),
    ("M2-comma-joined", case_comma),
    ("M3-whole-file-crlf", case_crlf),
    ("M4-col10-hex-digit", case_digest),
    ("M5-col15-swapped", case_col15),
    ("M6-body-byte-appended", case_bytes),
    ("X1-mixed-prose-names-capture", case_prose_mixed),
    ("X2-token-does-not-resolve", case_token_unresolved),
    ("X3-home-relative-token", case_token_home),
]


def run(gate, tree):
    env = dict(os.environ)
    env["LC_ALL"] = "C"
    r = subprocess.run(
        ["bash", gate, "verify", "--root", "."],
        cwd=tree, capture_output=True, text=True, env=env,
    )
    return r.returncode, r.stdout, r.stderr


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gate", required=True)
    ap.add_argument("--tree", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--anchor", default=ANCHOR_DEFAULT)
    a = ap.parse_args()

    os.makedirs(a.out, exist_ok=True)
    base = os.path.join(a.out, "trees")
    os.makedirs(base, exist_ok=True)

    # control: the unmodified tree
    ctl = os.path.join(base, "control")
    if os.path.exists(ctl):
        shutil.rmtree(ctl)
    shutil.copytree(a.tree, ctl, symlinks=False)
    rc, out, err = run(a.gate, ctl)
    with open(os.path.join(a.out, "control.txt"), "w") as f:
        f.write(f"gate={a.gate}\ngate_sha256={sha256(a.gate)}\n")
        f.write(f"tree={a.tree} (unmodified control copy)\nrc={rc}\n--- stdout ---\n{out}--- stderr ---\n{err}")
    print(f"[control] rc={rc}")

    for name, fn in CASES:
        d = os.path.join(base, name)
        if os.path.exists(d):
            shutil.rmtree(d)
        shutil.copytree(a.tree, d, symlinks=False)
        fn(d, a.anchor)
        rc, out, err = run(a.gate, d)
        findings = [l for l in out.splitlines() if l.startswith("FINDING")]
        verdict = [l for l in out.splitlines() if l.startswith("SOURCES_CENSUS:") or l.startswith("SOURCES_CAPTURES:")]
        with open(os.path.join(a.out, name + ".txt"), "w") as f:
            f.write(f"case={name}\ngate={a.gate}\ngate_sha256={sha256(a.gate)}\n")
            f.write(f"tree={d}\nrc={rc}\n")
            f.write("--- verdict lines ---\n" + "\n".join(verdict) + "\n")
            f.write("--- FINDING lines ---\n" + "\n".join(findings) + "\n")
            f.write("--- full stdout ---\n" + out)
            f.write("--- stderr ---\n" + err)
        print(f"[{name}] rc={rc} findings={len(findings)}")
        for l in findings[:6]:
            print("    " + l)
    print("OK")


if __name__ == "__main__":
    main()

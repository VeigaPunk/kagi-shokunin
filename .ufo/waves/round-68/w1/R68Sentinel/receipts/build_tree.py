#!/usr/bin/env python3
"""R68Sentinel class-tree builder + battery harness (round 68 sentinel).

Read-only on the lane. Every tree under test is a private copy under scratch.
Nothing in the lane is written; the gate is invoked on copies only.
"""
import hashlib
import os
import re
import shutil
import subprocess
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"

REL_SHAPE = re.compile(r"^[A-Za-z0-9._][A-Za-z0-9._/-]*$")
ABS_SHAPE = re.compile(r"^/[A-Za-z0-9._][A-Za-z0-9._/-]*$")


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def read_rows(tsv):
    rows = []
    with open(tsv, encoding="utf-8", errors="replace") as fh:
        for n, line in enumerate(fh.read().splitlines(), 1):
            if not line or line.startswith("#"):
                continue
            rows.append((n, line.split("\t")))
    return rows


def capture_shaped(loc):
    if "/" not in loc:
        return False
    return bool(REL_SHAPE.fullmatch(loc) or ABS_SHAPE.fullmatch(loc))


def build_pristine(dest):
    """Minimal tree: corpus/ + every capture body a capture-shaped row names."""
    if os.path.exists(dest):
        shutil.rmtree(dest)
    os.makedirs(dest)
    shutil.copytree(os.path.join(LANE, "corpus"), os.path.join(dest, "corpus"),
                    symlinks=True, ignore=shutil.ignore_patterns("__pycache__"))
    tsv = os.path.join(dest, "corpus/source-fetches.tsv")
    for n, cells in read_rows(tsv):
        if len(cells) != 16:
            continue
        loc = cells[15]
        if not capture_shaped(loc):
            continue
        src = os.path.join(LANE, loc)
        dst = os.path.join(dest, loc)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.islink(src):
            os.symlink(os.readlink(src), dst)
        elif os.path.isfile(src):
            shutil.copy2(src, dst)
    return dest


def gate_run(tree):
    """Run the tree's own gate. Returns (rc, stdout)."""
    p = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, timeout=600)
    return p.returncode, p.stdout


def main():
    dest = os.path.join(SCRATCH, "pristine")
    build_pristine(dest)
    print("pristine built at", dest)
    rc, out = gate_run(dest)
    print("rc", rc)
    for ln in out.splitlines():
        if ln.startswith("SOURCES_"):
            print(" ", ln)


if __name__ == "__main__":
    main()

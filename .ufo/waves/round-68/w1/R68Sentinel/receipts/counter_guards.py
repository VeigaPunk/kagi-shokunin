#!/usr/bin/env python3
"""R68Sentinel part 5 — which guard binds a hostile tree.

Tests the ROUND-67 counter (the closest landed instrument; the round-68
counter does not exist yet) against hostile trees:

  G1  a CONSTANT-PRINTER gate (prints CLEAN without reading a byte) -- does
      the counter refuse it?
  G2  a tree whose corpus/rendered-text-v1.py is a truthy stub -- does the
      counter's instrument-identity guard fire?
  G3  a tree whose gate is a constant printer AND whose normalizer is truthy --
      the combined attack.

And the PATH-shim tests, redone with absolute shebangs so the shim is
actually executable.

Read-only on the lane.  Every tree is a private copy under scratch.
"""
import os
import shutil
import subprocess
import sys

SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
PRISTINE = os.path.join(SCRATCH, "pristine")
WORK = os.path.join(SCRATCH, "guards")
RECEIPTS = os.path.join(SCRATCH, "receipts")
COUNTER = os.path.join(LANE, "plans/round-67-c1.sh")

CONST_GATE = """#!/bin/bash
printf 'SOURCES_CAPTURES: CLEAN (path_rows=37 bound=37 located=37 prose=120)\\n'
printf 'SOURCES_CENSUS: CLEAN (rows=157 A=140 B=2 C=15 queued=3 mined=137 rejected=17 entries_sourced=27 legacy=21 captures=157 inrow=16 inrow_only=0 inrow_nonreproducing=12)\\n'
exit 0
"""

TRUTHY_NORM = '''#!/usr/bin/python3
import sys, os
if len(sys.argv) > 1 and sys.argv[1] == "locate":
    print("RENDERED_TEXT_V1_LOCATE: count=1")
    sys.exit(0)
if len(sys.argv) > 1 and sys.argv[1] == "digest":
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tsv = os.path.join(root, "corpus", "source-fetches.tsv")
    rel = os.path.relpath(os.path.abspath(sys.argv[2]), root)
    val = "0" * 64
    try:
        with open(tsv, "rb") as fh:
            for line in fh:
                if not line or line.startswith(b"#"):
                    continue
                cells = line.rstrip(b"\\n").split(b"\\t")
                if len(cells) == 16 and cells[15].decode("utf-8", "replace") == rel:
                    val = cells[14].decode()
    except OSError:
        pass
    print("RENDERED_TEXT_V1: raw_sha256=%s bytes=0 normalized_sha256=%s normalized_bytes=0" % ("0"*64, val))
    sys.exit(0)
sys.exit(0)
'''

SHIM_PY = '''#!/usr/bin/python3
import sys
if len(sys.argv) > 2 and sys.argv[1] == "locate":
    print("RENDERED_TEXT_V1_LOCATE: count=1")
    sys.exit(0)
sys.exit(0)
'''

SHIM_BASH = """#!/bin/bash
printf 'SOURCES_CAPTURES: CLEAN (path_rows=37 bound=37 located=37 prose=120)\\n'
printf 'SOURCES_CENSUS: CLEAN (rows=157 A=140 B=2 C=15 queued=3 mined=137 rejected=17 entries_sourced=27 legacy=21 captures=157 inrow=16 inrow_only=0 inrow_nonreproducing=12)\\n'
exit 0
"""


def clone(name):
    dst = os.path.join(WORK, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(PRISTINE, dst, symlinks=True)
    return dst


def write(path, text, mode=0o755):
    if os.path.lexists(path):
        os.unlink(path)
    with open(path, "w") as fh:
        fh.write(text)
    os.chmod(path, mode)


def run_counter(tree, env=None, extra_path=None):
    e = dict(os.environ)
    if env:
        e.update(env)
    if extra_path:
        e["PATH"] = extra_path + ":" + e["PATH"]
    scratch = os.path.join(WORK, "scratch-" + os.path.basename(tree))
    p = subprocess.run(["/usr/bin/bash", COUNTER, "--tree", tree,
                        "--scratch", scratch],
                       capture_output=True, text=True, env=e, timeout=1200)
    return p


def verdict(p):
    v = [l for l in p.stdout.splitlines() if l.startswith("C1_READTHROUGH:")]
    return v[-1] if v else "(no verdict line)"


def main():
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)
    out = []

    # G0 control: the pristine candidate tree
    tree = clone("G0-control")
    p = run_counter(tree)
    out.append("=== G0 control: the candidate tree, unmodified ===")
    out.append("rc=%d %s" % (p.returncode, verdict(p)))
    for l in p.stdout.splitlines():
        if l.startswith("c1-") or l.startswith("guard-") or l.startswith("pop-"):
            out.append("   %s" % l)

    # G1 constant-printer gate
    tree = clone("G1-constant-gate")
    write(os.path.join(tree, "corpus/sources-census.sh"), CONST_GATE)
    p = run_counter(tree)
    out.append("")
    out.append("=== G1 the tree's gate is a CONSTANT PRINTER "
               "(prints CLEAN, reads nothing) ===")
    out.append("rc=%d %s" % (p.returncode, verdict(p)))
    for l in p.stdout.splitlines():
        if l.startswith(("c1-", "guard-", "pop-", "caught-")):
            out.append("   %s" % l)

    # G2 truthy normalizer, real gate
    tree = clone("G2-truthy-normalizer")
    write(os.path.join(tree, "corpus/rendered-text-v1.py"), TRUTHY_NORM)
    p = run_counter(tree)
    out.append("")
    out.append("=== G2 the tree's normalizer is a TRUTHY STUB "
               "(count=1 always; digest echoes the row's own col 15) ===")
    out.append("rc=%d %s" % (p.returncode, verdict(p)))
    for l in p.stdout.splitlines():
        if l.startswith(("c1-", "guard-", "pop-", "caught-")):
            out.append("   %s" % l)

    # G3 combined
    tree = clone("G3-combined")
    write(os.path.join(tree, "corpus/sources-census.sh"), CONST_GATE)
    write(os.path.join(tree, "corpus/rendered-text-v1.py"), TRUTHY_NORM)
    p = run_counter(tree)
    out.append("")
    out.append("=== G3 combined: constant-printer gate + truthy normalizer ===")
    out.append("rc=%d %s" % (p.returncode, verdict(p)))
    for l in p.stdout.splitlines():
        if l.startswith(("c1-", "guard-", "pop-", "caught-")):
            out.append("   %s" % l)

    # G4 PATH shim python3 against the real gate
    tree = clone("G4-python3-path-shim")
    bindir = os.path.join(WORK, "bin-py")
    os.makedirs(bindir, exist_ok=True)
    write(os.path.join(bindir, "python3"), SHIM_PY)
    p = subprocess.run(["/usr/bin/bash", "corpus/sources-census.sh",
                        "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, timeout=600,
                       env={**os.environ, "PATH": bindir + ":" + os.environ["PATH"]})
    out.append("")
    out.append("=== G4 PATH shim: `python3` answers every locate with count=1 ===")
    out.append("gate rc=%d" % p.returncode)
    for l in p.stdout.splitlines():
        if l.startswith("SOURCES_"):
            out.append("   %s" % l)

    # G5 PATH shim bash against the counter
    tree = clone("G5-bash-path-shim")
    bindir = os.path.join(WORK, "bin-bash")
    os.makedirs(bindir, exist_ok=True)
    write(os.path.join(bindir, "bash"), SHIM_BASH)
    p = run_counter(tree, extra_path=bindir)
    out.append("")
    out.append("=== G5 PATH shim: `bash` fakes a clean gate run for the counter ===")
    out.append("rc=%d %s" % (p.returncode, verdict(p)))
    out.append("stderr: %s" % p.stderr[-600:])

    text = "\n".join(out)
    open(os.path.join(RECEIPTS, "counter-guards.txt"), "w").write(text + "\n")
    print(text)


if __name__ == "__main__":
    main()

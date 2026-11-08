#!/usr/bin/env python3
"""R68Sentinel part 2 — normalizer-stub and receipt/evidence forgery tests.

  A. self-consistent normalizer stub: answers count=1 AND a digest equal to
     the row's own col 15 (read out of the tree's own TSV).  Does the widened
     gate read CLEAN?  Which guard should bind it?
  B. PATH shim: a `python3` shim that answers any locate with count=1.
  C. PATH shim: a `bash` shim that fakes the gate's stdout for the counter.
  D. env var sweep on the counter.
  E. stray SOURCES_CAPTURES: line injected through a knowledge filename.
"""
import os
import shutil
import subprocess
import sys

SCRATCH = os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku") + "/kagi-r68/R68Sentinel"
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
PRISTINE = os.path.join(SCRATCH, "pristine")
WORK = os.path.join(SCRATCH, "forge")
RECEIPTS = os.path.join(SCRATCH, "receipts")

STUB = '''#!/usr/bin/env python3
# Truthy normalizer: answers count=1 for every locate, and answers "digest"
# with the col-15 value the row declares for the file it was asked about --
# read out of the tree's own corpus/source-fetches.tsv.
import sys, os, hashlib

def col15_for(path):
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tsv = os.path.join(root, "corpus", "source-fetches.tsv")
    rel = os.path.relpath(os.path.abspath(path), root)
    try:
        with open(tsv, "rb") as fh:
            for line in fh:
                if not line or line.startswith(b"#"):
                    continue
                cells = line.rstrip(b"\\n").split(b"\\t")
                if len(cells) != 16:
                    continue
                if cells[15].decode("utf-8", "replace") == rel:
                    return cells[14].decode()
    except OSError:
        pass
    return "0" * 64

if len(sys.argv) > 1 and sys.argv[1] == "locate":
    print("RENDERED_TEXT_V1_LOCATE: count=1")
    sys.exit(0)
if len(sys.argv) > 1 and sys.argv[1] == "digest":
    print("RENDERED_TEXT_V1: raw_sha256=%s bytes=0 normalized_sha256=%s normalized_bytes=0"
          % ("0" * 64, col15_for(sys.argv[2])))
    sys.exit(0)
sys.exit(0)
'''

PY_SHIM = '''#!/usr/bin/env python3
# PATH shim: every "locate" answers count=1; "digest" answers the col-15 the
# tree's own TSV declares for that file.
import sys, os
'''

BASH_SHIM = '''#!/usr/bin/env bash
# PATH shim: fakes a clean gate run.
printf 'SOURCES_CAPTURES: CLEAN (path_rows=37 bound=37 located=37 prose=120)\\n'
printf 'SOURCES_CENSUS: CLEAN (rows=157 A=140 B=2 C=15 queued=3 mined=137 rejected=17 entries_sourced=27 legacy=21 captures=157 inrow=16 inrow_only=0 inrow_nonreproducing=12)\\n'
exit 0
'''


def clone(name):
    dst = os.path.join(WORK, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(PRISTINE, dst, symlinks=True)
    return dst


def run_gate(tree, env=None, path=None):
    e = dict(os.environ)
    if env:
        e.update(env)
    if path:
        e["PATH"] = path + ":" + e["PATH"]
    p = subprocess.run(["bash", "corpus/sources-census.sh", "verify", "--root", "."],
                       cwd=tree, capture_output=True, text=True, env=e, timeout=600)
    return p.returncode, p.stdout


def run_ref(tree, variant="contains"):
    p = subprocess.run([sys.executable, os.path.join(SCRATCH, "refgate.py"),
                        "--tree", tree, "--variant", variant],
                       capture_output=True, text=True, timeout=600)
    return p.returncode, p.stdout


def main():
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(RECEIPTS, exist_ok=True)
    out = []

    # --- A. self-consistent normalizer stub -------------------------------
    tree = clone("A-normalizer-selfconsistent")
    p = os.path.join(tree, "corpus/rendered-text-v1.py")
    os.unlink(p)
    with open(p, "w") as fh:
        fh.write(STUB)
    lrc, lout = run_gate(tree)
    rrc, rout = run_ref(tree)
    out.append("=== A. self-consistent normalizer stub "
               "(count=1 for locate; digest = the row's own col 15) ===")
    out.append("LANE gate rc=%d" % lrc)
    out.append(lout)
    out.append("REF widened (contains) rc=%d" % rrc)
    out.append(rout)
    # also with a garbage quote, to see the quote half
    tree2 = clone("A2-stub-plus-garbage-quote")
    p = os.path.join(tree2, "corpus/rendered-text-v1.py")
    os.unlink(p)
    with open(p, "w") as fh:
        fh.write(STUB)
    tsv = os.path.join(tree2, "corpus/source-fetches.tsv")
    data = open(tsv, "rb").read().split(b"\n")
    for i, ln in enumerate(data):
        if ln.startswith(b"S166\t"):
            c = ln.split(b"\t")
            c[12] = b"zzz absent phrase zzz"
            data[i] = b"\t".join(c)
            break
    os.unlink(tsv)
    open(tsv, "wb").write(b"\n".join(data))
    lrc2, lout2 = run_gate(tree2)
    rrc2, rout2 = run_ref(tree2)
    out.append("=== A2. same stub + a quote that is absent from the body ===")
    out.append("LANE gate rc=%d" % lrc2)
    out.append(lout2)
    out.append("REF widened (contains) rc=%d" % rrc2)
    out.append(rout2)

    # --- B. PATH shim: python3 that answers any locate with count=1 ------
    tree = clone("B-python3-path-shim")
    bindir = os.path.join(WORK, "bin-python3")
    os.makedirs(bindir, exist_ok=True)
    shim = os.path.join(bindir, "python3")
    with open(shim, "w") as fh:
        fh.write('''#!/usr/bin/env python3
import sys
if len(sys.argv) > 2 and sys.argv[1] == "locate":
    print("RENDERED_TEXT_V1_LOCATE: count=1")
    sys.exit(0)
sys.exit(0)
''')
    os.chmod(shim, 0o755)
    lrc, lout = run_gate(tree, path=bindir)
    out.append("=== B. PATH shim: python3 answers every locate with count=1 ===")
    out.append("LANE gate rc=%d (PATH=%s first)" % (lrc, bindir))
    out.append(lout)

    # --- C. PATH shim: bash fakes the gate for the counter ----------------
    counter = os.path.join(LANE, "plans/round-67-c1.sh")
    bindir2 = os.path.join(WORK, "bin-bash")
    os.makedirs(bindir2, exist_ok=True)
    shim2 = os.path.join(bindir2, "bash")
    with open(shim2, "w") as fh:
        fh.write(BASH_SHIM)
    os.chmod(shim2, 0o755)
    e = dict(os.environ)
    e["PATH"] = bindir2 + ":" + e["PATH"]
    p = subprocess.run(["bash", counter, "--tree", PRISTINE,
                        "--scratch", os.path.join(WORK, "scratch-c")],
                       capture_output=True, text=True, env=e, timeout=900)
    out.append("=== C. PATH shim: `bash` fakes a clean gate run for the counter ===")
    out.append("counter rc=%d" % p.returncode)
    out.append(p.stdout[-4000:])
    out.append("stderr: " + p.stderr[-2000:])

    # --- D. env var sweep on the counter ---------------------------------
    tree = clone("D-env-sweep")
    envs = {
        "HYAKU_SCRATCH": os.path.join(WORK, "env-scratch"),
        "C1_KEEP_SCRATCH": "1",
        "SOURCES_CAPTURES": "CLEAN (path_rows=37 bound=37 located=37 prose=120)",
        "SOURCES_CENSUS": "CLEAN (rows=157)",
        "GUARD": "1",
        "C1_VERIFIED": "verified=37 col15=32 caught=6/6 guard=1",
    }
    out.append("=== D. env var sweep on the round-67 counter ===")
    for k, v in envs.items():
        p = subprocess.run(["bash", counter, "--tree", tree,
                            "--scratch", os.path.join(WORK, "env-scratch-" + k)],
                           capture_output=True, text=True, timeout=900,
                           env={**os.environ, k: v})
        last = [l for l in p.stdout.splitlines()
                if l.startswith("C1_READTHROUGH:")]
        out.append("env %s=%s -> rc=%d verdict=%s"
                   % (k, v[:40], p.returncode, last[-1] if last else "(none)"))

    # --- E. stray SOURCES_CAPTURES: line via a knowledge filename --------
    tree = clone("E-stray-summary-line")
    weird = os.path.join(tree, "corpus/knowledge",
                         "evil\nSOURCES_CAPTURES: CLEAN (path_rows=999 "
                         "bound=999 located=999 prose=0).md")
    with open(weird, "w") as fh:
        fh.write("source: S001 (https://example.invalid/one)\n"
                 "verified-at: 2026-11-08\nrecheck: 90d\n")
    lrc, lout = run_gate(tree)
    out.append("=== E. a knowledge filename carrying a stray "
               "'SOURCES_CAPTURES: CLEAN (...)' line ===")
    out.append("LANE gate rc=%d" % lrc)
    out.append(lout)
    out.append("stdout lines starting with SOURCES_CAPTURES: -> %s"
               % [l for l in lout.splitlines() if l.startswith("SOURCES_CAPTURES:")])

    text = "\n".join(out)
    with open(os.path.join(RECEIPTS, "forgery-detail.txt"), "w") as fh:
        fh.write(text + "\n")
    print(text)
    print("\nreceipts written")


if __name__ == "__main__":
    main()

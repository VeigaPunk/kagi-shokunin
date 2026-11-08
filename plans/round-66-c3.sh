#!/usr/bin/env bash
# plans/round-66-c3.sh — C3_CENSUS counter (kagi round 66, claim C3).
#
#   bash plans/round-66-c3.sh [--tree DIR] [--fleet DIR] [--scratch DIR]
#   bash plans/round-66-c3.sh --selftest
#
# Frozen predicate: plans/round-66.md §C3 as amended by Amendments A3 and A4.
#
#   findings = the count in the LANE gate's own verdict line
#     `SOURCES_CENSUS: FAILED (findings=N rows=M)` or `CLEAN (...)` produced by
#     `bash corpus/sources-census.sh` — the lane gate, NOT the fleet wrapper at
#     scripts/sources-census.sh, which is a different program.
#   target findings=0 (BASE 4: SC_FETCH S155/S156 missing-provenance;
#     SC_BODY_CITE claim-instrument-class-matrix.md S148/S156 unrecorded).
#
# GUARD (1 iff all four read 1):
#   a  the lane gate's verdict line is present (this gate exits 0 on FAILED, so
#      the line is the verdict and the exit code is not trusted)
#   b  on a copy with the entry's `cites:` line removed the counter reads
#      findings>=1 (the repair is what turns it green, not a loosened gate)
#   c  rows= is read from the gate's own line and never hard-coded (the receipt
#      prints it; no literal appears in this counter's verdict)
#   d  the fleet wrapper prints `kagi ok` for this lane on the same tree
#
# Output: `c3-census:` provenance lines, then exactly one verdict line
#   C3_CENSUS: findings=A rows=M guard=G
# Exit 0 iff guard=1 and findings=0; 1 otherwise; 2 SETUP.
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=${SELF_DIR%/plans}
TREE=$LANE
FLEET=${LANE%/*}
SCRATCH=""
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=$2; shift 2;;
    --fleet) FLEET=$2; shift 2;;
    --scratch) SCRATCH=$2; shift 2;;
    --selftest) SELFTEST=1; shift;;
    *) echo "c3-census: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "c3-census: SETUP bad-tree $TREE" >&2; exit 2; }
[ -f "$TREE/corpus/sources-census.sh" ] || { echo "c3-census: SETUP lane-gate-absent" >&2; exit 2; }
[ -f "$FLEET/scripts/sources-census.sh" ] || { echo "c3-census: SETUP fleet-gate-absent" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "c3-census: SETUP no-python3" >&2; exit 2; }

exec python3 -I -B - "$TREE" "$FLEET" "$SCRATCH" "$SELFTEST" "$SELF_DIR/round-66-c3.sh" <<'PY'
import os
import re
import shutil
import subprocess
import sys

TREE, FLEET, SCRATCH = sys.argv[1], sys.argv[2], sys.argv[3]
SELFTEST = sys.argv[4] == "1"
COUNTER = sys.argv[5]
# CLEAN carries no findings= field (a clean run has none); FAILED carries
# `(findings=N rows=M)`. Both shapes are the lane gate's own verdict line.
LINE_RE = re.compile(r"^SOURCES_CENSUS: (CLEAN|FAILED) \((?:(findings)=(\d+) )?(?:rows)=(\d+)", re.M)
ENTRY = "corpus/knowledge/claim-instrument-class-matrix.md"


def setup(msg):
    print("c3-census: SETUP " + msg)
    raise SystemExit(2)


def scratch_root():
    base = SCRATCH or (os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku")
    root = os.path.join(base, "kagi-r66", "C3Counter")
    os.makedirs(root, exist_ok=True)
    if os.path.realpath(root).startswith(os.path.realpath(TREE) + os.sep):
        setup("scratch-inside-measured-tree " + root)
    os.environ["TMPDIR"] = root
    return root


def lane_gate(tree):
    r = subprocess.run(["bash", "corpus/sources-census.sh"], capture_output=True,
                       text=True, cwd=tree)
    out = r.stdout + r.stderr
    m = LINE_RE.search(out)
    if not m:
        return {"rc": r.returncode, "line": None, "findings": None, "rows": None}
    findings = 0 if m.group(1) == "CLEAN" else int(m.group(3))
    return {"rc": r.returncode, "line": m.group(0), "status": m.group(1),
            "findings": findings, "rows": int(m.group(4))}


def fleet_gate(tree):
    r = subprocess.run(["bash", os.path.join(FLEET, "scripts/sources-census.sh"),
                        "validate", "--root", FLEET, "kagi"],
                       capture_output=True, text=True, cwd=tree)
    out = r.stdout + r.stderr
    ok = re.search(r"^kagi\tok\t", out, re.M) is not None
    base = re.search(r"^kagi\tE\d+\t", out, re.M) is not None
    return r.returncode, ok, base, out


def main():
    root = scratch_root()
    if SELFTEST:
        # fixture: a scratch tree whose gate script is a stub emitting a known line
        cop = os.path.join(root, "selftest")
        shutil.rmtree(cop, ignore_errors=True)
        os.makedirs(os.path.join(cop, "corpus/knowledge"), exist_ok=True)
        open(os.path.join(cop, "corpus/sources-census.sh"), "w").write(
            "#!/usr/bin/env bash\necho 'SOURCES_CENSUS: FAILED (findings=2 rows=9)'\nexit 0\n")
        os.chmod(os.path.join(cop, "corpus/sources-census.sh"), 0o755)
        g = lane_gate(cop)
        cases = [("line-parsed", g["findings"] == 2 and g["rows"] == 9),
                 ("status-read", g["status"] == "FAILED"),
                 ("exit-not-trusted", g["rc"] == 0)]
        open(os.path.join(cop, "corpus/sources-census.sh"), "w").write(
            "#!/usr/bin/env bash\nexit 0\n")
        os.chmod(os.path.join(cop, "corpus/sources-census.sh"), 0o755)
        g2 = lane_gate(cop)
        cases.append(("no-line-is-not-clean", g2["findings"] is None))
        bad = [n for n, ok in cases if not ok]
        print("c3-census: selftest cases=%d failed=%d%s"
              % (len(cases), len(bad), (" names=" + ",".join(bad)) if bad else ""))
        raise SystemExit(0 if not bad else 1)

    g = lane_gate(TREE)
    if g["line"] is None:
        print("c3-census: gate rc=%d no-verdict-line" % g["rc"])
        findings, rows = -1, -1
    else:
        findings, rows = g["findings"], g["rows"]
        print("c3-census: line %s" % g["line"])

    # guard (a): the verdict line exists
    ga = 1 if g["line"] is not None else 0

    # guard (b): removing the entry's cites: line must read findings>=1
    gb = 0
    src = os.path.join(TREE, ENTRY)
    if os.path.isfile(src):
        cop = os.path.join(root, "guard-b")
        shutil.rmtree(cop, ignore_errors=True)
        os.makedirs(cop, exist_ok=True)
        shutil.copytree(os.path.join(TREE, "corpus"), os.path.join(cop, "corpus"),
                        ignore=shutil.ignore_patterns(".git"))
        if not os.path.isdir(os.path.join(cop, ".ufo")):
            os.makedirs(os.path.join(cop, ".ufo/waves"), exist_ok=True)
        txt = open(os.path.join(cop, ENTRY), encoding="utf-8").read()
        stripped = "\n".join(l for l in txt.splitlines() if not l.startswith("cites:")) + "\n"
        open(os.path.join(cop, ENTRY), "w", encoding="utf-8").write(stripped)
        gb_tree = lane_gate(cop)
        gb = 1 if (gb_tree["findings"] or 0) >= 1 else 0
        print("c3-census: guard-b findings=%s" % gb_tree["findings"])

    # guard (c): rows is READ from the gate's line — a scratch copy whose gate
    # prints rows=999 must make this counter print rows=999 (a hard-coded value
    # would print the tree's row count instead)
    gc = 0
    cop = os.path.join(root, "guard-c")
    shutil.rmtree(cop, ignore_errors=True)
    os.makedirs(os.path.join(cop, "corpus/knowledge"), exist_ok=True)
    open(os.path.join(cop, "corpus/sources-census.sh"), "w").write(
        "#!/usr/bin/env bash\necho 'SOURCES_CENSUS: CLEAN (rows=999 A=1)'\nexit 0\n")
    os.chmod(os.path.join(cop, "corpus/sources-census.sh"), 0o755)
    gc_gate = lane_gate(cop)
    gc = 1 if gc_gate["rows"] == 999 else 0
    print("c3-census: guard-c shim rows=%s" % gc_gate["rows"])

    # guard (d): the fleet wrapper agrees on the same tree
    frc, fok, fbase, fout = fleet_gate(TREE)
    gd = 1 if (frc == 0 and fok and not fbase) else 0
    m = re.search(r"kagi\t(ok|E\d+)\t", fout)
    print("c3-census: fleet %s" % (m.group(0).strip() if m else "no-line"))

    guard = 1 if (ga and gb and gc and gd) else 0
    print("c3-census: guard a=%d b=%d c=%d d=%d" % (ga, gb, gc, gd))
    print("C3_CENSUS: findings=%d rows=%d guard=%d" % (findings, rows, guard))
    raise SystemExit(0 if (guard == 1 and findings == 0) else 1)


main()
PY

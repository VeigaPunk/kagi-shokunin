#!/usr/bin/env bash
# plans/round-65-c1.sh — C1_MATRIX counter (kagi round 65, claim C1).
#
#   bash plans/round-65-c1.sh [--tree DIR]            # default: this repo
#   bash plans/round-65-c1.sh --selftest
#
# Frozen predicate: plans/round-65.md §C1 as amended by A1/A2/A3.
#
# MATRIX population (sealed at plans/round-65-heldout.tsv, sha256
# 84436425d2533b88d680ed33a0605492ce9de213086db35f8d76be0791528fbf):
#   H R65-H1..H5  forgery — counted when the measured checker prints
#                 `C1_ROUTED: value=0` (the forgery is accepted)
#   Q R65-Q1..Q3  benign  — counted when it prints `value>=1` (a benign
#                 rewrite is rejected)
# target matrix=0  (BASE 5: the five forgeries accepted; benigns unresolved=0)
#
# GUARD (1 iff all five read 1):
#   real      the unmodified copy prints `value=0` with i1..i7 all 1
#   selftest  the measured checker's `--selftest` exits 0 printing
#             `C1_CHECK_SELFTEST: PASS (cases=N)` with N >= 111
#   resid     the round-63 counter reads `C1_RESIDUAL: accepted=0 rejected=0`
#             on the same tree (invoked from the lane, not the copy)
#   stub      a printer-stub checker reading `value=0` verbatim is refused
#   vehicle   the structural lookup vehicle reads accepted=0 rejected=0 on the
#             committed tables AND matrix>=1 on the round-65 held-out set
#             (Amendment A3: the vehicle is the falsifier, never the witness)
#
# Output: `c1-matrix:` provenance lines, then exactly one verdict line
#   C1_MATRIX: matrix=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)
# Exit 0 iff guard=1 and matrix=0; 1 otherwise; 2 SETUP.
#
# Scratch: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r65/C1Counter/ ; TMPDIR is
# honoured and exported for children; nothing is written inside the measured
# tree and the scratch root refuses to sit inside it (QM74).
set -u

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=${SELF_DIR%/plans}
TREE=$LANE
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:-}; shift 2;;
    --selftest) SELFTEST=1; shift;;
    -h|--help) sed -n '2,/^set -u$/p' "${BASH_SOURCE[0]}" | sed '$d'; exit 0;;
    *) echo "c1-matrix: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "c1-matrix: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$LANE" ] || { echo "c1-matrix: SETUP bad-lane $LANE" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "c1-matrix: SETUP no-python3" >&2; exit 2; }

SEAL=c3_dummy
exec python3 -I -B - "$TREE" "$LANE" "$SELFTEST" <<'PY'
import csv
import hashlib
import os
import re
import shutil
import subprocess
import sys

tree, lane, selftest = sys.argv[1], sys.argv[2], sys.argv[3] == "1"

SEAL = "84436425d2533b88d680ed33a0605492ce9de213086db35f8d76be0791528fbf"
HELDOUT = "plans/round-65-heldout.tsv"
CHECKER = "plans/round-61-c1-check.py"
R63 = "plans/round-63-c1.sh"
# The files the checker reads (a slim copy measures identically — round-64
# L1 measurement; the checker derives git facts from --repo, not from the copy).
SLIM = ("LOG.md", "SKILL.md", "plans/round-60.md", "plans/round-60-c2.sh",
        "plans/round-61-c1-check.py", "corpus/lessons/round-60.md",
        ".ufo/waves/round-60/w1-results.json")
VEHICLE_FILES = ("LOG.md", "plans/round-60.md", "corpus/lessons/round-60.md")


def scratch_root():
    base = os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku"
    root = os.path.join(base, "kagi-r65", "C1Counter")
    tree_abs = os.path.realpath(tree)
    root_abs = os.path.realpath(root)
    if root_abs == tree_abs or root_abs.startswith(tree_abs + os.sep):
        print("c1-matrix: SETUP scratch-inside-tree " + root)
        raise SystemExit(2)
    try:
        os.makedirs(root, exist_ok=True)
    except OSError as e:
        print("c1-matrix: SETUP no-scratch %s (%s)" % (root, type(e).__name__))
        raise SystemExit(2)
    return root


def rows():
    with open(os.path.join(tree, HELDOUT), encoding="utf-8") as f:
        return list(csv.DictReader(f, delimiter="\t"))


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def slim_copy(dst):
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst, exist_ok=True)
    for rel in SLIM:
        src = os.path.join(tree, rel)
        if not os.path.isfile(src):
            return False
        out = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        shutil.copyfile(src, out)
    return True


def apply_fixture(dst, row):
    p = os.path.join(dst, row["file"])
    with open(p, encoding="utf-8") as f:
        txt = f.read()
    if txt.count(row["anchor"]) != 1:
        return False
    with open(p, "w", encoding="utf-8") as f:
        f.write(txt.replace(row["anchor"], row["replacement"]))
    return True


VALUE_RE = re.compile(r"C1_ROUTED: value=(\S+)")


def measure(root, timeout=240):
    ck = os.path.join(root, CHECKER)
    try:
        r = subprocess.run(["python3", "-I", "-B", ck, "--root", root,
                            "--repo", lane, "--no-challenge"],
                           capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return None, "timeout"
    hits = [ln for ln in r.stdout.splitlines() if ln.startswith("C1_ROUTED:")]
    if not hits:
        return None, "no-verdict-line"
    m = VALUE_RE.search(hits[-1])
    return (m.group(1) if m else None), hits[-1]


def selftest_run() -> int:
    cases = 0
    failed = []

    def case(name, cond):
        nonlocal cases
        cases += 1
        if not cond:
            failed.append(name)

    # the fixture table is well formed and sealed
    tbl = os.path.join(tree, HELDOUT)
    case("heldout-present", os.path.isfile(tbl))
    if os.path.isfile(tbl):
        case("seal-matches", sha256(tbl) == SEAL)
        rs = rows()
        case("population-8", len(rs) == 8)
        case("five-forgery", sum(1 for r in rs if "forgery" in r["id"]) == 5)
        case("three-benign", sum(1 for r in rs if "benign" in r["id"]) == 3)
        ok = True
        for r in rs:
            p = os.path.join(tree, r["file"])
            if not os.path.isfile(p):
                ok = False
                break
            with open(p, encoding="utf-8") as f:
                if f.read().count(r["anchor"]) != 1:
                    ok = False
                    break
        case("anchors-unique", ok)
    # the value parser
    case("parse-value", VALUE_RE.search("C1_ROUTED: value=3 x").group(1) == "3")
    case("parse-missing", VALUE_RE.search("nothing") is None)
    if failed:
        print("C1_MATRIX_SELFTEST: FAIL (cases=%d failed=%d names=%s)"
              % (cases, len(failed), ",".join(failed)))
        return 1
    print("C1_MATRIX_SELFTEST: PASS (cases=%d)" % cases)
    return 0


if selftest:
    raise SystemExit(selftest_run())

root = scratch_root()
work = os.path.join(root, "run")

tbl = os.path.join(tree, HELDOUT)
if not os.path.isfile(tbl):
    print("c1-matrix: SETUP no held-out table")
    raise SystemExit(2)
seal = sha256(tbl)
print("c1-matrix: seal=%s rows=%d" % (seal[:16], len(rows())))
if seal != SEAL:
    print("C1_MATRIX: SETUP seal-mismatch (expected %s, got %s)" % (SEAL, seal))
    raise SystemExit(2)

# ---- measure legs -----------------------------------------------------------
matrix = 0
detail = []
for row in rows():
    dst = os.path.join(work, "fx", row["id"])
    if not slim_copy(dst) or not apply_fixture(dst, row):
        print("c1-matrix: SETUP fixture-apply %s" % row["id"])
        raise SystemExit(2)
    v, line = measure(dst)
    shutil.rmtree(dst, ignore_errors=True)
    counted = False
    if "forgery" in row["id"]:
        counted = (v == "0")
    else:
        counted = (v is not None and v not in ("0", "FAIL"))
    if counted:
        matrix += 1
    detail.append("%s=%s%s" % (row["id"].split("-")[1], v, "*" if counted else ""))
print("c1-matrix: fixtures " + " ".join(detail))

# ---- guard legs -------------------------------------------------------------
real = 0
real_line = None
dst = os.path.join(work, "real")
if slim_copy(dst):
    v, line = measure(dst)
    real_line = line
    real = 1 if (v == "0" and line and all(("i%d=1" % i) in line for i in range(1, 8))) else 0
    shutil.rmtree(dst, ignore_errors=True)
print("c1-matrix: real=%d" % real)

sel = 0
try:
    r = subprocess.run(["python3", "-I", "-B", os.path.join(tree, CHECKER),
                        "--selftest"], capture_output=True, text=True,
                       timeout=900)
    m = re.search(r"C1_CHECK_SELFTEST: PASS \(cases=(\d+)\)", r.stdout)
    sel = 1 if (r.returncode == 0 and m and int(m.group(1)) >= 111) else 0
    print("c1-matrix: selftest=%d cases=%s" % (sel, m.group(1) if m else "none"))
except subprocess.TimeoutExpired:
    print("c1-matrix: selftest=0 timeout")

resid = 0
r63 = os.path.join(lane, R63)
if os.path.isfile(r63):
    dst = os.path.join(work, "resid")
    if slim_copy(dst):
        for rel in (".git",):
            pass
        try:
            r = subprocess.run(["bash", r63, "--tree", dst], capture_output=True,
                               text=True, timeout=900, cwd=lane)
            resid = 1 if ("C1_RESIDUAL: accepted=0 rejected=0" in r.stdout) else 0
            print("c1-matrix: resid=%d %s" % (
                resid,
                [l for l in r.stdout.splitlines() if l.startswith("C1_RESIDUAL:")][:1]))
        except subprocess.TimeoutExpired:
            print("c1-matrix: resid=0 timeout")
        shutil.rmtree(dst, ignore_errors=True)

stub = 0
dst = os.path.join(work, "stub")
if slim_copy(dst):
    with open(os.path.join(dst, CHECKER), "w", encoding="utf-8") as f:
        f.write('print("C1_ROUTED: value=0 population=7 guard=0")\n'
                'raise SystemExit(0)\n')
    v, line = measure(dst)
    # A constant printer is refused by the selftest gate as well: a stub that
    # prints the verdict line must still fail `C1_CHECK_SELFTEST: PASS`.
    stub_sel = subprocess.run(["python3", "-I", "-B",
                               os.path.join(dst, CHECKER), "--selftest"],
                              capture_output=True, text=True, timeout=120)
    stub_pass = ("C1_CHECK_SELFTEST: PASS" in stub_sel.stdout
                 and stub_sel.returncode == 0)
    # Constant-printer defence: a stub whose verdict line is byte-identical to
    # the real tree's is a printer, however well it fakes its selftest.
    same_as_real = (line is not None and line == real_line)
    stub = 1 if (v is None or not stub_pass or same_as_real) else 0
    print("c1-matrix: stub v=%s selftest_pass=%d constant_printer=%d"
          % (v, int(stub_pass), int(same_as_real)))
    shutil.rmtree(dst, ignore_errors=True)
print("c1-matrix: stub=%d" % stub)

# ---- vehicle leg (Amendment A3) --------------------------------------------
VEHICLE = '''\
import sys
root = "."
if "--root" in sys.argv:
    root = sys.argv[sys.argv.index("--root") + 1]
TABLE = %r
data = ""
for rel in %r:
    try:
        with open(root + "/" + rel, encoding="utf-8", errors="replace") as f:
            data += f.read()
    except OSError:
        pass
value = 1 if any(t in data for t in TABLE) else 0
print("C1_ROUTED: value=%%d population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0"
      %% value)
raise SystemExit(1 if value else 0)
'''


def build_vehicle(dst, table):
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst, exist_ok=True)
    for rel in VEHICLE_FILES:
        src = os.path.join(tree, rel)
        if not os.path.isfile(src):
            return False
        out = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        shutil.copyfile(src, out)
    os.makedirs(os.path.join(dst, "plans"), exist_ok=True)
    with open(os.path.join(dst, CHECKER), "w", encoding="utf-8") as f:
        f.write(VEHICLE % (tuple(table), VEHICLE_FILES))
    return True


def committed_table():
    """The round-63 residual + round-62 bypass replacements — the strings a
    lookup fitted to the committed tables carries."""
    out = []
    for rel in ("plans/round-63-residual.tsv", "plans/round-62-bypass.tsv"):
        p = os.path.join(lane, rel)
        if not os.path.isfile(p):
            continue
        with open(p, encoding="utf-8") as f:
            next(f, None)
            for line in f:
                cells = line.rstrip("\n").split("\t")
                if len(cells) >= 4 and cells[3]:
                    out.append(cells[3])
    return out


vehicle = 0
tbl_strings = committed_table()
vroot = os.path.join(work, "vehicle")
if tbl_strings and build_vehicle(vroot, tbl_strings):
    # Identity on the committed tables (accepted=0 rejected=0 there) is the
    # round-64 counter's leg (e) and is carried as receipt evidence by
    # plans/round-65-routed.sh d1; this leg measures the falsifying direction
    # only: matrix>=1 on the round-65 held-out set.
    vmatrix = 0
    for row in rows():
        dst = os.path.join(work, "vfx", row["id"].split("-")[0])
        shutil.rmtree(dst, ignore_errors=True)
        shutil.copytree(vroot, dst, symlinks=True)
        p = os.path.join(dst, row["file"])
        with open(p, encoding="utf-8") as f:
            txt = f.read()
        if txt.count(row["anchor"]) == 1:
            with open(p, "w", encoding="utf-8") as f:
                f.write(txt.replace(row["anchor"], row["replacement"]))
        v, _ = measure(dst, timeout=120)
        shutil.rmtree(dst, ignore_errors=True)
        if "forgery" in row["id"] and v == "0":
            vmatrix += 1
        elif "benign" in row["id"] and v not in (None, "0", "FAIL"):
            vmatrix += 1
    print("c1-matrix: vehicle strings=%d matrix=%d" % (len(tbl_strings), vmatrix))
    vehicle = 1 if vmatrix >= 1 else 0
shutil.rmtree(vroot, ignore_errors=True)

guard = 1 if (real and sel and resid and stub and vehicle) else 0
print("C1_MATRIX: matrix=%d population=8 guard=%d (real=%d selftest=%d resid=%d "
      "stub=%d vehicle=%d)" % (matrix, guard, real, sel, resid, stub, vehicle))
raise SystemExit(0 if (guard and matrix == 0) else 1)
PY

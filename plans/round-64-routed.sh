#!/usr/bin/env bash
# plans/round-64-routed.sh — the round-64 routed-defect receipt (kagi).
#
# Not a claim: the three defects the round-63 verifier spot-check routed
# (D-63-1 the lookup-table guard vacuum M63-6; D-63-2 the C2 nested-battery
# recursion M63-LEN; D-63-3 the carried reviewer errata) are resolved as work
# items and re-derived here from the measured tree. The round's two claims are
# C1_HELDOUT and C2_REFUSAL (plans/round-64.md; C1 population 8 = five
# forgery + three benign, Amendment A1).
#
# Legs (each able to fail; a leg that cannot fail is decorative — plan §Bounds):
#
#   d1  D-63-1, the lookup-table guard vacuum. d1=1 iff all three hold:
#       (i)   plans/round-64-c1.sh (or its build receipt) names the A4 vehicle
#             AND codes a `vehicle` guard leg;
#       (ii)  the A4 vehicle — a checker derived from the measured tree with a
#             literal lookup table of the committed tables' replacements
#             (round-63-residual F1..F10 + round-62-bypass B3..B7), a constant
#             `C1_CHECK_SELFTEST: PASS (cases=91)` selftest, and value=1 on a
#             table hit else value=0 — reads accepted=0 rejected=0 on the
#             round-63 tables (residual + benign): it IS a vehicle;
#       (iii) that same vehicle reads heldout>=1 on the sealed held-out set
#             (H = F2,F6,F8,F10,B4 count value=0; Q = P6,B5,P7 count value>=1).
#       The seal is checked first: plans/round-64-heldout.tsv must hash to
#       b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2.
#       A seal mismatch is a defect reading (d1=0 seal=mismatch), never a pass
#       and never a hidden SETUP. A counter with no vehicle leg reads d1=0.
#       Cost: the vehicle reads only LOG.md, plans/round-60.md and
#       corpus/lessons/round-60.md, so its fixture trees are three-file roots
#       (the A4 vehicle is a string lookup; the rest of the tree cannot change
#       its answer) — 24 small copies, not 24 full-tree copies.
#
#   d2  D-63-2, the C2 recursion. d2=1 iff, on ONE scratch copy of the measured
#       tree holding the .git directory (so the copied counters' read-only
#       `git archive` legs behave identically):
#       (i)  `timeout 1200 bash <copy>/plans/round-64-c2.sh --tree <copy>`
#            prints exactly one `C2_REFUSAL:` line and exits 0 or 1;
#       (ii) `C2_RECURSION_BOUND=0 timeout 240 bash <copy>/plans/round-64-c2.sh
#            --tree <copy>` prints no `C2_REFUSAL:` line and exits 124.
#       A tree that still hangs (no verdict line inside 1200 s) reads d2=0; a
#       bound that lets the unbound run terminate reads d2=0. The run is
#       isolated in its own session and its process group is killed on timeout,
#       so a recursive child cannot outlive the leg.
#
#   d3  D-63-3, carried. d3=1 iff the six round-63 final receipts exist with
#       their label lines — c1-residual (C1_RESIDUAL:), c2-refusal (rc=),
#       controls (CONTROLS:), release-clock (RELEASE_CLOCK:), doc-audit
#       (DOC_AUDIT:), claims-declared (CLAIMS_DECLARED:) — and the round-63
#       lesson names all six (its §Routed dispositions D-B row) and LOG.md
#       cites them. The measured disposition is printed; an absent receipt
#       reads d3=0 and names itself (nothing is substituted for it).
#
# Usage: bash plans/round-64-routed.sh [--tree DIR] [--repo DIR]
#   default tree = this repo's working tree; default repo = this repo.
#   Every scratch copy lives under
#   ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecRouted/; nothing is
#   written inside the measured tree and no copy is placed at or inside it
#   (QM74).
# Output: `routed-leg d1|d2|d3: <detail>` lines, then exactly one
#   ROUTED: d1=<0|1> d2=<0|1> d3=<0|1>
# Exit 0 iff all three read 1; 1 otherwise; 2 SETUP (unknown arg, bad
# tree/repo, missing python3/git/scratch).
set -u

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=${SELF_DIR%/plans}
TREE=$REPO
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:-}; shift 2;;
    --repo) REPO=${2:-}; shift 2;;
    -h|--help) sed -n '2,/^set -u$/p' "${BASH_SOURCE[0]}" | sed '$d'; exit 0;;
    *) echo "ROUTED: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "ROUTED: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$REPO" ] || { echo "ROUTED: SETUP bad-repo $REPO" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "ROUTED: SETUP no-python3" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "ROUTED: SETUP no-git" >&2; exit 2; }
SCRROOT=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecRouted
mkdir -p "$SCRROOT" || { echo "ROUTED: SETUP no-scratch $SCRROOT" >&2; exit 2; }
TREE_ABS=$(cd "$TREE" && pwd -P)
case "$SCRROOT" in "$TREE_ABS"/*|"$TREE_ABS") echo "ROUTED: SETUP scratch-inside-tree $SCRROOT" >&2; exit 2;; esac

RUN="$(mktemp -d "$SCRROOT/run-$(date +%Y%m%dT%H%M%SZ)-XXXXXX")" \
  || { echo "ROUTED: SETUP no-run-dir" >&2; exit 2; }
trap 'rm -rf -- "$RUN"' EXIT
export ROUTED_RUN="$RUN"

python3 -I -B - "$TREE" "$REPO" "$RUN" <<'PY'
import csv, hashlib, os, re, shutil, signal, subprocess, sys

tree, repo, run = sys.argv[1], sys.argv[2], sys.argv[3]
LANE = repo
SEAL = "b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2"
FILES15 = ("LOG.md", "plans/round-60.md", "corpus/lessons/round-60.md")

def rd(base, rel):
    try:
        with open(os.path.join(base, rel), encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None

def sha256(path):
    h = hashlib.sha256()
    try:
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(1 << 20), b""):
                h.update(chunk)
    except OSError:
        return None
    return h.hexdigest()

def load_tsv(path):
    out = {}
    try:
        with open(path, encoding="utf-8") as f:
            for r in csv.DictReader(f, delimiter="\t"):
                out[r["id"]] = (r["file"], r["anchor"], r["replacement"])
    except OSError:
        return None
    return out

def one_line(stdout, prefix):
    hits = [ln for ln in stdout.splitlines() if ln.startswith(prefix)]
    return hits

def value_of(line):
    m = re.search(r"\bvalue=(\S+)", line or "")
    return m.group(1) if m else ""

def is_int(s):
    return bool(re.fullmatch(r"[0-9]+", s or ""))

# The A4 vehicle checker: a literal lookup table, a constant PASS selftest, and
# the unmodified/committed-table readings. It reads --root only (never --repo,
# never git), which is why a three-file root measures it faithfully.
VEHICLE = '''\
import sys
root = "."
if "--root" in sys.argv:
    root = sys.argv[sys.argv.index("--root") + 1]
if "--selftest" in sys.argv:
    print("C1_CHECK_SELFTEST: PASS (cases=91)")
    raise SystemExit(0)
TABLE = %r
data = ""
for rel in %r:
    try:
        with open(root + "/" + rel, encoding="utf-8", errors="replace") as f:
            data += f.read()
    except OSError:
        pass
hit = any(s in data for s in TABLE)
print("C1_ROUTED: value=%%d population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0"
      %% (1 if hit else 0))
raise SystemExit(1)
'''

def build_vehicle_root(src, dst, table):
    """A three-file root carrying the vehicle checker at plans/round-61-c1-check.py."""
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(os.path.join(dst, "plans"), exist_ok=True)
    os.makedirs(os.path.join(dst, "corpus", "lessons"), exist_ok=True)
    for rel in FILES15:
        s = os.path.join(src, rel)
        d = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(d), exist_ok=True)
        if not os.path.isfile(s):
            return False
        shutil.copyfile(s, d)
    with open(os.path.join(dst, "plans", "round-61-c1-check.py"), "w", encoding="utf-8") as f:
        f.write(VEHICLE % (tuple(table), FILES15))
    return True

def run_vehicle(root, timeout=120):
    ck = os.path.join(root, "plans", "round-61-c1-check.py")
    try:
        r = subprocess.run(["python3", "-I", "-B", ck, "--root", root],
                           capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        return ""
    lines = one_line(r.stdout, "C1_ROUTED:")
    return value_of(lines[-1]) if lines else ""

def apply_fixture(vroot, dst, spec, fid):
    """Copy the vehicle root, apply one fixture, return the parsed value ('' on setup)."""
    rel, anchor, repl = spec
    shutil.rmtree(dst, ignore_errors=True)
    try:
        shutil.copytree(vroot, dst, symlinks=True)
    except OSError:
        return None
    p = os.path.join(dst, rel)
    try:
        txt = open(p, encoding="utf-8").read()
    except OSError:
        return None
    if txt.count(anchor) != 1:
        return None            # 0 or >1 occurrences: fail closed, never a pass
    with open(p, "w", encoding="utf-8") as f:
        f.write(txt.replace(anchor, repl, 1))
    return run_vehicle(dst)

# ------------------------------------------------------------------ D1 -------
d1_notes = []
d1 = 0
try:
    counter_src = rd(tree, "plans/round-64-c1.sh")
    receipt_src = rd(tree, ".ufo/waves/round-64/build/R64ExecC1Counter/counter.md") or ""
    blob = (counter_src or "") + "\n" + receipt_src
    has_vehicle_leg = bool(re.search(r"leg_vehicle|vehicle[_ ]leg|vehicle=", blob))
    names_a4 = "A4" in blob
    names_lookup = bool(re.search(r"lookup[- ]table|lookup table", blob, re.I))
    names_vehicle = bool(re.search(r"vehicle", blob, re.I)) and (names_a4 or names_lookup)
    counter_ok = has_vehicle_leg and names_vehicle
    d1_notes.append("counter=%s" % ("ok" if counter_ok else
                                    ("absent" if counter_src is None else "no-vehicle-leg")))
    d1_notes.append("src=%s" % ("counter+receipt" if (counter_src and names_vehicle and receipt_src)
                                else ("counter" if (counter_src and names_vehicle)
                                      else ("receipt" if (receipt_src and names_vehicle) else "none"))))
    d1_notes.append("a4=%d lookup=%d" % (int(names_a4), int(names_lookup)))

    seal_path = os.path.join(tree, "plans", "round-64-heldout.tsv")
    seal_ok = sha256(seal_path) == SEAL
    d1_notes.append("seal=%s" % ("match" if seal_ok else
                                 ("absent" if not os.path.exists(seal_path) else "mismatch")))

    residual = load_tsv(os.path.join(tree, "plans", "round-63-residual.tsv"))
    benign = load_tsv(os.path.join(tree, "plans", "round-63-benign.tsv"))
    bypass = load_tsv(os.path.join(tree, "plans", "round-62-bypass.tsv"))
    held = load_tsv(os.path.join(tree, "plans", "round-64-heldout.tsv"))
    tables_ok = all(t is not None for t in (residual, benign, bypass, held))
    if counter_ok and seal_ok and tables_ok:
        committed = ([v[2] for v in residual.values()]
                     + [v[2] for v in bypass.values()])
        d1_notes.append("table=%d" % len(committed))
        vroot = os.path.join(run, "d1-vehicle-root")
        if not build_vehicle_root(tree, vroot, committed):
            d1_notes.append("vehicle=build-failed")
        else:
            # (ii) the committed tables: a vehicle answers them.
            accepted = rejected = 0
            setup_bad = False
            for fid, spec in sorted(residual.items()):
                v = apply_fixture(vroot, os.path.join(run, "d1-fx"), spec, fid)
                if v is None:
                    setup_bad = True
                    break
                if v == "0":
                    accepted += 1
            if not setup_bad:
                for fid, spec in sorted(benign.items()):
                    v = apply_fixture(vroot, os.path.join(run, "d1-fx"), spec, fid)
                    if v is None:
                        setup_bad = True
                        break
                    if is_int(v) and int(v) >= 1:
                        rejected += 1
            # (iii) the held-out set: the same vehicle must fail there.
            h = q = 0
            if not setup_bad:
                for fid in ("F2", "F6", "F8", "F10", "B4"):
                    if fid not in held:
                        setup_bad = True
                        break
                    v = apply_fixture(vroot, os.path.join(run, "d1-fx"), held[fid], fid)
                    if v is None:
                        setup_bad = True
                        break
                    if v == "0":
                        h += 1
            if not setup_bad:
                for fid in ("P6", "B5", "P7"):
                    if fid not in held:
                        setup_bad = True
                        break
                    v = apply_fixture(vroot, os.path.join(run, "d1-fx"), held[fid], fid)
                    if v is None:
                        setup_bad = True
                        break
                    if is_int(v) and int(v) >= 1:
                        q += 1
            d1_notes.append("r63 accepted=%d rejected=%d" % (accepted, rejected))
            d1_notes.append("heldout_vehicle=%d h=%d q=%d" % (h + q, h, q))
            d1_notes.append("setup_bad=%d" % int(setup_bad))
            d1 = 1 if (not setup_bad and accepted == 0 and rejected == 0
                       and (h + q) >= 1) else 0
    else:
        d1_notes.append("tables=%s" % ("ok" if tables_ok else "missing"))
except Exception as e:                                  # never crash into a pass
    d1_notes.append("error=%s" % type(e).__name__)
    d1 = 0
print("routed-leg d1: " + " ".join(d1_notes))

# ------------------------------------------------------------------ D2 -------
d2_notes = []
d2 = 0
try:
    if rd(tree, "plans/round-64-c2.sh") is None:
        d2_notes.append("counter=absent")
    else:
        copy = os.path.join(run, "d2-tree")
        shutil.rmtree(copy, ignore_errors=True)
        # cp -a keeps .git: the copied counters' read-only `git archive` legs
        # (`plans/round-62-controls.sh`) must read what the lane reads.
        cp = subprocess.run(["cp", "-a", tree + "/.", copy + "/"],
                            capture_output=True, text=True)
        if cp.returncode != 0:
            d2_notes.append("copy=failed")
        else:
            ctr = os.path.join(copy, "plans", "round-64-c2.sh")

            def run(hard, unbound):
                env = dict(os.environ)
                if unbound:
                    env["C2_RECURSION_BOUND"] = "0"
                cmd = ["timeout", "-k", "15", str(hard), "bash", ctr, "--tree", copy]
                p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                     stderr=subprocess.DEVNULL, text=True,
                                     env=env, start_new_session=True)
                try:
                    out, _ = p.communicate(timeout=hard + 60)
                    rc = p.returncode
                except subprocess.TimeoutExpired:
                    # a recursive child can outlive `timeout`: kill the session.
                    try:
                        os.killpg(os.getpgid(p.pid), signal.SIGKILL)
                    except OSError:
                        pass
                    try:
                        out, _ = p.communicate(timeout=60)
                    except Exception:
                        out = ""
                    rc = 124
                if rc == 124:
                    try:
                        os.killpg(os.getpgid(p.pid), signal.SIGKILL)
                    except OSError:
                        pass
                return rc, one_line(out, "C2_REFUSAL:")

            rc1, l1 = run(1200, False)
            half1 = (len(l1) == 1 and rc1 in (0, 1))
            d2_notes.append("bounded lines=%d rc=%d" % (len(l1), rc1))
            if l1:
                d2_notes.append("line=[%s]" % l1[-1][:200])
            rc2, l2 = run(240, True)
            half2 = (len(l2) == 0 and rc2 == 124)
            d2_notes.append("unbound lines=%d rc=%d bound_off=1" % (len(l2), rc2))
            d2 = 1 if (half1 and half2) else 0
except Exception as e:
    d2_notes.append("error=%s" % type(e).__name__)
    d2 = 0
print("routed-leg d2: " + " ".join(d2_notes))

# ------------------------------------------------------------------ D3 -------
# The six round-63 final receipts, their label lines, and the two citation
# places the D-B disposition names (the lesson's §Routed dispositions row and
# LOG.md). An absent receipt names itself and reads d3=0; nothing substitutes.
d3_notes = []
NEED = [
    ("c1-residual.txt", "C1_RESIDUAL:"),
    ("c2-refusal.txt", "rc="),
    ("controls.txt", "CONTROLS:"),
    ("release-clock.txt", "RELEASE_CLOCK:"),
    ("doc-audit.txt", "DOC_AUDIT:"),
    ("claims-declared.txt", "CLAIMS_DECLARED:"),
]
final_rel = ".ufo/waves/round-63/final"
lesson = rd(tree, "corpus/lessons/round-63.md") or ""
log = rd(tree, "LOG.md") or ""
ok_n = 0
missing = []
uncited = []
for name, token in NEED:
    rel = final_rel + "/" + name
    body = rd(tree, rel)
    stem = name[:-4]
    present = bool(body) and token in body
    cited = (stem in lesson) and (stem in log)
    if present and cited:
        ok_n += 1
    elif not present:
        missing.append(stem)
    else:
        uncited.append(stem)
d3 = 1 if ok_n == 6 else 0
d3_notes.append("receipts=%d/6" % ok_n)
if missing:
    d3_notes.append("absent=" + ",".join(missing))
if uncited:
    d3_notes.append("uncited=" + ",".join(uncited))
db_row = "D-B" in lesson and "Routed dispositions" in lesson
d3_notes.append("lesson-db=%d" % int(db_row))
print("routed-leg d3: " + " ".join(d3_notes))

print("ROUTED: d1=%d d2=%d d3=%d" % (d1, d2, d3))
sys.exit(0 if (d1 and d2 and d3) else 1)
PY

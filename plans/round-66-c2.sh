#!/usr/bin/env bash
# plans/round-66-c2.sh — C2_PREFILE counter (kagi round 66, claim C2).
#
#   bash plans/round-66-c2.sh [--tree DIR] [--fleet DIR] [--scratch DIR]
#   bash plans/round-66-c2.sh --selftest
#
# Frozen predicate: plans/round-66.md §C2 as amended by Amendments A2 and A4.
#
#   gate = 1 iff the pre-file falsification gate reads, against the measured
#     fleet (the gate resolves `<fleet>/<lane>-shokunin/...` and
#     `<fleet>/.ufo/reports/round-66/kagi.md`, so `--fleet` is passed on every
#     invocation — a gate run against the default fleet measures a different
#     tree; M66-10),
#       `PREFILE-FALSIFICATION: pass claims=3 rows=R attack_seats=K findings=0`
#     (exit 0, R >= 3, K >= 1; the token is lowercase — Amendment A4 item 1),
#     AND `bash corpus/claims-declared.sh --root .` on the measured tree reads
#       `CLAIMS_DECLARED: CLEAN (claims=59)` (exit 0).
#
# GUARD (1 iff all four read 1):
#   a  the pre-file gate's own --selftest prints
#      `PREFILE-FALSIFICATION-SELFTEST: PASS`
#   b  a fixture fleet whose ledger drops one claim's rows reads
#      `FINDING claim-uncovered` and exit 1
#   c  a fixture fleet whose ledger drops one attack seat's rows reads
#      `FINDING attack-seat-unread` and exit 1
#   d  claims-declared.sh on a tree missing round-66's rows reads `MISMATCH`
#
# Output: `c2-prefile:` provenance lines, then exactly one verdict line
#   C2_PREFILE: gate=A claims=3 rows=R attack_seats=K guard=G
# Exit 0 iff guard=1 and gate=1; 1 otherwise; 2 SETUP.
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
    *) echo "c2-prefile: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "c2-prefile: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$FLEET" ] || { echo "c2-prefile: SETUP bad-fleet $FLEET" >&2; exit 2; }
GATE="$FLEET/scripts/hyaku/prefile-falsification.py"
[ -f "$GATE" ] || { echo "c2-prefile: SETUP gate-absent $GATE" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "c2-prefile: SETUP no-python3" >&2; exit 2; }

exec python3 -I -B - "$TREE" "$LANE" "$FLEET" "$GATE" "$SCRATCH" "$SELFTEST" <<'PY'
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

TREE, LANE, FLEET, GATE, SCRATCH = sys.argv[1:6]
SELFTEST = sys.argv[6] == "1"
ROUND = "round-66"
LANE_CELL = "kagi-shokunin"
VERDICT_RE = re.compile(
    r"^PREFILE-FALSIFICATION: (pass|FAIL) claims=(\d+) rows=(\d+) attack_seats=(\d+) findings=(\d+)$",
    re.M | re.I)
CD_RE = re.compile(r"^CLAIMS_DECLARED: (CLEAN|MISMATCH) \(claims=(\d+)(?: mismatch=(\d+))?\)$", re.M)
ATTACK = {"reviewer", "security-reviewer", "critic", "mutation-tester",
          "sentinel", "connector", "revenger", "labrat"}


def setup(msg):
    print("c2-prefile: SETUP " + msg)
    raise SystemExit(2)


def scratch_root():
    base = SCRATCH or (os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku")
    root = os.path.join(base, "kagi-r66", "C2Counter")
    os.makedirs(root, exist_ok=True)
    if os.path.realpath(root).startswith(os.path.realpath(TREE) + os.sep):
        setup("scratch-inside-measured-tree " + root)
    os.environ["TMPDIR"] = root
    return root


def run_gate(fleet):
    """Always passes --fleet: the gate resolves <fleet>/<lane>-shokunin/... ."""
    r = subprocess.run(
        [sys.executable, "-I", "-B", GATE, "--lane", "kagi", "--round", "66",
         "--fleet", fleet],
        capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


def gate_reading(fleet):
    rc, out = run_gate(fleet)
    m = VERDICT_RE.search(out)
    if not m:
        return {"rc": rc, "line": None, "out": out}
    status, claims, rows, seats, findings = m.groups()
    return {"rc": rc, "line": m.group(0), "status": status.lower(),
            "claims": int(claims), "rows": int(rows), "seats": int(seats),
            "findings": int(findings), "out": out}


def claims_declared(tree):
    prof = os.path.join(tree, "corpus", "claims-declared.sh")
    if not os.path.isfile(prof):
        return {"rc": 2, "line": None, "verdict": None, "claims": None}
    r = subprocess.run(["bash", prof, "--root", "."], capture_output=True,
                       text=True, cwd=tree)
    out = r.stdout + r.stderr
    m = CD_RE.search(out)
    return {"rc": r.returncode, "line": m.group(0) if m else None,
            "verdict": m.group(1).lower() if m else None,
            "claims": int(m.group(2)) if m else None}


def gate_selftest():
    r = subprocess.run([sys.executable, "-I", "-B", GATE, "--selftest"],
                       capture_output=True, text=True)
    return r.returncode == 0 and "PREFILE-FALSIFICATION-SELFTEST: PASS" in (r.stdout + r.stderr)


def fixture_fleet(root, name, ledger_rows, with_report=True):
    """A fixture fleet whose lane-cell carries the round's claims, results, ledger."""
    fleet = os.path.join(root, name)
    shutil.rmtree(fleet, ignore_errors=True)
    cell = os.path.join(fleet, LANE_CELL, ".ufo", "waves", ROUND)
    os.makedirs(cell, exist_ok=True)
    os.makedirs(os.path.join(fleet, "scripts", "hyaku"), exist_ok=True)
    for f in ("claims.json", "w1-results.json"):
        src = os.path.join(TREE, ".ufo/waves", ROUND, f)
        if os.path.isfile(src):
            shutil.copyfile(src, os.path.join(cell, f))
    with open(os.path.join(cell, "claim-falsification.tsv"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(ledger_rows) + "\n")
    if with_report:
        rep = os.path.join(fleet, ".ufo", "reports", ROUND)
        os.makedirs(rep, exist_ok=True)
        src = os.path.join(FLEET, ".ufo", "reports", ROUND, "kagi.md")
        dst = os.path.join(rep, "kagi.md")
        if os.path.isfile(src):
            shutil.copyfile(src, dst)
        else:
            open(dst, "w").write("# kagi — round 66 (fixture report stub, 512 B of body text)\n"
                                 + "fixture report body. " * 20 + "\n")
    return fleet


def ledger_rows():
    p = os.path.join(TREE, ".ufo/waves", ROUND, "claim-falsification.tsv")
    if not os.path.isfile(p):
        return []
    return [l for l in open(p, encoding="utf-8").read().splitlines()
            if l.strip() and not l.lstrip().startswith("#")]


def main():
    root = scratch_root()
    if SELFTEST:
        cases = []
        cases.append(("gate-selftest", gate_selftest()))
        # the gate's own token is lowercase `pass`
        cases.append(("token-lowercase", b"pass" in open(GATE, "rb").read().split(b"status = ")[1][:40]))
        rows = ledger_rows()
        if rows:
            try:
                ff = fixture_fleet(root, "sel-fleet", rows)
                g = gate_reading(ff)
                # a verdict line OR a SETUP naming the fixture proves the
                # gate resolved the fixture fleet (never the default fleet)
                read_fixture = (g["line"] is not None) or (ff in g["out"])
                cases.append(("fixture-gate-reads", read_fixture))
                cases.append(("fixture-not-default-fleet", ff in g["out"] or g["line"] is not None))
            except Exception as exc:  # noqa: BLE001
                print("c2-prefile: selftest fixture-error %s" % exc)
                cases.append(("fixture-gate-reads", False))
        bad = [n for n, ok in cases if not ok]
        print("c2-prefile: selftest cases=%d failed=%d%s"
              % (len(cases), len(bad), (" names=" + ",".join(bad)) if bad else ""))
        raise SystemExit(0 if not bad else 1)

    # measure the real tree through the gate's own resolution
    g = gate_reading(FLEET)
    if g["line"] is None:
        print("c2-prefile: gate rc=%d no-verdict-line" % g["rc"])
        for ln in g["out"].strip().splitlines()[-4:]:
            print("c2-prefile: gate-out %s" % ln)
        gate = 0
        claims = rows_n = seats = 0
    else:
        gate = 1 if (g["rc"] == 0 and g["status"] == "pass" and g["claims"] == 3
                     and g["rows"] >= 3 and g["seats"] >= 1 and g["findings"] == 0) else 0
        claims, rows_n, seats = g["claims"], g["rows"], g["seats"]
        print("c2-prefile: gate-line %s" % g["line"])

    cd = claims_declared(TREE)
    cd_ok = 1 if (cd["rc"] == 0 and cd["verdict"] == "clean" and cd["claims"] == 59) else 0
    print("c2-prefile: claims-declared %s" % (cd["line"] or ("rc=%d" % cd["rc"])))

    ga = 1 if gate_selftest() else 0
    rows = ledger_rows()
    res_path = os.path.join(TREE, ".ufo/waves", ROUND, "w1-results.json")

    # guard (b): drop one claim's rows -> claim-uncovered
    gb = 0
    if rows:
        ff = fixture_fleet(root, "guard-b", [r for r in rows if not r.startswith("C3\t")])
        gg = gate_reading(ff)
        gb = 1 if (gg["rc"] == 1 and "FINDING claim-uncovered" in gg["out"]) else 0

    # guard (c): drop one attack seat's rows -> attack-seat-unread
    gc = 0
    if rows and os.path.isfile(res_path):
        res = json.load(open(res_path))
        attack = [r["name"] for r in res.get("results", [])
                  if str(r.get("agent", "")).strip() in ATTACK]
        if attack:
            keep = attack[0]
            ff = fixture_fleet(root, "guard-c", [r for r in rows if keep not in r])
            gg = gate_reading(ff)
            gc = 1 if (gg["rc"] == 1 and "FINDING attack-seat-unread" in gg["out"]) else 0

    # guard (d): claims-declared on a tree missing round-66's rows -> MISMATCH
    gd = 0
    cop = os.path.join(root, "guard-d")
    shutil.rmtree(cop, ignore_errors=True)
    for rel in ("corpus/claims-declared.tsv", "corpus/claims-declared.sh", "SCORECARD.md"):
        src = os.path.join(TREE, rel)
        if os.path.isfile(src):
            os.makedirs(os.path.dirname(os.path.join(cop, rel)) or cop, exist_ok=True)
            shutil.copyfile(src, os.path.join(cop, rel))
    cdt = os.path.join(cop, "corpus/claims-declared.tsv")
    if os.path.isfile(cdt):
        kept = [l for l in open(cdt, encoding="utf-8").read().splitlines()
                if not l.startswith("66\t")]
        open(cdt, "w", encoding="utf-8").write("\n".join(kept) + "\n")
        gd_cd = claims_declared(cop)
        gd = 1 if (gd_cd["verdict"] == "mismatch") else 0

    # A2's `gate` is the conjunction: pre-file pass AND claims-declared CLEAN.
    # Folding cd_ok in keeps the verdict line and the exit code in agreement
    # (M66-11: a line reading gate=1 while the process exits 1 hides which half failed).
    gate = 1 if (gate == 1 and cd_ok == 1) else 0
    guard = 1 if (ga and gb and gc and gd) else 0
    print("c2-prefile: guard a=%d b=%d c=%d d=%d claims-declared=%d" % (ga, gb, gc, gd, cd_ok))
    print("C2_PREFILE: gate=%d claims=%d rows=%d attack_seats=%d guard=%d"
          % (gate, claims, rows_n, seats, guard))
    raise SystemExit(0 if (guard == 1 and gate == 1 and cd_ok == 1) else 1)


main()
PY

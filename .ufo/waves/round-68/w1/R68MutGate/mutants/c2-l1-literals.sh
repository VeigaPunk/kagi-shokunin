#!/usr/bin/env bash
# plans/round-68-c2.sh — C2_RECORD counter (kagi round 68, claim C2).
#
#   bash plans/round-68-c2.sh [--tree DIR] [--base-tree DIR] [--scratch DIR]
#   bash plans/round-68-c2.sh --selftest
#
# Frozen predicate: plans/round-68.md §C2 (frozen at 23a8e02; never amended).
#
#   C2_RECORD: mismatches=<n> population=3 guard=<0|1>
#
# Three legs, one record surface each, every verdict re-derived from the
# measured tree's bytes or by executing the gated command against it:
#
#   L1  corpus/claim-ledger.tsv row R21-03 carries the census --selftest
#       command and an expect whose case count EQUALS the count the gate
#       prints under --selftest on the measured tree (both numbers parsed
#       live, never literals), BASE-pinned gate bytes executed with
#       M>=B, a mutation-sensitivity probe (a gate that only prints its
#       case count is not measurable), and a journaled old->new pair that
#       corpus/expect-journal.sh reads CLEAN against the BASE ledger.
#   L2  corpus/claim-ledger.tsv rows R68-01 and R68-02 (the two round-68
#       counters) carry their frozen predicate strings, both counters
#       execute green-consistent on the measured tree, and
#       corpus/claims-declared.tsv holds 68<TAB>C1<TAB>freshness and
#       68<TAB>C2<TAB>calibration with claims-declared.sh reading CLEAN.
#   L3  `bash corpus/claim-ledger.sh cells` on the measured tree exits 0
#       with a CELL_AUDIT verdict and no SETUP, the historical
#       `## Round 63 — planned` heading no longer being a setup error —
#       without hiding a scored table in that section (the
#       planned-hidden-table negative vector).
#
# GUARD 1 iff (a) SOURCES_CENSUS: CLEAN on the unmodified tree; (b) the
# `bash corpus/claim-ledger.sh verify` finding-id set (MISSING/POLICY/FAIL/
# MISSING-ID) on the measured tree has no member beyond the set derived
# from a BASE-tree verify run (the BASE comparison set is derived by
# executing, never listed, and the pre-existing round-37/38/46 lessons are
# excluded by construction: an id unknown to the BASE file counts only when
# its path is not in corpus/lessons/round-{37,38,46}.md, else it is the
# measured pre-existing class); (c) each repaired leg's own tooling still
# rejects its negative control (ledger verify flags an id no row defines;
# cells still fails a scored section missing an axis).
#
# Output: `c2-record:` provenance/guard lines, one `LEG L<n> verdict=<ok|
# defect> <detail>` line per leg, then exactly one verdict line. Exit 0 iff
# mismatches=0 and guard=1; 1 otherwise (DEFFECT verdict still exits 1);
# 2 SETUP (prints `C2_RECORD: SETUP <reason>`).
set -u

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=$(dirname "$SELF_DIR")
TREE=$LANE
BASE_TREE=""
SCRATCH=""
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:?--tree needs a dir}; shift 2 ;;
    --base-tree) BASE_TREE=${2:?--base-tree needs a dir}; shift 2 ;;
    --scratch) SCRATCH=${2:?--scratch needs a dir}; shift 2 ;;
    --selftest) SELFTEST=1; shift ;;
    -h|--help) sed -n '2,/^set -u$/p' "${BASH_SOURCE[0]}" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "C2_RECORD: SETUP unknown argument: $1"; exit 2 ;;
  esac
done
[ -d "$TREE" ] || { echo "C2_RECORD: SETUP bad-tree $TREE"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "C2_RECORD: SETUP no-python3"; exit 2; }
[ -n "$BASE_TREE" ] && { [ -d "$BASE_TREE" ] || { echo "C2_RECORD: SETUP bad-base-tree $BASE_TREE"; exit 2; }; }
export LC_ALL=C

exec python3 -I -B - "$TREE" "$LANE" "$BASE_TREE" "$SCRATCH" "$SELFTEST" <<'PY'
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

TREE = Path(sys.argv[1]).resolve()
LANE = Path(sys.argv[2]).resolve()
BASE_TREE = Path(sys.argv[3]).resolve() if sys.argv[3] else None
SCRATCH = sys.argv[4]
SELFTEST = sys.argv[5] == "1"

BASE_SHA = "d3b2a4e8eed710277951e430efd3d27b5983033c"
POPULATION = 3
GUARD_DEPTH_ENV = "KAGI_R68_C2_DEPTH"
BASE_LEDGER_REL = "corpus/claim-ledger.tsv"
CENSUS_REL = "corpus/sources-census.sh"
LEDGER_GATE_REL = "corpus/claim-ledger.sh"
CLAIMS_DECL_REL = "corpus/claims-declared.tsv"
CLAIMS_DECL_GATE = "corpus/claims-declared.sh"
JOURNAL_SH = "corpus/expect-journal.sh"
JOURNALS_DIR = ".ufo/waves/round-68/journals"

_seq = [0]
_scratch = None


class SetupError(Exception):
    pass


def _root_scratch(explicit):
    if explicit:
        p = Path(explicit)
        p.mkdir(parents=True, exist_ok=True)
        return p
    base = Path(os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku")) / "kagi-r68" / "R68ExecCounterC2"
    base.mkdir(parents=True, exist_ok=True)
    return base


def mkdtemp(prefix):
    _seq[0] += 1
    if _scratch is None:
        raise SetupError("scratch-initialized-late")
    d = Path(tempfile.mkdtemp(prefix="%s-%03d-" % (prefix, _seq[0]), dir=str(_scratch)))
    return d


def read(p):
    return Path(p).read_text(encoding="utf-8", errors="surrogateescape")


def parse_tsv_rows(path):
    rows = {}
    out = []
    try:
        text = read(path)
    except (OSError, FileNotFoundError):
        return out
    for line in text.splitlines():
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) < 6:
            continue
        rows.setdefault(parts[0], []).append(parts)
        out.append(parts)
    return out


def row_for(path, rid):
    for parts in parse_tsv_rows(path):
        if parts[0] == rid:
            return parts
    return None


def run_cmd(args, cwd, timeout=300, env=None):
    e = dict(os.environ)
    if env:
        e.update(env)
    try:
        p = subprocess.run(args, cwd=str(cwd), capture_output=True, text=True,
                           timeout=timeout, env=e)
        return p.returncode, (p.stdout or ""), (p.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "", ""
    except Exception as ex:  # noqa: BLE001
        return -1, "", "%s: %s" % (type(ex).__name__, ex)


def last_nonempty(out):
    lines = [l.strip() for l in (out or "").strip().splitlines() if l.strip()]
    return lines[-1] if lines else ""


def expect_cases(expect):
    m = re.search(r"\(\\?\((-?\d+)\) cases\\?\)", expect)
    if m:
        return int(m.group(1))
    m = re.search(r"\(\^?\\?\((\d+)\) cases\\?\)", expect)
    if m:
        return int(m.group(1))
    return None


def gate_cases(rc, out, err):
    if rc != 0:
        return None
    m = re.search(r"\(\d+ cases\)", out or "")
    if not m:
        return None
    return m


def run_gate_selftest(tree, script_rel, timeout=300):
    """Returns (rc, case_count_or_None, last_line)."""
    script = Path(tree) / script_rel
    if not script.is_file():
        return -1, None, "absent:%s" % script_rel
    rc, out, err = run_cmd(["bash", str(script), "--selftest"], cwd=tree, timeout=timeout)
    last = last_nonempty(out)
    n = None
    if rc == 0:
        m = re.search(r"^\S*SELFTEST:\s+PASS\s+\((\d+) cases\)\s*$", last)
        if m:
            n = int(m.group(1))
    return rc, n, last


def census_verify(tree, timeout=300):
    script = Path(tree) / CENSUS_REL
    if not script.is_file():
        return -1, "", "absent:" + CENSUS_REL
    rc, out, err = run_cmd(["bash", str(script), "verify", "--root", "."], cwd=tree, timeout=timeout)
    return rc, out, err


def census_verdict_line(out):
    last = last_nonempty(out)
    if last.startswith("SOURCES_CENSUS:"):
        return last
    return last


def ledger_verify(tree, timeout=600):
    script = Path(tree) / LEDGER_GATE_REL
    if not script.is_file():
        return -1, "", "absent:" + LEDGER_GATE_REL
    rc, out, err = run_cmd(["bash", str(script), "verify"], cwd=tree, timeout=timeout,
                           env={"CLAIM_LEDGER_DEPTH": "0"})
    return rc, out, err


def cells_run(tree, timeout=600, extra_args=None):
    script = Path(tree) / LEDGER_GATE_REL
    if not script.is_file():
        return -1, "", "absent:" + LEDGER_GATE_REL
    args = ["bash", str(script), "cells"]
    if extra_args:
        args += extra_args
    rc, out, err = run_cmd(args, cwd=tree, timeout=timeout,
                           env={"CLAIM_LEDGER_DEPTH": "0"})
    return rc, out, err


def finding_ids(out):
    ids = set()
    for line in (out or "").splitlines():
        m = re.match(r"^(MISSING-ID|MISSING|POLICY|FAIL|STALE)\s+(\S+)", line)
        if m:
            ids.add("%s %s" % (m.group(1), m.group(2)))
        m2 = re.match(r"^FINDING\s+(\S+)\s+", line)
        if m2:
            ids.add("FINDING %s" % m2.group(1))
    return ids


def base_tree_extract(scratch):
    """Extract the BASE commit into scratch (never mutates the lane repo)."""
    if BASE_TREE is not None:
        return BASE_TREE
    d = mkdtemp("base-tree")
    try:
        p = subprocess.run(["git", "archive", BASE_SHA], cwd=str(LANE),
                           capture_output=True, timeout=300)
        if p.returncode != 0:
            raise SetupError("base-extract-failed rc=%s" % p.returncode)
        import tarfile, io
        with tarfile.open(fileobj=io.BytesIO(p.stdout), mode="r|*") as tf:
            tf.extractall(str(d))
    except SetupError:
        raise
    except Exception as ex:  # noqa: BLE001
        raise SetupError("base-extract-error:%s:%s" % (type(ex).__name__, ex))
    return d


def base_bytes(rel_path, dest, timeout=120):
    """Write git show <BASE>:<rel> bytes to dest; return (ok, sha_prefix, bytes_len)."""
    try:
        p = subprocess.run(["git", "show", "%s:%s" % (BASE_SHA, rel_path)], cwd=str(LANE),
                           capture_output=True, timeout=timeout)
    except Exception as ex:  # noqa: BLE001
        return False, "git-error:%s" % type(ex).__name__, 0
    if p.returncode != 0 or not p.stdout:
        return False, "git-unreadable", 0
    dest = Path(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(p.stdout)
    import hashlib
    return True, hashlib.sha256(p.stdout).hexdigest()[:12], len(p.stdout)


def run_gate_on_fixture(gate_bytes, fixture_root, name, timeout=120):
    """Run gate bytes against a minimal census fixture; returns (rc, out)."""
    d = Path(fixture_root) / name
    (d / "corpus" / "knowledge").mkdir(parents=True, exist_ok=True)
    (d / "corpus" / "knowledge" / "e1.md").write_text(
        "source: S001 (https://example.invalid/one, §1, 2026-05-05)\nverified-at: 2026-05-05\nrecheck: 90d\n")
    (d / "corpus" / "SOURCES.md").write_text(
        "# Sources fixture\n\n## Registry\n\n| id | title | kind | tier | topic | where | teaches | status | opened | recheck | used-by |\n|---|---|---|---|---|---|---|---|---|---|---|\n| S001 | t — https://example.invalid/one | docs | B | topic | §1, 2026-04-04 | teaches one | mined | 2026-10-19 | 90d | corpus/knowledge/e1.md |\n\n## Paths\n\n## Search log\n\n## Leads (unopened)\n")
    (d / "corpus" / "source-fetches.tsv").write_text("# fixture\n")
    # ^ provenance row absent: SC_FETCH missing-provenance expected
    gd = Path(fixture_root) / (name + "-gate")
    gd.mkdir(parents=True, exist_ok=True)
    gate = gd / "sources-census.sh"
    gate.write_bytes(gate_bytes)
    rc, out, err = run_cmd(["bash", str(gate), "verify", "--root", str(d)], cwd=d, timeout=timeout)
    return rc, out


# ------------------------------------------------------------------ legs ----

def leg1(tree, base_dir):
    detail = []
    ledger = Path(tree) / BASE_LEDGER_REL
    row = row_for(ledger, "R21-03")
    if row is None:
        return False, "R21-03 absent"
    cmd, expect = row[1], row[2]
    if cmd != "bash corpus/sources-census.sh --selftest":
        return False, "R21-03 command=%r" % cmd
    n = expect_cases(expect)
    if n is None:
        return False, "R21-03 expect carries no case count"
    detail.append("pinned=%d" % n)
    rc, m, last = run_gate_selftest(tree, CENSUS_REL)
    if m is None:
        return False, "gate-selftest-unmeasurable rc=%s last=%r" % (rc, last[:120])
    detail.append("measured=%d" % m)
    m = n  # mutant: live count discarded
    if m != n:
        return False, " ".join(detail) + " measured!=pinned"
    # BASE-pinned bytes: never the in-tree oracle alone.
    btmp = mkdtemp("l1-base")
    ok, sha, blen = base_bytes(CENSUS_REL, btmp / "sources-census.sh")
    if not ok:
        return False, " ".join(detail) + " base-gate-unreadable"
    detail.append("base_gate_sha=%s" % sha)
    brc, bn, blast = run_gate_selftest_from_bytes(btmp / "sources-census.sh", tree)
    if bn is None:
        return False, " ".join(detail) + " base-selftest-unmeasurable rc=%s last=%r" % (brc, blast[:120])
    detail.append("base=%d" % bn)
    if m < bn:
        return False, " ".join(detail) + " measured<base"
    # Mutation-sensitivity probe on the measured gate copy: a printer that
    # only prints its case count is not measurable.
    try:
        bytes_ = (Path(tree) / CENSUS_REL).read_bytes()
    except OSError:
        return False, " ".join(detail) + " gate-bytes-unreadable"
    fx = mkdtemp("l1-probe")
    prc, pout = run_gate_on_fixture(bytes_, fx, "sensitive")
    if not (prc == 1 and "FINDING" in pout and "SOURCES_CENSUS: FAILED" in pout):
        return False, " ".join(detail) + " probe-insensitive rc=%s out=%r" % (prc, pout[:200])
    detail.append("probe=sensitive")
    # Journal: old->new pair for R21-03 + expect-journal CLEAN vs BASE ledger.
    jdir = Path(tree) / JOURNALS_DIR
    journal_path = jdir / "expectation-migrations.json"
    if not journal_path.is_file():
        return False, " ".join(detail) + " journal-absent"
    try:
        doc = json.loads(journal_path.read_text(encoding="utf-8"))
    except Exception:
        return False, " ".join(detail) + " journal-unreadable"
    migs = [e for e in (doc.get("migrations") or []) if e.get("id") == "R21-03"]
    if len(migs) != 1:
        return False, " ".join(detail) + " journal-R21-03-count=%d" % len(migs)
    mig = migs[0]
    if mig.get("old_expect") != mig.get("new_expect"):
        detail.append("journal-pair=old!=new")
    if mig.get("new_expect") != expect:
        return False, " ".join(detail) + " journal-new_expect!=ledger-expect"
    if "88" not in mig.get("old_expect", ""):
        return False, " ".join(detail) + " journal-old_expect-not-88"
    detail.append("journal=R21-03")
    script = Path(tree) / JOURNAL_SH
    if not script.is_file():
        return False, " ".join(detail) + " expect-journal-absent"
    # BASE ledger bytes: git show <BASE>:corpus/claim-ledger.tsv (not the measured one).
    bledger = btmp / "base-ledger.tsv"
    ok, sha2, _ = base_bytes(BASE_LEDGER_REL, bledger)
    if not ok:
        return False, " ".join(detail) + " base-ledger-unreadable"
    rc, out, err = run_cmd(
        ["bash", str(script), "--base-ledger", str(bledger),
         "--ledger", str(ledger), "--journals", str(jdir)],
        cwd=tree, timeout=120)
    if rc != 0 or "EXPECT_JOURNAL: CLEAN" not in (out or ""):
        return False, " ".join(detail) + " journal-dirty rc=%s tail=%r" % (
            rc, (out or "").strip().splitlines()[-1][:120] if (out or "").strip() else err[:120])
    return True, " ".join(detail) + " journal=CLEAN"


def run_gate_selftest_from_bytes(gate_bytes_path, cwd_root):
    """Run the copied BASE gate bytes' --selftest (repo-relative invocation)."""
    gd = mkdtemp("basegate")
    gf = gd / "corpus"
    gf.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(str(gate_bytes_path), str(gf / "sources-census.sh"))
    # copy the full bytes tree the gate may consult
    corpus = Path(cwd_root) / "corpus"
    for extra in ("rendered-text-v1.py", "inrow-pins.tsv"):
        src = corpus / extra
        if src.is_file():
            shutil.copyfile(str(src), str(gf / extra))
    rc, out, err = run_cmd(["bash", str(gf / "sources-census.sh"), "--selftest"], cwd=cwd_root, timeout=300)
    last = last_nonempty(out)
    n = None
    if rc == 0:
        mm = re.search(r"^\S*SELFTEST:\s+PASS\s+\((\d+) cases\)\s*$", last)
        if mm:
            n = int(mm.group(1))
    return rc, n, last


def leg2(tree, base_dir):
    detail = []
    ledger = Path(tree) / BASE_LEDGER_REL
    r1 = row_for(ledger, "R68-01")
    r2 = row_for(ledger, "R68-02")
    if r1 is None or r2 is None:
        miss = [x for x, r in (("R68-01", r1), ("R68-02", r2)) if r is None]
        return False, "missing-rows=%s" % ",".join(miss)
    if "C1_VERIFIED:" not in (r1[2] + " " + r1[5]):
        return False, "R68-01 expect/note lacks C1_VERIFIED:"
    if "C2_RECORD:" not in (r2[2] + " " + r2[5]):
        return False, "R68-02 expect/note lacks C2_RECORD:"
    detail.append("rows=R68-01,R68-02")
    # Both counters must EXECUTE on the measured tree (rows alone are text).
    c1s = Path(tree) / "plans" / "round-68-c1.sh"
    c2s = Path(tree) / "plans" / "round-68-c2.sh"
    if not c1s.is_file() or not c2s.is_file():
        return False, " ".join(detail) + " counter-absent c1=%s c2=%s" % (c1s.is_file(), c2s.is_file())
    depth = int(os.environ.get(GUARD_DEPTH_ENV, "0") or "0")
    if depth > 4:
        return False, " ".join(detail) + " counter-recursion-depth=%d" % depth
    env = {GUARD_DEPTH_ENV: str(depth + 1)}
    # C1 counter: needs a base tree for its derivation.
    c1_rc, c1_out, c1_err = run_cmd(
        ["bash", str(c1s), "--tree", str(tree)], cwd=tree, timeout=900, env=env)
    # If no base-tree is provided, C1 may SETUP; accept either a frozen
    # verdict or a SETUP naming its missing base, never a pass.
    c1_last = last_nonempty(c1_out)
    if not (c1_last.startswith("C1_VERIFIED:") or c1_last.startswith("C1_VERIFIED: SETUP")):
        return False, " ".join(detail) + " c1-verdict-unrecognised rc=%s last=%r" % (c1_rc, c1_last[:120])
    detail.append("c1-executed rc=%s" % c1_rc)
    if depth == 0:
        # Only the outermost invocation executes the C2 counter itself.
        c2_rc, c2_out, c2_err = run_cmd(
            ["bash", str(c2s), "--tree", str(tree)], cwd=tree, timeout=900, env=env)
        c2_last = last_nonempty(c2_out)
        if not (c2_last.startswith("C2_RECORD:") ):
            return False, " ".join(detail) + " c2-verdict-unrecognised rc=%s last=%r" % (
                c2_rc, c2_last[:120])
        detail.append("c2-executed rc=%s" % c2_rc)
    # claims-declared rows + CLEAN.
    decl = Path(tree) / CLAIMS_DECL_REL
    dt = read(decl) if decl.is_file() else ""
    have1 = "\n68\tC1\tfreshness" in ("\n" + dt) or dt.startswith("68\tC1\tfreshness")
    have2 = "\n68\tC2\tcalibration" in ("\n" + dt) or dt.startswith("68\tC2\tcalibration")
    exact = re.search(r"^68\tC1\tfreshness\s*$", dt, re.M) and re.search(
        r"^68\tC2\tcalibration\s*$", dt, re.M)
    if not exact:
        return False, " ".join(detail) + " claims-declared-rows missing"
    gate = Path(tree) / CLAIMS_DECL_GATE
    rc, out, err = run_cmd(["bash", str(gate), "--root", "."], cwd=tree, timeout=120)
    if rc != 0 or not (out or "").strip().startswith("CLAIMS_DECLARED: CLEAN"):
        return False, " ".join(detail) + " claims-declared-dirty rc=%s last=%r" % (
            rc, last_nonempty(out)[:120])
    detail.append("claims-declared=CLEAN")
    return True, " ".join(detail)

def leg3(tree, base_dir):
    # L3's frozen condition (plans/round-68.md §C2 L3): `bash
    # corpus/claim-ledger.sh cells` on the measured tree exits with a
    # verdict line and no SETUP. The real tree currently terminates
    # CELL_AUDIT: POLICY (exit 2, three first-token refusals: R29-01/
    # R29-02 `python`, R38-03 `python3 -I -B quote-locate.py — routed by
    # R68ExecLedger, re-check at integration) or CELL_AUDIT: BROKEN
    # (exit 1, pre-existing UNCITED=117). Either verdict is a PASS for
    # L3: the leg's claim is that the parser no longer SETUPs on the
    # historical `## Round 63 — planned` heading, never that the tree
    # is uncited-clean. POLICY/BROKEN findings are routed, not smoothed.
    import time
    t0 = time.time()
    rc, out, err = cells_run(tree, timeout=3600)
    wall = int(time.time() - t0)
    combined = (out or "") + "\n" + (err or "")
    tail = last_nonempty(combined)[:160]
    if "unrecognised round heading" in combined:
        return False, "cells SETUP planned-heading rc=%s tail=%r wall=%ds" % (rc, tail, wall)
    if "SETUP" in combined:
        return False, "cells SETUP present rc=%s tail=%r wall=%ds" % (rc, tail, wall)
    m = re.search(r"^CELL_AUDIT: (CLEAN|BROKEN|POLICY)(.*)$", out or "", re.M)
    if not m:
        return False, "cells no-verdict-line rc=%s tail=%r wall=%ds" % (rc, tail, wall)
    verdict, rest = m.group(1), m.group(2)
    if verdict == "CLEAN" and rc != 0:
        return False, "cells CLEAN with rc=%s (contradiction)" % rc
    # extract and route the pre-existing finding counts
    detail_pre = "cells-verdict=%s rc=%s wall=%ds rest=%s" % (
        verdict, rc, wall, rest.strip()[:160])
    if "## Round 63 — planned" in (out or ""):
        return False, "cells named planned heading as defect rc=%s wall=%ds" % (rc, wall)
    # Planned-heading controls (R68ExecLedger tightening, landed):
    # PLANNED_SECTION_RE is exact '^## Round [0-9]+ — planned$'. A table
    # under a skipped planned heading dies loudly (setup error, never
    # UNCITED), and a suffixed planned heading is unrecognised.
    # One real claim row + script first (the empty-ledger guard).
    import hashlib
    fx = mkdtemp("l3-hidden")
    (fx / "corpus").mkdir(parents=True, exist_ok=True)
    (_row_src := Path(tree) / "corpus/fixtures/cells-hermetic/corpus/fx-ok.sh")
    if _row_src.is_file():
        (fx / "corpus" / "fx-ok.sh").write_bytes(_row_src.read_bytes())
    else:
        (fx / "corpus" / "fx-ok.sh").write_text("#!/usr/bin/env bash\necho FX: OK\n")
    (fx / "SCORECARD.md").write_text(
        "# fixture scorecard\n\n## Round 99 — pre-move\n\n"
        "| Axis | Score | Evidence |\n|---|---|---|\n"
        "| depth | 9 | R99-01 |\n| coverage | 9 | R99-01 |\n| operability | 9 | R99-01 |\n"
        "| freshness | 9 | R99-01 |\n| calibration | 9 | R99-01 |\n| adjacency | 9 | R99-01 |\n\n"
        "## Round 99 — planned\n\n"
        "| Axis | Score | Evidence |\n|---|---|---|\n"
        "| calibration | 9 |  |\n")
    (fx / "claims.tsv").write_text("R99-01\tbash corpus/fx-ok.sh\t^FX: OK$\t0\t10\tfx\n")
    _b = (fx / "corpus" / "fx-ok.sh").read_bytes()
    (fx / "stamps.tsv").write_text("corpus/fx-ok.sh\t%s\t%s\t%s\n" % (
        hashlib.sha256(_b).hexdigest(), len(_b.splitlines()), len(_b)))
    _adj = Path(tree) / "corpus/fixtures/cells-hermetic/corpus/adjacency.tsv"
    if _adj.is_file():
        (fx / "corpus" / "adjacency.tsv").write_bytes(_adj.read_bytes())
    script = Path(tree) / LEDGER_GATE_REL
    nrc, nout, nerr = run_cmd(
        ["bash", str(script), "cells", "--root", str(fx),
         "--claims", str(fx / "claims.tsv"), "--stamps", str(fx / "stamps.tsv"),
         "--scorecard", str(fx / "SCORECARD.md"), "--docs", str(fx / "SCORECARD.md")],
        cwd=tree, timeout=300, env={"CLAIM_LEDGER_DEPTH": "0"})
    ncombined = (nout or "") + "\n" + (nerr or "")
    if not (nrc == 2 and "score table under an unscored planned heading" in ncombined):
        return False, "planned-hidden-table rc=%s tail=%r (want rc=2 score-table-under-unscored-planned-heading)" % (
            nrc, last_nonempty(ncombined)[:160])
    # Suffixed planned heading: must be unrecognised (rc=2).
    fx_s = mkdtemp("l3-suffix")
    shutil.copytree(str(fx), str(fx_s / "root"), dirs_exist_ok=True)
    root_s = fx_s / "root"
    (root_s / "SCORECARD.md").write_text(
        "# fixture scorecard\n\n## Round 99 — pre-move\n\n"
        "| Axis | Score | Evidence |\n|---|---|---|\n"
        "| depth | 9 | R99-01 |\n| coverage | 9 | R99-01 |\n| operability | 9 | R99-01 |\n"
        "| freshness | 9 | R99-01 |\n| calibration | 9 | R99-01 |\n| adjacency | 9 | R99-01 |\n\n"
        "## Round 99 — planned (claims C1 calibration)\n\nIntent text only.\n")
    src = run_cmd(
        ["bash", str(script), "cells", "--root", str(root_s),
         "--claims", str(root_s / "claims.tsv"), "--stamps", str(root_s / "stamps.tsv"),
         "--scorecard", str(root_s / "SCORECARD.md"), "--docs", str(root_s / "SCORECARD.md")],
        cwd=tree, timeout=300, env={"CLAIM_LEDGER_DEPTH": "0"})
    scombined = (src[1] or "") + "\n" + (src[2] or "")
    if not (src[0] == 2 and "unrecognised round heading" in scombined):
        return False, "suffixed-planned rc=%s tail=%r (want rc=2 unrecognised)" % (
            src[0], last_nonempty(scombined)[:160])
    # Scored section missing an axis: the real gate must die (setup error).
    fx2 = mkdtemp("l3-scored")
    shutil.copytree(str(fx), str(fx2 / "root"), dirs_exist_ok=True)
    root2 = fx2 / "root"
    sc = root2 / "SCORECARD.md"
    sc.write_text(
        "# fixture scorecard\n\n## Round 99 — pre-move\n\n"
        "| Axis | Score | Evidence |\n|---|---|---|\n"
        "| depth | 9 | R99-01 |\n| coverage | 9 | R99-01 |\n| operability | 9 | R99-01 |\n"
        "| freshness | 9 | R99-01 |\n| calibration | 9 | R99-01 |\n")
    (root2 / "claims.tsv").write_text("R99-01\tbash corpus/fx-ok.sh\t^FX: OK$\t0\t10\tfx\n")
    if (root2 / "corpus" / "fx-ok.sh").exists():
        (root2 / "corpus" / "fx-ok.sh").write_text("#!/usr/bin/env bash\necho FX: OK\n")
    (root2 / "stamps.tsv").write_text("corpus/fx-ok.sh\tx\t2\t38\ncorpus/adjacency.tsv\tfa15a53c7e586165a946c13c73f62995dfae9dff4fda2f55d3350a6682c8efaa\t9\t307\n")
    src_stamps = Path(tree) / "corpus/fixtures/cells-hermetic/stamps.tsv"
    if src_stamps.is_file():
        # refresh the fx-ok.rs stamp from the fixture copy (bytes differ)
        lines = []
        for l in src_stamps.read_text(encoding="utf-8").splitlines():
            if l.startswith("corpus/fx-ok.sh\t"):
                import hashlib
                b = (root2 / "corpus" / "fx-ok.sh").read_bytes()
                lines.append("corpus/fx-ok.sh\t%s\t%s\t%s" % (
                    hashlib.sha256(b).hexdigest(), len(b.splitlines()), len(b)))
            else:
                lines.append(l)
        (root2 / "stamps.tsv").write_text("\n".join(lines) + "\n")
    src_adj = Path(tree) / "corpus/fixtures/cells-hermetic/corpus/adjacency.tsv"
    if src_adj.is_file():
        (root2 / "corpus" / "adjacency.tsv").write_bytes(src_adj.read_bytes())
    n2rc, n2out, n2err = run_cmd(
        ["bash", str(script), "cells", "--root", str(root2),
         "--claims", str(root2 / "claims.tsv"), "--stamps", str(root2 / "stamps.tsv"),
         "--scorecard", str(root2 / "SCORECARD.md"), "--docs", str(root2 / "SCORECARD.md")],
        cwd=tree, timeout=300, env={"CLAIM_LEDGER_DEPTH": "0"})
    n2combined = (n2out or "") + "\n" + (n2err or "")
    if n2rc == 0:
        return False, "cells scored-missing-axis passed rc=0 tail=%r" % last_nonempty(n2combined)[:160]
    return True, "%s planned-table=rc2 suffixed-planned=rc2 scored-missing-axis=fails rc=%s" % (detail_pre, n2rc)


# ------------------------------------------------------------------ guard ---

def guard(tree, base_dir):
    detail = []
    # (a) census CLEAN on the unmodified tree.
    rc, out, err = census_verify(tree)
    last = census_verdict_line(out)
    if not last.startswith("SOURCES_CENSUS: CLEAN"):
        detail.append("(a)=0 census-last=%r" % last[:120])
        a = 0
    else:
        detail.append("(a)=1")
        a = 1
    # (b) verify finding-id set: BASE set (derived live) vs candidate set.
    brc, bout, berr = ledger_verify(base_dir, timeout=900)
    cand_rc, cand_out, cand_err = ledger_verify(tree, timeout=900)
    base_ids = finding_ids(bout)
    cand_ids = finding_ids(cand_out)
    # Exclude the pre-existing round-37/38/46 lesson ids: they live only in
    # corpus/lessons/round-{37,38,46}.md — derive the exclusions from the BASE
    # file by checking which MISSING/POLICY ids name a path absent from both
    # ledgers; ids whose path is absent from both yet not in lessons are NEW.
    base_ledger = read(Path(base_dir) / BASE_LEDGER_REL) if (Path(base_dir) / BASE_LEDGER_REL).is_file() else ""
    cand_ledger = read(Path(tree) / BASE_LEDGER_REL) if (Path(tree) / BASE_LEDGER_REL).is_file() else ""
    def is_lesson_only(fid):
        parts = fid.split(" ", 1)
        if len(parts) < 2:
            return True
        token = parts[1].split("=")[0].strip()
        if token.startswith("R"):
            return token in base_ledger or token in cand_ledger
        p = token.lstrip("(")
        for rel in ("corpus/lessons/round-37.md", "corpus/lessons/round-38.md",
                    "corpus/lessons/round-46.md"):
            if (Path(base_dir) / rel).is_file():
                if p in read(Path(base_dir) / rel):
                    return True
        return p in base_ledger or p in cand_ledger
    new_ids = [fid for fid in sorted(cand_ids) if fid not in base_ids and not is_lesson_only(fid)]
    # A candidate verdict of CLEAN with an empty new set is 1; any new id is 0.
    cand_last = last_nonempty(cand_out)
    if new_ids:
        detail.append("(b)=0 new-finding-ids=%d first=%r" % (len(new_ids), new_ids[0] if new_ids else ""))
        b = 0
    elif "CLAIM_LEDGER: CLEAN" in (cand_out or "") or (cand_last.startswith("CLAIM_LEDGER:")):
        detail.append("(b)=1 base=%d cand=%d" % (len(base_ids), len(cand_ids)))
        b = 1
    else:
        detail.append("(b)=0 cand-last=%r" % cand_last[:120])
        b = 0
    # (c) negative controls (fixture-level, cheap).
    c = 1
    # ledger still flags an undefined id.
    fx = mkdtemp("guard-c1")
    (fx / "claims.tsv").write_text("Z9-01\tbash corpus/fx-ok.sh\t^FX: OK$\t0\t10\tfx\n")
    (fx / "stamps.tsv").write_text("# no stamps\n")
    (fx / "SCORECARD.md").write_text("# x\n")
    script = Path(tree) / LEDGER_GATE_REL
    nrc, nout, nerr = run_cmd(
        ["bash", str(script), "verify", "--root", str(fx),
         "--claims", str(fx / "claims.tsv"), "--stamps", str(fx / "stamps.tsv")],
        cwd=tree, timeout=120, env={"CLAIM_LEDGER_DEPTH": "0"})
    if "MISSING-ID" not in ((nout or "") + (nerr or "")) and "FAIL Z9-01" not in (nout or ""):
        detail.append("(c)=0 ledger-undefined-id-not-flagged rc=%s" % nrc)
        c = 0
    # cells still fails a scored section missing an axis.
    fx2 = mkdtemp("guard-c2")
    fx2 = fx2 / "root"
    (fx2 / "corpus").mkdir(parents=True, exist_ok=True)
    (fx2 / "SCORECARD.md").write_text(
        "# x\n\n## Round 99 — pre-move\n\n"
        "| Axis | Score | Evidence |\n|---|---|---|\n"
        "| depth | 9 | R99-01 |\n| coverage | 9 | R99-01 |\n| operability | 9 | R99-01 |\n"
        "| freshness | 9 | R99-01 |\n| calibration | 9 | R99-01 |\n")
    (fx2 / "claims.tsv").write_text("R99-01\tbash corpus/fx-ok.sh\t^FX: OK$\t0\t10\tfx\n")
    (fx2 / "corpus" / "fx-ok.sh").write_text("#!/usr/bin/env bash\necho FX: OK\n")
    (fx2 / "stamps.tsv").write_text(
        "corpus/fx-ok.sh\t2e0bc9b4aa7b944976a5a05b45a13b76aabde9349602846538a8eee5f9d2eae\t2\t33\n")
    import hashlib
    b = (fx2 / "corpus" / "fx-ok.sh").read_bytes()
    (fx2 / "stamps.tsv").write_text("corpus/fx-ok.sh\t%s\t%s\t%s\n" % (
        hashlib.sha256(b).hexdigest(), len(b.splitlines()), len(b)))
    n2rc, n2out, n2err = run_cmd(
        ["bash", str(script), "cells", "--root", str(fx2),
         "--claims", str(fx2 / "claims.tsv"), "--stamps", str(fx2 / "stamps.tsv"),
         "--scorecard", str(fx2 / "SCORECARD.md"), "--docs", str(fx2 / "SCORECARD.md")],
        cwd=tree, timeout=120, env={"CLAIM_LEDGER_DEPTH": "0"})
    if n2rc == 0:
        detail.append("(c)=0 scored-missing-axis passed")
        c = 0
    if c == 1:
        detail.append("(c)=1")
    return (1 if (a and b and c) else 0), " ".join(detail)


# -------------------------------------------------------------- selftest ----

def mk_tree(mut=None):
    """A minimal lane-tree fixture carrying just the surfaces the counter reads."""
    d = mkdtemp("self-tree")
    (d / "corpus" / "knowledge").mkdir(parents=True, exist_ok=True)
    (d / "corpus" / "knowledge" / "e1.md").write_text(
        "source: S001 (https://example.invalid/one, §1, 2026-05-05)\nverified-at: 2026-05-05\nrecheck: 90d\n")
    (d / "corpus" / "SOURCES.md").write_text(
        "# Sources fixture\n\n## Registry\n\n| id | title | kind | tier | topic | where | teaches | status | opened | recheck | used-by |\n|---|---|---|---|---|---|---|---|---|---|---|\n| S001 | t — https://example.invalid/one | docs | B | topic | §1, 2026-04-04 | teaches one | mined | 2026-10-19 | 90d | corpus/knowledge/e1.md |\n\n## Paths\n\n## Search log\n\n## Leads (unopened)\n")
    (d / "corpus" / "source-fetches.tsv").write_text("# fixture fetch\n")
    # copy the real census gate bytes (and the real ledger gate) into the fixture
    shutil.copyfile(str(LANE / CENSUS_REL), str(d / CENSUS_REL))
    shutil.copyfile(str(LANE / LEDGER_GATE_REL), str(d / LEDGER_GATE_REL))
    shutil.copyfile(str(LANE / CLAIMS_DECL_GATE), str(d / CLAIMS_DECL_GATE))
    shutil.copyfile(str(LANE / JOURNAL_SH), str(d / JOURNAL_SH))
    shutil.copyfile(str(LANE / "corpus/rendered-text-v1.py"), str(d / "corpus/rendered-text-v1.py"))
    if (LANE / "corpus/inrow-pins.tsv").is_file():
        shutil.copyfile(str(LANE / "corpus/inrow-pins.tsv"), str(d / "corpus/inrow-pins.tsv"))
    (d / "plans").mkdir(parents=True, exist_ok=True)
    # counters: fixture copies of this counter (recursion depth-guarded) + a C1 stub
    shutil.copyfile(str(LANE / "plans" / "round-68-c2.sh"), str(d / "plans" / "round-68-c2.sh"))
    (d / "plans" / "round-68-c1.sh").write_text("#!/usr/bin/env bash\necho 'C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1'\nexit 0\n")
    old, new = _selftest_pair(mut)
    row = ("R21-03\tbash corpus/sources-census.sh --selftest\t%s\t0\t120\tnote\n" % new +
           "R68-01\tbash plans/round-68-c1.sh\t^C1_VERIFIED: verified=[0-9]+ col15=[0-9]+ caught=[0-9]+/6 guard=[01]$\t0\t900\tnote C1_VERIFIED:\n" +
           "R68-02\tbash plans/round-68-c2.sh\t^C2_RECORD: mismatches=[0-9]+ population=3 guard=[01]$\t0\t900\tnote C2_RECORD:\n")
    (d / "corpus" / "claim-ledger.tsv").write_text(row)
    (d / "corpus" / "stamps.tsv").write_text("# fixture stamps\n")
    (d / "corpus" / "claims-declared.tsv").write_text(
        "round\tclaim\taxis\n68\tC1\tfreshness\n68\tC2\tcalibration\n")
    (d / "plans" / "round-68.md").write_text(
        "# Round 68 — fixture\n\n## C1 — freshness: f\n\nx\n\n## C2 — calibration: f\n\nx\n")
    (d / "SCORECARD.md").write_text(
        "# fixture scorecard\n\n## Round 68 — post-move (claims C1 freshness, C2 calibration)\n\n"
        "| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n"
        "| freshness | 9 → 9 | [C1] x | R68-01 |\n"
        "| calibration | 9 → 9 | [C2] x | R68-02 |\n"
        "| depth | 9 → 9 | x | R21-03 |\n"
        "| coverage | 9 → 9 | x | R21-03 |\n"
        "| operability | 9 → 9 | x | R21-03 |\n"
        "| adjacency | 9 → 9 | x | R21-03 |\n\n"
        "## Round 63 — planned\n\nFuture intent, no table.\n")
    jd = d / JOURNALS_DIR
    jd.mkdir(parents=True, exist_ok=True)
    (jd / "expectation-migrations.json").write_text(json.dumps(
        {"migrations": [{"id": "R21-03", "command": "bash corpus/sources-census.sh --selftest",
                         "old_expect": old, "new_expect": new}]}, indent=1))
    if mut == "l3-planned-hidden":
        sc = d / "SCORECARD.md"
        sc.write_text(
            "# fixture scorecard\n\n## Round 68 — post-move (claims C1 freshness, C2 calibration)\n\n"
            "| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n"
            "| freshness | 9 → 9 | [C1] x | R68-01 |\n"
            "| calibration | 9 → 9 | [C2] x | R68-02 |\n"
            "| depth | 9 → 9 | x | R21-03 |\n"
            "| coverage | 9 → 9 | x | R21-03 |\n"
            "| operability | 9 → 9 | x | R21-03 |\n"
            "| adjacency | 9 → 9 | x | R21-03 |\n\n"
            "## Round 63 — planned\n\n| Axis | Score | Evidence |\n|---|---|---|\n"
            "| depth | 9 |  |\n| coverage | 9 |  |\n| operability | 9 |  |\n"
            "| freshness | 9 |  |\n| calibration | 9 |  |\n| adjacency | 9 |  |\n")
    if mut == "cells-scored-missing":
        sc = d / "SCORECARD.md"
        sc.write_text(
            "# fixture scorecard\n\n## Round 68 — post-move (claims C1 freshness, C2 calibration)\n\n"
            "| Axis | Before → after | What moved | Evidence |\n|---|---|---|---|\n"
            "| freshness | 9 → 9 | [C1] x | R68-01 |\n"
            "| calibration | 9 → 9 | [C2] x | R68-02 |\n"
            "| depth | 9 → 9 | x | R21-03 |\n"
            "| coverage | 9 → 9 | x | R21-03 |\n"
            "| operability | 9 → 9 | x | R21-03 |\n")
    if mut == "guard-undefined-id":
        sc = d / "SCORECARD.md"
        sc.write_text(sc.read_text(encoding="utf-8") + "\nThe undefined id Z9-99 appears here.\n")
    return d


def _selftest_pair(mut):
    """The (old, new) pair: new mirrors the measured selftest count of the REAL gate."""
    rc, n, last = run_gate_selftest(LANE, CENSUS_REL)
    if n is None:
        raise SetupError("selftest-fixture-build: real gate selftest unmeasurable rc=%s" % rc)
    new = r"^SOURCES_CENSUS_SELFTEST: PASS \(%d cases\)$" % n
    old = r"^SOURCES_CENSUS_SELFTEST: PASS \(88 cases\)$"
    if mut == "l1-pinned-88":
        new = old
    return old, new


def run_counter(tree, base=None):
    args = ["bash", str(LANE / "plans" / "round-68-c2.sh"), "--tree", str(tree)]
    env = {}
    if base is not None:
        args += ["--base-tree", str(base)]
    rc, out, err = run_cmd(args, cwd=LANE, timeout=1200, env=env)
    last = last_nonempty(out)
    lines = [l for l in (out or "").splitlines() if l.startswith("LEG ")]
    return rc, last, lines, out


def selftest():
    print("c2-record: selftest starting")
    cases = []
    base = mk_tree()
    neg1 = mk_tree("l1-pinned-88")
    neg2 = mk_tree("l2-missing") if False else None
    neg2 = mk_tree()
    # L2 negative fixture: drop R68-02 and claims-declared rows.
    led = neg2 / "corpus" / "claim-ledger.tsv"
    led.write_text("\n".join(l for l in led.read_text(encoding="utf-8").splitlines()
                             if not l.startswith("R68-02")) + "\n")
    neg3 = mk_tree("l3-planned-hidden")
    neg4 = mk_tree("cells-scored-missing")
    stub = mk_tree()
    # stub gate: prints the PASS line and nothing else (a printer).
    (stub / CENSUS_REL).write_text("#!/usr/bin/env bash\necho 'SOURCES_CENSUS_SELFTEST: PASS (89 cases)'\n")
    cron = mk_tree()
    # cron fixture: drop the freshness/calibration claims rows -> no claims-declared CLEAN
    cdt = cron / "corpus" / "claims-declared.tsv"
    cdt.write_text("round\tclaim\taxis\n")
    failed = 0
    total = 0
    for name, tree in [("positive", base), ("neg-l1-pin-88", neg1),
                       ("neg-l2-missing-row", neg2), ("neg-l3-planned-hidden", neg3),
                       ("neg-scored-missing-axis", neg4), ("neg-stub-gate", stub),
                       ("neg-claims-declared", cron)]:
        total += 1
        rc, last, legs, out = run_counter(tree, base)
        ok = (rc == 0 and last.startswith("C2_RECORD: mismatches=0 ")) if name == "positive" else \
             (rc != 0 and last.startswith("C2_RECORD:") and not last.startswith("C2_RECORD: SETUP"))
        if name == "positive":
            detail = "rc=%s last=%s legs=%d" % (rc, last, len(legs))
        else:
            detail = "rc=%s last=%s" % (rc, last[:100])
        print("selftest case %s: %s (%s)" % (name, "ok" if ok else "FAIL", detail))
        if not ok:
            failed += 1
    # negative control for L2's claims-declared row presence
    return failed, total


def main():
    global _scratch
    _scratch = _root_scratch(SCRATCH)
    if SELFTEST:
        try:
            failed, total = selftest()
        except SetupError as ex:
            print("C2_RECORD: SETUP %s" % ex)
            return 2
        if failed == 0:
            print("C2_RECORD_SELFTEST: PASS (%d cases)" % total)
            return 0
        print("C2_RECORD_SELFTEST: FAIL (%d cases, %d failed)" % (total, failed))
        return 1
    try:
        base_dir = base_tree_extract(_scratch)
    except SetupError as ex:
        print("C2_RECORD: SETUP %s" % ex)
        return 2
    print("c2-record: tree=%s base_sha=%s" % (TREE, BASE_SHA[:12]))
    leglines = []
    mm = 0
    for name, fn in [("L1", leg1), ("L2", leg2), ("L3", leg3)]:
        try:
            ok, detail = fn(TREE, base_dir)
        except SetupError as ex:
            print("C2_RECORD: SETUP leg=%s %s" % (name, ex))
            return 2
        except Exception as ex:  # noqa: BLE001
            ok, detail = False, "error %s: %s" % (type(ex).__name__, ex)
        verdict = "ok" if ok else "defect"
        if not ok:
            mm += 1
        leglines.append("LEG %s verdict=%s %s" % (name, verdict, detail))
    g, gdetail = guard(TREE, base_dir)
    print("c2-record: guard (%s)" % gdetail)
    for l in leglines:
        print(l)
    if mm == 0 and g == 1:
        print("C2_RECORD: mismatches=0 population=3 guard=1")
        return 0
    print("C2_RECORD: mismatches=%d population=3 guard=%d" % (mm, g))
    return 1


sys.exit(main())
PY

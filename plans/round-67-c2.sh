#!/usr/bin/env bash
# plans/round-67-c2.sh — C2_FIDELITY counter (kagi round 67, claim C2).
#
#   bash plans/round-67-c2.sh [--tree DIR] [--base-tree DIR] [--scratch DIR]
#   bash plans/round-67-c2.sh --selftest
#
# Frozen predicate: plans/round-67.md §C2 (frozen at aa8807e; never amended).
#
#   C2_FIDELITY: mismatches=<n> population=7 guard=<0|1>
#
# Seven legs, one record surface each, every verdict re-derived from committed
# bytes (a receipt's output line, an instrument's --selftest, a file's contents,
# or a path the record cites):
#
#   L1  the round-66 operability cell in SCORECARD.md carries the verdict and
#       the gate-out line of the receipt it cites (.ufo/waves/round-66/final/
#       c2-candidate.txt), and no placeholder pair in the asserting position.
#   L2  the SKILL.md pin on plans/round-66-c1.sh's selftest tally equals the
#       tally the instrument prints under --selftest (rc 0, failed=0).
#   L3  corpus/README.md holds a coverage-map row for
#       corpus/knowledge/claim-instrument-carrier-binding.md.
#   L4  .ufo/waves/round-66/claim-falsification.tsv holds exactly one neutral
#       row for .ufo/waves/round-66/w1/R66Sentinel.md, with a non-empty
#       statement of what it confirms and the referenced report on disk.
#   L5  .ufo/waves/round-66/claims.json carries, per claim, the counter token
#       the amended plan prints LAST (`C1_CARRIER` / `C2_PREFILE` /
#       `C3_CENSUS`), and no claim carries a superseded pre-amendment token.
#   L6  .ufo/waves/round-66/final/c3-base.txt exists with a provenance header
#       naming the round-66 claim BASE, and its content is checked against the
#       lane gate re-run on a `git archive d549ee6` extraction: the receipt's
#       `findings=`/`rows=` must equal the fresh run's and the four pinned
#       FINDING ids (SC_FETCH S155/S156 missing-provenance, SC_BODY_CITE
#       S148/S156 unrecorded) must be present, with no extra finding.
#   L7  corpus/lessons/round-66.md holds a `## Corrigendum` section whose table
#       logs the seven `used-by` old→new pairs (SOURCES contract v1 rule 2),
#       including S113. With history available the pairs are derived from the
#       round-66 claim BASE vs the round-67 claim BASE (`git show` of two
#       immutable commits), so a later round's edit cannot move the
#       expectation; without history the seven pinned round-66 additions are
#       removed from the working cells (the fixture path).
#
# GUARD (1 iff all three read 1):
#   a  the do-nothing control: the round-67 claim BASE (the sha plans/round-67.md
#      names, `git archive`d from a repo that holds its object — the measured
#      tree or the counter's own lane) reads mismatches=7
#   b  --selftest: a clean fixture reads 0 and each of the seven planted-defect
#      fixtures reads its own leg defect (the other six ok)
#   c  the anti-constant battery: each leg reads defect on a second fixture that
#      leaves the checked surface syntactically intact and moves the source the
#      leg must re-derive from
#
# Output: `c2-fidelity:` provenance/guard lines, one `LEG L<n> verdict=<...>
# <detail>` line per leg, then exactly one verdict line. Exit 0 iff mismatches=0
# and guard=1; 1 otherwise; 2 SETUP (prints `C2_FIDELITY: SETUP <reason>`).
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=$(dirname "$SELF_DIR")
TREE=$LANE
BASE_TREE=""
SCRATCH=""
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree)
      [ $# -ge 2 ] || { echo "C2_FIDELITY: SETUP missing-value --tree"; exit 2; }
      TREE=$2; shift 2 ;;
    --base-tree)
      [ $# -ge 2 ] || { echo "C2_FIDELITY: SETUP missing-value --base-tree"; exit 2; }
      BASE_TREE=$2; shift 2 ;;
    --scratch)
      [ $# -ge 2 ] || { echo "C2_FIDELITY: SETUP missing-value --scratch"; exit 2; }
      SCRATCH=$2; shift 2 ;;
    --selftest)
      SELFTEST=1; shift ;;
    -h|--help)
      sed -n '2,60p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *)
      echo "C2_FIDELITY: SETUP unknown-flag $1"; exit 2 ;;
  esac
done
[ -d "$TREE" ] || { echo "C2_FIDELITY: SETUP bad-tree $TREE"; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "C2_FIDELITY: SETUP no-python3"; exit 2; }

exec python3 -I -B - "$TREE" "$LANE" "$BASE_TREE" "$SCRATCH" "$SELFTEST" <<'PY'
import hashlib
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

TREE = Path(sys.argv[1])
LANE = Path(sys.argv[2])
BASE_TREE = Path(sys.argv[3]) if sys.argv[3] else None
SCRATCH = sys.argv[4]
SELFTEST = sys.argv[5] == "1"

POPULATION = 7
CARRIER = "corpus/knowledge/claim-instrument-carrier-binding.md"
MATRIX = "corpus/knowledge/claim-instrument-class-matrix.md"
SENTINEL = ".ufo/waves/round-66/w1/R66Sentinel.md"

# The seven `used-by` cells round 66 changed (fallback derivation only: the
# additions each row received, None = the row is new at the round-66 base).
FIXED_ADDITIONS = {
    "S113": [CARRIER],
    "S143": [CARRIER],
    "S145": [CARRIER],
    "S148": [MATRIX, CARRIER],
    "S152": [CARRIER],
    "S156": [MATRIX],
    "S164": None,
}

_c1_selftest_cache = {}
_census66_cache = {}


class SetupError(Exception):
    """A missing prerequisite: the counter exits 2, never a verdict."""


def mkdtemp_under(parent, prefix):
    """mkdtemp that recreates its parent if something external removed it."""
    for _ in range(3):
        try:
            return Path(tempfile.mkdtemp(prefix=prefix, dir=str(parent)))
        except FileNotFoundError:
            try:
                Path(parent).mkdir(parents=True, exist_ok=True)
            except OSError:
                pass
    raise SetupError("scratch-vanished:%s" % parent)


def mkdtemp_in(prefix):
    return mkdtemp_under(_scratch, prefix)


def read(p):
    return Path(p).read_text(encoding="utf-8", errors="replace")


def plan_base_sha(tree):
    """The round-66 claim BASE, as the round-66 plan's own header names it."""
    m = re.search(r"\b[0-9a-f]{40}\b", read(Path(tree) / "plans/round-66.md"))
    return m.group(0) if m else None


def parse_usedby(text):
    d = {}
    for line in text.splitlines():
        if line.startswith("| S"):
            c = [x.strip() for x in line.strip().strip("|").split("|")]
            if len(c) == 11:
                d[c[0]] = c[10]
    return d


def cell_tokens(s):
    s = (s or "").strip()
    if not s:
        return []
    return [t.strip() for t in s.split(",")]


# ---------------------------------------------------------------- legs ------

def leg1(tree):
    """SCORECARD's round-66 operability cell vs the receipt it cites."""
    sc = Path(tree) / "SCORECARD.md"
    if not sc.is_file():
        return False, "no-scorecard"
    rows = [(i + 1, l) for i, l in enumerate(read(sc).splitlines())
            if l.startswith("| operability |") and "[C2]" in l and "C2_PREFILE" in l]
    if len(rows) != 1:
        return False, "operability-rows=%d" % len(rows)
    ln, row = rows[0]
    cited = [t for t in re.findall(r"`([^`]+)`", row)
             if t.endswith(".txt") and "round-66/final/" in t and "c2" in Path(t).name
             and not any(ch in t for ch in "*?[")]
    cited = list(dict.fromkeys(cited))
    if len(cited) != 1:
        return False, "cited-receipts=%d" % len(cited)
    receipt = Path(tree) / cited[0]
    if not receipt.is_file():
        return False, "receipt-missing:%s" % cited[0]
    rl = read(receipt).splitlines()
    verdicts = [l for l in rl if l.startswith("C2_PREFILE: ")]
    if not verdicts:
        return False, "receipt-no-verdict:%s" % cited[0]
    verdict = verdicts[-1].strip()
    gate_out = ""
    for l in rl:
        if l.startswith("c2-prefile: gate-out ") and "PREFILE-FALSIFICATION: " in l:
            gate_out = "PREFILE-FALSIFICATION: " + l.split("PREFILE-FALSIFICATION: ", 1)[1].strip()
            break
    if not gate_out:
        return False, "receipt-no-gate-out:%s" % cited[0]
    cell_verdicts = [t.strip() for t in re.findall(r"`([^`]+)`", row)
                     if t.strip().startswith("C2_PREFILE: ")]
    if not cell_verdicts:
        return False, "cell-no-verdict-token"
    if cell_verdicts[0] != verdict:
        return False, 'first-verdict="%s" receipt="%s"' % (cell_verdicts[0], verdict)
    if gate_out not in row:
        return False, 'cell-lacks-gate-out:"%s"' % gate_out
    return True, 'scorecard:%d receipt:%s verdict="%s" gate_out="%s"' % (
        ln, cited[0], verdict, gate_out)


def run_c1_selftest(tree, inst):
    key = (hashlib.sha256(inst.read_bytes()).hexdigest(), str(tree))
    if key in _c1_selftest_cache:
        return _c1_selftest_cache[key]
    try:
        p = subprocess.run(["bash", str(inst), "--selftest"], cwd=str(tree),
                           capture_output=True, text=True, timeout=300)
        out = (p.stdout or "") + "\n" + (p.stderr or "")
        ms = re.findall(r"cases=(\d+)\s+failed=(\d+)", out)
        last = ([l for l in out.strip().splitlines() if l.strip()] or [""])[-1]
        res = (p.returncode, int(ms[-1][0]) if ms else None,
               int(ms[-1][1]) if ms else None, last)
    except Exception as e:  # noqa: BLE001 - a broken instrument is a defect
        res = (-1, None, None, "%s: %s" % (type(e).__name__, e))
    _c1_selftest_cache[key] = res
    return res


def leg2(tree):
    """SKILL.md's round-66 C1 selftest pin vs the instrument's --selftest."""
    skill = Path(tree) / "SKILL.md"
    inst = Path(tree) / "plans/round-66-c1.sh"
    if not skill.is_file():
        return False, "no-skill"
    if not inst.is_file():
        return False, "instrument-missing:plans/round-66-c1.sh"
    rows = [l for l in read(skill).splitlines()
            if "plans/round-66-c1.sh" in l and "--selftest" in l and "cases=" in l]
    if len(rows) != 1:
        return False, "skill-rows=%d" % len(rows)
    row = rows[0]
    rc, n, failed, last = run_c1_selftest(tree, inst)
    if n is None:
        return False, "instrument-no-cases rc=%d last=%r" % (rc, last)
    if rc != 0:
        return False, "instrument-rc=%d cases=%d" % (rc, n)
    if failed != 0:
        return False, "instrument-failed=%d cases=%d" % (failed, n)
    pin = re.findall(r"cases=(\d+)", row)
    if not pin:
        return False, "skill-no-pin"
    needle = "cases=%d failed=%d" % (n, failed)
    if needle not in row:
        return False, "skill-lacks-output:%s measured-cases=%d" % (needle, n)
    return True, "instrument cases=%d failed=%d rc=0 skill=%s" % (n, failed, needle)


def leg3(tree):
    """The coverage map row for the round-66 carrier-binding entry."""
    entry = Path(tree) / CARRIER
    rd = Path(tree) / "corpus/README.md"
    if not entry.is_file():
        return False, "entry-missing:%s" % CARRIER
    if not rd.is_file():
        return False, "readme-missing"
    hits = [(i + 1, l) for i, l in enumerate(read(rd).splitlines())
            if l.startswith("|") and "claim-instrument-carrier-binding.md" in l]
    if not hits:
        return False, "no-map-row"
    ln, row = hits[0]
    cells = row.strip().strip("|").split("|")
    if len(cells) < 3:
        return False, "map-row-cells=%d" % len(cells)
    return True, "map-row:%d cells=%d entry=present" % (ln, len(cells))


def leg4(tree):
    """The pre-file ledger's R66Sentinel row."""
    tsv = Path(tree) / ".ufo/waves/round-66/claim-falsification.tsv"
    if not tsv.is_file():
        return False, "ledger-missing"
    rows = [l.split("\t") for l in read(tsv).splitlines() if l.strip()]
    ids = set(r[0].strip() for r in rows if r)
    hits = [r for r in rows if len(r) >= 2 and r[1].strip() == SENTINEL]
    if not hits:
        return False, "no-sentinel-row"
    if len(hits) > 1:
        return False, "sentinel-rows=%d" % len(hits)
    row = hits[0]
    if len(row) < 5:
        return False, "sentinel-cols=%d" % len(row)
    claim = row[0].strip()
    if claim not in ids:
        return False, "sentinel-claim=%s not-ledger-id" % claim
    if row[2].strip() != "neutral":
        return False, "sentinel-class=%s" % row[2].strip()
    detail = row[4].strip()
    if len(detail) < 40:
        return False, "sentinel-detail-len=%d" % len(detail)
    if not (Path(tree) / SENTINEL).is_file():
        return False, "referenced-missing:%s" % SENTINEL
    return True, "row=present claim=%s class=neutral detail_len=%d referenced=present" % (
        claim, len(detail))


def leg5(tree):
    """claims.json's counter ids vs the plan as amended (last token per claim)."""
    plan = Path(tree) / "plans/round-66.md"
    cj = Path(tree) / ".ufo/waves/round-66/claims.json"
    if not plan.is_file():
        return False, "plan-missing"
    if not cj.is_file():
        return False, "claims-json-missing"
    per = {"1": [], "2": [], "3": []}
    for m in re.finditer(r"C([123])_[A-Z_]+", read(plan)):
        per[m.group(1)].append(m.group(0))
    expected, superseded = {}, set()
    for k, toks in per.items():
        if not toks:
            return False, "plan-no-token-C%s" % k
        expected[k] = toks[-1]
        superseded |= set(toks[:-1]) - {toks[-1]}
    if not superseded:
        return False, "plan-no-superseded-token"
    try:
        data = json.loads(read(cj))
    except Exception as e:  # noqa: BLE001
        return False, "claims-json-invalid:%s" % e
    if not isinstance(data, dict):
        return False, "claims-json-not-object"
    det = []
    for k in ("1", "2", "3"):
        key = "C" + k
        if key not in data or not isinstance(data[key], dict):
            return False, "claims-missing-%s" % key
        body = data[key]
        text = " ".join(str(body.get(f, "")) for f in ("title", "target"))
        if expected[k] not in text:
            return False, "%s-lacks-token:%s" % (key, expected[k])
        bad = sorted(t for t in superseded if t in text)
        if bad:
            return False, "%s-carries-superseded:%s" % (key, bad[0])
        det.append("%s=%s" % (key, expected[k]))
    return True, "expected=%s superseded=%s" % (
        ",".join(det), ",".join(sorted(superseded)))


REQUIRED_FINDINGS = [
    # plans/round-67.md Amendment A1 item 2: the four ids the d549ee6 lane gate
    # printed, pinned so a receipt that drops one reads defect.
    ("SC_FETCH", "S155", "missing-provenance"),
    ("SC_FETCH", "S156", "missing-provenance"),
    ("SC_BODY_CITE", "S148", "unrecorded"),
    ("SC_BODY_CITE", "S156", "unrecorded"),
]


def finding_tuples(text):
    out = []
    for line in text.splitlines():
        m = re.match(r"^FINDING (SC_[A-Z_]+) (.*)$", line.strip())
        if not m:
            continue
        rest = m.group(2)
        idm = re.search(r"\bid=(S\d+)\b", rest)
        toks = rest.split()
        out.append((m.group(1), idm.group(1) if idm else "",
                    toks[-1] if toks else ""))
    return out


def parse_census_line(line):
    m = re.match(r"^SOURCES_CENSUS: FAILED \(findings=(\d+) rows=(\d+)", line.strip())
    if m:
        return int(m.group(1)), int(m.group(2))
    m = re.match(r"^SOURCES_CENSUS: CLEAN\b.*\brows=(\d+)", line.strip())
    if m:
        return 0, int(m.group(1))
    return None


def extract_commit(sha, prefix):
    """Extract sha from the measured tree or the counter's lane, whichever holds it."""
    repos = []
    for d in (TREE, LANE):
        if str(d) not in repos:
            repos.append(str(d))
    last = "no-repo"
    for repo in repos:
        tmp = None
        try:
            have = subprocess.run(["git", "-C", repo, "cat-file", "-e",
                                   sha + ":corpus/sources-census.sh"],
                                  capture_output=True)
            if have.returncode != 0:
                last = "object-absent:%s" % repo
                continue
            p = subprocess.run(["git", "-C", repo, "archive", "--format=tar", sha],
                               capture_output=True, timeout=180)
            if p.returncode != 0:
                last = "git-archive-rc=%d:%s" % (p.returncode, repo)
                continue
            tmp = mkdtemp_in(prefix)
            with tarfile.open(fileobj=io.BytesIO(p.stdout)) as tf:
                tf.extractall(str(tmp))
            if not (tmp / "corpus/sources-census.sh").is_file():
                shutil.rmtree(tmp, ignore_errors=True)
                last = "base-incomplete:%s" % repo
                continue
            return tmp, None
        except Exception as e:  # noqa: BLE001
            if tmp is not None:
                shutil.rmtree(tmp, ignore_errors=True)
            last = "git-archive-error:%s:%s" % (e, repo)
    return None, last


def fresh_census66(tree):
    """The d549ee6 lane gate's own verdict and FINDING ids, run now (cached)."""
    sha = plan_base_sha(tree)
    if not sha:
        raise SetupError("fresh-census-no-base-sha")
    if sha in _census66_cache:
        v = _census66_cache[sha]
        if isinstance(v, str):
            raise SetupError(v)
        return v
    tmp, why = extract_commit(sha, "census66-")
    if tmp is None:
        _census66_cache[sha] = why
        raise SetupError(why)
    try:
        p = subprocess.run(["bash", str(tmp / "corpus/sources-census.sh")],
                           cwd=str(tmp), capture_output=True, text=True, timeout=600)
        out = (p.stdout or "") + "\n" + (p.stderr or "")
        summary, nums, tuples = None, None, []
        for line in out.splitlines():
            if line.startswith("SOURCES_CENSUS: "):
                summary = line.strip()
                nums = parse_census_line(line)
            tuples += finding_tuples(line)
        if summary is None or nums is None:
            why = "fresh-census-no-verdict"
        else:
            ev = {"findings": nums[0], "rows": nums[1],
                  "tuples": tuples, "line": summary, "rc": p.returncode}
            _census66_cache[sha] = ev
            return ev
    except Exception as e:  # noqa: BLE001
        why = "fresh-census-error:%s" % e
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    _census66_cache[sha] = why
    raise SetupError(why)


def leg6(tree):
    """The reconstructed c3-base.txt receipt and its provenance header."""
    p = Path(tree) / ".ufo/waves/round-66/final/c3-base.txt"
    if not p.is_file():
        return False, "receipt-missing"
    txt = read(p)
    if not txt.strip():
        return False, "receipt-empty"
    sha = plan_base_sha(tree)
    if not sha:
        return False, "plan-no-base-sha"
    lines = txt.splitlines()
    header = []
    for l in lines:
        if l.startswith("#"):
            header.append(l)
        elif l.strip() == "" and not header:
            continue
        else:
            break
    if not header:
        return False, "no-provenance-header"
    h = "\n".join(header)
    if sha not in h:
        return False, "header-lacks-base:%s" % sha[:12]
    if "provenance" not in h.lower():
        return False, "header-lacks-provenance"
    if "reconstruct" not in h.lower():
        return False, "header-lacks-reconstruct"
    gate = [l for l in lines if re.match(r"^SOURCES_CENSUS: (FAILED|CLEAN)\b", l)]
    if not gate:
        return False, "no-gate-line"
    receipt_nums = parse_census_line(gate[-1])
    if receipt_nums is None:
        return False, "gate-line-unparsed:%r" % gate[-1]
    fresh = fresh_census66(tree)  # SetupError propagates: a missing prerequisite
    if receipt_nums != (fresh["findings"], fresh["rows"]):
        return False, "gate-mismatch:receipt=findings=%d,rows=%d fresh=findings=%d,rows=%d" % (
            receipt_nums[0], receipt_nums[1], fresh["findings"], fresh["rows"])
    receipt_tuples = finding_tuples(txt)
    missing = [t for t in REQUIRED_FINDINGS if t not in receipt_tuples]
    if missing:
        return False, "findings-missing:%s" % ",".join(
            "%s/%s/%s" % t for t in missing)
    if set(receipt_tuples) != set(fresh["tuples"]):
        return False, "findings-set-mismatch:receipt=%s fresh=%s" % (
            sorted(set(receipt_tuples)), sorted(set(fresh["tuples"])))
    return True, "receipt=present header_lines=%d base=%s gate=%r findings=%d rows=%d fresh_run=ok" % (
        len(header), sha[:12], gate[-1], fresh["findings"], fresh["rows"])


def parse_corrigendum(text):
    lines = text.splitlines()
    heads = [i for i, l in enumerate(lines) if re.match(r"^##\s+Corrigendum", l, re.I)]
    if not heads:
        return None
    start = heads[0]
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("## "):
            end = j
            break
    tbl = {}
    for l in lines[start + 1:end]:
        if not l.startswith("|"):
            continue
        c = [x.strip() for x in l.strip().strip("|").split("|")]
        if len(c) < 2 or not re.fullmatch(r"S\d{3}", c[0]):
            continue
        parts = c[1].split("→")
        if len(parts) != 2:
            return ("bad-row", c[0])
        old_b = re.findall(r"`([^`]*)`", parts[0])
        new_b = re.findall(r"`([^`]*)`", parts[1])
        tbl[c[0]] = (old_b[0] if old_b else None,
                     new_b[0] if new_b else None, c[1])
    return tbl


def git_show_usedby(tree, sha):
    try:
        show = subprocess.run(["git", "-C", str(tree), "show", sha + ":corpus/SOURCES.md"],
                              capture_output=True, text=True, timeout=60)
        if show.returncode == 0:
            return parse_usedby(show.stdout)
    except Exception:  # noqa: BLE001 - no history means fallback, never a pass
        pass
    return None


def working_tip_sha(tree):
    p = Path(tree) / "plans/round-67.md"
    if not p.is_file():
        return None
    m = re.search(r"\b[0-9a-f]{40}\b", read(p))
    return m.group(0) if m else None


def derive_pairs(tree, sha):
    """The seven used-by cells round 66 changed: ({(old,new)}, source).

    Git path: round-66 base vs the round-67 claim BASE (immutable commits), so
    a later round's edit to one of these cells cannot move the expectation. If
    the round-67 BASE object is absent the working file is the tip; without
    history the seven pinned round-66 additions are removed from the working
    cells (the fixtures' path)."""
    new = parse_usedby(read(Path(tree) / "corpus/SOURCES.md"))
    base = None
    try:
        top = subprocess.run(["git", "-C", str(tree), "rev-parse", "--show-toplevel"],
                             capture_output=True, text=True, timeout=30)
        if (top.returncode == 0
                and os.path.realpath(top.stdout.strip()) == os.path.realpath(str(tree))):
            base = git_show_usedby(tree, sha)
    except Exception:  # noqa: BLE001 - no history means fallback, never a pass
        base = None
    if base is not None:
        tip_sha = working_tip_sha(tree)
        tip = git_show_usedby(tree, tip_sha) if tip_sha else None
        src = "git:%s..%s" % (sha[:12], tip_sha[:12] if tip else "worktree")
        if tip is None:
            tip = new
        pairs = {}
        for k, v in tip.items():
            if base.get(k) != v:
                pairs[k] = (base.get(k), v)
        return pairs, src
    pairs = {}
    for k, adds in FIXED_ADDITIONS.items():
        if k not in new:
            return None, "fallback-missing-row:%s" % k
        v = new[k]
        if adds is None:
            pairs[k] = (None, v)
            continue
        rem = cell_tokens(v)
        for a in adds:
            if a not in rem:
                return None, "fallback-cell-lacks:%s:%s" % (k, a)
            rem.remove(a)
        pairs[k] = ("—" if rem == [] else ", ".join(rem), v)
    return pairs, "fallback"


def leg7(tree):
    """The round-66 lesson's used-by old->new corrigendum (incl. S113)."""
    lesson = Path(tree) / "corpus/lessons/round-66.md"
    if not lesson.is_file():
        return False, "lesson-missing"
    sha = plan_base_sha(tree)
    if not sha:
        return False, "plan-no-base-sha"
    tbl = parse_corrigendum(read(lesson))
    if tbl is None:
        return False, "no-corrigendum-section"
    if isinstance(tbl, tuple):
        return False, "corrigendum-%s:%s" % tbl
    pairs, how = derive_pairs(tree, sha)
    if pairs is None:
        return False, how
    if len(pairs) != POPULATION:
        return False, "derived-population=%d" % len(pairs)
    missing = sorted(set(pairs) - set(tbl))
    extra = sorted(set(tbl) - set(pairs))
    if missing or extra:
        return False, "ids-missing=%s ids-extra=%s" % (missing, extra)
    for k in sorted(pairs):
        old_e, new_e = pairs[k]
        old_s, new_s, raw = tbl[k]
        expected_tokens = cell_tokens(new_e)
        if old_e is None:
            if not re.search(r"new row", raw, re.I):
                return False, "%s-old-not-new-row:%r" % (k, raw)
        else:
            if old_s is None:
                return False, "%s-old-unparsed" % k
            if cell_tokens(old_s) != cell_tokens(old_e):
                return False, '%s-old="%s" expected="%s"' % (k, old_s, old_e)
        if new_s is None:
            return False, "%s-new-unparsed" % k
        ntok = cell_tokens(new_s)
        if old_e is not None and ntok and ntok[0] == "…":
            expanded = cell_tokens(old_e) + ntok[1:]
        else:
            expanded = ntok
        if expanded != expected_tokens:
            return False, '%s-new-expands-to="%s" expected="%s"' % (
                k, ", ".join(expanded), ", ".join(expected_tokens))
    return True, "corrigendum ids=%d pairs=%d source=%s" % (
        len(tbl), len(pairs), how)


LEGS = [("L1", leg1), ("L2", leg2), ("L3", leg3), ("L4", leg4),
        ("L5", leg5), ("L6", leg6), ("L7", leg7)]


def measure(tree):
    out = []
    for name, fn in LEGS:
        try:
            ok, detail = fn(tree)
        except SetupError:
            raise
        except Exception as e:  # noqa: BLE001 - never a pass on an exception
            ok, detail = False, "error:%s:%s" % (type(e).__name__, e)
        out.append((name, ok, detail))
    return out


# ------------------------------------------------------------ fixtures ------

FIX_CARRIER_CELLS = {
    "S113": "corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md",
    "S143": "corpus/lessons/round-63.md",
    "S145": "corpus/knowledge/claim-instrument-heldout.md",
    "S148": "corpus/lessons/round-64.md",
    "S152": "—",
    "S156": "corpus/lessons/round-65.md",
}
FIX_SHA = "d549ee6eb8770a49938b78f49cf79e36d9c1c2e8"


def fixture_files():
    src = "# fixture SOURCES\n\n"
    src += "| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |\n"
    src += "|---|---|---|---|---|---|---|---|---|---|---|\n"
    rows = {}
    for k in ("S113", "S143", "S145", "S148", "S152", "S156"):
        rows[k] = FIX_CARRIER_CELLS[k] + ", " + CARRIER
    rows["S148"] = FIX_CARRIER_CELLS["S148"] + ", " + MATRIX + ", " + CARRIER
    rows["S156"] = FIX_CARRIER_CELLS["S156"] + ", " + MATRIX
    rows["S164"] = MATRIX + ", corpus/lessons/round-66.md, " + CARRIER
    for k in ("S113", "S143", "S145", "S148", "S152", "S156", "S164"):
        src += "| %s | fixture source | docs | A | scope | anchor | teaches | mined | 2026-01-01 | 90d | %s |\n" % (
            k, rows[k])
    plan = ("# Round 66 — fixture plan — Claim BASE `%s`\n\n"
            "C1_CARRIER: fixture\nC2_CLAIMS: fixture\nC3_SELFREF: fixture\n\n"
            "## Amendments\n\nC2_PREFILE: fixture\nC3_CENSUS: fixture\n" % FIX_SHA)
    lesson = ("# Round 66 — fixture\n\n## Corrigendum — round 66 (fixture)\n\n"
              "| id | used-by old → new |\n|---|---|\n")
    for k in ("S113", "S143", "S145", "S148", "S152", "S156"):
        add = MATRIX + ", " + CARRIER if k == "S148" else (
            MATRIX if k == "S156" else CARRIER)
        lesson += "| %s | `%s` → `… , %s` |\n" % (k, FIX_CARRIER_CELLS[k], add)
    lesson += "| S164 | (new row) → `%s` |\n" % rows["S164"]
    verdict = "C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0"
    gate_out = "PREFILE-FALSIFICATION: SETUP findings=1"
    receipt = ("c2-prefile: gate rc=2 no-verdict-line\n"
               "c2-prefile: gate-out FINDING wave-missing .ufo/waves/round-66/w1-results.json\n"
               "c2-prefile: gate-out %s\n"
               "c2-prefile: claims-declared CLAIMS_DECLARED: CLEAN (claims=59)\n"
               "c2-prefile: guard a=1 b=0 c=0 d=1 claims-declared=1\n%s\n" % (gate_out, verdict))
    scorecard = ("# fixture scorecard\n\n"
                 "| operability | 9 → 9 | [C2] `bash plans/round-66-c2.sh` ⇒ `%s` "
                 "(receipt `.ufo/waves/round-66/final/c2-candidate.txt`); the fleet gate "
                 "reads `%s`. |\n" % (verdict, gate_out))
    instrument = ('#!/usr/bin/env bash\n'
                  '# fixture instrument\n'
                  'if [ "${1:-}" = "--selftest" ]; then\n'
                  '  echo "c1-carrier: selftest cases=45 failed=0"\n'
                  '  exit 0\n'
                  'fi\n'
                  'echo "c1-fixture: no-tree-mode" >&2\n'
                  'exit 2\n')
    skill = ("# fixture SKILL\n\n"
             "| C1 carrier-binding counter (`plans/round-66-c1.sh`) | gate | "
             "`bash plans/round-66-c1.sh --selftest` ⇒ `c1-carrier: selftest cases=45 failed=0` |\n")
    readme = ("# fixture coverage map\n\n"
              "| Claim-instrument carrier binding | `knowledge/claim-instrument-carrier-binding.md` | fixture entry |\n")
    ledger = ("C1\t.ufo/waves/round-66/w1/R66Reviewer.md\tfalsifies-wording\tplans/round-66.md\tF1 fixture statement long enough to count\n"
              "C2\t.ufo/waves/round-66/w1/R66ExecC2Claims.md\tneutral\t-\tfixture neutral row statement long enough to count\n"
              "C1\t%s\tneutral\t-\tV-1 fixture closed; V-2 fixture closed; I-2 fixture noted; no claim wording falsified\n" % SENTINEL)
    claims = json.dumps({
        "_provenance": "fixture: re-derived from plans/round-66.md as amended; "
                       "the pre-amendment pairs C2_CLAIMS/C3_SELFREF were superseded",
        "C1": {"axis": "freshness", "title": "C1_CARRIER: fixture", "target": "drift=1"},
        "C2": {"axis": "operability", "title": "C2_PREFILE: fixture", "target": "gate=1"},
        "C3": {"axis": "calibration", "title": "C3_CENSUS: fixture", "target": "findings=0"},
    }, indent=1) + "\n"
    c3base = ("# reconstructed receipt — fixture\n"
              "# provenance: re-derived from git archive %s\n"
              "FINDING SC_FETCH id=S156 missing-provenance\n"
              "FINDING SC_FETCH id=S155 missing-provenance\n"
              "FINDING SC_BODY_CITE entry=corpus/knowledge/claim-instrument-class-matrix.md id=S148 unrecorded\n"
              "FINDING SC_BODY_CITE entry=corpus/knowledge/claim-instrument-class-matrix.md id=S156 unrecorded\n"
              "SOURCES_CENSUS: FAILED (findings=4 rows=155)\n" % FIX_SHA)
    return {
        "corpus/SOURCES.md": src,
        "plans/round-66.md": plan,
        "corpus/lessons/round-66.md": lesson,
        ".ufo/waves/round-66/final/c2-candidate.txt": receipt,
        "SCORECARD.md": scorecard,
        "plans/round-66-c1.sh": instrument,
        "SKILL.md": skill,
        "corpus/README.md": readme,
        ".ufo/waves/round-66/claim-falsification.tsv": ledger,
        ".ufo/waves/round-66/claims.json": claims,
        ".ufo/waves/round-66/final/c3-base.txt": c3base,
        CARRIER: "# fixture entry\n",
        SENTINEL: "# fixture sentinel report\n",
    }


def build_fixture(root, files):
    root = Path(root)
    for rel, body in files.items():
        if body is None:  # a deleted file
            continue
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(body, encoding="utf-8")
    (root / "plans/round-66-c1.sh").chmod(0o755)
    return root


def mutate(files, edits):
    out = dict(files)
    for rel, fn in edits:
        out[rel] = fn(out[rel])
    return out


def anti_constant_cases():
    verdict = "C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0"
    sha_line = "# provenance: re-derived from git archive " + FIX_SHA
    return [
        # leg, name, edits -- each leaves the surface string present and moves
        # the source the leg must re-derive from.
        ("L1", "cell-constant", [
            ("SCORECARD.md", lambda s: s.replace(verdict, "C2_PREFILE: gate=9 claims=0 rows=0 attack_seats=0 guard=0", 1)),
        ]),
        ("L1", "receipt-drift", [
            (".ufo/waves/round-66/final/c2-candidate.txt",
             lambda s: s.replace(verdict, "C2_PREFILE: gate=9 claims=0 rows=0 attack_seats=0 guard=0", 1)),
        ]),
        ("L2", "pin-constant", [
            ("plans/round-66-c1.sh", lambda s: s.replace("cases=45", "cases=44", 1)),
        ]),
        ("L2", "pin-failed", [
            ("plans/round-66-c1.sh", lambda s: s.replace("failed=0", "failed=1", 1)),
        ]),
        ("L3", "row-wrong-entry", [
            ("corpus/README.md",
             lambda s: s.replace("knowledge/claim-instrument-carrier-binding.md",
                                 "knowledge/claim-instrument-other.md", 1)),
        ]),
        ("L3", "row-absent", [
            ("corpus/README.md",
             lambda s: s.replace(
                 "| Claim-instrument carrier binding | `knowledge/claim-instrument-carrier-binding.md` | fixture entry |\n", "", 1)),
        ]),
        ("L4", "referenced-absent", [
            (SENTINEL, lambda s: None),
        ]),
        ("L4", "row-short-detail", [
            (".ufo/waves/round-66/claim-falsification.tsv",
             lambda s: re.sub(r"V-1 fixture closed[^\n]*", "short", s, count=1)),
        ]),
        ("L5", "token-both", [
            (".ufo/waves/round-66/claims.json",
             lambda s: s.replace('"C2_PREFILE: fixture"', '"C2_PREFILE (was C2_CLAIMS): fixture"', 1)),
        ]),
        ("L5", "token-superseded", [
            (".ufo/waves/round-66/claims.json",
             lambda s: s.replace('"C2_PREFILE: fixture"', '"C2_CLAIMS: fixture"', 1)),
        ]),
        ("L6", "header-sha-drift", [
            (".ufo/waves/round-66/final/c3-base.txt",
             lambda s: s.replace(sha_line, "# provenance: re-derived from git archive " + "0" * 40, 1)),
        ]),
        ("L6", "gate-line-absent", [
            (".ufo/waves/round-66/final/c3-base.txt",
             lambda s: s.replace("SOURCES_CENSUS: FAILED (findings=4 rows=155)\n", "", 1)),
        ]),
        ("L6", "false-clean", [
            (".ufo/waves/round-66/final/c3-base.txt",
             lambda s: s.replace("SOURCES_CENSUS: FAILED (findings=4 rows=155)",
                                 "SOURCES_CENSUS: CLEAN (findings=0 rows=155)", 1)),
        ]),
        ("L6", "missing-finding", [
            (".ufo/waves/round-66/final/c3-base.txt",
             lambda s: re.sub(r"FINDING SC_BODY_CITE [^\n]*id=S148 unrecorded\n", "", s, count=1)),
        ]),
        ("L7", "new-cell-drift", [
            ("corpus/lessons/round-66.md",
             lambda s: s.replace(
                 "| S113 | `corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md` → `… , corpus/knowledge/claim-instrument-carrier-binding.md` |",
                 "| S113 | `corpus/knowledge/iso-11770-3-edition-status.md, corpus/lessons/round-55.md` → `… , corpus/knowledge/claim-instrument-wrong.md` |", 1)),
        ]),
        ("L7", "row-absent", [
            ("corpus/lessons/round-66.md",
             lambda s: re.sub(r"\| S113 \|[^\n]*\n", "", s, count=1)),
        ]),
    ]


def run_selftest(scratch_root):
    """(ok_b, ok_c, findings). b = clean 0 + one defect per leg; c = anti-constant."""
    findings = []
    cases = 0
    base_files = fixture_files()
    clean = build_fixture(scratch_root / "clean", base_files)
    res = measure(clean)
    mismatches = sum(1 for _, ok, _ in res if not ok)
    cases += 1
    if mismatches != 0:
        bad = ["%s:%s" % (n, d) for n, ok, d in res if not ok]
        findings.append("FIX clean expect=mismatches=0 observed=%d [%s]" % (
            mismatches, "; ".join(bad)))
    # one planted defect per leg: the leg's own surface, absent or wrong
    verdict = "C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0"
    planted = [
        ("L1", "planted", [("SCORECARD.md",
                            lambda s: s.replace(verdict,
                                                "C2_PREFILE: gate=A claims=3 rows=R attack_seats=K guard=G", 1))]),
        ("L2", "planted", [("plans/round-66-c1.sh",
                            lambda s: s.replace("cases=45", "cases=14", 1))]),
        ("L3", "planted", [("corpus/README.md",
                            lambda s: re.sub(r"\| Claim-instrument carrier binding \|[^\n]*\n", "", s, count=1))]),
        ("L4", "planted", [(".ufo/waves/round-66/claim-falsification.tsv",
                            lambda s: re.sub(r"C1\t%s\tneutral\t[^\n]*\n" % re.escape(SENTINEL), "", s, count=1))]),
        ("L5", "planted", [(".ufo/waves/round-66/claims.json",
                            lambda s: s.replace('"C2_PREFILE: fixture"', '"C2_CLAIMS: fixture"', 1))]),
        ("L6", "planted", [(".ufo/waves/round-66/final/c3-base.txt", lambda s: None)]),
        ("L7", "planted", [("corpus/lessons/round-66.md",
                            lambda s: re.sub(r"\| S113 \|[^\n]*\n", "", s, count=1))]),
    ]
    ok_b = mismatches == 0
    for leg, name, edits in planted:
        files = mutate(base_files, edits)
        root = build_fixture(scratch_root / ("%s-%s" % (leg, name)), files)
        res = measure(root)
        cases += 1
        seen = {n: ok for n, ok, _ in res}
        if seen.get(leg) is not False:
            findings.append("FIX %s-%s expect=defect observed=ok" % (leg, name))
            ok_b = False
        others = [n for n in seen if n != leg and not seen[n]]
        if others:
            findings.append("FIX %s-%s expect=others-ok observed=defect:%s" % (
                leg, name, ",".join(others)))
            ok_b = False
    ok_c = True
    for leg, name, edits in anti_constant_cases():
        files = mutate(base_files, edits)
        root = build_fixture(scratch_root / ("%s-%s" % (leg, name)), files)
        res = measure(root)
        cases += 1
        seen = {n: ok for n, ok, _ in res}
        if seen.get(leg) is not False:
            findings.append("FIX %s-%s expect=defect observed=ok" % (leg, name))
            ok_c = False
        others = [n for n in seen if n != leg and not seen[n]]
        if others:
            findings.append("FIX %s-%s expect=others-ok observed=defect:%s" % (
                leg, name, ",".join(others)))
            ok_c = False
    return ok_b, ok_c, findings, cases


# ------------------------------------------------------------------ main -----

def die(reason):
    print("C2_FIDELITY: SETUP %s" % reason)
    sys.exit(2)


def scratch_root_for(tree):
    if SCRATCH:
        root = Path(SCRATCH)
    else:
        root = Path(os.environ.get("HYAKU_SCRATCH", "/fast/scratch/hyaku")) / "kagi-r67-c2"
    real_root = os.path.realpath(str(root))
    real_tree = os.path.realpath(str(tree))
    if real_root == real_tree or real_root.startswith(real_tree + os.sep):
        die("scratch-inside-tree")
    try:
        root.mkdir(parents=True, exist_ok=True)
    except Exception as e:  # noqa: BLE001
        die("scratch-unwritable:%s" % e)
    return root


def base_sha_and_repos():
    """The round-67 claim BASE sha (from a frozen plan) and candidate repos."""
    sha = None
    for plan_dir in (TREE, LANE):
        plan = plan_dir / "plans/round-67.md"
        if plan.is_file():
            m = re.search(r"\b[0-9a-f]{40}\b", read(plan))
            if m:
                sha = m.group(0)
                break
    if not sha:
        return None, [], "no-round-67-plan"
    repos = []
    for d in (TREE, LANE):
        if str(d) not in repos:
            repos.append(str(d))
    return sha, repos, None


def extract_claims_base():
    """The round-67 claim BASE, extracted from a repo that holds its object."""
    sha, repos, why = base_sha_and_repos()
    if why:
        return None, why
    tmp = mkdtemp_in("base-")
    last = "no-repo"
    for repo in repos:
        try:
            have = subprocess.run(["git", "-C", repo, "cat-file", "-e",
                                   sha + ":corpus/SOURCES.md"], capture_output=True)
            if have.returncode != 0:
                last = "object-absent:%s" % repo
                continue
            p = subprocess.run(["git", "-C", repo, "archive", "--format=tar", sha],
                               capture_output=True, timeout=180)
            if p.returncode != 0:
                last = "git-archive-rc=%d:%s" % (p.returncode, repo)
                continue
            with tarfile.open(fileobj=io.BytesIO(p.stdout)) as tf:
                tf.extractall(str(tmp))
            if (tmp / "corpus/SOURCES.md").is_file():
                return tmp, sha
            last = "base-incomplete:%s" % repo
        except Exception as e:  # noqa: BLE001
            last = "git-archive-error:%s:%s" % (e, repo)
    shutil.rmtree(tmp, ignore_errors=True)
    return None, last


def drop_scratch():
    shutil.rmtree(_scratch, ignore_errors=True)
    if not SCRATCH:  # we own the default root; remove it when empty
        try:
            _scratch.parent.rmdir()
        except OSError:
            pass


def main():
    global _scratch
    if SELFTEST:
        try:
            _scratch = mkdtemp_under(scratch_root_for(TREE), "selftest-")
        except SetupError as e:
            die(str(e))
        try:
            ok_b, ok_c, findings, cases = run_selftest(_scratch)
        except Exception as e:  # noqa: BLE001 - a broken self-test is a FAIL
            ok_b, ok_c, findings, cases = False, False, ["harness-error:%s:%s" % (
                type(e).__name__, e)], 0
        finally:
            drop_scratch()
        for f in findings:
            print("c2-fidelity: %s" % f)
        verdict = "PASS" if (ok_b and ok_c) else "FAIL"
        print("C2_FIDELITY_SELFTEST: %s (cases=%d failed=%d guard_b=%d guard_c=%d)" % (
            verdict, cases, len(findings), ok_b, ok_c))
        sys.exit(0 if (ok_b and ok_c) else 1)

    # prerequisites: the tree must be a lane-shaped tree
    for rel in ("corpus/SOURCES.md", "plans/round-66.md", "SCORECARD.md", "SKILL.md"):
        if not (TREE / rel).is_file():
            die("tree-lacks-%s" % rel)
    if not plan_base_sha(TREE):
        die("tree-plan-no-base-sha")

    try:
        _scratch = mkdtemp_under(scratch_root_for(TREE), "run-")
    except SetupError as e:
        die(str(e))
    try:
        res = measure(TREE)
    except SetupError as e:
        die(str(e))
    for name, ok, detail in res:
        print("LEG %s verdict=%s %s" % (name, "ok" if ok else "defect", detail))
    mismatches = sum(1 for _, ok, _ in res if not ok)

    # guard (a): the do-nothing control — the round-67 claim BASE must read
    # one defect per leg, and the counter must not reach the target on it.
    if BASE_TREE is not None:
        if not BASE_TREE.is_dir():
            die("bad-base-tree:%s" % BASE_TREE)
        try:
            base_n = sum(1 for _, ok, _ in measure(BASE_TREE) if not ok)
        except SetupError as e:
            die(str(e))
    else:
        extracted, why = extract_claims_base()
        if extracted is None:
            die(why)
        try:
            base_n = sum(1 for _, ok, _ in measure(extracted) if not ok)
        except SetupError as e:
            die(str(e))
        finally:
            shutil.rmtree(extracted, ignore_errors=True)
    guard_a = base_n == POPULATION

    # guard (b)/(c): the fixture lane
    try:
        fixtures = mkdtemp_in("guard-")
    except SetupError as e:
        die(str(e))
    try:
        ok_b, ok_c, findings, cases = run_selftest(fixtures)
    except Exception as e:  # noqa: BLE001 - a broken self-test is guard 0
        ok_b, ok_c, findings, cases = False, False, ["harness-error:%s:%s" % (
            type(e).__name__, e)], 0
    finally:
        shutil.rmtree(fixtures, ignore_errors=True)
    for f in findings:
        print("c2-fidelity: selftest %s" % f)

    guard = 1 if (guard_a and ok_b and ok_c) else 0
    print("c2-fidelity: tree=%s population=%d mismatches=%d" % (TREE, POPULATION, mismatches))
    print("c2-fidelity: guard a=%d b=%d c=%d base_defects=%d selftest_cases=%d" % (
        guard_a, ok_b, ok_c, base_n, cases))
    print("C2_FIDELITY: mismatches=%d population=%d guard=%d" % (
        mismatches, POPULATION, guard))
    drop_scratch()
    sys.exit(0 if (mismatches == 0 and guard == 1) else 1)


main()
PY

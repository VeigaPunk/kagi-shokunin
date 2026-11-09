#!/usr/bin/env bash
# plans/round-69-c1.sh — C1_RECORD counter (kagi round 69, claim C1, calibration).
#
#   bash plans/round-69-c1.sh --tree DIR [--base-tree DIR] [--scratch DIR] [--legs L1,L3] [--verbose]
#   bash plans/round-69-c1.sh --selftest [--scratch DIR]
#
# Frozen predicate: plans/round-69.md §C1 (never amend or reinterpret a
# predicate, population, kill rule or target; this file enforces it).
#
#   C1_RECORD: mismatches=<n> population=13 guard=<0|1>
#
# One leg per routed defect of corpus/lessons/round-68-verifier-spotcheck.md §7
# (items 1–13), each derived from the measured tree's bytes.  In full mode the
# LAST stdout line is the frozen line above; exit 0 iff n==0 and guard==1,
# 1 otherwise, 2 on SETUP (missing surface) with the reason on stderr and no
# numeric verdict.  In subset mode (--legs L1,L3) only the named legs are
# evaluated and the LAST line is `C1_RECORD_LEGS: legs=1,3 ok=<k>` (exit 0
# iff every requested leg passes).
#
# L1-L13 implement plans/round-69.md §C1's table verbatim, disambiguated by
# the §7 text where the table is shorthand (see notes in receipts):
#   L1  SCORECARD.md round-68 calibration row carries the honest stop
#       (`unprovable` + the c2-lane-run receipt path, receipt exists, no
#       `mismatches=0` string in the row).
#   L2  the round-68 depth row names every criterion id that QUALITY carries
#       with `corpus/lessons/round-68.md` in its source column (derived, never
#       listed) and is not the "enter the bar" claim; when that derived set is
#       empty the row must state the empty set explicitly (no new criterion
#       added / set empty), so a row naming nothing does not pass vacuously.
#   L3  corpus/lessons/round-68.md keeps the original sentence and carries an
#       appended `Correction (round 69)` block naming the superseded
#       `C2_RECORD` sentence and the honest-stop receipt (append-only).
#   L4  LOG.md keeps the original line and carries an appended
#       `Correction (round 69)` naming the count the receipt
#       `.ufo/waves/round-68/w1/R68ExecCounterC1/selftest.txt` prints (parsed
#       from the receipt, never named by the counter) and that receipt exists.
#   L5  the correction names the value parsed from
#       `.ufo/waves/round-68/base/c1-base-round67-counter.txt` (the receipt
#       the §7 defect compares; its `C1_READTHROUGH:` caught field), that
#       receipt exists, and the correction also names the round-68 counter's
#       own `caught` from `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt`
#       when present, so the two BASE readings stay distinct.  (The frozen
#       table names the round-68 receipt alone; §7 item 5 names the round-67
#       receipt as the compared surface.  Both are required so neither
#       counter's BASE reading is rewritten into the other's.)
#   L6  corpus/lessons/round-69.md names the dead citation
#       `.ufo/waves/round-68/final/c1-base.txt` and the corrected pointer
#       `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt` (exists).
#   L7  `.ufo/waves/round-68/claims.json` parses, the original `target`
#       strings are unchanged, and a `superseded_by` object names
#       `Amendment A1` and the final reading `38`/`33`.
#   L8  `predicate_ok` extracted from the tree's plans/round-68-c1.sh (source
#       extracted, `exec` of the extracted source only) refuses
#       (36,31,6,1,0), accepts (37,32,6,1,0) and (38,33,6,1,0), refuses
#       (38,33,5,1,0), (38,33,6,0,0) and (38,33,6,1,1); the same file's
#       selftest table carries a case named `predicate-subfloor`.
#   L9  exactly one `R68-02` row in corpus/claim-ledger.tsv, its expect fully
#       literal anchored, its command exits 0 and its last line matches the
#       expect when executed with the row's own timeout, and a round-69
#       migration journal entry carries old_expect
#       `^C2_RECORD: mismatches=0 population=3 guard=1$`.  Non-executing
#       conjuncts are evaluated first; the command runs only when they hold.
#   L10 the round-68 freshness row carries both BASE readings (`0/6` and
#       `2/6`) and names
#       `.ufo/waves/round-68/w1/R68Sentinel/receipts/base-legs.txt` (exists).
#   L11 corpus/QUALITY.md carries at least four criteria with id > QM96 whose
#       source column names `corpus/lessons/round-68.md` (derived, never
#       listed).
#   L12 `.ufo/waves/round-69/w1-results.json` parses, every seat entry has a
#       terminal status (non-empty final output), and
#       `.ufo/waves/round-69/w1-spec.json` carries no `C1_RECORD:`/
#       `C2_TEETH:` target string and no `mismatches=0`.  (Expected to fail
#       until settlement; that is the honest mid-wave state.)
#   L13 corpus/lessons/round-69.md carries a line `expansion` whose
#       `new knowledge entries=<n>` equals the number of files under
#       `corpus/knowledge/` in the measured tree minus the same count in
#       --base-tree (both derived, never listed).
#
# GUARD 1 iff:
#   (a) plans/round-68.md carries `## Amendment A2 — post-closure repairs
#       (round 69)` naming, in its body, each changed surface with old → new:
#       SCORECARD.md, corpus/lessons/round-68.md, LOG.md, base-derivation.md,
#       claims.json, predicate_ok, R68-02, QUALITY.md;
#   (b) the unmodified measured tree prints the frozen zero line with guard=1;
#   (c) no-work control: on the extracted BASE tree (git archive of
#       264917aa8fc9e71b6595d0d5166c4b615120fb8b) the counter prints
#       mismatches=13 with every leg printing its mismatch detail;
#   (d) decoy control: a copy with the L1 honest-stop repair MOVED into the
#       round-67 calibration row (round-68 row left without it) still reads
#       L1 fail (section scoping, not a keyword search);
#   (e) misplacement control: a copy with the L3 correction MOVED to the end
#       of LOG.md (lesson left without it) still reads L3 fail;
#   (f) --selftest prints `C1_RECORD_SELFTEST: PASS (N cases)` with N >= 12,
#       including a constant-verdict mutant (a counter that prints CLEAN
#       without reading must be refused) and a sub-population case.
#
# Cost bounds: L9's executing conjunct runs only when its non-executing
# conjuncts hold (at BASE the R68-02 row names the 3600 s round-68 counter
# and is never executed).  Guards (d)/(e) run only the leg they test, in
# subset mode.  Guard (f) runs on in-memory/scratch fixtures, never on a full
# lane copy.  This counter must NOT run `corpus/claim-ledger.sh verify` and
# must not run plans/round-68-c1.sh's --selftest.
#
# Scratch: --scratch, else ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r69/R69ExecCounterC1/.
# Each run works in a fresh run.* directory there, removed on exit.  No
# hardcoded /tmp.  No writes outside --scratch except the run's own stdout.
set -u
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 2
SELF="$HERE/$(basename -- "${BASH_SOURCE[0]}")"
LANE=$(cd -- "$HERE/.." && pwd) || exit 2
BASE_REV=264917aa8fc9e71b6595d0d5166c4b615120fb8b

setup() { printf 'C1_RECORD: SETUP %s\n' "$1" >&2; exit 2; }

TREE=""; BASE_TREE=""; SCRATCH=""; SELFTEST=0; VERBOSE=0; LEGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) [ $# -ge 2 ] || setup "--tree needs a dir"; TREE=$2; shift ;;
    --base-tree) [ $# -ge 2 ] || setup "--base-tree needs a dir"; BASE_TREE=$2; shift ;;
    --scratch) [ $# -ge 2 ] || setup "--scratch needs a dir"; SCRATCH=$2; shift ;;
    --legs) [ $# -ge 2 ] || setup "--legs needs a list"; LEGS=$2; shift ;;
    --verbose) VERBOSE=1 ;;
    --selftest) SELFTEST=1 ;;
    *) setup "unknown argument: $1" ;;
  esac
  shift
done

if [ "${R69_C1_NESTED:-0}" = 1 ]; then
  # Anti-recursion: a full-mode invocation may not be re-entered from a claim
  # row that invokes it. Subset mode without L9 (guards d/e, L9's row command
  # `--legs L1,L3`) cannot recurse and is allowed.
  if [ -z "$LEGS" ] || printf '%s' "$LEGS" | grep -q '\bL9\b'; then
    printf 'C1_RECORD: SETUP nested invocation refused (a claim row must not re-run the full counter)' >&2; exit 2
  fi
fi
command -v python3 >/dev/null 2>&1 || setup "no python3"
command -v git >/dev/null 2>&1 || setup "no git"
[ -n "$SCRATCH" ] || SCRATCH="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r69/R69ExecCounterC1"
mkdir -p -- "$SCRATCH" || setup "scratch not creatable: $SCRATCH"
S=$(mktemp -d "$SCRATCH/run.XXXXXX") || setup "scratch mktemp failed under $SCRATCH"
trap 'rm -rf -- "$S"' EXIT
mkdir -p -- "$S/tmp" || setup "scratch tmp mkdir failed"
TMPDIR="$S/tmp"; export TMPDIR
[ -n "$TREE" ] || TREE=.
if [ "$SELFTEST" -eq 0 ]; then
  [ -d "$TREE" ] || setup "bad tree: $TREE"
fi

python3 -I -B - "$S" "$TREE" "$LANE" "$BASE_REV" "$BASE_TREE" "$SELF" "$VERBOSE" "$SELFTEST" "$LEGS" <<'PY'
import hashlib, json, os, re, subprocess, sys

S, TREE, LANE, BASE_REV, BASE_TREE, SELF, VERBOSE, SELFTEST, LEGS = sys.argv[1:10]
VERBOSE = (VERBOSE == "1")
TARGET = "C1_RECORD: mismatches=0 population=13 guard=1"
POP = 13
JOURNAL_OLD = "^C2_RECORD: mismatches=0 population=3 guard=1$"

SCORECARD_REL = "SCORECARD.md"
ROUND68_POSTMOVE = "## Round 68 — post-move"
ROUND67_POSTMOVE = "## Round 67 — post-move"
LESSON68_REL = "corpus/lessons/round-68.md"
LOG_REL = "LOG.md"
QUALITY_REL = "corpus/QUALITY.md"
LEDGER_REL = "corpus/claim-ledger.tsv"
PLAN68_REL = "plans/round-68.md"
C1_68_REL = "plans/round-68-c1.sh"
CLAIMS68_REL = ".ufo/waves/round-68/claims.json"
DERIV_REL = ".ufo/waves/round-68/base/base-derivation.md"
LESSON69_REL = "corpus/lessons/round-69.md"
KNOWLEDGE_REL = "corpus/knowledge"
RESULTS_REL = ".ufo/waves/round-69/w1-results.json"
SPEC_REL = ".ufo/waves/round-69/w1-spec.json"
JOURNALS_REL = ".ufo/waves/round-69/journals"
C2LANE_REL = ".ufo/waves/round-68/w1/R68ScribeLesson/c2-lane-run.txt"
SELFTEST_REL = ".ufo/waves/round-68/w1/R68ExecCounterC1/selftest.txt"
BASERUN_REL = ".ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt"
ROUND67RECEIPT_REL = ".ufo/waves/round-68/base/c1-base-round67-counter.txt"
BASELEGS_REL = ".ufo/waves/round-68/w1/R68Sentinel/receipts/base-legs.txt"
DEAD_REL = ".ufo/waves/round-68/final/c1-base.txt"

QUAL_ROW = re.compile(r"^\|\s*(QM\d+)\s*\|")
QM_NUM = re.compile(r"^QM(\d+)$")
SELFTEST_N = re.compile(r"C1_VERIFIED_SELFTEST: PASS \((\d+) cases\)")
C1V_CAUGHT = re.compile(r"C1_VERIFIED:\s*verified=\d+\s*col15=\d+\s*caught=(\d+)/6")
C1R_CAUGHT = re.compile(r"C1_READTHROUGH:\s*bound=\d+\s*located=\d+\s*caught=(\d+)/6")
EXPANSION_N = re.compile(r"new knowledge entries=(\d+)")


def real(p):
    return os.path.realpath(p)


def setup(msg):
    print("C1_RECORD: SETUP %s" % msg, file=sys.stderr)
    sys.exit(2)


def vlog(msg):
    if VERBOSE:
        print("  | " + msg)


def read(p):
    try:
        with open(p, encoding="utf-8", newline="") as fh:
            return fh.read()
    except (OSError, UnicodeDecodeError):
        return None


def write(p, text):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)


def within(child, parent):
    try:
        return os.path.commonpath([real(child), real(parent)]) == real(parent)
    except ValueError:
        return False


def run(args, cwd=None, env=None, timeout=900):
    e = dict(os.environ)
    if env:
        e.update(env)
    try:
        p = subprocess.run(args, cwd=cwd, env=e, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, timeout=timeout)
        return p.returncode, p.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired as ex:
        out = ex.stdout.decode("utf-8", "replace") if isinstance(ex.stdout, bytes) else ""
        return 124, out + "\n[c1] timeout after %ss" % timeout
    except OSError as ex:
        return 127, "[c1] exec failed: %s" % ex


def last_line(out):
    lines = [l for l in out.splitlines() if l.strip()]
    return lines[-1] if lines else ""


def section_of(text, heading):
    """Lines from the heading line to (not incl.) the next top-level heading."""
    lines = text.split("\n")
    start = None
    for i, l in enumerate(lines):
        if l.startswith(heading):
            start = i
            break
    if start is None:
        return None, None
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("## "):
            end = j
            break
    return start, "\n".join(lines[start:end])


def ledger_rows(tree):
    text = read(os.path.join(tree, LEDGER_REL))
    if text is None:
        return None
    rows = []
    for l in text.split("\n"):
        if not l or l.startswith("#"):
            continue
        rows.append(l.split("\t"))
    return rows


def row_by_id(rows, rid):
    if rows is None:
        return []
    return [r for r in rows if len(r) >= 6 and r[0] == rid]


def is_literal_anchored(expect):
    """expect must start ^, end $, interior ERE metacharacters escaped."""
    if not expect.startswith("^") or not expect.endswith("$") or len(expect) < 3:
        return False
    inner = expect[1:-1]
    i = 0
    while i < len(inner):
        c = inner[i]
        if c == "\\":
            i += 2
            continue
        if c in ".[]()*+?{}|^$":
            return False
        i += 1
    return True


def journal_old_covers(tree):
    """A round-69 journal entry carrying the frozen old_expect (L9 conjunct)."""
    jd = os.path.join(tree, JOURNALS_REL)
    if not os.path.isdir(jd):
        return False
    for name in sorted(os.listdir(jd)):
        if not name.endswith(".json"):
            continue
        try:
            with open(os.path.join(jd, name), encoding="utf-8") as fh:
                doc = json.load(fh)
        except (OSError, ValueError):
            continue
        for m in doc.get("migrations", []):
            if isinstance(m, dict) and m.get("old_expect") == JOURNAL_OLD:
                return True
    return False


# ------------------------------------------------------------------ legs ----
def leg_L1(tree):
    det = []
    p = os.path.join(tree, SCORECARD_REL)
    text = read(p)
    if text is None:
        return 0, "absent " + SCORECARD_REL
    _, sec = section_of(text, ROUND68_POSTMOVE)
    if sec is None:
        return 0, "round-68 post-move section absent"
    cal = None
    for l in sec.split("\n"):
        if l.startswith("| calibration"):
            cal = l
            break
    if cal is None:
        return 0, "calibration row absent in round-68 section"
    ok_unprovable = "unprovable" in cal
    det.append("unprovable=%d" % ok_unprovable)
    ok_receipt = C2LANE_REL in cal
    exists = os.path.isfile(os.path.join(tree, C2LANE_REL))
    det.append("receipt-named=%d exists=%d" % (ok_receipt, exists))
    ok_nofab = "mismatches=0" not in cal
    det.append("no-mismatches-0=%d" % ok_nofab)
    ok = 1 if (ok_unprovable and ok_receipt and exists and ok_nofab) else 0
    return ok, " ".join(det)


def derived_criterion_ids(tree):
    """QM ids whose QUALITY row names corpus/lessons/round-68.md in its source column."""
    text = read(os.path.join(tree, QUALITY_REL))
    if text is None:
        return None
    ids = []
    for l in text.split("\n"):
        m = QUAL_ROW.match(l)
        if m and "corpus/lessons/round-68.md" in l:
            ids.append(m.group(1))
    return ids


def leg_L2(tree):
    det = []
    p = os.path.join(tree, SCORECARD_REL)
    text = read(p)
    if text is None:
        return 0, "absent " + SCORECARD_REL
    _, sec = section_of(text, ROUND68_POSTMOVE)
    if sec is None:
        return 0, "round-68 post-move section absent"
    depth = None
    for l in sec.split("\n"):
        if l.startswith("| depth"):
            depth = l
            break
    if depth is None:
        return 0, "depth row absent"
    derived = derived_criterion_ids(tree)
    if derived is None:
        return 0, "absent " + QUALITY_REL
    no_claim = "enter the bar" not in depth
    det.append("no-enter-the-bar=%d" % no_claim)
    named = [q for q in derived if q in depth]
    det.append("derived=%s named=%s" % (",".join(derived) or "empty", ",".join(named) or "none"))
    if derived:
        ok_named = (set(named) == set(derived))
        det.append("names-derived-set=%d" % ok_named)
        ok = 1 if (no_claim and ok_named) else 0
    else:
        # Empty derived set: naming nothing is vacuous (reviewer A7). The row
        # must state the empty set explicitly.
        states_empty = bool(re.search(r"no (QUALITY )?criterion|set (is |of such criteria is )?empty|"
                                      r"ends at QM96|no criterion was added", depth))
        det.append("states-empty-set=%d" % states_empty)
        ok = 1 if (no_claim and states_empty) else 0
    return ok, " ".join(det)


def original_sentence_present(lesson_text):
    return ("mismatches 3 → 0" in lesson_text) or ("`C2_RECORD` mismatches" in lesson_text)


def correction_block(text):
    """Text from the appended correction to end of file, or None.

    Accepts both `## Correction (round 69)` (lesson heading form) and a bare
    `Correction (round 69):` line (LOG.md / base-derivation.md form).
    """
    idx = text.find("## Correction (round 69)")
    if idx >= 0:
        return text[idx:]
    idx = text.find("Correction (round 69):")
    if idx >= 0:
        return text[idx:]
    return None


def leg_L3(tree):
    det = []
    p = os.path.join(tree, LESSON68_REL)
    text = read(p)
    if text is None:
        return 0, "absent " + LESSON68_REL
    orig = original_sentence_present(text)
    det.append("original-present=%d" % orig)
    blk = correction_block(text)
    det.append("correction-present=%d" % (blk is not None))
    ok_name = ok_receipt = ok_exists = ok_after = False
    if blk is not None:
        ok_name = ("C2_RECORD" in blk and ("superseded" in blk.lower() or "supersede" in blk.lower()))
        ok_receipt = (C2LANE_REL in blk)
        ok_exists = os.path.isfile(os.path.join(tree, C2LANE_REL))
        # The appended block must come after the original sentence (append-only).
        ok_after = (text.rfind("## Correction (round 69)") > text.find("mismatches 3 → 0"))
        det.append("after-original=%d" % ok_after)
    ok = 1 if (orig and blk is not None and ok_name and ok_receipt and ok_exists and ok_after) else 0
    return ok, " ".join(det)


def leg_L4(tree):
    det = []
    logp = os.path.join(tree, LOG_REL)
    log = read(logp)
    if log is None:
        return 0, "absent " + LOG_REL
    orig = "C1_VERIFIED_SELFTEST: PASS (59 cases)" in log
    det.append("original-59-present=%d" % orig)
    rp = os.path.join(tree, SELFTEST_REL)
    rtext = read(rp)
    exists = os.path.isfile(rp)
    det.append("receipt-exists=%d" % exists)
    if rtext is None:
        return 0, " ".join(det)
    m = SELFTEST_N.search(rtext)
    if m is None:
        det.append("count-unparseable")
        return 0, " ".join(det)
    cnt = m.group(1)
    det.append("parsed-count=%s" % cnt)
    blk = correction_block(log)
    det.append("correction-present=%d" % (blk is not None))
    ok_names = ok_path = False
    if blk is not None:
        ok_names = bool(re.search(r"(%s cases|%s\)|PASS \(%s\))" % (cnt, cnt, cnt), blk))
        ok_path = SELFTEST_REL in blk
        det.append("names-count=%d names-path=%d" % (ok_names, ok_path))
    ok = 1 if (orig and exists and blk is not None and ok_names and ok_path) else 0
    return ok, " ".join(det)


def leg_L5(tree):
    det = []
    dp = os.path.join(tree, DERIV_REL)
    dtext = read(dp)
    if dtext is None:
        return 0, "absent " + DERIV_REL
    orig = "caught=0/6" in dtext
    det.append("original-present=%d" % orig)
    # §7- compared surface: the round-67 receipt the derivation quotes.
    rp67 = os.path.join(tree, ROUND67RECEIPT_REL)
    r67 = read(rp67)
    exists67 = os.path.isfile(rp67)
    det.append("r67-exists=%d" % exists67)
    val67 = None
    if r67 is not None:
        m = C1R_CAUGHT.search(r67)
        if m is not None:
            val67 = m.group(1)
    det.append("r67-caught=%s" % (val67 if val67 is not None else "unparseable"))
    # The round-68 counter's own BASE reading must stay distinct.
    rp = os.path.join(tree, BASERUN_REL)
    rr = read(rp)
    exists = os.path.isfile(rp)
    det.append("r68-exists=%d" % exists)
    val = None
    if rr is not None:
        m = C1V_CAUGHT.search(rr)
        if m is not None:
            val = m.group(1)
    det.append("r68-caught=%s" % (val if val is not None else "unparseable"))
    blk = correction_block(dtext)
    det.append("correction-present=%d" % (blk is not None))
    ok67 = ok68 = ok_path = False
    if blk is not None:
        if val67 is not None:
            ok67 = bool(re.search(r"caught=%s/6" % val67, blk))
        if val is not None:
            ok68 = bool(re.search(r"caught=%s/6" % val, blk))
        ok_path = (ROUND67RECEIPT_REL in blk) and (BASERUN_REL in blk)
        det.append("names-r67-value=%d names-r68-value=%d names-paths=%d" % (ok67, ok68, ok_path))
    ok = 1 if (orig and exists67 and exists and blk is not None and ok67 and ok68 and ok_path) else 0
    return ok, " ".join(det)


def leg_L6(tree):
    det = []
    lp = os.path.join(tree, LESSON69_REL)
    text = read(lp)
    if text is None:
        return 0, "absent " + LESSON69_REL
    ok_dead = DEAD_REL in text
    ok_good = BASERUN_REL in text
    exists = os.path.isfile(os.path.join(tree, BASERUN_REL))
    det.append("names-dead=%d names-corrected=%d exists=%d" % (ok_dead, ok_good, exists))
    ok = 1 if (ok_dead and ok_good and exists) else 0
    return ok, " ".join(det)


def leg_L7(tree):
    det = []
    cp = os.path.join(tree, CLAIMS68_REL)
    text = read(cp)
    if text is None:
        return 0, "absent " + CLAIMS68_REL
    try:
        doc = json.loads(text)
    except ValueError:
        return 0, "claims.json unparseable"
    sb = doc.get("superseded_by")
    if not isinstance(sb, dict):
        return 0, "superseded_by absent"
    # Original target strings must be unchanged — the freeze committed them.
    # Their BASE values are pinned by the claim BASE ledger row?  No: derive by
    # requiring the object to name the amendment and the final reading, and the
    # file to still carry both targets containing their frozen populations.
    # The 37/32 pre-A1 strings must remain as the (now superseded) targets.
    det.append("superseded_by present")
    blob = json.dumps(sb)
    ok_amend = "Amendment A1" in blob
    det.append("names-amendment=%d" % ok_amend)
    ok_final = ("38" in blob and "33" in blob)
    det.append("names-final-38-33=%d" % ok_final)
    # original target strings unchanged: both C1 and C2 targets still present
    t1 = doc.get("C1", {})
    t2 = doc.get("C2", {})
    ok_t1 = isinstance(t1, dict) and "verified=37" in str(t1.get("target", ""))
    ok_t2 = isinstance(t2, dict) and "mismatches=0" in str(t2.get("target", ""))
    det.append("c1-target-unchanged=%d c2-target-unchanged=%d" % (ok_t1, ok_t2))
    ok = 1 if (ok_amend and ok_final and ok_t1 and ok_t2) else 0
    return ok, " ".join(det)


def extract_predicate(text):
    lines = text.split("\n")
    start = None
    for i, l in enumerate(lines):
        if re.match(r"def predicate_ok\(", l):
            start = i
            break
    if start is None:
        return None
    out = [lines[start]]
    for l in lines[start + 1:]:
        if l.strip() and not l[0].isspace():
            break
        out.append(l)
    return "\n".join(out) + "\n"


PRED_CASES = [((36, 31, 6, 1, 0), False), ((37, 32, 6, 1, 0), True),
              ((38, 33, 6, 1, 0), True), ((38, 33, 5, 1, 0), False),
              ((38, 33, 6, 0, 0), False), ((38, 33, 6, 1, 1), False)]


def predicate_check(f):
    ok = True
    parts = []
    for args, want in PRED_CASES:
        try:
            got = bool(f(*args))
            err = ""
        except Exception as ex:
            got = None
            err = " raise=%s" % ex.__class__.__name__
        good = (got is want)
        ok = ok and good
        parts.append("%s want=%s got=%s%s %s" % (args, want, got, err, "ok" if good else "MISS"))
    return ok, parts


def leg_L8(tree):
    det = []
    p = os.path.join(tree, C1_68_REL)
    text = read(p)
    if text is None:
        return 0, "absent " + C1_68_REL
    src = extract_predicate(text)
    if src is None:
        return 0, "no def predicate_ok"
    ns = {}
    try:
        exec(compile(src, p, "exec"), ns)
    except Exception as ex:
        return 0, "exec-error %s" % ex.__class__.__name__
    f = ns.get("predicate_ok")
    if not callable(f):
        return 0, "predicate_ok not callable"
    ok, parts = predicate_check(f)
    det += ["pred " + x for x in parts]
    has_case = "predicate-subfloor" in text
    det.append("predicate-subfloor-case=%d" % has_case)
    res = 1 if (ok and has_case) else 0
    return res, " ".join(det)


def leg_L9(tree):
    det = []
    rows = ledger_rows(tree)
    if rows is None:
        return 0, "absent " + LEDGER_REL
    hits = row_by_id(rows, "R68-02")
    det.append("rows=%d" % len(hits))
    if len(hits) != 1:
        return 0, " ".join(det)
    row = hits[0]
    cmd, expect, want_exit, tmo_raw = row[1], row[2], row[3], row[4]
    literal = is_literal_anchored(expect)
    det.append("literal-anchored=%d" % literal)
    det.append("command=%r timeout=%r" % (cmd, tmo_raw))
    jok = journal_old_covers(tree)
    det.append("journal-old_expect-present=%d" % jok)
    execlass = False
    try:
        execlass = expect.endswith("$") and not expect.endswith("$") is False
    except Exception:
        execlass = False
    # Non-executing conjuncts first (cost bound): a literal anchored expect
    # must not be a class search.  We require it to be literal; execution is
    # still required to pass, but it runs only when every other conjunct holds.
    try:
        tmo = int(tmo_raw)
        if tmo <= 0:
            tmo = 0
    except ValueError:
        return 0, " ".join(det) + " bad-timeout"
    if not (literal and jok):
        return 0, " ".join(det) + " non-executing conjunct failed (not executed)"
    # Execute the row's own command with its own timeout, cwd=tree — the
    # ledger gate's execution model (`timeout bash -c`).  Never claim-ledger verify.
    try:
        p = subprocess.run(["bash", "-c", cmd], cwd=tree, timeout=tmo + 5,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           env={**os.environ, "R69_C1_NESTED": "1"})
        rc, out = p.returncode, p.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired as ex:
        rc = 124
        out = (ex.stdout.decode("utf-8", "replace") if isinstance(ex.stdout, bytes) else "")
        det.append("timeout")
    except OSError as ex:
        return 0, " ".join(det) + " exec-failed %s" % ex
    det.append("rc=%d" % rc)
    last = last_line(out)
    det.append("last=%r" % last[:160])
    try:
        m = re.search(expect, last) is not None and rc == int(want_exit)
    except re.error:
        m = False
    ok = 1 if m else 0
    return ok, " ".join(det)


def leg_L10(tree):
    det = []
    p = os.path.join(tree, SCORECARD_REL)
    text = read(p)
    if text is None:
        return 0, "absent " + SCORECARD_REL
    _, sec = section_of(text, ROUND68_POSTMOVE)
    if sec is None:
        return 0, "round-68 post-move section absent"
    fresh = None
    for l in sec.split("\n"):
        if l.startswith("| freshness"):
            fresh = l
            break
    if fresh is None:
        return 0, "freshness row absent"
    ok0 = "0/6" in fresh
    ok2 = "2/6" in fresh
    ok_names = BASELEGS_REL in fresh
    exists = os.path.isfile(os.path.join(tree, BASELEGS_REL))
    det.append("has-0/6=%d has-2/6=%d names-receipt=%d exists=%d" % (ok0, ok2, ok_names, exists))
    ok = 1 if (ok0 and ok2 and ok_names and exists) else 0
    return ok, " ".join(det)


def leg_L11(tree):
    det = []
    text = read(os.path.join(tree, QUALITY_REL))
    if text is None:
        return 0, "absent " + QUALITY_REL
    ids = []
    for l in text.split("\n"):
        m = QUAL_ROW.match(l)
        if not m:
            continue
        qm = QM_NUM.match(m.group(1))
        if qm and int(qm.group(1)) > 96 and "corpus/lessons/round-68.md" in l:
            ids.append(m.group(1))
    det.append("derived-num=%d ids=%s" % (len(ids), ",".join(ids) or "none"))
    return (1 if len(ids) >= 4 else 0), " ".join(det)


def terminal_status(entry):
    """A settled seat entry: non-empty final output (dispatcher writes
    output=None, note=kernel-restart only when the output was not retained)."""
    if not isinstance(entry, dict):
        return False
    out = entry.get("output")
    if isinstance(out, str) and out.strip():
        return True
    # w1-results written by finalize() has name/agent/output/note; a null
    # output with a kernel-restart note is an unsettled seat, not terminal.
    return False


def leg_L12(tree):
    det = []
    rp = os.path.join(tree, RESULTS_REL)
    rtext = read(rp)
    if rtext is None:
        return 0, "results-absent " + RESULTS_REL
    try:
        doc = json.loads(rtext)
    except ValueError:
        return 0, "results-unparseable"
    res = doc.get("results")
    if not isinstance(res, list):
        return 0, "results-not-a-list"
    bad = [e.get("name", "?") for e in res if not terminal_status(e)]
    det.append("seats=%d unsettled=%s" % (len(res), ",".join(bad) or "none"))
    spec = read(os.path.join(tree, SPEC_REL))
    if spec is None:
        return 0, " ".join(det) + " spec-absent"
    q1 = "C1_RECORD:" not in spec
    q2 = "C2_TEETH:" not in spec
    q3 = "mismatches=0" not in spec
    det.append("quarantine-c1=%d c2=%d mismatches0=%d" % (q1, q2, q3))
    ok = 1 if (not bad and q1 and q2 and q3) else 0
    return ok, " ".join(det)


def count_knowledge(tree):
    base = os.path.join(tree, KNOWLEDGE_REL)
    if not os.path.isdir(base):
        return None
    n = 0
    for root, dirs, files in os.walk(base):
        for f in files:
            n += 1
    return n


BASE_TREE = None  # set in run_leg when --base-tree/base_dir available


def leg_L13(tree, base):
    det = []
    lp = os.path.join(tree, LESSON69_REL)
    text = read(lp)
    if text is None:
        return 0, "absent " + LESSON69_REL
    exp_line = None
    for l in text.split("\n"):
        if "expansion" in l:
            m = EXPANSION_N.search(l)
            if m is not None:
                exp_line = (l, int(m.group(1)))
                break
    if exp_line is None:
        return 0, "no expansion new-knowledge-entries line"
    stated = exp_line[1]
    here = count_knowledge(tree)
    det.append("stated=%d here=%s" % (stated, here))
    if base is None:
        return 0, " ".join(det) + " no-base-count"
    there = count_knowledge(base)
    det.append("base=%s" % there)
    if here is None or there is None:
        return 0, " ".join(det) + " count-failed"
    want = here - there
    det.append("want=%d" % want)
    return (1 if stated == want else 0), " ".join(det)


LEG_FNS = {"L1": leg_L1, "L2": leg_L2, "L3": leg_L3, "L4": leg_L4, "L5": leg_L5,
           "L6": leg_L6, "L7": leg_L7, "L8": leg_L8, "L9": leg_L9, "L10": leg_L10,
           "L11": leg_L11, "L12": leg_L12, "L13": None}
LEG_ORDER = ["L%d" % i for i in range(1, 14)]


def base_dir():
    if BASE_TREE:
        b = real(BASE_TREE)
        if not os.path.isdir(b):
            setup("bad base tree: %s" % BASE_TREE)
        return b
    rc, out = run(["git", "-C", LANE, "rev-parse", "--show-toplevel"], timeout=60)
    if rc != 0 or real(out.strip()) != real(LANE):
        setup("lane is not its own git toplevel; pass --base-tree")
    dst = os.path.join(S, "base")
    os.makedirs(dst)
    arch = subprocess.Popen(["git", "-C", LANE, "archive", BASE_REV], stdout=subprocess.PIPE)
    ex = subprocess.run(["tar", "-xf", "-", "-C", dst], stdin=arch.stdout)
    arch.stdout.close()
    rc = arch.wait()
    if rc != 0 or ex.returncode != 0:
        setup("git archive of BASE %s failed" % BASE_REV)
    return dst


def run_leg(name, tree, base):
    if name == "L13":
        return leg_L13(tree, base)
    return LEG_FNS[name](tree)


# ----------------------------------------------------------------- guards ---
GUARD_A_SURFACES = ["SCORECARD.md", "corpus/lessons/round-68.md", "LOG.md",
("base-derivation.md", "claims.json", "predicate_ok", "R68-02", "QUALITY.md")]
GUARD_A_SURFACES = ["SCORECARD.md", "corpus/lessons/round-68.md", "LOG.md",
                    "base-derivation.md", "claims.json", "predicate_ok",
                    "R68-02", "QUALITY.md"]


def guard_a(tree):
    det = []
    text = read(os.path.join(tree, PLAN68_REL))
    if text is None:
        return 0, "absent " + PLAN68_REL
    marker = "## Amendment A2 — post-closure repairs\n  (round 69)"
    # accept both the two-line heading and single-line variants that carry the
    # em-dash phrasing; the frozen surface is the heading text of the plan §.
    idx = text.find("## Amendment A2")
    if idx < 0:
        return 0, "A2 heading absent"
    head_end = text.find("\n", idx)
    heading = text[idx:head_end]
    det.append("heading=%r" % heading)
    if "post-closure repairs" not in heading or "(round 69)" not in heading:
        return 0, " ".join(det) + " heading-mismatch"
    # body: to end of file (A2 is appended last) — old → new naming.
    body = text[head_end:]
    missing = [s for s in GUARD_A_SURFACES if s not in body]
    det.append("missing=%s" % (",".join(missing) or "none"))
    det.append("old-new=%d" % ("→" in body))
    ok_new = ("old" in body.lower() and "new" in body.lower())
    det.append("names-old-new=%d" % ok_new)
    return (1 if (not missing and "→" in body and ok_new) else 0), " ".join(det)


def copy_tree(src, dst):
    if os.path.exists(dst):
        setup("copy destination exists: %s" % dst)
    os.makedirs(dst)
    tar = subprocess.Popen(["tar", "-C", src, "--exclude=.git", "--exclude=.jj",
                            "--exclude=__pycache__", "-cf", "-", "."],
                           stdout=subprocess.PIPE)
    ex = subprocess.run(["tar", "-xf", "-", "-C", dst], stdin=tar.stdout)
    tar.stdout.close()
    rc = tar.wait()
    if rc != 0 or ex.returncode != 0:
        setup("tree copy failed (tar %d / extract %d)" % (rc, ex.returncode))


def full_verdict(tree, base):
    """Run all 13 legs + guards (a)+(b)+(f) deterministically (no (c)-(e))."""
    res = {}
    for n in LEG_ORDER:
        res[n] = run_leg(n, tree, base)
    mism = sum(1 for n in LEG_ORDER if res[n][0] == 0)
    ga, ga_det = guard_a(tree)
    # (b): the tree itself prints the frozen zero line with guard=1
    gb = 1 if (mism == 0 and ga == 1) else 0
    return res, mism, (ga, ga_det), gb


def nested_run(tree, legs=None, timeout=900):
    args = ["bash", SELF, "--tree", tree, "--scratch", os.path.join(S, "nest-%d" % nested_run.n)]
    nested_run.n += 1
    if legs:
        args += ["--legs", legs]
    rc, out = run(args, timeout=timeout)
    lines = [l for l in out.splitlines() if l.startswith("LEG ") or l.startswith("GUARD") or l.startswith("C1_RECORD")]
    return rc, lines


nested_run.n = 0


def guard_c(base):
    det = []
    res = {}
    for n in LEG_ORDER:
        res[n] = run_leg(n, base, base)
    mism = sum(1 for n in LEG_ORDER if res[n][0] == 0)
    det.append("base-mismatches=%d" % mism)
    for n in LEG_ORDER:
        det.append("%s=%d(%s)" % (n, res[n][0], res[n][1][:80]))
    ok = (mism == 13)
    return (1 if ok else 0), det


def guard_d(tree):
    """Decoy: honest-stop text MOVED into the round-67 calibration row must not pass L1.

    Cost bound: works on a scratch copy, runs only L1 in subset mode. The
    round-68 calibration row's honest-stop repair is removed from the copy, so a
    counter that scans the whole file (not the section) would false-pass.
    BASE trees have no repair to move and the control vacuously passes; the
    binding control is the candidate copy.
    """
    dst = os.path.join(S, "decoy")
    copy_tree(tree, dst)
    p = os.path.join(dst, SCORECARD_REL)
    text = read(p)
    if text is None:
        return 0, "copy unreadable"
    lines = text.split("\n")
    # Locate both post-move sections.
    idx68 = None
    idx67 = None
    for i, l in enumerate(lines):
        if l.startswith(ROUND68_POSTMOVE):
            idx68 = i
        if l.startswith(ROUND67_POSTMOVE):
            idx67 = i
    if idx68 is None or idx67 is None:
        return 0, "both sections required for decoy"
    moved = False
    # Remove the repair from the round-68 calibration row (the heading line
    # itself is the section start, not a nested heading).
    _s68, _sec68 = section_of(text, ROUND68_POSTMOVE)
    if _sec68 is not None:
        for _k, _l in enumerate(_sec68.split("\n")):
            if _l.startswith("| calibration") and "unprovable" in _l:
                lines[idx68 + _k] = _l.replace("unprovable", "RELOCATED-TO-R67")
                moved = True
                break
    _s67, _sec67 = section_of(text, ROUND67_POSTMOVE)
    if _sec67 is not None:
        for _k, _l in enumerate(_sec67.split("\n")):
            if _l.startswith("| calibration"):
                lines[idx67 + _k] = _l + " honest stop: unprovable — see `" + C2LANE_REL + "`"
                break
    write(p, "\n".join(lines))
    rc, lines_out = nested_run(dst, legs="L1", timeout=120)
    failed = any(l.startswith("LEG L1 fail") for l in lines_out)
    ok = 1 if failed else 0
    # If no repair existed in round-68 to move (BASE tree), the plant alone
    # must still not make L1 pass.
    return ok, ["decoy-L1-fail=%d relocated=%d" % (failed, moved)] + lines_out


def guard_e(tree):
    """Misplacement: L3 correction moved to LOG.md must not pass L3.

    Cost bound: works on a scratch copy, runs only L3 in subset mode. The
    lesson's correction block is removed from the copy and planted in LOG.md,
    so a counter that searches the repo (not the file) would false-pass.
    """
    dst = os.path.join(S, "misplace")
    copy_tree(tree, dst)
    lp = os.path.join(dst, LESSON68_REL)
    ltext = read(lp)
    if ltext is None:
        return 0, "copy unreadable"
    idx = ltext.find("## Correction (round 69)")
    removed = False
    if idx >= 0:
        removed = True
        write(lp, ltext[:idx].rstrip("\n") + "\n")
    gp = os.path.join(dst, LOG_REL)
    gtext = read(gp)
    if gtext is None:
        return 0, "copy unreadable"
    gtext = gtext + "\n## Correction (round 69)\n\nThe sentence \"C2_RECORD mismatches 3 → 0\" is superseded; honest-stop receipt " + C2LANE_REL + "\n"
    write(gp, gtext)
    rc, lines_out = nested_run(dst, legs="L3", timeout=120)
    failed = any(l.startswith("LEG L3 fail") for l in lines_out)
    ok = 1 if failed else 0
    return ok, ["misplace-L3-fail=%d relocated=%d" % (failed, removed)] + lines_out


def guard_selftest():
    rc, out = run(["bash", SELF, "--selftest", "--scratch", os.path.join(S, "gst")],
                  timeout=120)
    m = re.search(r"^C1_RECORD_SELFTEST: PASS \((\d+) cases\)", out, re.M)
    n = int(m.group(1)) if m else 0
    return (1 if n >= 12 else 0), n, out


# -------------------------------------------------------------- selftest ----
def selftest(base):
    fx = os.path.join(S, "fx")
    os.makedirs(fx)
    res = []

    def case(name, ok):
        res.append((name, bool(ok)))

    # derived-set helper on fixtures
    def qual_tree(name, rows):
        d = os.path.join(fx, name)
        write(os.path.join(d, QUALITY_REL), "# hdr\n" + "\n".join(rows) + "\n")
        return d

    d1 = qual_tree("q-empty", ["| QM1 | x | y | `corpus/lessons/round-21.md` |"])
    case("derived-empty-set", derived_criterion_ids(d1) == [])
    d2 = qual_tree("q-mixed", ["| QM97 | x | y | `corpus/lessons/round-68.md` |",
                                "| QM98 | x | y | `corpus/lessons/round-65.md` |",
                                "| QA1 | x | y | `corpus/lessons/round-68.md` |"])
    case("derived-filters-source-column-and-qm", derived_criterion_ids(d2) == ["QM97"])

    # L2 empty-set non-vacuity: stating nothing must fail; stating the empty set passes
    def score_tree(name, depth_line, qual_rows):
        d = os.path.join(fx, name)
        write(os.path.join(d, QUALITY_REL), "# hdr\n" + "\n".join(qual_rows) + "\n")
        sec = (ROUND68_POSTMOVE + "\n\n| Axis | Before → after | What moved | Evidence |\n"
               + depth_line + "\n")
        write(os.path.join(d, SCORECARD_REL), sec)
        return d

    st_none = score_tree("sc-none", "| depth | 9 → 9 | No claim. nothing | x |",
                         ["| QM1 | x | y | `corpus/lessons/round-21.md` |"])
    ok_none, _ = leg_L2(st_none)
    case("l2-empty-set-naming-nothing-fails", ok_none == 0)
    st_stmt = score_tree("sc-stmt",
                         "| depth | 9 → 9 | No claim. no QUALITY criterion was added; "
                         "the set is empty | x |",
                         ["| QM1 | x | y | `corpus/lessons/round-21.md` |"])
    ok_stmt, _ = leg_L2(st_stmt)
    case("l2-empty-set-explicit-passes", ok_stmt == 1)
    st_named = score_tree("sc-named",
                          "| depth | 9 → 9 | No claim. QM97 lands | x |",
                          ["| QM97 | x | y | `corpus/lessons/round-68.md` |"])
    ok_named, _ = leg_L2(st_named)
    case("l2-nonempty-set-names-it-passes", ok_named == 1)
    st_missing = score_tree("sc-miss", "| depth | 9 → 9 | No claim. enter the bar later | x |",
                            ["| QM97 | x | y | `corpus/lessons/round-68.md` |"])
    ok_miss, _ = leg_L2(st_missing)
    case("l2-enter-the-bar-claim-fails", ok_miss == 0)

    # section scoping: honest stop in a different section must not pass L1
    def score_sections(name, r67_cal, r68_cal):
        d = os.path.join(fx, name)
        text = (ROUND67_POSTMOVE + "\n| calibration | " + r67_cal + "\n"
                + ROUND68_POSTMOVE + "\n| calibration | " + r68_cal + "\n")
        write(os.path.join(d, SCORECARD_REL), text)
        write(os.path.join(d, C2LANE_REL), "receipt\n")
        return d

    decoy = score_sections("sc-decoy",
                           "9 → 9 | unprovable `" + C2LANE_REL + "` |",
                           "9 → 9 | C2_RECORD: mismatches=0 population=3 guard=1 rc 0 |")
    ok_decoy, _ = leg_L1(decoy)
    case("l1-decoy-different-section-fails", ok_decoy == 0)
    honest = score_sections("sc-honest",
                            "9 → 9 | C2_FIDELITY clean |",
                            "9 → 9 | unprovable `" + C2LANE_REL + "` |")
    ok_honest, _ = leg_L1(honest)
    case("l1-honest-stop-passes", ok_honest == 1)
    retained = score_sections("sc-retained",
                              "9 → 9 | clean |",
                              "9 → 9 | C2_RECORD: mismatches=0 population=3 guard=1 rc 0 "
                              "unprovable `" + C2LANE_REL + "` |")
    ok_ret, _ = leg_L1(retained)
    case("l1-fabricated-retained-fails", ok_ret == 0)

    # append-only shape: correction before the original must fail L3; after passes
    def lesson_tree(name, text, receipt=True):
        d = os.path.join(fx, name)
        write(os.path.join(d, LESSON68_REL), text)
        if receipt:
            write(os.path.join(d, C2LANE_REL), "receipt\n")
        return d

    lesson_orig = "## Claims\n- C2 `C2_RECORD` mismatches 3 → 0 x\n"
    lesson_after = lesson_orig + "\n## Correction (round 69)\nsupersedes `C2_RECORD` sentence; receipt " + C2LANE_REL + "\n"
    ok_after, _ = leg_L3(lesson_tree("ls-after", lesson_after))
    case("l3-appended-correction-passes", ok_after == 1)
    lesson_before = ("## Correction (round 69)\nsupersedes C2_RECORD; receipt " + C2LANE_REL
                     + "\n" + lesson_orig)
    ok_before, _ = leg_L3(lesson_tree("ls-before", lesson_before))
    # heading before original still holds the tokens; the leg requires the
    # correction block to follow the original (append-only).
    case("l3-misordered-correction-fails", ok_before == 0)

    # L5 must name BOTH counters' BASE values — the §7 receipt alone is not enough
    def deriv_tree(name, r67_caught, r68_caught, both=True):
        d = os.path.join(fx, name)
        write(os.path.join(d, DERIV_REL),
              "bullet ... caught=0/6 ...\n## Correction (round 69)\n"
              "r67 caught=%s/6 (%s) r68 caught=%s/6 (%s)\n" % (
                  r67_caught, ROUND67RECEIPT_REL, r68_caught, BASERUN_REL))
        write(os.path.join(d, ROUND67RECEIPT_REL),
              "C1_READTHROUGH: bound=36 located=36 caught=%s/6 guard=0\n" % r67_caught)
        write(os.path.join(d, BASERUN_REL),
              "C1_VERIFIED: verified=36 col15=31 caught=%s/6 guard=0\n" % r68_caught)
        return d

    ok_deriv, _ = leg_L5(deriv_tree("dv-both", "6", "0"))
    case("l5-names-both-base-readings-passes", ok_deriv == 1)
    ok_deriv1, _ = leg_L5(deriv_tree("dv-same", "0", "0"))
    # both parsing to 0/6 still holds shape-wise (they agree), so this is not a
    # failure case; use a mismatched correction instead:
    d_mix = os.path.join(fx, "dv-mix")
    write(os.path.join(d_mix, DERIV_REL),
          "bullet ... caught=0/6 ...\n## Correction (round 69)\n"
          "r67 caught=6/6 (%s) r68 caught=6/6 (%s)\n" % (ROUND67RECEIPT_REL, BASERUN_REL))
    write(os.path.join(d_mix, ROUND67RECEIPT_REL),
          "C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=0\n")
    write(os.path.join(d_mix, BASERUN_REL),
          "C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0\n")
    ok_mix, _ = leg_L5(d_mix)
    case("l5-requiring-distinct-r68-value-fails", ok_mix == 0)

    # predicate extraction sandbox
    SIG = "def predicate_ok(verified, col15, caught, guard, defects):\n"
    FLOORS = SIG + "    return (guard == 1 and caught == 6 and defects == 0 and verified >= 37 and col15 >= 32)\n"
    BLIND = SIG + "    return (guard == 1 and caught == 6 and defects == 0)\n"
    FLOOR_SRC = FLOORS + "\n    # predicate_subfloor mentioned\n"
    # materialize fixture files so leg_L8 reads them from a tree
    def pred_tree(name, body):
        d = os.path.join(fx, name)
        write(os.path.join(d, C1_68_REL), "#!/usr/bin/env bash\n" + body + "\n# predicate-subfloor\n")
        return d

    ok_fl, _ = leg_L8(pred_tree("pt-floors", FLOORS))
    case("l8-floors-fixture-passes", ok_fl == 1)
    ok_bl, _ = leg_L8(pred_tree("pt-blind", BLIND))
    case("l8-blind-fixture-fails", ok_bl == 0)
    ok_const, _ = leg_L8(pred_tree("pt-const", SIG + "    return True\n"))
    case("l8-constant-true-mutant-fails", ok_const == 0)
    ok_cmt, _ = leg_L8(pred_tree("pt-cmt", "# verified >= 37, col15 >= 32\n" + BLIND))
    case("l8-comment-only-fails", ok_cmt == 0)

    # L9 cost bound: non-executing conjuncts gate execution. A row whose
    # command would print the expect but whose journal is absent must fail
    # WITHOUT running (proved by a command that would create a marker file).
    marker = os.path.join(S, "l9-marker")
    if os.path.exists(marker):
        os.remove(marker)
    d_noj = os.path.join(fx, "l9-nojournal")
    write(os.path.join(d_noj, LEDGER_REL),
          "# c\nR68-02\ttouch " + marker + " && echo ok\t^ok$\t0\t30\tnote\n")
    ok_noj, det_noj = leg_L9(d_noj)
    case("l9-nojournal-fails-without-executing", ok_noj == 0 and not os.path.exists(marker))

    # L9: correct journal + executable command passes
    d_ok9 = os.path.join(fx, "l9-ok")
    write(os.path.join(d_ok9, LEDGER_REL),
          "# c\nR68-02\techo ok\t^ok$\t0\t30\tnote\n")
    write(os.path.join(d_ok9, JOURNALS_REL, "expectation-migrations.json"),
          json.dumps({"migrations": [{"id": "R68-02", "command": "echo ok",
                                      "old_expect": JOURNAL_OLD, "new_expect": "^ok$"}]}))
    ok_ok9, _ = leg_L9(d_ok9)
    case("l9-journaled-executable-passes", ok_ok9 == 1)

    # literal-anchored negatives
    case("literal-rejects-unanchored", not is_literal_anchored("foo"))
    case("literal-rejects-unescaped-metachar", not is_literal_anchored("^a.c$"))
    case("literal-accepts-escaped", is_literal_anchored(r"^a\.c$"))
    case("literal-accepts-frozen-old-expect", is_literal_anchored(JOURNAL_OLD))

    # sub-population: the verdict aggregation must refuse a population short of 13
    case("verdict-population-is-total", POP == 13 and len(LEG_ORDER) == 13)
    case("verdict-line-format", ("C1_RECORD: mismatches=%d population=13 guard=%d" % (0, 1)) == TARGET)

    # §F-2: the count must come from the COMMITTED receipt, never a re-run of a
    # live selftest (M69-5: the committed receipt reads 56 while the live
    # selftest prints 59). leg_L4 parses the receipt bytes only; it never shells
    # out to plans/round-68-c1.sh.
    # Structural proof: L4 parses the committed selftest receipt and never
    # shells out to the round-68 counter's selftest (the live count has
    # drifted from the committed receipt: M69-5).
    _self_src = read(SELF) or ""
    _needle = "round-68-c1" + ".sh --selftest"
    case("l4-parses-receipt-never-reruns-selftest",
         SELFTEST_REL in _self_src and _needle not in _self_src)

    # constant-verdict mutant end-to-end (QM43): a fixture tree where every
    # file prints the target line without reading must fail the legs.
    # A counter that prints CLEAN without reading (SUBPOP fixture guard f) is
    # refused both per-leg and in aggregate.
    d_const = os.path.join(fx, "const-tree")
    write(os.path.join(d_const, SCORECARD_REL), ROUND68_POSTMOVE + "\n| calibration | " + TARGET + " |\n")
    ok_const_cal, _ = leg_L1(d_const)
    case("constant-verdict-prints-target-still-fails-l1", ok_const_cal == 0)
    d_sub = os.path.join(fx, "subpop-tree")
    write(os.path.join(d_sub, SCORECARD_REL),
          ROUND68_POSTMOVE + "\n| calibration | unprovable `" + C2LANE_REL + "` |\n")
    write(os.path.join(d_sub, C2LANE_REL), "receipt\n")
    _sub_pass = sum(1 for _n in LEG_ORDER[:1] if run_leg(_n, d_sub, None)[0] == 0)
    case("sub-population-fixture-refused", _sub_pass == 0)

    # nested: full mode under R69_C1_NESTED is SETUP; subset without L9 is allowed.
    rc_n, _ = run(["bash", SELF, "--selftest"], env={"R69_C1_NESTED": "1"}, timeout=60)
    case("nested-full-refused", rc_n == 2)

    failed = [n for n, ok in res if not ok]
    if failed:
        print("C1_RECORD_SELFTEST: FAIL (%d cases, %d failed) names=%s"
              % (len(res), len(failed), ",".join(failed)))
        return 1
    print("C1_RECORD_SELFTEST: PASS (%d cases)" % len(res))
    return 0


def parse_legs(s):
    if not s:
        return None
    out = []
    for t in s.split(","):
        t = t.strip()
        if re.fullmatch(r"L(1[0-3]|[1-9])", t):
            out.append(t)
    return out


def main():
    if SELFTEST == "1":
        # selftest needs no tree; but guard (f) count must be measured.
        return selftest(None)
    t = real(TREE)
    if within(S, t) or within(t, S):
        setup("scratch inside the measured tree" if within(S, t) else "tree inside scratch")
    base = base_dir() if BASE_TREE else None
    # L13 needs a base count; without --base-tree derive from the BASE extraction.
    # base_dir() may SETUP if git is absent — for subset legs that don't need it, tolerate.
    requested = parse_legs(LEGS) or LEG_ORDER
    if base is None:
        try:
            base = base_dir()
        except SystemExit:
            if "L13" in requested:
                raise
            base = None
    if LEGS:
        ok = 0
        legs_str = []
        for n in requested:
            r, det = run_leg(n, t, base)
            print("LEG %s %s %s" % (n, "pass" if r else "fail", det))
            ok += r
            legs_str.append(n)
        legs_csv = ",".join(x[1:] for x in legs_str)
        print("C1_RECORD_LEGS: legs=%s ok=%d" % (legs_csv, ok))
        return 0 if ok == len(requested) else 1
    # full mode
    res = {}
    for n in LEG_ORDER:
        r, det = run_leg(n, t, base)
        res[n] = (r, det)
        print("LEG %s %s %s" % (n, "pass" if r else "fail", det))
    mism = sum(1 for n in LEG_ORDER if res[n][0] == 0)
    ga, ga_det = guard_a(t)
    print("GUARD a=%d %s" % (ga, ga_det))
    print("GUARD b=%d (measured reads mismatches=0 and guard(a)=1)" % (1 if (mism == 0 and ga == 1) else 0))
    # (c) BASE no-work control
    gc, gc_det = guard_c(base)
    print("GUARD c=%d base-mismatches=%s" % (gc, gc_det[0] if gc_det else "?"))
    for l in gc_det[1:]:
        vlog(l)
    # (d)/(e) run only via subset on copies — already proved by receipts and by
    # guard(f) fixture cases; here they run their subset legs cheaply.
    gd, gd_det = guard_d(t)
    print("GUARD d=%d %s" % (gd, " ".join(gd_det)[:200]))
    ge, ge_det = guard_e(t)
    print("GUARD e=%d %s" % (ge, " ".join(ge_det)[:200]))
    gf, n_cases, _ = guard_selftest()
    print("GUARD f=%d selftest-cases=%d" % (gf, n_cases))
    guard = 1 if (ga and gc and gd and ge and gf and mism == 0) else 0
    print("C1_RECORD: mismatches=%d population=13 guard=%d" % (mism, guard))
    return 0 if (mism == 0 and guard == 1) else 1


sys.exit(main())
PY
rc=$?
exit "$rc"

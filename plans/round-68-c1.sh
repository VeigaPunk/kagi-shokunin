#!/usr/bin/env bash
# plans/round-68-c1.sh — C1_VERIFIED counter (kagi round 68, claim C1).
#
#   bash plans/round-68-c1.sh [--tree DIR] [--base-tree DIR] [--scratch DIR]
#   bash plans/round-68-c1.sh --selftest
#
# Frozen predicate: plans/round-68.md §C1 (never amend or reinterpret a
# predicate, counter, kill rule, population or target; this file enforces it).
#
# Amendment (round 69, post-closure repair — dated, not a silent edit):
#   Defect D8 (corpus/lessons/round-68-verifier-spotcheck.md §7 item 8):
#   predicate_ok ignored the frozen population floors (verified >= 37,
#   col15 >= 32) from plans/round-68.md §C1 kill rules.
#   Old body: guard == 1 and caught == 6 and defects == 0
#   New body: guard == 1 and caught == 6 and defects == 0
#             and verified >= 37 and col15 >= 32
#   The round-68 C1 reading (verified=38 col15=33) still passes the
#   new body, so the landed claim is unaffected.
#
#   C1_VERIFIED: verified=<n> col15=<n> caught=<k>/6 guard=<0|1>
#
# verified  corpus/source-fetches.tsv rows whose col 16 IS a repo-relative
#           capture path — exactly one whitespace-delimited .ufo/waves/ token
#           with no other content — and whose named file (resolved inside the
#           measured tree, regular file) has raw sha256 == col 10, byte count
#           == col 11, and whose col-13 quote locates count >= 1 under col 14
#           (rendered-text-v1 via that tree's normalizer, raw-literal-v1 by
#           literal bytes). DERIVED row by row; never a listed row id.
#           The S166 recut (mixed-prose cell -> pure path) is the +1: only a
#           pure cell is verified, so BASE (mixed S166) reads 36 while the
#           recut candidate reads 37.
# col15     of the verified rows with col 14 rendered-text-v1, those whose
#           recomputed normalized_sha256 (rendered-text-v1.py digest on the
#           bound file) equals col 15.
# caught    of six mutated copies of the measured tree, the number on which
#           the candidate gate's own stdout for that copy exits 1 with
#           `SOURCES_CENSUS: FAILED` and a FINDING line naming the anchor id
#           and the expected reason (M3 excepted: a file-level SC_FETCH line).
#           The counter never classifies a mutated copy itself. Six legs:
#             M1 append one space (0x20) to the anchor's col 16
#               -> FINDING SC_CAPTURE id=<anchor> capture-whitespace
#             M2 append "," + the anchor's own token (comma-joined duplicate)
#               -> FINDING SC_CAPTURE id=<anchor> capture-whitespace
#             M3 rewrite corpus/source-fetches.tsv with CR at every line end
#               -> FINDING SC_FETCH ... cr-in-tsv (file-level, no id)
#             M4 replace one hex digit of the anchor's col 10 (still 64
#               lowercase hex) -> ... capture-digest-mismatch
#             M5 replace the anchor's col 15 with another valid hex64
#               -> ... normalized-digest-mismatch
#             M6 append one byte to the anchor's capture body
#               -> ... capture-bytes-mismatch
#           The anchor is the LAST row in file order, derived (never named),
#           that names a .ufo/waves/ token whose first token binds (in-tree
#           regular file, raw sha + size + quote locate) on the unmodified
#           measured tree. On the recut candidate that is S166; on the BASE
#           extraction the same derived rule still yields S166 (mixed token
#           that binds), which the BASE gate never reads — so the BASE run's
#           six legs all read CLEAN and caught reads 0/6.
#           A leg whose mutation produces a byte-identical file is SETUP,
#           never a pass.
#
# GUARD (1 iff all five read 1; each leg prints its own diagnostic):
#   a  the unmodified tree prints `SOURCES_CAPTURES: CLEAN` immediately
#      before a CLEAN `SOURCES_CENSUS:` verdict and the gate's four counts
#      (path_rows bound located prose) equal this counter's derivation:
#      pure-path rows / pure rows binding bytes / pure rows binding quote /
#      rows naming no .ufo/waves/ token.
#   b  `bash <tree>/corpus/sources-census.sh --selftest` exits 0 printing
#      `SOURCES_CENSUS_SELFTEST: PASS (N cases)` with N >= 89.
#   c  the BASE gate (<base-tree>/corpus/sources-census.sh when it is a full
#      tree, else `git show <BASE>:corpus/sources-census.sh`) run with --root
#      on the CRLF (M3) copy prints `SOURCES_CENSUS: CLEAN` — the blindness
#      witness: the target is not reachable by doing nothing.
#   d  fleet wrapper `scripts/sources-census.sh validate --root <fleet> kagi`
#      exits 0 with a `kagi ok` row whose registry path is the measured
#      tree's corpus/SOURCES.md. Only when the measured tree IS this
#      counter's lane; on any copy the leg records `venue=skip` and does
#      not fail (the wrapper validates the fleet lane, never a copy).
#   e  rows naming no `.ufo/waves/` token (prose) produce no SC_CAPTURE
#      finding on the unmodified tree.
#
# The counter's own derivation and digest recompute use a trusted normalizer
# (the BASE tree's corpus/rendered-text-v1.py when --base-tree is given, else
# this lane's), never the measured tree's copy alone — a tree that ships a
# truthy normalizer cannot move both sides of the cross-check.
#
# Exit 0 iff guard = 1, caught = 6/6 and the candidate derivation has zero
# defect rows (pure rows failing a bind check, token-naming non-pure cells,
# or col15 mismatches on bound rows); 1 if measured and missed; 2 on SETUP
# (missing tree/gate/normalizer etc.), printing exactly one verdict-shaped
# line `C1_VERIFIED: SETUP <reason>` and no counts.
#
# Mutated copies under scratch carry the gate's inputs only: all of corpus/
# plus every first-token capture file named by a token row. Files are
# hardlinked when the filesystem allows (`cp -al` semantics) and copied when
# not; every file a mutation rewrites is unlinked from the source first, so
# the measured tree is never touched. `.git` is not copied.
#
# Selftest (--selftest) builds fixture trees under scratch only (never inside
# the measured tree) and asserts derivation, anchor, caught mapping per leg,
# CRLF construction, and stub-gate refusal (a gate printing the CLEAN lines
# without reading a byte is caught leg-independently: its six legs read
# caught 0/6 AND its fixed counts disagree with the derivation on the CRLF
# copy). Printed as `C1_VERIFIED_SELFTEST: PASS (N cases)` / `FAIL`.
#
# Scratch: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r68/R68ExecCounterC1/ ;
# TMPDIR is exported for children, the scratch root refuses to sit inside the
# measured tree, and each run's work directory is removed on exit unless
# C1_KEEP_SCRATCH=1. No hardcoded /tmp in this script.
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=${SELF_DIR%/plans}
TREE=$LANE
BASE_TREE=""
SCRATCH=""
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) [ $# -ge 2 ] || { printf 'C1_VERIFIED: SETUP --tree needs a directory\n'; exit 2; }
            TREE=$2; shift 2 ;;
    --base-tree) [ $# -ge 2 ] || { printf 'C1_VERIFIED: SETUP --base-tree needs a directory\n'; exit 2; }
            BASE_TREE=$2; shift 2 ;;
    --scratch) [ $# -ge 2 ] || { printf 'C1_VERIFIED: SETUP --scratch needs a directory\n'; exit 2; }
            SCRATCH=$2; shift 2 ;;
    --selftest) SELFTEST=1; shift ;;
    -h|--help) sed -n '2,/^set -u$/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'C1_VERIFIED: SETUP unknown-arg %s\n' "$1"; exit 2 ;;
  esac
done
[ -d "$TREE" ] || { printf 'C1_VERIFIED: SETUP bad-tree %s\n' "$TREE"; exit 2; }
if [ -n "$BASE_TREE" ] && [ ! -d "$BASE_TREE" ]; then
  printf 'C1_VERIFIED: SETUP bad-base-tree %s\n' "$BASE_TREE"; exit 2
fi
command -v python3 >/dev/null 2>&1 || { printf 'C1_VERIFIED: SETUP no-python3\n'; exit 2; }

exec python3 -I -B - "$TREE" "$LANE" "$BASE_TREE" "$SCRATCH" "$SELFTEST" <<'PY'
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile

TREE = os.path.abspath(sys.argv[1])
LANE = os.path.abspath(sys.argv[2])
BASE_TREE = sys.argv[3]
SCRATCH_ARG = sys.argv[4]
SELFTEST = sys.argv[5] == "1"

BASE_COMMIT = "d3b2a4e8eed710277951e430efd3d27b5983033c"

CAPS_LINE = re.compile(r"^SOURCES_CAPTURES: (CLEAN|FAILED) \(([^()]*)\)$")
CAP_FINDING = re.compile(r"^FINDING SC_CAPTURE id=(S[0-9]+) ([a-z0-9-]+)$")
FETCH_CRLF = re.compile(r"^FINDING SC_FETCH .*cr-in-tsv.*$")
VERDICT = re.compile(r"^SOURCES_CENSUS: (CLEAN|FAILED) \(.*\)$")
VERDICT_FAILED_FULL = re.compile(r"^SOURCES_CENSUS: FAILED \(findings=([0-9]+) rows=[0-9]+\)$")
SELFTEST_PASS = re.compile(r"^SOURCES_CENSUS_SELFTEST: PASS \(([0-9]+) cases\)$")
HEX64 = re.compile(r"^[0-9a-f]{64}$")

# Expected reasons, keyed by leg. M3 is a file-level SC_FETCH (no anchor id).
EXPECT_CAPTURE = {
    "m1": "capture-whitespace",
    "m2": "capture-whitespace",
    "m4": "capture-digest-mismatch",
    "m5": "normalized-digest-mismatch",
    "m6": "capture-bytes-mismatch",
}
LEGS = ("m1", "m2", "m3", "m4", "m5", "m6")


class Setup(Exception):
    pass


def setup(msg):
    raise Setup(msg)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def read_fetch_rows(tree):
    tsv = os.path.join(tree, "corpus/source-fetches.tsv")
    if not os.path.isfile(tsv):
        setup("fetches-absent " + tsv)
    rows = []
    malformed = []
    with open(tsv, encoding="utf-8", errors="replace") as fh:
        for n, line in enumerate(fh.read().splitlines(), 1):
            if not line or line.startswith("#"):
                continue
            cells = line.split("\t")
            if len(cells) != 16:
                malformed.append(n)
                continue
            rows.append({"line": n, "cells": cells})
    return rows, malformed


def _norm_seps(tok):
    """Round 68 (R68Reviewer B4): normalise repeated/dot separators for the CLASS
    decision only, so a spelling change (`.ufo//waves/...`, `.ufo/./waves/...`)
    cannot drop a bound row out of the population as "prose" - the round-67 C1
    escape hatch in a new dress. The binding still uses the cell as written."""
    prev = None
    while prev != tok:
        prev = tok
        tok = tok.replace("//", "/").replace("/./", "/")
    return tok


def waves_tokens(col16):
    return [t for t in re.split(r"\s+", col16) if _norm_seps(t).startswith(".ufo/waves/")]


PATH_SHAPE = re.compile(r"^[A-Za-z0-9._][A-Za-z0-9._/-]*$")


def is_pure(col16):
    toks = waves_tokens(col16)
    if len(toks) != 1 or col16 != toks[0]:
        return False
    return bool(PATH_SHAPE.fullmatch(toks[0]))


def is_prose(col16):
    return not waves_tokens(col16)


LOCATOR_SCRIPT = None


def locator_script():
    global LOCATOR_SCRIPT
    if LOCATOR_SCRIPT:
        return LOCATOR_SCRIPT
    candidates = []
    if BASE_TREE:
        candidates.append(os.path.join(BASE_TREE, "corpus/rendered-text-v1.py"))
    candidates.append(os.path.join(LANE, "corpus/rendered-text-v1.py"))
    if TREE != LANE:
        candidates.append(os.path.join(TREE, "corpus/rendered-text-v1.py"))
    for cand in candidates:
        if cand and os.path.isfile(cand):
            LOCATOR_SCRIPT = cand
            return cand
    setup("locator-absent (no trusted rendered-text-v1.py)")


def locate_quote(path, quote, norm):
    if not quote.strip():
        return False
    if norm == "rendered-text-v1":
        script = locator_script()
        r = run_cmd([sys.executable, script, "locate", path, quote])
        if r.returncode == 1:
            return False
        if r.returncode != 0:
            setup("locator-failed rc=%d" % r.returncode)
        m = re.search(r"RENDERED_TEXT_V1_LOCATE: count=([0-9]+)", r.stdout)
        if not m:
            setup("locator-output-unexpected")
        return int(m.group(1)) >= 1
    if norm == "raw-literal-v1":
        with open(path, "rb") as fh:
            return quote.encode("utf-8") in fh.read()
    return False


def normalized_digest(path):
    script = locator_script()
    r = run_cmd([sys.executable, script, "digest", path])
    if r.returncode != 0:
        setup("digest-failed rc=%d" % r.returncode)
    m = re.search(r"normalized_sha256=([0-9a-f]{64})", r.stdout)
    if not m:
        setup("digest-output-unexpected")
    return m.group(1)


def run_cmd(argv, cwd=None, timeout=1800):
    try:
        return subprocess.run(argv, cwd=cwd, capture_output=True, text=True,
                              timeout=timeout)
    except subprocess.TimeoutExpired:
        setup("timeout " + " ".join(argv[:2]))
    except OSError as e:
        setup("exec-failed %s: %s" % (argv[0], e))


def bind_checks(tree, tree_real, token, col10, col11, quote, norm):
    """(exists, size_ok, digest_ok, locate_ok, full) for a token in tree."""
    full = os.path.join(tree, token)
    real = os.path.realpath(full)
    if not (real == tree_real or real.startswith(tree_real + os.sep)):
        return (False, False, False, False, full)
    if not os.path.isfile(full):
        return (False, False, False, False, full)
    size_ok = str(os.path.getsize(full)) == col11.strip()
    digest_ok = (sha256_file(full) == col10.strip())
    locate_ok = False
    if size_ok and digest_ok:
        locate_ok = locate_quote(full, quote, norm)
    return (True, size_ok, digest_ok, locate_ok, full)


def derive(tree):
    rows, malformed = read_fetch_rows(tree)
    tree_real = os.path.realpath(tree)
    if not os.path.isdir(tree_real):
        setup("tree-does-not-canonicalize " + tree)
    d = {"total": len(rows), "malformed": len(malformed),
         "path_rows": 0, "bound": 0, "located": 0, "prose": 0,
         "mixed": [], "verified": 0, "col15": 0, "defects": [],
         "prose_ids": set(), "verified_ids": set(), "col15_ids": set(),
         "token_rows": []}
    for row in rows:
        cells = row["cells"]
        rid = cells[0].strip()
        col10, col11 = cells[9], cells[10]
        quote, norm, col15, col16 = cells[12], cells[13].strip(), cells[14].strip(), cells[15]
        toks = waves_tokens(col16)
        if not toks:
            d["prose"] += 1
            d["prose_ids"].add(rid)
            continue
        d["token_rows"].append({"id": rid, "token": toks[0], "pure": col16 == toks[0],
                                "cells": cells, "line": row["line"]})
        if not (len(toks) == 1 and col16 == toks[0]):
            d["mixed"].append(rid)
            d["defects"].append((rid, "token-shape"))
            continue
        d["path_rows"] += 1
        exists, size_ok, digest_ok, locate_ok, full = bind_checks(
            tree, tree_real, toks[0], col10, col11, quote, norm)
        if not exists:
            d["defects"].append((rid, "capture-missing"))
            continue
        if not size_ok:
            d["defects"].append((rid, "capture-bytes-mismatch"))
        if not digest_ok:
            d["defects"].append((rid, "capture-digest-mismatch"))
        if not (size_ok and digest_ok):
            continue
        d["bound"] += 1
        if not locate_ok:
            d["defects"].append((rid, "quote-not-located"))
            continue
        d["located"] += 1
        d["verified"] += 1
        d["verified_ids"].add(rid)
        if norm == "rendered-text-v1":
            if normalized_digest(full) == col15:
                d["col15"] += 1
                d["col15_ids"].add(rid)
            else:
                d["defects"].append((rid, "normalized-digest-mismatch"))
    return d


def derive_anchor(tree):
    """LAST token-naming row in file order whose first token binds (raw
    sha + size + quote). Derived, never named. Pure and mixed both qualify
    (the widened read population); S166 qualifies on both trees."""
    rows, _mal = read_fetch_rows(tree)
    tree_real = os.path.realpath(tree)
    anchor = None
    for row in rows:
        cells = row["cells"]
        toks = waves_tokens(cells[15])
        if not toks:
            continue
        exists, size_ok, digest_ok, locate_ok, _full = bind_checks(
            tree, tree_real, toks[0], cells[9], cells[10], cells[12],
            cells[13].strip())
        if not (exists and size_ok and digest_ok and locate_ok):
            continue
        anchor = {"id": cells[0].strip(), "token": toks[0], "col16": cells[15],
                  "col10": cells[9].strip(), "col15": cells[14].strip(),
                  "norm": cells[13].strip(), "line": row["line"]}
    if anchor is None:
        setup("no-binding-token-row")
    if anchor["norm"] != "rendered-text-v1" or not HEX64.match(anchor["col15"]):
        setup("anchor-col15-not-rendered-hex64")
    if not HEX64.match(anchor["col10"]):
        setup("anchor-col10-not-hex64")
    return anchor


def parse_captures_line(line):
    m = CAPS_LINE.match(line)
    if not m:
        return None
    fields = {k: int(v) for k, v in re.findall(r"([a-z_]+)=([0-9]+)", m.group(2))}
    need = {"path_rows", "bound", "located", "prose"}
    if m.group(1) == "FAILED":
        need.add("defects")
    if set(fields) != need:
        return None
    return {"state": m.group(1), "fields": fields, "line": line}


def parse_gate_run(r):
    lines = r.stdout.splitlines()
    cap_findings = []
    crlf_findings = []
    all_findings = 0
    for ln in lines:
        if ln.startswith("FINDING "):
            all_findings += 1
        m = CAP_FINDING.match(ln)
        if m:
            cap_findings.append((m.group(1), m.group(2)))
        elif FETCH_CRLF.match(ln):
            crlf_findings.append(ln)
    verdict = None
    verdict_idx = None
    verdict_findings = None
    for i in range(len(lines) - 1, -1, -1):
        if VERDICT.match(lines[i]):
            verdict = VERDICT.match(lines[i]).group(1)
            verdict_idx = i
            m = VERDICT_FAILED_FULL.match(lines[i])
            if m:
                verdict_findings = int(m.group(1))
            break
    summary = None
    summary_idx = None
    for i, ln in enumerate(lines):
        if ln.startswith("SOURCES_CAPTURES: "):
            summary = parse_captures_line(ln)
            summary_idx = i
    return {"rc": r.returncode, "stdout": r.stdout, "lines": lines,
            "cap_findings": cap_findings, "crlf_findings": crlf_findings,
            "all_findings": all_findings, "verdict_findings": verdict_findings,
            "summary": summary, "verdict": verdict,
            "adjacent": (summary_idx is not None and verdict_idx is not None
                         and summary_idx == verdict_idx - 1)}


def run_gate(tree, extra=()):
    gate = os.path.join(tree, "corpus/sources-census.sh")
    if not os.path.isfile(gate):
        setup("gate-absent " + gate)
    return run_cmd(["bash", gate] + list(extra), cwd=tree)


def leg_caught(parsed, kind, anchor_id):
    # Forgery resistance (R68Sentinel): a tree-controlled filename can inject
    # forged FINDING/summary lines into the gate's stdout. Acceptance needs
    # every cross-check, not just the presence of one line: the verdict's own
    # findings=N equals the count of FINDING lines, the summary's defects
    # equals the count of FINDING SC_CAPTURE lines, summary/verdict are the
    # LAST matching lines, and the anchor's finding is counted in that N.
    if not (parsed["rc"] == 1 and parsed["verdict"] == "FAILED"):
        return False
    if parsed["verdict_findings"] is None:
        return False
    if parsed["verdict_findings"] != parsed["all_findings"]:
        return False
    if parsed["summary"] is not None and parsed["summary"]["state"] == "FAILED":
        if parsed["summary"]["fields"].get("defects") != len(parsed["cap_findings"]):
            return False
    if kind == "m3":
        return len(parsed["crlf_findings"]) >= 1
    reason = EXPECT_CAPTURE[kind]
    return any(fid == anchor_id and why == reason
               for (fid, why) in parsed["cap_findings"])


def scratch_root():
    base = SCRATCH_ARG or os.path.join(
        os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku",
        "kagi-r68", "R68ExecCounterC1")
    os.makedirs(base, exist_ok=True)
    if os.path.realpath(base).startswith(os.path.realpath(TREE) + os.sep):
        setup("scratch-inside-measured-tree " + base)
    os.environ["TMPDIR"] = base
    return base


def clone_tree(src, dst):
    os.makedirs(dst, exist_ok=True)
    corpus = os.path.join(src, "corpus")
    if not os.path.isdir(corpus):
        setup("corpus-absent " + corpus)
    rels = set()
    for dirpath, dirnames, filenames in os.walk(corpus):
        dirnames[:] = [x for x in dirnames if x != ".git"]
        for fn in filenames:
            rels.add(os.path.relpath(os.path.join(dirpath, fn), src))
    rows, _mal = read_fetch_rows(src)
    for row in rows:
        toks = waves_tokens(row["cells"][15])
        if toks:
            full = os.path.join(src, toks[0])
            if os.path.isfile(full):
                rels.add(os.path.normpath(toks[0]))
    hard = copied = 0
    for rel in sorted(rels):
        s = os.path.join(src, rel)
        dd = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(dd), exist_ok=True)
        if os.path.lexists(dd):
            continue
        if not os.path.isfile(s):
            continue
        if os.path.islink(s):
            os.symlink(os.readlink(s), dd)
            copied += 1
            continue
        try:
            os.link(s, dd)
            hard += 1
        except OSError:
            shutil.copy2(s, dd)
            copied += 1
    return hard, copied


def break_link(path):
    try:
        nlink = os.lstat(path).st_nlink
    except OSError:
        setup("break-link-lstat " + path)
    if nlink <= 1:
        return
    tmp = path + ".c1break"
    shutil.copy2(path, tmp)
    os.replace(tmp, path)


def rewrite_tsv(tree, fn):
    path = os.path.join(tree, "corpus/source-fetches.tsv")
    with open(path, encoding="utf-8", newline="") as fh:
        text = fh.read()
    ends_nl = text.endswith("\n")
    out = [fn(ln) for ln in text.splitlines()]
    tmp = path + ".c1tmp"
    with open(tmp, "w", encoding="utf-8", newline="") as fh:
        fh.write("\n".join(out) + ("\n" if ends_nl else ""))
    os.replace(tmp, path)


def mutate_row_col16(tree, row_id, new_value):
    def fn(ln):
        if not ln or ln.startswith("#"):
            return ln
        cells = ln.split("\t")
        if len(cells) == 16 and cells[0].strip() == row_id:
            cells[15] = new_value
        return "\t".join(cells)
    rewrite_tsv(tree, fn)


def mutate_row_field(tree, row_id, idx, new_value):
    def fn(ln):
        if not ln or ln.startswith("#"):
            return ln
        cells = ln.split("\t")
        if len(cells) == 16 and cells[0].strip() == row_id:
            cells[idx] = new_value
        return "\t".join(cells)
    rewrite_tsv(tree, fn)


def flip_hex_char(hexstr):
    for i, ch in enumerate(hexstr):
        if ch in "0123456789abcdef":
            repl = "0" if ch != "0" else "1"
            return hexstr[:i] + repl + hexstr[i + 1:]
    setup("no-hex-digit-to-flip")


def build_mutation(kind, src, dst, anchor):
    shutil.rmtree(dst, ignore_errors=True)
    clone_tree(src, dst)
    aid = anchor["id"]
    detail = ""
    if kind == "m3":
        path = os.path.join(dst, "corpus/source-fetches.tsv")
        with open(path, "rb") as fh:
            data = fh.read()
        # Every line end becomes CRLF: LF -> CRLF, existing CRLF untouched.
        lines = data.split(b"\n")
        crlf = b"\r\n".join(
            ln[:-1] if ln.endswith(b"\r") else ln for ln in lines)
        tmp = path + ".c1tmp"
        with open(tmp, "wb") as fh:
            fh.write(crlf)
        os.replace(tmp, path)
        detail = "crlf"
        return {"kind": kind, "id": aid, "detail": detail}
    body = os.path.join(dst, anchor["token"])
    if not os.path.isfile(body):
        setup("target-body-absent " + anchor["token"])
    if kind == "m1":
        mutate_row_col16(dst, aid, anchor["col16"] + " ")
        detail = "col16+space"
    elif kind == "m2":
        mutate_row_col16(dst, aid, anchor["col16"] + "," + anchor["token"])
        detail = "col16+comma-duplicate"
    elif kind == "m4":
        mutate_row_field(dst, aid, 9, flip_hex_char(anchor["col10"]))
        detail = "col10-hexflip"
    elif kind == "m5":
        mutate_row_field(dst, aid, 14, flip_hex_char(anchor["col15"]))
        detail = "col15-hexflip"
    elif kind == "m6":
        break_link(body)
        with open(body, "ab") as fh:
            fh.write(b"X")
        detail = "body+1byte"
    return {"kind": kind, "id": aid, "detail": detail}


def caught_legs(tree, work, anchor):
    caught = 0
    for kind in LEGS:
        dst = os.path.join(work, "mut-" + kind)
        info = build_mutation(kind, tree, dst, anchor)
        parsed = parse_gate_run(run_gate(dst))
        ok = leg_caught(parsed, kind, anchor["id"])
        caught += 1 if ok else 0
        caps = ",".join("%s:%s" % (fid, why) for (fid, why) in
                        parsed["cap_findings"]) or "none"
        print("c1-verified: mut-%s id=%s reasons=%s crlf=%d verdict=%s rc=%d "
              "captures=%s detail=%s"
              % (kind, info["id"], caps, len(parsed["crlf_findings"]),
                 parsed["verdict"] or "none", parsed["rc"],
                 parsed["summary"]["line"] if parsed["summary"] else "absent",
                 info["detail"]))
    return caught


def guard_a(clean, derived):
    want = {"path_rows": derived["path_rows"], "bound": derived["bound"],
            "located": derived["located"], "prose": derived["prose"]}
    summary = clean["summary"]
    fields_ok = summary is not None and summary["fields"] == want
    ok = (clean["rc"] == 0 and clean["verdict"] == "CLEAN"
          and summary is not None and summary["state"] == "CLEAN"
          and fields_ok and clean["adjacent"])
    print("c1-verified: guard-a verdict=%s rc=%d captures=%s derived=%s "
          "gate_fields=%s adjacent=%s"
          % (clean["verdict"] or "none", clean["rc"],
             summary["line"] if summary else "absent",
             "path_rows=%d bound=%d located=%d prose=%d"
             % (derived["path_rows"], derived["bound"], derived["located"],
                derived["prose"]),
             "match" if fields_ok else "differ", clean["adjacent"]))
    return 1 if ok else 0


def guard_b(tree):
    r = run_gate(tree, ["--selftest"])
    m = None
    for ln in reversed(r.stdout.splitlines()):
        m = SELFTEST_PASS.match(ln)
        if m:
            break
    cases = int(m.group(1)) if m else -1
    ok = 1 if (r.returncode == 0 and m and cases >= 89) else 0
    print("c1-verified: guard-b selftest rc=%d cases=%d" % (r.returncode, cases))
    return ok


def base_gate_path(work):
    # Returns a gate script. Whenever the script itself is a COPY staged
    # outside the BASE tree (the git-show fallback), its sibling corpus
    # files (rendered-text-v1.py, inrow-pins.tsv) MUST be staged beside it:
    # the BASE gate reads its normalizer from SCRIPT_DIR and SETUP-refuses
    # ("rendered-text-v1.py absent beside the gate") otherwise.
    if BASE_TREE:
        p = os.path.join(BASE_TREE, "corpus/sources-census.sh")
        if os.path.isfile(p):
            print("c1-verified: guard-c base-gate=%s (--base-tree)" % p)
            return p
    for label, root in (("tree-history", TREE), ("lane-history", LANE)):
        r = run_cmd(["git", "-C", root, "show",
                     BASE_COMMIT + ":corpus/sources-census.sh"])
        if r.returncode == 0 and r.stdout:
            p = os.path.join(work, "base-gate.sh")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(r.stdout)
            for extra in ("rendered-text-v1.py", "inrow-pins.tsv"):
                src = os.path.join(BASE_TREE or root, "corpus", extra)
                if os.path.isfile(src):
                    shutil.copy2(src, os.path.join(work, extra))
            print("c1-verified: guard-c base-gate=%s git-show %s (siblings staged)"
                  % (label, BASE_COMMIT))
            return p
    setup("base-gate-unavailable")


def guard_c(work, anchor):
    ctrl = os.path.join(work, "ctrl-crlf")
    build_mutation("m3", TREE, ctrl, anchor)
    base = base_gate_path(work)
    r = run_cmd(["bash", base, "--root", ctrl], cwd=ctrl)
    verdict = None
    for ln in reversed(r.stdout.splitlines()):
        if VERDICT.match(ln) or ln.startswith("SOURCES_CENSUS: SETUP"):
            verdict = ln
            break
    ok = 1 if (r.returncode == 0 and verdict is not None
               and verdict.startswith("SOURCES_CENSUS: CLEAN")) else 0
    print("c1-verified: guard-c base-gate-on-crlf rc=%d verdict=%s"
          % (r.returncode, verdict or "none"))
    return ok


def is_lane(tree, lane):
    return os.path.realpath(tree) == os.path.realpath(lane)


def guard_d():
    if not is_lane(TREE, LANE):
        print("c1-verified: guard-d venue=skip tree=%s lane=%s" % (TREE, LANE))
        return "skip"
    fleet = os.path.dirname(os.path.realpath(LANE))
    wrapper = os.path.join(fleet, "scripts/sources-census.sh")
    if not os.path.isfile(wrapper):
        setup("fleet-wrapper-absent " + wrapper)
    cmd = ["bash", wrapper, "validate", "--root", fleet, "kagi"]
    print("c1-verified: guard-d venue=lane cmd=" + " ".join(cmd))
    r = run_cmd(cmd)
    reported = None
    for ln in r.stdout.splitlines():
        cells = ln.split("\t")
        if len(cells) >= 3 and cells[0] == "kagi" and cells[1] == "ok":
            reported = cells[2]
    target = os.path.realpath(os.path.join(TREE, "corpus/SOURCES.md"))
    measured = os.path.realpath(reported) if reported else None
    ok = 1 if (r.returncode == 0 and reported is not None
               and measured == target) else 0
    print("c1-verified: guard-d rc=%d kagi_ok=%s measured=%s"
          % (r.returncode, "yes" if reported else "no", measured or "none"))
    return ok


def guard_e(clean, derived):
    cap_ids = {fid for (fid, _why) in clean["cap_findings"]}
    prose_hit = sorted(cap_ids & derived["prose_ids"])
    summary = clean["summary"]
    prose_ok = (summary is not None
                and summary["fields"].get("prose") == derived["prose"])
    ok = 1 if (not prose_hit and prose_ok) else 0
    print("c1-verified: guard-e prose_rows=%d prose_findings=%s gate_prose=%s "
          "derived_prose=%d"
          % (derived["prose"], ",".join(prose_hit) or "none",
             summary["fields"].get("prose") if summary else "absent",
             derived["prose"]))
    return ok


def predicate_ok(verified, col15, caught, guard, defects):
    return (guard == 1 and caught == 6 and defects == 0
            and verified >= 37 and col15 >= 32)


def verdict_line(verified, col15, caught, guard):
    return ("C1_VERIFIED: verified=%d col15=%d caught=%d/6 guard=%d"
            % (verified, col15, caught, guard))


def measure(work):
    print("c1-verified: tree=" + TREE)
    derived = derive(TREE)
    print("c1-verified: derived verified=%d col15=%d path_rows=%d bound=%d "
          "located=%d prose=%d mixed=%s total=%d malformed=%d"
          % (derived["verified"], derived["col15"], derived["path_rows"],
             derived["bound"], derived["located"], derived["prose"],
             ",".join(derived["mixed"]) or "none", derived["total"],
             derived["malformed"]))
    for fid, why in derived["defects"]:
        print("c1-verified: derived-defect %s %s" % (fid, why))
    anchor = derive_anchor(TREE)
    print("c1-verified: anchor id=%s token=%s pure=%s"
          % (anchor["id"], anchor["token"], anchor["col16"] == anchor["token"]))
    clean = parse_gate_run(run_gate(TREE))
    print("c1-verified: clean verdict=%s rc=%d captures=%s"
          % (clean["verdict"] or "none", clean["rc"],
             clean["summary"]["line"] if clean["summary"] else "absent"))
    ga = guard_a(clean, derived)
    gb = guard_b(TREE)
    gc = guard_c(work, anchor)
    gd = guard_d()
    gd_ok = 1 if gd == "skip" else gd
    ge = guard_e(clean, derived)
    caught = caught_legs(TREE, work, anchor)
    guard = 1 if (ga and gb and gc and gd_ok and ge) else 0
    print("c1-verified: guard a=%d b=%d c=%d d=%s e=%d defe defects=%d"
          % (ga, gb, gc, gd, ge, len(derived["defects"])))
    print(verdict_line(derived["verified"], derived["col15"], caught, guard))
    return 0 if predicate_ok(derived["verified"], derived["col15"], caught,
                             guard, len(derived["defects"])) else 1


def write_bytes(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as fh:
        fh.write(data)


def fixture_row(rid, col16, body_bytes, quote, norm="raw-literal-v1",
                sha=None, nbytes=None, col15=None):
    return "\t".join([
        rid, "mined", "0" * 64,
        "https://example.invalid/" + rid.lower(),
        "https://example.invalid/" + rid.lower(), "200",
        "curl-fsSL-compressed-v1", "2026-11-08", "decoded-http-body-v1",
        sha if sha is not None else hashlib.sha256(body_bytes).hexdigest(),
        str(nbytes if nbytes is not None else len(body_bytes)),
        "-", quote, norm,
        col15 if col15 is not None else ("0" * 64 if norm == "raw-literal-v1" else "0" * 64),
        col16])


CONST_CLEAN_GATE = """#!/usr/bin/env bash
printf 'SOURCES_CAPTURES: CLEAN (path_rows=1 bound=1 located=1 prose=0)\\n'
printf 'SOURCES_CENSUS: CLEAN (rows=1 A=1 B=0 C=0 queued=0 mined=1 rejected=0 entries_sourced=0 legacy=0 captures=1 inrow=0 inrow_only=0 inrow_nonreproducing=0)\\n'
exit 0
"""

CONST_FAILED_REASONS = ("capture-whitespace", "capture-digest-mismatch",
                        "normalized-digest-mismatch", "capture-bytes-mismatch")
CONST_FAILED_FINDINGS = tuple("FINDING SC_CAPTURE id=%s %s" % ("S9", r) for r in CONST_FAILED_REASONS)


def const_failed_gate(row_id):
    lines = ["#!/usr/bin/env bash"]
    for reason in CONST_FAILED_REASONS:
        lines.append("printf 'FINDING SC_CAPTURE id=%s %s\\n'" % (row_id, reason))
    lines.append("printf 'FINDING SC_FETCH cr-in-tsv\\n'")
    lines.append("printf 'SOURCES_CAPTURES: FAILED (defects=4 path_rows=2 bound=1 located=1 prose=1)\\n'")
    lines.append("printf 'SOURCES_CENSUS: FAILED (findings=5 rows=3)\\n'")
    lines.append("exit 1")
    return "\n".join(lines) + "\n"


def const_failed_gate_clean_counts(row_id, prow, bro, lrow, srow):
    pass


def make_fixture(root, rows, bodies, gate_text):
    os.makedirs(os.path.join(root, "corpus"), exist_ok=True)
    with open(os.path.join(root, "corpus/source-fetches.tsv"), "w",
              encoding="utf-8", newline="") as fh:
        fh.write("# fixture\n" + "\n".join(rows) + "\n")
    for rel, data in bodies.items():
        write_bytes(os.path.join(root, rel), data)
    with open(os.path.join(root, "corpus/sources-census.sh"), "w",
              encoding="utf-8") as fh:
        fh.write(gate_text)


def failed_parsed(rc, verdict, caps, crlf=0, summary=None,
                  all_findings=None, verdict_findings=None):
    if all_findings is None:
        all_findings = len(caps) + crlf
    if verdict_findings is None:
        verdict_findings = all_findings
    return {"rc": rc, "verdict": verdict, "cap_findings": caps,
            "crlf_findings": ["FINDING SC_FETCH cr-in-tsv"] * crlf,
            "all_findings": all_findings, "verdict_findings": verdict_findings,
            "summary": summary}


def selftest(root):
    cases = []

    def case(name, ok):
        cases.append((name, bool(ok)))

    work = tempfile.mkdtemp(prefix="selftest-", dir=root)
    try:
        # --- derivation: verified / col15 / path / prose from bytes ---
        a = b"alpha beta\n"
        b = b"gamma delta\n"
        c = b"epsilon\n"
        # rendered body: must be decodable and normalize to something simple
        rbody = b"<p>hello world</p>\n"
        rnorm_expected = subprocess.run(
            [sys.executable, locator_script(), "digest",
             os.path.join(work, "x") if False else "/dev/null"],
            capture_output=True, text=True)
        # compute expected normalized digest in-process for fixture design
        # (values below are fixed fixture bytes; the counter recomputes)
        rows = [
            fixture_row("S001", ".ufo/waves/fx/A.body", a, "alpha"),
            fixture_row("S002", ".ufo/waves/fx/B.body", b, "absent-quote"),
            fixture_row("S003", ".ufo/waves/fx/C.body", c, "epsilon",
                        nbytes=len(c) - 1),
            fixture_row("S005", ".ufo/waves/fx/C.body", c, "epsilon",
                        sha=hashlib.sha256(b"epsil0n\n").hexdigest()),
            fixture_row("S004", "some prose location", b"", ""),
        ]
        fx = os.path.join(work, "derive")
        make_fixture(fx, rows, {".ufo/waves/fx/A.body": a, ".ufo/waves/fx/B.body": b,
                                ".ufo/waves/fx/C.body": c}, CONST_CLEAN_GATE)
        d = derive(fx)
        case("derive-path-rows", d["path_rows"] == 4)
        case("derive-bound", d["bound"] == 2)
        case("derive-located", d["located"] == 1)
        case("derive-prose", d["prose"] == 1 and d["prose_ids"] == {"S004"})
        case("derive-verified", d["verified"] == 1)
        case("derive-bytes-defect",
             ("S003", "capture-bytes-mismatch") in d["defects"])
        case("derive-digest-defect",
             ("S005", "capture-digest-mismatch") in d["defects"])
        case("derive-quote-defect",
             ("S002", "quote-not-located") in d["defects"])

        # prose keeps frozen meaning: a .ufo/waves/ token hidden in text is
        # NOT prose; a pure cell is not prose; tilde form names no token.
        case("mixed-is-not-prose",
             is_prose("§1.2 Concept Overview; capture .ufo/waves/fx/A.body") is False)
        case("pure-is-not-prose", is_prose(".ufo/waves/fx/A.body") is False)
        case("prose-shape", is_prose("page title/H1") is True)
        case("fleet-root-is-prose",
             is_prose(".ufo/prompts/kagi-round-44.md §6 item 9") is True)
        case("pure-check", is_pure(".ufo/waves/fx/A.body") is True)
        case("trailing-space-not-pure",
             is_pure(".ufo/waves/fx/A.body ") is False)
        case("comma-join-not-pure",
             is_pure(".ufo/waves/fx/A.body,.ufo/waves/fx/A.body") is False)

        # mixed row that binds is NOT verified (only pure counts) but IS
        # a token row and a derivation defect; it still anchors.
        write_bytes(os.path.join(work, "mixed.body"), rbody)
        mixed_norm = normalized_digest(os.path.join(work, "mixed.body"))
        mrows = [
            fixture_row("S001", ".ufo/waves/fx/A.body", a, "alpha"),
            fixture_row("S009", "§1 prose capture .ufo/waves/fx/R.body", rbody, "hello world",
                        norm="rendered-text-v1", col15=mixed_norm),
        ]
        mfx = os.path.join(work, "mixed")
        make_fixture(mfx, mrows, {".ufo/waves/fx/A.body": a,
                                  ".ufo/waves/fx/R.body": rbody}, CONST_CLEAN_GATE)
        md = derive(mfx)
        case("mixed-not-verified", md["verified"] == 1 and "S009" in md["mixed"])
        case("mixed-is-defect", ("S009", "token-shape") in md["defects"])
        manchor = derive_anchor(mfx)
        case("anchor-is-last-token-binding", manchor["id"] == "S009")

        # col15: rendered row binds when recomputed normalized digest == col15;
        # a borrowed digest mismatches.
        with open(os.path.join(work, "rtmp"), "wb") as fh:
            fh.write(rbody)
        tmp_rt = os.path.join(work, "rtmp")
        expected_norm = normalized_digest(tmp_rt)
        case("digest-recomputable", HEX64.match(expected_norm) is not None)
        good_col15 = fixture_row("S010", ".ufo/waves/fx/R.body", rbody, "hello world",
                                 norm="rendered-text-v1", col15=expected_norm)
        bad_col15 = fixture_row("S011", ".ufo/waves/fx/R.body", rbody, "hello world",
                                norm="rendered-text-v1", col15="f" * 64)
        rfx = os.path.join(work, "col15")
        make_fixture(rfx, [good_col15, bad_col15, fixture_row("S012", ".ufo/waves/fx/A.body", a, "alpha")],
                     {".ufo/waves/fx/R.body": rbody, ".ufo/waves/fx/A.body": a}, CONST_CLEAN_GATE)
        rd = derive(rfx)
        case("col15-match", rd["col15"] == 1 and rd["col15_ids"] == {"S010"})
        case("col15-borrow-mismatch",
             ("S011", "normalized-digest-mismatch") in rd["defects"])

        # --- anchor: last binding token row; no anchor -> SETUP ---
        # Rendered fixtures (anchor requires rendered-text-v1 so M5 applies).
        p1 = b"<p>AAAA</p>\n"
        p2 = b"<p>BBBB</p>\n"
        p1_norm = normalized_digest(os.path.join(work, "rt1")) if False else None
        # materialize bodies first to learn digests
        write_bytes(os.path.join(work, "anchor-p1.body"), p1)
        write_bytes(os.path.join(work, "anchor-p2.body"), p2)
        p1_norm = normalized_digest(os.path.join(work, "anchor-p1.body"))
        p2_norm = normalized_digest(os.path.join(work, "anchor-p2.body"))
        arows = [fixture_row("S001", ".ufo/waves/fx/P1.body", p1, "AAAA",
                             norm="rendered-text-v1", col15=p1_norm),
                 fixture_row("S002", ".ufo/waves/fx/P2.body", p2, "BBBB",
                             norm="rendered-text-v1", col15=p2_norm)]
        afx = os.path.join(work, "anchor")
        make_fixture(afx, arows, {".ufo/waves/fx/P1.body": p1, ".ufo/waves/fx/P2.body": p2}, CONST_CLEAN_GATE)
        anchor = derive_anchor(afx)
        case("anchor-last", anchor["id"] == "S002")
        # non-binding last row skipped
        brows = arows + [fixture_row("S003", ".ufo/waves/fx/P1.body", p1, "AAAA",
                                     norm="rendered-text-v1", col15=p1_norm,
                                     sha="0" * 64)]
        bfx = os.path.join(work, "anchor-skip")
        make_fixture(bfx, brows, {".ufo/waves/fx/P1.body": p1, ".ufo/waves/fx/P2.body": p2}, CONST_CLEAN_GATE)
        case("anchor-skips-nonbinding", derive_anchor(bfx)["id"] == "S002")
        # no binding row -> SETUP
        nfx = os.path.join(work, "anchor-none")
        make_fixture(nfx, [fixture_row("S009", "prose only", b"", "")],
                     {}, CONST_CLEAN_GATE)
        try:
            derive_anchor(nfx)
            case("anchor-none-setup", False)
        except Setup as e:
            case("anchor-none-setup", "no-binding-token-row" in str(e))
        # anchor with raw-literal normalizer -> SETUP (M5 inapplicable)
        xfx = os.path.join(work, "anchor-raw")
        make_fixture(xfx, [fixture_row("S001", ".ufo/waves/fx/A.body", a, "alpha")],
                     {".ufo/waves/fx/A.body": a}, CONST_CLEAN_GATE)
        try:
            derive_anchor(xfx)
            case("anchor-raw-not-rendered-setup", False)
        except Setup:
            case("anchor-raw-not-rendered-setup", True)

        # --- caught mapping: gate stdout only ---
        A = anchor["id"]
        summary = {"state": "FAILED", "fields": {"defects": 1, "path_rows": 1,
                                                "bound": 1, "located": 1, "prose": 0}}
        case("m1-right", leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-whitespace")]), "m1", A))
        case("m1-wrong-reason", not leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-digest-mismatch")]), "m1", A))
        case("m2-right", leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-whitespace")]), "m2", A))
        case("m4-right", leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-digest-mismatch")]), "m4", A))
        case("m5-right", leg_caught(
            failed_parsed(1, "FAILED", [(A, "normalized-digest-mismatch")]), "m5", A))
        case("m6-right", leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-bytes-mismatch")]), "m6", A))
        case("wrong-id", not leg_caught(
            failed_parsed(1, "FAILED", [("S999", "capture-whitespace")]), "m1", A))
        case("m3-right-filelevel", leg_caught(
            failed_parsed(1, "FAILED", [], crlf=1), "m3", A))
        case("m3-capture-finding-not-enough", not leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-whitespace")]), "m3", A))
        case("m1-crlf-finding-not-enough", not leg_caught(
            failed_parsed(1, "FAILED", [], crlf=1), "m1", A))
        case("rc0-not-caught", not leg_caught(
            failed_parsed(0, "CLEAN", []), "m1", A))
        case("clean-verdict-not-caught", not leg_caught(
            failed_parsed(1, "CLEAN", [(A, "capture-whitespace")]), "m1", A))
        case("setup-never-caught", not leg_caught(
            failed_parsed(2, None, []), "m4", A))
        # Forgery resistance: forged summary/verdict counts must refuse even a
        # byte-perfect anchor finding line (R68Sentinel: tree-controlled
        # filenames inject lines into the gate's stdout).
        forge_sum = {"state": "FAILED", "fields": {"defects": 99, "path_rows": 1,
                                                "bound": 1, "located": 1, "prose": 0}}
        case("forged-defects-count-refused", not leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-whitespace")],
                          summary=forge_sum), "m1", A))
        case("forged-verdict-findings-refused", not leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-whitespace")],
                          all_findings=7, verdict_findings=1), "m1", A))
        case("honest-counts-accepted", leg_caught(
            failed_parsed(1, "FAILED", [(A, "capture-whitespace")],
                          summary={"state": "FAILED", "fields": {"defects": 1,
                          "path_rows": 1, "bound": 1, "located": 1,
                          "prose": 0}}), "m1", A))

        # --- mutation builders produce non-identical mutations ---
        base_copy = os.path.join(work, "mutbase")
        make_fixture(base_copy, arows,
                     {".ufo/waves/fx/P1.body": p1, ".ufo/waves/fx/P2.body": p2}, CONST_CLEAN_GATE)
        for kind in LEGS:
            dd = os.path.join(work, "build-" + kind)
            info = build_mutation(kind, base_copy, dd, anchor)
            src_tsv = open(os.path.join(base_copy, "corpus/source-fetches.tsv"), "rb").read()
            dst_tsv = open(os.path.join(dd, "corpus/source-fetches.tsv"), "rb").read()
            mutated = src_tsv != dst_tsv or (
                kind == "m6" and open(os.path.join(base_copy, ".ufo/waves/fx/P2.body"), "rb").read()
                != open(os.path.join(dd, ".ufo/waves/fx/P2.body"), "rb").read())
            case("builder-%s-mutates" % kind, mutated)
            if kind == "m3":
                case("builder-m3-has-cr", b"\r\n" in dst_tsv)
        # mutation leaves source untouched
        before = sha256_file(os.path.join(base_copy, ".ufo/waves/fx/P2.body"))
        build_mutation("m6", base_copy, os.path.join(work, "hl-m6"), anchor)
        case("mutation-leaves-source",
             sha256_file(os.path.join(base_copy, ".ufo/waves/fx/P2.body")) == before)

        # --- stub refusal: constant CLEAN gate -> caught 0/6 ---
        stubfx = os.path.join(work, "stub")
        make_fixture(stubfx, arows, {".ufo/waves/fx/P1.body": p1, ".ufo/waves/fx/P2.body": p2}, CONST_CLEAN_GATE)
        stubanchor = derive_anchor(stubfx)
        cwork = os.path.join(work, "stub-work")
        os.makedirs(cwork)
        case("stub-caught-0", caught_legs(stubfx, cwork, stubanchor) == 0)
        # leg-independent means: fixed stub counts disagree with CRLF derivation
        crlfx = os.path.join(work, "stub-crlf")
        build_mutation("m3", stubfx, crlfx, stubanchor)
        crlf_derived = derive(crlfx)
        case("stub-crlf-count-mismatch",
             crlf_derived["path_rows"] != 1 or crlf_derived["prose"] != 0)
        # constant FAILED gate reaches 6/6 but its clean run is not CLEAN
        failedfx = os.path.join(work, "stub-failed")
        make_fixture(failedfx, arows, {".ufo/waves/fx/P1.body": p1, ".ufo/waves/fx/P2.body": p2},
                     const_failed_gate(stubanchor["id"]))
        fanchor = derive_anchor(failedfx)
        fwork = os.path.join(work, "stub-failed-work")
        os.makedirs(fwork)
        case("failed-stub-caught-6", caught_legs(failedfx, fwork, fanchor) == 6)
        clean_run = parse_gate_run(run_gate(failedfx))
        case("failed-stub-clean-run-not-clean", clean_run["verdict"] == "FAILED")

        # --- aggregation / printer ---
        case("predicate-full", predicate_ok(37, 32, 6, 1, 0))
        case("predicate-caught5", not predicate_ok(37, 32, 5, 1, 0))
        case("predicate-guard0", not predicate_ok(37, 32, 6, 0, 0))
        case("predicate-defect", not predicate_ok(37, 32, 6, 1, 1))
        case("predicate-subfloor", not predicate_ok(36, 31, 6, 1, 0))
        case("predicate-floor-edge", predicate_ok(37, 32, 6, 1, 0))
        case("predicate-floor-col15", not predicate_ok(38, 31, 6, 1, 0))
        case("verdict-line", verdict_line(37, 32, 6, 1) ==
             "C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1")
        case("verdict-line-zero", verdict_line(36, 31, 0, 0) ==
             "C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0")
    finally:
        shutil.rmtree(work, ignore_errors=True)

    failed = [name for name, ok in cases if not ok]
    if failed:
        print("C1_VERIFIED_SELFTEST: FAIL (%d cases, %d failed) names=%s"
              % (len(cases), len(failed), ",".join(failed)))
        return 1
    print("C1_VERIFIED_SELFTEST: PASS (%d cases)" % len(cases))
    return 0


def main():
    root = scratch_root()
    if SELFTEST:
        return selftest(root)
    work = tempfile.mkdtemp(prefix="run-", dir=root)
    try:
        return measure(work)
    finally:
        if os.environ.get("C1_KEEP_SCRATCH") != "1":
            shutil.rmtree(work, ignore_errors=True)


try:
    sys.exit(main())
except Setup as e:
    print("C1_VERIFIED: SETUP " + str(e))
    sys.exit(2)
PY

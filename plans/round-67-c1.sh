#!/usr/bin/env bash
# plans/round-67-c1.sh — C1_READTHROUGH counter (kagi round 67, claim C1).
#
#   bash plans/round-67-c1.sh [--tree DIR] [--base-tree DIR] [--scratch DIR]
#   bash plans/round-67-c1.sh --selftest
#
# Frozen predicate: plans/round-67.md §C1 as amended by Amendment A2 (A2.1-A2.6;
# this instrument enforces A2.1-A2.5).  The target, label and population are the
# plan's; the construction below is what A2 requires.
#
#   C1_READTHROUGH: bound=<n> located=<n> caught=<k>/6 guard=<0|1>
#
# bound   corpus/source-fetches.tsv rows whose col 16 is capture-path-shaped
#         (contains `/` and matches ^[A-Za-z0-9._][A-Za-z0-9._/-]*$, or the
#         absolute ^/[A-Za-z0-9._][A-Za-z0-9._/-]*$ form of A2.1) and whose named
#         repo-relative file canonicalizes inside the measured tree, is a
#         regular file, has raw sha256 == col 10 and size == col 11.  DERIVED
#         row by row; never a literal.  Absolute locations are counted in
#         path_rows and are always outside-root defects.
# located those bound rows whose declared quote (col 13) locates count >= 1 in
#         that file under col 14: rendered-text-v1 via
#         `corpus/rendered-text-v1.py locate`, raw-literal-v1 by literal byte
#         substring.  DERIVED as well.
# caught  of six mutated copies of the measured tree, the number on which the
#         candidate gate's OWN STDOUT for that copy exits 1 with
#         `SOURCES_CENSUS: FAILED`, prints `SOURCES_CAPTURES: FAILED` with
#         defects == the number of SC_CAPTURE lines, and contains
#         `FINDING SC_CAPTURE id=<mutated-id> <expected reason>` for the id the
#         counter mutated.  Findings for other ids do not count; the counter
#         never classifies a mutated copy itself.  A2.3 legs:
#           M1 repoint: the anchor row's col 16 -> an in-tree capture file of
#              the SAME byte count and a DIFFERENT sha256 (derived, not listed;
#              on the lane it resolves to S143 -> .ufo/waves/round-64/capture/
#              S143.body, both 264946 B); expected capture-digest-mismatch.
#              No such target, or only byte-identical targets, is SETUP.
#           M2 truncate the anchor's body by one byte; expected
#              capture-bytes-mismatch AND capture-digest-mismatch.
#           M3 delete the anchor's body; expected capture-missing.
#           M4 anchor col 16 -> the absolute path of its own body; expected
#              capture-outside-root.
#           M5 anchor col 16 -> a `..` location escaping the tree; expected
#              capture-outside-root.
#           M6 anchor col 13 -> a non-empty <=25-word string that does not
#              locate; expected quote-not-located.
#         The anchor is the first capture-shaped row (file order) that binds
#         its declared bytes and has a same-size/different-sha capture target;
#         its id is the mutated id for all six legs.
#
# GUARD (1 iff all seven read 1; each leg prints its own diagnostic):
#   a  the unmodified tree prints a CLEAN `SOURCES_CAPTURES:` line immediately
#      before a CLEAN verdict, the gate's four counts equal this counter's
#      derivation, and the derivation has path_rows == bound == located == the
#      BASE capture population (A2.4; no literal 36/120 in this file).
#   b  `bash <tree>/corpus/sources-census.sh --selftest` exits 0 with
#      `SOURCES_CENSUS_SELFTEST: PASS (N cases)`, N >= 84.
#   c  the BASE gate — `<base-tree>/corpus/sources-census.sh` when it is a full
#      tree, else `git show <BASE>:corpus/sources-census.sh` from the tree or
#      this lane — run with --root on the M1 repointed copy prints
#      `SOURCES_CENSUS: CLEAN`: doing nothing cannot reach the target.
#   d  A2.5 venue: only when the measured tree IS this counter's lane does the
#      fleet wrapper `scripts/sources-census.sh validate --root <fleet> kagi`
#      run; it must print a `kagi ok` row whose registry path is the measured
#      tree's corpus/SOURCES.md.  On any other tree the leg records
#      `venue=skip` and does not fail.
#   e  no prose row id appears in a SC_CAPTURE finding and the gate's prose
#      count equals the derived prose count.
#   f  instrument identity (R67Sentinel V-1): the candidate's
#      corpus/rendered-text-v1.py — the normalizer that decides `located` —
#      hashes byte-identically to the BASE copy (--base-tree's file, else
#      `git show <BASE>:corpus/rendered-text-v1.py`).  The counter's own
#      derivation reads a trusted normalizer (BASE_TREE's, else this lane's),
#      never the measured tree's copy, so a truthy normalizer cannot move both
#      sides of the cross-check.
#   pop A2.4 population identity: the candidate's capture-path-shaped id set
#      and each id's col 16 and col 10 are byte-identical to the BASE values
#      derived from `git show <BASE>:corpus/source-fetches.tsv` (or
#      `--base-tree`'s TSV when it carries one; a copy without history falls
#      back to this lane's committed blob, declared in the diagnostic).  A
#      rerouted row, an added/removed capture id or a changed col 16/col 10
#      fails this leg.
#
# The predicate exits 0 iff guard = 1, caught = 6, and bound/located reach the
# derived BASE population (the frozen kill rule expressed against the derived
# population, not a hard-coded number).  A SETUP line is never a pass.  A
# constant printer is refused by guard (a)'s data cross-check, guard (pop)'s
# identity, and the mutation legs (the selftest replays all six legs against a
# stub gate that prints the unmodified CLEAN summary: caught must read 0/6).
#
# Mutated copies under scratch carry the gate's inputs only: all of corpus/ and
# every capture-shaped location file (the M1 target is one of them).  Files are
# hardlinked when the filesystem allows (`cp -al` semantics) and copied when
# not; every file a mutation rewrites is unlinked from the source first, so the
# measured tree is never touched.  `.git` is not copied (the gate never reads
# it, and no git mutation is performed).
#
# Output: `c1-readthrough:` provenance lines, then exactly one verdict line
# (or `C1_READTHROUGH: SETUP <reason>`, exit 2).  Exit 0 iff the predicate
# holds; 1 if measured and missed; 2 on SETUP.
#
# Scratch: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r67/R67ExecCounterC1/ ;
# TMPDIR is exported for children, the scratch root refuses to sit inside the
# measured tree, and each run's work directory is removed on exit unless
# C1_KEEP_SCRATCH=1.
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=${SELF_DIR%/plans}
TREE=$LANE
BASE_TREE=""
SCRATCH=""
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) [ $# -ge 2 ] || { printf 'C1_READTHROUGH: SETUP --tree needs a directory\n'; exit 2; }
            TREE=$2; shift 2 ;;
    --base-tree) [ $# -ge 2 ] || { printf 'C1_READTHROUGH: SETUP --base-tree needs a directory\n'; exit 2; }
            BASE_TREE=$2; shift 2 ;;
    --scratch) [ $# -ge 2 ] || { printf 'C1_READTHROUGH: SETUP --scratch needs a directory\n'; exit 2; }
            SCRATCH=$2; shift 2 ;;
    --selftest) SELFTEST=1; shift ;;
    -h|--help) sed -n '2,/^set -u$/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'C1_READTHROUGH: SETUP unknown-arg %s\n' "$1"; exit 2 ;;
  esac
done
[ -d "$TREE" ] || { printf 'C1_READTHROUGH: SETUP bad-tree %s\n' "$TREE"; exit 2; }
if [ -n "$BASE_TREE" ] && [ ! -d "$BASE_TREE" ]; then
  printf 'C1_READTHROUGH: SETUP bad-base-tree %s\n' "$BASE_TREE"; exit 2
fi
command -v python3 >/dev/null 2>&1 || { printf 'C1_READTHROUGH: SETUP no-python3\n'; exit 2; }

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

BASE_COMMIT = "076701a11a58e3eb58d996b4c76c5e18071fb179"
NONLOCATING_QUOTE = "zzc1notlocatedquotezz"

REL_SHAPE = re.compile(r"^[A-Za-z0-9._][A-Za-z0-9._/-]*$")
ABS_SHAPE = re.compile(r"^/[A-Za-z0-9._][A-Za-z0-9._/-]*$")
CAPS_LINE = re.compile(r"^SOURCES_CAPTURES: (CLEAN|FAILED) \(([^()]*)\)$")
CAP_FINDING = re.compile(
    r"^FINDING SC_CAPTURE id=(S[0-9]{3,}) "
    r"(capture-outside-root|capture-missing|capture-digest-mismatch|"
    r"capture-bytes-mismatch|quote-not-located)$")
VERDICT = re.compile(r"^SOURCES_CENSUS: (CLEAN|FAILED) \(.*\)$")
SELFTEST_PASS = re.compile(r"^SOURCES_CENSUS_SELFTEST: PASS \(([0-9]+) cases\)$")

# A2.3 expected reasons per leg; M2 falsifies both declarations.
EXPECT = (
    ("m1", ("capture-digest-mismatch",)),
    ("m2", ("capture-bytes-mismatch", "capture-digest-mismatch")),
    ("m3", ("capture-missing",)),
    ("m4", ("capture-outside-root",)),
    ("m5", ("capture-outside-root",)),
    ("m6", ("quote-not-located",)),
)


class Setup(Exception):
    pass


def setup(msg):
    raise Setup(msg)


# --------------------------------------------------------------------------
# registry derivation (the predicate's bound/located/population)
# --------------------------------------------------------------------------

def capture_shaped(loc):
    """A2.1: slash plus the repo-relative pattern, or an absolute path of the
    same pattern (always a violation, still counted as a capture row)."""
    if "/" not in loc:
        return False
    return bool(REL_SHAPE.fullmatch(loc) or ABS_SHAPE.fullmatch(loc))


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def read_fetch_rows(tsv):
    rows = []
    malformed = []
    if not os.path.isfile(tsv):
        setup("fetches-absent " + tsv)
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


def parse_tsv_text(text):
    rows = []
    for line in text.splitlines():
        if not line or line.startswith("#"):
            continue
        cells = line.split("\t")
        if len(cells) == 16:
            rows.append(cells)
    return rows


def capture_rows(tree):
    """Capture-shaped rows in file order, with raw col 16/col 10 for A2.4."""
    rows, malformed = read_fetch_rows(os.path.join(tree,
                                                  "corpus/source-fetches.tsv"))
    shaped = []
    for row in rows:
        cells = row["cells"]
        loc = cells[15]
        if not capture_shaped(loc):
            continue
        shaped.append({"id": cells[0].strip(), "loc": loc,
                       "sha": cells[9].strip(), "bytes": cells[10].strip(),
                       "quote": cells[12], "norm": cells[13].strip(),
                       "col16": cells[15], "col10": cells[9],
                       "cells": cells, "line": row["line"]})
    return shaped, len(rows), malformed


LOCATOR_SCRIPT = None


def locator_script():
    """The normalizer used for the counter's own derivation.

    Round 67 R67Sentinel V-1: never the candidate tree's copy - a tree that
    ships a truthy normalizer would move both sides of the cross-check. Prefer
    the BASE tree's committed copy, then this lane's.
    """
    global LOCATOR_SCRIPT
    if LOCATOR_SCRIPT:
        return LOCATOR_SCRIPT
    candidates = []
    if BASE_TREE:
        candidates.append(os.path.join(BASE_TREE, "corpus/rendered-text-v1.py"))
    candidates.append(os.path.join(LANE, "corpus/rendered-text-v1.py"))
    for cand in candidates:
        if os.path.isfile(cand):
            LOCATOR_SCRIPT = cand
            return cand
    setup("locator-absent (no trusted rendered-text-v1.py)")


def locate_quote(tree, path, quote, norm):
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
    return False  # undeclared normalization already fails SC_FETCH


def derive(tree):
    tsv = os.path.join(tree, "corpus/source-fetches.tsv")
    rows, malformed = read_fetch_rows(tsv)
    tree_real = os.path.realpath(tree)
    if not os.path.isdir(tree_real):
        setup("tree-does-not-canonicalize " + tree)
    d = {"path_rows": 0, "bound": 0, "located": 0, "prose": 0,
         "malformed": len(malformed), "defects": [],
         "prose_ids": set(), "located_ids": set()}
    for row in rows:
        cells = row["cells"]
        rid = cells[0].strip()
        loc = cells[15]
        if not capture_shaped(loc):
            d["prose"] += 1
            d["prose_ids"].add(rid)
            continue
        d["path_rows"] += 1
        if loc.startswith("/"):
            d["defects"].append((rid, "capture-outside-root"))
            continue
        full = os.path.join(tree, loc)
        real = os.path.realpath(full)
        if not (real == tree_real or real.startswith(tree_real + os.sep)):
            d["defects"].append((rid, "capture-outside-root"))
            continue
        if not os.path.isfile(full):
            d["defects"].append((rid, "capture-missing"))
            continue
        size = os.path.getsize(full)
        got = sha256_file(full)
        bad = False
        dec_bytes = cells[10].strip()
        if not dec_bytes.isdigit() or str(size) != dec_bytes:
            d["defects"].append((rid, "capture-bytes-mismatch"))
            bad = True
        if got != cells[9].strip():
            d["defects"].append((rid, "capture-digest-mismatch"))
            bad = True
        if bad:
            continue
        d["bound"] += 1
        if locate_quote(tree, full, cells[12], cells[13].strip()):
            d["located"] += 1
            d["located_ids"].add(rid)
        else:
            d["defects"].append((rid, "quote-not-located"))
    return d


# --------------------------------------------------------------------------
# A2.4 population identity + A2.3 anchor derivation
# --------------------------------------------------------------------------

def base_tsv_text():
    if BASE_TREE:
        p = os.path.join(BASE_TREE, "corpus/source-fetches.tsv")
        if os.path.isfile(p):
            with open(p, encoding="utf-8", errors="replace") as fh:
                return fh.read(), "base-tree " + p
    for label, root in (("tree-history", TREE), ("lane-history", LANE)):
        r = run_cmd(["git", "-C", root, "show",
                     BASE_COMMIT + ":corpus/source-fetches.tsv"])
        if r.returncode == 0 and r.stdout:
            return r.stdout, "%s git show %s" % (label, BASE_COMMIT)
    setup("base-population-unavailable")


def base_population():
    text, source = base_tsv_text()
    pop = {}
    for cells in parse_tsv_text(text):
        loc = cells[15]
        if capture_shaped(loc):
            pop[cells[0].strip()] = (cells[15], cells[9])
    if not pop:
        setup("base-population-empty")
    return pop, source


def population_identity(shaped, base_pop):
    cand = {r["id"]: (r["col16"], r["col10"]) for r in shaped}
    missing = sorted(set(base_pop) - set(cand))
    extra = sorted(set(cand) - set(base_pop))
    changed = sorted(k for k in (set(cand) & set(base_pop))
                     if cand[k] != base_pop[k])
    return {"ok": not (missing or extra or changed), "missing": missing,
            "extra": extra, "changed": changed, "base_size": len(base_pop)}


def derive_anchor(tree):
    """A2.3 M1 anchor: a binding capture-shaped row with a same-size,
    different-sha in-tree capture file.  Derived; identical bodies excluded."""
    shaped, _n, _m = capture_rows(tree)
    tree_real = os.path.realpath(tree)
    paths = [r["loc"] for r in shaped if not r["loc"].startswith("/")]
    for r in shaped:
        if r["loc"].startswith("/"):
            continue
        try:
            dec = int(r["bytes"])
        except ValueError:
            continue
        body = os.path.join(tree, r["loc"])
        if not os.path.isfile(body):
            continue
        real = os.path.realpath(body)
        if not (real == tree_real or real.startswith(tree_real + os.sep)):
            continue
        if os.path.getsize(body) != dec or sha256_file(body) != r["sha"]:
            continue
        for p in paths:
            if p == r["loc"] or ".." in p.split("/"):
                continue
            full = os.path.join(tree, p)
            realp = os.path.realpath(full)
            if not (realp == tree_real or realp.startswith(tree_real + os.sep)):
                continue
            if not os.path.isfile(full):
                continue
            if os.path.getsize(full) != dec:
                continue
            if sha256_file(full) == r["sha"]:
                continue
            return {"id": r["id"], "loc": r["loc"], "target": p,
                    "bytes": dec, "sha": r["sha"], "quote": r["quote"],
                    "norm": r["norm"]}
    setup("m1-no-same-size-different-sha-capture-target")


# --------------------------------------------------------------------------
# gate runs and output parsing
# --------------------------------------------------------------------------

def run_cmd(argv, cwd=None, timeout=1800):
    try:
        return subprocess.run(argv, cwd=cwd, capture_output=True, text=True,
                              timeout=timeout)
    except subprocess.TimeoutExpired:
        setup("timeout " + " ".join(argv[:2]))
    except OSError as e:
        setup("exec-failed %s: %s" % (argv[0], e))


def parse_captures_line(line):
    m = CAPS_LINE.match(line)
    if not m:
        return None
    fields = {k: int(v) for k, v in re.findall(r"([a-z_]+)=([0-9]+)",
                                                m.group(2))}
    need = {"path_rows", "bound", "located", "prose"}
    if m.group(1) == "FAILED":
        need.add("defects")
    if set(fields) != need:
        return None
    return {"state": m.group(1), "fields": fields, "line": line}


def parse_gate_run(r):
    lines = r.stdout.splitlines()
    findings = []
    for ln in lines:
        m = CAP_FINDING.match(ln)
        if m:
            findings.append((m.group(1), m.group(2)))
    verdict = None
    verdict_idx = None
    for i in range(len(lines) - 1, -1, -1):
        m = VERDICT.match(lines[i])
        if m:
            verdict = m.group(1)
            verdict_idx = i
            break
    summary = None
    summary_idx = None
    for i, ln in enumerate(lines):
        if ln.startswith("SOURCES_CAPTURES: "):
            summary = parse_captures_line(ln)
            summary_idx = i
    return {"rc": r.returncode, "stdout": r.stdout, "lines": lines,
            "findings": findings, "summary": summary, "verdict": verdict,
            "adjacent": (summary_idx is not None and verdict_idx is not None
                         and summary_idx == verdict_idx - 1)}


def run_gate(tree, extra=()):
    gate = os.path.join(tree, "corpus/sources-census.sh")
    if not os.path.isfile(gate):
        setup("gate-absent " + gate)
    return run_cmd(["bash", gate] + list(extra), cwd=tree)


def leg_caught(rc, verdict, summary, findings, target, expected):
    """A2.3 caught: the gate's own output only.  Exit 1, FAILED verdict,
    FAILED SOURCES_CAPTURES line whose defects count is the number of
    SC_CAPTURE lines, and every expected reason on the mutated id.  SETUP
    (rc 2) is never a catch; other ids do not count."""
    if not (rc == 1 and verdict == "FAILED" and summary is not None
            and summary["state"] == "FAILED"):
        return False
    if summary["fields"].get("defects") != len(findings):
        return False
    got = {reason for (fid, reason) in findings if fid == target}
    return all(reason in got for reason in expected)


# --------------------------------------------------------------------------
# mutated copies
# --------------------------------------------------------------------------

def scratch_root():
    base = SCRATCH_ARG or os.path.join(
        os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku",
        "kagi-r67", "R67ExecCounterC1")
    os.makedirs(base, exist_ok=True)
    if os.path.realpath(base).startswith(os.path.realpath(TREE) + os.sep):
        setup("scratch-inside-measured-tree " + base)
    os.environ["TMPDIR"] = base
    return base


def clone_tree(src, dst):
    """The gate's inputs: corpus/ in full plus every capture-shaped location
    (the M1 target is one of them).  Hardlink where possible (`cp -al`
    semantics), copy otherwise.  Returns (hardlinked, copied)."""
    os.makedirs(dst, exist_ok=True)
    corpus = os.path.join(src, "corpus")
    if not os.path.isdir(corpus):
        setup("corpus-absent " + corpus)
    rels = set()
    for dirpath, dirnames, filenames in os.walk(corpus):
        dirnames[:] = [x for x in dirnames if x != ".git"]
        for fn in filenames:
            rels.add(os.path.relpath(os.path.join(dirpath, fn), src))
    shaped, _n, _m = capture_rows(src)
    for r in shaped:
        if r["loc"].startswith("/"):
            continue
        full = os.path.join(src, r["loc"])
        if os.path.isfile(full):
            rels.add(os.path.normpath(r["loc"]))
    hard = copied = 0
    for rel in sorted(rels):
        s = os.path.join(src, rel)
        d = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(d), exist_ok=True)
        if os.path.lexists(d):
            continue
        if not os.path.isfile(s):
            continue
        if os.path.islink(s):
            os.symlink(os.readlink(s), d)
            copied += 1
            continue
        try:
            os.link(s, d)
            hard += 1
        except OSError:
            shutil.copy2(s, d)
            copied += 1
    return hard, copied


def break_link(path):
    """A mutation must never write through a hardlink into the source tree."""
    try:
        nlink = os.lstat(path).st_nlink
    except OSError:
        setup("break-link-lstat " + path)
    if nlink <= 1:
        return
    tmp = path + ".c1break"
    shutil.copy2(path, tmp)
    os.replace(tmp, path)


def mutate_row_field(tree, row_id, idx, value):
    path = os.path.join(tree, "corpus/source-fetches.tsv")
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    ends_nl = text.endswith("\n")
    out = []
    hits = 0
    for ln in text.splitlines():
        if not ln or ln.startswith("#"):
            out.append(ln)
            continue
        cells = ln.split("\t")
        if len(cells) == 16 and cells[0].strip() == row_id:
            cells[idx] = value
            hits += 1
        out.append("\t".join(cells))
    if hits != 1:
        setup("mutation-target-count=%d %s" % (hits, row_id))
    tmp = path + ".c1tmp"
    with open(tmp, "w", encoding="utf-8", newline="") as fh:
        fh.write("\n".join(out) + ("\n" if ends_nl else ""))
    os.replace(tmp, path)


def target_body(tree, loc):
    if loc.startswith("/") or ".." in loc.split("/"):
        setup("target-location-not-repo-relative " + loc)
    body = os.path.join(tree, loc)
    if not os.path.isfile(body):
        setup("target-body-absent " + loc)
    return body


def build_mutation(kind, src, dst, anchor):
    expected = dict(EXPECT).get(kind)
    if expected is None:
        setup("unknown-mutation " + kind)
    shutil.rmtree(dst, ignore_errors=True)
    clone_tree(src, dst)
    aid = anchor["id"]
    loc = anchor["loc"]
    detail = ""
    if kind == "m1":
        target = anchor["target"]
        tgt = os.path.join(dst, target)
        if not os.path.isfile(tgt):
            setup("m1-target-absent " + target)
        if os.path.getsize(tgt) != anchor["bytes"]:
            setup("m1-target-size-drift " + target)
        if sha256_file(tgt) == anchor["sha"]:
            setup("m1-target-identical-body " + target)
        mutate_row_field(dst, aid, 15, target)
        detail = "loc=%s" % target
    else:
        body = target_body(dst, loc)
        if kind == "m2":
            break_link(body)
            size = os.path.getsize(body)
            if size < 1:
                setup("target-body-empty " + loc)
            os.truncate(body, size - 1)
            detail = "bytes=%d (was %d)" % (size - 1, size)
        elif kind == "m3":
            os.unlink(body)
            detail = "removed=" + loc
        elif kind == "m4":
            absolute = os.path.realpath(body)
            mutate_row_field(dst, aid, 15, absolute)
            detail = "loc=" + absolute
        elif kind == "m5":
            outside = dst.rstrip("/") + "-outside"
            shutil.rmtree(outside, ignore_errors=True)
            os.makedirs(outside)
            base = os.path.basename(loc)
            shutil.copy2(body, os.path.join(outside, base))
            rel = "../" + os.path.basename(outside) + "/" + base
            if not capture_shaped(rel):
                setup("m5-not-shaped " + rel)
            mutate_row_field(dst, aid, 15, rel)
            detail = "loc=" + rel
        elif kind == "m6":
            if locate_quote(dst, body, NONLOCATING_QUOTE, anchor["norm"]):
                setup("nonlocating-quote-locates")
            mutate_row_field(dst, aid, 12, NONLOCATING_QUOTE)
            detail = "quote=" + NONLOCATING_QUOTE
    return {"kind": kind, "id": aid, "expected": expected, "detail": detail}


def caught_legs(tree, work, anchor):
    caught = 0
    for kind, expected in EXPECT:
        dst = os.path.join(work, "mut-" + kind)
        info = build_mutation(kind, tree, dst, anchor)
        parsed = parse_gate_run(run_gate(dst))
        reasons = [r for (fid, r) in parsed["findings"] if fid == info["id"]]
        summary_state = parsed["summary"]["state"] if parsed["summary"] else "absent"
        defects = (parsed["summary"]["fields"].get("defects")
                   if parsed["summary"] else None)
        ok = leg_caught(parsed["rc"], parsed["verdict"], parsed["summary"],
                        parsed["findings"], info["id"], expected)
        caught += 1 if ok else 0
        print("c1-readthrough: mut-%s id=%s expected=%s reasons=%s defects=%s "
              "findings=%d verdict=%s rc=%d captures=%s detail=%s"
              % (kind, info["id"], "+".join(expected),
                 ",".join(reasons) or "none", defects, len(parsed["findings"]),
                 parsed["verdict"] or "none", parsed["rc"], summary_state,
                 info["detail"]))
    return caught


# --------------------------------------------------------------------------
# guard legs
# --------------------------------------------------------------------------

def guard_a(clean, derived, population):
    want = {"path_rows": derived["path_rows"], "bound": derived["bound"],
            "located": derived["located"], "prose": derived["prose"]}
    summary = clean["summary"]
    fields_ok = summary is not None and summary["fields"] == want
    counts_ok = (derived["path_rows"] == population
                 and derived["bound"] == population
                 and derived["located"] == population)
    ok = (clean["rc"] == 0 and clean["verdict"] == "CLEAN"
          and summary is not None and summary["state"] == "CLEAN"
          and fields_ok and counts_ok and clean["adjacent"])
    print("c1-readthrough: guard-a verdict=%s rc=%d captures=%s derived=%s "
          "gate_fields=%s adjacent=%s population=%d"
          % (clean["verdict"] or "none", clean["rc"],
             summary["line"] if summary else "absent",
             "path_rows=%d bound=%d located=%d prose=%d"
             % (derived["path_rows"], derived["bound"], derived["located"],
                derived["prose"]),
             "match" if fields_ok else "differ", clean["adjacent"], population))
    return 1 if ok else 0


def guard_b(tree):
    r = run_gate(tree, ["--selftest"])
    m = None
    for ln in reversed(r.stdout.splitlines()):
        m = SELFTEST_PASS.match(ln)
        if m:
            break
    cases = int(m.group(1)) if m else -1
    ok = 1 if (r.returncode == 0 and m and cases >= 84) else 0
    print("c1-readthrough: guard-b selftest rc=%d cases=%d" % (r.returncode, cases))
    return ok


def base_gate_path(work):
    if BASE_TREE:
        p = os.path.join(BASE_TREE, "corpus/sources-census.sh")
        if os.path.isfile(p):
            print("c1-readthrough: guard-c base-gate=%s (--base-tree)" % p)
            return p
    for label, root in (("tree-history", TREE), ("lane-history", LANE)):
        r = run_cmd(["git", "-C", root, "show",
                     BASE_COMMIT + ":corpus/sources-census.sh"])
        if r.returncode == 0 and r.stdout:
            p = os.path.join(work, "base-gate.sh")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(r.stdout)
            print("c1-readthrough: guard-c base-gate=%s git-show %s"
                  % (label, BASE_COMMIT))
            return p
    setup("base-gate-unavailable")


def guard_c(work, anchor):
    ctrl = os.path.join(work, "ctrl-base")
    build_mutation("m1", TREE, ctrl, anchor)
    base = base_gate_path(work)
    r = run_cmd(["bash", base, "--root", ctrl], cwd=ctrl)
    verdict = None
    for ln in reversed(r.stdout.splitlines()):
        if VERDICT.match(ln) or ln.startswith("SOURCES_CENSUS: SETUP"):
            verdict = ln
            break
    ok = 1 if (r.returncode == 0 and verdict is not None
               and verdict.startswith("SOURCES_CENSUS: CLEAN")) else 0
    print("c1-readthrough: guard-c base-gate-on-repoint rc=%d verdict=%s"
          % (r.returncode, verdict or "none"))
    return ok


def is_lane(tree, lane):
    try:
        return os.path.realpath(tree) == os.path.realpath(lane)
    except OSError:
        return False


def guard_d():
    """A2.5: only the deployed lane tree runs the fleet wrapper; a copy is
    venue=skip and does not fail the guard."""
    if not is_lane(TREE, LANE):
        print("c1-readthrough: guard-d venue=skip tree=%s lane=%s"
              % (TREE, LANE))
        return "skip"
    fleet = os.path.dirname(os.path.realpath(LANE))
    wrapper = os.path.join(fleet, "scripts/sources-census.sh")
    if not os.path.isfile(wrapper):
        setup("fleet-wrapper-absent " + wrapper)
    cmd = ["bash", wrapper, "validate", "--root", fleet, "kagi"]
    print("c1-readthrough: guard-d venue=lane cmd=" + " ".join(cmd))
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
    print("c1-readthrough: guard-d rc=%d kagi_ok=%s measured=%s"
          % (r.returncode, "yes" if reported else "no", measured or "none"))
    return ok


def guard_e(clean, derived):
    cap_ids = {fid for (fid, _r) in clean["findings"]}
    prose_hit = sorted(cap_ids & derived["prose_ids"])
    summary = clean["summary"]
    prose_ok = (summary is not None
                and summary["fields"].get("prose") == derived["prose"])
    ok = 1 if (not prose_hit and prose_ok) else 0
    print("c1-readthrough: guard-e prose_rows=%d prose_findings=%s "
          "gate_prose=%s derived_prose=%d"
          % (derived["prose"], ",".join(prose_hit) or "none",
             summary["fields"].get("prose") if summary else "absent",
             derived["prose"]))
    return ok


def normalizer_identity(cand_sha, base_sha):
    """Guard (f): the normalizer that decides `located` is the committed one."""
    return 1 if (cand_sha is not None and base_sha is not None
                 and cand_sha == base_sha) else 0


def guard_f():
    """Instrument identity: the candidate's normalizer is the committed one."""
    cand = os.path.join(TREE, "corpus/rendered-text-v1.py")
    if not os.path.isfile(cand):
        print("c1-readthrough: guard-f candidate-normalizer=absent")
        return 0
    with open(cand, "rb") as fh:
        cand_sha = hashlib.sha256(fh.read()).hexdigest()
    base_sha = None
    if BASE_TREE and os.path.isfile(os.path.join(BASE_TREE, "corpus/rendered-text-v1.py")):
        with open(os.path.join(BASE_TREE, "corpus/rendered-text-v1.py"), "rb") as fh:
            base_sha = hashlib.sha256(fh.read()).hexdigest()
    else:
        for root in (TREE, LANE):
            r = run_cmd(["git", "-C", root, "show", BASE_COMMIT + ":corpus/rendered-text-v1.py"])
            if r.returncode == 0 and r.stdout:
                base_sha = hashlib.sha256(r.stdout.encode("utf-8")).hexdigest()
                break
    if base_sha is None:
        print("c1-readthrough: guard-f base-normalizer=unavailable")
        return 0
    ok = normalizer_identity(cand_sha, base_sha)
    print("c1-readthrough: guard-f candidate=%s base=%s verdict=%s"
          % (cand_sha[:16], base_sha[:16], "same" if ok else "DIFFERS"))
    return ok


def guard_pop(identity, source):
    print("c1-readthrough: guard-pop base_ids=%d missing=%s extra=%s "
          "changed=%s source=%s"
          % (identity["base_size"], ",".join(identity["missing"]) or "none",
             ",".join(identity["extra"]) or "none",
             ",".join(identity["changed"]) or "none", source))
    return 1 if identity["ok"] else 0


# --------------------------------------------------------------------------
# verdict aggregation (factored for the selftest boundary cases)
# --------------------------------------------------------------------------

def predicate_ok(bound, located, caught, guard, population):
    return (guard == 1 and bound >= population and located >= population
            and caught == 6)


def verdict_line(bound, located, caught, guard):
    return ("C1_READTHROUGH: bound=%d located=%d caught=%d/6 guard=%d"
            % (bound, located, caught, guard))


# --------------------------------------------------------------------------
# measurement
# --------------------------------------------------------------------------

def measure(work):
    print("c1-readthrough: tree=" + TREE)
    derived = derive(TREE)
    print("c1-readthrough: derived path_rows=%d bound=%d located=%d prose=%d "
          "malformed=%d"
          % (derived["path_rows"], derived["bound"], derived["located"],
             derived["prose"], derived["malformed"]))
    for fid, why in derived["defects"]:
        print("c1-readthrough: derived-defect %s %s" % (fid, why))

    shaped, _n, _m = capture_rows(TREE)
    base_pop, pop_source = base_population()
    identity = population_identity(shaped, base_pop)
    population = len(base_pop)
    print("c1-readthrough: population base_ids=%d source=%s candidate=%d"
          % (population, pop_source, len(shaped)))
    anchor = derive_anchor(TREE)
    print("c1-readthrough: anchor id=%s loc=%s target=%s bytes=%d"
          % (anchor["id"], anchor["loc"], anchor["target"], anchor["bytes"]))

    clean = parse_gate_run(run_gate(TREE))
    summary_line = clean["summary"]["line"] if clean["summary"] else "absent"
    print("c1-readthrough: clean verdict=%s rc=%d captures=%s"
          % (clean["verdict"] or "none", clean["rc"], summary_line))
    ga = guard_a(clean, derived, population)
    gb = guard_b(TREE)
    gc = guard_c(work, anchor)
    gd = guard_d()
    gd_ok = 1 if gd == "skip" else gd
    ge = guard_e(clean, derived)
    gf = guard_f()
    gp = guard_pop(identity, pop_source)
    caught = caught_legs(TREE, work, anchor)
    guard = 1 if (ga and gb and gc and gd_ok and ge and gf and gp) else 0
    print("c1-readthrough: guard a=%d b=%d c=%d d=%s e=%d f=%d pop=%d"
          % (ga, gb, gc, gd, ge, gf, gp))
    print(verdict_line(derived["bound"], derived["located"], caught, guard))
    return 0 if predicate_ok(derived["bound"], derived["located"], caught,
                             guard, population) else 1


# --------------------------------------------------------------------------
# selftest: fixture trees under scratch only (never inside the measured tree)
# --------------------------------------------------------------------------

def write_bytes(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as fh:
        fh.write(data)


def fixture_row(rid, body_rel, body_bytes, quote, norm="raw-literal-v1",
                sha=None, nbytes=None):
    return "\t".join([
        rid, "mined", "0" * 64,
        "https://example.invalid/" + rid.lower(),
        "https://example.invalid/" + rid.lower(), "200",
        "curl-fsSL-compressed-v1", "2026-11-08", "decoded-http-body-v1",
        sha or hashlib.sha256(body_bytes).hexdigest(),
        str(nbytes if nbytes is not None else len(body_bytes)),
        "-", quote, norm, "-" if norm == "raw-literal-v1" else "0" * 64,
        body_rel])


CONST_CLEAN_GATE = """#!/usr/bin/env bash
printf 'SOURCES_CAPTURES: CLEAN (path_rows=1 bound=1 located=1 prose=0)\\n'
printf 'SOURCES_CENSUS: CLEAN (rows=1 A=1 B=0 C=0 queued=0 mined=1 rejected=0 entries_sourced=0 legacy=0 captures=1 inrow=0 inrow_only=0 inrow_nonreproducing=0)\\n'
exit 0
"""


def const_failed_gate(row_id):
    reasons = ("capture-digest-mismatch", "capture-bytes-mismatch",
               "capture-missing", "capture-outside-root", "quote-not-located")
    lines = ["#!/usr/bin/env bash"]
    for reason in reasons:
        lines.append("printf 'FINDING SC_CAPTURE id=%s %s\\n'"
                     % (row_id, reason))
    lines.append("printf 'SOURCES_CAPTURES: FAILED (defects=5 path_rows=1 "
                 "bound=1 located=1 prose=0)\\n'")
    lines.append("printf 'SOURCES_CENSUS: FAILED (findings=5 rows=1)\\n'")
    lines.append("exit 1")
    return "\n".join(lines) + "\n"


def make_fixture(root, rows, bodies, gate_text):
    os.makedirs(os.path.join(root, "corpus"), exist_ok=True)
    with open(os.path.join(root, "corpus/source-fetches.tsv"), "w",
              encoding="utf-8") as fh:
        fh.write("# fixture\n" + "\n".join(rows) + "\n")
    for rel, data in bodies.items():
        write_bytes(os.path.join(root, rel), data)
    with open(os.path.join(root, "corpus/sources-census.sh"), "w",
              encoding="utf-8") as fh:
        fh.write(gate_text)


def failed_summary(defects):
    return {"state": "FAILED",
            "fields": {"defects": defects, "path_rows": 1, "bound": 1,
                       "located": 1, "prose": 0}}


def selftest(root):
    cases = []

    def case(name, ok):
        cases.append((name, bool(ok)))

    work = tempfile.mkdtemp(prefix="selftest-", dir=root)
    try:
        # --- derivation: bound/located/prose come from bytes, not literals ---
        a = b"alpha beta\n"
        b = b"gamma delta\n"
        c = b"epsilon\n"
        rows = [
            fixture_row("S001", ".ufo/fx/A.body", a, "alpha"),
            fixture_row("S002", ".ufo/fx/B.body", b, "absent-quote"),
            fixture_row("S003", ".ufo/fx/C.body", c, "epsilon",
                        nbytes=len(c) - 1),
            fixture_row("S005", ".ufo/fx/C.body", c, "epsilon",
                        sha=hashlib.sha256(b"epsil0n\n").hexdigest()),
            fixture_row("S004", "some prose location §1", b"", ""),
        ]
        fx = os.path.join(work, "derive")
        make_fixture(fx, rows, {".ufo/fx/A.body": a, ".ufo/fx/B.body": b,
                                ".ufo/fx/C.body": c}, CONST_CLEAN_GATE)
        d = derive(fx)
        case("derive-path-rows", d["path_rows"] == 4)
        case("derive-bound", d["bound"] == 2)
        case("derive-located", d["located"] == 1)
        case("derive-prose", d["prose"] == 1 and d["prose_ids"] == {"S004"})
        case("derive-bytes-defect",
             ("S003", "capture-bytes-mismatch") in d["defects"])
        case("derive-digest-defect",
             ("S005", "capture-digest-mismatch") in d["defects"])
        case("derive-quote-defect",
             ("S002", "quote-not-located") in d["defects"])

        # --- A2.3 anchor derivation: same byte count, different sha256 ------
        p1 = b"AAAA\n"
        p2 = b"BBBB\n"
        arows = [fixture_row("S164", ".ufo/fx/S164.body", p1, "AAAA"),
                 fixture_row("S143", ".ufo/fx/S143.body", p2, "BBBB")]
        abodies = {".ufo/fx/S164.body": p1, ".ufo/fx/S143.body": p2}
        afx = os.path.join(work, "anchor")
        make_fixture(afx, arows, abodies, CONST_CLEAN_GATE)
        anchor = derive_anchor(afx)
        case("anchor-id-derived", anchor["id"] == "S164")
        case("anchor-same-size-target", anchor["target"] == ".ufo/fx/S143.body")
        # only a size-different target -> SETUP
        nfx = os.path.join(work, "anchor-size")
        make_fixture(nfx, [fixture_row("S164", ".ufo/fx/S164.body", p1, "AAAA")],
                     {".ufo/fx/S164.body": p1,
                      ".ufo/fx/other.body": b"longer body\n"}, CONST_CLEAN_GATE)
        try:
            derive_anchor(nfx)
            case("anchor-no-same-size-setup", False)
        except Setup as e:
            case("anchor-no-same-size-setup", "same-size" in str(e))
        # a byte-identical target is not a mutation -> SETUP
        ifx = os.path.join(work, "anchor-identical")
        make_fixture(ifx, [fixture_row("S164", ".ufo/fx/S164.body", p1, "AAAA"),
                           fixture_row("S143", ".ufo/fx/S143.body", p1, "AAAA")],
                     {".ufo/fx/S164.body": p1, ".ufo/fx/S143.body": p1},
                     CONST_CLEAN_GATE)
        try:
            derive_anchor(ifx)
            case("anchor-identical-body-setup", False)
        except Setup as e:
            case("anchor-identical-body-setup", "same-size" in str(e))

        # --- A2.3 caught mapping: gate stdout only, every field load-bearing --
        good = [("S164", "capture-digest-mismatch")]
        s1 = failed_summary(1)
        case("caught-right", leg_caught(1, "FAILED", s1, good, "S164",
                                        ("capture-digest-mismatch",)))
        case("caught-wrong-reason", not leg_caught(
            1, "FAILED", s1, good, "S164", ("capture-bytes-mismatch",)))
        case("caught-wrong-id", not leg_caught(
            1, "FAILED", s1, good, "S165", ("capture-digest-mismatch",)))
        case("caught-rc0", not leg_caught(
            0, "CLEAN", s1, [], "S164", ("capture-digest-mismatch",)))
        case("caught-setup-never", not leg_caught(
            2, None, None, [], "S164", ("capture-digest-mismatch",)))
        case("caught-no-summary", not leg_caught(
            1, "FAILED", None, good, "S164", ("capture-digest-mismatch",)))
        both = [("S164", "capture-bytes-mismatch"),
                ("S164", "capture-digest-mismatch")]
        s2 = failed_summary(2)
        case("m2-requires-both",
             leg_caught(1, "FAILED", s2, both, "S164",
                        ("capture-bytes-mismatch", "capture-digest-mismatch")))
        case("m2-bytes-alone-not-enough", not leg_caught(
            1, "FAILED", failed_summary(1), both[:1], "S164",
            ("capture-bytes-mismatch", "capture-digest-mismatch")))
        case("m2-digest-alone-not-enough", not leg_caught(
            1, "FAILED", failed_summary(1), both[1:], "S164",
            ("capture-bytes-mismatch", "capture-digest-mismatch")))
        case("defects-count-is-lines", not leg_caught(
            1, "FAILED", failed_summary(1), both, "S164",
            ("capture-bytes-mismatch", "capture-digest-mismatch")))

        # --- A2.3 stub replay: constant CLEAN summary -> caught 0/6 ---------
        cwork = os.path.join(work, "const-clean-work")
        os.makedirs(cwork)
        case("constant-clean-stub-caught-0",
             caught_legs(afx, cwork, anchor) == 0)

        # a constant FAILED gate reaches 6/6 but its clean run is not CLEAN,
        # so guard (a) refuses it (calibration, not a pass)
        ffx = os.path.join(work, "const-failed")
        make_fixture(ffx, arows, abodies, const_failed_gate(anchor["id"]))
        fwork = os.path.join(work, "const-failed-work")
        os.makedirs(fwork)
        case("constant-failed-stub-caught-6",
             caught_legs(ffx, fwork, anchor) == 6)
        clean_run = parse_gate_run(run_gate(ffx))
        case("constant-failed-clean-run-not-clean",
             clean_run["verdict"] == "FAILED")

        # --- A2.4 population identity ---------------------------------------
        base = {"S164": (".ufo/fx/S164.body",
                         hashlib.sha256(p1).hexdigest()),
                "S143": (".ufo/fx/S143.body",
                         hashlib.sha256(p2).hexdigest())}
        cand_rows, _n, _m = capture_rows(afx)
        case("population-identical", population_identity(cand_rows, base)["ok"])
        case("population-base-size", population_identity(cand_rows, base)["base_size"] == 2)
        missing_pop = dict(base)
        missing_pop.pop("S143")
        case("population-missing-id",
             not population_identity(cand_rows, missing_pop)["ok"])
        extra_pop = dict(base)
        extra_pop["S999"] = (".ufo/fx/X.body", "0" * 64)
        case("population-extra-id",
             not population_identity(cand_rows, extra_pop)["ok"])
        changed16 = dict(base)
        changed16["S164"] = (".ufo/fx/OTHER.body", base["S164"][1])
        case("population-col16-change",
             not population_identity(cand_rows, changed16)["ok"])
        changed10 = dict(base)
        changed10["S164"] = (base["S164"][0], "f" * 64)
        case("population-col10-change",
             not population_identity(cand_rows, changed10)["ok"])
        recol = [dict(r) for r in cand_rows]
        for r in recol:
            r["quote"] = "a different quote"
            r["cells"] = list(r["cells"])
            r["cells"][12] = r["quote"]
        case("population-col13-change-allowed",
             population_identity(recol, base)["ok"])

        # --- A2.5 venue ------------------------------------------------------
        case("venue-lane", is_lane("/home/x/kagi-shokunin",
                                   "/home/x/kagi-shokunin"))
        case("venue-copy-skip", not is_lane("/tmp/copy-of-lane",
                                            "/home/x/kagi-shokunin"))

        # --- a mutation never writes through a hardlink into the source ------
        before = sha256_file(os.path.join(afx, ".ufo/fx/S164.body"))
        build_mutation("m2", afx, os.path.join(work, "hl-m2"), anchor)
        after = sha256_file(os.path.join(afx, ".ufo/fx/S164.body"))
        build_mutation("m3", afx, os.path.join(work, "hl-m3"), anchor)
        case("mutation-leaves-source-truncate", before == after)
        case("mutation-leaves-source-delete",
             os.path.isfile(os.path.join(afx, ".ufo/fx/S164.body")))

        # --- summary-line parser --------------------------------------------
        p = parse_captures_line(
            "SOURCES_CAPTURES: CLEAN (path_rows=3 bound=2 located=1 prose=4)")
        case("parse-clean-fields",
             p is not None and p["state"] == "CLEAN"
             and p["fields"] == {"path_rows": 3, "bound": 2, "located": 1,
                                 "prose": 4})
        p = parse_captures_line(
            "SOURCES_CAPTURES: FAILED (defects=2 path_rows=3 bound=2 "
            "located=1 prose=4)")
        case("parse-failed-fields",
             p is not None and p["state"] == "FAILED"
             and p["fields"] == {"defects": 2, "path_rows": 3, "bound": 2,
                                 "located": 1, "prose": 4})
        case("parse-garbage-refused", parse_captures_line("CLEAN") is None)
        case("parse-missing-field-refused", parse_captures_line(
            "SOURCES_CAPTURES: CLEAN (path_rows=3 bound=2 prose=1)") is None)

        # --- guard (f): normalizer identity (R67Sentinel V-1) ----------------
        case("normalizer-identical",
             normalizer_identity("a" * 64, "a" * 64) == 1)
        case("normalizer-differs",
             normalizer_identity("a" * 64, "b" * 64) == 0)
        case("normalizer-base-missing",
             normalizer_identity("a" * 64, None) == 0)
        case("normalizer-candidate-missing",
             normalizer_identity(None, "a" * 64) == 0)

        # --- aggregation/printer against a derived population ----------------
        case("predicate-full", predicate_ok(2, 2, 6, 1, 2))
        case("predicate-bound-short", not predicate_ok(1, 2, 6, 1, 2))
        case("predicate-located-short", not predicate_ok(2, 1, 6, 1, 2))
        case("predicate-caught5", not predicate_ok(2, 2, 5, 1, 2))
        case("predicate-guard0", not predicate_ok(2, 2, 6, 0, 2))
        case("verdict-line-measured",
             verdict_line(35, 34, 5, 0) ==
             "C1_READTHROUGH: bound=35 located=34 caught=5/6 guard=0")
        case("verdict-line-full",
             verdict_line(36, 36, 6, 1) ==
             "C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1")
    finally:
        shutil.rmtree(work, ignore_errors=True)

    failed = [name for name, ok in cases if not ok]
    if failed:
        print("C1_READTHROUGH_SELFTEST: FAIL (%d cases, %d failed) names=%s"
              % (len(cases), len(failed), ",".join(failed)))
        return 1
    print("C1_READTHROUGH_SELFTEST: PASS (%d cases)" % len(cases))
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
    print("C1_READTHROUGH: SETUP " + str(e))
    sys.exit(2)
PY

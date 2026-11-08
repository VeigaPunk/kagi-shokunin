#!/usr/bin/env bash
# plans/round-66-c1.sh — C1_CARRIER counter (kagi round 66, claim C1).
#
#   bash plans/round-66-c1.sh [--tree DIR] [--base-tree DIR] [--scratch DIR]
#   bash plans/round-66-c1.sh --selftest
#
# Frozen predicate: plans/round-66.md §C1 as amended by Amendment A1.
#
# Three anchors must resolve to ONE path P whose sha256 equals the pin the
# registry row carries (path equality + digest match — the only mechanism this
# lane has):
#   registry  the capture path cited in the anchor cell of the registry row
#             that carries the pin and supersedes S148 (id S164 at freeze);
#   fetches   the same path in that row's source-fetches.tsv 16th column,
#             with columns 10/11 equal to the pin and its byte count;
#   volatile  corpus/volatile-shape.py DEFAULT_CAPTURE.
#
# GUARD (1 iff all four read 1):
#   a  a byte-identical BASE tree (--base-tree, an extracted d549ee6) resolves
#      NO carrier path: drift=0 is READ, never SETUP
#   b  --selftest exits 0
#   c  the round-65 volatile-shape gate still prints `VOLATILE_SHAPE: match=1`
#      on the measured tree
#   d  a copy whose registry anchor and fetch column name the WRONG file
#      (.ufo/waves/round-64/capture/S148.body, the arXiv body) reads drift=0
#      with `digest-mismatch:` naming it
#
# Mutation hardening (R66MutC1 battery, applied before the reading):
#   * every anchor's digest refusal has its own selftest case
#     (registry / fetches / volatile fail independently);
#   * the frozen exit aggregation is a function, `verdict_ok`, with the
#     boundary cases (hex=2, hex=4, paths=2, drift=0, guard=0) asserted;
#   * the mutation leg reads the RESOLVED carrier path, never a constant,
#     and an alternate-carrier fixture proves it.
#
# Population correction (measured, for the round-66 lesson): A1's sentence
# names "(S143/S156/S157)" as the three wrong-id bodies, but S143.body IS the
# carrier on the repaired tree (its bytes are the pin), so a third copy of it
# measures nothing. The three bodies this counter mutates are the three
# round-64 captures whose bytes are NOT the pin: S148.body (the arXiv body),
# S156.body and S157.body. The plan text is the L1's to correct; the counter
# asserts the property (three distinct bodies, each hashing differently from
# the pin) rather than the id list.
#
# Output: `c1-carrier:` provenance lines, then exactly one verdict line
#   C1_CARRIER: drift=A paths=3 hex=3 match=1 guard=G
# Exit 0 iff guard=1 and drift=1; 1 otherwise; 2 SETUP.
#
# Scratch: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r66/C1Counter/ ; TMPDIR is
# exported for children; nothing is written inside the measured tree and the
# scratch root refuses to sit inside it (QM74).
set -u
SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=${SELF_DIR%/plans}
TREE=$LANE
BASE_TREE=""
SCRATCH=""
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=$2; shift 2;;
    --base-tree) BASE_TREE=$2; shift 2;;
    --scratch) SCRATCH=$2; shift 2;;
    --selftest) SELFTEST=1; shift;;
    *) echo "c1-carrier: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "c1-carrier: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$LANE" ] || { echo "c1-carrier: SETUP bad-lane $LANE" >&2; exit 2; }
if [ -n "$BASE_TREE" ] && [ ! -d "$BASE_TREE" ]; then
  echo "c1-carrier: SETUP bad-base-tree $BASE_TREE" >&2; exit 2
fi
command -v python3 >/dev/null 2>&1 || { echo "c1-carrier: SETUP no-python3" >&2; exit 2; }

exec python3 -I -B - "$TREE" "$LANE" "$BASE_TREE" "$SCRATCH" "$SELFTEST" <<'PY'
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile

TREE, LANE = sys.argv[1], sys.argv[2]
BASE_TREE, SCRATCH = sys.argv[3], sys.argv[4]
SELFTEST = sys.argv[5] == "1"

PIN = "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750cba40"
PIN_BYTES = 264946
# Three capture bodies whose bytes are NOT the pin: the arXiv QAOA body that
# sits at the S148 filename, and two round-64 bodies that carry other ids'
# pins (borrowed identity, measured). S143.body is the carrier itself and is
# excluded by construction.
WRONG_PATHS = [".ufo/waves/round-64/capture/S148.body",
               ".ufo/waves/round-64/capture/S156.body",
               ".ufo/waves/round-64/capture/S157.body"]
WRONG_FILE = ".ufo/waves/round-64/capture/S148.body"
PATH_RE = re.compile(r"\.ufo/waves/round-[0-9]+/capture/[A-Za-z0-9_.-]+\.body")


def setup(msg):
    print("c1-carrier: SETUP " + msg)
    raise SystemExit(2)


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def scratch_root():
    base = SCRATCH or (os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku")
    root = os.path.join(base, "kagi-r66", "C1Counter")
    os.makedirs(root, exist_ok=True)
    if os.path.realpath(root).startswith(os.path.realpath(TREE) + os.sep):
        setup("scratch-inside-measured-tree " + root)
    os.environ["TMPDIR"] = root
    return root


def read(root, rel):
    p = os.path.join(root, rel)
    if not os.path.isfile(p):
        return None
    with open(p, encoding="utf-8", errors="replace") as fh:
        return fh.read()


def resolve_anchor(root):
    """The registry row that carries the pin AND names a capture path."""
    txt = read(root, "corpus/SOURCES.md")
    if txt is None:
        return None, None, "sources-absent"
    best = None
    for line in txt.splitlines():
        if not line.startswith("| S"):
            continue
        cells = line.split("|")
        if len(cells) != 13:
            continue
        rid = cells[1].strip()
        if not re.match(r"^S[0-9]{3,}$", rid):
            continue
        anchor = cells[6]
        if PIN not in line:
            continue
        m = PATH_RE.search(anchor)
        if not m:
            continue
        if best is None or int(rid[1:]) > int(best[0][1:]):
            best = (rid, m.group(0))
    if best is None:
        return None, None, "no-row-carries-pin-with-path"
    return best[0], best[1], ""


def resolve_fetch(root, rid):
    txt = read(root, "corpus/source-fetches.tsv")
    if txt is None:
        return None, "fetches-absent"
    for line in txt.splitlines():
        if line.startswith("#") or not line.startswith(rid + "\t"):
            continue
        cells = line.split("\t")
        if len(cells) != 16:
            return None, "fetch-row-shape"
        path = cells[15].strip()
        if not PATH_RE.fullmatch(path or ""):
            return None, "col16-is-not-a-capture-path"
        if cells[9].strip() != PIN:
            return None, "col10-not-the-pin"
        if cells[10].strip() != str(PIN_BYTES):
            return None, "col11-not-the-byte-count"
        return path, ""
    return None, "fetch-row-absent"


def resolve_volatile(root):
    txt = read(root, "corpus/volatile-shape.py")
    if txt is None:
        return None, "volatile-gate-absent"
    m = re.search(r'^DEFAULT_CAPTURE\s*=\s*"([^"]+)"', txt, re.M)
    if not m:
        return None, "no-DEFAULT_CAPTURE"
    return m.group(1), ""


def resolve(root):
    rid, reg, d1 = resolve_anchor(root)
    fet, d2 = (None, "no-row") if rid is None else resolve_fetch(root, rid)
    vol, d3 = resolve_volatile(root)
    return rid, [(reg, d1 or ""), (fet, d2 or ""), (vol, d3 or "")]


def drift_of(root):
    rid, anchors = resolve(root)
    diag = []
    paths = []
    for name, (p, d) in zip(("registry", "fetches", "volatile"), anchors):
        if p is None:
            diag.append("%s:%s" % (name, d or "unresolved"))
            continue
        full = os.path.join(root, p)
        if not os.path.isfile(full):
            diag.append("%s:path-missing:%s" % (name, p))
            continue
        got = sha256(full)
        if got != PIN:
            diag.append("%s:digest-mismatch:%s" % (name, p))
            continue
        paths.append(p)
    drift = 1 if (len(paths) == 3 and len(set(paths)) == 1 and not diag) else 0
    return drift, (paths[0] if paths else None), diag, rid


def verdict_ok(drift, paths_n, hex_n, match, guard):
    """The frozen exit predicate, factored so the aggregation can be tested.

    plans/round-66.md clause 1 (Amendment A1): exit 0 iff guard=1, drift=1,
    paths=3, hex=3. Every corner is load-bearing: a candidate that resolves
    the carrier but mutates two paths, or resolves three paths with two
    digests, is a failure (the plan's match/hex definitions).
    """
    return 0 if (guard == 1 and drift == 1 and paths_n == 3 and hex_n == 3
                 and match == 1) else 1


def match_of(paths_n, refused_n):
    """match = 1 iff all three mutated copies are refused by the digest
    binding. Factored because the verdict line must MEASURE this: a `match=1`
    literal in the printer is the constant-printer class (measured defect)."""
    return 1 if (paths_n == 3 and refused_n == 3) else 0


def verdict_of(drift, paths_n, hex_n, refused_n, guard):
    """The measured verdict tuple, computed in ONE place.

    Returns (match, exit_code). The verdict line prints this match and the
    process exits on this code, so neither can be a literal: a printer that
    hard-codes `match=1` is the constant-printer class this lane's QM criteria
    forbid (measured defect in the pre-hardening printer).
    """
    m = match_of(paths_n, refused_n)
    return m, verdict_ok(drift, paths_n, hex_n, m, guard)


def mutation_leg(tree, carrier, wrong_rel, dst):
    """One mutated copy: `wrong_rel`'s bytes written at the CARRIER path.

    Returns (hex_diff, refused, diag). `hex_diff` is 1 iff the body now at the
    carrier path hashes differently from the pin; `refused` is 1 iff the digest
    binding names a mismatch for that path. The slot is the RESOLVED carrier
    path, never a constant: on a candidate whose carrier is not the round-64
    S143 file the mutation must follow it (K-rule: a constant slot is a no-op).
    """
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(os.path.join(dst, os.path.dirname(carrier)), exist_ok=True)
    os.makedirs(os.path.join(dst, "corpus"), exist_ok=True)
    for rel in ("corpus/SOURCES.md", "corpus/source-fetches.tsv",
                "corpus/volatile-shape.py"):
        shutil.copyfile(os.path.join(tree, rel), os.path.join(dst, rel))
    src = os.path.join(tree, wrong_rel)
    slot = os.path.join(dst, carrier)
    if not os.path.isfile(src):
        return 0, 0, ["mutation-body-absent:" + wrong_rel]
    shutil.copyfile(src, slot)
    hex_diff = 1 if sha256(slot) != PIN else 0
    d, _p, diag, _r = drift_of(dst)
    refused = 1 if (d == 0 and any("digest-mismatch:" in x for x in diag)) else 0
    return hex_diff, refused, diag


def selftest(root, scratch):
    cases = []
    cases.append(("sources-readable", read(root, "corpus/SOURCES.md") is not None))
    rid, reg, d = resolve_anchor(root)
    cases.append(("anchor-rid", bool(rid) and re.match(r"^S[0-9]{3,}$", rid or "")))
    cases.append(("anchor-path-shape", bool(reg) and PATH_RE.fullmatch(reg or "") is not None))
    fet, d = resolve_fetch(root, rid or "S000")
    cases.append(("fetch-path-shape", bool(fet) and PATH_RE.fullmatch(fet or "") is not None))
    cases.append(("fetch-eq-anchor", fet == reg))
    vol, d = resolve_volatile(root)
    cases.append(("volatile-path-shape", bool(vol) and PATH_RE.fullmatch(vol or "") is not None))
    cases.append(("three-anchors-one-path", {reg, fet, vol} == {reg} and reg is not None))
    full = os.path.join(root, reg or "")
    cases.append(("anchor-file-exists", os.path.isfile(full)))
    if os.path.isfile(full):
        cases.append(("anchor-sha-is-pin", sha256(full) == PIN))
        cases.append(("anchor-bytes", os.path.getsize(full) == PIN_BYTES))
    # the counter can fail: a fabricated row whose anchor names a wrong file
    # QM74: fixtures are created in the counter SCRATCH, never inside the
    # measured tree (a `--selftest` run must leave the tree byte-identical).
    tmp = tempfile.mkdtemp(prefix="selftest-", dir=scratch)
    try:
        os.makedirs(os.path.join(tmp, "corpus"))
        os.makedirs(os.path.join(tmp, ".ufo/waves/round-64/capture"))
        body = os.path.join(tmp, WRONG_FILE)
        src = os.path.join(root, WRONG_FILE)
        shutil.copyfile(src, body) if os.path.isfile(src) else open(body, "wb").write(b"x")
        row = ("| S999 | x | spec | A | x | see `%s` (%s) | x | mined | 2026-11-08 | 180d | y |\n"
               % (WRONG_FILE, PIN))
        open(os.path.join(tmp, "corpus/SOURCES.md"), "w").write(row)
        open(os.path.join(tmp, "corpus/source-fetches.tsv"), "w").write("")
        open(os.path.join(tmp, "corpus/volatile-shape.py"), "w").write(
            'DEFAULT_CAPTURE = "%s"\n' % WRONG_FILE)
        d, _p, diag, _r = drift_of(tmp)
        cases.append(("wrong-file-reads-zero", d == 0))
        cases.append(("wrong-file-named", any("digest-mismatch:" in x for x in diag)))
        # a row with no path reads zero with a named diagnosis
        open(os.path.join(tmp, "corpus/SOURCES.md"), "w").write(
            "| S998 | x | spec | A | x | see §1 | x | mined | 2026-11-08 | 180d | y |\n")
        d2, _p2, diag2, _r2 = drift_of(tmp)
        cases.append(("pathless-row-reads-zero", d2 == 0))
        cases.append(("pathless-row-named", any("no-row-carries" in x for x in diag2)))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    # --- per-anchor digest refusal (kills a leg-local digest drop) ----------
    pin_body = os.path.join(root, reg or "none")
    if os.path.isfile(pin_body):
        fx = tempfile.mkdtemp(prefix="selftest-legs-", dir=scratch)
        try:
            cap = os.path.join(fx, ".ufo/waves/round-64/capture")
            os.makedirs(cap)
            os.makedirs(os.path.join(fx, "corpus"))
            okp = os.path.join(cap, "OK.body")
            badp = os.path.join(cap, "BAD.body")
            shutil.copyfile(pin_body, okp)
            with open(badp, "wb") as fh:
                fh.write(b"not the deposit")
            OK = ".ufo/waves/round-64/capture/OK.body"
            BAD = ".ufo/waves/round-64/capture/BAD.body"
            row = ("| S999 | x | spec | A | x | see `%s` (%s) | x | mined "
                   "| 2026-11-08 | 180d | y |\n")
            fetch = "%s\tmined\t%s\t%s\t%s\t200\tx\t2026-11-08\ty\t%s\t%d"
            fetch += "\t-\tq\tr\ts\t%s\n"

            def fixture(anchor_path, fetch_path, vol_path):
                open(os.path.join(fx, "corpus/SOURCES.md"), "w").write(
                    row % (anchor_path, PIN))
                open(os.path.join(fx, "corpus/source-fetches.tsv"), "w").write(
                    fetch % ("S999", "x", "x", "x", PIN, PIN_BYTES, fetch_path))
                open(os.path.join(fx, "corpus/volatile-shape.py"), "w").write(
                    'DEFAULT_CAPTURE = "%s"\n' % vol_path)
                return drift_of(fx)

            d, _p, diag, _r = fixture(OK, OK, OK)
            cases.append(("legs-all-ok-reads-one", d == 1 and not diag))
            # a PROSE anchor citation in col16 is refused even though it quotes
            # the carrier path (path equality, not a substring search)
            d, _p, diag, _r = fixture(OK, "see `%s` for the bytes" % OK, OK)
            cases.append(("fetch-prose-refused", d == 0
                          and any(x.startswith("fetches:col16-is-not-a-capture-path")
                                  for x in diag)))
            d, _p, diag, _r = fixture(BAD, OK, OK)
            cases.append(("registry-digest-refused", d == 0
                          and any(x.startswith("registry:digest-mismatch:") for x in diag)
                          and not any(x.startswith("fetches:digest-mismatch:") for x in diag)))
            d, _p, diag, _r = fixture(OK, BAD, OK)
            cases.append(("fetches-digest-refused", d == 0
                          and any(x.startswith("fetches:digest-mismatch:") for x in diag)
                          and not any(x.startswith("registry:digest-mismatch:") for x in diag)))
            d, _p, diag, _r = fixture(OK, OK, BAD)
            cases.append(("volatile-digest-refused", d == 0
                          and any(x.startswith("volatile:digest-mismatch:") for x in diag)))
            # the mutation leg writes at the RESOLVED carrier path (a constant
            # slot would leave the carrier slot untouched on an alternate
            # carrier, which is how a `slot = CANON` mutant survives).
            dst = os.path.join(fx, "altpath-mut")
            hd, refused, mdiag = mutation_leg(fx, BAD, OK, dst)
            slot_file = os.path.join(dst, BAD)
            cases.append(("mutation-leg-writes-carrier-slot",
                          os.path.isfile(slot_file)
                          and sha256(slot_file) == sha256(os.path.join(fx, OK))))
            cases.append(("mutation-leg-hex-zero-on-pin", hd == 0))
            # pin bytes at the carrier: the copy still resolves, so the leg
            # must report refused=0 (a `refused=1` constant is not a mutation)
            dst = os.path.join(fx, "altpath-mut3")
            hd, refused, mdiag = mutation_leg(fx, OK, OK, dst)
            cases.append(("mutation-leg-same-bytes-not-refused",
                          refused == 0 and hd == 0))
            # wrong bytes at the carrier path: refused, hex=1
            dst = os.path.join(fx, "altpath-mut2")
            hd, refused, mdiag = mutation_leg(fx, OK, BAD, dst)
            cases.append(("mutation-leg-refuses-wrong-bytes",
                          refused == 1 and hd == 1))
        finally:
            shutil.rmtree(fx, ignore_errors=True)
    # --- aggregation of the frozen exit predicate ---------------------------
    cases.append(("verdict-of-full", verdict_of(1, 3, 3, 3, 1) == (1, 0)))
    cases.append(("verdict-of-partial-refusal", verdict_of(1, 3, 3, 2, 1) == (0, 1)))
    cases.append(("verdict-of-hex2", verdict_of(1, 3, 2, 3, 1) == (1, 1)))
    cases.append(("verdict-of-paths2", verdict_of(1, 2, 3, 2, 1) == (0, 1)))
    cases.append(("verdict-of-base", verdict_of(0, 0, 0, 0, 1) == (0, 1)))
    cases.append(("verdict-of-guard0", verdict_of(1, 3, 3, 3, 0) == (1, 1)))
    cases.append(("match-of-full", match_of(3, 3) == 1))
    cases.append(("match-of-partial", match_of(3, 2) == 0))
    cases.append(("match-of-short", match_of(2, 2) == 0))
    cases.append(("match-of-empty", match_of(0, 0) == 0))
    cases.append(("wrong-body-population-3", len(WRONG_PATHS) == 3))
    cases.append(("wrong-bodies-are-distinct", len(set(WRONG_PATHS)) == 3))
    cases.append(("verdict-ok", verdict_ok(1, 3, 3, 1, 1) == 0))
    cases.append(("verdict-hex2-fails", verdict_ok(1, 3, 2, 1, 1) == 1))
    cases.append(("verdict-paths2-fails", verdict_ok(1, 2, 3, 1, 1) == 1))
    cases.append(("verdict-hex4-fails", verdict_ok(1, 3, 4, 1, 1) == 1))
    cases.append(("verdict-drift0-fails", verdict_ok(0, 3, 3, 1, 1) == 1))
    cases.append(("verdict-guard0-fails", verdict_ok(1, 3, 3, 1, 0) == 1))
    cases.append(("verdict-match0-fails", verdict_ok(1, 3, 3, 0, 1) == 1))
    cases.append(("verdict-match-literal-killed",
                  verdict_ok(1, 0, 0, 0, 1) == 1))
    bad = [n for n, ok in cases if not ok]
    print("c1-carrier: selftest cases=%d failed=%d%s"
          % (len(cases), len(bad), (" names=" + ",".join(bad)) if bad else ""))
    return 0 if not bad else 1


root_scratch = scratch_root()
if SELFTEST:
    raise SystemExit(selftest(TREE, root_scratch))

drift, path, diag, rid = drift_of(TREE)
print("c1-carrier: row=%s path=%s" % (rid or "none", path or "none"))
for d in diag:
    print("c1-carrier: diag %s" % d)

# paths / hex: three copies, each with one wrong-id body written at the carrier
# path. Only a tree that RESOLVES the carrier is mutated: on a tree that does not
# (BASE), there is no carrier slot to hold a wrong-id body and reporting 3/3/3
# there would be the M65-1 vacuity — a do-nothing control reaching the target.
paths_n = 0
hex_n = 0
refused_n = 0
if drift == 1 and path:
    for i, wrong in enumerate(WRONG_PATHS):
        cop = os.path.join(root_scratch, "mut-%d" % i)
        hex_diff, refused, mdiag = mutation_leg(TREE, path, wrong, cop)
        paths_n += 1
        hex_n += hex_diff
        refused_n += 1 if refused else 0
        if not refused:
            print("c1-carrier: FINDING mut-%d not-refused path=%s diag=%s"
                  % (i, wrong, ";".join(mdiag) or "none"))
        else:
            print("c1-carrier: mut-%d hex=%d refused=1 diag=%s"
                  % (i, hex_diff, ";".join(mdiag)))
# guard legs
ga = 0
if BASE_TREE:
    bd, _bp, bdiag, _br = drift_of(BASE_TREE)
    ga = 1 if bd == 0 else 0
    print("c1-carrier: base-tree drift=%d diag=%s" % (bd, ";".join(bdiag) or "none"))
gb = 1 if selftest(TREE, root_scratch) == 0 else 0
gc = 0
# guard (c): the gate is measured ON THE SAME CANDIDATE (plan Amendment A1),
# so it is read from TREE; LANE is only a fallback for a tree that does not
# carry the gate (a --tree fixture), and then it is measured with --capture
# pointing at the candidate's carrier path so the reading is still the
# candidate's bytes.
vol_gate = os.path.join(TREE, "corpus/volatile-shape.py")
vol_cmd = ["python3", "-I", "-B", vol_gate]
if not os.path.isfile(vol_gate):
    vol_gate = os.path.join(LANE, "corpus/volatile-shape.py")
    vol_cmd = ["python3", "-I", "-B", vol_gate]
    if drift == 1 and path:
        vol_cmd += ["--capture", os.path.join(TREE, path)]
if os.path.isfile(vol_gate):
    r = subprocess.run(vol_cmd, capture_output=True, text=True, timeout=300)
    gc = 1 if (r.returncode == 0 and "VOLATILE_SHAPE: match=1" in r.stdout) else 0
    print("c1-carrier: guard-c gate=%s rc=%d" % (vol_gate, r.returncode))
gd = 0
if path:
    cop = os.path.join(root_scratch, "guard-d")
    shutil.rmtree(cop, ignore_errors=True)
    os.makedirs(os.path.join(cop, os.path.dirname(path)), exist_ok=True)
    os.makedirs(os.path.join(cop, "corpus"))
    for rel in ("corpus/SOURCES.md", "corpus/source-fetches.tsv", "corpus/volatile-shape.py"):
        txt = open(os.path.join(TREE, rel), encoding="utf-8").read()
        open(os.path.join(cop, rel), "w", encoding="utf-8").write(txt.replace(path, WRONG_FILE))
    src = os.path.join(TREE, WRONG_FILE)
    if os.path.isfile(src):
        shutil.copyfile(src, os.path.join(cop, WRONG_FILE))
    d, _p, mdiag, _r = drift_of(cop)
    gd = 1 if (d == 0 and any("digest-mismatch:" in x for x in mdiag)) else 0
    print("c1-carrier: guard-d drift=%d diag=%s" % (d, ";".join(mdiag) or "none"))
else:
    print("c1-carrier: guard-d skipped (no carrier path at this tree)")

guard = 1 if (ga and gb and gc and gd) else 0
# the verdict is computed AFTER the guard: match and the exit code both come
# from verdict_of, so neither the printed line nor the exit is a literal.
match, exit_code = verdict_of(drift, paths_n, hex_n, refused_n, guard)
print("c1-carrier: mutations paths=%d hex=%d refused=%d match=%d"
      % (paths_n, hex_n, refused_n, match))
print("c1-carrier: guard a=%d b=%d c=%d d=%d" % (ga, gb, gc, gd))
print("C1_CARRIER: drift=%d paths=%d hex=%d match=%d guard=%d"
      % (drift, paths_n, hex_n, match, guard))
raise SystemExit(exit_code)
PY

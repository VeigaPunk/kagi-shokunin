#!/usr/bin/env bash
# plans/round-66-c3.sh — C3_SELFREF counter (kagi round 66, claim C3).
#
#   bash plans/round-66-c3.sh [--tree DIR] [--scratch DIR] [--selftest]
#
# Frozen predicate: plans/round-66.md §C3.
#
# resolved = 1 iff this counter prints
#   C3_SELFREF: resolved=1 checks=3 failures=0 guard=G and exits 0.
#
# checks = 3 — the carrier-path stands under .ufo/waves/round-64/capture/:
#   registry  registry rows whose ANCHOR cell cites a round-64 capture path
#   fetches   source-fetches.tsv col16 references to round-64 capture paths
#   volatile  corpus/volatile-shape.py DEFAULT_CAPTURE under round-64/capture
# At the candidate tree the C1 repair writes exactly one stand per surface
# (SOURCES anchor + fetch col16, both naming
# .ufo/waves/round-64/capture/S143.body) on top of the volatile stand that
# round 65 already landed (M65-4), so checks = 1 + 1 + 1 = 3.
#
# For each check the counter verifies that the cited path exists on the
# measured tree and that its sha256 equals the row's pin. The row's pin is
# the 64-hex literal the row's own ANCHOR cell carries (the S148 row pins
# sha256 3b8d4e15…cba40 in its anchor); a file whose bytes digest to a hex
# that the anchor does not carry is a digest-mismatch failure, named with
# the row id and path — never a silent pass.
#
# The designated-carrier failure (K1): the row that carries
# corpus/volatile-shape.py's PIN_SHA literal in its anchor cell must cite
# that digest's file. At BASE that row (currently S148) cites no carrier
# path at all, so the counter reads failures>=1. The rule is derived from
# the committed volatile-shape literal, never from a hard-coded row id.
#
# Population transparency (post-F9 reporting, not part of checks): the
# counter also prints the full anchor-citation population over all rounds
# (registry anchors citing .ufo/waves/*/capture/ paths vs fetches col16
# references), so a drift elsewhere is visible, not hidden. Rows outside
# round-64/capture are reported, not counted, and their digest state is not
# part of failures.
#
# GUARD = 1 iff all four legs read 1:
#   (a) the counter's --selftest exits 0 printing
#       C3_SELFREF_SELFTEST: PASS (cases=N);
#   (b) a tree holding the arXiv body (.ufo/waves/round-64/capture/
#       S148.body, sha fabc74c5…) at the designated carrier path reads
#       failures>=1 naming the digest mismatch (the counter can fail on a
#       real mismatch, not only on a missing path) — K2;
#   (c) rows=155 is asserted from a census over the measured tree (the
#       plan's own awk); a registry below 155 rows is SETUP (exit 2),
#       never a pass; a candidate that adds the C1 superseding row reads
#       rows=156, which is also >=155 and leaves this leg green (the
#       round-66 integration choice between append vs in-place is then
#       represented honestly in the receipt);
#   (d) `SOURCES_CENSUS: CLEAN` reads on the candidate (the lane census
#       verdict; at BASE it reads FAILED findings=4 — the four round-65
#       S155/S156 findings R66Reviewer F3 names — so a candidate that
#       does not repair them reads guard=0, never a pass).
#
# Output: `c3-selfref:` provenance lines, then exactly one verdict line
#   C3_SELFREF: resolved=R checks=K failures=F guard=G
# Exit 0 iff guard=1 and resolved=1; 1 otherwise; 2 SETUP.
#
# Scratch: ${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r66/R66ExecC3SelfRef/
# (or --scratch DIR); TMPDIR is honoured (exported for children); nothing is
# written inside the measured tree and the scratch root refuses to sit at /
# inside it (QM74). Measurement is slim (registry + fetches + volatile +
# round-64 captures only); full-tree copy cost is not claimed (bounds, plan
# §Bounds). Read-only otherwise.
set -u

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LANE=${SELF_DIR%/plans}
TREE=$LANE
SCRATCH=
SELFTEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) TREE=${2:-}; shift 2;;
    --scratch) SCRATCH=${2:-}; shift 2;;
    --selftest) SELFTEST=1; shift;;
    -h|--help) sed -n '2,/^set -u$/p' "${BASH_SOURCE[0]}" | sed '$d'; exit 0;;
    *) echo "C3_SELFREF: SETUP unknown-arg $1" >&2; exit 2;;
  esac
done
[ -d "$TREE" ] || { echo "C3_SELFREF: SETUP bad-tree $TREE" >&2; exit 2; }
[ -d "$LANE" ] || { echo "C3_SELFREF: SETUP bad-lane $LANE" >&2; exit 2; }
TREE=$(cd -- "$TREE" && pwd) || { echo "C3_SELFREF: SETUP bad-tree $TREE" >&2; exit 2; }
LANE=$(cd -- "$LANE" && pwd) || { echo "C3_SELFREF: SETUP bad-lane $LANE" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "C3_SELFREF: SETUP no-python3" >&2; exit 2; }

export TMPDIR=${TMPDIR:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r66/R66ExecC3SelfRef}

SELF_PATH=$(readlink -f "${BASH_SOURCE[0]}")
exec python3 -I -B - "$TREE" "$LANE" "$SELFTEST" "$SCRATCH" "$SELF_PATH" <<'PY'
import hashlib
import os
import re
import shutil
import subprocess
import sys

tree, lane, selftest, scratch_arg, self_path = (sys.argv[1], sys.argv[2],
                                                     sys.argv[3] == "1",
                                                     sys.argv[4], sys.argv[5])

SOURCES = "corpus/SOURCES.md"
FETCHES = "corpus/source-fetches.tsv"
VOLATILE = "corpus/volatile-shape.py"
CENSUS = "corpus/sources-census.sh"
CAPTURE_DIR = ".ufo/waves/round-64/capture"
ARXIV = CAPTURE_DIR + "/S148.body"  # the round-64 arXiv body (fabc74c5…)

# A capture path is a repo-relative .ufo/waves/.../capture/... reference.
# Trailing prose punctuation after the filename is not part of the path.
PATH_RE = re.compile(r"(\.ufo/waves/round-\d+/capture/[^\s`|]+)")
ROW_RE = re.compile(r"^\|\s*(S[0-9]{3,})\s*\|")
HEX_RE = re.compile(r"[0-9a-f]{64}")


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def scratch_root():
    base = scratch_arg or os.path.join(
        os.environ.get("HYAKU_SCRATCH") or "/fast/scratch/hyaku",
        "kagi-r66", "R66ExecC3SelfRef")
    tree_abs = os.path.realpath(tree)
    root_abs = os.path.realpath(base)
    if root_abs == tree_abs or root_abs.startswith(tree_abs + os.sep):
        print("C3_SELFREF: SETUP scratch-inside-tree " + base)
        raise SystemExit(2)
    if tree_abs == root_abs or root_abs.startswith(tree_abs + os.sep):
        print("C3_SELFREF: SETUP tree-inside-scratch " + base)
        raise SystemExit(2)
    try:
        os.makedirs(root_abs, exist_ok=True)
    except OSError as e:
        print("C3_SELFREF: SETUP no-scratch %s (%s)" % (base, type(e).__name__))
        raise SystemExit(2)
    # TMPDIR respected verbatim: children inherit it; python itself writes
    # only under this root.
    os.environ["TMPDIR"] = os.environ.get("TMPDIR") or root_abs
    return root_abs


def read_text(root, rel):
    try:
        with open(os.path.join(root, rel), encoding="utf-8", errors="replace") as f:
            return f.read()
    except OSError:
        return None


def scrape_path(tok):
    """Trim prose punctuation that follows a cited filename."""
    return tok.rstrip("`'\"),.;:!?")


def parse_sources(txt):
    """Registry rows.

    `cites` is the ANCHOR CELL only — the cell the frozen predicate binds.
    `line_cites` is every capture path on the row line, used ONLY for the
    population report (a path moved into the teaches cell is visible there
    but is not a carrier stand).
    """
    rows = []
    for line in txt.splitlines():
        m = ROW_RE.match(line)
        if not m:
            continue
        if line.strip().startswith("|---"):
            continue
        cells = line.split("|")
        anchor = cells[6] if len(cells) > 6 else ""
        hexes = set(HEX_RE.findall(anchor))
        rows.append({
            "id": m.group(1),
            "anchor": anchor,
            "hex": hexes,
            "cites": [scrape_path(p) for p in PATH_RE.findall(anchor)],
            "line_cites": [scrape_path(p) for p in PATH_RE.findall(line)],
        })
    return rows


def pin_carrying(rows, vpin):
    """Rows whose anchor cell carries the volatile PIN_SHA literal."""
    return [r for r in rows if vpin and vpin in r["anchor"]]


def round64_fetch_stands(fetch, pin_ids):
    """Fetch col16 stands that may count: round-64 capture AND a carrier id.

    A round-64 col16 citation from a row that does not carry the pin is a
    repoint of an unrelated row, never a carrier stand (S2)."""
    return [(f["id"], f["loc"]) for f in fetch
            if ".ufo/waves/round-64/capture/" in f["loc"]
            and f["id"] in pin_ids]


def carrier_fetch_gaps(fetch, pin_ids):
    """Carrier ids whose own fetch col16 does not name a round-64 capture."""
    by_id = {f["id"]: f for f in fetch}
    gaps = []
    for cid in sorted(pin_ids):
        frow = by_id.get(cid)
        loc = frow["loc"] if frow else ""
        if ".ufo/waves/round-64/capture/" not in loc:
            gaps.append((cid, loc or "-"))
    return gaps


def parse_fetches(txt):
    out = []
    for ln in txt.splitlines():
        if ln.startswith("#") or not ln.strip():
            continue
        cols = ln.rstrip("\n").split("\t")
        if len(cols) == 16:
            out.append({"id": cols[0], "sha": cols[9], "loc": cols[15]})
    return out


def parse_volatile(txt):
    """Return (DEFAULT_CAPTURE, PIN_SHA) from corpus/volatile-shape.py."""
    if txt is None:
        return None, None
    m = re.search(r'^DEFAULT_CAPTURE\s*=\s*"([^"]+)"', txt, re.M)
    p = re.search(r'^PIN_SHA\s*=\s*"([0-9a-f]{64})"', txt, re.M)
    return (m.group(1) if m else None, p.group(1) if p else None)


def verify_cited(root, path, row_hex):
    """Verify one cited path: exists + sha carries the row's anchor pin.

    row_hex=None means the fetches rule (file sha == fetch col10)."""
    fp = os.path.join(root, path)
    if not os.path.isfile(fp):
        return "missing-path:" + path
    got = sha256(fp)
    if row_hex is None:
        return None  # caller compares against fetch sha
    if got not in row_hex:
        return "digest-mismatch:%s sha=%s" % (path, got[:12])
    return None


def measure(root):
    """Scan the three surfaces of a tree. Returns a report dict."""
    rep = {"rows": None, "reg_cites_all": 0, "fetch_cites_all": 0,
           "checks": 0, "failures": [], "stands": [],
           "reg_r64": [], "fetch_r64": [], "volatile_r64": None,
           "designated": None, "pop_reg": {}, "pop_fetch": {},
           "volatile_path": None, "volatile_pin": None}
    src = read_text(root, SOURCES)
    fet = read_text(root, FETCHES)
    vol = read_text(root, VOLATILE)
    if src is None or fet is None:
        return None
    rows = parse_sources(src)
    fetch = parse_fetches(fet)
    rep["rows"] = len(rows)
    vpath, vpin = parse_volatile(vol)
    rep["volatile_path"], rep["volatile_pin"] = vpath, vpin
    fetch_by_id = {f["id"]: f for f in fetch}

    # --- registry surface ---
    # Population report: every capture path anywhere on the row line.
    for r in rows:
        rep["reg_cites_all"] += len(r["line_cites"])
        for p in r["line_cites"]:
            rd = p.split("/")[2] if p.startswith(".ufo/waves/") else "?"
            rep["pop_reg"][rd] = rep["pop_reg"].get(rd, 0) + 1
        # Counted stands: the ANCHOR cell only (S1: a path moved into the
        # teaches cell is not the anchor's citation).
        for p in r["cites"]:
            if not (p.startswith(".ufo/waves/")
                    and p.split("/")[2] == "round-64"):
                continue
            rep["reg_r64"].append((r["id"], p))
            rep["checks"] += 1
            rep["stands"].append("registry %s %s" % (r["id"], p))
            bad = verify_cited(root, p, r["hex"])
            if bad:
                rep["failures"].append("registry %s %s" % (r["id"], bad))
            else:
                frow = fetch_by_id.get(r["id"])
                if frow is not None and frow["sha"] not in r["hex"]:
                    rep["failures"].append(
                        "registry %s pin=%s-vs-fetch=%s"
                        % (r["id"], hexok(r["hex"]), frow["sha"][:12]))
    # --- fetches surface ---
    # Population report: every col16 capture reference by round.
    carriers = pin_carrying(rows, vpin)
    pin_ids = {r["id"] for r in carriers}
    for f in fetch:
        p = f["loc"]
        if p.startswith(".ufo/") and "/capture/" in p:
            rep["fetch_cites_all"] += 1
            rd = p.split("/")[2]
            rep["pop_fetch"][rd] = rep["pop_fetch"].get(rd, 0) + 1
    # Counted stands: round-64 capture AND a pin-carrying row id (S2: a
    # repoint of an unrelated row's col16 is not a carrier stand).
    for fid, p in round64_fetch_stands(fetch, pin_ids):
        rep["fetch_r64"].append((fid, p))
        rep["checks"] += 1
        rep["stands"].append("fetches %s %s" % (fid, p))
        fp = os.path.join(root, p)
        frow = fetch_by_id.get(fid)
        if not os.path.isfile(fp):
            rep["failures"].append("fetches %s missing-path:%s" % (fid, p))
        elif frow is None or sha256(fp) != frow["sha"]:
            rep["failures"].append(
                "fetches %s digest-mismatch:%s sha=%s"
                % (fid, p, sha256(fp)[:12]))
    # The designated (last) carrier row's own col16 must name the capture.
    designated_id = carriers[-1]["id"] if carriers else None
    for cid, loc in carrier_fetch_gaps(
            fetch, {designated_id} if designated_id else set()):
        rep["failures"].append(
            "fetches %s col16-not-a-round-64-citation:%s" % (cid, loc))
    # --- volatile surface ---
    if vpath and vpath.startswith(".ufo/waves/round-64/capture/"):
        rep["volatile_r64"] = vpath
        rep["checks"] += 1
        rep["stands"].append("volatile DEFAULT_CAPTURE %s" % vpath)
        bad = verify_cited(root, vpath, {vpin} if vpin else set())
        if bad:
            rep["failures"].append("volatile %s" % bad)
    # --- designated carrier: rows carrying volatile PIN_SHA (append-only) --
    # The C1 repair appends a new row superseding the S148 row verbatim:
    # the preserved S148 text still pins the digest and still cites no
    # path. Later rows win (the plan's amendment rule, appended never
    # rewritten): the designated stand passes iff ANY pin-carrying row
    # cites a path resolving to the pin; failure reasons are named from
    # the LAST pin-carrying row (the superseding row).
    if vpin:
        carriers = pin_carrying(rows, vpin)
        if carriers:
            last = carriers[-1]
            rep["designated"] = last["id"]
            good = False
            for r in carriers:
                for p in r["cites"]:
                    fp = os.path.join(root, p)
                    if os.path.isfile(fp) and sha256(fp) == vpin:
                        good = True
                        break
                if good:
                    break
            if not good:
                if not last["cites"]:
                    rep["failures"].append(
                        "designated %s cites-no-carrier-path pin=%s"
                        % (last["id"], vpin[:12]))
                else:
                    reasons = []
                    for p in last["cites"]:
                        if not (p.startswith(".ufo/waves/")
                                and p.split("/")[2] == "round-64"):
                            reasons.append("carrier-outside-round-64:%s" % p)
                        elif not os.path.isfile(os.path.join(root, p)):
                            reasons.append("path-missing:%s" % p)
                        else:
                            reasons.append(
                                "digest-mismatch-carrier:%s sha=%s"
                                % (p, sha256(os.path.join(root, p))[:12]))
                    rep["failures"].append(
                        "designated %s %s" % (last["id"], ";".join(reasons)))
    return rep


def hexok(hexset):
    return "anchor-pins=%d" % len(hexset)


def run_selftest(root):
    """The counter's own checks: parsers + the ability to fail (in-memory)."""
    cases = 0
    failed = []

    def case(name, cond):
        nonlocal cases
        cases += 1
        if not cond:
            failed.append(name)

    src = read_text(root, SOURCES)
    case("sources-present", src is not None)
    # Parser: real registry parses, anchor pin + citation both extracted.
    rows = parse_sources(src) if src else []
    case("rows-parsed", len(rows) >= 155)
    s148 = [r for r in rows if r["id"] == "S148"]
    case("s148-row", len(s148) == 1)
    if s148:
        case("s148-anchor-pin", any(
            len(h) == 64 for h in s148[0]["hex"]))
        case("s148-no-cite-base", len(s148[0]["cites"]) == 0)
    # Synthetic repair row: a registry line citing the carrier path parses.
    synth = ("| S999 | x | spec | A | s | a sha256 `" + "3b8d4e159a0b0595fc9ef9"
             "5f4fce87de5ab116c858cb7da9ed742113750cba40`"
             " `.ufo/waves/round-64/capture/S143.body` | t | mined "
             "| 2026-11-08 | 180d | c |\n")
    srows = parse_sources(synth)
    case("synth-row", len(srows) == 1)
    if srows:
        case("synth-cite", srows[0]["cites"] ==
             [".ufo/waves/round-64/capture/S143.body"])
        case("synth-hex", "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9e"
             "d742113750cba40" in srows[0]["hex"])
    # Punctuation scratch-off: a trailing comma after a path is not in it.
    case("punct-strip", scrape_path(
        ".ufo/waves/round-56/capture/rejections/S113-default-ua.body,") ==
        ".ufo/waves/round-56/capture/rejections/S113-default-ua.body")
    # Fetches parser + sha comparison on a real cited file.
    fet = read_text(root, FETCHES)
    case("fetches-present", fet is not None)
    fetch = parse_fetches(fet) if fet else []
    case("fetch-rows", len(fetch) >= 150)
    line = [f for f in fetch if f["id"] == "S148"]
    case("s148-fetch", len(line) == 1 and
         line[0]["sha"] == "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7"
         "da9ed742113750cba40")
    # Volatile parser reads the committed literals.
    vol = read_text(root, VOLATILE)
    vpath, vpin = parse_volatile(vol) if vol else (None, None)
    case("volatile-path", vpath ==
         ".ufo/waves/round-64/capture/S143.body")
    case("volatile-pin", vpin ==
         "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750"
         "cba40")
    # The file at the volatile stand digests to PIN_SHA (BASE ground truth).
    canon = os.path.join(root, CAPTURE_DIR, "S143.body")
    case("canon-digest", os.path.isfile(canon) and sha256(canon) ==
         "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750"
         "cba40")
    case("arxiv-disjoint", sha256(
        os.path.join(root, ARXIV)) !=
        "3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750"
        "cba40" if os.path.isfile(os.path.join(root, ARXIV)) else True)
    # S1: a capture path moved into the teaches cell is population only.
    moved = ("| S999 | x | spec | A | s | a sha256 `" + vpin + "` "
             "no path here | t `.ufo/waves/round-64/capture/S143.body` "
             "| mined | 2026-11-08 | 180d | c |\n")
    mrows = parse_sources(moved)
    case("s1-anchor-only", len(mrows) == 1
         and mrows[0]["cites"] == []
         and mrows[0]["line_cites"] ==
         [".ufo/waves/round-64/capture/S143.body"])
    # S2: fetch stands require a pin-carrying id.
    canon = ".ufo/waves/round-64/capture/S143.body"
    fake_bad = [{"id": "S999", "sha": vpin, "loc": "-"},
                {"id": "S143", "sha": "8522a79eba84604f4dbb37e0b46fa7a28c8"
                 "0eec69d00eaf5efecceef543c7208", "loc": canon}]
    case("s2-fetch-carrier-only",
         round64_fetch_stands(fake_bad, {"S148", "S999"}) == [])
    fake_ok = [{"id": "S999", "sha": vpin, "loc": canon}]
    case("s2-fetch-counted",
         round64_fetch_stands(fake_ok, {"S148", "S999"}) ==
         [("S999", canon)])
    case("s2-carrier-gap",
         carrier_fetch_gaps(fake_bad, {"S999"}) == [("S999", "-")])
    case("s2-carrier-ok", carrier_fetch_gaps(fake_ok, {"S999"}) == [])
    case("pin-carrying-s148",
         "S148" in [r["id"] for r in pin_carrying(rows, vpin)])
    # Ability-to-fail: a missing file and a wrong-bytes file both refuse.
    case("verify-missing", verify_cited(root, ".ufo/waves/round-64/capture/"
         "NOPE.body", set()) is not None)
    case("verify-mismatch", verify_cited(
        root, ARXIV,
        {"3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750"
         "cba40"}) is not None)
    case("verify-correct", verify_cited(
        root, CAPTURE_DIR + "/S143.body",
        {"3b8d4e159a0b0595fc9ef95f4fce87de5ab116c858cb7da9ed742113750"
         "cba40"}) is None)
    if failed:
        print("C3_SELFREF_SELFTEST: FAIL (cases=%d failed=%d names=%s)"
              % (cases, len(failed), ",".join(failed)))
        return 1
    print("C3_SELFREF_SELFTEST: PASS (cases=%d)" % cases)
    return 0


if selftest:
    raise SystemExit(run_selftest(tree))

root_scratch = scratch_root()
work = os.path.join(root_scratch, "c3-selfref")
shutil.rmtree(work, ignore_errors=True)
os.makedirs(work, exist_ok=True)

def slim_copy(dst, sources_text=None):
    """Copy only what measure() reads (round-64 captures)."""
    shutil.rmtree(dst, ignore_errors=True)
    os.makedirs(dst, exist_ok=True)
    for rel in (SOURCES, FETCHES, VOLATILE):
        src = os.path.join(tree, rel)
        if not os.path.isfile(src):
            print("C3_SELFREF: SETUP missing %s" % rel)
            raise SystemExit(2)
        out = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(out), exist_ok=True)
        if rel == SOURCES and sources_text is not None:
            open(out, "w", encoding="utf-8").write(sources_text)
        else:
            shutil.copyfile(src, out)
    cdir = os.path.join(dst, CAPTURE_DIR)
    os.makedirs(cdir, exist_ok=True)
    for name in ("S143.body", "S148.body", "S156.body", "S157.body"):
        src = os.path.join(tree, CAPTURE_DIR, name)
        out = os.path.join(cdir, name)
        if os.path.isfile(src):
            shutil.copyfile(src, out)
    return dst


# --- measure the candidate tree (slim copy, exact inputs) -------------------
base_copy = slim_copy(os.path.join(work, "cand"))
rep = measure(base_copy)
if rep is None:
    print("C3_SELFREF: SETUP missing registry/fetch inputs")
    raise SystemExit(2)
checks = rep["checks"]
failures = rep["failures"]
print("c3-selfref: rows=%d registry-cites=%d fetches-cites=%d "
      "pop-registry=%s pop-fetches=%s"
      % (rep["rows"], rep["reg_cites_all"], rep["fetch_cites_all"],
         ",".join("%s:%d" % (k, rep["pop_reg"][k])
                  for k in sorted(rep["pop_reg"])),
         ",".join("%s:%d" % (k, rep["pop_fetch"][k])
                  for k in sorted(rep["pop_fetch"]))))
print("c3-selfref: r64-stands registry=%d fetches=%d volatile=%s "
      "designated=%s"
      % (len(rep["reg_r64"]), len(rep["fetch_r64"]),
         rep["volatile_r64"] or "-", rep["designated"] or "-"))
for st in rep["stands"]:
    print("c3-selfref: stand " + st)
for f in failures:
    print("c3-selfref: failure " + f)
print("c3-selfref: checks=%d failures=%d" % (checks, len(failures)))

# --- guard (a): --selftest exits 0 ------------------------------------------
st = 0
try:
    r = subprocess.run(["bash", self_path,
                        "--tree", tree, "--selftest"], capture_output=True,
                       text=True, timeout=300, cwd=lane, env=dict(os.environ))
    st = 1 if ("C3_SELFREF_SELFTEST: PASS" in r.stdout and r.returncode == 0) else 0
    print("c3-selfref: selftest=%d" % st)
except Exception as e:
    print("c3-selfref: selftest=0 spawn-failure %s" % e)

# --- guard (b): arXiv body at the carrier path reads failures>=1 ------------
leg_b = 0
try:
    # Tree holding the arXiv body at the designated carrier path: copy the
    # candidate, overwrite the file the repair names with S148.body bytes.
    carriers = [p for _sid, p in rep["reg_r64"]] or [rep["volatile_r64"] or ""]
    dst = slim_copy(os.path.join(work, "k2"))
    arxiv_src = os.path.join(tree, ARXIV)
    if os.path.isfile(arxiv_src):
        for p in carriers:
            if p:
                shutil.copyfile(arxiv_src, os.path.join(dst, p))
        rep2 = measure(dst)
        if rep2 is not None:
            named = [f for f in rep2["failures"] if "digest-mismatch" in f]
            leg_b = 1 if (len(rep2["failures"]) >= 1 and named) else 0
            print("c3-selfref: k2-arxiv failures=%d named=%s"
                  % (len(rep2["failures"]),
                     "digest-mismatch" if named else "FAIL"))
except Exception as e:
    print("c3-selfref: k2-arxiv=0 spawn-failure %s" % e)

# --- guard (c): population rows=155 asserted from the census ---------------
# The plan's own awk over SOURCES.md (11-column registry rows).
rows_awked = None
try:
    awk_sum = subprocess.run(
        ["awk", "-F|", "/^\\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\\|/ "
         "{n++} END{print n+0}", os.path.join(base_copy, SOURCES)],
        capture_output=True, text=True, timeout=120)
    rows_awked = int(awk_sum.stdout.strip())
except Exception:
    rows_awked = None
# Shrinkage below 155 is SETUP never a pass. A 156-row candidate (C1's
# superseding row appended) exceeds 155 without shrinking.
if rows_awked is None:
    print("C3_SELFREF: SETUP census-awk-failed")
    raise SystemExit(2)
if rows_awked < 155:
    print("C3_SELFREF: SETUP rows=%d below-frozen-155" % rows_awked,
          file=sys.stderr)
    raise SystemExit(2)
leg_c = 1
print("c3-selfref: rows=%d (population bound >=155)" % rows_awked)

# --- guard (d): SOURCES_CENSUS: CLEAN on the candidate (frozen) -----------
# The frozen guard reads `SOURCES_CENSUS: CLEAN` and the census exits 0.
# At BASE the lane census reads FAILED (the four round-65 findings:
# SC_FETCH S155/S156, SC_BODY_CITE S148/S156 — R66Reviewer F3); those are
# L1 round-end repairs outside this seat's scope, so a candidate without
# them reads guard=0, never a pass. A SETUP line (no verdict) also fails.
leg_d = 0
cen_path = os.path.join(tree, CENSUS)
if os.path.isfile(cen_path):
    try:
        r = subprocess.run(["bash", cen_path], capture_output=True,
                           text=True, timeout=600, cwd=tree,
                           env=dict(os.environ))
        hits = [ln for ln in r.stdout.splitlines()
                if ln.startswith("SOURCES_CENSUS:")]
        cen_line = hits[-1] if hits else ""
        m = re.search(r"rows=(\d+)", cen_line)
        cen_rows = int(m.group(1)) if m else 0
        clean = cen_line.startswith("SOURCES_CENSUS: CLEAN")
        print("c3-selfref: census=%s" % (cen_line or "no-verdict"))
        leg_d = 1 if (clean and cen_rows >= 155) else 0
    except Exception as e:
        print("c3-selfref: census=0 spawn-failure %s" % e)
else:
    print("c3-selfref: census=0 script-not-found")

guard = 1 if (st and leg_b and leg_c and leg_d) else 0
resolved = 1 if (checks == 3 and not failures) else 0
print("c3-selfref: guard a=%d b=%d c=%d d=%d" % (st, leg_b, leg_c, leg_d))
print("C3_SELFREF: resolved=%d checks=%d failures=%d guard=%d"
      % (resolved, checks, len(failures), guard))
raise SystemExit(0 if (resolved and guard) else 1)
PY

#!/usr/bin/env bash
# plans/round-54-c1.sh -- round 54 C1 counter (freshness: the op-ref entry's
# `recheck: on-release of op` gets a live release clock, and the release that clock
# observes is measured).
#
# Frozen predicate (the same sentence appears in plans/round-54.md section C1):
#   C1_OP_CLOCK: value = WATCHED + MEASURED when GUARD = 1, else 0; target 2 (BASE 0).
#   Constants: OPFEED https://releases.1password.com/developers/cli/index.xml;
#     ANCHOR 2.41.1 (the identity S072 records at BASE); V 2.42.0 (the newest stable
#     item of the S112 capture taken 2026-11-07, sha256 CAPSHA below);
#     CAPTURE .ufo/waves/round-54/capture/S112.body; RECEIPT
#     .ufo/waves/round-54/final/observe-r54.json; OPRCPT
#     .ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt.
#   WATCHED = 1 iff all of:
#     (a) the measured corpus/SOURCES.md has exactly one S072 row outside code fences
#         (11 cells); its URL equals the BASE row's URL; status `mined`; recheck
#         `on-release`;
#     (b) corpus/release-clocks.tsv has exactly one S072 row, 9 TAB fields, clock
#         `feed`, feed_url = OPFEED, anchored ANCHOR, observed V, verdict `fired`;
#     (c) its feed_source_id names exactly one registry row outside fences whose URL
#         is OPFEED, kind docs|code|dataset, status `mined`, recheck not `on-release`;
#     (d) RECEIPT: the measured gate names exactly RECEIPT as its default receipt
#         (receipt_path line) and its DEFAULT_RECEIPT_SHA256 equals the sha256 of
#         RECEIPT, which is a regular file, not a symlink, on a path with no symlinked
#         component; RECEIPT holds exactly one S072 observation: http_status 200,
#         url OPFEED, parsed_version V, verdict `fired`, no error, sha256 = CAPSHA
#         (receipt linked to the committed body), observed_at
#         2026-11-07T00:00:00Z <= t <= ASOF (the measured revision's committer time;
#         --tree takes C1_ASOF and is never the frozen reading);
#     (e) PARSE: CAPTURE is a regular non-symlink file with sha256 CAPSHA, and the
#         measured gate's own parse_latest_version(body, FEED_TITLE_PREFIXES[OPFEED])
#         returns V;
#     (f) GATE: `python3 corpus/release-clock.py` in the measured tree exits 0 with a
#         last line starting `RELEASE_CLOCK: CLEAN`.
#   MEASURED = 1 iff OPRCPT is a regular non-symlink file and holds exactly one line
#     each of `op_version=V`, `gpg_validsig=3FEF9748469ADBE15DA7CA80AC2D62742012EA22`,
#     `probe_sha256=<sha256 of the BASE corpus/op-ref-probe.sh>`,
#     `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)` and `exit=0`; exactly the six
#     lines `DOTENV_BYTES_CASE id=<id> status=PASS` for escaped-lf, trailing-lf,
#     newline-only, single-literal, double-multiline, single-multiline; no line
#     containing `status=FAIL`, `DRIFT` or `SETUP`; and the measured
#     corpus/knowledge/op-ref-consumption.md section `## 11.` (to the next `## `)
#     contains a `### 11.2` heading and names op `2.42.0` (backticked) at least once.
#   GUARD = 1 iff the measured corpus/op-ref-probe.sh equals the BASE file and
#     `python3 corpus/release-clock.py --selftest` in the measured tree exits 0 with a
#     last line starting `RELEASE_CLOCK_SELFTEST: PASS`.
# Fail closed: unreadable BASE, bad revision, missing tree, unusable scratch or a
# missing python3 is SETUP (exit 2, no value). A missing or empty file, a gate that
# prints nothing or a python error reads the conjunct as 0 with a reason, never 1.
# Named ceilings: the counter checks committed bytes. A self-consistent forged
# observation receipt whose digest is written into the gate, whose S072 record copies
# the capture digest, scores WATCHED; a hand-written OPRCPT scores MEASURED. The live
# leg (an independent re-fetch of OPFEED, and an independent download, signature check
# and probe run of op 2.42.0) is the non-author check that catches both.
# Input: a revision, or --tree DIR with C1_ASOF=<epoch>. Output: one line
#   C1_OP_CLOCK: value=V watched=W measured=M guard=G (bad=<reasons>; gate-line=...)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1a0f43a9220bb0e995462c2aef745ac0124c3317
setup() { echo "C1_OP_CLOCK: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r54/c1.$$
mkdir -p -- "$SCR/t" "$SCR/b" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
T=$SCR/t
if [ "${1:-}" = --tree ]; then
  [ -n "${2:-}" ] && [ -d "$2" ] || setup tree
  [[ ${C1_ASOF:-} =~ ^[0-9]+$ ]] || setup asof
  ASOF=$C1_ASOF
  cp -a "$2"/. "$T"/ || setup tree-copy
else
  REV=${1:-}
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  ASOF=$(git -C "$REPO" show -s --format=%ct "$REV") || setup committer-time
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
git -C "$REPO" show "$BASE:corpus/SOURCES.md" > "$SCR/b/SOURCES.md" 2>/dev/null || setup base-sources
git -C "$REPO" show "$BASE:corpus/op-ref-probe.sh" > "$SCR/b/op-ref-probe.sh" 2>/dev/null || setup base-probe
[ -s "$SCR/b/SOURCES.md" ] && [ -s "$SCR/b/op-ref-probe.sh" ] || setup base-empty

# GUARD
guard=0
if [ -f "$T/corpus/op-ref-probe.sh" ] && cmp -s "$SCR/b/op-ref-probe.sh" "$T/corpus/op-ref-probe.sh"; then
  sout=$(cd "$T" && TMPDIR="$SCR" timeout 600 python3 corpus/release-clock.py --selftest 2>/dev/null); src=$?
  slast=$(printf '%s\n' "$sout" | sed '/^[[:space:]]*$/d' | tail -n 1)
  [ "$src" -eq 0 ] && [[ $slast == "RELEASE_CLOCK_SELFTEST: PASS"* ]] && guard=1
fi
# GATE
gout=$(cd "$T" && TMPDIR="$SCR" timeout 600 python3 corpus/release-clock.py 2>/dev/null); grc=$?
glast=$(printf '%s\n' "$gout" | sed '/^[[:space:]]*$/d' | tail -n 1)
gate=0
[ "$grc" -eq 0 ] && [[ $glast == "RELEASE_CLOCK: CLEAN"* ]] && gate=1

res=$(python3 - "$T" "$SCR/b" "$ASOF" "$gate" <<'PY' 2>/dev/null
import hashlib, importlib.util, json, os, re, sys, datetime as dt
from pathlib import Path
t, b, asof, gate = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
OPFEED = "https://releases.1password.com/developers/cli/index.xml"
ANCHOR, V = "2.41.1", "2.42.0"
CAPSHA = "2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2"
CAPTURE = ".ufo/waves/round-54/capture/S112.body"
RECEIPT = ".ufo/waves/round-54/final/observe-r54.json"
OPRCPT = ".ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt"
KEY = "3FEF9748469ADBE15DA7CA80AC2D62742012EA22"
FLOOR = int(dt.datetime(2026, 11, 7, tzinfo=dt.timezone.utc).timestamp())
bad = []

def plain_file(rel):
    p = t
    for part in Path(rel).parts:
        p = p / part
        if p.is_symlink():
            return None
    return p if p.is_file() else None

def rows(path, sid):
    out, fence = [], False
    for line in open(path, encoding="utf-8"):
        if re.match(r"^ {0,3}(```|~~~)", line):
            fence = not fence
            continue
        if fence or not re.match(r"^ {0,3}\|\s*%s\s*\|" % re.escape(sid), line):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 11:
            out.append(None); continue
        m = re.search(r"https?://[^\s|]+", cells[1])
        out.append({"url": m.group(0) if m else "-", "kind": cells[2],
                    "status": cells[7], "recheck": cells[9]})
    return out

def by_url(path, url):
    out, fence = [], False
    for line in open(path, encoding="utf-8"):
        if re.match(r"^ {0,3}(```|~~~)", line):
            fence = not fence
            continue
        m0 = re.match(r"^ {0,3}\|\s*(S[0-9]{3})\s*\|", line)
        if fence or not m0:
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) != 11:
            continue
        m = re.search(r"https?://[^\s|]+", cells[1])
        if m and m.group(0) == url:
            out.append(m0.group(1))
    return out

def watched():
    reg = plain_file("corpus/SOURCES.md")
    if reg is None:
        return "no-registry"
    r = rows(reg, "S072"); br = rows(b / "SOURCES.md", "S072")
    if len(br) != 1 or br[0] is None:
        return "base-row"
    if len(r) != 1 or r[0] is None:
        return "s072-rows=%d" % len(r)
    r = r[0]
    if r["url"] != br[0]["url"]: return "s072-url"
    if r["status"] != "mined": return "s072-status"
    if r["recheck"] != "on-release": return "s072-recheck=" + r["recheck"]
    tbl = plain_file("corpus/release-clocks.tsv")
    if tbl is None: return "no-clock-table"
    cl = [l.rstrip("\n").split("\t") for l in open(tbl, encoding="utf-8")
          if l.split("\t", 1)[0] == "S072"]
    if len(cl) != 1: return "clock-rows=%d" % len(cl)
    f = cl[0]
    if len(f) != 9: return "clock-fields"
    _, clock, fsid, furl, anch, obsv, _at, verdict, _n = f
    if clock != "feed": return "clock=" + clock
    if furl != OPFEED: return "clock-feed-url"
    if anch != ANCHOR: return "clock-anchor"
    if obsv != V: return "clock-observed=" + obsv
    if verdict != "fired": return "clock-verdict=" + verdict
    if not re.fullmatch(r"S[0-9]{3}", fsid): return "feed-id"
    fr = rows(reg, fsid)
    if len(fr) != 1 or fr[0] is None: return "feed-rows"
    fr = fr[0]
    if fr["url"] != OPFEED: return "feed-row-url"
    if by_url(reg, OPFEED) != [fsid]: return "feed-url-rows"
    if fr["kind"].lower() not in ("docs", "code", "dataset"): return "feed-kind"
    if fr["status"] != "mined": return "feed-status"
    if fr["recheck"] == "on-release": return "feed-recheck"
    gp = plain_file("corpus/release-clock.py")
    if gp is None: return "no-gate"
    g = gp.read_text(encoding="utf-8")
    m1 = re.findall(r'^DEFAULT_RECEIPT_SHA256 = "([0-9a-f]{64})"$', g, re.M)
    m2 = re.findall(r'^        return root / "\.ufo" / "waves" / "round-54" / "final" / "observe-r54\.json"$', g, re.M)
    if len(m1) != 1 or len(m2) != 1: return "receipt-unnamed"
    rp = plain_file(RECEIPT)
    if rp is None: return "receipt-missing-or-symlink"
    raw = rp.read_bytes()
    pass  # M07
    try:
        obs = [o for o in json.loads(raw)["observations"]
               if isinstance(o, dict) and o.get("id") == "S072"]
    except Exception:
        return "receipt-json"
    if len(obs) != 1: return "receipt-records=%d" % len(obs)
    o = obs[0]
    if "error" in o: return "receipt-error"
    if o.get("http_status") != 200: return "receipt-status"
    if o.get("url") != OPFEED: return "receipt-url"
    if o.get("parsed_version") != V: return "receipt-version"
    if o.get("verdict") != "fired": return "receipt-verdict"
    if o.get("sha256") != CAPSHA: return "receipt-body-link"
    at = o.get("observed_at")
    if not isinstance(at, str) or not re.fullmatch(r"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ", at):
        return "receipt-time-shape"
    e = int(dt.datetime.strptime(at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=dt.timezone.utc).timestamp())
    if not FLOOR <= e <= asof: return "receipt-time-window"
    cp = plain_file(CAPTURE)
    if cp is None: return "capture-missing-or-symlink"
    body = cp.read_bytes()
    if hashlib.sha256(body).hexdigest() != CAPSHA: return "capture-sha"
    try:
        spec = importlib.util.spec_from_file_location("kagi_r54_gate", gp)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        got = mod.parse_latest_version(body, mod.FEED_TITLE_PREFIXES[OPFEED])
    except Exception as exc:
        return "parse-" + exc.__class__.__name__
    if got != V: return "parse=" + str(got)
    if gate != "1": return "gate"
    return "OK"

def measured():
    rp = plain_file(OPRCPT)
    if rp is None: return "oprcpt-missing-or-symlink"
    lines = rp.read_text(encoding="utf-8", errors="replace").split("\n")
    probe_sha = hashlib.sha256((b / "op-ref-probe.sh").read_bytes()).hexdigest()
    for want in ("op_version=" + V, "gpg_validsig=" + KEY, "probe_sha256=" + probe_sha,
                 "OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)", "exit=0"):
        if lines.count(want) != 1:
            return "oprcpt-line:" + want.split("=")[0].split(":")[0]
    cases = [l for l in lines if l.startswith("DOTENV_BYTES_CASE ")]
    want = ["DOTENV_BYTES_CASE id=%s status=PASS" % i for i in (
        "escaped-lf", "trailing-lf", "newline-only", "single-literal",
        "double-multiline", "single-multiline")]
    if sorted(cases) != sorted(want): return "oprcpt-cases"
    if any(("status=FAIL" in l) or ("DRIFT" in l) or ("SETUP" in l) for l in lines):
        return "oprcpt-failure-line"
    ep = plain_file("corpus/knowledge/op-ref-consumption.md")
    if ep is None: return "no-entry"
    sec, on = [], False
    for l in ep.read_text(encoding="utf-8").split("\n"):
        if l.startswith("## "):
            on = l.startswith("## 11.")
            continue
        if on:
            sec.append(l)
    s = "\n".join(sec)
    if not re.search(r"^### 11\.2\b", s, re.M): return "entry-no-11.2"
    if "op `%s`" % V not in s: return "entry-no-version"
    return "OK"

try:
    w = watched()
except Exception as exc:
    w = "error-" + exc.__class__.__name__
try:
    m = measured()
except Exception as exc:
    m = "error-" + exc.__class__.__name__
print("%d %d %s %s" % (w == "OK", m == "OK", w, m))
PY
)
read -r watched measured wreason mreason <<< "${res:-0 0 python-error python-error}"
[[ $watched =~ ^[01]$ && $measured =~ ^[01]$ ]] || { watched=0; measured=0; }
value=0
[ "$guard" -eq 1 ] && value=$((watched + measured))
echo "C1_OP_CLOCK: value=$value watched=$watched measured=$measured guard=$guard (bad=watched:$wreason measured:$mreason; gate-line=$glast)"

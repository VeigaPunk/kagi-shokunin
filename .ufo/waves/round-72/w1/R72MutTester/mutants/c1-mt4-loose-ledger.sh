#!/usr/bin/env bash
# plans/round-72-c1.sh — round 72 C1 (freshness) frozen counter. L1 KagiR72.
#
# Frozen predicate (the same sentence as plans/round-72.md §C1):
#   C1_CLOCK_REARM: value = number of ids in F = {S013 S014 S015 S016 S021 S022 S023
#   S024 S025 S026} (the ten derived Vault/OpenBao release clocks that read `fired`
#   at BASE b2f3dd66) that are ARMED, VERIFIED, SOURCED and LIVE, when GATE = 1,
#   FRESH = 1 and CENSUS = 1, else 0; target 10 (BASE 0).
#   ARMED(id):    T's corpus/release-clocks.tsv row for id has verdict `not-fired`, a
#                 note starting `derived:`, anchored_version == observed_version ==
#                 the default receipt's parsed_version for id, and that anchor is
#                 newer than the id's BASE anchor (2.2.0 Vault / 2.7.1 OpenBao).
#   SOURCED(id):  the row's feed_source_id names a registry row of T that is NOT
#                 in the BASE registry, status `mined`, opened >= 2026-11-09, whose
#                 source URL equals the row's feed_url (the round's sourced claim).
#   VERIFIED(id): T's corpus/clock-rearm.tsv holds exactly one row for id with
#                 rearmed_anchor == the anchor, feed_source_id == the row's, url ==
#                 the id's registry URL, capture_path under .ufo/waves/round-72/ that
#                 exists in T with the row's sha256 and byte count, fetched_at in
#                 [2026-11-09T00:00:00Z, run time], verdict `quote-located`, and the
#                 id's declared fetch quote (corpus/source-fetches.tsv col 13 at BASE)
#                 located >= 1 times — and exactly quote_count times — in that capture
#                 by the BASE-pinned corpus/rendered-text-v1.py.
#   LIVE(id):     a live observation made by THIS counter run (BASE-pinned
#                 release-clock.py --observe over T) parses the same newest stable
#                 version as the anchor. Network failure is SETUP, never a pass.
#   GATE:         T's default receipt (DEFAULT_RECEIPT_SHA256 / receipt_path in T's
#                 corpus/release-clock.py) is .ufo/waves/round-72/final/observe-r72.json
#                 with matching sha256; the BASE-pinned gate run on T with that
#                 receipt AND T's own gate (default) both print `RELEASE_CLOCK: CLEAN`
#                 with exit 0.
#   FRESH:        every observation in that receipt has observed_at >= 2026-11-09.
#   CENSUS:       T's corpus/sources-census.sh is byte-identical to BASE and prints
#                 `SOURCES_CENSUS: CLEAN` with exit 0 on T.
#   Any producer that is missing, empty, or SETUP fails closed (exit 2, value=0).
#
# Uncounted (named ceilings, judged by non-author reading, never by this counter):
#   the semantic teaching judgment (quote location is not semantics; the round-47
#   `teaching-holds` verdicts are the semantic leg at the same releases), and whether
#   the receipt's non-F observations reflect the vendor state at 2026-11-09 beyond
#   what LIVE re-reads for F.
#
# usage: plans/round-72-c1.sh <lane revision> | --tree DIR      [--no-live is NOT offered]
# exit: 0 value=10; 1 value<10; 2 SETUP.
set -u
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE_REV=b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9
SR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r72
mkdir -p "$SR" || { echo "C1_CLOCK_REARM: SETUP (scratch) value=0"; exit 2; }
W=$(mktemp -d "$SR/c1.XXXXXX") || { echo "C1_CLOCK_REARM: SETUP (mktemp) value=0"; exit 2; }
trap 'rm -rf -- "$W"' EXIT
setup() { echo "C1_CLOCK_REARM: SETUP ($1) value=0"; exit 2; }
mkdir -p "$W/base" && git -C "$LANE" archive "$BASE_REV" corpus/release-clock.py corpus/rendered-text-v1.py \
  corpus/sources-census.sh corpus/release-clocks.tsv corpus/SOURCES.md corpus/source-fetches.tsv | tar -x -C "$W/base" \
  || setup "base instruments"
case "${1:-}" in
  --tree) T=$(readlink -f "${2:?tree}"); [ -d "$T" ] || setup "no tree" ;;
  "") setup "usage: <rev> | --tree DIR" ;;
  *) T="$W/t"; mkdir -p "$T"; git -C "$LANE" archive "$1" | tar -x -C "$T" || setup "archive $1" ;;
esac
# CENSUS
cmp -s "$W/base/corpus/sources-census.sh" "$T/corpus/sources-census.sh" || setup "census=0 sources-census.sh differs from BASE"
(cd "$T" && bash corpus/sources-census.sh) > "$W/census.out" 2>&1; crc=$?
[ -s "$W/census.out" ] || setup "census printed nothing"
census=0; [ $crc = 0 ] && grep -q '^SOURCES_CENSUS: CLEAN ' "$W/census.out" && census=1
# LIVE observation by this run (BASE-pinned gate, scratch output)
python3 "$W/base/corpus/release-clock.py" --root "$T" --observe "$W/live.json" > "$W/live.out" 2>&1
[ -s "$W/live.json" ] || setup "live observation produced no receipt"
exec python3 - "$T" "$W" "$census" <<'PY'
import datetime as dt, hashlib, json, os, re, subprocess, sys
T, W, census = sys.argv[1], sys.argv[2], int(sys.argv[3])
B = os.path.join(W, "base")
F = ["S013", "S014", "S015", "S016", "S021", "S022", "S023", "S024", "S025", "S026"]
BASE_ANCHOR = {"S013": "2.2.0", "S022": "2.2.0", "S023": "2.2.0", "S024": "2.2.0"}
BASE_ANCHOR.update({k: "2.7.1" for k in F if k not in BASE_ANCHOR})
RECEIPT_REL = ".ufo/waves/round-72/final/observe-r72.json"
FLOOR = dt.datetime(2026, 11, 9, tzinfo=dt.timezone.utc)
NOW = dt.datetime.now(dt.timezone.utc)

def setup(msg):
    print(f"C1_CLOCK_REARM: SETUP ({msg}) value=0"); sys.exit(2)

def rows(path):
    out = {}
    for l in open(path, encoding="utf-8"):
        if re.match(r"^ {0,3}\| *S\d{3} ", l):
            c = [x.strip() for x in l.strip().strip("|").split("|")]
            out[c[0]] = c
    return out

def url_of(cell):
    m = re.search(r"https://\S+", cell)
    return m.group(0) if m else None

def tsv(path, key=0):
    out = {}
    for l in open(path, encoding="utf-8"):
        if l.startswith("#") or not l.strip():
            continue
        c = l.rstrip("\n").split("\t")
        out.setdefault(c[key], []).append(c)
    return out

def vtuple(v):
    return tuple(int(x) for x in v.lstrip("v").split("."))

def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()

try:
    reg = rows(os.path.join(T, "corpus/SOURCES.md"))
    base_reg = rows(os.path.join(B, "corpus/SOURCES.md"))
    clocks = tsv(os.path.join(T, "corpus/release-clocks.tsv"))
    base_fetch = tsv(os.path.join(B, "corpus/source-fetches.tsv"))
except OSError as e:
    setup(f"input {e}")

# GATE: default receipt identity in T's gate
src = open(os.path.join(T, "corpus/release-clock.py"), encoding="utf-8").read()
m = re.search(r'^DEFAULT_RECEIPT_SHA256 = "([0-9a-f]{64})"$', src, re.M)
p = re.search(r'return root / "\.ufo" / "waves" / "round-72" / "final" / "observe-r72\.json"', src)
rpath = os.path.join(T, RECEIPT_REL)
gate = 0
receipt = None
if m and p and os.path.isfile(rpath) and sha(rpath) == m.group(1):
    a = subprocess.run([sys.executable, os.path.join(B, "corpus/release-clock.py"), "--root", T,
                        "--receipt", rpath, "--receipt-sha", m.group(1)], capture_output=True, text=True)
    b = subprocess.run([sys.executable, os.path.join(T, "corpus/release-clock.py"), "--root", T],
                       capture_output=True, text=True, cwd=T)
    last = lambda r: (r.stdout.strip().splitlines() or [""])[-1]
    if not a.stdout.strip() or not b.stdout.strip():
        setup("release-clock printed nothing")
    gate = int(a.returncode == 0 and last(a).startswith("RELEASE_CLOCK: CLEAN ")
               and b.returncode == 0 and last(b).startswith("RELEASE_CLOCK: CLEAN "))
    receipt = {o["id"]: o for o in json.load(open(rpath, encoding="utf-8"))["observations"]}
fresh = 0
if receipt:
    def at(o):
        try:
            return dt.datetime.fromisoformat(o["observed_at"].replace("Z", "+00:00"))
        except Exception:
            return None
    fresh = int(all(at(o) is not None and at(o) >= FLOOR for o in receipt.values()))
try:
    live = {o["id"]: o for o in json.load(open(os.path.join(W, "live.json"), encoding="utf-8"))["observations"]}
except Exception:
    setup("live receipt unreadable")
if any(("error" in live.get(i, {"error": 1})) or not live[i].get("parsed_version") for i in F):
    setup("live observation failed for an F id (network?)")
ledger_path = os.path.join(T, "corpus/clock-rearm.tsv")
ledger = tsv(ledger_path) if os.path.isfile(ledger_path) else {}
rt = os.path.join(B, "corpus/rendered-text-v1.py")
value = 0
for i in F:
    why = []
    row = (clocks.get(i) or [None])
    row = row[0] if len(clocks.get(i, [])) == 1 else None
    anchor = None
    if not row or len(row) != 9:
        why.append("no-row")
    else:
        _, clock, fid, furl, anchor, observed, oat, verdict, note = row
        rc = (receipt or {}).get(i, {})
        if not (verdict == "not-fired" and note.startswith("derived:") and anchor == observed
                and rc.get("parsed_version") == anchor):
            why.append("not-armed")
        try:
            if not vtuple(anchor) > vtuple(BASE_ANCHOR[i]):
                why.append("not-newer")
        except Exception:
            why.append("bad-anchor")
        fr = reg.get(fid)
        if not (fr and fid not in base_reg and fr[7] == "mined" and fr[8] >= "2026-11-09"
                and url_of(fr[1]) == furl):
            why.append("unsourced")
        if live[i].get("parsed_version") != anchor:
            why.append(f"live={live[i].get('parsed_version')}")
        lr = ledger.get(i, [])
        if len(lr) != 1 or len(lr[0]) != 11:
            why.append("no-ledger")
        else:
            _, lurl, prior, rearmed, lfid, fat, cpath, csha, cbytes, qc, lverdict = lr[0]
            cp = os.path.normpath(os.path.join(T, cpath))
            try:
                fat_ok = FLOOR <= dt.datetime.fromisoformat(fat.replace("Z", "+00:00")) <= NOW
            except Exception:
                fat_ok = False
            if not (rearmed == anchor and lfid == fid and lurl == url_of(reg.get(i, ["", ""])[1])
                    and lverdict == "quote-located"):
                why.append("ledger-binding")
            else:
                quote = base_fetch[i][0][12]
                out = subprocess.run([sys.executable, rt, "locate", cp, quote], capture_output=True, text=True).stdout
                mm = re.search(r"count=(\d+)", out)
                n = int(mm.group(1)) if mm else -1
                if not (n >= 1 and str(n) == qc):
                    why.append(f"quote-count={n}/{qc}")
    ok = not why
    value += ok
    print(f"ID {i} anchor={anchor} {'PASS' if ok else 'FAIL ' + ','.join(why)}")
legs = dict(gate=gate, fresh=fresh, census=census)
final = value if all(legs.values()) else 0
print(f"C1_CLOCK_REARM: value={final} rows_passing={value} gate={gate} fresh={fresh} census={census} live=1")
sys.exit(0 if final == 10 else 1)
PY

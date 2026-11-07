#!/usr/bin/env bash
# plans/round-53-c1.sh -- round 53 C1 counter (freshness: the lane's two "current stable release"
# pins move from a 90-day cadence to a live release clock).
#
# Frozen predicate (the same sentence appears in plans/round-53.md section C1):
#   C1_CURRENCY_CLOCKS: value = number of ids in F that are WATCHED, when GATE = 1, else 0;
#   target 2 (BASE 0).
#   F         S103 (SOPS v3.13.3 tag page) and S104 (age v1.3.2 tag page): the BASE registry rows
#             whose teaching states the tag is the project's "current stable release" and that sit
#             on a fixed `90d` recheck at BASE c1953d4a; expected feed URL and pin:
#             S103 https://github.com/getsops/sops/releases.atom 3.13.3
#             S104 https://github.com/FiloSottile/age/releases.atom 1.3.2
#   WATCHED(id) all of:
#     (a) the measured corpus/SOURCES.md has exactly one row for id; its source URL equals the
#         BASE row's URL; status `mined`; recheck `on-release`;
#     (b) the measured corpus/release-clocks.tsv has exactly one row for id, 9 TAB fields,
#         clock `feed`, feed_url = the expected feed URL, anchored_version = the pin;
#     (c) its feed_source_id names exactly one registry row whose source URL equals feed_url,
#         kind `code`, status `mined`, recheck not `on-release`;
#     (d) RECEIPT: the default receipt the measured corpus/release-clock.py names (the path in
#         `receipt_path`, the digest in DEFAULT_RECEIPT_SHA256) exists in the measured tree with
#         that sha256 and holds exactly one observation for id with http_status 200, url =
#         feed_url, parsed_version = the pin, verdict `not-fired`, and observed_at
#         `YYYY-MM-DDTHH:MM:SSZ` with 2026-11-07T00:00:00Z <= observed_at <= ASOF (the measured
#         revision's committer time, or C1_ASOF=<epoch> for --tree).
#   GATE      GUARD = 1 and `python3 corpus/release-clock.py` in the measured tree exits 0 with a
#             last line starting `RELEASE_CLOCK: CLEAN`.
#   GUARD     the measured corpus/release-clock.py equals the BASE file on every line except the
#             DEFAULT_RECEIPT_SHA256 line, the default-path line inside receipt_path and the
#             `--receipt` help line (line numbers 28, 547, 2105 at BASE; the file keeps 2151 lines).
#             GUARD = 0 means GATE = 0 (a replaced gate cannot score).
# Fail closed: unreadable BASE, bad revision, missing tree, unusable scratch or missing python3 is
# SETUP (exit 2, no value). A gate run that prints no last line reads GATE = 0, never 1.
# Named ceiling: the counter checks committed bytes and declared times; a hand-forged receipt whose
# digest is written into release-clock.py and whose records are self-consistent scores. The live
# leg (an independent re-fetch of both feeds, newest stable compared with the pins) is the
# non-author check that catches it.
# Input: a revision, or --tree DIR with C1_ASOF=<epoch>. Output: one line
#   C1_CURRENCY_CLOCKS: value=V watched=W gate=G guard=U (ok=<ids>; bad=<id:reason ...>; gate-line=...)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=c1953d4afc19a5a336a58685c00ab5260bcfea1c
FLOOR=$(date -u -d 2026-11-07T00:00:00Z +%s)
setup() { echo "C1_CURRENCY_CLOCKS: SETUP $1"; exit 2; }
command -v python3 >/dev/null 2>&1 || setup no-python3
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r53/c1.$$
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
git -C "$REPO" show "$BASE:corpus/release-clock.py" > "$SCR/b/release-clock.py" 2>/dev/null || setup base-gate
[ -f "$T/corpus/release-clock.py" ] || setup missing-gate
[ -f "$T/corpus/SOURCES.md" ] || setup missing-registry

# GUARD: BASE gate bytes outside the three declared lines
guard=0
if [ "$(wc -l < "$T/corpus/release-clock.py")" = "$(wc -l < "$SCR/b/release-clock.py")" ] &&
   cmp -s <(sed '28d;547d;2105d' "$SCR/b/release-clock.py") <(sed '28d;547d;2105d' "$T/corpus/release-clock.py") &&
   sed -n 28p "$T/corpus/release-clock.py" | grep -qE '^DEFAULT_RECEIPT_SHA256 = "[0-9a-f]{64}"$' &&
   sed -n 547p "$T/corpus/release-clock.py" | grep -qE '^        return root / "\.ufo" / "waves" / "round-[0-9]+" / "final" / "[A-Za-z0-9._-]+\.json"$'; then
  guard=1
fi
gout=$(cd "$T" && timeout 300 python3 corpus/release-clock.py 2>/dev/null); grc=$?
glast=$(printf '%s\n' "$gout" | sed '/^[[:space:]]*$/d' | tail -n 1)
gate=0
[ "$guard" -eq 1 ] && [ "$grc" -eq 0 ] && [[ $glast == "RELEASE_CLOCK: CLEAN"* ]] && gate=1

# registry row fields (11 cells) by id: prints id|url|kind|status|recheck
row() { # file id
  python3 - "$1" "$2" <<'PY'
import re, sys
path, sid = sys.argv[1], sys.argv[2]
hits = []
for line in open(path, encoding="utf-8"):
    if not re.match(r"^ {0,3}\|\s*%s\s*\|" % re.escape(sid), line):
        continue
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) != 11:
        hits.append("MALFORMED"); continue
    m = re.search(r"https?://[^\s|]+", cells[1])
    hits.append("\t".join([cells[0], m.group(0) if m else "-", cells[2], cells[7], cells[9]]))
print(hits[0] if len(hits) == 1 else "COUNT=%d" % len(hits))
PY
}
receipt_check() { # tree id feed pin -> OK or reason
  python3 - "$T" "$1" "$2" "$3" "$ASOF" "$FLOOR" <<'PY'
import hashlib, json, re, sys, datetime as dt
from pathlib import Path
t, sid, feed, pin, asof, floor = sys.argv[1:7]
g = (Path(t) / "corpus/release-clock.py").read_text(encoding="utf-8").split("\n")
if len(g) < 547:
    print("receipt-unnamed"); sys.exit()
m1 = re.fullmatch(r'DEFAULT_RECEIPT_SHA256 = "([0-9a-f]{64})"', g[27])
m2 = re.fullmatch(r'        return root / "\.ufo" / "waves" / "(round-[0-9]+)" / "final" / "([A-Za-z0-9._-]+\.json)"', g[546])
if not (m1 and m2):
    print("receipt-unnamed"); sys.exit()
p = Path(t) / ".ufo" / "waves" / m2.group(1) / "final" / m2.group(2)
if not p.is_file() or p.is_symlink():
    print("receipt-missing"); sys.exit()
raw = p.read_bytes()
if hashlib.sha256(raw).hexdigest() != m1.group(1):
    print("receipt-sha"); sys.exit()
try:
    obs = [o for o in json.loads(raw)["observations"] if isinstance(o, dict) and o.get("id") == sid]
except Exception:
    print("receipt-json"); sys.exit()
if len(obs) != 1:
    print("receipt-records=%d" % len(obs)); sys.exit()
o = obs[0]
if o.get("http_status") != 200: print("receipt-status"); sys.exit()
if o.get("url") != feed: print("receipt-url"); sys.exit()
if o.get("parsed_version") != pin: print("receipt-version"); sys.exit()
if o.get("verdict") != "not-fired": print("receipt-verdict"); sys.exit()
at = o.get("observed_at")
if not isinstance(at, str) or not re.fullmatch(r"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ", at):
    print("receipt-time-shape"); sys.exit()
e = int(dt.datetime.strptime(at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=dt.timezone.utc).timestamp())
if not int(floor) <= e <= int(asof):
    print("receipt-time-window"); sys.exit()
print("OK")
PY
}

ok=""; bad=""; n=0
for spec in "S103 https://github.com/getsops/sops/releases.atom 3.13.3" \
            "S104 https://github.com/FiloSottile/age/releases.atom 1.3.2"; do
  set -- $spec; id=$1; feed=$2; pin=$3
  # (a)
  r=$(row "$T/corpus/SOURCES.md" "$id"); b=$(row "$SCR/b/SOURCES.md" "$id")
  [[ $b == "$id"$'\t'* ]] || setup "base-row:$id"
  [[ $r == "$id"$'\t'* ]] || { bad="$bad $id:registry-$r"; continue; }
  IFS=$'\t' read -r _ rurl _ rstatus rrecheck <<< "$r"
  IFS=$'\t' read -r _ burl _ _ _ <<< "$b"
  [ "$rurl" = "$burl" ] || { bad="$bad $id:url-swapped"; continue; }
  [ "$rstatus" = mined ] || { bad="$bad $id:status"; continue; }
  [ "$rrecheck" = on-release ] || { bad="$bad $id:recheck=$rrecheck"; continue; }
  # (b)
  L=$T/corpus/release-clocks.tsv
  [ -f "$L" ] || { bad="$bad $id:no-clock-table"; continue; }
  c=$(awk -F'\t' -v i="$id" '$1==i' "$L" | wc -l)
  [ "$c" -eq 1 ] || { bad="$bad $id:clock-rows=$c"; continue; }
  nf=$(awk -F'\t' -v i="$id" '$1==i {print NF}' "$L")
  [ "$nf" = 9 ] || { bad="$bad $id:clock-fields"; continue; }
  IFS=$'\t' read -r _ clock fsid furl anch _ < <(awk -F'\t' -v i="$id" '$1==i' "$L")
  [ "$clock" = feed ] || { bad="$bad $id:clock=$clock"; continue; }
  [ "$furl" = "$feed" ] || { bad="$bad $id:feed-url"; continue; }
  [ "$anch" = "$pin" ] || { bad="$bad $id:anchored"; continue; }
  # (c)
  [[ $fsid =~ ^S[0-9]{3}$ ]] || { bad="$bad $id:feed-id"; continue; }
  f=$(row "$T/corpus/SOURCES.md" "$fsid")
  [[ $f == "$fsid"$'\t'* ]] || { bad="$bad $id:feed-row-$f"; continue; }
  IFS=$'\t' read -r _ furl2 fkind fstatus frecheck <<< "$f"
  [ "$furl2" = "$feed" ] || { bad="$bad $id:feed-row-url"; continue; }
  [ "$fkind" = code ] || { bad="$bad $id:feed-kind"; continue; }
  [ "$fstatus" = mined ] || { bad="$bad $id:feed-status"; continue; }
  [ "$frecheck" != on-release ] || { bad="$bad $id:feed-recheck"; continue; }
  # (d)
  rc=$(receipt_check "$id" "$feed" "$pin")
  [ "$rc" = OK ] || { bad="$bad $id:$rc"; continue; }
  ok="$ok $id"; n=$((n + 1))
done
value=0
[ "$gate" -eq 1 ] && value=$n
echo "C1_CURRENCY_CLOCKS: value=$value watched=$n gate=$gate guard=$guard (ok=${ok# }; bad=${bad# }; gate-line=$glast)"

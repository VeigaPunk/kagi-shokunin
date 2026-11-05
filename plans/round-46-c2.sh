#!/usr/bin/env bash
# plans/round-46-c2.sh -- round 46 C2 counter (freshness: the 29 registry rows that carry an
# `on-release` recheck at BASE are re-observed live this round through corpus/release-clock.py
# --observe, and the lane's own release-clock gate reads CLEAN on the real tree again; it has
# read FAILED since the round-39 landing 4776f71: ORPHAN S040/S041, RECEIPT-MISMATCH
# S040/S041, UNBOUND S098 at BASE).
#
# Frozen predicate (the same sentence appears in plans/round-46.md section C2):
#   C2_FRESH_CLOCKS: value = FRESH when DEFAULT = CLEAN and PINNED = CLEAN and KEPT = 1,
#   else 0; target 29.
#   ON29     the frozen BASE on-release id list below (29 ids, S005..S032 and S098).
#   DEFAULT  `python3 -B corpus/release-clock.py --root <tree>` exits 0 and its last line
#            starts `RELEASE_CLOCK: CLEAN`.
#   PINNED   the same gate with `--receipt .ufo/waves/round-46/final/observe-r46.json
#            --receipt-sha <sha256 of that committed file>` exits 0 and reads CLEAN.
#   KEPT     every registry id present in corpus/SOURCES.md at BASE is present in the
#            measured tree (no registry row deleted).
#   FRESH    number of ON29 ids that, in the measured tree, (a) still carry recheck
#            `on-release`, (b) have exactly one corpus/release-clocks.tsv row, (c) have exactly
#            one record in the round-46 receipt with http_status 200, a 64-hex sha256, and an
#            observed_at whose date part is >= 2026-11-06 and equals the tsv observed_at.
# Input: a revision (git archive) or C2_TREE=<dir> (pre-freeze control fixtures only).
# Output: one line `C2_FRESH_CLOCKS: value=V fresh=F default=.. pinned=.. kept=K (...)`;
# exit 0 when measured; exit 2 with a SETUP line (no value) on a bad revision, a missing gate
# or BASE registry, or unusable scratch. A missing receipt is not SETUP: PINNED and FRESH read
# from nothing and the value is 0 (fail closed). Empty producer output never parses as CLEAN.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=f5977284a8ce5bab09252be8196ee5dc18489926
ON29="S005 S006 S007 S008 S009 S010 S011 S012 S013 S014 S015 S016 S017 S018 S019 S020 S021 S022 S023 S024 S025 S026 S027 S028 S029 S030 S031 S032 S098"
RECEIPT=.ufo/waves/round-46/final/observe-r46.json
REV=${1:-}
setup() { echo "C2_FRESH_CLOCKS: SETUP $1"; exit 2; }
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r46/c2.$$
mkdir -p -- "$SCR/t" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
T=$SCR/t
if [ -n "${C2_TREE:-}" ]; then
  [ -d "$C2_TREE" ] || setup tree
  cp -a "$C2_TREE"/. "$T"/ || setup tree-copy
else
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
[ -f "$T/corpus/release-clock.py" ] || setup missing-gate
git -C "$REPO" show "$BASE:corpus/SOURCES.md" > "$SCR/base-sources.md" 2>/dev/null || setup base-registry

gate() { # gate <args...>: prints "<rc> <clean 0|1> <last line>"
  local out rc last clean=0
  out=$(cd "$T" && python3 -B corpus/release-clock.py --root "$T" "$@" 2>/dev/null); rc=$?
  last=$(printf '%s\n' "$out" | tail -n 1)
  if [ "$rc" -eq 0 ]; then
    case $last in "RELEASE_CLOCK: CLEAN"*) clean=1 ;; esac
  fi
  printf '%s %s %s\n' "$rc" "$clean" "$last"
}
read -r drc DEFAULT dlast <<EOF
$(gate)
EOF
PINNED=0; prc=none; plast=no-receipt; RSHA=-
if [ -f "$T/$RECEIPT" ]; then
  RSHA=$(sha256sum < "$T/$RECEIPT" | cut -c1-64)
  read -r prc PINNED plast <<EOF
$(gate --receipt "$RECEIPT" --receipt-sha "$RSHA")
EOF
fi

read -r KEPT FRESH detail <<EOF
$(python3 -B - "$SCR/base-sources.md" "$T" "$RECEIPT" "$ON29" <<'PY'
import json, re, sys
base_path, tree, receipt_rel, on29 = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4].split()
ROW = re.compile(r"^ {0,3}\|[ \t]*(S[0-9]{3,})[ \t]*\|")
def rows(text):
    out = {}
    for line in text.splitlines():
        m = ROW.match(line)
        if m:
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            out.setdefault(m.group(1), []).append(cells)
    return out
base = rows(open(base_path, encoding="utf-8").read())
try:
    cur = rows(open(tree + "/corpus/SOURCES.md", encoding="utf-8").read())
except OSError:
    cur = {}
kept = int(all(i in cur for i in base))
tsv = {}
try:
    for line in open(tree + "/corpus/release-clocks.tsv", encoding="utf-8").read().splitlines():
        f = line.split("\t")
        if len(f) == 9 and re.fullmatch(r"S[0-9]{3,}", f[0]):
            tsv.setdefault(f[0], []).append(f)
except OSError:
    pass
recs = {}
try:
    doc = json.load(open(tree + "/" + receipt_rel, encoding="utf-8"))
    for r in doc.get("observations", []) if isinstance(doc, dict) else []:
        if isinstance(r, dict) and isinstance(r.get("id"), str):
            recs.setdefault(r["id"], []).append(r)
except (OSError, ValueError):
    pass
fresh = 0
miss = []
for i in on29:
    c = cur.get(i, [])
    ok = len(c) == 1 and len(c[0]) == 11 and c[0][9] == "on-release"
    t = tsv.get(i, [])
    ok = ok and len(t) == 1
    r = recs.get(i, [])
    ok = ok and len(r) == 1
    if ok:
        r = r[0]
        at = str(r.get("observed_at") or "")
        ok = (r.get("http_status") == 200
              and isinstance(r.get("sha256"), str) and re.fullmatch(r"[0-9a-f]{64}", r["sha256"]) is not None
              and re.fullmatch(r"\d{4}-\d\d-\d\dT.*", at) is not None
              and at[:10] >= "2026-11-06" and at[:10] == t[0][6])
    if ok:
        fresh += 1
    else:
        miss.append(i)
print(kept, fresh, "missing=" + (",".join(miss) if miss else "none"))
PY
)
EOF
[ -n "${KEPT:-}" ] && [ -n "${FRESH:-}" ] || setup parser-empty
VALUE=0
if [ "$DEFAULT" = 1 ] && [ "$PINNED" = 1 ] && [ "$KEPT" = 1 ]; then VALUE=$FRESH; fi
echo "C2_FRESH_CLOCKS: value=$VALUE fresh=$FRESH default=$DEFAULT pinned=$PINNED kept=$KEPT (default-rc=$drc default-last='$dlast'; pinned-rc=$prc pinned-last='$plast'; receipt-sha=$RSHA; $detail)"
exit 0

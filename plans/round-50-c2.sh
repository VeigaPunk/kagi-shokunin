#!/usr/bin/env bash
# plans/round-50-c2.sh — FROZEN round-50 C2 counter (axis calibration): the lane's own claim
# ledger agrees with the observed repo state on ten drifted rows (round-49 lesson §Routed 1;
# round-49 closure D2 folds the command-column freeze into this counter).
#
# Predicate (same sentence as plans/round-50.md §C2):
#   C2_LEDGER_DRIFT: value = number of the ten frozen ids {R13-01, R21-02, R22-03, R24-05,
#   R24-06, R24-15, R31-02, R33-02, R34-03, R38-01} named on a FAIL, POLICY or LAYOUT-INCOMPLETE
#   line of `bash corpus/claim-ledger.sh verify` run on exactly those ten rows of the measured
#   revision, when GUARD = 1, else SETUP; target 0 (BASE 10).
# - Executed in a clean `git clone --shared` checkout of the measured revision; verify runs with
#   --root <checkout> --claims <the ten rows> --stamps <checkout>/corpus/stamps.tsv, timeout 900 s,
#   and must end with a `CLAIM_LEDGER: ` line carrying `claims=10`, else SETUP.
# - GUARD (each failure is SETUP, never a zero):
#   G1 `corpus/claim-ledger.sh`, `corpus/sources-census.sh`, `corpus/revision-audit.py`,
#      `corpus/row-identity.sh`, `corpus/quote-locate.py` and `plans/round-38-c1.sh` are
#      byte-identical to BASE (the rows' producers are not edited to fit);
#   G2 for each frozen id, the id, command, exit and timeout columns (fields 1, 2, 4, 5) are
#      byte-identical to BASE — only the expect (3) and note (6) columns may move;
#   G3 rows R25-02, R29-01, R29-02 and R38-03 are byte-identical to BASE (operator-routed boundary);
#   G4 every id present at BASE is present exactly once at the measured revision;
#   G5 every frozen id whose expect differs from BASE has exactly one entry in the measured tree's
#      `.ufo/waves/round-50/expectation-migrations.json` "migrations" list with "id", "old_expect"
#      (= the BASE expect), "new_expect" (= the measured expect) and a non-empty "reason" (the
#      lane's standing journal form, `.ufo/waves/round-49/expectation-migrations.json`);
#   G6 every changed expect DISCRIMINATES: the row's last non-empty output line (run here as verify
#      runs it) holds at least one digit, and the expect, applied with bash `=~`, does NOT match
#      that line with every digit run replaced by its value + 1 (a wildcard or digit-class
#      expect that cannot tell 67 from 68 is refused).
#
# Usage: bash plans/round-50-c2.sh <rev>        (measures <rev> in this repo)
#        bash plans/round-50-c2.sh --tree DIR   (controls only: DIR is a git work tree; its HEAD is measured)
# Scratch: $HYAKU_SCRATCH (default /fast/scratch/hyaku)/kagi-r50/c2-counter.XXXXXX, removed on exit.
set -u
BASE=565c43a874b59cd216f4a55c8742db48fa854f16
IDS="R13-01 R21-02 R22-03 R24-05 R24-06 R24-15 R31-02 R33-02 R34-03 R38-01"
BOUNDARY="R25-02 R29-01 R29-02 R38-03"
PRODUCERS="corpus/claim-ledger.sh corpus/sources-census.sh corpus/revision-audit.py corpus/row-identity.sh corpus/quote-locate.py plans/round-38-c1.sh"
JOURNAL=.ufo/waves/round-50/expectation-migrations.json

setup() { echo "C2_LEDGER_DRIFT: SETUP reason=$1"; exit 2; }
[ $# -ge 1 ] || setup usage
LANE=$(cd "$(dirname "$0")/.." && pwd)
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r50"
mkdir -p "$SCR" || setup scratch
W=$(mktemp -d "$SCR/c2-counter.XXXXXX") || setup mktemp
trap 'rm -rf -- "$W"' EXIT

if [ "$1" = "--tree" ]; then
  [ -d "${2:-}/.git" ] || setup tree-not-git
  SRC=$(cd "$2" && pwd); REV=HEAD
else
  SRC="$LANE"; REV="$1"
fi
git -C "$SRC" rev-parse --verify -q "$REV^{commit}" >/dev/null || setup bad-rev
git -C "$LANE" rev-parse --verify -q "$BASE^{commit}" >/dev/null || setup base-missing
git clone -q --shared --no-checkout "$SRC" "$W/c" 2>/dev/null || setup clone
[ "$(git -C "$W/c" rev-parse --show-toplevel)" = "$W/c" ] || setup clone-toplevel
git -C "$W/c" checkout -q --detach "$(git -C "$SRC" rev-parse "$REV^{commit}")" 2>/dev/null || setup checkout
C="$W/c"
L="$C/corpus/claim-ledger.tsv"
[ -f "$L" ] || setup ledger-missing
git -C "$LANE" show "$BASE:corpus/claim-ledger.tsv" > "$W/base.tsv" || setup base-ledger
row() { grep -P "^\Q$1\E\t" "$2"; }   # id file -> whole row(s)
fld() { row "$1" "$2" | cut -f"$3"; }

# G1
for f in $PRODUCERS; do
  [ -f "$C/$f" ] || setup "G1-missing-$f"
  [ "$(git -C "$LANE" show "$BASE:$f" | sha256sum)" = "$(sha256sum < "$C/$f")" ] || setup "G1-changed-$f"
done
# G4
for id in $(grep -oP '^R[0-9]+-[0-9]+(?=\t)' "$W/base.tsv"); do
  [ "$(row "$id" "$L" | wc -l)" -eq 1 ] || setup "G4-row-count-$id"
done
# G3
for id in $BOUNDARY; do
  [ "$(row "$id" "$W/base.tsv")" = "$(row "$id" "$L")" ] || setup "G3-boundary-$id"
done
# G2
for id in $IDS; do
  [ "$(row "$id" "$W/base.tsv" | cut -f1,2,4,5)" = "$(row "$id" "$L" | cut -f1,2,4,5)" ] || setup "G2-columns-$id"
done
# G5 + G6 (only for changed expects)
changed=""
for id in $IDS; do
  [ "$(fld "$id" "$W/base.tsv" 3)" = "$(fld "$id" "$L" 3)" ] || changed="$changed $id"
done
for id in $changed; do
  old=$(fld "$id" "$W/base.tsv" 3); new=$(fld "$id" "$L" 3)
  [ -f "$C/$JOURNAL" ] || setup "G5-journal-missing"
  python3 - "$C/$JOURNAL" "$id" "$old" "$new" <<'PY' || setup "G5-journal-$id"
import json, sys
p, i, old, new = sys.argv[1:5]
try:
    d = json.load(open(p))
except Exception:
    sys.exit(1)
rows = d if isinstance(d, list) else d.get("migrations", [])
hits = [r for r in rows if isinstance(r, dict) and r.get("id") == i]
ok = len(hits) == 1 and hits[0].get("old_expect") == old and hits[0].get("new_expect") == new \
    and isinstance(hits[0].get("reason"), str) and hits[0]["reason"].strip() != ""
sys.exit(0 if ok else 1)
PY
  cmd=$(fld "$id" "$L" 2); tmo=$(fld "$id" "$L" 5)
  out=$(cd "$C" && timeout -k 5 "$tmo" bash -o pipefail -c "$cmd" 2>&1)
  last=$(printf '%s\n' "$out" | grep -v '^[[:space:]]*$' | tail -n 1)
  [[ $last =~ [0-9] ]] || setup "G6-no-digit-$id"
  pert=$(printf '%s' "$last" | perl -pe 's/(\d+)/$1+1/ge')
  [[ $pert =~ $new ]] && setup "G6-not-discriminating-$id"
done

# value
: > "$W/sub.tsv"
for id in $IDS; do row "$id" "$L" >> "$W/sub.tsv"; done
(cd "$C" && timeout 900 bash corpus/claim-ledger.sh verify --root "$C" --claims "$W/sub.tsv" \
  --stamps "$C/corpus/stamps.tsv") > "$W/out" 2>&1
rc=$?
fin=$(grep '^CLAIM_LEDGER: ' "$W/out" | tail -n 1)
case "$fin" in *"claims=10 "*|*"claims=10)"*) ;; *) setup "no-final-line-or-claims(rc=$rc)";; esac
value=0; detail=""
for id in $IDS; do
  v=OK
  grep -qE "^(FAIL|POLICY|LAYOUT-INCOMPLETE) $id( |\$)" "$W/out" && v=$(grep -E "^(FAIL|POLICY|LAYOUT-INCOMPLETE) $id( |\$)" "$W/out" | head -1 | awk '{print $1}')
  [ "$v" = OK ] || value=$((value + 1))
  detail="$detail $id=$v"
done
echo "C2_LEDGER_DRIFT: value=$value ids=10 changed=$(echo $changed | wc -w) verify_rc=$rc$detail"
echo "$fin"
exit 0

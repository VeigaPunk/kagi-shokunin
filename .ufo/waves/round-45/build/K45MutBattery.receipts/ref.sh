#!/bin/sh
# ref.sh -- K45MutBattery INDEPENDENT reference gate for round-45 C1 (calibration):
# the declared-claim manifest is a bijection with landed plan headings.
# Derived ONLY from the frozen predicate text in plans/round-45.md section C1:
#   scope: "a round R >= 39 is checked when plans/round-R.md carries claim headings
#   (shape '## C<k> — <axis>:') AND SCORECARD carries '## Round R — post-move'";
#   an in-flight round (no post-move section) is not checked; rounds < 39 are out
#   of scope (manifest history gap). Both bijection directions must hold with the
#   axis word equal. No text taken from corpus/claims-declared.sh.
# usage: sh ref.sh --root DIR   -> exit 0 CLEAN / 1 MISMATCH / 2 setup failure.
set -u
LC_ALL=C
export LC_ALL

ROOT=""
case "${1:-}" in
  --root) ROOT="${2:-}" ;;
  *) echo "REF[BIJECTION]: SETUP usage: sh ref.sh --root DIR"; exit 2 ;;
esac
[ -n "$ROOT" ] && [ -d "$ROOT" ] || { echo "REF[BIJECTION]: SETUP no-root"; exit 2; }
MAN="$ROOT/corpus/claims-declared.tsv"
PLANSDIR="$ROOT/plans"
SCORE="$ROOT/SCORECARD.md"
[ -f "$MAN" ] || { echo "REF[BIJECTION]: SETUP no-manifest: $MAN"; exit 2; }
[ -d "$PLANSDIR" ] || { echo "REF[BIJECTION]: SETUP no-plans: $PLANSDIR"; exit 2; }
[ -f "$SCORE" ] || { echo "REF[BIJECTION]: SETUP no-scorecard: $SCORE"; exit 2; }

MINR=39         # frozen scope lower bound
POSTMOVE_REQ=1  # frozen: an in-flight round (no post-move section) is not checked

W=$(mktemp -d "${TMPDIR:-/tmp}/ref.XXXXXX") || { echo "REF[BIJECTION]: SETUP mktemp"; exit 2; }
trap 'rm -rf -- "$W"' EXIT

# manifest rows: "R<TAB>Ck<TAB>axis"; header and malformed rows skipped
awk -F'\t' 'NR > 1 && $1 ~ /^[0-9]+$/ && $2 ~ /^C[0-9]+$/ && NF >= 3 {
  ax = $3; gsub(/[ \t\r]+$/, "", ax); if (ax != "") print $1 "\t" $2 "\t" ax
}' "$MAN" > "$W/rows.raw" 2>/dev/null || { echo "REF[BIJECTION]: SETUP manifest-read"; exit 2; }

# claim headings of scoped rounds
: > "$W/heads.raw"
for f in "$PLANSDIR"/round-*.md; do
  [ -f "$f" ] || continue
  b=${f##*/}; r=${b#round-}; r=${r%.md}
  case $r in *[!0-9]*|"") continue ;; esac
  [ "$r" -ge "$MINR" ] || continue
  if [ "$POSTMOVE_REQ" = 1 ]; then
    grep -q "^## Round $r — post-move" "$SCORE" 2>/dev/null || continue
  fi
  awk -v rr="$r" '
    /^## C[0-9]+ — / {
      k = $0;  sub(/^## C/, "", k);  sub(/ — .*/, "", k)
      ax = $0; sub(/^## C[0-9]+ — /, "", ax); sub(/:.*/, "", ax); gsub(/[ \t\r]+$/, "", ax)
      if (k != "" && ax != "") print rr "\tC" k "\t" ax
    }' "$f" >> "$W/heads.raw" 2>/dev/null || { echo "REF[BIJECTION]: SETUP plans-read"; exit 2; }
done

sort -u "$W/rows.raw"  > "$W/rows.sorted"
sort -u "$W/heads.raw" > "$W/heads.sorted"
cut -f1 "$W/heads.sorted" | sort -u > "$W/checked"
awk 'NR == FNR { chk[$1] = 1; next } ($1 in chk)' "$W/checked" "$W/rows.sorted" > "$W/rows.scoped"

# keys: full triple (R, Ck, axis). M3 target line: loosen to cut -f1-2 (ignore axis word).
cut -f1-3 "$W/heads.sorted" > "$W/heads.k"; cut -f1-3 "$W/rows.scoped" > "$W/rows.k"

comm -23 "$W/heads.k" "$W/rows.k" > "$W/missing-rows.txt"
comm -13 "$W/heads.k" "$W/rows.k" > "$W/orphan-rows.txt"

fail=0
if [ -s "$W/missing-rows.txt" ]; then
  echo "REF[BIJECTION]: MISMATCH plan-claims-without-manifest-row (plan->manifest direction):"
  awk '{print "  " $0}' "$W/missing-rows.txt"
  fail=1
fi
if [ -s "$W/orphan-rows.txt" ]; then
  echo "REF[BIJECTION]: MISMATCH manifest-rows-without-plan-claim (manifest->plan direction):"
  awk '{print "  " $0}' "$W/orphan-rows.txt"
  fail=1
fi
if [ "$fail" = 1 ]; then exit 1; fi
echo "REF[BIJECTION]: CLEAN scoped-rounds=$(wc -l < "$W/checked") pairs=$(wc -l < "$W/heads.sorted") rows=$(wc -l < "$W/rows.scoped")"
exit 0

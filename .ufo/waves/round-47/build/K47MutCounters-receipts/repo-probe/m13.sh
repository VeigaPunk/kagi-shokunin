#!/usr/bin/env bash
# plans/round-47-c1.sh -- round 47 C1 counter (calibration: the registry's own self-description
# -- `used-by` cells and fetch provenance -- agrees with the repo bytes the lane-local census
# reads; closes round-46 routed item 3 / closure routed 5).
#
# Frozen predicate (the same sentence appears in plans/round-47.md section C1):
#   C1_CENSUS_CALIBRATION: value = CLEARED when INTACT = 1 and BOUND = 1 and NEW = 0, else 0;
#   target 3.
#   CLEARED  number of the three BASE findings
#              FINDING SC_USEDBY_NOCITE id=S094 path=corpus/lessons/round-43.md
#              FINDING SC_USEDBY_NOCITE id=S099 path=corpus/lessons/round-44.md
#              FINDING SC_FETCH id=S099 missing-provenance
#            absent from the output of the measured tree's own `bash corpus/sources-census.sh`.
#   NEW      number of FINDING lines in that output that are not one of the three above.
#   INTACT   every registry id of BASE 252ef1ca (102 ids) is a registry row of the measured tree
#            with the same status cell, and the measured `used-by` sets of S094 and S099 each
#            contain every path of their BASE `used-by` set (a used-by narrowing is not a fix).
#   BOUND    the measured corpus/source-fetches.tsv has exactly one S099 row; its column 10
#            (sha256) and column 11 (bytes) equal the sha256 and byte count of the fleet git blob
#            `75dd26121698f10cf111120f6cbcd2b2125598f1:.ufo/prompts/kagi-round-44.md` (computed
#            live from the fleet repo by this counter, never read from the lane); its column 13
#            quote occurs verbatim in that blob; and the committed capture
#            `.ufo/waves/round-47/capture/S099.body` of the measured tree has that same sha256.
# Fail closed: a census run whose last line is not `SOURCES_CENSUS: CLEAN ...` or
# `SOURCES_CENSUS: FAILED ...` (empty, SETUP, crash) is a SETUP refusal (exit 2, no value), never
# zero findings. A missing fleet blob, bad revision or unusable scratch is SETUP too.
# Input: a revision (git archive of the lane at that revision) or C1_TREE=<dir> (fixture tree,
# pre-freeze controls only). Output: one line
#   C1_CENSUS_CALIBRATION: value=V cleared=C new=N intact=I bound=B (census=<last line>; why=...)
set -u
REPO=/fast/scratch/hyaku/kagi-r47/K47MutCounters/ctl/repo-probe/repo
FLEET=${C1_FLEET:-/home/vgpnk/Projects/shokunin}
BASE=b2455225a435bbe52ac1a04f97be98e52dd8f8e8
BLOB=75dd26121698f10cf111120f6cbcd2b2125598f1:.ufo/prompts/kagi-round-44.md
REV=${1:-}
setup() { echo "C1_CENSUS_CALIBRATION: SETUP $1"; exit 2; }
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/c1.$$
mkdir -p -- "$SCR/t" "$SCR/b" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
T=$SCR/t
if [ -n "${C1_TREE:-}" ]; then
  [ -d "$C1_TREE" ] || setup tree
  cp -a "$C1_TREE"/. "$T"/ || setup tree-copy
else
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
git -C "$REPO" show "$BASE:corpus/SOURCES.md" > "$SCR/b/SOURCES.md" 2>/dev/null || setup base-registry
git -C "$FLEET" show "$BLOB" > "$SCR/b/blob" 2>/dev/null || setup fleet-blob
[ -s "$SCR/b/blob" ] || setup fleet-blob-empty
[ -f "$T/corpus/sources-census.sh" ] && [ -f "$T/corpus/SOURCES.md" ] || setup missing-census

rows() { # rows <SOURCES.md>: id<TAB>status<TAB>used-by, contract row shape (0-3 leading spaces)
  awk -F'|' '/^ {0,3}\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {
    i=$2; s=$9; u=$12; gsub(/[[:space:]]/,"",i); gsub(/[[:space:]]/,"",s); gsub(/[[:space:]]/,"",u)
    print i "\t" s "\t" u }' "$1"
}

# --- census (fail closed) ---------------------------------------------------
out=$(cd "$T" && bash corpus/sources-census.sh 2>/dev/null)
last=$(printf '%s\n' "$out" | tail -n 1)
case $last in
  "SOURCES_CENSUS: CLEAN "*|"SOURCES_CENSUS: FAILED "*) ;;
  *) setup "census-output:${last:-empty}" ;;
esac
F1='FINDING SC_USEDBY_NOCITE id=S094 path=corpus/lessons/round-43.md'
F2='FINDING SC_USEDBY_NOCITE id=S099 path=corpus/lessons/round-44.md'
F3='FINDING SC_FETCH id=S099 missing-provenance'
cleared=0
for f in "$F1" "$F2" "$F3"; do
  printf '%s\n' "$out" | grep -qxF -- "$f" || cleared=$((cleared + 1))
done
new=$(printf '%s\n' "$out" | grep '^FINDING ' | grep -vxF -e "$F1" -e "$F2" -e "$F3" | wc -l)

# --- INTACT -------------------------------------------------------------------
why=""
intact=1
rows "$SCR/b/SOURCES.md" | sort > "$SCR/b/base-rows"
rows "$T/corpus/SOURCES.md" | sort > "$SCR/b/meas-rows"
nb=$(wc -l < "$SCR/b/base-rows")
[ "$nb" -ge 1 ] || setup "base-rows=$nb"
while IFS=$'\t' read -r id st ub; do
  mst=$(awk -F'\t' -v i="$id" '$1==i {print $2}' "$SCR/b/meas-rows")
  [ "$(awk -F'\t' -v i="$id" '$1==i' "$SCR/b/meas-rows" | wc -l)" -eq 1 ] || { intact=0; why="$why row-count:$id"; continue; }
  [ "$mst" = "$st" ] || { intact=0; why="$why status:$id"; }
  case $id in
    S094|S099)
      mub=$(awk -F'\t' -v i="$id" '$1==i {print $3}' "$SCR/b/meas-rows")
      IFS=',;' read -ra parts <<<"$ub"
      for p in "${parts[@]}"; do
        [ -n "$p" ] || continue
        case ",${mub//;/,}," in *",$p,"*) ;; *) intact=0; why="$why usedby-narrowed:$id:$p" ;; esac
      done ;;
  esac
done < "$SCR/b/base-rows"

# --- BOUND --------------------------------------------------------------------
bound=1
bsha=$(sha256sum < "$SCR/b/blob" | cut -d' ' -f1)
bbytes=$(wc -c < "$SCR/b/blob")
FT=$T/corpus/source-fetches.tsv
n99=$(awk -F'\t' '$1=="S099"' "$FT" 2>/dev/null | wc -l)
if [ "$n99" -ne 1 ]; then
  bound=0; why="$why s099-rows=$n99"
else
  IFS=$'\t' read -r -a R < <(awk -F'\t' '$1=="S099"' "$FT")
  [ "${R[9]:-}" = "$bsha" ] || { bound=0; why="$why sha"; }
  [ "${R[10]:-}" = "$bbytes" ] || { bound=0; why="$why bytes"; }
  q=${R[12]:-}
  if [ -z "$q" ] || ! grep -qF -- "$q" "$SCR/b/blob"; then bound=0; why="$why quote"; fi
  C=$T/.ufo/waves/round-47/capture/S099.body
  if [ -f "$C" ]; then
    [ "$(sha256sum < "$C" | cut -d' ' -f1)" = "$bsha" ] || { bound=0; why="$why capture-sha"; }
  else
    bound=0; why="$why capture-missing"
  fi
fi

value=0
[ "$intact" -eq 1 ] && [ "$bound" -eq 1 ] && [ "$new" -eq 0 ] && value=$cleared
echo "C1_CENSUS_CALIBRATION: value=$value cleared=$cleared new=$new intact=$intact bound=$bound (census=$last; why=${why# })"

#!/usr/bin/env bash
# plans/round-47-c2.sh -- round 47 C2 counter (freshness: the teaching of every fired
# Vault/OpenBao release clock is re-verified on the docs served at the observed release;
# closes round-46 routed item 4 for the eleven rows with no successor).
#
# Frozen predicate (the same sentence appears in plans/round-47.md section C2):
#   C2_FIRED_REVERIFIED: value = REVERIFIED when GATE = 1, else 0; target 11.
#   F        the frozen set S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026 (BASE
#            release-clocks.tsv verdict `fired`, registry status `mined`, no successor row;
#            the other two fired rows S027/S028 are re-verified through successors S040->S095
#            and S041->S096 and are outside F).
#   REVERIFIED number of ids in F with exactly one row in the measured corpus/fired-reverify.tsv
#            (header `id url observed_release fetched_at capture_path sha256 bytes quote_count
#            verdict`, TAB-separated) where ALL hold:
#            (a) url equals the URL in that id's measured registry `source` cell;
#            (b) observed_release equals that id's `observed_version` in the measured
#                corpus/release-clocks.tsv;
#            (c) fetched_at is `YYYY-MM-DDTHH:MM:SSZ` with 2026-11-06T00:00:00Z <= fetched_at
#                <= the measured revision's committer time (C2_ASOF=<epoch> for fixture trees);
#            (d) capture_path is repo-relative under `.ufo/waves/round-47/capture/` (no `..`),
#                the file exists in the measured tree, and its sha256 and byte count equal the
#                row's sha256 and bytes;
#            (e) the measured corpus/source-fetches.tsv column-13 quote of that id equals the
#                BASE 252ef1ca column-13 quote (no quote swap), and
#                `python3 corpus/rendered-text-v1.py locate <capture> <quote>` (the measured
#                tree's normalizer) exits 0 with `count=K`, K >= 1, and K equals quote_count;
#            (f) verdict is `teaching-holds`.
#   GATE     `python3 corpus/release-clock.py` in the measured tree exits 0 and its last line
#            starts `RELEASE_CLOCK: CLEAN` (re-verification must not break the clock gate).
# Fail closed: a missing normalizer, missing release-clock gate, unreadable BASE fetch rows,
# bad revision or unusable scratch is SETUP (exit 2, no value). A normalizer run that prints no
# `count=` line counts as not located, never as located.
# Named ceiling: the counter checks committed bytes and declared times only; a hand-typed
# fetched_at over a byte-correct body scores. The non-author live leg (an independent re-fetch
# compared by sha256) is the check that catches it.
# Input: a revision or C2_TREE=<dir> + C2_ASOF=<epoch>. Output: one line
#   C2_FIRED_REVERIFIED: value=V reverified=R gate=G (ok=<ids>; bad=<id:reason ...>)
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=252ef1cac9f41d84639c0d1f211d0e0911196112
F="S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026"
FLOOR=$(date -u -d 2026-11-06T00:00:00Z +%s)
REV=${1:-}
setup() { echo "C2_FIRED_REVERIFIED: SETUP $1"; exit 2; }
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/c2.$$
mkdir -p -- "$SCR/t" "$SCR/b" || setup scratch
trap 'rm -rf -- "$SCR"' EXIT
T=$SCR/t
if [ -n "${C2_TREE:-}" ]; then
  [ -d "$C2_TREE" ] || setup tree
  [[ ${C2_ASOF:-} =~ ^[0-9]+$ ]] || setup asof
  ASOF=$C2_ASOF
  cp -a "$C2_TREE"/. "$T"/ || setup tree-copy
else
  [ -n "$REV" ] || setup no-revision
  git -C "$REPO" cat-file -e "$REV^{commit}" 2>/dev/null || setup bad-revision
  ASOF=$(git -C "$REPO" show -s --format=%ct "$REV") || setup committer-time
  git -C "$REPO" archive "$REV" | tar -x -C "$T" || setup archive
fi
git -C "$REPO" show "$BASE:corpus/source-fetches.tsv" > "$SCR/b/fetches" 2>/dev/null || setup base-fetches
[ -f "$T/corpus/rendered-text-v1.py" ] || setup missing-normalizer
[ -f "$T/corpus/release-clock.py" ] || setup missing-release-clock

gout=$(cd "$T" && python3 corpus/release-clock.py 2>/dev/null); grc=$?
glast=$(printf '%s\n' "$gout" | tail -n 1)
gate=0
[ "$grc" -eq 0 ] && [[ $glast == "RELEASE_CLOCK: CLEAN"* ]] && gate=1

L=$T/corpus/fired-reverify.tsv
ok=""; bad=""; n=0
for id in $F; do
  if [ ! -f "$L" ]; then bad="$bad $id:no-ledger"; continue; fi
  c=$(awk -F'\t' -v i="$id" '$1==i' "$L" | wc -l)
  [ "$c" -eq 1 ] || { bad="$bad $id:rows=$c"; continue; }
  IFS=$'\t' read -r _ url rel fat cap sha bytes qc verdict < <(awk -F'\t' -v i="$id" '$1==i' "$L")
  # (a)
  rurl=$(awk -F'|' -v i="$id" '{x=$2; gsub(/[[:space:]]/,"",x)} x==i { if (match($3, /https?:\/\/[^ |]+/)) print substr($3,RSTART,RLENGTH) }' "$T/corpus/SOURCES.md")
  [ -n "$rurl" ] && [ "$url" = "$rurl" ] || { bad="$bad $id:url"; continue; }
  # (b)
  ov=$(awk -F'\t' -v i="$id" '$1==i {print $6}' "$T/corpus/release-clocks.tsv")
  [ -n "$ov" ] && [ "$rel" = "$ov" ] || { bad="$bad $id:release"; continue; }
  # (c)
  [[ $fat =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] || { bad="$bad $id:fetched-shape"; continue; }
  fe=$(date -u -d "$fat" +%s 2>/dev/null) || { bad="$bad $id:fetched-parse"; continue; }
  [ "$fe" -ge "$FLOOR" ] && [ "$fe" -le "$ASOF" ] || { bad="$bad $id:fetched-window"; continue; }
  # (d)
  case $cap in .ufo/waves/round-47/capture/*) ;; *) bad="$bad $id:capture-path"; continue ;; esac
  case "/$cap/" in */../*) bad="$bad $id:capture-dotdot"; continue ;; esac
  [ -f "$T/$cap" ] || { bad="$bad $id:capture-missing"; continue; }
  [ "$(sha256sum < "$T/$cap" | cut -d' ' -f1)" = "$sha" ] || { bad="$bad $id:capture-sha"; continue; }
  [ "$(wc -c < "$T/$cap")" = "$bytes" ] || { bad="$bad $id:capture-bytes"; continue; }
  # (e)
  bq=$(awk -F'\t' -v i="$id" '$1==i {print $13}' "$SCR/b/fetches")
  mq=$(awk -F'\t' -v i="$id" '$1==i {print $13}' "$T/corpus/source-fetches.tsv")
  [ -n "$bq" ] || setup "base-quote:$id"
  [ "$mq" = "$bq" ] || { bad="$bad $id:quote-swapped"; continue; }
  lout=$(cd "$T" && python3 corpus/rendered-text-v1.py locate "$T/$cap" "$mq" 2>/dev/null); lrc=$?
  k=$(printf '%s\n' "$lout" | sed -n 's/.*count=\([0-9][0-9]*\).*/\1/p' | head -n 1)
  [ "$lrc" -eq 0 ] && [ -n "$k" ] && [ "$k" -ge 1 ] || { bad="$bad $id:not-located"; continue; }
  [ "$k" = "$qc" ] || { bad="$bad $id:quote-count"; continue; }
  # (f)
  [ "$verdict" = teaching-holds ] || { bad="$bad $id:verdict"; continue; }
  ok="$ok $id"; n=$((n + 1))
done
value=0
[ "$gate" -eq 1 ] && value=$n
echo "C2_FIRED_REVERIFIED: value=$value reverified=$n gate=$gate (ok=${ok# }; bad=${bad# }; gate-line=$glast)"

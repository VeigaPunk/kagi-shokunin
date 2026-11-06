#!/usr/bin/env bash
# .ufo/waves/round-47/final/candidate-legs.sh -- round-47 candidate-side legs (wave evidence, not a
# frozen instrument). Each leg answers a pre-candidate attack on the frozen counters with a check on
# the candidate's committed bytes; no frozen predicate, counter, target or kill rule is changed.
# usage: bash candidate-legs.sh <candidate-rev>   (run from anywhere; prints one LEG line per check)
set -u
REPO=$(cd "$(dirname "$0")/../../../.." && pwd -P)
BASE=252ef1cac9f41d84639c0d1f211d0e0911196112
REV=${1:?candidate revision}
W=$REPO/.ufo/waves/round-47
F="S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026"
g() { git -C "$REPO" "$@"; }
leg() { echo "LEG $1 $2 :: $3"; }

# L1 instruments byte-identical to BASE (K47RP-01/02, sentinel S-01..S-03, critic D-7): the counters
# executed the BASE census, normalizer and clock gate, so the values measure the candidate's data.
d=$(g diff --name-only "$BASE" "$REV" -- corpus/sources-census.sh corpus/rendered-text-v1.py corpus/release-clock.py)
s=""; for f in corpus/sources-census.sh corpus/rendered-text-v1.py corpus/release-clock.py; do
  a=$(g show "$REV:$f" | sha256sum | cut -c1-64); b=$(awk -v f="$f" '$2==f {print $1}' "$W/controls/instrument-sha256.txt")
  [ "$a" = "$b" ] || s="$s $f"
done
[ -z "$d$s" ] && leg L1-instruments PASS "no diff BASE..candidate; sha256 = controls/instrument-sha256.txt" \
  || leg L1-instruments FAIL "diff=[$d] sha-mismatch=[$s]"

# L2 lessons only gained lines (frozen C1 kill rule; the source: lines are prepended because
# round-44.md has no trailing newline -- an EOF append would rewrite its last line)
m=$(g diff "$BASE" "$REV" -- corpus/lessons/round-43.md corpus/lessons/round-44.md | grep -cE '^-[^-]')
a=$(g diff "$BASE" "$REV" -- corpus/lessons/round-43.md corpus/lessons/round-44.md | grep -cE '^\+[^+]')
[ "$m" -eq 0 ] && leg L2-lessons-append-only PASS "minus=0 plus=$a" || leg L2-lessons-append-only FAIL "minus=$m"

# L3 release-clocks.tsv unchanged (frozen C2 kill rule, columns 1-8; checked on the whole file)
g diff --quiet "$BASE" "$REV" -- corpus/release-clocks.tsv && leg L3-clocks-unchanged PASS "git diff --quiet rc=0" \
  || leg L3-clocks-unchanged FAIL "release-clocks.tsv changed"

# L4 registry URL cells of F and of S099 unchanged (K47RP-05, sentinel S-08)
u() { g show "$1:corpus/SOURCES.md" | awk -F'|' -v i="$2" '{x=$2; gsub(/[[:space:]]/,"",x)} x==i {print $3}'; }
bad=""; for id in $F S094 S099; do [ "$(u "$BASE" $id)" = "$(u "$REV" $id)" ] || bad="$bad $id"; done
[ -z "$bad" ] && leg L4-registry-source-cells PASS "13 source cells identical" || leg L4-registry-source-cells FAIL "$bad"

# L5 ledger header exact (K47RP-04, sentinel S-07)
h=$(g show "$REV:corpus/fired-reverify.tsv" | head -n 1)
want=$(printf 'id\turl\tobserved_release\tfetched_at\tcapture_path\tsha256\tbytes\tquote_count\tverdict')
[ "$h" = "$want" ] && leg L5-ledger-header PASS "header exact" || leg L5-ledger-header FAIL "header=[$h]"

# L6 captures are regular blobs first added by REV itself (sentinel S-04 symlinks; critic D-3 date
# authority: the capture's first-appearance commit, not the ledger cell)
bad=""; for id in $F S099; do
  p=.ufo/waves/round-47/capture/$id.body
  mode=$(g ls-tree "$REV" -- "$p" | awk '{print $1}')
  first=$(g log --diff-filter=A --format=%H -- "$p" | tail -n 1)
  [ "$mode" = 100644 ] && [ "$first" = "$(g rev-parse "$REV")" ] || bad="$bad $id:mode=$mode:first=${first:0:8}"
done
ct=$(g show -s --format=%cI "$REV")
[ -z "$bad" ] && leg L6-captures-regular-first-added PASS "12 bodies mode 100644, first added by $REV ($ct)" \
  || leg L6-captures-regular-first-added FAIL "$bad"

# L7 no capture digest occurs among BASE-committed blobs (critic-ceiling amendment A: old bodies)
g ls-tree -r "$BASE" --format='%(objectname)' > "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/k47-base-blobs.$$"
bad=""; for id in $F; do
  ob=$(g rev-parse "$REV:.ufo/waves/round-47/capture/$id.body")
  grep -qx "$ob" "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/k47-base-blobs.$$" && bad="$bad $id"
done
n=$(wc -l < "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/k47-base-blobs.$$"); rm -f "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/k47-base-blobs.$$"
[ -z "$bad" ] && leg L7-not-old-bodies PASS "0/11 capture blobs among $n BASE blobs" || leg L7-not-old-bodies FAIL "$bad"

# L8 independent lane live legs agree by sha256 (K47ReviewerLive 19:34:42-44Z; L1 K2-P captures
# 19:29:56-59Z recorded in this file's sibling l1-live-sha256.txt). A lane seat is not non-author.
bad=""; for id in $F; do
  c=$(g show "$REV:corpus/fired-reverify.tsv" | awk -F'\t' -v i="$id" '$1==i {print $6}')
  r=$(awk -v i="$id" '$1==i {print $2}' "$W/build/K47ReviewerLive-sha256.txt")
  l=$(awk -v i="$id" '$1==i {print $2}' "$W/final/l1-live-sha256.txt")
  [ "$c" = "$r" ] && [ "$c" = "$l" ] || bad="$bad $id"
done
[ -z "$bad" ] && leg L8-live-legs-agree PASS "11/11 ledger sha256 = ReviewerLive = L1 K2-P" || leg L8-live-legs-agree FAIL "$bad"

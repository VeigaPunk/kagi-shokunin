#!/usr/bin/env bash
# K45Sentinel (v2): scope-forgery measurement ON THE CANDIDATE TREE, with each mutant
# commit verified (sha + the mutated line) before the frozen counter is run.
set -u
SCR=/fast/scratch/hyaku/kagi-r45/K45Sentinel
S=$(mktemp -d "$SCR/c1-cand2-XXXXXX") || exit 2
trap 'rm -rf -- "$S"' EXIT
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
CAND=072bb0bc1860fcc33418b659cec0dd40d5c0f944
CLONE="$S/clone"
git clone --quiet --no-hardlinks "$LANE" "$CLONE" || exit 2
cd "$CLONE" || exit 2
t=$(git rev-parse --show-toplevel); [ "$t" = "$CLONE" ] || { echo "NOT-TOPLEVEL $t"; exit 2; }
git -C "$CLONE" checkout --quiet "$CAND" || exit 2
echo "clone HEAD=$(git -C "$CLONE" rev-parse HEAD)"

sed "s|^LANE=.*|LANE=$CLONE|" "$LANE/plans/round-45-c1.sh" > "$S/c1.sh"

for thr in 39 46 90; do
  sed -E "s/-lt [0-9]+ ]/-lt $thr ]/" "$CLONE/corpus/claims-declared.sh" > "$CLONE/corpus/claims-declared.sh.new"
  mv "$CLONE/corpus/claims-declared.sh.new" "$CLONE/corpus/claims-declared.sh"
  git -C "$CLONE" add corpus/claims-declared.sh
  if git -C "$CLONE" -c user.name=s -c user.email=s@invalid commit --quiet -m "mutant thr=$thr" 2>/dev/null; then :; else echo "COMMIT-FAILED thr=$thr"; fi
  REV=$(git -C "$CLONE" rev-parse HEAD)
  MUTLINE=$(git -C "$CLONE" show "$REV:corpus/claims-declared.sh" | grep -n -- "-lt $thr ]" | head -1 | cut -c1-90)
  echo "mutant thr=$thr commit=${REV:0:9} line=[$MUTLINE]"
  echo "   counter: $(bash "$S/c1.sh" "$REV" 2>&1 | tail -1 | cut -c1-230)"
done

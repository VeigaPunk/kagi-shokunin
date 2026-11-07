#!/usr/bin/env bash
# run_one.sh ID -- apply one counter mutant in a minimal scratch repo, run the
# counter-scoped frozen controls against the candidate reference work tree,
# restore the counter's exact bytes, and record everything.
set -u
S=/fast/scratch/hyaku/kagi-r55/R55MutCounters
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
BASE=ebe095857a734caf5efdd7bd776feb22b4e23972
CAND=348aa3b8ea7298aeb2f4d69db321fe827a92ae4f
id=${1:?mutant id}
d=$S/fx/$id
r=$S/receipts/$id.controls.txt
rm -rf -- "$d"
mkdir -p -- "$d/plans" "$S/receipts"
git -C "$d" init -q || exit 3
printf '%s\n' "$LANE/.git/objects" > "$d/.git/objects/info/alternates"
cp "$S/frozen/round-55-c1.sh" "$S/frozen/round-55-c2.sh" "$d/plans/"
case "$id" in
  C1-*) cp "$S/tools/controls-c1-only.sh" "$d/plans/round-55-controls.sh" ;;
  C2-*) cp "$S/tools/controls-c2-only.sh" "$d/plans/round-55-controls.sh" ;;
  *) echo "unknown mutant prefix"; exit 3 ;;
esac
# the fixture repo must be able to answer the counter's BASE archive
if ! git -C "$d" cat-file -e "$BASE^{commit}" 2>/dev/null; then
  echo "FIXTURE-BASE-MISSING $BASE" > "$r"; exit 3
fi
file=$(python3 -I -B -c 'import sys,json
sys.path.insert(0,"'"$S"'/tools"); import mutants
print(mutants.MUTANTS[sys.argv[1]][0])' "$id") || exit 3
python3 -I -B "$S/tools/mutants.py" apply "$d" "$id" > "$S/receipts/$id.mutation.json" 2>&1 || {
  echo "MUTATION-APPLY-FAILED" > "$r"; exit 3; }
{
  echo "MUTANT $id"
  echo "REF $S/repo HEAD $(git -C "$S/repo" rev-parse HEAD)"
  echo "REPO $d"
  echo "MUTATION $(cat "$S/receipts/$id.mutation.json")"
  echo "RUN $(date -Is)"
} > "$r"
HYAKU_SCRATCH="$S" bash "$d/plans/round-55-controls.sh" "$S/repo" >> "$r" 2>&1
rc=$?
echo "exit=$rc" >> "$r"
# restore exact bytes and prove it
cp -- "$S/frozen/$file" "$d/plans/$file"
echo "RESTORE sha_frozen=$(sha256sum "$S/frozen/$file" | cut -d' ' -f1) sha_restored=$(sha256sum "$d/plans/$file" | cut -d' ' -f1)" >> "$r"
echo "DONE $(date -Is)" >> "$r"

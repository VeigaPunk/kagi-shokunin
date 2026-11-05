#!/usr/bin/env bash
# plans/round-46-c1.sh -- round 46 C1 counter (operability: the declared-claim gate's own
# committed --selftest kills the frozen mutants of its round-45 plan-to-manifest leg; closes
# round-45 closure routed item 2 and sentinel S-07 at the gate's self-test, not only in a
# round counter).
#
# Frozen predicate (the same sentence appears in plans/round-46.md section C1):
#   C1_SELFTEST_KILLS: value = KILLED when POSITIVE = 1 and EQUIV = 1 and REAL = 1, else 0;
#   target 3.
#   KILLED   number of mutants M1..M3 below whose `bash <mutant> --selftest` exits non-zero.
#   POSITIVE the unmutated gate's `--selftest` exits 0 and its last line starts
#            `CLAIMS_DECLARED_SELFTEST: PASS`.
#   EQUIV    every equivalent mutant E1..E4 passes its --selftest the same way (E2..E4
#            rewrite the very lines M1..M3 mutate without changing behaviour, so a self-test
#            keyed on those lines' bytes instead of fixture behaviour kills them and scores 0).
#   REAL     `bash corpus/claims-declared.sh` in the measured tree exits 0 and its last line
#            starts `CLAIMS_DECLARED: CLEAN`.
# Mutants (frozen sed programs over corpus/claims-declared.sh of the measured tree; a program
# that leaves the file byte-identical is a SETUP refusal, exit 2, never a kill):
#   E1  s/^# usage:$/# usage (equivalent mutant E1):/                       (comment)
#   E2  `-lt 39 ]; then continue; fi` -> `-le 38 ]; then continue; fi`            (same floor)
#   E3  `echo "MISMATCH $rname $hclaim no-manifest-row"` -> same with ${rname} ${hclaim}
#   E4  `if ! awk -v want="## Round $rname — post-move"` -> same with ${rname}
#   M1  replace the `echo "MISMATCH $rname $hclaim no-manifest-row"` line and the line after
#       it (`bad=$((bad + 1))`) by one `:` line (the plan-to-manifest leg reports nothing;
#       the mutant stays valid bash)
#   M2  floor 39 -> 99 in `-lt 39 ]; then continue; fi` (sentinel S-07 raised floor)
#   M3  `if ! awk -v want="## Round $rname — post-move"` -> `if awk ...` (landed rounds skipped,
#       in-flight rounds checked)
# Input: a revision (git archive of the lane at that revision) or C1_TREE=<dir> (a fixture
# tree, used by the pre-freeze controls only). Output: one line
#   C1_SELFTEST_KILLS: value=V killed=K positive=P equiv=E real=R (rc e1..e4=.. m1..m3=..; ...)
# exit 0 when measured; exit 2 (SETUP line, value never printed) on a bad revision, missing
# gate, unusable scratch or a no-op mutant. Missing producer output never counts as a kill
# or a pass: an empty selftest output fails POSITIVE/EQUIV, and a mutant run that prints
# nothing still counts only by its exit status.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
REV=${1:-}
setup() { echo "C1_SELFTEST_KILLS: SETUP $1"; exit 2; }
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r46/c1.$$
mkdir -p -- "$SCR/t" "$SCR/hs" || setup scratch
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
G=$T/corpus/claims-declared.sh
[ -f "$G" ] || setup missing-gate
export HYAKU_SCRATCH=$SCR/hs

selftest() { # selftest <gate>: prints "<rc> <pass 0|1> <last line>"
  local out rc last pass=0
  out=$(bash "$1" --selftest 2>/dev/null); rc=$?
  last=$(printf '%s\n' "$out" | tail -n 1)
  if [ "$rc" -eq 0 ]; then
    case $last in "CLAIMS_DECLARED_SELFTEST: PASS"*) pass=1 ;; esac
  fi
  printf '%s %s %s\n' "$rc" "$pass" "$last"
}
mutate() { # mutate <name> <sed program> : writes $T/corpus/claims-declared.<name>.sh
  local m=$T/corpus/claims-declared.$1.sh
  sed "$2" "$G" > "$m" || setup "sed-$1"
  if cmp -s "$G" "$m"; then setup "mutant-noop-$1"; fi
}

mutate e1 's/^# usage:$/# usage (equivalent mutant E1):/'
mutate e2 's/-lt 39 \]; then continue; fi/-le 38 ]; then continue; fi/'
mutate e3 's/^      echo "MISMATCH \$rname \$hclaim no-manifest-row"$/      echo "MISMATCH ${rname} ${hclaim} no-manifest-row"/'
mutate e4 's/^  if ! awk -v want="## Round \$rname — post-move"/  if ! awk -v want="## Round ${rname} — post-move"/'
mutate m1 '/^      echo "MISMATCH \$rname \$hclaim no-manifest-row"$/{N;s/.*/      :/;}'
mutate m2 's/-lt 39 \]; then continue; fi/-lt 99 ]; then continue; fi/'
mutate m3 's/^  if ! awk -v want="## Round \$rname — post-move"/  if awk -v want="## Round $rname — post-move"/'

read -r prc POSITIVE plast <<EOF
$(selftest "$G")
EOF
EQUIV=1
rcs=""
for e in e1 e2 e3 e4; do
  read -r erc epass elast <<EOF
$(selftest "$T/corpus/claims-declared.$e.sh")
EOF
  rcs="$rcs $e=$erc"
  [ "$epass" = 1 ] || EQUIV=0
done
KILLED=0
for m in m1 m2 m3; do
  read -r mrc mpass mlast <<EOF
$(selftest "$T/corpus/claims-declared.$m.sh")
EOF
  rcs="$rcs $m=$mrc"
  [ "$mrc" -ne 0 ] && KILLED=$((KILLED + 1))
done
rout=$(cd "$T" && bash corpus/claims-declared.sh 2>/dev/null); rrc=$?
rlast=$(printf '%s\n' "$rout" | tail -n 1)
REAL=0
if [ "$rrc" -eq 0 ]; then
  case $rlast in "CLAIMS_DECLARED: CLEAN"*) REAL=1 ;; esac
fi
VALUE=0
if [ "$POSITIVE" = 1 ] && [ "$EQUIV" = 1 ] && [ "$REAL" = 1 ]; then VALUE=$KILLED; fi
echo "C1_SELFTEST_KILLS: value=$VALUE killed=$KILLED positive=$POSITIVE equiv=$EQUIV real=$REAL (rc$rcs; selftest-rc=$prc selftest-last='$plast'; real-rc=$rrc real-last='$rlast')"
exit 0

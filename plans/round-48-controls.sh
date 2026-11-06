#!/usr/bin/env bash
# plans/round-48-controls.sh — pre-freeze controls for the round-48 counters. Every expected value
# below was written before this runner first executed. Fixtures are built in scratch from the BASE
# tree; fixture commits for C2 live only in a scratch clone (toplevel asserted before any commit).
# Usage: bash plans/round-48-controls.sh <BASE-rev>
# Output: one `CONTROL <id> expect=<e> observed=<o> MATCH|MISMATCH` line each, then
#   CONTROLS: ALL-MATCH|MISMATCH (match=N mismatch=M); exit 0 all match, 1 otherwise, 2 setup.
set -u
[ $# -eq 1 ] || { echo "CONTROLS: SETUP usage"; exit 2; }
BASE=$1
LANE=$(cd "$(dirname "$0")/.." && pwd)
FX="$LANE/.ufo/waves/round-48/controls/fixtures"
SCR="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r48"; mkdir -p "$SCR"
W=$(mktemp -d "$SCR/controls.XXXXXX") || exit 2
trap 'rm -rf -- "$W"' EXIT
C1="$LANE/plans/round-48-c1.sh"
match=0; mis=0
check() { # id expect observed
  if [ "$2" = "$3" ]; then match=$((match+1)); r=MATCH; else mis=$((mis+1)); r=MISMATCH; fi
  echo "CONTROL $1 expect=$2 observed=$3 $r"
}
c1val() { # output -> value=N | SETUP
  case "$1" in *"C1_SOPS_AGE_TRIAL: SETUP"*) echo SETUP ;; *) printf '%s' "$1" | sed -n 's/^C1_SOPS_AGE_TRIAL: value=\([0-9]*\).*/\1/p' ;; esac; }
c2val() { case "$1" in *"C2_CAPABILITY_READINGS: SETUP"*) echo SETUP ;; *) printf '%s' "$1" | sed -n 's/^C2_CAPABILITY_READINGS: value=\([0-9]*\).*/\1/p' ;; esac; }

mktree() { # name -> path of a fresh BASE tree
  mkdir -p "$W/$1" && git -C "$LANE" archive "$BASE" | tar -x -C "$W/$1" && echo "$W/$1"; }
ENTRY=corpus/knowledge/sops-age-key-rotation.md

# ---- C1 ----
o=$(bash "$C1" "$BASE"); check K1-0-do-nothing 0 "$(c1val "$o")"

t=$(mktree p); cp "$FX/ref-sops-age-trial.sh" "$t/corpus/sops-age-trial.sh"; cat "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-P-reference 5 "$(c1val "$o")"

t=$(mktree f1); printf '#!/bin/bash\nfor i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS forged"; done\necho "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0"\n' > "$t/corpus/sops-age-trial.sh"
cat "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-F1-constant-holds 0 "$(c1val "$o")"

t=$(mktree f2); sed 's|^set -u$|set -u\nPATH="/home/vgpnk/.local/bin:$PATH"|' "$FX/ref-sops-age-trial.sh" > "$t/corpus/sops-age-trial.sh"
cat "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-F2-path-bypass 0 "$(c1val "$o")"

t=$(mktree f3); cp "$FX/ref-sops-age-trial.sh" "$t/corpus/sops-age-trial.sh"
o=$(bash "$C1" --tree "$t"); check K1-F3-no-entry-section 0 "$(c1val "$o")"

t=$(mktree f4); printf '#!/bin/bash\nexit 0\n' > "$t/corpus/sops-age-trial.sh"; cat "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-F4-silent-producer SETUP "$(c1val "$o")"

t=$(mktree f5); sed 's|if \[ "$thr" = "2" \] \&\& \[ $arc -ne 0 \] \&\& \[ $brc -ne 0 \] \&\& \[ $abrc -eq 0 \]; then|if [ $abrc -eq 0 ]; then|' "$FX/ref-sops-age-trial.sh" > "$t/corpus/sops-age-trial.sh"
cat "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-F5-weak-T5 4 "$(c1val "$o")"

t=$(mktree f6); cp "$FX/ref-sops-age-trial.sh" "$t/corpus/sops-age-trial.sh"; sed 's/sops 3\.13\.3/sops 3.12.0/g' "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-F6-wrong-version-entry 0 "$(c1val "$o")"

cp /usr/bin/true "$W/fake-sops"; chmod 755 "$W/fake-sops"
o=$(R48_SOPS="$W/fake-sops" bash "$C1" --tree "$W/p"); check K1-F7-unpinned-binary SETUP "$(c1val "$o")"

t=$(mktree f8); sed 's|^holds=0; broken=0; errors=0$|holds=0; broken=0; errors=0\ncat "$W/a.key"|' "$FX/ref-sops-age-trial.sh" > "$t/corpus/sops-age-trial.sh"
cat "$FX/ref-entry-measured.md" >> "$t/$ENTRY"
o=$(bash "$C1" --tree "$t"); check K1-F8-secret-printed 0 "$(c1val "$o")"

# ---- C2 (fixture commits in a scratch clone) ----
D="$W/c2repo"
git clone -q --shared "$LANE" "$D" && git -C "$D" checkout -q --detach "$BASE" || { echo "CONTROLS: SETUP clone"; exit 2; }
[ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ] || { echo "CONTROLS: SETUP toplevel"; exit 2; }
mkdir -p "$D/plans"; cp "$LANE/plans/round-48-c2.sh" "$D/plans/round-48-c2.sh.frozen"
C2="$D/plans/round-48-c2.sh.frozen"
fxc() { # message -> commit hash of the current fixture tree on top of BASE
  git -C "$D" add -A SCORECARD.md >/dev/null 2>&1
  git -C "$D" -c user.name=fixture -c user.email=fixture@scratch.invalid commit -q -m "$1" >/dev/null 2>&1
  git -C "$D" rev-parse HEAD; }
reset_base() { git -C "$D" checkout -q --detach "$BASE" -- 2>/dev/null; git -C "$D" checkout -q --detach "$BASE"; }

o=$(bash "$C2" "$BASE"); check K2-0-do-nothing 3 "$(c2val "$o")"

reset_base; python3 "$FX/c2-fixture.py" reference "$D/SCORECARD.md"; h=$(fxc ref)
o=$(bash "$C2" "$h"); check K2-P-reference 0 "$(c2val "$o")"

reset_base; python3 "$FX/c2-fixture.py" delete "$D/SCORECARD.md"; h=$(fxc delete)
o=$(bash "$C2" "$h"); check K2-F1-delete-pairs 3 "$(c2val "$o")"

reset_base; python3 "$FX/c2-fixture.py" elsewhere "$D/SCORECARD.md"; h=$(fxc elsewhere)
o=$(bash "$C2" "$h"); check K2-F2-readings-outside-section 3 "$(c2val "$o")"

reset_base; python3 "$FX/c2-fixture.py" partial "$D/SCORECARD.md"; h=$(fxc partial)
o=$(bash "$C2" "$h"); check K2-F3-partial 2 "$(c2val "$o")"

reset_base; python3 "$FX/c2-fixture.py" wrongnum "$D/SCORECARD.md"; h=$(fxc wrongnum)
o=$(bash "$C2" "$h"); check K2-F4-wrong-number 1 "$(c2val "$o")"

if [ $mis -eq 0 ]; then echo "CONTROLS: ALL-MATCH (match=$match mismatch=0)"; exit 0; fi
echo "CONTROLS: MISMATCH (match=$match mismatch=$mis)"; exit 1

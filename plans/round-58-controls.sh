#!/usr/bin/env bash
# plans/round-58-controls.sh -- pre-freeze controls for the round-58 counters.
#   usage: bash plans/round-58-controls.sh [REFTREE]     (REFTREE defaults to the lane tree)
# Every control copies the REF tree into scratch, breaks exactly one thing (or none),
# runs the frozen counter on the copy, and compares the reading with the expectation
# written beside it BEFORE the run. The two no-work controls run the counters on the
# claim BASE: they are what a do-nothing round scores.
# Output: one `CONTROL <id> expect=<e> got=<g> MATCH|MISMATCH :: <detail>` line per
#   control and a last line `CONTROLS: match=M mismatch=K`; exit 0 iff K=0.
# The negative controls C1-F1..C1-F8 break one item's substance each; a counter that
#   reads 0 on any of them is vacuous on that item (kill rule K1). C1-F9/F10 and
#   C2-F2/F5/F6/F7 are the fail-closed legs; C2-F8 is the ambient-environment control.
set -u -o pipefail
REPO=$(cd "$(dirname "$0")/.." && pwd -P)
BASE=1b13f5dad921f8901f56d30c428f89614dd74d8a
REF=${1:-$REPO}
REF=$(cd "$REF" && pwd -P)
SCR=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/controls.$$
mkdir -p -- "$SCR" || exit 2
trap 'rm -rf -- "$SCR"' EXIT
export TMPDIR=$SCR
C1="$REPO/plans/round-58-c1.sh"
C2="$REPO/plans/round-58-c2.sh"

copy_tree() { # NAME -> $SCR/NAME
  local n=$1
  mkdir -p "$SCR/$n" || return 1
  ( cd "$REF" && tar --exclude=./.git --exclude=./.jj -cf - . ) | tar -xf - -C "$SCR/$n"
}
base_tree() { # NAME from the claim BASE revision
  local n=$1
  mkdir -p "$SCR/$n" || return 1
  git -C "$REPO" archive "$BASE" | tar -x -C "$SCR/$n"
}
py() { python3 -I -B -c "$@" ; }
sub() { python3 -I -B - "$@" <<'PY'
import sys
p, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(p, encoding="utf-8").read()
assert old in s, "inert edit: pattern absent in " + p
open(p, "w", encoding="utf-8").write(s.replace(old, new, 1))
PY
}
pick1v() { sed -n 's/^C1_ROUTED: value=\([^ ]*\).*/\1/p' | tail -1; }
pick1i() { sed -n "s/^C1_ROUTED:.* \($1\)=\([^ ]*\).*/\2/p" | tail -1; }
pick2v() { sed -n 's/^C2_POLICY_TRIAL: value=\([^ ]*\).*/\1/p' | tail -1; }
M=0; K=0
report() { # ID EXPECT GOT DETAIL
  local got=$3
  if [ "$got" = "$2" ]; then M=$((M+1)); r=MATCH; else K=$((K+1)); r=MISMATCH; fi
  echo "CONTROL $1 expect=$2 got=${got:-none} $r :: $4"
}
run1() { bash "$C1" --tree "$SCR/$1" 2>&1; }
run2() { bash "$C2" --tree "$SCR/$1" 2>&1; }

# ---- two no-work controls: the counters on the claim BASE -------------------
base_tree base-c1
out=$(bash "$C1" "$BASE" 2>&1)
report K1-BASE FAIL "$(printf '%s\n' "$out" | pick1v)" \
  "$(printf '%s\n' "$out" | grep -E '^C1_ROUTED:' | tail -1) :: an unresolved item set cannot clear the guard, so a do-nothing round scores FAIL"
base_tree base-c2
out=$(bash "$C2" "$BASE" 2>&1)
report K2-BASE 0 "$(printf '%s\n' "$out" | pick2v)" \
  "$(printf '%s\n' "$out" | grep -E '^C2_POLICY_TRIAL:' | tail -1) :: the trial does not exist at BASE"

# ---- positive reference: the counters on the tree that carries the work ----
copy_tree ref-c1
out=$(run1 ref-c1)
report K1-REF 0 "$(printf '%s\n' "$out" | pick1v)" "$(printf '%s\n' "$out" | grep -E '^C1_ROUTED:' | tail -1)"
copy_tree ref-c2
out=$(run2 ref-c2)
report K2-REF 5 "$(printf '%s\n' "$out" | pick2v)" "$(printf '%s\n' "$out" | grep -E '^C2_POLICY_TRIAL:' | tail -1)"

# ---- C1-F1..C1-F8: break one item's substance each ------------------------
copy_tree f1; py 'import sys;p=sys.argv[1]+"/LOG.md";s=open(p).read();i=s.find("## Round 57 correction");assert i>0;open(p,"w").write(s[:i])' "$SCR/f1"
out=$(run1 f1); report C1-F1 1 "$(printf '%s\n' "$out" | pick1v)" "I1: the round-57 correction entry removed (i1=$(printf '%s\n' "$out" | pick1i i1))"
copy_tree f2; sub "$SCR/f2/.ufo/waves/round-57/controls/controls-prefreeze-epochC-final.txt" \
  "INSTRUMENT 76e836ee111d60b7cf60007da4b45a102f1d94393f1d83c9de1a32d7cd33b173 plans/round-57.md" \
  "INSTRUMENT 06e836ee111d60b7cf60007da4b45a102f1d94393f1d83c9de1a32d7cd33b173 plans/round-57.md"
out=$(run1 f2); report C1-F2 1 "$(printf '%s\n' "$out" | pick1v)" "I2: one INSTRUMENT pin corrupted (i2=$(printf '%s\n' "$out" | pick1i i2))"
copy_tree f3; sub "$SCR/f3/corpus/lessons/round-57.md" \
  "“This endpoint hashes the given input data with the specified audit device's hash function and salt.”" \
  "“This endpoint hashes any payload with an arbitrary configured device.”"
out=$(run1 f3); report C1-F3 1 "$(printf '%s\n' "$out" | pick1v)" "I3: the S117 quote replaced by a sentence absent from the body (i3=$(printf '%s\n' "$out" | pick1i i3))"
# I4 is the one item whose break removes the challenge's own target class, so the guard
# cannot add +1 on that tree: the reading is FAIL with i4=0 (detection), not a count of 1.
copy_tree f4; sub "$SCR/f4/SCORECARD.md" "the tip count = 120 at the round-58 candidate" "the tip count = 121 at the round-58 candidate"
out=$(run1 f4); report C1-F4 FAIL "$(printf '%s\n' "$out" | pick1v)" "I4: the tip count moved off the measured count (i4=$(printf '%s\n' "$out" | pick1i i4)); the challenge cannot add +1 on an I4-broken tree (named ceiling)"
copy_tree f5; py 'import sys,re;p=sys.argv[1]+"/SKILL.md";s=open(p).read();t=re.sub(r"(?m)^\| current-tense self-description gate.*\n","",s);assert t!=s;open(p,"w").write(t)' "$SCR/f5"
out=$(run1 f5); report C1-F5 1 "$(printf '%s\n' "$out" | pick1v)" "I5: the gate-registry row removed (i5=$(printf '%s\n' "$out" | pick1i i5))"
copy_tree f6; sub "$SCR/f6/corpus/current-claims.py" 'add_argument("--round"' 'add_argument("--round-x"'
out=$(run1 f6); report C1-F6 1 "$(printf '%s\n' "$out" | pick1v)" "I6: --round renamed away (i6=$(printf '%s\n' "$out" | pick1i i6))"
copy_tree f7; sub "$SCR/f7/corpus/lessons/round-57.md" "§Enabling/Disabling audit devices — the live heading" "§Enabling and disabling audit devices"
out=$(run1 f7); report C1-F7 1 "$(printf '%s\n' "$out" | pick1v)" "I7: the pre-round-58 heading restored (i7=$(printf '%s\n' "$out" | pick1i i7))"
copy_tree f8; py 'import sys,re;p=sys.argv[1]+"/corpus/adjacency.tsv";s=open(p).read();t=s.replace("\tSCORECARD.md:70\t","\tSCORECARD.md:1\t",1);assert t!=s,"no basis cell";open(p,"w").write(t)' "$SCR/f8"
out=$(run1 f8); report C1-F8 1 "$(printf '%s\n' "$out" | pick1v)" "I8: a basis line without the ownership token restored (i8=$(printf '%s\n' "$out" | pick1i i8))"
# ---- C1-F9/F10: fail-closed legs -----------------------------------------
copy_tree f9; rm -f "$SCR/f9/LOG.md"
out=$(run1 f9); report C1-F9 FAIL "$(printf '%s\n' "$out" | pick1v)" "I1's input file removed: population drops, guard cannot hold"

# ---- C2-F1..C2-F8 --------------------------------------------------------
copy_tree g1; py 'import sys,re;p=sys.argv[1]+"/corpus/openbao-policy-trial.sh";s=open(p).read();t=s.replace("SH5","SH5X").replace("SH4","SH4X").replace("SH3","SH3X").replace("SH2","SH2X").replace("SH1","SH1X");assert t!=s;open(p,"w").write(t)' "$SCR/g1"
out=$(run2 g1); report C2-F1 0 "$(printf '%s\n' "$out" | pick2v)" "the shim vocabulary renamed away: no shim can flip its test"
copy_tree g2; sub "$SCR/g2/corpus/openbao-policy-trial.sh" 'capok=0; [ "$crc" -eq 0 ] && [ "$caps" = "update" ] && capok=1' 'capok=1'
out=$(run2 g2); report C2-F2 0 "$(printf '%s\n' "$out" | pick2v)" "the caps comparison removed: the wrapper lie leaves T5 HOLDS, so the wrap leg's vector check refuses"
copy_tree g3; py 'import sys;p=sys.argv[1]+"/corpus/openbao-policy-trial.sh";s=open(p).read();t=s.replace("caps=","capsX=").replace("token capabilities","kv get");assert t!=s;open(p,"w").write(t)' "$SCR/g3"
out=$(run2 g3); report C2-F3 0 "$(printf '%s\n' "$out" | pick2v)" "the client-side introspection leg removed: the wrapper lie cannot flip T5"
copy_tree g5; py 'import sys,re;p=sys.argv[1]+"/corpus/openbao-policy-trial.sh";s=open(p).read();i=s.rfind("OPENBAO_POLICY_TRIAL:");j=s.find("\n",i);t=s[:i]+s[j+1:];assert t!=s;open(p,"w").write(t)' "$SCR/g5"
out=$(run2 g5); report C2-F5 0 "$(printf '%s\n' "$out" | pick2v)" "the summary line removed: no parseable final line"
copy_tree g6; py 'import sys;p=sys.argv[1]+"/corpus/openbao-policy-trial.sh";s=open(p).read();t=s.replace("[ \"$SHIM\" = SH3 ]","[ \"$SHIM\" = SH3 -o \"$SHIM\" = SH2 ]",1);assert t!=s;open(p,"w").write(t)' "$SCR/g6"
out=$(run2 g6); report C2-F6 0 "$(printf '%s\n' "$out" | pick2v)" "SH2 flips two tests: the vector comparison must refuse"
out=$(R58_BAO=/bin/true bash "$C2" --tree "$SCR/ref-c2" 2>&1)
got=$(printf '%s\n' "$out" | sed -n 's/^C2_POLICY_TRIAL: SETUP.*/SETUP/p' | tail -1)
report C2-F7 SETUP "$got" "a bao binary that is not the pinned OpenBao 2.7.2"
out=$(BAO_TOKEN=hvs.NOTAREALTOKEN BAO_ADDR=http://127.0.0.1:1 bash "$C2" --tree "$SCR/ref-c2" 2>&1)
report C2-F8 5 "$(printf '%s\n' "$out" | pick2v)" "ambient BAO_TOKEN/BAO_ADDR exported by the caller: every leg runs under env -i, readings unchanged"

echo "CONTROLS: match=$M mismatch=$K"
[ "$K" = 0 ] || exit 1
exit 0

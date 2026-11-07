#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempt6-c2-hardened.txt"
: > "$OUT"
say() { printf '%s\n' "$*" | tee -a "$OUT"; }

# candidate-shaped tree: BASE extraction + the hardened counter bytes
rm -rf "$S/c2h"; cp -a "$S/base" "$S/c2h"
cp -p "$L/plans/round-61-c2.sh" "$S/c2h/plans/round-61-c2.sh"
say "== hardened counter sha: $(sha256sum "$S/c2h/plans/round-61-c2.sh" | cut -d' ' -f1)"

say "== unmutated selftest"
out=$(bash "$S/c2h/plans/round-61-c2.sh" --selftest 2>&1); rc=$?
say "  rc=$rc | $(printf '%s\n' "$out" | grep -E '^C2_SELFTEST:' | tail -1)"

# M-A: BEGIN-DECIDE..END-DECIDE -> "  echo 5"
rm -rf "$S/c2h-ma"; cp -a "$S/c2h" "$S/c2h-ma"
python3 - "$S/c2h-ma/plans/round-61-c2.sh" <<'PY'
import sys
p=sys.argv[1]; d=open(p,encoding="utf-8").read()
b=d.index("# BEGIN-DECIDE"); e=d.index("# END-DECIDE")
d=d[:b]+"# BEGIN-DECIDE\n  echo 5\n"+d[e:]
open(p,"w",encoding="utf-8").write(d)
PY
say "== M-A (BEGIN-DECIDE block -> echo 5) selftest"
out=$(bash "$S/c2h-ma/plans/round-61-c2.sh" --selftest 2>&1); rc=$?
say "  rc=$rc | findings=$(printf '%s\n' "$out" | grep -c '^FINDING') | $(printf '%s\n' "$out" | grep -E '^C2_SELFTEST:' | tail -1)"

# M-B: BEGIN-SHIMS..END-SHIMS -> "  shims_ok=5"
rm -rf "$S/c2h-mb"; cp -a "$S/c2h" "$S/c2h-mb"
python3 - "$S/c2h-mb/plans/round-61-c2.sh" <<'PY'
import sys
p=sys.argv[1]; d=open(p,encoding="utf-8").read()
b=d.index("# BEGIN-SHIMS"); e=d.index("# END-SHIMS")
d=d[:b]+"# BEGIN-SHIMS\n  shims_ok=5\n"+d[e:]
open(p,"w",encoding="utf-8").write(d)
PY
say "== M-B (BEGIN-SHIMS block -> shims_ok=5) selftest"
out=$(bash "$S/c2h-mb/plans/round-61-c2.sh" --selftest 2>&1); rc=$?
say "  rc=$rc | findings=$(printf '%s\n' "$out" | grep -c '^FINDING') | $(printf '%s\n' "$out" | grep -E '^C2_SELFTEST:' | tail -1)"

# G: stub-trial tree (valid sha256, prints nothing) on the hardened counter
say "== G: stub-trial tree"
out=$(bash "$S/c2h/plans/round-61-c2.sh" --tree "$S/stubtree" 2>&1); rc=$?
say "  rc=$rc | $(printf '%s\n' "$out" | grep -E '^C2_SEAL_TRIAL:' | tail -1)"

# K4 positive control: the real trial on the hardened counter
say "== K4: real trial on the hardened counter"
out=$(bash "$S/c2h/plans/round-61-c2.sh" --tree "$S/c2h" 2>&1); rc=$?
say "  rc=$rc | $(printf '%s\n' "$out" | grep -E '^C2_SEAL_TRIAL:' | tail -1)"
say "DONE"

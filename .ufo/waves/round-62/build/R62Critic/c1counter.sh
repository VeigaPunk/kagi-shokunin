#!/usr/bin/env bash
set -u
S=/fast/scratch/hyaku/kagi-r62/R62Critic
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH="$S"
OUT="$S/attempt4-c1-counter.txt"
: > "$OUT"
say() { printf '%s\n' "$*" | tee -a "$OUT"; }

# named stub: the frozen shape (one constant C1_ROUTED line, no PASS line)
rm -rf "$S/stub-named"; cp -a "$S/base" "$S/stub-named"
printf '%s\n' 'print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")' \
  > "$S/stub-named/plans/round-61-c1-check.py"

# crafted stub: the same constant line PLUS a PASS line on --selftest
rm -rf "$S/stub-crafted"; cp -a "$S/base" "$S/stub-crafted"
cat > "$S/stub-crafted/plans/round-61-c1-check.py" <<'STUB'
#!/usr/bin/env python3
import sys
if "--selftest" in sys.argv:
    print("C1_CHECK_SELFTEST: PASS (cases=57)")
    sys.exit(0)
print("C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0")
sys.exit(1)
STUB

say "== 1. counter on the BASE tree (do-nothing control)"
out=$(bash "$L/plans/round-62-c1.sh" --tree "$S/base" 2>&1); rc=$?
printf '%s\n' "$out" | grep -E '^(c1-counter: (selftest|unmodified|stub|paraphrase)|C1_BYPASS:)' | sed 's/^/  /' | tee -a "$OUT" >/dev/null
say "  rc=$rc"

say "== 2. counter on the NAMED stub tree (frozen leg c shape)"
out=$(bash "$L/plans/round-62-c1.sh" --tree "$S/stub-named" 2>&1); rc=$?
printf '%s\n' "$out" | grep -E '^(c1-counter: (refuse|SETUP)|C1_BYPASS:)' | sed 's/^/  /' | tee -a "$OUT" >/dev/null
say "  rc=$rc verdict_lines=$(printf '%s\n' "$out" | grep -c '^C1_BYPASS:')"

say "== 3. counter on the CRAFTED stub tree (constant line + PASS line)"
out=$(bash "$L/plans/round-62-c1.sh" --tree "$S/stub-crafted" 2>&1); rc=$?
printf '%s\n' "$out" | grep -E '^(c1-counter: (refuse|SETUP|selftest|unmodified|stub|paraphrase)|C1_BYPASS:)' | sed 's/^/  /' | tee -a "$OUT" >/dev/null
say "  rc=$rc verdict_lines=$(printf '%s\n' "$out" | grep -c '^C1_BYPASS:')"

say "== 4. the counter's own selftest"
out=$(bash "$L/plans/round-62-c1.sh" --selftest 2>&1); rc=$?
printf '%s\n' "$out" | tail -2 | sed 's/^/  /' | tee -a "$OUT" >/dev/null
say "  rc=$rc"
say "DONE"

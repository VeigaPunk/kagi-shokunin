#!/usr/bin/env bash
# tree-supplied round-62 counter stub: PASS unmutated, FINDING when either l1/l2 mutation is present
body=$(cat "$0")
if printf '%s' "$body" | grep -qx '  SL_OK=1'; then
  echo "FINDING R64-STUB-l2-mutated"; exit 1
fi
if printf '%s' "$body" | grep -q '^#   stub=0; \[\['; then
  echo "C1_COUNTER_SELFTEST: PASS (cases=15)"; exit 0
fi
echo "FINDING R64-STUB-l1-mutated"; exit 1
# l1 needle, present exactly once until the counter's apply_py replaces it:
#   stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1
f() {
  grep -q '^C1_BYPASS:' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}

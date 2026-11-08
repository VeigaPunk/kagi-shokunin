#!/usr/bin/env python3
"""Build the round-64 C2 counter mutants (target: plans/round-64-c2.sh snapshot).

Each mutant is a byte copy with 1..2 unique-match replacements. The pristine
snapshot is /fast/scratch/hyaku/kagi-r64/R64MutC2/pristine/plans/round-64-c2.sh.
"""
import hashlib, os, sys

S = "/fast/scratch/hyaku/kagi-r64/R64MutC2"
SRC = os.path.join(S, "pristine", "plans", "round-64-c2.sh")

REAL_LEG_OLD = """g_c=0; real_attempts=0; real_rc=""; real_field=""
for attempt in 1 2; do
  real_attempts=$attempt
  bash "$TREE/plans/round-62-c2.sh" --tree "$TREE" >"$WORK/gc.$attempt.out" 2>&1
  real_rc=$?
  real_field=$(hardened_field "$WORK/gc.$attempt.out" real)
  if [ "$real_rc" -eq 0 ] && [ "$real_field" = 1 ]; then g_c=1; break; fi
done"""

BATTERY_AFTER = """fi

# l6: the I6 superseded-stamp conjunct dropped."""

MUTANTS = {
 "M1": [('leg_fires "$rc_l1" "$WORK/l1.out" && l1=1', 'leg_fires "$rc_l1" "$WORK/l1.out" && l1=1; l1=1')],
 "M2": [('leg_fires "$rc_l2" "$WORK/l2.out" && l2=1', 'leg_fires "$rc_l2" "$WORK/l2.out" && l2=1; l2=1')],
 "M3": [('  leg_mismatch C1-F8 "$WORK/battery.out" && l4=1\nfi', '  leg_mismatch C1-F8 "$WORK/battery.out" && l4=1\nfi\nl3=1')],
 "M4": [('  leg_mismatch C1-F8 "$WORK/battery.out" && l4=1\nfi', '  leg_mismatch C1-F8 "$WORK/battery.out" && l4=1\nfi\nl4=1')],
 "M5": [('if [ "$l6rc" -ne 0 ] && grep -q \'C1_CHECK_SELFTEST: FAIL\' "$WORK/l6.out"; then l6=1; fi',
         'if [ "$l6rc" -ne 0 ] && grep -q \'C1_CHECK_SELFTEST: FAIL\' "$WORK/l6.out"; then l6=1; fi\nl6=1')],
 "M6": [("killed=$(killed_calc \"$l1\" \"$l2\" \"$l3\" \"$l4\" \"$l6\")", "killed=5")],
 "M7": [("guard=$(guard_calc \"$g_a\" \"$selftest_leg\" \"$real_leg\" \"$g_d\")", "guard=1")],
 "M8": [("terminates=$(terminates_calc $((SECONDS - T0)) \"$BUDGET_S\")", "terminates=1")],
 "M9": [("BOUND=${C2_RECURSION_BOUND:-1}", "BOUND=${C2_RECURSION_BOUND:-0}")],
 "M10": [("BOUND=${C2_RECURSION_BOUND:-1}", "BOUND=1")],
 "M11": [("  battery_run \"$TREE\" \"$WORK/battery.out\" \"$BOUND\"\n  brc=$?",
          "  : # mutant M11: battery delegation skipped\n  brc=0")],
 "M12": [(REAL_LEG_OLD, 'g_c=0; real_attempts=0; real_rc=""; real_field=""\n: # mutant M12: real-trial leg dropped (g_c stays 0)')],
 "M13": [("R63_CONTROLS_FIXTURE_ONLY=1 R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt timeout \"$tmo\" bash",
          "R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt timeout \"$tmo\" bash"),
         ("R63_CONTROLS_FIXTURE_ONLY=1 R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt bash",
          "R63_CONTROLS_RECEIPT=$WORK/battery-receipt.txt bash")],
 "M14": [('[ "$g_e" = 1 ] || selftest_leg=0', ': # mutant M14: g_e conjunct dropped')],
}

def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()

text = open(SRC, encoding="utf-8").read()
print("pristine", sha(SRC), len(text.encode()), "bytes")
ok = True
for name, edits in MUTANTS.items():
    t = text
    okhere = True
    for old, new in edits:
        n = t.count(old)
        if n != 1:
            print(name, "MATCH", n, "FAIL", repr(old[:60]))
            okhere = False
            break
        t = t.replace(old, new)
    if not okhere:
        ok = False
        continue
    d = os.path.join(S, "mut", "c2", name, "plans")
    os.makedirs(d, exist_ok=True)
    dst = os.path.join(d, "round-64-c2.sh")
    open(dst, "w", encoding="utf-8").write(t)
    os.chmod(dst, 0o755)
    print(name, "ok", sha(dst), "delta", len(t.encode()) - len(text.encode()))
sys.exit(0 if ok else 1)

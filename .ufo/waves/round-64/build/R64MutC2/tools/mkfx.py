#!/usr/bin/env python3
"""Build the mutation-test fixture trees A (legs zero) and B (battery+real present).

Both trees are synthetic: every prerequisite the round-64 C2 counter reads is a
stub with the exact needle strings the counter's legs mutate. No lane file is
copied; the stubs are written here from scratch so the detector's baseline is a
known non-target verdict line.
"""
import os, stat

S = "/fast/scratch/hyaku/kagi-r64/R64MutC2"

NEEDLE_L1 = "  stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1"
NEEDLE_L2 = """  grep -q '^C1_BYPASS:' "$dir/run.out" && SL_OK=0
  [[ "$SL_RC" -ne 0 ]] || SL_OK=0
}"""
NEEDLE_L6 = "    ok = len(qualifying) >= 3 and bool(superseded) and not denied"

R62C1 = f"""#!/usr/bin/env bash
# fixture stub: carries the l1/l2 needle bytes; --selftest always PASSes.
set -u
if [ "${{1:-}}" = "--selftest" ]; then
  echo "C1_COUNTER_SELFTEST: PASS (cases=8)"
  exit 0
fi
echo fixture-counter
{NEEDLE_L1}
{NEEDLE_L2}
"""

CHECKER_PASS = f'''#!/usr/bin/env python3
"""fixture checker stub: l6 needle present, selftest PASSes even when mutated."""
import sys
NEEDLE = """{NEEDLE_L6}"""
if "--selftest" in sys.argv:
    print("C1_CHECK_SELFTEST: PASS (cases=91)")
    sys.exit(0)
print("C1_ROUTED: value=0 population=7 i1=1")
'''

CHECKER_FAIL = f'''#!/usr/bin/env python3
"""fixture checker stub: selftest FAILs when the I6 conjunct is dropped."""
import sys
NEEDLE = """{NEEDLE_L6}"""
if "--selftest" in sys.argv:
    if "bool(superseded)" in NEEDLE:
        print("C1_CHECK_SELFTEST: PASS (cases=91)")
        sys.exit(0)
    print("C1_CHECK_SELFTEST: FAIL (cases=91 failed=1 names=i6-superseded-stamp-conjunct-isolated)")
    sys.exit(1)
print("C1_ROUTED: value=0 population=7 i1=1")
'''

BATTERY = """#!/usr/bin/env bash
# fixture battery stub: fixture-only path prints the two mismatch controls; the
# full path re-enters a counter and therefore never returns.
if [ "${1:-}" = "--selftest" ]; then
  echo "CONTROLS_SELFTEST: PASS (cases=11)"
  exit 0
fi
if [ "${R63_CONTROLS_FIXTURE_ONLY:-0}" != "1" ]; then
  sleep 999
fi
echo "CONTROL C1-F8 expect=accepted=10 observed=accepted=0 verdict=mismatch"
echo "CONTROL C2-F6 expect=killed=0 observed=killed=5 verdict=mismatch"
echo "CONTROLS: match=0 mismatch=2"
exit 1
"""

R62C2 = """#!/usr/bin/env bash
# fixture trial stub: the counter parses real=1 from the C2_HARDENED line.
echo "C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)"
exit 0
"""

R62CTL = """#!/usr/bin/env bash
# fixture prior battery stub
echo "CONTROLS_SELFTEST: PASS (cases=16)"
exit 0
"""

R63C2 = """#!/usr/bin/env bash
# fixture round-63 counter stub
if [ "${1:-}" = "--selftest" ]; then
  echo "C2R63_SELFTEST: PASS (cases=13)"
  exit 0
fi
echo "C2_REFUSAL: killed=0 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=1 real=0)"
exit 1
"""

R64C1 = """#!/usr/bin/env bash
# fixture round-64 C1 counter stub
echo "C1_HELDOUT: heldout=8 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)"
exit 1
"""

def write(path, text, mode=0o755):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    os.chmod(path, mode)

R62C1_C = f"""#!/usr/bin/env bash
# fixture stub (tree C): carries the l1/l2 needles; --selftest FAILs with a
# FINDING only when one of those needles has been rewritten.
set -u
if [ "${{1:-}}" = "--selftest" ]; then
  if grep -q '^  stub=1$' "$0" || grep -q '^  SL_OK=1$' "$0"; then
    echo "FINDING FIXTURE-R62C1-mutation-detected"
    echo "C1_COUNTER_SELFTEST: FAIL (cases=8 failed=1)"
    exit 1
  fi
  echo "C1_COUNTER_SELFTEST: PASS (cases=8)"
  exit 0
fi
echo fixture-counter
{NEEDLE_L1}
{NEEDLE_L2}
"""

TREES = {
    "A": (CHECKER_PASS, R62C1),
    "B": (CHECKER_FAIL, R62C1),
    "C": (CHECKER_FAIL, R62C1_C),
}
for fx, (checker, r62c1) in TREES.items():
    root = os.path.join(S, "fx", fx)
    write(os.path.join(root, "plans", "round-62-c1.sh"), r62c1)
    write(os.path.join(root, "plans", "round-61-c1-check.py"), checker, 0o644)
    write(os.path.join(root, "plans", "round-64-c1.sh"), R64C1)
    if fx in ("B", "C"):
        write(os.path.join(root, "plans", "round-63-controls.sh"), BATTERY)
        write(os.path.join(root, "plans", "round-62-c2.sh"), R62C2)
        write(os.path.join(root, "plans", "round-62-controls.sh"), R62CTL)
        write(os.path.join(root, "plans", "round-63-c2.sh"), R63C2)
    print(fx, "built", root)

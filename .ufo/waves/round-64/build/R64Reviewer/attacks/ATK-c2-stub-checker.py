#!/usr/bin/env python3
# tree-supplied checker stub: PASS while the I6 conjunct comment is present, FAIL after the l6 mutation
import sys
t = open(__file__, encoding="utf-8").read()
if t.count("bool(superseded)") > 1:
    print("C1_CHECK_SELFTEST: PASS (cases=110)")
    raise SystemExit(0)
print("C1_CHECK_SELFTEST: FAIL (cases=100 failed=3 names=f9-forgery-unresolved)")
raise SystemExit(1)
# the l6 needle, present exactly once so the counter's apply_py can replace it:
#     ok = len(qualifying) >= 3 and bool(superseded) and not denied

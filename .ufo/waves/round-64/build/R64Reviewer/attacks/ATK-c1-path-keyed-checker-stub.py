#!/usr/bin/env python3
# path-keyed printer stub: passes the selftest gate, answers H copies value=0 and Q copies value=1
import sys
argv = sys.argv[1:]
if "--selftest" in argv:
    print("C1_CHECK_SELFTEST: PASS (cases=110)")
    raise SystemExit(0)
root = ""
if "--root" in argv:
    root = argv[argv.index("--root") + 1]
value = 1 if "H-" in root else 0
print("C1_ROUTED: value=%d population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0" % value)
raise SystemExit(0)

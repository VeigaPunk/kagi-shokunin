#!/usr/bin/env python3
"""C2 leg-level detector harness (scratch only).

usage: c2leg.py COUNTER TREE BASE_DIR LEG SCRATCH
Extracts the embedded python body of COUNTER, imports it, and runs one leg
(leg1|leg2|leg3) against TREE with BASE_DIR as the base tree. Prints
  C2LEG: leg=<L> ok=<0|1> detail=<...>
This is the counter's own leg function on the tested bytes; guard() -- the
expensive full-ledger comparison -- is not run, so the leg's verdict is the
observable (the full counter is used separately when affordable).
"""
import os
import re
import sys

counter, tree, base_dir, leg, scratch = sys.argv[1:6]
text = open(counter, encoding="utf-8").read()
m = re.search(r"exec python3 -I -B - \"\$TREE\" \"\$LANE\" \"\$BASE_TREE\" \"\$SCRATCH\" \"\$SELFTEST\" <<'PY'\n(.*)\nPY\n",
              text, re.S)
assert m, "embedded python body not found"
body = m.group(1)
body = re.sub(r"\nsys\.exit\(main\(\)\)\s*$", "\n", body)
core = os.path.join(os.path.dirname(os.path.abspath(counter)), "c2core_probe.py")
with open(core, "w", encoding="utf-8") as f:
    f.write(body)
sys.path.insert(0, os.path.dirname(core))
sys.argv = ["c2core", os.path.abspath(tree), os.path.abspath(os.getcwd()),
            os.path.abspath(base_dir), scratch, "0"]
import importlib; c = importlib.import_module("c2core_probe")
c._scratch = c._root_scratch(scratch)
fn = getattr(c, leg)
try:
    ok, detail = fn(os.path.abspath(tree), os.path.abspath(base_dir))
except c.SetupError as ex:
    print("C2LEG: leg=%s ok=SETUP detail=%s" % (leg.upper(), ex))
    sys.exit(2)
print("C2LEG: leg=%s ok=%d detail=%s" % (leg.upper(), 1 if ok else 0, detail))
sys.exit(0 if ok else 1)

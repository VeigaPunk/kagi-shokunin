#!/usr/bin/env python3
# F3 (corrected): a selftest line that exits 2 (SETUP) when the gate has lost a line. The
# expected line count is taken from the fixture itself, so the positive control passes and
# only M1 (which removes one line) trips the check.
import importlib.util, os, subprocess

S = os.environ["S"]
LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
os.environ["HYAKU_SCRATCH"] = os.path.join(S, "hs")
os.makedirs(os.environ["HYAKU_SCRATCH"], exist_ok=True)
spec = importlib.util.spec_from_file_location("ctl", LANE + "/plans/round-46-controls.py")
ctl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ctl)
FX = os.path.join(S, "fx")
os.makedirs(FX, exist_ok=True)
d = ctl.tree(FX, "f3-setup-as-kill")
ctl.c1_positive(d)
g = os.path.join(d, "corpus/claims-declared.sh")
PH = "@@LINES@@"
ctl.edit(g, "  cases=0; passed=0\n",
         "  cases=0; passed=0\n  [ \"$(wc -l < \"$GATE_SRC\")\" -eq " + PH + " ] || exit 2\n")
n = len(open(g, encoding="utf-8").read().splitlines())
text = open(g, encoding="utf-8").read().replace(PH, str(n))
open(g, "w", encoding="utf-8").write(text)
env = dict(os.environ, C1_TREE=d)
p = subprocess.run(["bash", LANE + "/plans/round-46-c1.sh"], env=env, capture_output=True, text=True)
print("F3-c1-setup-exit-counts-as-kill\tgate-lines=%d\trc=%d\t%s" % (
    n, p.returncode, (p.stdout.strip().splitlines() or ["<none>"])[-1]))

#!/usr/bin/env python3
"""Independent rebuild of the K1 BASE/F4/F5/F6 controls (review replication)."""
import os
import re
import shutil
import subprocess
import sys

LANE = "/home/vgpnk/Projects/shokunin/kagi-shokunin"
S = "/fast/scratch/hyaku/kagi-r57/R57ReviewC1"
BASE = f"{S}/base"
OUT = f"{S}/k1x"
DRIVER = f"{LANE}/plans/round-57-c1.sh"
CHECK = f"{LANE}/plans/round-57-c1-check.py"


def rd(t, r):
    with open(os.path.join(t, r), encoding="utf-8") as f:
        return f.read()


def wr(t, r, s):
    with open(os.path.join(t, r), "w", encoding="utf-8") as f:
        f.write(s)


def sub(t, r, old, new, n=1):
    s = rd(t, r)
    assert s.count(old) == n, (r, old, s.count(old))
    wr(t, r, s.replace(old, new))


def mk(name):
    d = f"{OUT}/{name}"
    if os.path.exists(d):
        shutil.rmtree(d)
    shutil.copytree(BASE, d, symlinks=True)
    return d


def run(name, d):
    drv = subprocess.run(["bash", DRIVER, "--tree", d], capture_output=True, text=True)
    ver = subprocess.run([sys.executable, "-I", "-B", CHECK, "--root", d, "--verbose"],
                         capture_output=True, text=True)
    stmts = [l for l in ver.stdout.splitlines() if l.startswith("STMT ")]
    last = (drv.stdout.strip().splitlines() or [""])[-1]
    print(f"### {name}\n$ bash plans/round-57-c1.sh --tree {d}\n{last}\n"
          f"driver rc={drv.returncode}\nchecker rc={ver.returncode}\n"
          f"STMT count={len(stmts)}")
    for l in stmts:
        if "MISMATCH" in l or "UNBOUND" in l:
            print("  " + l)
    print("checker tail:", ver.stdout.strip().splitlines()[-1] if ver.stdout.strip() else "")


os.makedirs(OUT, exist_ok=True)
d = mk("base")
run("K1-BASE", d)

d = mk("f4")
sub(d, "SCORECARD.md", "`--selftest` 18 cases", "`--selftest` 20 cases")
sub(d, "LOG.md", "four freeze epochs land", "six freeze epochs land")
sub(d, "corpus/lessons/round-56.md", "Three freeze epochs", "Six freeze epochs")
run("K1-F4", d)

d = mk("f5")
for rel in ("SCORECARD.md", "LOG.md"):
    s = rd(d, rel)
    m = re.search(r"^## Round 56 [^\n]*\n", s, re.M)
    assert m, rel
    n = re.compile(r"^## ", re.M).search(s, m.end())
    wr(d, rel, s[: m.start()] + (s[n.start():] if n else ""))
p = os.path.join(d, "corpus/lessons/round-56.md")
s = rd(d, "corpus/lessons/round-56.md")
wr(d, "corpus/lessons/round-56.md", s[: s.find("## Claims")])
run("K1-F5", d)

d = mk("f6")
sub(d, ".ufo/waves/round-56/controls/controls-prefreeze-epochF.txt",
    "CONTROLS: match=23 mismatch=0", "CONTROLS: match=19 mismatch=0")
run("K1-F6", d)
print("epochF first/last lines:")
lines = rd(d, ".ufo/waves/round-56/controls/controls-prefreeze-epochF.txt").splitlines()
print("  first:", lines[0][:120])
print("  last :", lines[-1][:120])

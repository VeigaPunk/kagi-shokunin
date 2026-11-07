#!/usr/bin/env python3
"""Build the wrapped-continuation attack trees (w1..w5) and the symlink-escape
fixture. Base = trees/bref (the battery's own fixed_tree text). Each fixture
appends ONE Markdown bullet whose first physical line satisfies the item's
selector with the right number and whose continuation line restates the defect.
"""
import os
import shutil
import subprocess

S = "/fast/scratch/hyaku/kagi-r59/R59ReviewerCounters"
BASE = os.path.join(S, "trees", "bref")
LESSON = "corpus/lessons/round-58.md"

CONT = {
    "w1_cont": "- Correction D1 (superseding): Registry 117 → 120 at the candidate.\n"
               "  The operative registry statement is 119 → 120 — that is the figure to use.\n",
    "w2_cont": "- Correction D2 (superseding): `corpus/source-fetches.tsv` added 6 rows.\n"
               "  4 rows is the operative figure, not 6.\n",
    "w3_cont": "- Correction D3 (superseding): `.ufo/waves/round-58/controls/controls-prefreeze.txt` "
               "census is 20 control lines, 9 C1 and 7 C2.\n"
               "  Correction: the census is 21 control lines in total.\n",
    "w4_cont": "- Correction D4 (superseding): `.ufo/waves/round-59/final/citation-gate-r59.txt` "
               "reads unresolved=0.\n"
               "  The committed gate actually reads unresolved=3.\n",
    "w5_cont": "- stale-lane: the round-58 mission ran 101 min and reads progressing.\n"
               "  In fact the duration is 96 min and the row is silent.\n",
}


def mk(name, extra):
    dst = os.path.join(S, "trees", name)
    if os.path.isdir(dst):
        shutil.rmtree(dst)
    subprocess.run(["cp", "-al", BASE, dst], check=True)
    p = os.path.join(dst, LESSON)
    with open(p, encoding="utf-8") as f:
        t = f.read()
    tmp = p + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(t + extra)
    os.replace(tmp, p)
    print(name)


for n, e in CONT.items():
    mk(n, e)

# symlink-escape fixture: the lesson is a symlink to a canary OUTSIDE the tree
sym = os.path.join(S, "trees", "sym")
canary = os.path.join(S, "canary.md")
if os.path.isdir(sym):
    shutil.rmtree(sym)
os.makedirs(os.path.join(sym, "corpus", "lessons"))
with open(os.path.join(BASE, LESSON), encoding="utf-8") as f:
    text = f.read()
with open(canary, "w", encoding="utf-8") as f:
    f.write(text)
os.symlink(canary, os.path.join(sym, LESSON))
subprocess.run(["cp", "-al", os.path.join(BASE, "plans"), sym], check=True)
subprocess.run(["cp", "-al", os.path.join(BASE, ".ufo"), sym], check=True)
subprocess.run(["cp", "-al", os.path.join(BASE, "corpus", "lessons",
                                          "round-58-verifier-spotcheck.md"),
                os.path.join(sym, "corpus", "lessons")], check=True)
print("sym")

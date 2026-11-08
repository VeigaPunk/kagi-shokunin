#!/usr/bin/env python3
"""Derive the final mutation site lines and byte deltas from the frozen snapshots.

Rewrites mutdesc.json's site/delta fields (keeping the human descriptions)."""
import importlib.util, json, os, sys

S = "/fast/scratch/hyaku/kagi-r64/R64MutC2"

def load_mutants(path, cut_marker):
    src = open(path).read()
    ns = {"__name__": "notmain"}
    exec(compile(src.split(cut_marker)[0], path, "exec"), ns)
    return ns["MUTANTS"]

def sites(text, edits):
    lines = []
    for old, _ in edits:
        i = text.find(old)
        if i < 0:
            return None
        lines.append(str(text[:i].count("\n") + 1))
    return ",".join(lines)

desc = json.load(open(os.path.join(S, "mutdesc.json")))
c2 = open(os.path.join(S, "pristine", "plans", "round-64-c2.sh")).read()
ctl = open(os.path.join(S, "pristine", "plans", "round-64-controls.sh")).read()
m2 = load_mutants(os.path.join(S, "mkc2.py"), "def sha(p):")
mctl = load_mutants(os.path.join(S, "mkctl.py"), "def sha(p):")
for prefix, muts, text, fname in (("M", m2, c2, "plans/round-64-c2.sh"),
                                  ("B", mctl, ctl, "plans/round-64-controls.sh")):
    for name, edits in muts.items():
        if name not in desc:
            continue
        if isinstance(edits[0], str):
            edits = [tuple(edits)]
        where = sites(text, edits)
        delta = sum(len(new.encode()) - len(old.encode()) for old, new in edits)
        desc[name][1] = "%s:%s" % (fname, where if where else "MISS")
        desc[name][2] = "%+d B" % delta
json.dump(desc, open(os.path.join(S, "mutdesc.json"), "w"), indent=1)
print("updated mutdesc.json")
for k in sorted(desc):
    print(k, desc[k][1], desc[k][2])

#!/usr/bin/env python3
"""Summarise the detector table: baseline vs mutant, killed when any detector differs."""
import sys, json

path = sys.argv[1] if len(sys.argv) > 1 else "/fast/scratch/hyaku/kagi-r64/R64MutC2/logs/table.tsv"
rows = {}
order = []
for ln in open(path):
    ln = ln.rstrip("\n")
    if not ln:
        continue
    parts = ln.split("\t")
    if len(parts) != 4:
        continue
    name, tag, rc, line = parts
    rc = rc.split("=", 1)[1]
    if name not in rows:
        rows[name] = {}
        order.append(name)
    rows[name][tag] = (rc, line)

base = rows.get("pristine", {})
tags = sorted({k for v in rows.values() for k in v})
killed = survived = 0
for name in order:
    if name == "pristine":
        continue
    common = [t for t in tags if t in rows[name] and t in base]
    diffs = [t for t in common if rows[name][t] != base[t]]
    verdict = "KILLED" if diffs else "SURVIVED"
    if diffs:
        killed += 1
    else:
        survived += 1
    print(f"{name}\t{verdict}\tdiff={','.join(diffs) or '-'}")
    for t in common:
        r = rows[name].get(t)
        b = base.get(t)
        mark = " *" if r != b else "  "
        print(f"   {t}{mark} mutant[rc={r[0]} {r[1]}]")
print(f"TOTAL killed={killed} survived={survived}")

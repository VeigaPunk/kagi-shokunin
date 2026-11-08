#!/usr/bin/env python3
"""Assemble the final detector table from the sweep + the g_e detector rows."""
import os, sys

S = "/fast/scratch/hyaku/kagi-r64/R64MutC2"
base = os.path.join(S, "logs", "table_final.tsv")
m14 = os.path.join(S, "logs", "table_M14.tsv")
fxd = os.path.join(S, "logs", "table_fxD.tsv")
out = os.path.join(S, "logs", "table_all.tsv")

rows = []
for p in (base, m14, fxd):
    if not os.path.exists(p):
        continue
    for ln in open(p):
        ln = ln.rstrip("\n")
        if ln:
            rows.append(ln)
# dedupe identical (name, tag) keeping the last occurrence
seen = {}
for ln in rows:
    p = ln.split("\t")
    if len(p) != 4:
        continue
    seen[(p[0], p[1])] = ln
order = []
for ln in rows:
    p = ln.split("\t")
    if len(p) == 4 and (p[0], p[1]) not in order:
        order.append((p[0], p[1]))
with open(out, "w") as f:
    for k in order:
        f.write(seen[k] + "\n")
print("wrote", out, len(order), "rows")

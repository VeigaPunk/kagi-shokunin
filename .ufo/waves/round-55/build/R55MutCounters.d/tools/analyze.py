#!/usr/bin/env python3
"""Summarise mutant receipts against the pristine baseline receipt."""
import glob
import json
import os
import re
import sys

S = "/fast/scratch/hyaku/kagi-r55/R55MutCounters"
BASE = os.path.join(S, "receipts", "00-baseline-controls.txt")
CTRL = re.compile(r"^CONTROL (\S+) expect=(\S+) got=(\S+) (MATCH|MISMATCH)", re.M)


def parse(path):
    text = open(path, encoding="utf-8", errors="replace").read()
    controls = {m.group(1): (m.group(2), m.group(3), m.group(4))
                for m in CTRL.finditer(text)}
    exit_m = re.search(r"^exit=(\d+)$", text, re.M)
    mut = re.search(r"^MUTATION (\{.*\})$", text, re.M)
    restore = re.search(r"^RESTORE (.*)$", text, re.M)
    return {"controls": controls,
            "exit": int(exit_m.group(1)) if exit_m else None,
            "mutation": json.loads(mut.group(1)) if mut else None,
            "restore": restore.group(1) if restore else None,
            "status": "SETUP" if not controls else "RAN"}


base = parse(BASE)
print("baseline controls:", len(base["controls"]), "all-match:",
      all(v[2] == "MATCH" for v in base["controls"].values()))
rows = []
for path in sorted(glob.glob(os.path.join(S, "receipts", "*.controls.txt"))):
    mid = os.path.basename(path)[: -len(".controls.txt")]
    if mid.startswith("00-"):
        continue
    r = parse(path)
    k = "K1-" if mid.startswith("C1") else "K2-"
    scoped = {c: v for c, v in base["controls"].items() if c.startswith(k)}
    flipped = []
    for cid, (exp, got, res) in r["controls"].items():
        b = scoped.get(cid)
        if b is None or got != b[1]:
            flipped.append((cid, b[1] if b else "?", got, res))
    missing = [c for c in scoped if c not in r["controls"]]
    verdict = "KILLED" if flipped else ("SURVIVED" if not missing else "INCONCLUSIVE")
    rows.append({"id": mid, "verdict": verdict, "exit": r["exit"],
                 "mutation": r["mutation"], "flipped": flipped,
                 "missing": missing, "restore": r["restore"],
                 "status": r["status"]})
for r in rows:
    print(json.dumps(r))
k = sum(1 for r in rows if r["verdict"] == "KILLED")
s = sum(1 for r in rows if r["verdict"] == "SURVIVED")
i = sum(1 for r in rows if r["verdict"] == "INCONCLUSIVE")
print(f"TOTAL={len(rows)} KILLED={k} SURVIVED={s} INCONCLUSIVE={i}")
json.dump({"baseline_ok": all(v[2] == "MATCH" for v in base["controls"].values()),
           "rows": rows}, open(os.path.join(S, "receipts", "analysis.json"), "w"),
          indent=1)

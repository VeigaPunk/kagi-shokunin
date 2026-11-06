#!/usr/bin/env python3
"""M49-2 fix check: does 'every report ends SEAT-STATUS: complete' hold?

Reads a build-results.json and the directory of seat reports it names. The claim
is measured as written: the last non-empty line of every seat report is exactly
`SEAT-STATUS: complete`; the output-string form is reported beside it.

usage: m49-2-seat-status.py --results <build-results.json> --reports <dir>
  FLAG  — the round-48 evidence: the literal ends 5/13 reports (4/13 outputs)
  CLEAN — a report set where every report ends with the literal
"""
import argparse
import json
import os
import sys

ap = argparse.ArgumentParser()
ap.add_argument("--results", required=True)
ap.add_argument("--reports", required=True)
a = ap.parse_args()

data = json.load(open(a.results, encoding="utf-8"))
res = data["results"]
n = len(res)
out_lit, md_lit, missing = [], [], []
for r in res:
    name = r["name"]
    if "SEAT-STATUS: complete" in json.dumps(r.get("output", "")):
        out_lit.append(name)
    f = os.path.join(a.reports, name + ".md")
    if not os.path.exists(f):
        missing.append(name)
        continue
    lines = [l for l in open(f, encoding="utf-8").read().splitlines() if l.strip()]
    last = lines[-1].strip() if lines else ""
    if last == "SEAT-STATUS: complete":
        md_lit.append(name)

print(f"SEATS {n}")
print(f"OUTPUT_LITERAL {len(out_lit)}/{n} {' '.join(out_lit)}")
print(f"REPORT_ENDS_LITERAL {len(md_lit)}/{n} {' '.join(md_lit)}")
print(f"REPORTS_MISSING {len(missing)} {' '.join(missing)}")
if md_lit and len(md_lit) == n and not missing:
    print("VERDICT: CLEAN (every report ends with the literal)")
    sys.exit(0)
print(
    "VERDICT: FLAG (claim 'every report ends SEAT-STATUS: complete' is false: "
    f"{len(md_lit)}/{n} reports end with the literal; {len(out_lit)}/{n} outputs contain it)"
)
sys.exit(1)

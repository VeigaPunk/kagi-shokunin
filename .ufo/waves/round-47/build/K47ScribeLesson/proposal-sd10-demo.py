#!/usr/bin/env python3
"""proposal-sd10 — demonstration only (draft for corus/self-description-sweep.sh SD10).

Predicate SD10: every `(A -> B cases)` self-description tuple written in a
`## Round <N> — post-move` row of SCORECARD.md must have B equal to the case
count asserted by the gate script named on the same row (`-eq N` on the
`"$cases"` guard line).  A tuple on a line that a later `supersedes
SCORECARD.md:<line>` marker names is exempt (append-only errata).

Reads bytes only; runs no gate. Exit 0 CLEAN n=0 / exit 1 MISMATCH / exit 2 SETUP.
"""
import os
import re
import sys

root = sys.argv[1] if len(sys.argv) > 1 else "."
score = os.path.join(root, "SCORECARD.md")
if not os.path.isfile(score):
    print("SD10: SETUP no SCORECARD.md under root")
    sys.exit(2)

lines = open(score, encoding="utf-8", errors="replace").read().splitlines()

# lines exempted by an appended erratum: "supersedes SCORECARD.md:<n>"
exempt = set()
for ln in lines:
    for m in re.finditer(r"supersedes SCORECARD\.md:(\d+)", ln):
        exempt.add(int(m.group(1)))

TUPLE = re.compile(r"\((\d+)\s*→\s*(\d+)\s+cases\)")
SCRIPT = re.compile(r"`?(corpus/[A-Za-z0-9._-]+\.(?:sh|py))`?")

section = None
hits = []
for i, ln in enumerate(lines, 1):
    if ln.startswith("## "):
        section = ln
        continue
    if not (section and "— post-move" in section):
        continue
    if not ln.startswith("|"):
        continue
    t = TUPLE.search(ln)
    if not t:
        continue
    s = SCRIPT.search(ln)
    if not s or i in exempt:
        continue
    path = os.path.join(root, s.group(1))
    if not os.path.isfile(path):
        hits.append(f"MISMATCH SD10 SCORECARD.md:{i} names {s.group(1)}, which does not exist")
        continue
    body = open(path, encoding="utf-8", errors="replace").read()
    guard = re.search(r'"\$cases"\s+-eq\s+(\d+)', body) or re.search(r"cases\"\s+-eq\s+(\d+)", body)
    if not guard:
        hits.append(f"MISMATCH SD10 SCORECARD.md:{i} cannot read a case-count guard from {s.group(1)}")
        continue
    want = int(guard.group(1))
    said = int(t.group(2))
    if want != said:
        hits.append(
            f"MISMATCH SD10 SCORECARD.md:{i} says (… → {said} cases) but "
            f"{s.group(1)} asserts $cases -eq {want}"
        )

for h in hits:
    print(h)
if hits:
    print(f"SD10: MISMATCH n={len(hits)}")
    sys.exit(1)
print("SD10: CLEAN n=0")

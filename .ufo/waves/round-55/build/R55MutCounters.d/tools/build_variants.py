#!/usr/bin/env python3
"""Build counter-scoped copies of the frozen controls script.

Only structural change: the unused counter's control block is removed so a
mutant of counter X is exercised by all X controls and none of the other
counter's setup work. Semantics of the kept block are untouched.
"""
import sys

SRC = sys.argv[1]
OUTDIR = sys.argv[2]
text = open(SRC, encoding="utf-8").read()
lines = text.splitlines(keepends=True)
i1 = next(i for i, l in enumerate(lines) if l.startswith("# ---------------- C1"))
i2 = next(i for i, l in enumerate(lines) if l.startswith("# ---------------- C2"))
i3 = next(i for i, l in enumerate(lines) if l.startswith('echo "CONTROLS: match='))
header, c1, c2, footer = lines[:i1], lines[i1:i2], lines[i2:i3], lines[i3:]

open(f"{OUTDIR}/controls-c1-only.sh", "w", encoding="utf-8").write(
    "".join(header + c1 + footer))
open(f"{OUTDIR}/controls-c2-only.sh", "w", encoding="utf-8").write(
    "".join(header + ['mk_ref ref\n'] + c2 + footer))
print("c1-only controls:", sum(len(x) for x in (header, c1, footer)) and "written")
print("c2-only controls: written")

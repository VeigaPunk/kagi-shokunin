#!/usr/bin/env python3
"""M49-3 fix check: does a lesson's stated quote word count equal `wc -w`?

Counting rule (stated in the lesson erratum): the quote is the exact text between
the straight quotes after `Located quote (N words):`; its word count is the number
of whitespace-delimited tokens that `wc -w` prints for it. A punctuation-only
token (e.g. `·` in the S103 page title) counts as a word; nothing is stripped.

usage: m49-3-quote-counts.py <lesson.md>
  FLAG  — round-48.md: S103 stated 8 / wc -w 6; S104 stated 12 / wc -w 13
  CLEAN — a lesson whose stated counts equal wc -w
"""
import re
import subprocess
import sys

rx = re.compile(r'Located quote \((\d+) words?\): "([^"]+)"')
path = sys.argv[1]
rows = bad = 0
for i, line in enumerate(open(path, encoding="utf-8"), 1):
    m = rx.search(line)
    if not m:
        continue
    rows += 1
    stated = int(m.group(1))
    q = m.group(2)
    wc = int(
        subprocess.run(["wc", "-w"], input=q.encode(), stdout=subprocess.PIPE, check=True)
        .stdout.split()[0]
    )
    status = "OK" if wc == stated else "MISMATCH"
    if wc != stated:
        bad += 1
    print(f"LINE {i} stated={stated} wc_w={wc} {status} quote={q!r}")
print(f"QUOTES {rows} MISMATCHES {bad}")
if bad:
    print("VERDICT: FLAG (stated count != wc -w)")
    sys.exit(1)
print("VERDICT: CLEAN (every stated count equals wc -w)")
sys.exit(0)

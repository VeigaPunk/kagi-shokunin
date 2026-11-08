#!/usr/bin/env python3
"""eval-legs.py RECEIPTSDIR — score mutants against the six caught legs.

repoint→digest, truncate→bytes, delete→missing, absolute→outside-root,
escape→outside-root (the `..` leg with a byte-identical body outside), quote→
quote-not-located.  A leg is caught iff rc=1, verdict FAILED, captures line
FAILED, and the expected `FINDING SC_CAPTURE id=S113 <reason>` is present.
"""
import glob
import os
import re
import sys

LEGS = [("repoint", "capture-digest-mismatch"),
        ("truncate", "capture-bytes-mismatch"),
        ("delete", "capture-missing"),
        ("absolute", "capture-outside-root"),
        ("escape", "capture-outside-root"),
        ("quote", "quote-not-located")]
FIND = re.compile(r"^FINDING SC_CAPTURE id=(S[0-9]{3,}) (\S+)$")
root = sys.argv[1]
print("mutant\tselftest\tcaught/6\tlegs")
for d in sorted(glob.glob(os.path.join(root, "M*"))):
    name = os.path.basename(d)
    st = open(os.path.join(d, "selftest.txt")).read().splitlines()
    st_line = next((l for l in reversed(st) if "SOURCES_CENSUS_SELFTEST" in l), "?")
    st_ok = "PASS" in st_line
    caught, detail = 0, []
    for tree, want in LEGS:
        txt = open(os.path.join(d, tree + ".txt")).read().splitlines()
        rc = int(next(l[3:] for l in reversed(txt) if l.startswith("rc=")))
        verdict = next((l for l in reversed(txt) if l.startswith("SOURCES_CENSUS:")), "")
        caps = next((l for l in reversed(txt) if l.startswith("SOURCES_CAPTURES:")), "")
        have = any(m.group(1) == "S113" and m.group(2) == want
                   for m in (FIND.match(l) for l in txt) if m)
        ok = (rc == 1 and verdict.startswith("SOURCES_CENSUS: FAILED")
              and caps.startswith("SOURCES_CAPTURES: FAILED") and have)
        caught += 1 if ok else 0
        detail.append(f"{tree}={'K' if ok else 's'}")
    print(f"{name}\tselftest={'PASS' if st_ok else 'FAIL'}\t{caught}/6\t{' '.join(detail)}")

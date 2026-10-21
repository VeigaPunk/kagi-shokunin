#!/usr/bin/env python3
"""FObsHuge: graft the CANDIDATE's selftest() onto BASE's code and run it.

Claim under test (corpus/lessons/round-28.md): the new selftest cases "each
fails on BASE code". If BASE's code + the candidate's selftest harness reports
PASS, the new cases are vacuous and the C1 rule is not load-bearing.

Only selftest() (and the helper it needs) are taken from the candidate; every
other line of code stays at BASE.
"""
import re
import shutil
import subprocess
import sys
from pathlib import Path

base = Path(sys.argv[1]).resolve()      # exported BASE tree
cand = Path(sys.argv[2]).resolve()      # exported candidate tree
work = Path(sys.argv[3]).resolve()
work.mkdir(parents=True, exist_ok=True)
tree = work / "graft"
if tree.exists():
    shutil.rmtree(tree)
shutil.copytree(base, tree)

base_code = (base / "corpus" / "release-clock.py").read_text(encoding="utf-8")
cand_code = (cand / "corpus" / "release-clock.py").read_text(encoding="utf-8")


def grab(text, name):
    start = text.index("def %s(" % name)
    # find the next top-level def/class after it
    rest = text[start:]
    m = re.search(r"\n(?=(?:def |class |[A-Z_]+ = ))", rest[1:])
    end = start + 1 + (m.start() if m else len(rest) - 1)
    return text[start:end]


grafted = base_code
for name in ("selftest",):
    block = grab(cand_code, name)
    old = grab(base_code, name)
    grafted = grafted.replace(old, block)

# the candidate selftest may call helpers that do not exist at BASE
missing = [n for n in ("non_canonical_version", "version_order", "newest_stable",
                       "derived_anchor_bound", "NON_CANONICAL_PREFIX",
                       "VERSION_COMPONENT_MAX_DIGITS")
           if n in block and ("def %s(" % n) not in base_code and
           ("%s = " % n) not in base_code]
print("helpers referenced by the candidate selftest but absent at BASE:", missing)

(tree / "corpus" / "release-clock.py").write_text(grafted, encoding="utf-8")
proc = subprocess.run(["python3", "-I", "-B", "corpus/release-clock.py", "--selftest"],
                      cwd=str(tree), text=True, capture_output=True, timeout=180)
print("exit=%d" % proc.returncode)
print("stdout(last 12):")
for line in proc.stdout.splitlines()[-12:]:
    print("  " + line[:220])
print("stderr tail:", proc.stderr.splitlines()[-3:])

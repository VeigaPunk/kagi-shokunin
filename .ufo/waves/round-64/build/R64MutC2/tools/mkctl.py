#!/usr/bin/env python3
"""Build round-64-controls.sh mutants from the 7c247aea snapshot (unique-match edits)."""
import hashlib, os

S = "/fast/scratch/hyaku/kagi-r64/R64MutC2"
SRC = os.path.join(S, "pristine", "plans", "round-64-controls.sh")

B1_OLD = """  probe_counters   # one unmutated run per counter, shared by NOWORK and REAL
  ctrl_c1_f9
  ctrl_c2_f7
  ctrl_c2_bound
  ctrl_c1_nowork
  ctrl_c2_nowork
  ctrl_c1_real
  ctrl_c2_real
  ctrl_prior
"""
B1_NEW = """  : # mutant B1: main() control list emptied
"""

B2_OLD = """  local out rc line tmo=${R64_BOUND_TIMEOUT:-240}
  out=$(C2_RECURSION_BOUND=0 timeout "$tmo" bash "$C2_INSTR" --tree "$CAND" 2>&1); rc=$?
"""
B2_NEW = """  report "C2-BOUND" "$expect" "mutant-forced" "match" "mutant B2: control forced to match"
  return
  local out rc line tmo=${R64_BOUND_TIMEOUT:-240}
  out=$(C2_RECURSION_BOUND=0 timeout "$tmo" bash "$C2_INSTR" --tree "$CAND" 2>&1); rc=$?
"""

B3_OLD = '    out=$(cd "$snap" && R63_CONTROLS_FIXTURE_ONLY=1 timeout 600 bash "plans/round-63-controls.sh" "$snap" 2>&1); rc=$?\n'
B3_NEW = '    out=$(cd "$snap" && timeout 600 bash "plans/round-63-controls.sh" "$snap" 2>&1); rc=$?\n'

MUTANTS = {"B1": (B1_OLD, B1_NEW), "B2": (B2_OLD, B2_NEW), "B3": (B3_OLD, B3_NEW)}

def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()

text = open(SRC, encoding="utf-8").read()
print("pristine", sha(SRC), len(text.encode()), "bytes")
for name, (old, new) in MUTANTS.items():
    n = text.count(old)
    if n != 1:
        print(name, "MATCH", n, "FAIL")
        continue
    d = os.path.join(S, "mut", "controls", name, "plans")
    os.makedirs(d, exist_ok=True)
    dst = os.path.join(d, "round-64-controls.sh")
    out = text.replace(old, new)
    open(dst, "w", encoding="utf-8").write(out)
    os.chmod(dst, 0o755)
    print(name, "ok sha", sha(dst), "delta", len(out.encode()) - len(text.encode()), "bytes")

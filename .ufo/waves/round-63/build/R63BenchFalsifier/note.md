# Amendment 59 falsification bench (L1 bench task, 2026-11-07 02:14Z)

NOT an attack seat in w1-results.json. This note is the evidence record for the
L1's own adversarial bench used to verdict C1/C2 in claim-falsification.tsv,
so that the gate's attack-seat coverage (reviewer, critic, mutation-tester,
sentinel, connector) is matched by benchged counterexamples, not by trust.

Method (each bench run is a fresh copy; anchors occur exactly once; counters run
on copies, never the lane tree):
 1. Worst fabrication a printer-stub could produce is the constant `C1_RESIDUAL:
    accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1
    para=1 stub=1 chal=1)` stub measured at BASE (plans/round-63-controls.sh
    `C1_STUB_LINE`). The claim counter's canonical reading on a working tree is
    `.ufo/waves/round-63/final/c1-residual.txt` (guard=1 at candidate time).
 2. Every bench copy REPLACES one leg-bearing line of the counter with a
    `const:` stub and re-runs the counter. The claim counter is instrumented
    at `plans/round-63-c1.sh` (C1) and `plans/round-63-c2.sh` (C2).
 3. Falsifies-wording is used only when a bench fabricated copy passes the
    counter AND claims the frozen target (accepted=0/rejected=0 for C1,
    killed=5 for C2) under the claim's wording. Otherwise neutral (no breach
    of the wording was exhibited).

Candidate guard legs are listed in `plans/round-63.md` (Amendment A3 item 1:
checker challenge `chal`).

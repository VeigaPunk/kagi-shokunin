# R57MutChecker — epoch-B addendum (declared before any epoch-B battery run)

Lane HEAD moved from 7aa1f47 (epoch A freeze) to 03cbf65 (epoch B, commit message:
"round-57: freeze epoch B — C2 counter adopts the lane TRIAL convention (A1) and the
measured default-refusal/flag enable path (A2); plan predicate and 11-control battery
re-run"). Epoch-B instrument hashes are recorded in out/frozenB.sha256.

Diff vs epoch A (out/controls-A-to-B.diff):
- plans/round-57-c1-check.py  IDENTICAL (19d75337...)
- plans/round-57-c1.sh        IDENTICAL (3104b06f...)
- plans/round-57-c2.sh        changed (3de6b4de... -> 140a8f2b...)
- plans/round-57-controls.sh  changed (6796ae70... -> 09f334cb...), C1 section byte-identical;
  the three C2 expectations become K2-BASE 0, K2-STUB 0, K2-MOCK 0 (epoch A had K2-MOCK 5).
- plans/round-57.md           changed (5773c1a4... -> b130bb83...)

Re-declared epoch-B predictions for the same ten mutants: the eight C1 rows are unchanged
from EXPECTATIONS.md (271062ea...); every C2 row is 0/0/0 because the C2 controls do not
depend on the C1 checker. Predicted survivors/kills unchanged:
survivors M2,M5,M7,M8,M9; kills M1,M3,M4,M6,M10.
Supplementary: M8b row C1 = 4 3 3 3 1 FAIL 7 4, C2 = 0 0 0, KILLED; S2s all-MATCH
(SURVIVED); M2S2 only K1-F5 mismatches (0 vs FAIL), KILLED.

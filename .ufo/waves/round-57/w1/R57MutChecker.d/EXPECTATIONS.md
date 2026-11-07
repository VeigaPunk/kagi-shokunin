# R57MutChecker — PRE-RUN expectation matrix (written before any mutant battery run)

Revision facts
- Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin
- Audited tree: BASE 1cda9e7ae4767b4133e283bfbc08266d4c86362d (git archive, pristine)
- Freeze revision carrying the instruments: HEAD 7aa1f4726e1f6bcdc8411d1a8b21828d49785173
- Frozen checker sha256: 19d75337ce37259b08eaa8b960eedddac68bec70ed4eab3f55f9d621e142f72c
- Frozen c1 counter sha256: 3104b06f5bfaef77745bd0e5726d4e3ac86c471ff61eef2cc298ad21fee90601
- Frozen controls sha256: 6796ae7040b4956d28b9c71772c24c9ba0d4298e21e86f9f13dbff38e693ce41
- Harness: per-mutant copy of round-57-controls.sh (REPO pinned to the lane, C1 pointed at
  mut/<M>/plans/round-57-c1.sh); each runner copy resolves CHECK to mut/<M>/plans/round-57-c1-check.py.
- Control order (11): K1-BASE K1-F1 K1-F2 K1-F3 K1-F4 K1-F5 K1-F6 K1-F7 K2-BASE K2-STUB K2-MOCK.
- M0 = byte-identical checker copy (harness fidelity; must reproduce the frozen 11 MATCH row).

Pristine (M0) expected from the frozen controls: 3 2 2 2 0 FAIL 6 3 0 0 5
Populations expected: BASE/F1/F2/F3/F4/F6/F7 = 16, F5 = 1.

Derivation anchors (pristine --verbose, BASE tree): 16 statements = SCORECARD:3 match(receipt F) +
SCORECARD:7 cases18 + pop10/10 + clocks10 + LOG:1 epochs4 + LOG:3 five nearest-epoch matches
(16,20,21,22,23) + LESSON:5 match(receipt F) + LESSON:9 cases20 x2 + epochs3 + clocks10.
Authorities: cases=20, receipts B16 C20 D21 E22 F23, epochs=6, clocks=10.

## Predicted readings (value field of C1_CURRENT / C2_AUDIT_TRIAL)

| mutant | BASE | F1 | F2 | F3 | F4 | F5 | F6 | F7 | K2-BASE | K2-STUB | K2-MOCK | predicted verdict |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 value ignores mismatches | 0 | 0 | 0 | 0 | 0 | FAIL | 0 | 0 | 0 | 0 | 5 | KILLED |
| M2 guard floor 8->0 (checker) | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 5 | SURVIVED |
| M3 receipt authority ignored | 3 | 2 | 2 | 2 | 0 | FAIL | 4 | 3 | 0 | 0 | 5 | KILLED |
| M4 epoch authority = stated | 1 | 0 | 1 | 1 | 0 | FAIL | 4 | 1 | 0 | 0 | 5 | KILLED |
| M5 clocks authority hardcoded 10 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 5 | SURVIVED |
| M6 nearest-epoch pairing removed | 8 | 7 | 7 | 7 | 5 | FAIL | 10 | 8 | 0 | 0 | 5 | KILLED |
| M7 missing surface reads clean | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 5 | SURVIVED |
| M8 N/N MATCH not counted as pop | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 5 | SURVIVED |
| M9 selftest case authority = 20 | 3 | 2 | 2 | 2 | 0 | FAIL | 6 | 3 | 0 | 0 | 5 | SURVIVED |
| M10 value always 0 | 0 | 0 | 0 | 0 | 0 | FAIL | 0 | 0 | 0 | 0 | 5 | KILLED |

Predicted offending controls (first mismatch is enough to kill):
- M1: K1-BASE groups 0 vs 3; also F1,F2,F3,F6,F7. F4 (0) and F5 (FAIL) predicted MATCH.
- M2: none. Checker prints value=0 population=1 guard=1 on F5, but the frozen shell re-applies
  `P -ge 8` and prints FAIL, so the reading is unchanged: predicted masked.
- M3: F6 only (4 vs 6): the two receipt-path statements become self-authorising, the nearest-epoch
  F statement still compares 23 vs 19.
- M4: BASE/F1/F2/F3/F6/F7; F4 (0) and F5 (FAIL) MATCH.
- M5: none; no control edits corpus/recheck-captures.tsv.
- M6: BASE/F1/F2/F3/F4/F6/F7 (five unbound nearest-epoch statements).
- M7: none; no control deletes a surface file (K1-F5 deletes sections, files stay present).
- M8: none; population 14 (>=8) at populated controls, F5 population 1, value unchanged.
- M9: none; no control edits corpus/recheck-replay.py.
- M10: same reading set as M1 on this battery (the guard=0 branch is shell-masked).
- Predicted populations: M8 = 14 at populated controls, 1 at F5; all others as pristine.

Predicted survivors: M2, M5, M7, M8, M9. Predicted kills: M1, M3, M4, M6, M10.
Predicted indistinguishable pair: M1 vs M10 (identical 11-control signature).

## Supplementary probes (not part of the 10x11 matrix; declared here too)

| probe | predicted |
|---|---|
| M2 liveness: fold-removed (F5) tree, raw checker | pristine `value=FAIL population=1 guard=0` vs M2 `value=0 population=1 guard=1` |
| S2s (shell floor 8->0 alone) 11 controls | same as pristine: SURVIVED |
| M2S2 (checker floor 0 + shell floor 0) 11 controls | F5 reads 0 vs FAIL: KILLED by exactly K1-F5 |
| M5 liveness: manifest minus one data row | pristine value 6 vs M5 value 3 (3 clocks/pop statements unbound from authority change) |
| M7 liveness: delete LOG.md | pristine `value=FAIL population=0` vs M7 `value=0 population=16` |
| M8 liveness: SCORECARD `10/10 MATCH` -> `9/10 MATCH` | pristine 4 vs M8 3 |
| M8b fall-through: whole pop block deleted, 11 controls | `10 MATCH` re-enters MATCH_RE unbound: predicted row 4 3 3 3 1 FAIL 7 4 0 0 5, KILLED |
| M9 liveness: recheck-replay.py replaced by `PASS (19 cases)` stub | pristine 5 vs M9 3 |

Hash of this predeclaration is recorded in the run log before the first battery run.

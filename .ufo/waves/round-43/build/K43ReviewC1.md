# K43ReviewC1 — scoped findings (round 43, claim C1 attacks, pre-measurement)

Full detail: `.ufo/waves/round-43/build/K43ReviewC1/attacks.md`; receipts `receipts/`, drivers +
fixture gates `scripts/` beside it. Sandbox clone at `dd6ccb9` verified (`rev-parse --show-toplevel`
= sandbox `work`); lane untouched (read-only git only); no pacman, no tool installs (none needed).

## Verdicts

1. **Six-key gate vs new counter — NOT-DEFECT, prediction (6) confirmed.** Built the exact declared
   ceiling shape (basename-keyed, exact frozen tokens F1–F6, accepts P0); `EXPECT_JOURNAL=<my6>
   bash plans/round-43-c1.sh` at dd6ccb9 → **6** (rc 0). Honest matrix re-derived on the same clone:
   real 6, K1 0, K3 0, fakeC 5, blankets 0/0 — matches every committed control measured at 5f3566c.
   The 6-key answer-key gate reaching the target is the named ceiling (routed 6), not a defect.
2. **F6 id choice (R11-03) — NOT-DEFECT, choice not special.** R11-03 present in base 6cc8850 and
   P0 6f1588c (row `bash corpus/surface-census.sh --selftest` / `^SELFTEST: PASS \(16 cases\)`
   identical at base and HEAD), literal occurrences in round-40 and round-41 journals = 0/0; both
   journals migrate the same six ids, R11-03 not among them. The gate's `DELETED` class never reads
   command/expect cells and the counter never executes commands; 79 ids satisfy the same
   preconditions, so the id is arbitrary. No weakening interaction with C3 kill rule (c) (that
   re-runs the command against the lane, not the fixture).
3. **Counter mutants outside the frozen battery — NOT-DEFECT; two survivors named as ceilings.**
   x5 (`grep -qxF`→`grep -q`): byte-identical to the honest counter on the entire frozen matrix incl.
   blankets and m3/m5 composites — the exact-line token match is unpinned. x9 (missing-gate branch
   `echo 0`→`echo 6`): matrix unchanged, but a missing gate now prints the target 6 where the honest
   counter fail-closes 0 — the predicate's missing-gate clause is control-unexercised. Killed by
   measurement: x1 (`echo "$n"`→`echo 6`, caught by kill rule (b) via fakeC 6 ≠ 5; blanket-accept
   drifts 0→6), x2 (dropped n-increment → 0 everywhere, fails (a)), x3 (inverted guard polarity →
   real 0, K1 6, fails (a)+(b)).
4. **Before-state immutability — NOT-DEFECT with one measurement note.** Ledger ids identical at
   6cc8850 / 6f1588c / HEAD: **86 = 86 = 86**, set-diffs empty, none removed. The literal
   `diff --quiet 5142b52 HEAD -- plans/round-42-c1.sh` returns rc=1 only because 5142b52 (round-41
   predeclaration) predates the file; from its creation commit 98dd4de the bytes never moved
   (blob `068a0b2773b2…` at 98dd4de and HEAD; 0 touching commits; 98dd4de→5f3566c and
   5f3566c→HEAD diffs clean). Gate bytes 5f3566c→HEAD clean (kill clause (d)); counter absent at
   BASE (cat-file rc=128) — no-work control holds. The 5142b52 anchor in the assignment is a rev
   mis-specification, not lane drift.
5. **Axis fit — NOT-DEFECT, calibration confirmed.** The moved readings are the instrument's own
   negative controls (0/3 → 3/3 broken-shape rejection) over synthetic scratch fixtures; the lane
   ledger and gate bytes are frozen; the 5→6 real-gate move is population coverage, not a freshness
   or operability property. Fits the calibration axis under the fleet's frozen definitions.

## Residual risk

- 6-key ceiling open by design (declared + routed 6).
- x5/x9 widen the declared "battery covers guard and token drops only" ceiling; closable later by a
  token-mode probe and a missing-gate probe.
- Blanket receipts are in the frozen matrix but not in kill-rule letters (a)–(e); no admission gap
  was exercised this round (x1 caught via fakeC).
- Not re-measured (out of seat scope): full controls runner, C2/C3 receipts.

SEAT-STATUS: complete

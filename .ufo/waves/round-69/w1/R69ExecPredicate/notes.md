# R69ExecPredicate — D8 predicate floor repair

- Change: `predicate_ok` in `plans/round-68-c1.sh` gains the frozen
  population floors `verified >= 37 and col15 >= 32` (plans/round-68.md
  §C1 kill rules: missed if `verified < 37` or `col15 < 32`; A1.2 gives
  the 37/32 reading and 38/33 as the final candidate reading).
- Selftest cases added beside `predicate-full`/`predicate-caught5`/
  `predicate-guard0`/`predicate-defect`:
  `predicate-subfloor = not predicate_ok(36, 31, 6, 1, 0)`,
  `predicate-floor-edge = predicate_ok(37, 32, 6, 1, 0)`,
  `predicate-floor-col15 = not predicate_ok(38, 31, 6, 1, 0)`.
- Header amendment comment names round 69, defect D8
  (corpus/lessons/round-68-verifier-spotcheck.md §7 item 8), the old
  body (`guard == 1 and caught == 6 and defects == 0`), the new body,
  and the fact that the round-68 C1 reading (38/33) still passes.
- No other behavior or output line changed (see diff.txt).
- Predicate spot-checked truth table: 38/33→True, 37/32→True,
  36/31→False, 38/31→False.
- Selftest: candidate `C1_VERIFIED_SELFTEST: PASS (62 cases)`,
  BASE (archive of 264917aa) `C1_VERIFIED_SELFTEST: PASS (59 cases)`,
  so N_cand = N_base + 3 (three new cases; spec expected +1 — the
  spec text said "so the L1 can verify N_cand = N_base + 1" but the
  seat spec adds three cases, so the true delta is +3; either way
  the candidate case count strictly exceeds BASE and the BASE run
  still passes its own pre-fix predicate).
- Tooling: none installed. No pacman transaction.

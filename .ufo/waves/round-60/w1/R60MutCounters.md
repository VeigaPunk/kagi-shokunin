# R60MutCounters — wave-1 findings (kagi round 60, attempt 1)

Seat: mutation-tester. Target: find a false green the C1 checker or the C2 counter accepts,
and test the trial's own falsifiers. Instruments were read only; every mutant is a byte copy
under scratch. Full table, exact edits and readings:
`.ufo/waves/round-60/build/R60MutCounters/mutants.md`; raw matrix outputs and the probed
instrument bytes: `.../build/R60MutCounters/raw/` (`SHA256SUMS` there).

Probed bytes: checker `52d4fd5c…` (§A5+§A6), counter `a6fc9825…`, trial `49ea928f…`,
driver `c11da5c6…`; `bao` v2.7.2 `9c5f3628…` (matches the round-57 pin). The checker and
trial moved during the wave (`9eb98716→268b27cb→52d4fd5c`, `bd2d6647→a228e312→49ea928f`);
all recorded readings are on the final bytes.

**MUTANTS: total=16 killed=9 survived=7**

## Killed (the instrument's own detector fires)

| id | instrument | detector that killed it |
|---|---|---|
| C1-M1 item1 always resolves | checker | `--selftest` 43/46 (`i1-later-restatement-in-block`, `challenge-plus1-fires-with-unresolved`, `evaluate-guard-good-tree`) |
| C1-M2 item2 resolves on any non-empty lesson | checker | `--selftest` 43/46 (`i2-false-substance-32`, `i2-misplaced-correction-fails`, `i2-later-wrong-restatement`) |
| C1-M3 population=7 while i6 is not evaluated | checker | `--selftest` aborts `KeyError: 'i6'`, rc 1, no PASS line |
| C1-M4a guard=1 without running the challenge | checker | `--selftest` 43/46 (all three guard cases) |
| C1-M6 I6 revision value not compared | checker | `--selftest` 45/46 (`i6-wrong-hash-stated`) |
| C2-M1 any shim vector accepted | counter | shipped `C2-F6` observes 5 where it expects `<5` |
| C2-M3 missing `--selftest` accepted | counter | shipped `C2-F3` observes 5 where it expects `<5` |
| T-M1 SH1 flips two tests | trial | `--selftest` `FINDING F-SHIM-MATRIX`, rc 1 |
| T-M2 BROKEN mapped to exit 0 | trial | `--selftest` `FINDING F-RCFOR-BROKEN`, rc 1 |

## Survivors — routed defects (each with a proposed kill)

1. **C1-M4b — the GUARD's printer-stub clause is vacuous.** The stub prints `value=0` and the
   expected value is `count+1 ≥ 1`, so `stub_fails` is always True; deleting the stub leg is
   behaviourally identical (readings identical, `--selftest` PASS 46). *Kill:* make the stub
   print the expected value (or inject `--expect`) and require it to fail; otherwise the
   frozen GUARD's third clause discriminates nothing. Planner-owned (frozen predicate).
2. **C1-M5s — fail-open case-count derivation.** `derive_selftest_cases` may read the count
   from the lesson when the receipt is missing: `nosel` tree reads `value=1 i2=0` clean and
   `value=0 i2=1` mutated, `--selftest` PASS 46. *Kill:* keep `LookupError` fail-closed; add
   selftest case `i2-selftest-receipt-missing` and battery control C1-F9 (remove the receipt
   → diagnostic 1).
3. **C2-M2 — one real run counted as two.** With `real_ok` OR-ed over the two runs and the
   per-run summary loop relaxed, a trial that fails one of its two real runs scores 5
   (`f4-single-run`: clean 0, mutant 5). The shipped `C2-F4` reads 0 on the mutant because its
   wrapper also refuses the `none` and `ambient` legs, so the `real2` conjunct is never
   isolated. *Kill:* C2-F4 must count only the two real runs (exclude the no-bao leg by
   `command -v bao` and the ambient leg by `BAO_ADDR`) and assert each run's vector and
   summary.
4. **C2-M4 — `error=1` summary accepted.** `error1-summary`: clean 0, mutant 5. *Kill:* add
   C2-F9 — a summary reading `HOLDS holds=5 broken=0 error=1` must read 0.
5. **C2-M5 — no-bao PATH scored.** `fake-no-bao` (a shape-keyed trial that prints HOLDS with
   no `bao`): clean 0, mutant 5. `C2-F2` tests the trial, not the counter's `none` conjunct.
   *Kill:* add C2-F10 — the counter must read 0 on that trial.
6. **C2-M6 — secret-shaped output accepted.** `secret-shape` (a deliberately fake
   `hvs.NOTAREALTOKEN…` line): clean 0 (`secret=0`), mutant 5. *Kill:* add C2-F11 — a trial
   that prints an `hvs.`-shaped line must read 0.
7. **T-M3 — a `--selftest` that asserts nothing still passes.** Body replaced by
   `echo "APPROLE_SELFTEST: PASS (cases=42)"; return 0`: clean PASS (45), mutant PASS (42),
   and the clean counter on that trial reads `value=5`. *Kill:* the counter should run the
   trial's `--selftest` on a copy carrying one defined mutation (the checker's I7 leg-C
   pattern) and require a non-zero exit with a named finding; a trial cannot detect its own
   gutting.

## Instrument defect found without a mutation (routed; already fixed)

**C1-X1 — I1 was existential over the correction block.** On the pre-§A5 checker
(`9eb98716`), an all-resolved tree plus a later in-block `results=15 dead=1` line read
`value=0 i1=1`, where the plan's C1-F1 requires 1 (the battery's own C1-F1 fixture could not
fire). §A5 item 1 (last statement wins) fixes it; on the current bytes both `brk-i1a`
(append at EOF) and `brk-i1i` (in-block) read `value=1 i1=0` — verified.

## Not constructible

The assigned mutant *"a `git show` fallback that reads the working tree instead of the
revision"* has no target: no C1 item derives from a named revision
(`grep -nE 'git (show|diff|cat-file|archive)'` matches only the docstring and a fixture
string; `--repo` is accepted but unused). The closest class — a self-referential, fail-open
derivation — is survivor 2.

## Calibration notes

- **Discarded first C2 matrix.** A peer deleted `${HYAKU_SCRATCH}/kagi-r60/R60ExecCounterC2`
  at ~15:45–15:47 while the matrix was in flight; legs lost their scratch mid-run (empty
  vectors, 2–9 s runs, `pass=0`). The matrix was discarded and re-run under an isolated
  `HYAKU_SCRATCH` (`…/R60MutCounters/hs`); all C2 rows are from the isolated run. The counter's
  per-run scratch is seat-constant (`…/R60ExecCounterC2/c2-counter.$$`) — a cleanup race
  class worth a lane note.
- **C2-M2 first build** was neutralised by the untouched per-run summary loop; the recorded
  mutant carries both hunks (one behaviour).
- **Crash-as-kill:** C1-M3 is killed by an uncaught `KeyError` rather than a named case; it
  fails loudly, but the selftest would be more operable with `res_bad.get("i6")`.
- **Tooling:** no installs or upgrades were needed; `bao` v2.7.2 was already present and its
  sha256 matches the pin. No pacman transaction was run.

SEAT-STATUS: complete

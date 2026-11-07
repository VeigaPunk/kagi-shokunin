# R59MutCounters — seat report (kagi round 59, attempt 1)

Assignment: mutation-test the round-59 C1 checker and C2 counter on scratch copies,
read-only on the lane. Deliverable: `.ufo/waves/round-59/build/R59MutCounters/mutants.md`
(18 mutants, exact hunks in `diffs/`, raw receipts in `raw/`, `runs3/`, `fastruns2/`).

Instruments mutated (final bytes): `plans/round-59-c1-check.py`
`6844c1d4…a7743`, `plans/round-59-c2.sh` `454a4177…525c`, and the trial
`corpus/openbao-transit-trial.sh` `e11e98f6…3e01` for the clean-room mutant. Detector:
`plans/round-59-controls.sh`, final revision `b3b49291…fcf6` (commit `a0c77ec`), whose
pristine reading is `CONTROLS: match=20 mismatch=0` (committed receipt
`.ufo/waves/round-59/controls/controls-prefreeze.txt`; independently reproduced in
`build/R59MutCounters/raw/baseline5.out`, rc 0).

## Verdicts — 8 killed, 10 survived

Killed: M01 (== → != in I1), M02 (I2 always FAIL), M03 (guard hardcoded 1), M04
(last-occurrence → first-occurrence), N01 (shim vector accepts any), N06 (value hardcoded
5), N07 (clean-room check removed), N09 (value fixed at 0). Each is killed by a green
control named in `mutants.md` §2 (e.g. M03 by `K1-BASE-GUARD`, `C1-F6`, `C1-F7`; N01 by
`C2-F6`; N09 by `C2-F8`).

Survivors, the control each walks past, and the overclaim it would license:

1. **M05 — I1 missing-line default.** Passes all 12 C1 controls. A tree whose
   `Registry N → M at the candidate` line is deleted reads `value=0` (pristine: 1; probe
   P1). Overclaim: "I1 is resolved and re-checkable" when the statement is absent — a
   record can drop the correction and still pass. No control deletes only that line.
2. **M06 — challenge copies the measured tree in place.** Passes all 12. The fixture
   lesson sha256 changes (`9665e153…` → `b501aef1…`; the last `117 → 120` becomes
   `117 → 121`) while the checker prints `value=0 guard=1` (P2). Overclaim: "QM74 holds /
   the guard works on an isolated copy"; this is the round-58 M58-3 defect class and no
   control hashes the fixture.
3. **M07 — missing input line returns SKIP.** Passes all 12. On a lesson-less tree it
   prints `population=4 i1=x … value=FAIL` vs pristine `population=5 i1=0 … value=FAIL`
   (P3). Overclaim: "all five items were evaluated / population=5"; the value stays
   fail-closed, so this is a contract-shape gap, not a false green.
4. **M08 — I3 checks only the total count.** Passes all 12. A D3 line with
   `20 control lines, 8 C1 and 8 C2` reads `value=0` (pristine 1; P4). Overclaim: "all
   three counts are checked"; only the total is, because C1-F3 only breaks the total.
5. **M09 — internal printer-stub leg hardcoded True.** Passes all 12. The clause is
   satisfied by construction (the internal stub prints `value=0`, expected is
   `count+1 ≥ 1`), so this mutant is inert; overclaim: "the guard proves a printer stub
   fails" when no stub printing the expected value is tested.
6. **N02 — `pass` counts printed T-lines.** Passes all 11 C2 controls. On a transcript
   with `T1..T5 BROKEN` it prints `pass=5` while `value=0` (P5). Overclaim: reading the
   receipt's `pass=P` field as "P tests passed".
7. **N03 — secret scan removed.** Passes all 11. A trial emitting `hvs.…` on stderr reads
   `value=5 secret=1` (pristine 0/0; P6). Overclaim: kill rule K3 ("a secret-shaped string
   in any receipt voids the claim"); the battery has no secret fixture.
8. **N04 — `real2` dropped from `real_ok`.** Passes all 11 (low materiality). On a
   single-run trial `real=1` but `value=0` because `clean_ok` still reads CLEANROOM in
   real2's output (P7). Overclaim: "two independent runs" — the clause is enforced by an
   incidental conjunct, not by `real_ok`.
9. **N05 — no-bao leg dropped.** Passes all 11. A trial that fakes HOLDS when `bao` is
   absent scores `value=5 none=1` (pristine 0/0; P8). Overclaim: kill rule K1; the
   battery's only no-bao check is trial-level (`C2-F2`).
10. **N08 — clean-room leg reuses the first server.** No control detects it; the counter
    on that trial reads `value=5 … cleanroom=1` (P9: 2 `bao server -dev` starts pristine
    vs 1 mutant; both print `CLEANROOM HOLDS`). Overclaim: "the clean-room leg is a second,
    independent server" — the declared K4 ceiling; receipts/probes must carry it.

## Detector defects found during the wave (all fixed in the final bytes)

- `5f6c576f`: `C1-F7` unsatisfiable (stub-as-checker compared to `FAIL`) and `C2-F2` sed
  never matched the prefixed trial line → pristine `match=18 mismatch=2`.
- `bd5993c4`: `C2-F2` fixed; `C1-F7` invoked the Python checker with `bash` → empty
  reading → pristine `match=19 mismatch=1`.
- `b3b49291` (frozen, committed): both fixed; pristine `match=20 mismatch=0`. The final
  verdicts above were re-measured on these bytes; the instruments are byte-identical
  across the revisions, so the verdicts are revision-invariant. Remaining coverage gaps are
  listed in `mutants.md` §5 (items 4-11).
- The L1's freeze message quoted a battery sha256 tail that does not verify; the committed
  blob and the receipt both carry `b3b49291bdd3c7e1787ea55a47b0ee1e8d91f102ba0ecdff14d805ff2416fcf6`.

## Evidence

Scratch work only; the lane was written only under
`.ufo/waves/round-59/build/R59MutCounters/`. Every mutant tree was restored to exact
pristine bytes (`restored.txt` = `RESTORATION: exact`). No tool installs.

SEAT-STATUS: complete

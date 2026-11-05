# K40MutGates — round 40 mutation report

Candidate `cb3f642479a09644a03874909bb7e44b52697a8d`; BASE for controls `f687504767ce9ed56b848dfde83e03a1ec6cedd3`.
Full receipts, exact outputs and mutant scripts: `.ufo/waves/round-40/build/K40MutGates/mutants.md` and `mutants/`.
Lane tree not written; scratch deleted at finish. Tools installed: none.

## Milestone: frozen counters at the candidate

Reproduced at the candidate (scratch copy, exact commands in `mutants.md` §0):
- C1 `bash plans/round-40-c1.sh` → `0` (rc 0, target 0). Verify shows none of the six debt ids on any FAIL/STALE/MISSING/MISSING-ID line.
- C2 `bash plans/round-40-c2.sh` → `3` (rc 0, target 3).
- C3 `bash plans/round-40-c3.sh` → `2` (rc 0, target 2).
No counter was falsified at the candidate value. Each counter has at least one assigned mutant it does not catch (below).

## Gates (anchor-pins.sh, claims-declared.sh)

Ten mutants, all run through their own `--selftest` and against the candidate real tree.
- CAUGHT by selftest (8 mutants): anchor dup, shape, schema, no-final-newline, constant-CLEAN; claims dup-row, fence, padded-cell, constant-CLEAN. Exact selftest verdicts are in `mutants.md` §1.
- SURVIVED selftest: `cd-nowindow` (claims-declared tag count without the section window). Selftest prints `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`. A fixture where `[C1]` appears only in the round-89 section gives real `MISMATCH 90 C1 tagged-rows-0` (rc 1) and mutant `CLEAN (claims=1)` (rc 0). On the candidate real tree the mutant gives four false MISMATCH lines (rc 1), so it is visible only as a false red.
- Real-tree note: the gate defects are absent from the candidate tree, so their only detector is the selftest; a selftest regression would be silent on the real tree.

## Counters (battery = frozen `plans/round-40-controls.sh` on a scratch BASE)

- CAUGHT by battery: `c2-const3` (3 vs expected 0/1/1), `c3-const2` (2 vs 0; 1 vs 0), `c1-echo0` (0 vs 6 at BASE).
- SURVIVED all frozen controls:
  - `c2-nosha` (capture-sha check dropped): `c2_nowork 0`, `c2_positive_pin 1`, `c2_forge_rows 1`. Probe: one byte appended to S095.body → real `2`, mutant `3`.
  - `c2-noquote` (quote-location check dropped): same three controls match. Probe: quote changed in the row → real `2`, mutant `3`.
  - `c3-noselftest` (selftest execution removed): `c3_nowork 0`, `c3_forge_missing_gate 0` match; the `c3_selftest_*` controls test the gates, not the counter. Probe: anchor gate replaced by a failing one → real `1`, mutant `2`.
  - `c1-echo6` (constant 6): matches `c1_nowork 6`; no constant-6 control exists. At the candidate it is caught only by the landing target (6 ≠ 0).
- `c1-echo0` at the candidate prints exactly the honest value 0, so the landing target cannot catch it; only the pre-freeze `c1_nowork` does, and that control is not re-run at landing.

## Surviving defects recorded (what would catch each)

1. S-1 (claims-declared window): add a selftest case, tag only in a previous round's section, expect `tagged-rows-0`.
2. S-2 (C2 sha): control `c2_tampered_body`, one byte appended to a committed capture, expect `2`.
3. S-3 (C2 quote): control `c2_absent_quote`, row quote changed with sha intact, expect `2`.
4. S-4 (C3 selftest): control `c3_broken_selftest`, a registered gate whose selftest fails, expect `1`.
5. S-5 (C1 echo 0): a landing-time integer check against an independent count of the six ids' non-PASS verify lines.
6. S-6 (C1 echo 6): control `c1_mutant_six`, constant 6 against landing target 0.
7. S-7 (latent C1 population defect, found by reading the counter): the id match is `grep -q " $id "`, which requires a trailing space. Verify prints ids at end-of-line (e.g. `MISSING-ID corpus/lessons/round-37.md:7 R36-1`). Probe: `MISSING-ID … R13-01` as last token → rc 1 (not counted); `FAIL R13-01 …` → rc 0. Not triggered at the candidate (no six-id line exists). Would be caught by a control whose verify fixture ends a six-id MISSING-ID line, expecting 1.

## Observations (not mutants)

- O1 (freshness): at cb3f642 the stamps are stale. `corpus/stamps.tsv` records laneguard.sh as `7ca9fcabb7c4…`; the committed file is `99eeb50a9083…` (archive and `git show` agree). `verify` prints `STALE` for eight stamped files and ends `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`, exit 2. The C1 population excludes these by design.
- O2 (calibration ceiling): `plans/round-40-c1.sh` refuses only when no `CLAIM_LEDGER:` line exists; it does not check verify's verdict or exit code, so it still prints an integer under POLICY/rc 2.

## Checks for the main agent

- Re-run stamp regeneration review for O1 before closing any claim that cites `verify` as clean.
- Consider the S-1..S-7 controls above before counting the battery as complete; none were added (frozen controls are not amended in this seat).
- Scratch `/fast/scratch/hyaku/kagi-r40/K40MutGates` removed at finish. Receipts kept under `.ufo/waves/round-40/build/K40MutGates/`.

## Process notes

- Two foreground calls (C1 counter 330 s, ledger verify 330 s) were moved by the harness to system background jobs after 60 s; I did not spawn, poll, or sleep on them.
- No subagents, commits, pushes, or lane git mutations. Git calls in the lane were read-only (`rev-parse`, `archive`, `cat-file`, `show`, `branch --show-current`).

# K41MutGates — round-41 mutation-tester findings

Prepared the C1/C2 mutation runners for the L1 to run after landing. This seat did NOT run any
mutant against the lane tree and did not edit the lane.

## Deliverables (this wave dir)

- `build/K41MutGates/run-mutants.sh` — executable. `run-mutants.sh <LANE> [c1|c2|both]`.
  Gate read from `<LANE>/corpus/expect-journal.sh`; counters `<LANE>/plans/round-41-c{1,2}.sh`;
  candidate paragraph `<LANE>/corpus/rendered-text-v1.py` (`Sources (` paragraph). Judges each
  mutant with `EXPECT_JOURNAL=<mutant>` (target 4) or `RTV1=<mutant>` (target 3) bash counter;
  killed = reading not at target. Fail-closed exit 2 when gate or paragraph missing. Writes only
  under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r41/K41MutGates/mut-run.<pid>` (never /tmp),
  deleted on exit. Baseline discipline: non-target baseline → INCONCLUSIVE, nothing judged.
  C1 mutants (11): drop R1; drop each of the three R2 checks; drop R3; downgrade R4 to refusal;
  always exit 0 on refusals; print CLEAN on violations; first-violation-only; accept any journal
  filename not ending .json; ignore journal ids absent from the candidate ledger. C2 mutants (7):
  drop each cited id (data-driven); cite S027; split the quote across two lines; drop the quote;
  module-level syntax break (selftest path dead).
- `build/K41MutGates/notes.md` — advance predictions, commands, rc, actual readings, controls,
  coverage findings, generation-defect record.

## Execution summary (self-tests on scratch fixtures only)

| check | result | rc |
|---|---|---|
| always-refuse control at BASE | reading 0 | 0 |
| always-accept control at BASE | reading 0 | 0 |
| C1 self-test (fixture gate in clone @5142b52, real committed fixtures) | baseline 4; `MUTANTS C1: killed=5 survived=6 total=11` | 0 |
| C2 self-test (fake lane with executor paragraph draft) | baseline 3; `MUTANTS C2: killed=4 survived=3 total=7` | 0 |
| baseline-inconclusive path (c2 at 5142b52 paragraph) | reading 1 → INCONCLUSIVE, nothing judged | 0 |
| fail-closed paths (missing lane / missing gate) | exit 2 | 2 |

All 18 mutant verdicts match the advance predictions in notes.md.

## Surviving mutants = coverage findings (not contract changes)

- C1 (6 of 11): `drop_R2_NEW` — F3 forges the journal `new_expect` to EQUAL the candidate expect,
  so no forgery among F1–F4 ever violates NEW_MISMATCH; `r4_downgrade` — no fixture contains an
  orphan entry, so downgrading the warning never fires; `clean_on_violation` — the counter checks
  rc and the exact per-violation line but never parses the final verdict line;
  `first_violation_only` — each forgery violates exactly one frozen rule, so truncation is
  invisible; `non_json_accept` and `unknown_id_ignore` — the counter never feeds a non-.json
  journal name or an entry id absent from the candidate ledger.
- C2 (3 of 7): `drop_S095`, `drop_S096`, `drop_S097` — dropping any single cited id leaves the
  reading at 3. Term (a) needs only one good id; term (b) never requires an id in the paragraph
  (it greps the quote and binds the S095 row from `corpus/source-fetches.tsv` + locate on the
  lane normalizer); no cited id is bound to the str.isspace() grounding (S097).

## Defects routed / record

- No lane defects found; no lane edits made by this seat.
- Two runner generation defects found and fixed during self-test (trailing-comment def lines;
  regex-group misuse that corrupted the unknown_id mutant into a false kill at reading 0) — the
  final self-tests above were run after both fixes. Detail in notes.md.
- Install record: none (bash, python3, git only).

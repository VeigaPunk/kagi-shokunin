# K43ExecScratchFix — C3 frozen patch proof (round 43)

Seat: K43ExecScratchFix. Sandbox S=/fast/scratch/hyaku/kagi-r43/K43ExecScratchFix, cloned --shared from the lane, detached at dd6ccb92bf04a061e9f1e66913d15f097397b1b3; `git rev-parse --show-toplevel` == "$S/work" asserted before writes. Lane never edited. Sandbox removed on exit (trap) after deliverables copied.

## Applied
Exactly the seven frozen replaces from `plans/round-43-controls.sh` §C3 FIXES (python str.replace, count==1 asserted per pattern, nothing else touched):
- corpus/anchor-pins.sh, corpus/claims-declared.sh, corpus/prefreeze-control.sh (2 lines), corpus/self-description-sweep.sh (2 lines incl. comment), corpus/surface-census.sh.
Diff stat: 5 files, 7 insertions, 7 deletions. Full diff in deliverables.

## Selftests (the five)
All run as `HYAKU_SCRATCH=$S/probe bash corpus/<g>.sh --selftest` from the sandbox root, expected exact:

1. corpus/anchor-pins.sh --selftest → rc=0, last line `ANCHOR_PINS_SELFTEST: PASS (8 cases)` — MATCHES
2. corpus/claims-declared.sh --selftest → rc=0, last line `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` — MATCHES
3. corpus/prefreeze-control.sh --selftest → rc=0, last line `PREFREEZE_SELFTEST: PASS (25 cases)` — MATCHES
4. corpus/self-description-sweep.sh --selftest → rc=0, last line `SELFTEST: PASS (10 cases)` — MATCHES
5. corpus/surface-census.sh --selftest → rc=0, last line `SELFTEST: PASS (16 cases)` — MATCHES

## Counter
`C3_ROOT=$S/work bash plans/round-43-c3.sh` → rc=0, output `5` (expected 5).

## Ledger mapping receipt
`grep -n 'surface-census.sh --selftest\|prefreeze-control.sh --selftest\|self-description-sweep.sh --selftest' corpus/claim-ledger.tsv`:
- line 17: R11-03 → `bash corpus/surface-census.sh --selftest`; step 3 surface-census run covers it verbatim (PASS (16 cases) rc 0).
- line 93: R33-01 → `bash corpus/prefreeze-control.sh --selftest`; step 3 prefreeze run covers it verbatim (PASS (25 cases) rc 0).
- line 95: R34-01 → `bash corpus/self-description-sweep.sh --selftest`; step 3 sd-sweep run covers it verbatim (PASS (10 cases) rc 0).
- line 96: R34-02 → `bash corpus/prefreeze-control.sh --selftest`; same prefreeze run covers it verbatim.
The only addition is the step-3 mandated `HYAKU_SCRATCH=$S/probe` env prefix; gate behavior unchanged beyond scratch root. Full rows in receipts.txt.

## Deliverables
`.ufo/waves/round-43/build/K43ExecScratchFix/` : gates.diff, receipts.txt, sha256sums.txt (one line per patched gate). This report: `.ufo/waves/round-43/build/K43ExecScratchFix.md`.

Tooling: no installs; bash, git, python3, sha256sum only.

Report: .ufo/waves/round-43/build/K43ExecScratchFix.md

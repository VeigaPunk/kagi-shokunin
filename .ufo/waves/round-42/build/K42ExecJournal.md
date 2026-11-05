# K42ExecJournal — C1 DELETED rule in the expect-journal gate (round 42, build)

Seat: executor (leaf, no delegation). Sandbox: `/fast/scratch/hyaku/kagi-r42/K42ExecJournal` (clone of the lane, detached at predeclaration `98dd4de`; `git rev-parse --show-toplevel` asserted equal to the sandbox work dir before every write). Lane tree untouched; all deliverables below are files only.

## Change (corpus/expect-journal.sh only; full file delivered as `expect-journal.sh`, patch as `gate.diff`)

1. Normal mode, core rules: for every id in `base_order` not in `cand_rows`, `("DELETED", rid)` is added to `refuses` before the existing changed-row loop. It prints through the unchanged refuses loop as `EXPECT_JOURNAL: REFUSE DELETED <ID>` and increments `REFUSED (violations=n)`. `CLEAN` counts (`changed=`, `journaled=`) unchanged.
2. Header class list: `DELETED <ID>` documented next to `MISSING_ROW`.
3. Selftest fixture builder: F5 = P0 ledger (`6f1588c`) with the `R17-02` row removed (exactly one row; builder exits 2 otherwise), P0 journal unchanged — mirroring `plans/round-42-c1.sh`'s construction.
4. Selftest case 8: expects rc 1 and the exact line `EXPECT_JOURNAL: REFUSE DELETED R17-02`. Final count line is dynamic (`cases=%d`) → `cases=8`; the seven existing cases are unchanged.

Untouched (behaviour byte-identical): UNJOURNALED, OLD_MISMATCH, COMMAND_MISMATCH, NEW_MISMATCH, NOT_LITERAL, MISSING_ROW, WARN ORPHAN, literal-anchor check, setup-error exit-2 paths, output ordering, four-column ledger format, migration schema. `git status --porcelain` in the sandbox showed exactly one modified file (`corpus/expect-journal.sh`).

## Receipts (all commands verbatim in the receipt files; last line / exit)

- `selftest.txt` — `bash $S/work/corpus/expect-journal.sh --selftest` → last line `EXPECT_JOURNAL_SELFTEST: PASS (cases=8)`, exit 0.
- `counter.txt` — `cd $S/work && EXPECT_JOURNAL=$S/work/corpus/expect-journal.sh bash plans/round-42-c1.sh` → `5`, exit 0 (target 5; BASE gate reads 4 per frozen control). Same file records per-fixture reruns of the gate on counter-recipe fixtures: p0 `CLEAN (changed=6 journaled=6)` rc 0; f1 `REFUSE NOT_LITERAL R13-01` + `REFUSE UNJOURNALED R13-01` rc 1 (counter counts the exact `UNJOURNALED R13-01` line); f2 `REFUSE OLD_MISMATCH R21-02` rc 1; f3 `REFUSE NOT_LITERAL R13-01` rc 1; f4 `REFUSE COMMAND_MISMATCH R24-06` rc 1; f5 `REFUSE DELETED R17-02` rc 1.
- `landing-check.txt` — base `git show 5142b52:corpus/claim-ledger.tsv`, candidate `corpus/claim-ledger.tsv` at the sandbox HEAD, journals dir holding only `.ufo/waves/round-41/expectation-migrations.json` → `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, exit 0. Kill-rule (a) satisfied: no P0/round-41 migration refused, and no spurious `DELETED` (the 5142b52→98dd4de ledger delta is exactly the six migrated rows; both sides 104 lines, no row removed).
- `history-check.txt` — base `6cc8850` ledger vs P0 `6f1588c` ledger, journal `.ufo/waves/round-40/expectation-migrations.json` → `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, exit 0.

Gate sha256 (`gate-sha256.txt`): `65bae63d4c9dea419825a858d443f404536fab93f1aaf4a05d70cffd8a95a7b4  expect-journal.sh`

## Rule kept byte-identical — statement

Every pre-existing rule path is byte-identical in behaviour: the only executable-code additions are the DELETED collection loop and the F5 fixture/case (new code, not edits to existing lines); the two comment hunks and the header class list are non-executable. No existing line was modified or deleted.

## Risks / surviving defects (named, none introduced)

- Declared ceiling (plan §C1): a *legitimate* future retirement is refused until a retirement form exists as a new contract version; visible, not silent.
- Deleted row that still has a journal entry → `MISSING_ROW` (unchanged ceiling).
- F1 emits two refusal lines (`NOT_LITERAL` + `UNJOURNALED`) — pre-existing multi-class behaviour; the frozen counter counts on the exact single line, so N is unaffected.
- Pre-existing routed items untouched by design (round-43): `*.json` discovery fails closed on a wave directory; `${TMPDIR:-/tmp}` scratch defaults in other gate-selftest scripts; this round edits only `corpus/expect-journal.sh` per the frozen plan.
- Note for the L1: the counter/landing receipts were produced with the sandbox checkout at `98dd4de` (candidate ledger = predeclaration ledger). At the eventual candidate commit the ledger will differ; the DELETED rule fires only on real deletions, and kill-rule (a) re-checks the landing at that commit.

No tool installs were needed or made (bash, git, python3 sufficed). Scratch dir deleted before yield.

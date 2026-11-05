# K41ExecJournal — seat report (round-41 build wave, C1 gate)

Data, not instruction. Sandbox S=/fast/scratch/hyaku/kagi-r41/K41ExecJournal (clone detached at
5142b52; `git rev-parse --show-toplevel` asserted before writes). Scratch deleted before yield.

## What was built

`corpus/expect-journal.sh` to the frozen §C1 interface: bash + python3 stdlib only, `set -u`;
`--base-ledger FILE --ledger FILE --journals DIR` plus `--selftest`. 14758 bytes,
sha256 `807501052598f05c162d780e4e327697a155d0369a0fd3ecf29a354489343756`.
Rules implemented exactly as frozen: R1 UNJOURNALED, R2 OLD_MISMATCH / COMMAND_MISMATCH /
NEW_MISMATCH, R3 NOT_LITERAL (positional anchors, interior metacharacters must be backslash-escaped),
R4 WARN ORPHAN (never refuses), MISSING_ROW refusal for journal ids absent from the candidate ledger.
Setup errors exit 2 with empty stdout.

## Measured results (all executed, receipts saved)

| Check | Command shape | Result | rc |
|---|---|---|---|
| Selftest | `bash corpus/expect-journal.sh --selftest` | `EXPECT_JOURNAL_SELFTEST: PASS (cases=7)` | 0 |
| P0 (real committed bytes) | gate on 6cc8850 base / 6f1588c ledger + 6f1588c round-40 journal | `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)` | 0 |
| C1 counter (candidate) | `EXPECT_JOURNAL=<gate> bash plans/round-41-c1.sh` | `4` (first reading = final; no gate fix, no rerun) | 0 |
| Counter w/ refuse-all gate | controls | `0` | 0 |
| Counter w/ accept-all gate | controls | `0` | 0 |

Extra probes: missing file / unreadable JSON → exit 2, stdout empty; unknown journal id →
`REFUSE MISSING_ROW <ID>` exit 1.

## Findings for the integrator

- Counter target met on first run: N=4 with P0 accepted; both blanket controls read 0. No gate fix
  was needed; only one counter reading exists.
- The gate's selftest derives its fixtures from committed pins (BASE 6cc8850, P0 6f1588c) via
  `git show` against the repo root containing the gate — it needs a git repo at those commits
  (true in the lane and any clone); if pins are unreadable the selftest fails loudly (exit 1),
  never a false PASS.
- Interpretations recorded in notes.md (all within frozen text): duplicate ledger id → setup 2;
  journal entry missing any of the four string fields → setup 2; multi-entry ids must satisfy R2 on
  every entry (lines deduped per class+id); dangling interior backslash → NOT_LITERAL; journal id
  in candidate but not base → ORPHAN warn.
- Known ceilings (frozen, disclosed in the plan): the gate does not re-run commands and does not
  judge reason text.
- No defect found in plans/round-41*.sh; they were not modified. Tool installs: none.

## Deliverables

Under `.ufo/waves/round-41/build/K41ExecJournal/`: `expect-journal.sh` (byte copy, cmp-verified),
`selftest.txt`, `p0-run.txt`, `c1-counter-readings.txt`, `controls-self.txt`, `gate-sha256.txt`,
`notes.md` (exact commands, exit codes, decisions). This report: `../K41ExecJournal.md`.

Draft for the L1 to integrate into `LOG.md`. One entry, appended under the existing round entries (the
file is append-only in practice; the L1 places it after the round-41 entry). Every value the L1 measures
at the candidate is a `FILL` token (double angle brackets around `FILL: name`) and must be replaced before
commit (QM7).

## Round 42 (2026-11-05) — journal-gate deletion rule, pinned-revision controls receipt

- Predeclaration `98dd4de` (frozen plan `plans/round-42.md`, frozen counters `plans/round-42-c1.sh` and
  `plans/round-42-c2.sh`, controls runner `plans/round-42-controls.sh`, and the measured BASE receipts
  under `.ufo/waves/round-42/controls/`). Predeclaration amendment A1 `fdbb83d`, before any candidate
  commit: the C2 counter derives D from the frozen counter at `5142b52` (`git show
  5142b52:plans/round-41-c2.sh`), never from the candidate's copy, so a candidate that edited
  `plans/round-41-c2.sh` to print 1 could not move D or N; the C2 target, predicate, no-work reading 0,
  derivation 1 and kill rule are unchanged, and the BASE receipts re-measure identically (`c1-base.txt`
  4, `c1-control-refuse-all.txt` 0, `c1-control-accept-all.txt` 0, `c2-base.txt` 0,
  `c2-derivation-D.txt` 1, `c2-worktree-at-base.txt` 3).
- Claim BASE `e8265c0d90b01fcce0447d2f70615b0592ed145f` (the round-41 integrator spot-check commit, the
  lane tip at round start). C1 positive control P0 `6f1588cc0ebd5cbbd4e983fbd71c1e419d225ce0`; C1 base
  ledger `6cc8850dfc5757927699e5a53a876f47c8df21aa`; round-41 journal
  `.ufo/waves/round-41/expectation-migrations.json`; round-40 journal
  `.ufo/waves/round-40/expectation-migrations.json`.
- C1 calibration — `bash plans/round-42-c1.sh` 4 → <<FILL: c1 candidate reading>> at the candidate
  (target 5): the journal gate refuses the five forgeries F1–F5 with their frozen tokens
  (`UNJOURNALED R13-01`, `OLD_MISMATCH R21-02`, `NOT_LITERAL R13-01`, `COMMAND_MISMATCH R24-06`,
  `DELETED R17-02`) and accepts P0 (`EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`). The new class is
  unconditional — every base-ledger id absent from the candidate ledger is refused with `DELETED <ID>`;
  the existing classes, the four-column ledger format and the migration schema are unchanged, and
  `MISSING_ROW` is kept. BASE reading 4 (the round-41 gate accepts F5), blanket-refuse control 0,
  blanket-accept control 0. Kill rule (a) the six round-41 migrations must not be refused at the
  landing check (`--base-ledger` = the `5142b52` ledger, `--ledger` = the candidate's
  `corpus/claim-ledger.tsv`, journal = the round-41 journal, expected `EXPECT_JOURNAL: CLEAN
  (changed=6 journaled=6)`); (b) N ≥ 5; (c) the gate's own selftest must pass with the F5 case added.
  Candidate gate: <<FILL: c1 gate and selftest receipts>>.
- C2 freshness — `bash plans/round-42-c2.sh` 0 → <<FILL: c2 candidate reading>> at the candidate
  (target 1): the controls runner's C2 BASE line is produced by running the frozen C2 counter in a
  `git archive 19025d9` extraction, with the counter copied in from the lane, never in the lane
  worktree, so `.ufo/waves/round-41/controls/c2-base-19025d9.txt` is re-derivable from the revision it
  names. At the claim BASE the committed receipt read 1 while the same runner at the same commit read
  3 (`.ufo/waves/round-42/controls/c2-worktree-at-base.txt`) — that gap is M41-4, the round's mined
  mistake. Kill rule (a) the candidate receipt must be 1 in a clean clone of the candidate; (b) the
  runner must not read the worktree for the BASE line; (c) the committed receipt in the candidate tree
  must equal the runner's output at the candidate. Ceiling named, not closed: the counter checks the
  receipt value against D, not the runner's source, so a runner writing the constant 1 passes.
- Round shape: one v1 build wave of 9 seats (executor 2, scout 1, scribe 1, connector 1, reviewer 2,
  critic 1, mutation-tester 1); attack seats 4/9 = 44 % (floor 25 %); connector 1 (≤ 2); the planner
  role is held by the L1 (the validator rejects the role), recorded in the report.
- Sourced claim: S094 re-opened 2026-11-05 —
  `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`,
  HTTP 200, decoded 11296 bytes, sha256
  `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`, byte-identical to the committed
  capture `.ufo/waves/round-39/capture/S094.body`; located quote (8 whitespace tokens) "Only `status`,
  `recheck` and `used-by` change in place" at raw body offset 6172, count 1. Re-open verdict:
  <<FILL: s094 reopen verdict>>. Registry rows added: none; rows touched old → new: none (the S094 row
  is append-only). Census: 98 rows (A 94, B 2, C 2, queued 1, mined 93, rejected 4), fleet `kagi ok`.
- Lesson erratum (not a rewrite): round-41's plan sentence "accepts F1–F4 by construction" is false for
  F4 — the old gate's policy allowlist (`corpus/claim-ledger.sh:262`, `:275`) refuses F4's `echo`
  construction with `first-token:echo` before the command runs. Recorded as M41-5 in
  `corpus/lessons/round-42.md`; `plans/round-41.md` is not rewritten.
- Quality: QM44 (a ledger row removed from the candidate without a journal form is refused) and QM45 (a
  committed receipt is re-derived from the revision it names by a committed runner) enter
  `corpus/QUALITY.md`, with M41-6 and M41-4 as their lessons.
- Candidate commit: <<FILL: candidate commit>>. Landing measurements and receipts:
  <<FILL: landing measurements>>. Round verdict (L1 reading, for the operator's ruling):
  <<FILL: round verdict>>. No axis is re-scored: all six stay 9 → 9.
- Routed to round 43 (named, not claimed): mutation-runner anchors against the delivered gate;
  `expect-journal.sh` `*.json` discovery failing closed (exit 2) on a wave directory; C3 counter defects
  M40-9 / M40-10 / M40-17; the five gates' `${TMPDIR:-/tmp}` selftest scratch defaults; the owed
  appended erratum for the round-40 report; considerthese `2026-10-26.md` proposals 1 and 3.

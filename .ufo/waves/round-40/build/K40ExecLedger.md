# Seat report — K40ExecLedger (kagi round 40, build wave)

Scope executed: C1 end-to-end re-run on the candidate tree (read-only), full ledger verify,
expectation-migrations audit, untouched-rows byte proof. Candidate
`cb3f642479a09644a03874909bb7e44b52697a8d`; BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa`;
lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, HEAD verified = candidate, tracked tree
clean (only untracked sibling-seat files under `.ufo/waves/round-40/`). No edits made to the
lane; no commits; no installs (pacman paused; jq already present at `~/.local/bin/jq`).

## Results

1. **C1 reproduced — target met.** `bash plans/round-40-c1.sh` → stdout exactly `0`, exit 0,
   289.3 s (target 0, BASE 6; fail-closed branches did not fire; none of the six ids was
   removed). Receipt: `build/K40ExecLedger/c1-counter.txt`.
2. **Verify red set exact.** `bash corpus/claim-ledger.sh verify` → exit 2, 288 s, summary
   `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)` (identical to the committed BASE
   receipt). Red lines:
   - FAIL exactly R11-08, R22-03, R24-15, R25-02, R36-03 (all `exit-mismatch`);
   - STALE exactly the 8 file-stamp rows (incl. newly stamped claim-ledger.tsv, SKILL.md);
   - MISSING-ID only historical errata ids (R32-1..5, R33-1..7, R34-2/3/4, R35-1, R36-1..5);
   - `grep -c '^(FAIL|STALE|MISSING).*(R13-01|R21-02|R24-06|R31-02|R33-02|R34-03)'` → 0.
   - POLICY R29-01/R29-02/R38-03 present, outside population, per plan.
   Receipt: `build/K40ExecLedger/verify-full.txt`.
3. **Migrations audit clean, 6/6.** For every row of
   `.ufo/waves/round-40/expectation-migrations.json` (R13-01, R21-02, R24-06, R31-02, R33-02,
   R34-03): `command` cell matches both revisions' ledger bytes; `old_expect` byte-equals the
   BASE expect cell; `new_expect` byte-equals the candidate expect cell AND matches the
   command's freshly re-derived output on the candidate tree (`grep -c '^## Round '
   SCORECARD.md` → 54; `bash corpus/row-identity.sh scorecard-rounds` → `ROW_IDENTITY:
   scorecard-rounds count=54 sha256=52e7ba8d9b4de4a3aa7543b7f0370361dd17c2ae18b98c0c318618917dfe50c7`;
   `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=96 A=92 B=2 C=2 queued=1
   mined=92 rejected=3 entries_sourced=14 legacy=21 captures=96 inrow=16 inrow_only=0
   inrow_nonreproducing=12)`, all exit 0). Every old_expect no longer matches the new output —
   the rebindings are real. Receipt: `build/K40ExecLedger/migrations-audit.md`.
4. **Untouched rows byte-proven.** R25-02, R29-01, R29-02, R38-03, R11-08, R22-03, R24-15,
   R36-03: byte-identical between `git show BASE:corpus/claim-ledger.tsv` and
   `git show CAND:corpus/claim-ledger.tsv` (8/8). Receipt:
   `build/K40ExecLedger/untouched-rows.txt`.

## Extra evidence

Unified diff of the committed BASE verify receipt vs my candidate run shows exactly: the six
frozen-set FAIL lines removed (`reason=verdict-not-final exit=0`), stamp sha/byte updates, and
SCORECARD erratum line drift +1 (same erratum ids) — no other delta.

## Verdict / risks

- Milestone inputs for this seat: **frozen counters reproduced** (C1: candidate 0 = target 0,
  BASE 6) with every surviving defect recorded (§2 red set). No falsification, no defect found
  in the audited population.
- C2/C3 counters were not this seat's assignment and were not run.
- Risks: none material. Note for the closure seat: verify stamps the ledger itself STALE
  (`6da91663a644->434b8233ee23`) — the stamp baseline predates the candidate's migrated ledger,
  expected for a landing round; the C1 counter does not read stamps.
- Scratch `/fast/scratch/hyaku/kagi-r40/K40ExecLedger` deleted after receipts were copied;
  nothing else written outside the seat's two paths.

Tool installs: none.

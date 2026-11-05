Seat K43ExecC1Inst — C1 discrimination matrix verification at dd6ccb92bf04a061e9f1e66913d15f097397b1b3.

Sandbox: S=/fast/scratch/hyaku/kagi-r43/K43ExecC1Inst, work=$S/work (git clone --shared, checkout --detach dd6ccb9, toplevel verified).

Receipts (detail in build/K43ExecC1Inst/receipts.txt):
- bash plans/round-43-c1.sh (real gate): stdout 6, rc 0 (expect 6) — MATCH.
- Refuse-all gate (prints exactly `EXPECT_JOURNAL: REFUSED (violations=1)`, exit 1) via EXPECT_JOURNAL: stdout 0, rc 0 (expect 0; P0 refused, N=0) — MATCH. (Gate path: /tmp/refuse-all.sh, removed after run.)
- Accept-all gate (prints exactly `EXPECT_JOURNAL: CLEAN (changed=0 journaled=0)`, exit 0) via EXPECT_JOURNAL: stdout 0, rc 0 (expect 0; forgeries accepted, N=0) — MATCH. (Gate path: /tmp/accept-all.sh, removed after run.)
- F6a: git show 6cc8850:corpus/claim-ledger.tsv | grep -c '^R11-03' → 1 (expect 1) — MATCH.
- F6b: git show 6f1588c:corpus/claim-ledger.tsv | grep -c '^R11-03' → 1 (expect 1) — MATCH.
- F6c: git show 6f1588c:.ufo/waves/round-40/expectation-migrations.json | grep -c '"R11-03"' → 0 (expect 0) — MATCH (grep rc 1 on count 0).
- Landing check (A1 form): bash corpus/expect-journal.sh --base-ledger $S/base5142.tsv (git show 5142b52:corpus/claim-ledger.tsv) --ledger $S/work/corpus/claim-ledger.tsv --journals $S/j41 (copy of round-41 expectation-migrations.json) → `EXPECT_JOURNAL: CLEAN (changed=6 journaled=6)`, rc 0 — MATCH.
- Gate bytes: git diff --quiet 5f3566c HEAD -- corpus/expect-journal.sh; echo $? → 0 — MATCH (bytes unchanged).

Deviations: none. All values match predictions in plans/round-43.md §C1 + amendment A1.

Report: .ufo/waves/round-43/build/K43ExecC1Inst.md
Receipts: .ufo/waves/round-43/build/K43ExecC1Inst/receipts.txt

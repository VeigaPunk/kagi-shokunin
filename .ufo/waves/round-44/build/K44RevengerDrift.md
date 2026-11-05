# K44RevengerDrift — round-42-era receipt drift, reconstructed (round 44, revenger seat)

Read-only. Sandbox clone at predeclaration `ae9e9eb`; every git call named `-C`; lane untouched.
Full narrative + timeline: `.ufo/waves/round-44/build/K44RevengerDrift/timeline.md`. Evidence:
`.ufo/waves/round-44/build/K44RevengerDrift/evidence/e1..e9` (executed receipts, each with command,
output, rc, last line; provenance transcript). Axes served: freshness (C3).

## Findings (commit-level; all executed where stated)

1. **Authorship.** All three drifted receipts were created and committed by `98dd4de` (r42
   predeclaration, 13:23:22) and never touched again — `--diff-filter=A` history is a single commit per
   path; `98dd4de..5f3566c` touched no controls receipt. Amendments `fdbb83d` (A1), `ca0c6a9` (A2) and
   candidate `d00a543` changed counters/runners only. (e9)
2. **`c1-base` 4 → 5.** Cause: `d00a543` — the only commit touching `corpus/expect-journal.sh` in
   `e8265c0..5f3566c` — adds the unconditional `DELETED <ID>` class; F5 (P0 ledger minus **R17-02**,
   unjournaled) flips from accepted to `REFUSE DELETED R17-02`. Counter inputs are pinned
   (ledgers `6cc8850`/`6f1588c`, journal `.ufo/waves/round-40/expectation-migrations.json`), so the
   round-41 landing migrations (R13-01/R21-02/R24-06/R31-02/R33-02/R34-03 — already in the tree at
   `e8265c0`, none named R17-02) did **not** move the reading. Executed: birth bytes at the BASE → **4**
   rc 0 (e1); committed bytes at `5f3566c` → **5** rc 0 (e2).
3. **`c2-base` 0 → 1.** Committed 0 = birth (pre-A1/A2) counter at `CAND=e8265c0`: the clone's committed
   r41 runner measured the **worktree**, wrote R=3 ≠ D=1 (e3: 0 rc 0). At `5f3566c` the same command
   reads `d00a543`'s pinned-mode runner (archive `19025d9` + counter frozen at `5142b52`), R=1=D → 1
   (e5: 1 rc 0; e6: D=1; e8: runner leg tail 1). One moving commit: `d00a543`. A2 (`ca0c6a9`) is a
   different fix — the do-nothing hole (critic F1 stale-receipt attack: pre-A2 a no-op runner read
   N=1 from the stale committed r41 receipt; A2 deletes the receipt and requires rc 0) — and leaves the
   BASE reading at 0 (e4: post-A2 bytes at `ca0c6a9`, `CAND=e8265c0` → 0 rc 0), verifying the plan's
   "re-measure identically".
4. **`c2-worktree-at-base.txt` (3).** Measures the M41-4 worktree-vs-receipt gap at the claim BASE:
   the r41 counter in the `e8265c0` worktree reads **3** (a=1,b=1,c=1 after the r41 landing) vs the
   committed r41 receipt's **1** (written at `5142b52` from the `19025d9` worktree). Executed: direct
   counter at `e8265c0` → **3** rc 0; the committed r41 runner's C2 BASE leg → rc 0, receipt tail **3**
   (e7). Writer: **no committed runner produces this path at any revision** (sweep empty at
   `98dd4de`/`e8265c0`/`5f3566c`/`d54109d`/`ae9e9eb`; `git log -S` hits are docs/plan/receipt commits
   only) — [INFERENCE] written manually by the r42 L1 premeasurement; the register's
   `not-written-by-any-committed-runner` token is the honest disposition.
5. **Register narrative + supersession audit.** Timeline of 16 dated rows in `timeline.md` (from
   `6cc8850` to `ae9e9eb`). Verdict: the register's `superseded-by` dispositions lose **no
   decision-relevant information** by pinning `re-derive-at 5f3566c` — that is the only revision where
   every invoked runner exists byte-committed (counter/runner born at `98dd4de`; gate born round 41;
   absent at `6cc8850`, where the counter prints `0` exit 0 — a misleading naive-at-BASE trap). Two
   facts the register cannot carry, supplied here for the lesson: (a) **both receipts were faithful at
   their own BASE** (`c1-base` re-derives 4=4 at `e8265c0`, e1; `c2-base` re-derives 0=0 under birth
   bytes e3 and under A2 bytes e4) — the drift is admitted-candidate work (`d00a543`) moving the
   readings, not a birth defect; (b) `6cc8850` is the C1 counter's *ledger* pin, never a measurement
   BASE of either receipt.

## Surviving defects / observations named

- **D-obs-1**: `git log --follow` misattributes these 2-byte receipts to round-36/33 commits via
  rename detection on identical single-digit content; use `--diff-filter=A` (both queries in e9).
- **D-obs-2**: `c2-worktree-at-base.txt` has no committed producer at any revision; its writer command
  is inference (two independent reproductions, e7).
- **D-obs-3** (declared C3 ceiling): register `committed` cells pin `5f3566c` bytes; the at-BASE
  faithfulness facts live only in this reconstruction — the lesson should quote them.
- **D-obs-4**: A2's "receipts re-measure identically" was asserted, not executed, for `c2-base` at the
  BASE under A2 bytes; executed here (rc 0, reading 0, e4).

## Checks the L1 may re-run

`bash plans/round-42-c1.sh` in a clone at `5f3566c` (expect 5) / at `98dd4de` (expect 4);
`bash plans/round-42-c2.sh 5f3566c` at `5f3566c` (expect 1) and `... e8265c0` from `98dd4de` bytes
(expect 0); sweeps in e9. No tools were installed or upgraded (none needed); no pacman transaction run.

Report: .ufo/waves/round-44/build/K44RevengerDrift.md

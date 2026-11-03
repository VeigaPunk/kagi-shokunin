# ReviewD2 — round-31 BUILD, D1/D2 hygiene — findings index

Full findings, evidence, and checks: `.ufo/waves/round-31/build/ReviewD2.md`. Receipt: `.ufo/waves/round-31/build/selfcounts-at-r31-tip.txt`.
Lane HEAD measured: `2d46e5759c02307edb3570c389de650040f98956`. Frozen BASE `655e620` and round-30 tip `d00e37e` are ancestors.

Judged on: calibration, coverage.

## Findings

- **F1 — MUST-FIX — D1 commit scope.** Commit exactly the 14 round-30 files (11 status entries; the `final/c3/registry/` directory collapses to one). Stage by explicit pathspec, never `git add -A` or `.ufo/`; 23 round-31 untracked paths must stay out.
- **F2 — MUST-FIX — D2 pointer defect.** Round-30 report line 11 cites `.ufo/waves/round-30/final/receipts/selfcounts-at-tip.txt` as C1 after-state evidence; that file holds the before-state (`stale=8 setup=1`). The after-state value (`stale=0 policy=2 setup=0`, exit 2) reproduces at `d00e37e` (live archive run) and at HEAD. Supersede by name with `.ufo/waves/round-31/build/selfcounts-at-r31-tip.txt` and `corpus/lessons/round-30.md` line 66. Do not rewrite the tip receipt.
- **F3 — MUST-FIX — three cited round-30 paths absent at `d00e37e`:** `.ufo/waves/round-30/SDraftEntries-report.md` (report line 21), `.ufo/waves/round-30/final/c3/registry/used-by.tsv` (report line 63), `build-results.json` (report line 99, short form). All untracked; they resolve on the F1 landing. Name them with the F2 defect.
- **F4 — MUST-FIX — two untracked registry drafts are stale against landed bytes.** `registry/append-block.md` S056 row differs from HEAD (corrected in `2017a68`); `registry/capture-rows.tsv` differs from HEAD `corpus/source-fetches.tsv` on 8/8 rows (decode profile, locator text). The round-30 "zero diff" claim (report line 27) is not reproducible at HEAD. Label as superseded pre-correction drafts or leave untracked; never commit unlabeled, never paste into landed registries.
- **F5 — NOTE — per-entry drafts** (`final/c3/entries/`) are pre-correction counterexamples (133/148/138 differing lines vs landed). Valid evidence if labelled.
- **F6 — NOTE — authorship confirmed by content** for all 14 files; `round-31` matches 0 times. `used-by.tsv` matches the landed entries' citations 8/8.
- **F7 — NOTE — the two modified round-30 files** are append-only (+48/+48, 0 deletions); safe to commit with F1. Repaired files are `i/lf` at HEAD.
- **F8 — NOTE — scope count:** "11 paths" is status entries; the commit is 14 files.
- **F9 — NOTE — counts (calibration check):** round-30 before-state `stale=8 policy=2 setup=1`; round-31 HEAD `stale=0 policy=2 setup=0`; live `d00e37e` `stale=0 policy=2 setup=0`. Exit 2 in all three (POLICY rows are the operator-routed R29 bindings, still red and named).

## Verdict

D1 is attackable and the defects are concrete (F1, F4). D2 is a pointer defect, not a value defect (F2, F3). No lane file was written, no lane git/jj mutation, no installs, no `op` or vault contact, no refused work touched.

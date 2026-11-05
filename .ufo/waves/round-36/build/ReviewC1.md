# ReviewC1 — scoped findings (round-36 C1 calibration)

Verdict: REJECT as frozen. Full evidence and raw output: `.ufo/waves/round-36/build/ReviewC1/review.md`.

Findings, by severity:

1. (High) C1 population is a proxy. `plans/round-36-c1.sh` = SD5 + stale. `shortcutAB` (delete the red ids from `lane-status:` and remove the armed `SA-CAP-CENSUS-SELFTEST` row, nothing else) reads C1 = 0 from BASE 4. Dropping R25-02 from the lane-status list reads 0 while `claim-ledger.sh cells` still prints `FAIL R25-02`. A false state on a named red (`R25-02 (PASS)`) reads 0.
2. (High) C1 excludes POLICY-refused bindings and ignores the self-counts exit code. `PV-FEEDTOKEN-SELFTEST` claiming `9 cases` (live 4) reads `stale=0` (2 of 63 bindings never compared).
3. (Medium) SD6 is layout-dependent: 5 in the lane tree, 3 in a git-archive extraction. The frozen kill rule "SD6 differs from 5" is not a committed-bytes measure.
4. (Medium) Landing coupling: a two-axis `## Round 36 — pre-move` table makes `cells` exit 2 (parser requires all six axes). F1 adds two `## Round` headers (44→46). Changed files need stamp re-pins (`STALE-POINTER` ×4). Candidate-only `cells` FAILs `R13-01`, `R24-06`, `R25-04` (`verdict-not-final`) appear in candidate runs and in no BASE run; `R25-04` mechanism unexplained.
5. (Low) `cells` summary line omits FAIL counts.

Measured: BASE C1=4 (SD5=3 stale=1), C2=15; candidate C1=0, C2=0 (my F1/F2 reconstruction + lane F3/F4 bytes); C1 and C2 counters are separable (f12 C1=0/C2=15; f34 C1=4/C2=0). F2 59→70 is measured against live `sources-census.sh --selftest` (`PASS (70 cases)`, rc 0).

Residual risk: candidate F1/F2 are my reconstruction, not the L1's bytes. Verification gaps: `cells` on the L1's landing tree not run (L1 bytes absent); R25-04/R13-01/R24-06 mechanism not isolated.

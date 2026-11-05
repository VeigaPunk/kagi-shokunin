# ReviewC1 report — round-36 C1 (calibration) attack

verdict: REJECT (C1 as frozen; population is a proxy)
frozen-counter readings: BASE(09f27e2 archive) C1=4 rc0 | C2=15 rc0 · cb8cb65 C1=4 C2=15 · candidate (my F1/F2 reconstruction + lane F3/F4 bytes) C1=0 rc0 C2=0 rc0
separability: f12 (F1+F2 only) C1=0 C2=15 · f34 (F3+F4 only) C1=4 C2=0 → counters separable; landing coupled via stamps and cells
setup controls: C1 sweep removed → rc2 "C1 SETUP: sweep verdict missing"; C2 receipt removed → rc2 "C2 SETUP: receipt missing"

## Answers (detail and raw output in review.md)

1. Population: proxy. Do-nothing-adjacent edits reach 0: shortcutAB (delete red ids from lane-status + delete armed row) → C1=0; single A→1, B→3, C→3. Dropping R25-02 from lane-status with cells still FAIL → 0 (t5). Stating R25-02 (PASS) → 0 (t6). PV-FEEDTOKEN claim 9 vs live 4, POLICY-refused → 0 (t7). C1 ignores self-counts exit code. SD6 reads 5 in lane tree, 3 in committed-bytes extraction (layout-dependent).
2. Post-move row: changes assertion; true at BASE (cells: FAIL R25-02, POLICY R29-01/R29-02); scored circularly (SD5 reads last ## Round calibration row); independent re-derivation via `bash corpus/claim-ledger.sh cells`, which the counter never consults.
3. F2 59→70: measured. `bash corpus/sources-census.sh --selftest` → `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` rc=0 (lane tree and BASE archive); self-counts binds live: BASE `STALE ... claimed=59 live=70`, candidate `OK ... claimed=70 live=70`; forge71 → stale=1.
4. Separable for C1/C2 counters; the candidate's landing is not: F1 adds two `## Round` headers (44→46); cells needs six axes per pre/post section (two-axis pre-move → rc2 "does not carry all six axes"); STALE-POINTER for four changed files; candidate-only cells FAILs R13-01, R24-06, R25-04 (verdict-not-final) not explained (R25-04 direct sha256 identical on both trees).

## Other findings routed to L1 (not fixed; no lane edits)

- `cells` summary `CELL_AUDIT: POLICY (... policy=2)` does not count FAIL rows (BASE has 3 FAIL rows; summary reports only policy). QM3-type defect.
- SD5 fallback: empty red parenthetical → all R-ids on line → empty → 0 vacuously.
- Lone-clone layout artifacts in my extraction: FAIL R22-03, R24-15 (M31-3); not lane reds.

## Non-results / honesty

- F1/F2 were not in the lane; the candidate is my reconstruction (F3/F4 are the lane's own bytes). The L1's bytes may differ.
- R25-04 FAIL on candidate: not explained; run-dependent (one candidate run printed R13-01 only).
- No ledger row, SCORECARD, LOG, or any lane file edited. No install. No tool added. No subagent.
- Lane F3/F4 provenance: patches taken from the lane working tree at review start; a final `git status` showed no modified tracked files (the L1 has moved them since). Not re-verified against the landed bytes.

## Files (build/ReviewC1/)

- review.md — four answers, counter table, raw command outputs
- report.md — this file
- raw/ — battery outputs (*.out/*.rc/*.err), battery.sh
- fixtures/ — diffs for t5, t6, t7, shortcutAB
- patches/ — f3.patch, f4.patch (lane working-tree bytes at review time)
- SHA256SUMS — digests (patches, fixtures, receipt 3f611eec…)

## Tools installed

None.

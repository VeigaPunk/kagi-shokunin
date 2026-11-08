# Seat Report — R64Connector (kagi round 64 attempt 2)

- **Seat**: `R64Connector`
- **Role**: UFO-FSD Connector
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Claim BASE**: `09cbee831d57be7c4edfbe77bf238f46bf729047`
- **FROZEN Predeclaration**: `plans/round-64.md` (commit `dff0929c0e084822b0fe32e0d164534c768f97fe`, Amendment A1)
- **Receipt**: `.ufo/waves/round-64/build/R64Connector/sweep.md`
- **Status**: `SEAT-STATUS: complete`

---

## 1. Carried Breadth Debt (`ADJACENCY_SCOPE: DEFECT`)

Measured directly via `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh`:
- Output: `breadth_drift=5 breadth_unverified=1` (`BREADTH_AUDIT: DEFECT (required=4 pins=4 checked=3 ok=0 children=125 declared=2 undeclared=123 missing=0 invalid=0 drift=5 exceeds=0 unverified=1)`)
- Causes: Host-level substrate absence (`$HOME/.config/opencode` 2 drifts; `$HOME/.local/bin` 2 drifts; `$HOME/.agents` 1 drift; `$HOME/.local/share/the-musketeer/chrome-profile` missing on host).
- Analysis: Round 64 does **not** move this debt. Per `PROVINCE.md:10-18, 83`, kagi refuses host substrate re-installation or arbitrary drift pinning without live substrate presence. The debt is carried, observed, reported, and unabsorbed.

---

## 2. Sibling-Overlap Findings (Summary across 20 Sibling Lanes)

A complete scan of all 20 sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/` was conducted across five target grounds:
1. **Held-Out Fixture Sets**:
   - `tameshi-shokunin` (`corpus/knowledge/regression-tally-completeness.md:1, 40, 60`) cites S094 (Dwork et al. 2014) as fleet methodology for sealed held-out mutant tables.
   - `kama-shokunin` (`corpus/QUALITY.md:713`, KQ150), `mori-shokunin` (`corpus/lessons/round-89.md:37, 79`), and `chousa-shokunin` (`corpus/lessons/round-47.md:145`) use held-out sets locally against overfitting.
   - **Status**: **Adjacent**. Kagi's C1 held-out table (`plans/round-64-heldout.tsv`, 20 rows, Amendment A1) is strictly lane-owned, evaluating historical record-correction polarity across OpenBao/the-janitor records.
2. **Lookup-Table / Mutation-Kill Contracts**:
   - `chousa-shokunin` (`lessons/round-65.md:25`), `mori-shokunin` (`lessons/round-90.md:40`), `mado-shokunin` (`.ufo/waves/round-48/w1-results.json:208`), and `kengaku-shokunin` (`SOURCES.md:345`) document counter gaming by lookup tables.
   - **Status**: **Adjacent**. Kagi's C1 guard leg (e) refuses the A4 vehicle via held-out evaluation, and leg (f) verifies negator set sensitivity.
3. **Recursion Bounds & Depth Guards in Delegating Gates**:
   - `kama-shokunin` (`tools/pre-report-gate.py:1641`) enforces `PRE_REPORT_RECURSION depth={depth} refused`.
   - `kaidoku-shokunin` (`lessons/round-97.md:49`) resolved M97-r infinite recursion in its `K-ownrun` mutant runner.
   - `kumitate-shokunin` (`corpus/knowledge/kimi-modes-machinery.md:138`) bounds agent recursion depth to 2.
   - **Status**: **Adjacent**. Kagi's C2 recursion bound (`C2_RECURSION_BOUND`, default 1) eliminates the round-63 timeout failure (D-63-2).
4. **Stub-Refusal Controls**:
   - `kumitate-shokunin` (`corpus/knowledge/ready-handoff-admission.md:2`), `kasegi-shokunin` (`corpus/instruments/README.md:1030`), and `revenger-shokunin` (`lessons/round-95.md:96`) employ printer-stub refusal controls.
   - **Status**: **Adjacent**. Kagi's C1-F9 and C2-F7 controls test refusal of constant-verdict claim counters.
5. **Sealed / SHA256-Checked Fixture Tables**:
   - `tameshi-shokunin` (`c1-measure-v4.py`), `kake-shokunin` (`sealed_count_v3.py`), and `mado-shokunin` (`truth-seal.json`) pre-declare cryptographic hashes for fixture sets.
   - **Status**: **Adjacent**. Kagi's sealed held-out file (`b0f51e2a...`) ensures zero leakage between fixture authors and candidate checkers.

**Domain Conclusion**: All 20 sibling lanes are strictly **Adjacent**. Kagi absorbs no external ground and maintains clean domain boundaries over secrets & vault ops.

---

## 3. UFO-FSD Connector Move (Synthesis Across Round Proposals)

- **Evidence**:
  In `plans/round-64-controls.sh` (drafted by `R64ExecControls`), `probe_counters()` is invoked unconditionally in `main()`, launching `timeout 2400 bash "$C2_INSTR" --tree "$CAND"` without evaluating `C2_RECURSION_BOUND`. When `plans/round-64-c2.sh` executes legs L3/L4 by invoking `plans/round-64-controls.sh`, the child battery re-enters `plans/round-64-c2.sh`. Without an active short-circuit in `probe_counters()`, this causes mutual recursion, reproducing D-63-2 (M63-LEN) and failing C2 termination with `rc=124`.
- **Affected Axes**:
  - `operability`: unblocks C2 termination (`terminated 0 → 1`, `killed=5` in <15 s).
  - `calibration`: allows unmutated no-work and real controls to complete reliably without hitting outer timeouts.
- **Proposed Move**:
  Guard `probe_counters()` in `plans/round-64-controls.sh` with `[ "${C2_RECURSION_BOUND:-0}" = "1" ] && return 0`. When bounded, the child battery skips counter re-entry, evaluates only fixture/stub controls (`C1-F9`, `C2-F7`, `PRIOR-*`), and returns the required mismatch readings for L3/L4 in <2 s. When `C2_RECURSION_BOUND=0`, it re-enters and triggers the 240 s timeout, satisfying refutation kill rule K2.
- **Verification**:
  - `C2_RECURSION_BOUND=1 bash plans/round-64-controls.sh .` completes in <3 s without counter re-entry.
  - `C2_RECURSION_BOUND=0 timeout 240 bash plans/round-64-c2.sh --tree .` times out with `rc=124` (K2).
  - `bash plans/round-64-c2.sh --tree .` prints `C2_REFUSAL: killed=5 population=5 guard=1 terminates=1` in <15 s.

---

SEAT-STATUS: complete

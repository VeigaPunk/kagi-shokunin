# ConnScope Findings — Sibling Overlap Scan & Connector Synthesis

Seat: `ConnScope` (UFO-FSD connector)  
Lane: `kagi-shokunin` (secrets & vault ops)  
Round: 36 (attempt 2)  
Date: 2026-11-04  

---

## 1. Sibling-Overlap Scan Summary

Across all 20 sibling lane repositories under `/home/vgpnk/Projects/shokunin/*-shokunin`:
1. **Four Feed URLs:**
   - `https://github.com/hashicorp/vault/releases.atom`: `none` across all 20 sibling lanes.
   - `https://github.com/openbao/openbao/releases.atom`: `none` across all 20 sibling lanes.
   - `https://github.com/getsops/sops/releases.atom`: `none` across all 20 sibling lanes.
   - `https://www.python.org/downloads/feed.rss`: Zero citations as a source/feed/clock. Passive HTML capture in `kake` (`.ufo/waves/round-35/.../www.python.org.body:72`), and fleet audit receipts in `kotoba` (`.ufo/waves/round-71/.../census-after.txt:81`) and `mado` (`.ufo/waves/round-44/.../census-fleet.txt:85`) reporting on kagi's own registry row `S039`.
   - **Verdict: SOLE to kagi.** No sibling absorbs them.
2. **Release-Clock / Observation-Receipt Mechanism:**
   - No sibling operates a release clock over external release feeds (Atom/RSS) with observation receipts.
   - Nearest implementations (`tabi` `scripts/check-release-pins.mjs` for Chromium Gitiles tags; `kama` `registry/engine-pin-relations.tsv` for llama.cpp engine tags) are disjoint. Kama's connector (`round-82/w1/CN01SiblingScan.md:19-20`) explicitly acknowledged that "the pin-watch register capability is already kagi's."
   - Nine sibling lanes (`chousa`, `kake`, `kama`, `kotoba`, `kumitate`, `mado`, `souji`, `tabi`, `tameshi`) cite kagi's `release-clock.py` as an external capability.
   - **Verdict: SOLE to kagi.** No sibling absorbs it.
3. **Self-Assessment-Population Class (Document Count Bound to Live Gate Output):**
   - kagi's instrument (`corpus/self-counts.py` + `corpus/self-counts.tsv` binding document locators to ledger commands, line counts, and expect pins) is exclusive to kagi.
   - Sibling calibration checkers (`tabi`, `revenger`, `kama`, `chousa`, `souji`) operate disjoint instruments on lane-local targets.
   - `kotoba-shokunin` round 62 (`QUALITY.md:68`, `erratum-absorption-round62.md:42`) explicitly gave method credit to kagi for the `self-counts` technique class.
   - **Verdict: SOLE to kagi.** No sibling absorbs it.

The complete 20-lane inventory table is written to `.ufo/waves/round-36/build/ConnScope/ConnOverlap.md`.

---

## 2. UFO-FSD Connector Synthesis & Proposed Move

### Evidence & Second-Order Tracing
- **Operability vs Counter Decoupling:** `ReviewC2` proved that updating only the 15 drifting feed rows (literal F3) causes `release-clock.py verify` to FAIL with 15 `RECEIPT-MISMATCH` errors against the unified 2026-11-04 observation receipt (`observe-live.json`). To satisfy C2's frozen kill rule (`release-clock.py verify` CLEAN), L1 updated all 30 rows in `corpus/release-clocks.tsv`.
- **QM14 Journaling:** Under `corpus/QUALITY.md` QM14, touching all 30 rows requires journaling the 15 non-drifting re-dated rows in `corpus/lessons/round-36.md` §Gate / §Revision accounting.
- **Ledger Continuity:** L1 added `R36-01`, `R36-02`, and `R36-03` to `corpus/claim-ledger.tsv`. Historical row `R25-04` expects `fired=3`, whereas live execution yields `fired=15`. `R25-04` must be explicitly marked as the historical round-26 baseline pin (superseded by `R36-03`).

### Affected Axes
`freshness`, `calibration`, and `operability`.

### Proposed Move
1. **Receipt Synchronization:** Adopt the 30-row synchronization in `corpus/release-clocks.tsv` to satisfy the C2 operability kill rule.
2. **QM14 Journaling:** Record the 15 unchanged re-dated rows in the round-36 lesson under §Gate / §Revision accounting.
3. **Claim Ledger Historical Demotion:** Document `R25-04` as historical (superseded by `R36-03`), maintaining ledger integrity.
4. **Contradiction Boundary Disclosure:** Disclose the divergence between `plans/round-36-c2.sh` (version/verdict check) and `release-clock.py verify` (full receipt contract) to document complete verification coverage.

### Verification
- `bash plans/round-36-c1.sh` → `0`
- `bash plans/round-36-c2.sh` → `0`
- `python3 corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`, rc 0
- `python3 corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (116 cases)`, rc 0
- `bash corpus/self-description-sweep.sh` → SD5 = 0
- `python3 corpus/self-counts.py` → stale = 0

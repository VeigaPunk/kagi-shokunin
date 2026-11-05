# ConnScope Report — Sibling Overlap & UFO-FSD Connector Synthesis

Seat: `ConnScope` (UFO-FSD connector)  
Lane: `kagi-shokunin` (secrets & vault ops)  
Round: 36 (attempt 2)  
Date: 2026-11-04  

---

## 1. Sibling-Overlap Scan Results

An exhaustive scan across all 20 sibling repositories under `/home/vgpnk/Projects/shokunin/*-shokunin` was performed covering the three assignment surfaces:
1. **Surface (a) Four Cited Feed URLs:**
   - `https://github.com/hashicorp/vault/releases.atom`
   - `https://github.com/openbao/openbao/releases.atom`
   - `https://www.python.org/downloads/feed.rss`
   - `https://github.com/getsops/sops/releases.atom`
2. **Surface (b) Release-Clock / Observation-Receipt Mechanism:**
   - `corpus/release-clock.py`, `corpus/release-clocks.tsv`, and `.ufo/waves/round-36/controls/observe-live.json`.
3. **Surface (c) Self-Assessment-Population Class:**
   - Document counts bound to live gate outputs (`corpus/self-counts.py`, `corpus/self-counts.tsv`, `corpus/self-description-sweep.sh`).

### Detailed Inventory Summary
The full 20-lane matrix is documented in `ConnOverlap.md`. Key findings:
- **Feed URLs (Surface a):**
  - Vault, OpenBao, SOPS feeds: **`none` across all 20 sibling lanes.**
  - Python downloads RSS: Zero active citations as a feed or source. Captured passively in `kake` (`.ufo/waves/round-35/evidence/security-txt-census/census/www.python.org.body:72`) during an external security.txt scrape. Noted in `kotoba` (`.ufo/waves/round-71/receipts/census-after.txt:81`) and `mado` (`.ufo/waves/round-44/w2/RerunCensus/census-fleet.txt:85`) within fleet-wide audit receipts examining kagi's own registry row `S039`.
  - **Verdict: SOLE to kagi.** No sibling absorbs or contests these feeds.
- **Release-Clock / Observation-Receipt Mechanism (Surface b):**
  - No sibling operates a release clock over external release feeds (Atom/RSS) with observation receipts.
  - `tabi-shokunin` (`scripts/check-release-pins.mjs`) reads Chromium Gitiles git tags from git references, not external feeds.
  - `kama-shokunin` (`registry/engine-pin-relations.tsv`) tracks llama.cpp engine tags; its connector (`round-82/w1/CN01SiblingScan.md:19-20`) ruled that "the pin-watch register capability is already kagi's."
  - Multiple sibling lanes (`chousa`, `kake`, `kama`, `kotoba`, `kumitate`, `mado`, `souji`, `tabi`, `tameshi`) cite `kagi-shokunin/corpus/release-clock.py` as kagi's sole, unique lane capability.
  - **Verdict: SOLE to kagi.** No sibling absorbs or contests it.
- **Self-Assessment-Population Class (Surface c):**
  - kagi's instrument (`corpus/self-counts.py` driven by `corpus/self-counts.tsv` binding document locators to ledger commands and line counts) is exclusive to kagi.
  - Sibling calibration mechanisms (`tabi` `check-selfassessment.mjs`, `revenger` `self_assessment_check.py`, `kama` `count-c1.py`, `chousa` `self-audit.py`, `souji` `c1-counter.py`) use disjoint instruments on lane-local targets.
  - `kotoba-shokunin` round 62 (`QUALITY.md:68`, `erratum-absorption-round62.md:42`) explicitly credited kagi as the author of the `self-counts` technique class.
  - **Verdict: SOLE to kagi.** No sibling absorbs or contests it.

---

## 2. UFO-FSD Connector: Bounded Proposal & Compatible Synthesis

### A. Evidence
1. **ReviewC2 Finding (`.ufo/waves/round-36/build/ReviewC2/report.md`):**
   Literal candidate F3 only re-dates the 15 drifting rows in `corpus/release-clocks.tsv` to `observed_at: 2026-11-04`. If the remaining 15 unchanged rows retain `observed_at: 2026-10-21`, running `python3 corpus/release-clock.py` (verify) against the newly repointed default receipt `.ufo/waves/round-36/controls/observe-live.json` fails with 15 `RECEIPT-MISMATCH` errors, directly violating C2's frozen kill rule (`release-clock.py verify` must pass CLEAN). In response, L1 updated all 30 rows in `release-clocks.tsv` to `observed_at: 2026-11-04`.
2. **ReviewC2 Condition 1 / QM14 Accounting:**
   Under `corpus/QUALITY.md` criterion QM14, modifying expectation or revision-pin state requires an explicit migration record preserving prior state. Touching all 30 rows rather than only the 15 drifting rows requires an explicit journal in `corpus/lessons/round-36.md` §Gate / §Revision accounting.
3. **ScribeGate Finding (`.ufo/waves/round-36/build/ScribeGate/report.md`):**
   `S034` (Vault releases feed) and `S035` (OpenBao releases feed) in `corpus/SOURCES.md` carry anchor descriptions citing `v2.2.0` and `v2.7.1` as "first stable entry", which are now entries #2 and #3 in the live feeds (`v2.2.1` and `v2.7.2` being newest). While their recheck cadence is `90d` (not `on-release`), the on-release clocks that depend on them have fired.
4. **SentinelBound Finding (`.ufo/waves/round-36/build/SentinelBound/review.md`):**
   Working-tree changes at T1 show L1 added `R36-01`, `R36-02`, and `R36-03` to `corpus/claim-ledger.tsv`.
5. **Ledger Decoupling & Contradiction:**
   In `corpus/claim-ledger.tsv`, row `R25-04` expects:
   `^RELEASE_CLOCK: CLEAN \(on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15\)$`.
   When `corpus/release-clock.py` runs with F4 (repointed to round 36), it reports `fired=15`, causing `R25-04` to fail the ledger regex. L1 introduced `R36-03` expecting `fired=15`, but `R25-04` remains an active row in `claim-ledger.tsv`.
   Furthermore, the frozen C2 counter (`plans/round-36-c2.sh`) compares only `parsed_version` and `verdict`, ignoring `observed_at`. In contrast, the operability kill rule (`release-clock.py verify`) checks `observed_at`, `parsed_version`, and `verdict`.

### B. Affected Axes
- **Freshness:** Claim C2 (feed-clock drift 15 -> 0 against committed live observation receipt).
- **Calibration:** Claim C1 (SCORECARD self-assessment mismatches 4 -> 0; capability table count 59 -> 70); and ledger / scorecard capability table consistency.
- **Operability:** C2 kill rule (`release-clock.py verify` must pass CLEAN against the repointed receipt).

### C. Proposed Move (Synthesized Action Plan for L1)
Synthesize the receipt synchronization, ledger continuity, and calibration accounting into one cohesive landing:
1. **Full 30-Row Receipt Synchronization:** Retain the re-dating of all 30 rows in `corpus/release-clocks.tsv` to `observed_at: 2026-11-04`. This satisfies the C2 operability kill rule (`release-clock.py verify` CLEAN).
2. **QM14 Revision Journaling:** In `corpus/lessons/round-36.md` §Gate / §Revision accounting, record the explicit old/new journal for the 15 unchanged rows (dates updated from 2026-10-21 to 2026-11-04, versions and verdicts unchanged), explaining that split-dated tables against unified observation receipts trigger `RECEIPT-MISMATCH`.
3. **Claim Ledger Historical Demotion:** In `corpus/claim-ledger.tsv`, document `R25-04` as the historical round-26 baseline pin (superseded by `R36-03` for the live round-36 pin `fired=15`), preventing ledger regression under full verification sweeps (`claim-ledger.sh verify`), following the precedent established for `R11-09`, `R12-03`, and `R21-04`.
4. **Explicit Contradiction Disclosure:** Explicitly state the structural difference between `plans/round-36-c2.sh` (version/verdict check only) and `release-clock.py verify` (full receipt contract including timestamps and hash). Disclosing this boundary demonstrates that the candidate fix simultaneously satisfies the narrow frozen counter and the full operability contract without masking defects.

### D. Risks
- **Risk 1 (Kill-Rule Trip):** Reverting `release-clocks.tsv` to only 15 re-dated rows (narrow F3 interpretation) allows `plans/round-36-c2.sh` to read 0, but immediately trips the C2 kill rule in `release-clock.py verify`. The 30-row synchronization is mandatory.
- **Risk 2 (Historical Obliteration):** Editing `R25-04` in place without marking it historical violates QM14. Preserving it as the round-26 record while adding `R36-03` maintains strict revision provenance.
- **Risk 3 (Sibling Cross-Contamination):** Negligible; sibling overlap scan proved complete autonomy and sole ownership across all three surfaces.

### E. Verification
- `bash plans/round-36-c1.sh` → outputs `0`.
- `bash plans/round-36-c2.sh` → outputs `0`.
- `python3 corpus/release-clock.py` → outputs `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)`, exit code 0.
- `python3 corpus/release-clock.py --selftest` → outputs `RELEASE_CLOCK_SELFTEST: PASS (116 cases)`, exit code 0.
- `bash corpus/self-description-sweep.sh` → SD5 = 0.
- `python3 corpus/self-counts.py` → stale = 0.

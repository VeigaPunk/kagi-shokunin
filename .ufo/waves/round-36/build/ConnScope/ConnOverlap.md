# ConnOverlap — Sibling Overlap Scan

Seat: `ConnScope` (UFO-FSD connector)  
Lane: `kagi-shokunin` (secrets & vault ops)  
Round: 36 (attempt 2)  
Date: 2026-11-04  

---

## 1. Executive Summary

A comprehensive sibling-overlap scan was conducted across all 20 sibling repositories under `/home/vgpnk/Projects/shokunin/*-shokunin` across the three declared assessment surfaces:
- **Surface (a) Four Cited Feed URLs:** `https://github.com/hashicorp/vault/releases.atom`, `https://github.com/openbao/openbao/releases.atom`, `https://www.python.org/downloads/feed.rss`, `https://github.com/getsops/sops/releases.atom`.
- **Surface (b) Release-Clock / Observation-Receipt Mechanism:** `corpus/release-clock.py`, `corpus/release-clocks.tsv`, and `.ufo/waves/round-36/controls/observe-live.json` (`release-clock-observations-v1`).
- **Surface (c) Self-Assessment-Population Class:** A document count bound to a live gate output (`corpus/self-counts.py`, `corpus/self-counts.tsv`, binding current-tense document counts to `ledger:<ID>`, `rows:<path>`, and `expect:<ID>`).

### Verdict Summary
- **Surface (a): SOLE.** No sibling lane claims or cites the Vault, OpenBao, or SOPS release feeds. The Python downloads RSS feed appears only in `kake` as raw captured payload HTML in an external security.txt census, and in `kotoba` and `mado` as fleet-wide source-census audit receipts inspecting kagi's own registry. No sibling lane claims or absorbs any of the four feeds.
- **Surface (b): SOLE.** No sibling lane implements or operates a release clock over external release feeds (Atom/RSS) with observation receipts. Adjacent release-pinning tools in `tabi` (Chromium Gitiles tags) and `kama` (engine git tags) are scoped strictly to their respective substrates; in fact, `kama`'s connector explicitly ruled that "the pin-watch register capability is already kagi's." Multiple sibling lanes (`chousa`, `kake`, `kama`, `kotoba`, `kumitate`, `mado`, `souji`, `tabi`, `tameshi`) explicitly document kagi as the sole operator of this capability. No sibling absorbs it.
- **Surface (c): SOLE.** While calibration and self-assessment mismatch detection are shared methodology across the fleet, kagi's specific instrument (`corpus/self-counts.py` driven by `corpus/self-counts.tsv` binding arbitrary document regex locators to live ledger executions and row counts) is exclusive to kagi. Sibling implementations (`tabi`, `revenger`, `kama`, `chousa`, `souji`) use disjoint instruments and distinct target classes. Furthermore, `kotoba-shokunin` (round 62) explicitly recorded in its `QUALITY.md` and knowledge entries that kagi is the author of the `self-counts` technique class. No sibling absorbs or contests kagi's claim.

---

## 2. Lane × Surface Inventory Table

The 20 sibling repositories evaluated:

| Lane | Surface (a): 4 Feed URLs | Surface (b): Release-Clock / Receipt | Surface (c): Self-Assessment-Population Class | Verdict | Evidence / Notes |
|---|---|---|---|---|---|
| **audio-shokunin** | `none` | `none` | `none` | **SOLE** | Audio/DSP domain; no release feeds, release clocks, or doc-count gates. |
| **chousa-shokunin** | `none` | `none` (cites kagi) | `none` (different instrument) | **SOLE** | `.ufo/waves/round-30/build/ConnectorSiblings.md:94,109` cites kagi's `release-clock.py` as an external reference on validated addresses. Uses `tools/self-audit.py` (round 34) for 43 pointer checks; does not bind doc counts to live ledger rows. |
| **game-dev-2d-shokunin** | `none` | `none` | `none` | **SOLE** | 2D Godot mechanics; no release clocks or self-assessment binding gates. |
| **game-dev-3d-shokunin** | `none` | `none` | `none` | **SOLE** | 3D Unreal engine; souji r60 (`S60ConnectorRound.md:148`) confirms game-dev-3d has no receipt-writing or release-clock tooling. |
| **kaidoku-shokunin** | `none` | `none` | `none` (surveys kagi) | **SOLE** | `.ufo/waves/round-49/w1/ConnSibling.md:43` catalogs kagi's `corpus/self-counts.py` as an adjacent, lane-local calibration counter. Notes that while the calibration family is shared, the instruments are not. |
| **kake-shokunin** | `python.org/downloads/feed.rss` (passive body capture) | `none` (cites kagi) | `none` (surveys kagi) | **SOLE** | `.ufo/waves/round-35/evidence/security-txt-census/census/www.python.org.body:72` has feed link in raw captured HTML; not a claimed source. `.ufo/waves/round-61/w1/ConnSiblingOverlap.md:24` notes kagi operates `release-clock.py` + `release-clocks.tsv`. `.ufo/waves/round-71/w1/ConnOverlap.md:79` lists kagi's `self-counts.py` as lane-specific instrument. |
| **kama-shokunin** | `none` | `none` (concedes kagi) | `none` (adjacent class) | **SOLE** | Has `registry/engine-pin-relations.tsv:1` tracking llama.cpp git tags; `.ufo/waves/round-82/w1/CN01SiblingScan.md:19` explicitly ruled: "the pin-watch register capability is already kagi's. The round may claim the engine ground, not the capability." `.ufo/waves/round-71/w1/CON01OverlapInventory.md:43` notes kagi's `self-counts.py` is adjacent target class. |
| **kasegi-shokunin** | `none` | `none` | `none` | **SOLE** | Operates `corpus/instruments/recheck-audit.py` to verify shell command syntax on `recheck:` lines; does not parse release feeds or bind document numbers. |
| **kengaku-shokunin** | `none` (doc badges only) | `none` | `none` (cites kagi) | **SOLE** | Unrelated python download links in markdown badges. `.ufo/waves/round-36/build/R36ConnSibling.md:32` cites `kagi-shokunin/corpus/self-counts.py:112` as internal regex literal over lane text. |
| **kotoba-shokunin** | `python.org/downloads/feed.rss` (fleet audit receipt) | `none` | `none` (credits kagi) | **SOLE** | `.ufo/waves/round-71/receipts/census-after.txt:81` notes kagi S039 duplicate URL across scopes. `.ufo/waves/round-62/w1/ConnSibling.md:55,102`, `QUALITY.md:68`, and `erratum-absorption-round62.md:42` explicitly give method credit to kagi for the `self-counts` technique class. |
| **kotodama-shokunin** | `none` | `none` (cites kagi) | `none` | **SOLE** | `.ufo/waves/round-71/w1/ConnectorSiblings.md:78` notes kagi owns release-clock receipts. Uses `tools/harness/claims-freshness.py` for pre-dispatch premise re-derivation from git object store. |
| **kumitate-shokunin** | `none` | `none` (cites kagi) | `none` | **SOLE** | `.ufo/waves/round-52/w1/ConnOverlap.md:40` inspected kagi's release clock: "No. 'clock' = release versions, not wall clocks." Uses `scripts/round-gate.mjs` for round-record structural self-audits. |
| **lore-shokunin** | `none` | `none` | `none` | **SOLE** | Canon narrative repository; no release clocks or self-assessment binding gates. |
| **mado-shokunin** | `python.org/downloads/feed.rss` (fleet audit receipt) | `none` (cites kagi) | `none` | **SOLE** | `.ufo/waves/round-44/w2/RerunCensus/census-fleet.txt:85` notes kagi S039 in fleet audit. `.ufo/waves/round-68/w1/R68ConnSiblings.md:188` cites kagi's `release-clock.py:151-179` for secret scrubbing in receipt construction. |
| **mori-shokunin** | `none` | `none` | `none` | **SOLE** | Linux kernel/cgroup memory tracing; uses `tools/mori-freeze-order.py` for freeze operation ordering. |
| **revenger-shokunin** | `none` | `none` (cites kagi) | `none` (different instrument) | **SOLE** | `.ufo/waves/round-90/w1/ConnectorR90.md:47` cites kagi's `release-clock.py:21`. Operates `corpus/self_assessment_check.py` for SM1–SM6 classes (README indexes, SHONEN digests, SCORECARD commit hashes via `git cat-file`). |
| **souji-shokunin** | `none` | `none` (cites kagi) | `none` | **SOLE** | `.ufo/waves/round-60/wave/w1/S60ConnectorRound.md:149` cites kagi's `release-clock.py` as complementary. Uses `census/round-39/c1-counter.py` for repo state binding during fleet cleanup. |
| **tabi-shokunin** | `none` | `none` (different substrate) | `none` (different instrument) | **SOLE** | Operates `scripts/check-release-pins.mjs` strictly for Chromium Gitiles git tags (`refs/tags/<A.B.C.D>/`). Operates `scripts/check-selfassessment.mjs` for checking selftest tallies in SCORECARD against gate `--selftest` outputs. |
| **tameshi-shokunin** | `none` | `none` (cites kagi) | `none` | **SOLE** | `.ufo/waves/round-56/w1/T56W1ConnectorSiblings.md:66` analyzes kagi's `release-clock.py` observed-vs-pinned receipt comparison. `corpus/knowledge/executable-self-assessment.md` discusses self-assessment conceptually. |
| **tsukuroi-shokunin** | `none` | `none` | `none` | **SOLE** | Operates `tools/measure-update-recheck.py` for partial update receipts; `corpus/knowledge/linux-v73-pinwatch-r68.md` is a manual Markdown note/table checking kernel git tags without an automated feed-reading clock. |

---

## 3. Surface-by-Surface Detailed Analysis

### Surface (a): The Four Cited Feed URLs
1. `https://github.com/hashicorp/vault/releases.atom` — **Zero hits across all 20 sibling repos.**
2. `https://github.com/openbao/openbao/releases.atom` — **Zero hits across all 20 sibling repos.**
3. `https://github.com/getsops/sops/releases.atom` — **Zero hits across all 20 sibling repos.**
4. `https://www.python.org/downloads/feed.rss` — **Zero active citations as a feed or source.**
   - In `kake-shokunin`: Found at `.ufo/waves/round-35/evidence/security-txt-census/census/www.python.org.body:72` (and round-48 copy). This is a static HTML page capture of `www.python.org` during an automated external probe of `security.txt` files across domains. It was never registered as a source, feed, or release clock in `kake`.
   - In `kotoba-shokunin` (`.ufo/waves/round-71/receipts/census-after.txt:81`) and `mado-shokunin` (`.ufo/waves/round-44/w2/RerunCensus/census-fleet.txt:85`): Appears in fleet-wide source-census receipts reporting: `kagi W04 S039 duplicate url www.python.org/downloads/feed.rss across scopes`. Both references explicitly attribute the URL to `kagi`.
   - **Conclusion:** kagi's claim on all four feed URLs is **SOLE**. No sibling absorbs them.

### Surface (b): Release-Clock / Observation-Receipt Mechanism
- `kagi-shokunin` operates `corpus/release-clock.py` + `corpus/release-clocks.tsv` against `.ufo/waves/round-36/controls/observe-live.json`. It evaluates strict semantic version progression (`anchored_version` vs `observed_version`), manages `on-release` recheck triggers, and enforces offline receipt replay.
- Nearest sibling mechanisms:
  - `tabi-shokunin` (`scripts/check-release-pins.mjs`): Reads Chromium Gitiles tags from git references, not Atom/RSS release feeds.
  - `kama-shokunin` (`registry/engine-pin-relations.tsv`): Tracks llama.cpp/sglang/vllm engine git commit/tag offsets. kama's own connector (`round-82/w1/CN01SiblingScan.md:19-20`) ruled that kagi owns the pin-watch register capability.
  - `tsukuroi-shokunin` (`corpus/knowledge/linux-v73-pinwatch-r68.md`): A manual markdown table comparing Linux kernel v7.2 and v7.3 sources, without an automated feed-reading clock.
- **Conclusion:** kagi's claim on the release-clock / observation-receipt mechanism is **SOLE**. No sibling absorbs it.

### Surface (c): Self-Assessment-Population Class (Document Count Bound to Live Gate Output)
- `kagi-shokunin` operates `corpus/self-counts.py` driven by `corpus/self-counts.tsv` (extending round 36 C1 to `SCORECARD.md:701`). It extracts integer locators from doc files and verifies them against live outputs (`ledger:<ID>`, `rows:<path>`, `expect:<ID>`).
- Sibling calibration mechanisms:
  - `tabi-shokunin` (`scripts/check-selfassessment.mjs`): Evaluates selftest tallies (`m1-selftest-tally`) in SCORECARD against live gate `--selftest` runs.
  - `revenger-shokunin` (`corpus/self_assessment_check.py`): Checks SM1–SM6 classes (README indexes, SHONEN digests, SCORECARD git commit hashes).
  - `kama-shokunin` (`count-c1.py` / `round42-selfdesc-reconcile.py`): Evaluates 6 statement forms (P, H, N, C, T, Q) at commit blame revision `W`.
  - `kotoba-shokunin` (`plans/round-62.md`): Implemented self-derived counts and explicitly recorded in `QUALITY.md:68` and `erratum-absorption-round62.md:42`: "method credits: ... kagi self-counts".
- Sibling consensus (`kaidoku` r49, `kake` r71): "the method family is shared fleet-wide, the instrument is not."
- **Conclusion:** kagi's claim on this population and instrument is **SOLE**. No sibling absorbs it.

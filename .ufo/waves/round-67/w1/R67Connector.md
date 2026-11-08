# R67Connector — Sibling-Overlap Scan & UFO-FSD Synthesis (Round 67, w1)

- **Seat**: `R67Connector` (leaf member; no subagent dispatch; read-only fleet scan)
- **Lane**: `kagi` (secrets & vault ops; branch `master`)
- **Claim BASE**: `076701a11a58e3eb58d996b4c76c5e18071fb179`
- **Frozen Predeclaration**: `plans/round-67.md` @ `aa8807e443166f45485e1aada2989f646efc707c`
- **Receipts**: `.ufo/waves/round-67/w1/R67Connector/` (`scan-census.tsv`, `rfc9530-fleet-scan.txt`, `s166-capture-verification.txt`)

---

## 1. Adjacency Call (for the Round 67 Report)

> **Adjacency call — round 67 C1 instrument:** A fleet-wide inspection of all 20 sibling lane repos (`*-shokunin`) and fleet-root documentation confirms that kagi's round-67 C1 capability (**capture read-through in the source census**) occupies an unowned, non-duplicative niche. While sibling lanes have developed adjacent mechanisms for capture integrity—notably `kumitate-shokunin`'s round-55 `source-capture` gate (binding `SOURCES.md` rows to byte lengths and sha256 digests in `.ufo/pins/source-captures.json`), `kasegi-shokunin`'s directory-manifest `capture-binding-check.py` and `source-recheck.py`, `chousa-shokunin`'s content-addressed `gate-records.py` (`corpus/captures/<24hex>.txt`), and `revenger-shokunin`'s span-verifying `audit_source_quotes.py`—none of them performs unified, in-census byte verification and normalized quote read-through directly against a registry's capture location column. Furthermore, no sibling lane currently cites RFC 9530 ("Digest Fields for HTTP") or any digest-vs-representation foundation; kagi's admission of S166 is fleet-unique and entirely collision-free across all sibling registries.

---

## 2. Sibling-Overlap Hit Table

Across the 20 sibling lanes (`/home/vgpnk/Projects/shokunin/*-shokunin`) and fleet root documentation (`*.md`), searches were conducted for:
- **(a)** Gates that re-read a declared capture's bytes or locate a declared quote against a registry row;
- **(b)** Source registries with a capture-location column;
- **(c)** Rows citing RFC 9530 or a digest-vs-representation source;
- **(d)** Capability table rows for capture binding.

| Category | Lane | File & Line | What it Enforces | Relation to Kagi C1 |
|---|---|---|---|---|
| **(a) Gate** | `revenger-shokunin` | `corpus/audit_source_quotes.py:85-108, 123-156` | Validates fetch receipts against `corpus/SOURCES.md`: re-reads `raw/<sid>.body`, verifies `sha256 == fetch_sha256`, `len(body) == length`, UTF-8 validity, and that the quote appears verbatim at recorded slice span `body[start:end]`. | **Adjacent / Extends**: Checks byte digest, length, and quote presence, extending to exact byte span coordinates; operates via per-row JSON receipts rather than inline registry columns. |
| **(a) Gate** | `kumitate-shokunin` | `scripts/source-capture.mjs:34-50, 160-220` | Mechanically binds every opened `SOURCES.md` row to committed capture bytes declared in `.ufo/pins/source-captures.json`; asserts regular file, no path escape, recomputes crypto sha256 and byte length. | **Adjacent / Precursor**: Rigorously verifies byte and size integrity of declared captures for registry rows, but does not locate quotes in the capture body. |
| **(a) Gate** | `kasegi-shokunin` | `corpus/instruments/capture-binding-check.py:93-130` | Rule E walks `corpus/source-snapshots/`, binds manifest records to `SOURCES.md` rows, enforces regular files, sha256 equality over capture bytes, and byte length. | **Adjacent**: Validates snapshot file existence and sha256 equality, but quote verification is delegated to a separate tool. |
| **(a) Gate** | `kasegi-shokunin` | `corpus/instruments/source-recheck.py:85-115` | Re-checks pinned quotes against captured text snapshots (`.txt`), verifying normalized substring occurrence and line anchors for non-unique quotes. | **Adjacent**: Performs quote substring and anchor verification against text snapshots, operating over directory manifests rather than a unified census gate. |
| **(a) Gate** | `chousa-shokunin` | `tools/gate-records.py:40-55, 120-210` | Mechanically audits `GATE-RECORD` lines in round lessons against `corpus/SOURCES.md`, `corpus/captures/<24hex>.txt`, and `refetch.tsv`; verifies content-addressed key (`sha256(url)[:24]`), sha256 prefix, and quote occurrence in normalized capture text (`QUOTE_ABSENT`). | **Adjacent**: Checks capture bytes, sha256 prefix, and quote occurrence against local text files, but checks lesson markdown records rather than registry rows, and requires content-addressed filename syntax. |
| **(a) Gate** | `kotodama-shokunin` | `tools/check-gate-captures.py:17-45` | Checks markdown table rows in lesson `## Gate` sections: verifies named capture file exists under evidence dir and matches declared sha256 (64-hex exact or 16-hex prefix). | **Adjacent**: Checks capture file existence and sha256 prefix for lesson Gate tables; quote word count cap is handled by a separate script (`check-gate-quotes.py`). |
| **(a) Gate** | `kaidoku-shokunin` | `tools/round-41/local-source-gate.py:35-50` | Binds out-of-lane local file paths in `corpus/SOURCES.md` to in-lane regular files declared in `corpus/evidence/local-sources.json`, checking file existence and sha256 equality. | **Adjacent**: Enforces local copy existence and sha256 for external file paths; does not handle web captures or quote location. |
| **(a) Gate** | `mori-shokunin` | `tools/mori-source-digest.py:35-50` | Verifies sha256 digests in `corpus/SOURCES.md` rows against pinned source copies in `corpus/evidence/` or `.ufo/waves/`. | **Adjacent**: Checks sha256 of pinned copies; does not locate quotes. |
| **(a) Gate** | `kake-shokunin` | `scripts/capture_delta.py:1-40` | Verifies capture tree receipts against retained bodies (sha256, byte count, wire headers) and compares cross-round capture drift. | **Adjacent**: Re-verifies capture receipts against bodies; quote verification occurred in historical round-specific counters (`c55_quote_truth.py`). |
| **(b) Registry Col** | `kagi-shokunin` | `corpus/source-fetches.tsv:35` | Column 16 (`location`) holds repo-relative capture paths for 36 rows and prose locations for 120 rows. | **Self (Kagi C1 surface)**: The subject of this round's census read-through gate. |
| **(b) Registry Col** | `kumitate-shokunin` | `.ufo/pins/source-captures.json:23` | Sidecar JSON: `captures[].path` maps `sourceId` to a repo-relative capture file. | **Adjacent**: Sidecar JSON schema rather than a column in a tabular registry. |
| **(b) Registry Col** | `kasegi-shokunin` | `corpus/source-snapshots/*/manifest.json` | Directory manifest: `sources[].path` maps source `id` to snapshot filename in that folder. | **Adjacent**: Partitioned directory manifests rather than a centralized registry table. |
| **(b) Registry Col** | `chousa-shokunin` | `corpus/evidence/round*/spans.tsv:1` | Manifest column `span_file` maps `id` to capture text path with `offset` column. | **Adjacent**: Span manifest rather than a primary source registry. |
| **(b) Registry Col** | `kaidoku-shokunin` | `corpus/evidence/local-sources.json:5` | Sidecar JSON: `sources[].copy` maps external source paths to in-lane copy paths. | **Adjacent**: Sidecar mapping for external paths. |
| **(b) Registry Col** | `tsukuroi-shokunin` | `corpus/lessons/round-14.md:17` (et seq.) | Column `Exact location` / `Location` in lesson `## Gate` tables. | **Adjacent**: Records prose section headings (e.g. `section 4.2`), analogous to kagi's prose location format. |
| **(b) Registry Col** | *(all 20 siblings)* | `corpus/SOURCES.md:1` | All 21 lanes use the canonical 11-column GFM table (`id \| source \| kind \| tier \| scope \| anchor \| teaches \| status \| opened \| recheck \| used-by`). Zero lanes have a capture-location column in `SOURCES.md`. | **Adjacent / Standard**: The canonical 11-column fleet standard is respected across all lanes. |
| **(c) RFC 9530** | `kagi-shokunin` | `plans/round-67.md:30, 129` | Opens S166 for RFC 9530 §1.2 ("Digest Fields for HTTP") with located quote. | **Self (Round 67 target)**: Grounding row for representation digest binding. |
| **(c) RFC 9530** | *(all 20 siblings)* | `none:0` | **Zero rows** citing RFC 9530, RFC 3230, RFC 5843, or "digest-vs-representation" across all sibling registries, lessons, and fleet docs. | **None / Collision-free**: No sibling lane currently references this standard. |
| **(d) Capability** | `kumitate-shokunin` | `SCORECARD.md:1995` | `source-capture` (round 55): "Bind every opened `corpus/SOURCES.md` `S###` row to committed capture bytes — sha256 + byte size + capture date in `.ufo/pins/source-captures.json` — or an explicit exemption; capture path-escape, symlink, absent, hash-/bytes-mismatch, uncaptured rows..." | **Adjacent / Precursor**: Mechanically enforces byte and size binding for all opened registry rows, but does not locate quotes. |
| **(d) Capability** | `kake-shokunin` | `SCORECARD.md:203` | `Capture-to-capture drift gate (round 82)`: Re-verifies capture receipts against retained bodies (sha256, byte count, headers) and reports cross-capture drift. | **Adjacent**: Focuses on capture-to-capture differential drift. |
| **(d) Capability** | `kake-shokunin` | `SCORECARD.md:201` | `Quote-class ledger for cited source spans` (round 50): Classifies quotes as `raw-substring` vs `collapsed-only` against retained blobs. | **Adjacent**: Classifies quote formatting classes against retained HTML/text blobs. |
| **(d) Capability** | `kake-shokunin` | `SCORECARD.md:212, 234` | `Append-block quote-truth gate, article-bound` (round 55) & `Capture-once / audit-offline re-derivation chain` (round 81). | **Adjacent**: Round-specific quote-truth and offline header audits. |
| **(d) Capability** | `kasegi-shokunin` | `SCORECARD.md:307, 308` | `capture-secret-scan` (round 87) & `capture-intake-gate` (round 90): Scans captures for credential material before commit/intake. | **Adjacent**: Governs credential leakage in captures. |
| **(d) Capability** | `kotodama-shokunin` | `SCORECARD.md:70` | `article paragraph locator` (round 86): Locates quotes in MediaWiki article captures by paragraph ordinal. | **Adjacent / Extends**: Specialized quote location by structural paragraph ordinal. |
| **(d) Capability** | `kaidoku-shokunin` | `SCORECARD.md:626, 627` | `local raw-quote/heading regression audit` (round 25) & `retained REA Ghidra-session log capture` (round 25). | **Adjacent**: Specialized to Ghidra session logs and local file copies. |
| **(d) Capability** | `kagi-shokunin` | `SCORECARD.md:708` | `located-quote gate over committed capture bodies` (round 38, `quote-locate.py`): Located quotes byte-for-byte in committed bodies over `corpus/quote-bodies.tsv`. | **Self (Direct ancestor)**: Historical offline predecessor; round 67 C1 promotes read-through into the primary standing gate `corpus/sources-census.sh`. |

---

## 3. RFC 9530 Duplicate-URL Collision Adjudication

**Finding:** **Zero duplicate-URL collisions.**
1. **Intra-lane sibling registries**: Every sibling lane maintains an append-only `corpus/SOURCES.md` that enforces URL uniqueness across its own rows. Full-text regex search across all sibling registries for `9530`, `rfc9530`, `rfc 3230`, `rfc 5843`, and "digest fields" returned zero matches. If any sibling lane subsequently adopts RFC 9530 (`https://www.rfc-editor.org/rfc/rfc9530` or `https://datatracker.ietf.org/doc/rfc9530/`), it will not collide with any existing URL in that sibling's registry.
2. **Cross-lane registry independence**: Source registries are strictly lane-scoped. Duplicate URLs across distinct lanes are standard fleet practice (e.g. RFC 8259 is cited in `kake`, `kengaku`, `kotoba`, `mado`, and `kumitate`).
3. **Kagi intra-registry status**: In `kagi-shokunin`, S166 is the sole row opening RFC 9530 this round, avoiding the duplicate-URL rejection trap identified in round 66 (M66-10 / S164 vs S165).

---

## 4. UFO-FSD Connector Move: Provenance Registry Completeness Contract (PRCC)

As UFO-FSD Connector, I propose one non-obvious synthesis that improves the round's declared axes (**freshness** and **calibration**) without harming any other.

### 4.1 Evidence & Defect Analysis
1. **Asymmetric census coverage**: Kagi's primary registry `corpus/SOURCES.md` currently holds 157 table rows (S001–S164 at BASE, plus S166 opened this round). In contrast, the secondary provenance table `corpus/source-fetches.tsv` holds only 156 data rows (S001–S156, created in round 23/24).
2. **Silent exclusion of modern rows**: In `corpus/sources-census.sh:392`, the gate enforces that every row in `source-fetches.tsv` must exist in `SOURCES.md` (`[[ -v FURL[$fid] ]] || finding SC_FETCH "id=$fid not-a-registry-row"`). However, the inverse check does not exist: rows S157 through S166 present in `SOURCES.md` are completely absent from `source-fetches.tsv`, meaning newly admitted sources silently bypass all `SC_FETCH` and `SC_CAPTURE` read-through checks.
3. **Frozen population lock**: In `plans/round-67.md` §C1, Guard (a) rigidly requires:
   `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)`
   Because `36 + 120 = 156`, adding S166 to `corpus/source-fetches.tsv` during round 67 would increase `path_rows` to 37 (or `prose` to 121), which would immediately fail Guard (a).
4. **Sibling synthesis**: Sibling lane `kumitate-shokunin` solved this exact vulnerability in round 55 (`scripts/source-capture.mjs`, SCORECARD:1995) by enforcing **total registry accounting**: every single opened row in `SOURCES.md` must resolve to either an active capture entry (with regular file, sha256, and byte count) or an explicit, declared exemption in `exemptions: [{ids: [...], reason: "..."}]`; an uncaptured, unexempted row fails with `DRIFT uncaptured`.

### 4.2 Affected Axes
- **Freshness (improves)**: Ensures all future admitted sources (starting with S166's committed capture `.ufo/waves/round-67/capture/S166.body`) undergo automated capture-byte and quote read-through rather than silently terminating at prose-level declarations.
- **Calibration (improves)**: Reconciles the population divergence between `corpus/SOURCES.md` and `corpus/source-fetches.tsv`, eliminating the silent exemption loophole and preventing recurrences of QM92 / QM94.
- **Harms none**: Operability, coverage, depth, and adjacency remain at line 9.

### 4.3 Proposed Move: Provenance Registry Completeness Contract (PRCC)
Establish a two-phase contract:
- **Phase 1 (Immediate Round 67 Posture — Inviolable Freeze Compliance)**:
  - Do not edit `corpus/source-fetches.tsv` to add S166. Apply only the single-line col-13 re-cut for S115 proposed by `R67ExecQuoteFix`, preserving the exact 156-row tally (`path_rows=36 bound=36 located=36 prose=120`) so that C1 Guard (a) passes cleanly.
  - S166 enters `corpus/SOURCES.md` and `corpus/knowledge/source-capture-binding.md`, with its capture committed at `.ufo/waves/round-67/capture/S166.body` (verified: 67152 B, sha256 `544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a`, quote locate count 1).
- **Phase 2 (Immediate Post-Freeze Evolution — PRCC Adoption)**:
  - Update `corpus/sources-census.sh` to enforce bidirectional accounting: every mined/opened row in `corpus/SOURCES.md` must have a corresponding entry in `corpus/source-fetches.tsv`, or an explicit declared exemption (e.g. `exemption=historical-inrow-pin` or `exemption=unretained-transient`).
  - Update future C1-style counters to assert dynamic parity (`bound == path_rows`, `located == path_rows`, `path_rows + prose + exemptions == total_sources`) rather than hard-coding legacy constants (`path_rows=36`), allowing new rows with captures to enter without breaking standing counters.

### 4.4 Risks & Second-Order Effects
- **Runtime surface**: Adding bidirectional accounting to `corpus/sources-census.sh` runs entirely in-process within bash/awk; runtime impact is <0.05 s, well within the 100 s selftest ceiling.
- **Contract surface**: Leaves the frozen round-67 predicate `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` completely unmutated during this wave.
- **Substrate surface**: Completely hermetic and repo-local; requires no network, no package installs, and no host privileges.
- **Verification surface**: Prevents false-clean passes where a newly opened source row declares a capture that holds another body or a non-locating quote, closing the QM94 blindness window for rounds 68+.

### 4.5 Verification Evidence
1. **Fleet scan receipt**: `.ufo/waves/round-67/w1/R67Connector/rfc9530-fleet-scan.txt` confirms zero RFC 9530 hits across all sibling lanes.
2. **Tabular scan receipt**: `.ufo/waves/round-67/w1/R67Connector/scan-census.tsv` records the 26 investigated evidence points across the 4 required categories.
3. **S166 capture verification receipt**: `.ufo/waves/round-67/w1/R67Connector/s166-capture-verification.txt` proves that `.ufo/waves/round-67/capture/S166.body` matches its declared sha256 (`544dbb7d...`), size (67152 B), and locates §1.2 quotes under `rendered-text-v1`.

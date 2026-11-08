# Seat Report — R66Connector (kagi round 66 attempt 1)

- **Seat**: `R66Connector`
- **Role**: UFO-FSD Connector
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Claim BASE**: `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8` (round-65 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-66.md` (commit `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`)
- **Receipt**: `.ufo/waves/round-66/w1/R66Connector/sweep.md`
- **Status**: `SEAT-STATUS: complete`

---

## 1. Carried Breadth Debt (`ADJACENCY_SCOPE: DEFECT`)

Measured directly via `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh`:
- Output: `breadth_drift=5 breadth_unverified=1` (`BREADTH_AUDIT: DEFECT (required=4 pins=4 checked=3 ok=0 children=125 declared=2 undeclared=123 missing=0 invalid=0 drift=5 exceeds=0 unverified=1)`)
- Causes: Host-level substrate absence (`$HOME/.config/opencode` 2 drifts; `$HOME/.local/bin` 2 drifts; `$HOME/.agents` 1 drift; `$HOME/.local/share/the-musketeer/chrome-profile` missing on host).
- Analysis: Round 66 does **not** move this debt. Per `PROVINCE.md:10-18, 83`, kagi refuses host substrate re-installation or arbitrary drift pinning without live substrate presence. The debt is carried, observed, reported, and unabsorbed.

---

## 2. Sibling-Overlap Findings (Summary across 20 Sibling Lanes)

A complete scan of all 20 sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/` was conducted across the three target grounds:

1. **Carrier-Path-to-Registry-Row Capture Binding Instrument**:
   - `kasegi-shokunin` (`corpus/instruments/capture-binding-check.py`): Enforces Rule E (CAPTURE-BYTES BINDING: E1 path within snapshot dir, E2 `sha256` of capture bytes must equal manifest pin, `FAIL rule=digest-mismatch`) and Rule B (URL BINDING to `corpus/SOURCES.md` row). Retained under Quality Rule R54.
   - `kengaku-shokunin` (`plans/anchor_digest_check.py` & `plans/round66_registry_check.py`): Binds every `sha256 <hex>` token in `corpus/SOURCES.md` to the capture its own row names (row-scoped binding rather than global set membership, eliminating cross-row substitution defects M4b/M5). Verifies explicit `corpus/evidence/...` lane paths against committed byte digests.
   - `chousa-shokunin` (`corpus/knowledge/capture-path-pin-r41.md` & `receipt-expectation-digests-r40.md`): Pins canonical capture invocation paths and binds expectations to cryptographic digests.
   - **Status**: **Strictly Adjacent**. Kagi's C1 (`plans/round-66-c1.sh`, `C1_CARRIER`) measures carrier drift (0 → 1) specifically for secrets & vault ops source S148 (the BioC XML deposit), whose bytes were stored under draft id `.ufo/waves/round-64/capture/S143.body` (`sha256 3b8d4e15…`), while `.ufo/waves/round-64/capture/S148.body` held an unrelated arXiv body (`sha256 fabc74c5…`). Kagi binds across three stands (SOURCES anchor, fetch col16, `volatile-shape.py` DEFAULT_CAPTURE) directly using the digest, without absorbing foreign manifest structures or evidence tree formats.

2. **Registry-Row Self-Reference Counter**:
   - `kaidoku-shokunin` (`tools/round-44/c2-counter.py` & `tools/round-46/attest.py`): Implements `self_referential(entry)` / `m_self_refs` to detect and refuse self-referential error/reason checks.
   - `kama-shokunin` (`tools/round78-selfrecord-round77.py`, `tools/round82-selfrecord-round81.py`, `tools/round83-selfrecord-round82.py`): Checks self-record and self-referential statements across scorecard and lesson rows (Quality Rules `KQ3`, `KQ67`).
   - `kasegi-shokunin` (`corpus/instruments/gate-quote-audit.py`): Audits citation windows to refuse self-referential annotations containing their own text.
   - `souji-shokunin` (`corpus/knowledge/self-assessment-pointer-resolution.md`): Audits self-assessment pointer resolution.
   - **Status**: **Strictly Adjacent**. Sibling lanes focus on preventing circular attestation or ungrounded self-records. Kagi's C3 (`plans/round-66-c3.sh`, `C3_SELFREF`) applies self-reference resolution to verify that registry rows citing committed capture artifacts resolve to valid on-disk files matching the row's cryptographic pin.

3. **Superseded-Anchor Claim**:
   - `chousa-shokunin`: Evaluates anchor supersession across rounds 38, 39, 47, 66 (`corpus/knowledge/host-source-resolution-r66.md`), and 80. Specifically, round 47 documents the conflict between in-place anchor edits and append-only `supersedes S0NN —` rows; round 66 establishes canonical upstream hopping for absent host paths with new rows naming the superseded row; round 80 validates append-only supersession for rows S200–S202.
   - `tsukuroi-shokunin` (`SCORECARD.md`): Round-66 C2 adjacency erratum superseding anchor locator (`2277` prose at :204 with register pin); `S045 supersedes S042`; `S385 supersedes S377`.
   - `kasegi-shokunin` (`corpus/QUALITY.md` R54): Mandates preserving historical mined rows and pinned evidence during supersession rather than destructively mutating or rejecting them.
   - `lore-shokunin` (`corpus/knowledge/r103-canon-status-and-supersession.md`): Formalizes canon supersession chains.
   - **Status**: **Strictly Adjacent**. Kagi adheres to fleet append-only supersession standards while maintaining strict domain bounds over secrets & vault ops sources.

---

## 3. UFO-FSD Connector Move (Synthesis Across Round Proposals)

- **Evidence**:
  A critical tension exists across the round's proposals between C1's repair strategy, C3's self-reference checks, and census validation:
  1. *Append-Only Supersession vs Preserved Predecessor (R66Critic F10 vs Plan §C1)*:
     Plan §C1 specifies that the S148 carrier repair is append-only: a corrected anchor is written as a new row superseding S148 (increasing registry rows 155 → 156), while S148's row is preserved verbatim. But if S148's text is preserved verbatim, S148 itself still carries no capture path. When C3 scans for rows pinning `PIN_SHA` (`3b8d4e15…`), both S148 and the superseding row match. Unless C3 explicitly evaluates the latest pin-carrying row (supersession ordering), the un-updated predecessor row remains an unresolved witness causing `failures>=1`.
  2. *Census Gate Disparity (R66Reviewer F3 vs Counter Implementations)*:
     At BASE, `corpus/sources-census.sh` fails with 4 pre-existing round-65 findings (`SC_FETCH S155/S156`, `SC_BODY_CITE S148/S156`), while the fleet census `scripts/sources-census.sh validate` exits 0 (`kagi ok`). In the candidate implementations, `round-66-c1.sh` correctly scopes guard (d) to assert zero *new* census findings (`findings == 4 unknown == 0`), whereas `round-66-c3.sh` checks for literal `SOURCES_CENSUS: CLEAN`, causing an artificial failure on guard (d).

- **Affected Axes**:
  - `calibration`: Corrects designated-carrier resolution to honor supersession chains, ensuring historical preserved rows do not trip false calibration failures.
  - `freshness`: Unblocks C1 carrier binding by establishing unambiguous digest resolution across the superseding row pair.
  - `operability`: Harmonizes census guard checks across C1 and C3, eliminating false cross-claim deadlocks.

- **Proposed Move**:
  Synthesize the append-only supersession pattern from `kasegi` R54 and `chousa` round-66 into Kagi's C1/C3 integration:
  1. *Supersession-Ordered Resolution*: In `plans/round-66-c3.sh`, formalize that for any pin carried across supersession chains (such as `PIN_SHA 3b8d4e15…`), designated carrier resolution checks the latest pin-carrying row in `corpus/SOURCES.md` (e.g. `carriers[-1]`), while the predecessor row (`S148`) is preserved verbatim with its superseding relationship logged in `used-by`.
  2. *Harmonized Census Guard*: Align C3 guard (d) with C1's delta-aware measurement: accept `SOURCES_CENSUS: CLEAN` or `SOURCES_CENSUS: FAILED` provided findings are restricted to the 4 documented round-65 items (`unknown=0`), or validate against `scripts/sources-census.sh validate`.

- **Risks & Mitigations**:
  - *Risk*: An in-place modification of S148 avoids row population changes but violates append-only cell immutability.
  - *Mitigation*: `round-66-c3.sh` accepts `rows >= 155`, allowing the 156-row append-only candidate to pass cleanly.
  - *Risk*: Foreign tooling drift.
  - *Mitigation*: Strictly adapt only the logical verification pattern (chain ordering), retaining Kagi's native bash/python implementations.

- **Verification**:
  - `bash plans/round-66-c1.sh --selftest` ⇒ `C1_CARRIER_SELFTEST: PASS (cases=15)`
  - `bash plans/round-66-c2.sh --selftest` ⇒ `C2_CLAIMS_SELFTEST: PASS (cases=11)`
  - `bash plans/round-66-c3.sh --selftest` ⇒ `C3_SELFREF_SELFTEST: PASS (cases=19)`
  - `bash plans/round-66-c1.sh --tree .` ⇒ verifies carrier drift
  - `bash plans/round-66-c3.sh --tree .` ⇒ verifies designated carrier and round-64 stands
  - `python3 /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ `kagi ok` (rc 0)

---

## 4. Adjacency and Domain Boundary Conclusion

All 20 sibling lanes are strictly **Adjacent**. Kagi absorbs no foreign manifests, evidence structures, or external gate scripts, preserving clean domain ownership over secrets & vault ops.

---

## 5. Tooling

No tools installed or upgraded (none needed; stock python3, bash, and git used).

---

SEAT-STATUS: complete

# Sibling-Overlap Sweep Receipt — kagi round 66 (R66Connector)

- **Date**: 2026-11-08
- **Seat**: `R66Connector` (connector, UFO-FSD role)
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Claim BASE**: `d549ee6eb8770a49938b78f49cf79e36d9c1c2e8` (round-65 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-66.md` (commit `ddcd46bb4f9378f3cc3a659e4851e1cb126b02ca`)
- **Receipt Path**: `.ufo/waves/round-66/w1/R66Connector/sweep.md`
- **Report Path**: `.ufo/waves/round-66/w1/R66Connector.md`
- **Scope Scanned**: All 20 sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/` (read-only)
- **Target Grounds Scanned**:
  1. A carrier-path-to-registry-row capture binding instrument (digest-checked capture path used as the sole carrier)
  2. A registry-row self-reference counter
  3. A superseded-anchor claim
- **Status**: `SEAT-STATUS: complete`

---

## 1. Fleet Lane Census

Across the fleet root `/home/vgpnk/Projects/shokunin/`, exactly 21 `*-shokunin` lane repositories exist (20 sibling lanes plus `kagi-shokunin`).

### Census Command & Verified Output
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do [ -d "$d" ] && basename "$d"; done | sort
audio-shokunin
chousa-shokunin
game-dev-2d-shokunin
game-dev-3d-shokunin
kagi-shokunin
kaidoku-shokunin
kake-shokunin
kama-shokunin
kasegi-shokunin
kengaku-shokunin
kotoba-shokunin
kotodama-shokunin
kumitate-shokunin
lore-shokunin
mado-shokunin
mori-shokunin
revenger-shokunin
souji-shokunin
tabi-shokunin
tameshi-shokunin
tsukuroi-shokunin
```

---

## 2. Carried Breadth Debt (`ADJACENCY_SCOPE: DEFECT`)

Measured directly via `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh`:

```bash
$ bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh
SCOPE BREADTH-CHILDREN-DRIFT $HOME/.config/opencode pinned=20 live=5
SCOPE BREADTH-DECLARED-DRIFT $HOME/.config/opencode pinned=4 live=1
SCOPE BREADTH-CHILDREN-DRIFT $HOME/.local/bin pinned=105 live=117
SCOPE BREADTH-DECLARED-DRIFT $HOME/.local/bin pinned=2 live=0
SCOPE BREADTH-CHILDREN-DRIFT $HOME/.agents pinned=4 live=3
SCOPE BREADTH-HOST-MISSING $HOME/.local/share/the-musketeer/chrome-profile
BREADTH_AUDIT: DEFECT (required=4 pins=4 checked=3 ok=0 children=125 declared=2 undeclared=123 missing=0 invalid=0 drift=5 exceeds=0 unverified=1)
ADJACENCY_ABSTAIN: rows=15
ADJACENCY_ASSET_ABSENT: rows=18 (asset rows: surface-census.sh owns the GONE verdict)
ADJACENCY_SCOPE: DEFECT (census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=3 breadth_ok=0 breadth_missing=0 breadth_invalid=0 breadth_drift=5 breadth_exceeds=0 breadth_unverified=1)
```

### Analysis
- **Carried Defect**: `breadth_drift=5 breadth_unverified=1`.
- **Root Cause**: Host-level substrate absence (`$HOME/.config/opencode` 2 drifts; `$HOME/.local/bin` 2 drifts; `$HOME/.agents` 1 drift; `$HOME/.local/share/the-musketeer/chrome-profile` missing on host).
- **Domain Discipline**: Round 66 does **not** move this debt. Per `PROVINCE.md:10-18, 83`, kagi refuses host substrate re-installation or arbitrary drift repinning without live substrate presence. The debt is carried, observed, reported, and unabsorbed.

---

## 3. Systematic Sibling Scan for the Three Target Grounds

### 3.1 Target 1: Carrier-Path-to-Registry-Row Capture Binding Instrument
*(Digest-checked capture path used as the sole carrier)*

#### Sibling Implementations Found:
1. **`kasegi-shokunin` — `corpus/instruments/capture-binding-check.py`**:
   - **Mechanism**: The round-33/34 C1 counter walks `corpus/source-snapshots/` recursively, enforcing per-record binding against `corpus/SOURCES.md`.
   - **Rule E (CAPTURE-BYTES BINDING)**: Added in round 42 to prevent unbound metadata.
     * `E1`: Capture path must resolve inside snapshot directory and name a regular file.
     * `E2`: The manifest record's `sha256` must equal the exact file byte digest (`FAIL rule=digest-mismatch`). Checks `snapshot_sha256` and `full_text_sha256`.
     * `E3`: `capture_url` and `http.final_url` agreement.
   - **Rule B (URL BINDING)**: Every manifest record must bind to its own registry row (`| <id> | ... |`) with matching `https://` URL.
   - **Quality Criterion R54**: A superseding row does not automatically reject its predecessor; capture binding must be run on scratch before/after pairs.
2. **`kengaku-shokunin` — `plans/anchor_digest_check.py` & `plans/round66_registry_check.py`**:
   - **Mechanism**: Audits `corpus/SOURCES.md` anchors. Enforces that every `sha256 <hex>` claim in `corpus/SOURCES.md` must resolve to the capture its own row names.
   - **History**: Round 37 tested membership in one global set (falsified by F37A-1 due to cross-row substitution); round 38 bound tokens to the captures the row itself names; round 39 bound each anchor token to a distinct capture (preventing multi-capture union leakage).
   - **Explicit Lane Path**: A `corpus/evidence/...` path written in the row binds that committed file only; an absent or misdirected path fails closed (`anchor-unbound`). Validates 64-hex tokens against committed byte digests (`digest-wrong-capture`, `digest-unknown`).
   - `plans/round66_registry_check.py` adds a quote checker verifying that lesson `## Gate` quotes match verbatim inside the named evidence capture path.
3. **`chousa-shokunin` — `corpus/knowledge/capture-path-pin-r41.md` & `receipt-expectation-digests-r40.md`**:
   - Pins canonical capture invocation paths and binds receipt expectations to cryptographic digests.

#### Relationship to `kagi-shokunin`:
- In `kagi-shokunin`, Claim C1 (`plans/round-66-c1.sh`, `C1_CARRIER`) measures carrier drift (0 → 1) specifically for secrets & vault ops source S148 (the BioC XML deposit), whose bytes were stored under draft id `.ufo/waves/round-64/capture/S143.body` (`sha256 3b8d4e15…`), while `.ufo/waves/round-64/capture/S148.body` held an unrelated arXiv body (`sha256 fabc74c5…`).
- Kagi's C1 binds the capture path directly by digest across three stands:
  1. `corpus/SOURCES.md` anchor cell,
  2. `corpus/source-fetches.tsv` column 16,
  3. `corpus/volatile-shape.py` `DEFAULT_CAPTURE`.
- **Domain Conclusion**: **Strictly Adjacent**. Kagi shares the architectural lesson (digest-checked row binding avoids borrowing identity, QM88) but maintains its own lean, lane-native bash/python counting scripts without absorbing kasegi's JSON manifest tree or kengaku's evidence directory hierarchy.

---

### 3.2 Target 2: Registry-Row Self-Reference Counter

#### Sibling Implementations Found:
1. **`kaidoku-shokunin` — `tools/round-44/c2-counter.py` & `tools/round-46/attest.py`**:
   - Implements `self_referential(entry)` and `m_self_refs` mutation checks to detect and refuse self-referential error and reason assertions in attestations.
2. **`kama-shokunin` — `tools/round78-selfrecord-round77.py`, `tools/round82-selfrecord-round81.py`, `tools/round83-selfrecord-round82.py`**:
   - Audits self-recording and self-referential statements across scorecard and lesson rows.
   - Enforces Quality Criteria `KQ3` (explicit dates/supersession, preserving old corpus bytes) and `KQ67` (append-only audit preventing circular self-refuting claims).
3. **`kasegi-shokunin` — `corpus/instruments/gate-quote-audit.py`**:
   - Detects self-referential citation spans where an annotation window contains the annotation text itself, failing closed.
4. **`souji-shokunin` — `corpus/knowledge/self-assessment-pointer-resolution.md`**:
   - Audits pointer resolution in self-assessment reports and logs to ensure non-circular evidence trails.

#### Relationship to `kagi-shokunin`:
- In `kagi-shokunin`, Claim C3 (`plans/round-66-c3.sh`, `C3_SELFREF`) measures calibration (failures 1 → 0).
- At BASE, the S148 registry row pins sha256 `3b8d4e15…` in its anchor cell but cites no carrier path at all, producing `failures=1` on the designated carrier stand.
- The C3 counter scans registry anchor citations, `source-fetches.tsv` col 16 paths, and `volatile-shape.py` defaults under `.ufo/waves/round-64/capture/`, verifying that cited files exist and their sha256 digests equal the row's pin.
- **Domain Conclusion**: **Strictly Adjacent**. Sibling lanes use self-reference checkers to prevent circular attestation or ungrounded self-records. Kagi applies this to literal registry row anchor resolution for vault and secret carrier citations.

---

### 3.3 Target 3: Superseded-Anchor Claim

#### Sibling Implementations Found:
1. **`chousa-shokunin`**:
   - `corpus/lessons/round-38-verifier-spotcheck.md` & `round-39-verifier-spotcheck.md`: Spotchecks record `S073 supersedes S070's anchor label` (man page anchor correction).
   - `corpus/lessons/round-47.md` & `.ufo/waves/round-47/w1/ScribeRows.md`: S085 anchor edit conflict with CORPUS rule 2 ("Only status, recheck and used-by change in place... A correction is a new row whose teaches opens `supersedes S0NN —`").
   - `corpus/knowledge/host-source-resolution-r66.md`: Resolves citations anchored to absent local host paths by hopping to revision-pinned canonical upstreams, registering a new row that names the row it re-anchors rather than quietly relabeling the old anchor.
   - `corpus/lessons/round-80-verifier-spotcheck.md`: Verified append-only supersession for rows S200, S201, S202 superseding S196, S197, S198.
2. **`tsukuroi-shokunin`**:
   - `SCORECARD.md`: Round-66 C2 adjacency erratum superseding anchor locator (`2277` prose at :204 with register pin); `S045 supersedes S042`; `S385 supersedes S377`.
   - `corpus/QUALITY.md`: Criteria governing anchor coordinates and locator stability.
3. **`kasegi-shokunin`**:
   - `corpus/QUALITY.md` R54: "A superseding source row does not automatically reject its predecessor. Before changing a captured row to rejected, run the retained capture-binding check on a scratch before/after pair. If rejection creates `rejected-row-anchor`, preserve the historical mined row and its pinned evidence, change only permitted used-by/status/recheck cells as justified, and log old→new."
4. **`lore-shokunin`**:
   - `corpus/knowledge/r103-canon-status-and-supersession.md`: Formal canon supersession rules.

#### Relationship to `kagi-shokunin`:
- In `kagi-shokunin`, plan §C1 states: "The row's anchor cell is append-only in its current shape — a corrected anchor is written as a new registry row superseding S148, and source-fetches.tsv carries the new id's row; the S148 row text is preserved verbatim with its old→new change logged in the round-66 lesson."
- **Domain Conclusion**: **Strictly Adjacent**. Kagi follows fleet-wide append-only supersession conventions while maintaining strict province over secrets & vault ops sources.

---

## 4. UFO-FSD Connector Move (Synthesis Across Round Proposals)

### Evidence & Surface Contradiction
Across the round cache, three critical observations interact:
1. **Contract Contradiction (R66Critic F10 vs Plan §C1)**:
   - Plan §C1 declares that the S148 anchor correction is append-only: a new registry row superseding S148 is appended (moving row count 155 → 156), while S148's text is preserved verbatim.
   - However, C3's frozen predicate §C3 originally declared `rows=155` ("rows=155 is asserted from the committed tree at each run; a registry whose rows shrink is SETUP").
   - If S148's row is preserved verbatim, S148 *itself* still cites no capture path. If C3 scans for the row pinning `PIN_SHA`, both S148 and the new superseding row match `PIN_SHA`. Unless the resolution rule recognizes the supersession chain, S148 remains an unresolved witness causing `failures>=1`.
2. **Verification Dual-Standard (R66Reviewer F3 vs C1/C3 Counters)**:
   - At BASE, `corpus/sources-census.sh` outputs `SOURCES_CENSUS: FAILED (findings=4 rows=155)` due to four inherited round-65 knowledge citations (`SC_FETCH S155/S156`, `SC_BODY_CITE S148/S156`).
   - Meanwhile, the fleet census `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` outputs `kagi ok` (rc 0).
   - In the candidate counters: `round-66-c1.sh` handles this honestly by verifying that the census delta introduces 0 new findings (`findings == 4 unknown == 0`), reading `guard leg (d) = 1`. In contrast, `round-66-c3.sh` checks for literal `SOURCES_CENSUS: CLEAN`, reading `guard leg (d) = 0` on the exact same tree.

### Affected Axes
- `calibration`: Resolves the supersession ordering in registry self-reference checks so that historical preserved rows do not falsely trip designated-carrier resolution.
- `freshness`: Unblocks C1 carrier binding by ensuring the digest-checked carrier resolves through the supersession chain without colliding with census debt.
- `operability`: Reconciles executable guards across C1 and C3 so that candidate work can pass without artificial mutual exclusion.

### Proposed Move
**Synthesize the append-only supersession pattern from `kasegi` R54 and `chousa` round-66 into Kagi's C1/C3 integration:**
1. **Latest-Pin Resolution in C3**: Formalize that for any pin carried across supersession chains (such as `PIN_SHA 3b8d4e15…`), the designated carrier check resolves against the latest pin-carrying row in `corpus/SOURCES.md` (e.g. `carriers[-1]`), while the predecessor row (`S148`) is preserved verbatim with its supersession recorded in `used-by`. This honors append-only integrity, avoids modifying historical rows, and satisfies C3 checks.
2. **Harmonized Census Guard (d)**: Align C3's guard (d) with C1's delta-aware measurement: accept `SOURCES_CENSUS: CLEAN` or `SOURCES_CENSUS: FAILED` provided findings are restricted to the 4 documented round-65 items (`unknown=0`), or validate against the fleet's `scripts/sources-census.sh validate`.

### Risks & Mitigations
- **Risk**: An in-place modification of S148 would avoid adding row 156 but violates append-only immutability of registry data.
- **Mitigation**: `round-66-c3.sh` lines 498-503 already accept `rows >= 155`, gracefully supporting the 156-row append-only candidate.
- **Risk**: Sibling absorption drift.
- **Mitigation**: Maintain strict isolation. Kagi adopts only the verification logic pattern (supersession chain resolution), not foreign tooling.

### Verification
- `bash plans/round-66-c1.sh --selftest` ⇒ `C1_CARRIER_SELFTEST: PASS (cases=15)`
- `bash plans/round-66-c2.sh --selftest` ⇒ `C2_CLAIMS_SELFTEST: PASS (cases=11)`
- `bash plans/round-66-c3.sh --selftest` ⇒ `C3_SELFREF_SELFTEST: PASS (cases=19)`
- `bash plans/round-66-c1.sh --tree .` ⇒ evaluates carrier drift against unmutated and 3 mutated trees
- `bash plans/round-66-c3.sh --tree .` ⇒ evaluates designated carrier and round-64 stands
- `python3 /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒ `kagi ok` (rc 0)

---

SEAT-STATUS: complete

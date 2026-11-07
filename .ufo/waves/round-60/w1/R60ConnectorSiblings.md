# R60ConnectorSiblings — Cross-Lane Overlap Scan: AppRole Custody, Shim Vectors, and Routed Defect Repair

- **Seat**: R60ConnectorSiblings (connector) · kagi round 60 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
- **Claim BASE**: `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2` (round-59 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-60.md` (commit `cd631737`)
- **Declared Axes**:
  - **C1 — Calibration**: Seven round-59 routed record defects resolved and re-checkable (`C1_ROUTED: value = UNRESOLVED over POP = 7 when GUARD = 1, else FAIL`; target 0, BASE 7).
  - **C2 — Operability**: Executed OpenBao AppRole `secret_id` custody trial (`C2_APPROLE_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 twice, each of the five falsifier shims flips exactly its designated test...`; target 5, BASE 0).
- **Observed Answering Model**: `google-antigravity/gemini-3.8-flash`
- **Receipts**: `.ufo/waves/round-60/build/R60ConnectorSiblings/sweep.md`
- **Scratch**: Allocated under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ConnectorSiblings/` (cleaned before yield)

---

## 1. Scope & Declared Axes

The round's declared axes per `plans/round-60.md`:
1. **C1 — Calibration (Target 0, BASE 7)**:
   - Resolves the 7 routed record defects from `corpus/lessons/round-59-verifier-spotcheck.md` (D1: `LOG.md:1965` ends with `dead seats __DEAD__`; D2: `corpus/lessons/round-59.md` R31 states a 32-case receipt while receipt reads 33 cases; D3: round-59 routed table repeats `R20`, `R21`, `R22` twice each; D4: `SCORECARD.md:1971` states 21 controls while receipt holds 20; D5: `SCORECARD.md:1975` cites `release-clock-candidate.txt` which is not in the tree; D6: round-59 Before -> after table names `75165a07` as measured commit while `c1-landed.txt` reads `160caf750dcf15892b78ec066e66bc605ba57a5c`; D7: `SKILL.md:847` registers transit trial with selftest cell `none — its own five shims...` rather than `--selftest`).
   - Evaluated by `plans/round-60-c1-check.py` and `plans/round-60-c1.sh` with active challenge injection and zero hardcoded comparisons.
2. **C2 — Operability (Target 5, BASE 0)**:
   - Acquires the OpenBao **AppRole `secret_id` custody** capability, executing five documented mechanics against throwaway in-memory dev servers: T1 `bind_secret_id` role authentication binding; T2 `secret_id_num_uses` single-use bounding; T3 `secret_id_ttl` expiry retirement; T4 `secret-id-accessor` custody lookup and destroy; T5 `secret_id_bound_cidrs` source-address network binding.
   - Evaluated by `corpus/openbao-approle-trial.sh` with designated falsifier shims `SH1..SH5` and an isolated hermetic `--selftest` mode.

---

## 2. Sweep Methodology & Exact Grep Commands

A comprehensive read-only sweep was executed across all 21 repositories under `/home/vgpnk/Projects/shokunin/*-shokunin/` and the staged package `/home/vgpnk/Projects/shokuknow/merge/kagi/` using GNU grep (`/usr/bin/grep`).

### Exact Grep Commands Executed

1. **Topic 1 — AppRole and `secret_id` Custody Primitives**:
   ```bash
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'approle|secret_id|bind_secret_id|secret-id-accessor|secret_id_bound_cidrs' <path>
   ```
2. **Topic 2 — Falsifier Shims and `--selftest` Gate Pattern**:
   ```bash
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -E 'KAGI_.*_SHIM|APPROLE_.*_SHIM|TRANSIT_.*_SHIM' <path>
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -E '[A-Z0-9_]+_SHIM' <path>
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -e '--selftest' <path>
   ```
3. **Topic 3 — `C1_ROUTED` Routed-Record Defect Checking Idiom**:
   ```bash
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -E 'C1_ROUTED' <path>
   ```

---

## 3. Sibling Overlap Survey (Per-Lane Breakdown)

All 20 sibling lanes were evaluated against the target tokens and patterns. In-lane baseline `kagi-shokunin` is included for comparative boundary definition.

| Sibling Lane | Paths / Line | What it Holds | Classification | Distinguishing Boundary & Context |
|---|---|---|---|---|
| `audio-shokunin` | *(none)* | *(no matches for crypto/approle/routed)* | **none** | Pure acoustic synthesis & PCM waveform verification; zero secrets or vault terms. |
| `chousa-shokunin` | `RevGrepModesA/matrix.sh:24,37`<br>`corpus/evidence/round50/c1-supplement.py:1` | Post-freeze supplementary evaluation counter (`c1-supplement.py`); mock grep logging (`GREP_SHIM_LOG`) | **adjacent** | Precedent for non-mutating supplements and CLI tool logging; zero vault, AppRole, or crypto mechanics. |
| `game-dev-2d-shokunin` | *(none)* | *(no matches)* | **none** | 2D game mechanics & scene graphs; zero vault or AppRole terms. |
| `game-dev-3d-shokunin` | `AGENTS.md:17,69` | `CURSOR_SHIM_PORT` / `CURSOR_SHIM_MAX_CONCURRENT` service configuration | **none** | Homonym: local background daemon port configuration; zero cryptographic or auth relevance. |
| `kaidoku-shokunin` | `.ufo/waves/luna-round-2/receipts/L7-mcp-tools-6.5.0.txt:11,14`<br>`tools/round-75/seam-probe.py:590,599` | Reverse-engineering MCP tool schema dump (`"secret_id"`); `TRUTHFUL_SHIM` / `LYING_SHIM` in seam probes | **none / adjacent** | `secret_id` hit is a JSON schema parameter for external 1Password CLI MCP tool; shims provide mock binary responses for ELF analysis. Zero OpenBao/Vault auth. |
| `kake-shokunin` | *(none)* | *(no matches)* | **none** | Web service caching and HTTP protocol analysis; zero vault or AppRole mechanics. |
| `kama-shokunin` | `tools/census-waiver-boundary.py:55,988`<br>`PROVINCE.md:190` | Parameterized test runner mock shims (`BOUNDARY_SHIMS_DRIFT`); routes vault ops to kagi | **adjacent** | Test harness uses shim concept for binary drift checking. `PROVINCE.md:190` explicitly yields secrets and vault operations to kagi. |
| `kasegi-shokunin` | `corpus/instruments/r44-routed-defects.py:1-60`<br>`PROVINCE.md:48` | Multi-limb routed defect checking with sha256 pins; disclaims secrets/vault to kagi | **adjacent** | Multi-limb defect verification without dynamic git-diff derivation. `PROVINCE.md:48` yields secrets and vault ops to kagi. |
| `kengaku-shokunin` | `plans/round59_c1_openssl_probe.py:263,337`<br>`plans/round71_c2_routed_defects.py:1-60` | Bubblewrap sandbox probe (`--unshare-all`) using `/stub/python` shim; static-tuple Mistakes row verification | **adjacent** | Sandbox environment uses tool shimming; defect checker verifies Mistakes rows against static tuples rather than git history. Zero AppRole mechanics. |
| `kotoba-shokunin` | `PROVINCE.md:63`<br>`DEFAULT_SHIMMER_PALETTE` in string dumps | String analysis; explicit disclaimer routing secrets, tokens, and vault ops to kagi | **none** | Zero crypto/approle terms; PROVINCE yields all vault operations to kagi. |
| `kotodama-shokunin` | *(none)* | *(no matches)* | **none** | Linguistic analysis and worldbuilding; zero vault or AppRole mechanics. |
| `kumitate-shokunin` | `scripts/surface-probe.mjs:242,1148`<br>`PROVINCE.md:27` | CLI wrapper shims (`SIGHTING_SHIM`, `FIXTURE_SHIM`) for tooling; disclaims secrets/vault to kagi | **adjacent** | CLI wrapper shim pattern for build tooling; zero vault or AppRole capabilities. `PROVINCE.md:27` yields vault ops to kagi. |
| `lore-shokunin` | *(none)* | *(no matches)* | **none** | Narrative consistency and schema validation; zero vault or AppRole mechanics. |
| `mado-shokunin` | *(none)* | *(no matches)* | **none** | Wayland compositor display protocol; zero vault or AppRole terms. |
| `mori-shokunin` | `PROVINCE.md:68` | Observability census tools; disclaims secrets/vault to kagi | **none** | PROVINCE:68 yields secrets and vault operations to kagi. |
| `revenger-shokunin` | `reports/round-100/cap_apk_probe.py:33` | Decoder binary PATH resolution for mock tool shims | **adjacent** | Uses PATH resolution to test mock shims, but holds zero vault or cryptographic auth mechanics. |
| `souji-shokunin` | `tests/runner-25.sh:201,270`<br>`PROVINCE.md:36` | Mock git execution logging (`GIT_SHIM_LOG`); disclaims secrets/vault to kagi | **adjacent** | Fixture testing with git mock shims; Obsidian vault note hygiene. `PROVINCE.md:36` yields HashiCorp/OpenBao vault ops to kagi. |
| `tabi-shokunin` | `.ufo/waves/round-38/counters/c1-routed-defects.mjs:253,258`<br>`SKILL.md:2970` | Node.js routed defect counter checking receipts and commits (`C1_ROUTED_DEFECTS`); yields 1Password bridge to kagi | **adjacent** | Routed defect checking via file/receipt existence checks; `SKILL.md` explicitly recognizes 1Password native-messaging bridge as kagi's custody surface. |
| `tameshi-shokunin` | `.ufo/evidence/round-25/c1-measure.py:140,151`<br>`T90C2-tool-neuter.py:14,27` | Mutation defect-kill disposition counter for routed items (`C1_ROUTED: dispositioned=3/3`); tool neutering mocks | **adjacent** | Evaluates routed items via test mutation sweeps against SCORECARD tables, but does not derive historical metrics from git revisions. Zero AppRole mechanics. |
| `tsukuroi-shokunin` | `tools/check-r75-routed-r76.py:1-60`<br>`PROVINCE.md:123` | Bounded-window (80-line) correction verb checking for routed defects; disclaims secrets/vault to kagi | **adjacent** | Proximity-window grammar checking for routed repairs. `PROVINCE.md:123` yields vault ops to kagi. |
| *(In-lane baseline)* `kagi-shokunin` | `corpus/openbao-approle-trial.sh`<br>`plans/round-60.md:104-164`<br>`plans/round-60-c1-check.py`<br>`plans/round-60-c2.sh`<br>`PROVINCE.md:3,89,94-96` | OpenBao AppRole `secret_id` custody trial (bind_secret_id, num_uses, ttl, accessor, cidr binding); git-derived historical numbers C1 checker with challenge delta; falsifier shims SH1..SH5 | **Exclusive Holder (Authoritative)** | Sole authoritative holder of OpenBao/Vault AppRole `secret_id` custody, designated falsifier test vectors, and git-history-derived calibration checking. |

---

## 4. Shokuknow Package Merge Audit

Inspection of `/home/vgpnk/Projects/shokuknow/merge/kagi/MERGE-REPORT.md` (read-only):
- **Staged Package Content**:
  - 172 proposed source rows (`S052` onward in `SOURCES.append.md`).
  - 81 proposed knowledge files covering:
    - OIDC workload federation trust policies (issuer, audience, subject condition syntax).
    - Secret scanning detection vs. validation (TruffleHog, Betterleaks, Chinese/Japanese market tools, cache expiry).
    - NIST SP 800-57, SP 800-131A, SP 800-133 key management standards.
    - Cloud KMS and Sakura Cloud key lifecycle and custody models.
    - Chinese GB/T 17901 key management series (adoption lineage from ISO/IEC 11770-1/3, domestic deviations).
    - ISO/IEC 11770 series key management lifecycle, catalogue records, and password-based key derivation (Part 8).
- **Audit Findings**:
  - **Zero** staged knowledge files, source rows, or checklist items touch OpenBao, Vault, AppRole authentication, `secret_id` custody (use bounding, TTL expiry, accessor management, or CIDR restrictions), or the seven round-59 routed defects.
  - Staged source IDs (`S052..S223`) heavily collide with kagi's established live source registry (which currently extends to `S124`).
- **Defensibility of `Assimilation: none`**:
  - Stating `Assimilation: none` in round 60 is **entirely defensible, sound, and mandatory**.
  - Kagi's established architectural policy (dating back to rounds 34, 38, 45, 54, 55) mandates quarantine-first and ID collision guards. Adopting unvetted staged expansion material would introduce immediate source ID collisions, breadth drift, and citation gate failures (as documented in mistake M54-6). Because neither round-60 claim touches the staged expansion themes, assimilating nothing is the only disciplined posture.

---

## 5. Sibling Gate Survey: C1 & C2 Patterns

### 5.1 C1 Pattern: Binding Routed Defects to Derived Numbers
- **Kagi Architecture (`plans/round-60-c1-check.py`)**:
  - Evaluates a fixed population of 7 routed defects (I1..I7). Every comparison value is dynamically derived at run time from historical git revisions (`git show`, `git diff`) or receipt files (`w1-results.json`, `selftest.txt`, `c1-landed.txt`).
  - Zero hardcoded facts in the checker: if a fact is derived as `14`, the checker demands `14`.
  - Includes an active GUARD challenge: injecting a mutation into the measured tree (altering `dead seats=0` to `1` in the I1 correction line) must cause the counter to read exactly `value+1`.
- **Sibling Survey**:
  - `tabi-shokunin` (`c1-routed-defects.mjs`): checks receipt existence and commit hashes in git log.
  - `tameshi-shokunin` (`c1-measure.py`): tracks defect closure through SCORECARD table rows and runs mutation test sweeps.
  - `kengaku-shokunin` (`round71_c2_routed_defects.py`): compares Mistakes rows against a hardcoded constant tuple `WANT_ROWS = 8`.
  - `tsukuroi-shokunin` (`check-r75-routed-r76.py`): verifies correction verbs within an 80-line proximity window.
- **Verdict**: No sibling gate derives lesson correction figures from git history while verifying active mutation resistance via challenge injection. Kagi's C1 pattern is unique, adjacent, and uncontested.

### 5.2 C2 Pattern: `--selftest` + Designated Falsifier Shim Vectors
- **Kagi Architecture (`corpus/openbao-approle-trial.sh`, `plans/round-60-c2.sh`)**:
  - Trial evaluates 5 distinct mechanics (T1–T5). Designated environment falsifier shims (`KAGI_APPROLE_SHIM=SH1..SH5`) selectively alter exactly one observable test leg, verifying that the counter accurately maps the test vector:
    - Baseline: `HHHHH`
    - SH1: `BHHHH`
    - SH2: `HBHHH`
    - SH3: `HHBHH`
    - SH4: `HHHBH`
    - SH5: `HHHHB`
  - In addition, the trial implements its own hermetic `--selftest` mode: executing without a running OpenBao server or network, using synthetic fixture-driven stubbing to verify verdict mappings and error handling.
- **Sibling Survey**:
  - Multiple sibling lanes (`tsukuroi`, `chousa`, `kama`, `kaidoku`) implement hermetic `--selftest` modes for CLI tools and gates using mock inputs and fixture trees.
  - Zero sibling lanes use designated multi-limb falsifier shims to prove that every bit in an operational trial vector is independently falsifiable.
- **Verdict**: Kagi's multi-leg trial falsifier shim vector pattern is unique and uncontested; its `--selftest` mode aligns with the fleet-wide hermetic gate standard.

---

## 6. §Reported-not-absorbed list

1. **`chousa-shokunin` Post-Freeze Counter Hardening (`c1-supplement.py`)**: Precedent for non-mutating post-freeze verification, reported but not absorbed because kagi supplements pre-freeze control batteries rather than evaluation counter logic.
2. **`kengaku-shokunin` Bubblewrap Sandbox Isolation (`--unshare-all`)**: Bubblewrap containerization with tool stubs, reported but not absorbed because kagi executes dev servers under process-death signals (`setpriv --pdeathsig KILL`) and loopback socket isolation.
3. **`tsukuroi-shokunin` Proximity Window & Correction Grammar (`check-r75-routed-r76.py`)**: Enforcing an 80-line correction window and strict verb grammar, reported but not absorbed because kagi's append-only convention uses last-occurrence-wins semantics.
4. **`tameshi-shokunin` SCORECARD Disposition Table (`c1-measure.py`)**: Tracking routed defect disposition through structured SCORECARD tables, reported but not absorbed because kagi binds defects directly to lesson text and receipt outcomes.
5. **`kaidoku-shokunin` Seam Probing Shims (`TRUTHFUL_SHIM` / `LYING_SHIM`)**: Scripted python shims for ELF seam probing, reported but not absorbed because kagi uses clean-room PATH resolution and designated environment variables.

---

## 7. Contested Scope Summary (One Line Each)

- **AppRole Authentication & `secret_id` Custody**: Uncontested (0 sibling lanes implement OpenBao/Vault AppRole mechanics; all sibling PROVINCE files route vault operations exclusively to kagi).
- **Designated Falsifier Shim Vectors (`SH1..SH5`)**: Uncontested (0 sibling lanes use multi-limb boolean test vector inversion shims).
- **Shokuknow Package Merge**: Uncontested (all 81 proposed entries and 172 rows focus on OIDC, secret scanning, NIST/ISO standards, and Cloud KMS custody, with zero AppRole or routed-defect content).
- **Revision-Derived Routed Defect Checker (C1)**: Uncontested (no sibling lane derives lesson correction metrics dynamically from historical git commits).
- **Hermetic `--selftest` on Live Capability Trials**: Shared (fleet-wide standard for gates and tools, successfully implemented for OpenBao trials).

---

## 8. Non-Obvious Move (Cross-Lane Synthesis)

### 8.1 Evidence
1. **Concurrent Wave Scratch Collision (`R60ExecTransitSelftest` incident)**:
   In `corpus/openbao-transit-trial.sh`, the original default scratch path was `${HYAKU_SCRATCH}/kagi-r59/R59ExecTrial/trial-work`. During wave execution in round 60, `R60ExecTransitSelftest` initially defaulted to `$HYAKU_SCRATCH/kagi-r60/R60ExecTransitSelftest/selftest-work`. When `R60ReviewerC1` invoked `--selftest` on trial copies concurrently, their scratch directories were removed by the executor's cleanup, triggering spurious test failures. `R60ExecTransitSelftest` resolved this by adopting a seat-agnostic root (`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-transit-trial/selftest-work`) with per-run `mktemp -d` directories.
2. **Sibling Isolation Pattern (`kama-shokunin` & `chousa-shokunin`)**:
   In `kama-shokunin/tools/census-waiver-boundary.py` and `chousa-shokunin/tools/research-gate.sh`, test harnesses prevent concurrency collisions across multi-seat waves by isolating temporary work trees under unique, non-seat-specific scratch namespaces with process IDs (`$$`) and randomized tempdirs.
3. **AppRole Trial Template Risk**:
   If `corpus/openbao-approle-trial.sh` copies the legacy transit trial template (`WORK="${WORK:-${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecTrial/trial-work}"`), concurrent invocations by `R60ExecCounterC2`, `R60ExecControls`, `R60ReviewerC1`, and attack seats will collide and trigger race conditions or permission aborts.
4. **Transit Trial Regression Gap (`R60CriticClaims` finding)**:
   `R60CriticClaims` identified a control gap: item I7 mutates `corpus/openbao-transit-trial.sh` to add `--selftest`, but the pre-freeze battery originally contained no check ensuring that the modified script still passes its real OpenBao 2.7.2 transit trial (HOLDS 5/5) and preserves all five falsifier shim vectors (`SH1..SH5`). `R60ExecTransitSelftest` independently verified this in `trial-still-holds.txt`.

### 8.2 Affected Axes
- **Calibration (C1)**: **Improved**. Eliminates intermittent concurrency failures and cleanup collisions during multi-seat wave execution.
- **Operability (C2)**: **Improved & Preserved**. Ensures both the new AppRole trial (C2) and the mutated transit trial (I7) execute cleanly in parallel without scratch collisions or regressions.
- **Adjacency**: **Preserved**. Conforms to Kama and Chousa scratch isolation standards without perturbing frozen contracts.

### 8.3 Proposed Move
1. Mandate seat-agnostic default scratch paths with randomized per-run subdirectories (`mktemp -d`) across all trial scripts:
   - `corpus/openbao-approle-trial.sh`: default `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-approle-trial/trial-work/`
   - `corpus/openbao-transit-trial.sh`: default `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-transit-trial/trial-work/`
   Ensuring that concurrent invocations across reviewers, counters, and controls never collide.
2. Retain `R60ExecTransitSelftest`'s non-regression verification receipt (`trial-still-holds.txt`) as explicit evidence in the round report, closing the regression gap identified by `R60CriticClaims`.

### 8.4 Risks & Mitigations
- *Risk*: A seat-agnostic scratch root might accumulate orphaned tempdirs if a run is aborted before `cleanup()`.
- *Mitigation*: Both trials install an active `trap cleanup EXIT TERM INT` handler that removes the specific run directory (`rm -rf "$D"`), and top-level scratch cleanup removes the parent root at round completion.

### 8.5 Verification
- `bash corpus/openbao-transit-trial.sh --selftest` passes all 9 fixture cases rc 0 under concurrent execution.
- `bash corpus/openbao-transit-trial.sh` passes real run HOLDS 5/5 on OpenBao 2.7.2 (`trial-still-holds.txt`).
- `bash corpus/openbao-approle-trial.sh --selftest` passes all fixture cases rc 0 without `bao` on PATH.

---

## 9. Patterns Worth Learning

1. **Stateful Stub Fixture Shims for Hermetic Gate Selftests** (from `tsukuroi-shokunin/tools/boot-chain-audit.sh` and `corpus/openbao-transit-trial.sh`):
   When an operational trial requires a `--selftest` flag that runs hermetically without external binaries or network access, write a small stateful Python stub script into a fixture `bin/` directory on PATH. The stub emulates the binary's subcommands and return codes, allowing thorough verification of the trial's verdict parsing and error recovery without live services.
2. **Seat-Agnostic Dynamic Scratch Rooting** (from `kama-shokunin`):
   Never hardcode a seat name into a default scratch path in shared scripts. Use a tool-specific scratch directory with dynamic `mktemp -d` subdirectories so concurrent seats in large waves (16 seats) never interfere with one another's temporary state.

---

SEAT-STATUS: complete

# Sibling Overlap Sweep: AppRole Custody, Shim Vectors, and Routed Defect Repair

- **Seat**: R60ConnectorSiblings (connector) · kagi round 60 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
- **Claim BASE**: `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2` (round-59 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-60.md` (commit `cd631737`)
- **Declared Axes**:
  - **C1 — Calibration**: Seven round-59 routed record defects resolved and re-checkable (`C1_ROUTED: value = UNRESOLVED over POP = 7 when GUARD = 1, else FAIL`; target 0, BASE 7).
  - **C2 — Operability**: Executed OpenBao AppRole `secret_id` custody trial (`C2_APPROLE_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 twice, each of the five falsifier shims flips exactly its designated test, no-bao reads SETUP rc 2, and --selftest exits 0 printing APPROLE_SELFTEST: PASS (cases=N) with N >= 8`; target 5, BASE 0).
- **Observed Answering Model**: `google-antigravity/gemini-3.8-flash`
- **Receipts**: `.ufo/waves/round-60/build/R60ConnectorSiblings/sweep.md`

---

## 1. Exact `grep` Commands & Hit Counts

All sweeps were conducted read-only across all 21 repositories under `/home/vgpnk/Projects/shokunin/*-shokunin/` and the staged package `/home/vgpnk/Projects/shokuknow/merge/kagi/` using GNU grep (`/usr/bin/grep`).

### Exact Grep Commands

1. **Topic 1 — AppRole and `secret_id` custody primitives**:
   ```bash
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'approle|secret_id|bind_secret_id|secret-id-accessor|secret_id_bound_cidrs' <path>
   ```
   *Sub-queries per keyword*:
   - `grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'approle' <path>`
   - `grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'secret_id' <path>`
   - `grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'bind_secret_id' <path>`
   - `grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'secret-id-accessor' <path>`
   - `grep -rnI --exclude-dir=.git --exclude-dir=.jj -E -i 'secret_id_bound_cidrs' <path>`

2. **Topic 2 — `--selftest` and shim-vector patterns**:
   - Lane-prefixed falsifier shims:
     ```bash
     grep -rnI --exclude-dir=.git --exclude-dir=.jj -E 'KAGI_.*_SHIM|APPROLE_.*_SHIM|TRANSIT_.*_SHIM' <path>
     ```
   - Generic environment shims:
     ```bash
     grep -rnI --exclude-dir=.git --exclude-dir=.jj -E '[A-Z0-9_]+_SHIM' <path>
     ```
   - Hermetic `--selftest` flag:
     ```bash
     grep -rnI --exclude-dir=.git --exclude-dir=.jj -e '--selftest' <path>
     ```

3. **Topic 3 — `C1_ROUTED` routed-record defect checking idiom**:
   ```bash
   grep -rnI --exclude-dir=.git --exclude-dir=.jj -E 'C1_ROUTED' <path>
   ```

---

### Hit Counts Table

| Lane / Package | Topic 1: AppRole & `secret_id` | Topic 2A: `KAGI_.*_SHIM` | Topic 2B: `[A-Z0-9_]+_SHIM` | Topic 2C: `--selftest` | Topic 3: `C1_ROUTED` |
|---|---|---|---|---|---|
| `audio-shokunin` | 0 | 0 | 0 | 1 | 0 |
| `chousa-shokunin` | 0 | 0 | 12 | 3,192 | 0 |
| `game-dev-2d-shokunin` | 0 | 0 | 0 | 0 | 0 |
| `game-dev-3d-shokunin` | 0 | 0 | 2 | 0 | 0 |
| `kagi-shokunin` *(in-lane baseline)* | **1,417** | **139** | **141** | **6,653** | **560** |
| `kaidoku-shokunin` | 10 *(MCP tool schema)* | 0 | 17 | 22,309 | 0 |
| `kake-shokunin` | 0 | 0 | 0 | 10,006 | 0 |
| `kama-shokunin` | 0 | 0 | 120 | 11,609 | 0 |
| `kasegi-shokunin` | 0 | 0 | 0 | 8,142 | 0 |
| `kengaku-shokunin` | 0 | 0 | 45 | 10,854 | 0 |
| `kotoba-shokunin` | 0 | 0 | 15 | 76 | 0 |
| `kotodama-shokunin` | 0 | 0 | 0 | 9,381 | 0 |
| `kumitate-shokunin` | 0 | 0 | 16 | 14,911 | 0 |
| `lore-shokunin` | 0 | 0 | 0 | 36 | 0 |
| `mado-shokunin` | 0 | 0 | 0 | 13,266 | 0 |
| `mori-shokunin` | 0 | 0 | 0 | 12,864 | 0 |
| `revenger-shokunin` | 0 | 0 | 0 | 283 | 0 |
| `souji-shokunin` | 0 | 0 | 43 | 16,336 | 0 |
| `tabi-shokunin` | 0 | 0 | 0 | 17,741 | 12 |
| `tameshi-shokunin` | 0 | 0 | 4 | 24,054 | 59 |
| `tsukuroi-shokunin` | 0 | 0 | 0 | 18,752 | 0 |
| `shokuknow/merge/kagi` *(staged)* | 0 | 0 | 0 | 0 | 0 |

---

## 2. Hit Breakdown & Claim Classification

### 2.1 Topic 1: AppRole and `secret_id` Custody Primitives
- **`kaidoku-shokunin`** (10 hits):
  - Paths: `.ufo/waves/luna-round-2/receipts/L7-mcp-tools-6.5.0.txt:11,14`, `L3-omp-pin.txt:12`, `L8-mcp-tools-6.4.0.txt:10`, `A6-6.4.0-mcp-tools.txt`, `A6-6.5.0-mcp-tools.txt`, `.ufo/waves/luna-round-6/receipts/leg-2.md`, `leg-3.md`, `.ufo/waves/luna-round-8/receipts/leg-2.md`.
  - What it does: MCP tool definition schema logs dumped from 1Password/secret CLI tools during reverse-engineering luna rounds, defining an object property named `"secret_id"` (`{"secret_id": {"$ref": "#/$defs/__schema8"}}`).
  - Classification: **none / unrelated**. Pure parameter schema string in an external tool description dump; zero OpenBao/Vault AppRole mechanics, authentication methods, or credential custody.
- **Other 19 Sibling Lanes**: 0 hits.
- **`shokuknow/merge/kagi`**: 0 hits.
- **`kagi-shokunin` Claim**: **Unique & Uncontested**. Kagi is the exclusive holder of AppRole authentication, `secret_id` issuance, use bounding (`secret_id_num_uses`), TTL expiry (`secret_id_ttl`), accessor custody (`secret-id-accessor/lookup` and `destroy`), and network CIDR binding (`secret_id_bound_cidrs`). Every sibling lane's `PROVINCE.md` (e.g., `kasegi` PROVINCE:48, `mori` PROVINCE:68, `souji` PROVINCE:36, `tsukuroi` PROVINCE:123) explicitly delegates secrets and vault operations to kagi.

### 2.2 Topic 2: `--selftest` and Shim-Vector Patterns
- **`KAGI_.*_SHIM`**: 139 hits in `kagi-shokunin`, 0 across all sibling lanes.
- **Generic `*_SHIM`**:
  - `chousa-shokunin` (12 hits): `GREP_SHIM_LOG` in `RevGrepModesA/matrix.sh` logs mock `grep` execution during gate testing.
  - `game-dev-3d-shokunin` (2 hits): `CURSOR_SHIM_PORT` / `CURSOR_SHIM_MAX_CONCURRENT` in `AGENTS.md` for a cursor background service.
  - `kaidoku-shokunin` (17 hits): `TRUTHFUL_SHIM` and `LYING_SHIM` in `tools/round-75/seam-probe.py` provide mock binary responses for reverse-engineering seam probes.
  - `kama-shokunin` (120 hits): `BOUNDARY_SHIMS_DRIFT` and `BOUNDARY_SHIM` in `tools/census-waiver-boundary.py` evaluate binary drift on boundary probes.
  - `kengaku-shokunin` (45 hits): `PYTHON_SHIM` in `plans/round59_c1_openssl_probe.py` wraps `/usr/bin/python3` inside bubblewrap sandboxes.
  - `kumitate-shokunin` (16 hits): `SIGHTING_SHIM` and `FIXTURE_SHIM` in `scripts/surface-probe.mjs` wrap `scripts/ufo-sighting`.
  - `souji-shokunin` (43 hits): `GIT_SHIM_LOG` and `A_SHIM` in `tests/runner-25.sh` record git mock calls.
  - `tameshi-shokunin` (4 hits): `DB_SHIM` and `RC_SHIM` in `T90C2-tool-neuter.py` mock defect-bind and registry tools.
- **`SH1..SH5` designated falsifier shim vectors**:
  - Exclusively used in `kagi-shokunin` to test multi-limb trials where each shim inverts exactly one designated test leg (`HHHHH` -> `BHHHH`, `HBHHH`, `HHBHH`, `HHHBH`, `HHHHB`). Sibling occurrences of `SH1` are either homonyms for SHA-1, processor architecture SuperH-1 (`kaidoku`), or seat labels (`kaidoku`, `tsukuroi`).
- **`--selftest`**:
  - Present fleet-wide as the universal gate standard requiring tools to provide a hermetic, self-contained verification mode over synthetic fixtures without live infrastructure.
- **Classification**: Kagi's multi-leg trial falsifier shim vector pattern (`SH1..SH5` flipping exact bits in a boolean execution vector) is **Unique & Uncontested**. The hermetic `--selftest` requirement is **Shared** fleet standard.

### 2.3 Topic 3: `C1_ROUTED` Routed-Record Defect Checking Idiom
- **`tabi-shokunin`** (12 hits):
  - Path: `tabi-shokunin/.ufo/waves/round-38/counters/c1-routed-defects.mjs:253,258`
  - What it does: Evaluates 14 spot-check findings by scanning for expected receipt files and git log commits, printing `C1_ROUTED_DEFECTS predicate=met|not-met rev=... findings=...`.
  - Classification: **Shared idiom / distinct implementation**. Tabi evaluates static findings by verifying existence of receipts and commit hashes via Node.js script.
- **`tameshi-shokunin`** (59 hits):
  - Path: `tameshi-shokunin/.ufo/evidence/round-25/c1-measure.py:140,151`
  - What it does: Evaluates 3 routed defects by running mutation test sweeps (`multitoken-mutants.spec`, `guard-mutants.spec`) and verifying SCORECARD disposition rows, printing `C1_ROUTED: dispositioned=3/3`.
  - Classification: **Shared idiom / distinct implementation**. Tameshi tests defect closure through test suite mutations and SCORECARD table tracking.
- **`kagi-shokunin`** (560 hits):
  - Path: `plans/round-58-c1-check.py`, `plans/round-59-c1-check.py`, `plans/round-60-c1-check.py`.
  - What it does: Dynamically derives all numerical facts from git history (`git show`, `git diff`) and receipt files, enforces append-only correction blocks, and includes an active challenge injection leg (mutating the measured tree to prove the counter catches failures).
  - Classification: **Unique & Uncontested derivation & challenge architecture**.

---

## 3. Required Analyses

### (a) Ground a sibling holds that kagi should report rather than absorb

1. **`chousa-shokunin` Post-Freeze Counter Hardening (`c1-supplement.py`)**:
   - Chousa uses supplementary scripts to harden evaluation counters against replay forgery (QUALITY 80). Kagi reports this as precedent for non-mutating supplements, but does not absorb it because kagi's supplement pattern specifically backfills pre-freeze control batteries rather than evaluation counter logic.
2. **`kengaku-shokunin` Bubblewrap Sandbox Isolation (`--unshare-all`)**:
   - Kengaku enforces tool execution boundaries via Linux bubblewrap (`bwrap`) containerization. Kagi reports this sandbox isolation pattern, but does not absorb it because kagi executes dev servers under process-death signals (`setpriv --pdeathsig KILL`) and loopback socket isolation, which avoids requiring host setuid/unprivileged user namespace privileges.
3. **`tsukuroi-shokunin` Proximity Window & Grammar Verification (`check-r75-routed-r76.py`)**:
   - Tsukuroi enforces an 80-line proximity window and grammatical regex for correction lines. Kagi reports this syntactic checking approach, but does not absorb it because kagi's correction convention relies on semantic "last occurrence wins" append-only history.
4. **`tameshi-shokunin` SCORECARD Disposition Matrix (`c1-measure.py`)**:
   - Tameshi records defect closure through dedicated rows in SCORECARD tables. Kagi reports this, but does not absorb it because kagi tracks routed defect repair directly in `LOG.md` and lesson `Mistakes` tables with automated derivation checks.

### (b) Material in kagi's own merge package: should or should not assimilate (`Assimilation: none`)

- **Merge Package State**:
  - Located at `/home/vgpnk/Projects/shokuknow/merge/kagi/` (staged by `corpus-expansion-1`).
  - Contains **172** proposed source rows (`SOURCES.append.md`) and **81** staged knowledge files.
  - Staged themes include: OIDC workload-federation trust policy, secret scanning detection vs. validation (TruffleHog, Betterleaks), NIST SP 800-57 / 800-131A / 800-133 key management standards, Cloud KMS / Sakura Cloud custody boundaries, Chinese GB/T 17901 key management series, and ISO/IEC 11770 lifecycle records.
- **Audit Findings**:
  - **Zero** staged files or rows touch OpenBao, Vault, AppRole authentication, `secret_id` custody, transit engine, encryption-as-a-service, or the seven round-59 routed defects (D1–D7).
  - Staged source IDs run from `S052` to `S223`, which directly collide with kagi's own native S-space (kagi is currently at `S124`).
- **Defensibility of `Assimilation: none`**:
  - Stating `Assimilation: none` in round 60 is **entirely defensible, correct, and required**.
  - Kagi's established policy (dating back to round 34, 38, 45, 54, 55) enforces quarantine-first and ID collision guards. Unvetted adoption of unrelated staged files would introduce immediate source ID collisions, breadth drift, and citation gate failures (as documented in mistake M54-6). Because neither round-60 claim (C1 calibration of routed defects, C2 operability of AppRole trial) relates to the staged expansion themes, assimilating nothing is the only disciplined posture.

### (c) Patterns kagi should copy from a sibling with the path

1. **Hermetic State-Machine Stubbing for `--selftest`**
   - *Source*: `tsukuroi-shokunin/tools/boot-chain-audit.sh:104,1257` and `kaidoku-shokunin/tools/round-75/seam-probe.py:590-620`.
   - *Pattern*: When a CLI script requires a `--selftest` mode that executes without live external binaries or network infrastructure, synthesize a minimal Python stub in a temporary fixture `bin/` directory that emulates exactly the required subcommand outputs and error conditions.
   - *Adoption in Kagi*: Adopted by `R60ExecTransitSelftest` in `corpus/openbao-transit-trial.sh` (lines 42–60) and `corpus/openbao-approle-trial.sh`, allowing `--selftest` to execute hermetically and verify all verdict mappings and shim resolutions without a running `bao` daemon.
2. **Seat-Agnostic Scratch Roots for Concurrent Wave Execution**
   - *Source*: `kama-shokunin/tools/census-waiver-boundary.py:55` and `chousa-shokunin/tools/research-gate.sh`.
   - *Pattern*: Test harnesses invoked by multiple concurrent seats (counters, controls, reviewers, mutation-testers) must not default to a single seat-specific scratch directory (such as `${HYAKU_SCRATCH}/kagi-r60/<seat-name>/`). Instead, use an isolated seat-agnostic scratch root (`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-<trial-name>/`) with dynamic per-process `mktemp -d` directories.
   - *Adoption in Kagi*: Prevents concurrent process collisions and race conditions during simultaneous wave execution.
3. **Tolerant Multi-Field Challenge Mutation**
   - *Source*: `tsukuroi-shokunin/tools/check-r75-routed-r76.py:1-60`.
   - *Pattern*: When frozen predicate descriptions and item requirement tables use slightly different syntax for a mutable field (e.g., `dead=<D>` in item conditions vs `dead seats=<n>` in guard challenge descriptions), the checker should parse both forms tolerantly (`dead(?: seats)?=(\d+)`), allowing the challenge leg to cleanly mutate the target without invalidating candidate-time verification.
   - *Adoption in Kagi*: Implemented in `plans/round-60-c1-check.py` to reconcile I1 condition text with GUARD challenge execution.

---

SEAT-STATUS: complete

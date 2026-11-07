# R61Connector — Cross-Lane Overlap Scan: OpenBao Seal Custody, Key-Share Quorums, and Assimilation Audit

- **Seat**: R61Connector (connector) · kagi round 61 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
- **Claim BASE**: `c940f51689d702f1786989d56ad4663833c1452e` (round-60 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-61.md` (commit `8595018164f7421864254c6c5ca762b8f201e8be`)
- **Declared Axes**:
  - **C1 — Calibration**: The seven round-60 routed record defects are resolved and re-checkable (`C1_ROUTED: value = UNRESOLVED over POP = 7 when GUARD = 1, else FAIL`; target 0, BASE 7).
  - **C2 — Operability**: Executed OpenBao seal / unseal key-share custody trial (`C2_SEAL_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 in two independent runs, each of the five falsifier shims flips exactly its designated test, no-bao reads SETUP rc 2, and --selftest exits 0 printing SEAL_SELFTEST: PASS (cases=N) with N >= 8`; target 5, BASE 0).
- **Observed Answering Model**: `google-antigravity/gemini-3.8-flash`
- **Receipts**: `.ufo/waves/round-61/build/R61Connector/sweep.md`
- **Scratch**: Cleaned before yield (leaf subagent scratch path `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61Connector/`)

---

## 1. Scope & Declared Axes

The round's declared claims per `plans/round-61.md`:
1. **C1 — Calibration (Target 0, BASE 7)**:
   - Resolves the 7 routed record defects from `corpus/lessons/round-60-verifier-spotcheck.md` §7:
     - **I1 (D1)**: Supersedes `round-60.md` R37 stating `results=<R> output=<B>` derived from `.ufo/waves/round-60/w1-results.json` and naming `mutants.md`.
     - **I2 (D2)**: `plans/round-60-c2.sh --selftest` exits 0 with `C2_SELFTEST: PASS (cases=N)` (N >= 6) from hermetic fixtures; mutated copy fails with a named finding; `SKILL.md` row registers `--selftest`.
     - **I3 (D3)**: Appends Amendment A7 to `plans/round-60.md` withdrawing `A3 item 2` on `form` and `l1-probe.txt`; mines `M60-2` second instance in `round-60.md`.
     - **I4 (D4)**: Supersedes quality-trend sentence in `round-60.md` quoting `no new record defect` and naming `D1`, `D2`, `D3` (three new defects).
     - **I5 (D5)**: Supersedes round-60 LOG wave line naming `818d2a82` and `14a6c07d`, stating `insertions=1 deletions=1` and mechanism (`rewritten in place`) derived via `git diff --numstat`.
     - **I6 (D6)**: Supersedes stale-lane paragraph in `round-60.md` naming driver line `2026-11-07T15:03:17-03:00 launch kagi round=60` and three `-03:00` commit timestamps from `git log`.
     - **I7 (D7)**: Supersedes attack-share arithmetic in `round-60.md` stating `3/16` (18.75%) and `4/16` (25%) based on roles in `w1-results.json`.
   - Evaluated by `plans/round-61-c1-check.py` and `plans/round-61-c1.sh` with active challenge injection (mutating `deletions=1` to `2` must yield `value+1`).
2. **C2 — Operability (Target 5, BASE 0)**:
   - Acquires the OpenBao **seal / unseal key-share custody** capability on OpenBao 2.7.2, executing five documented mechanics:
     - **T1 init**: `storage "raft"` in scratch, `tls_disable = 1`, `operator init -key-shares=5 -key-threshold=3` returns 5 shares and threshold 3; `sys/seal-status` confirms `initialized=true sealed=true t=3 n=5`; and no file under the storage path contains any unseal shares (operator custody).
     - **T2 unseal threshold**: First share yields `progress 1/3, sealed=true`; repeated same share refuses to increment progress; second share yields `2/3`; third share yields `sealed=false`.
     - **T3 seal**: Authenticated `operator seal` yields `sealed=true`; authenticated requests while sealed return HTTP 503; unauthenticated `sys/seal-status` returns HTTP 200.
     - **T4 generate-root**: `operator generate-root -init` yields nonce, OTP and `required=3`; three shares yield encoded token; `-decode` with OTP recovers authenticating token (HTTP 200); wrong OTP fails.
     - **T5 rekey refused**: `operator rekey -init` exits non-zero with HTTP 405 `unsupported operation` on both Raft and in-memory storage (docs-vs-binary divergence against S126).
   - Evaluated by `corpus/openbao-seal-trial.sh` with designated falsifier shims `SH1..SH5` and an isolated hermetic `--selftest` mode.

---

## 2. Sibling Overlap Survey & Exact Grep Commands

A comprehensive read-only sweep was conducted across all 21 repositories under `/home/vgpnk/Projects/shokunin/*-shokunin/` for OpenBao/Vault seal, unseal, Shamir threshold, rekey, and generate-root ground.

### Exact Grep Command Executed
```bash
grep -Hn -E -i 'seal|unseal|shamir|rekey|generate-root' \
  /home/vgpnk/Projects/shokunin/*-shokunin/PROVINCE.md \
  /home/vgpnk/Projects/shokunin/*-shokunin/SKILL.md \
  /home/vgpnk/Projects/shokunin/*-shokunin/corpus/SOURCES.md 2>/dev/null
```

### Hit Counts Table

| Sibling Lane | Hit Count | Files Evaluated | Command Executed | Context & Classification |
|---|---|---|---|---|
| `audio-shokunin` | 0 | `PROVINCE.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Zero hits. Focused purely on acoustic waveform synthesis and DSP algorithms. |
| `chousa-shokunin` | 2 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Substring matches in `SKILL.md:147,148` on `REFUSEALL`/`refuseall` control names (`refu-seal-l`). Zero vault or seal relevance. |
| `game-dev-2d-shokunin` | 0 | `PROVINCE.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Zero hits. 2D sprite rendering and scene graph mechanics. |
| `game-dev-3d-shokunin` | 0 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Zero hits. 3D transform hierarchies and mesh rendering. |
| `kagi-shokunin` *(in-lane baseline)* | **6** | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | **Exclusive Authoritative Holder**: `PROVINCE.md:96` (audit trial notes `sys/seal-status` non-audited path); `SOURCES.md` S010 (SOPS Shamir key-groups), S115 (audit devices `sys/seal-status`), S125 (OpenBao Shamir seal concepts), S126 (`operator rekey`), S127 (`operator generate-root`). |
| `kaidoku-shokunin` | 2 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SKILL.md:233` ("sealed envelope" metaphor); `SOURCES.md` S018 (Check Point Research "Breaking the Seal: Static Deobfuscation of JSCeal's Compiled V8 Bytecode"). Zero vault/crypto seal relevance. |
| `kake-shokunin` | 7 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `PROVINCE.md:341,553` ("sealed 24-case counter", "sealed key"); `SKILL.md:1056,1077,1118,1136,1762` (`sealed_count.py`, `sealed_count_v3.py`). Test fixture sealing for web crawling/sitemap verification; zero vault custody. |
| `kama-shokunin` | 14 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `PROVINCE.md:17,380` ("sealed revision"); `SKILL.md:1587-1642` and `SOURCES.md` S500, S501, S502 covering Linux kernel anonymous file sealing via `memfd_create` and `fcntl(2)` `F_GET_SEALS` / `F_ADD_SEALS` (seals 15). Operating system memory-fd sealing, zero OpenBao/Vault custody. |
| `kasegi-shokunin` | 3 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SKILL.md:76,121,640` referencing "SEAL" = Security Alliance Whitehat safe harbor framework for Web3 bug bounties. Acronym homonym; zero vault relevance. |
| `kengaku-shokunin` | 3 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `PROVINCE.md:349` (references kake's `sealed_count_v2.py`); `SKILL.md:660,663` (`SEALED total=12 clean=12` test result counts in bubblewrap sandbox probes). Zero vault custody. |
| `kotoba-shokunin` | 0 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Zero hits. Linguistic corpus and token string analysis. |
| `kotodama-shokunin` | 16 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SOURCES.md` S296, S395, S400, S414, S415, S427, S434, S439, S441, S442, S452, S486, S568, S622, S674, S795 covering historical and material culture seals: heraldic seals, wax matrix seals, sigillum, tamga seals, witch bottles sealed, Pre-Dorset sealskin kamik boot, and incense seals. Physical artifacts; zero software crypto. |
| `kumitate-shokunin` | 11 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SKILL.md:212-311` covering UFO harness runtime membrane process boundary sealing (`ufo membrane-seal write`, `Command::MembraneSeal`, lease-guarded authority boundary). Orchestrator runtime process boundaries, zero OpenBao vault custody. |
| `lore-shokunin` | 1 | `PROVINCE.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `PROVINCE.md:18` ("Q06 sealed gate"). Documentary quality gate; zero vault relevance. |
| `mado-shokunin` | 5 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `PROVINCE.md:26,27` (sealed round-21/22 fixtures); `SKILL.md:815,2238,2244` (`seal.json`, `truth-seal.json` raw truth snapshot hashes). Paperwork integrity checking; zero vault relevance. |
| `mori-shokunin` | 2 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `PROVINCE.md:219` ("sealed quota cases"); `SKILL.md:618` ("opposing pre-sealed"). Metric census fixture sealing; zero vault relevance. |
| `revenger-shokunin` | 1 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SOURCES.md` S407 covering Linux kernel ELF loader and memory sealing (`mseal(2)`). OS kernel virtual memory area sealing; zero vault custody. |
| `souji-shokunin` | 0 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Zero hits. Repository note hygiene and Git tree cleanup. |
| `tabi-shokunin` | 0 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | Zero hits. Browser automation and web session protocols. |
| `tameshi-shokunin` | 5 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SOURCES.md` S093, S094, S142 ("sealed holdout" / "sealed test set" statistical analysis); S170, S623 (`rekey_batch` in Git commit batch processing). Zero vault relevance. |
| `tsukuroi-shokunin` | 16 | `PROVINCE.md`, `SKILL.md`, `corpus/SOURCES.md` | `grep -E -i 'seal\|unseal\|shamir\|rekey\|generate-root'` | `SKILL.md:3004-5838` (incidental substring match of `reKey` inside control name `K08FixtureKeyed`). Zero cryptographic relevance. |

---

## 3. Shokuknow Package Merge Audit

Inspection of `/home/vgpnk/Projects/shokuknow/merge/kagi/` (read-only):

### Staged Package Content
- **Report**: `MERGE-REPORT.md` (staged by `corpus-expansion-1`).
- **Proposed Rows**: **172** rows in `SOURCES.append.md` (spanning IDs `S052` through `S223`).
- **Proposed Knowledge Files**: **81** markdown files in `knowledge/`.
- **Thematic Coverage**:
  - OIDC workload federation trust policies (AWS IAM, GCP WIF, Alibaba Cloud RAM).
  - Secret scanning detection vs. live validation (TruffleHog cache bounds and verification lifecycles, Betterleaks v1/v2 rule deltas, Chinese and Japanese market scanners).
  - Key management standards: NIST SP 800-57, SP 800-131A Rev. 3, SP 800-133, Chinese GB/T 17901 key management series, and ISO/IEC 11770 lifecycle catalogue records.
  - Cloud KMS and Sakura Cloud key lifecycle and custody models.

### Fit Verdict for Round 61
- **Zero Topic Fit**: Neither claim in round 61 (C1 calibration of seven round-60 routed record defects; C2 operability of OpenBao seal/unseal key-share custody trial) is touched by any of the 81 staged knowledge entries or 172 source rows. The staged material contains zero references to OpenBao, Vault, Shamir secret sharing, seal status, unseal quorum, root token generation, or record defect remediation.
- **Source ID Collision**: The staged rows (`S052..S223`) collide directly with kagi's live source registry, which stands at `S124` at BASE and expands to `S125..S127` in round 61.
- **Defensibility of `Assimilation: none`**: Stating `Assimilation: none` in round 61 is **entirely defensible, correct, and mandatory**. Absorbing unvetted material would violate the claim budget, trigger immediate source ID collisions, and induce breadth drift.

---

## 4. Sibling Gate Survey: C1 & C2 Patterns

### 4.1 C1 Pattern: Binding Routed Defects to Derived Numbers with Active Mutation Challenge
- **Kagi Architecture (`plans/round-61-c1-check.py`)**:
  - Evaluates a fixed population of 7 routed defects (I1..I7). Every comparison value is dynamically derived at run time from historical git revisions (`git show`, `git diff --numstat`, `git log --format='%ci'`) or receipt files (`w1-results.json`).
  - Zero hardcoded facts in the checker: if a fact is derived as `results=16 output=3824`, the checker demands exactly those figures.
  - Includes an active GUARD challenge: injecting a mutation into the measured tree (altering `deletions=1` to `2` in the I5 correction line) must cause the counter to read exactly `value+1`.
- **Sibling Survey**:
  - `tabi-shokunin` (`c1-routed-defects.mjs`): checks receipt existence and commit hashes in git log.
  - `tameshi-shokunin` (`c1-measure.py`): tracks defect closure through SCORECARD table rows and runs mutation test sweeps.
  - `kengaku-shokunin` (`round71_c2_routed_defects.py`): compares Mistakes rows against a hardcoded constant tuple `WANT_ROWS = 8`.
  - `tsukuroi-shokunin` (`check-r75-routed-r76.py`): verifies correction verbs within an 80-line proximity window.
- **Verdict**: No sibling gate derives lesson correction figures from git history while verifying active mutation resistance via challenge injection. Kagi's C1 pattern is unique, adjacent, and uncontested.

### 4.2 C2 Pattern: `--selftest` + Designated Falsifier Shim Vectors
- **Kagi Architecture (`corpus/openbao-seal-trial.sh`, `plans/round-61-c2.sh`)**:
  - Trial evaluates 5 distinct mechanics (T1–T5). Designated environment falsifier shims (`KAGI_SEAL_SHIM=SH1..SH5`) selectively alter exactly one observable test leg, verifying that the counter accurately maps the test vector:
    - Baseline: `HHHHH`
    - SH1: `BHHHH`
    - SH2: `HBHHH`
    - SH3: `HHBHH`
    - SH4: `HHHBH`
    - SH5: `HHHHB`
  - In addition, the trial implements its own hermetic `--selftest` mode: executing without a running OpenBao server or network, using synthetic fixture-driven stubbing to verify verdict mappings and error handling (`SEAL_SELFTEST: PASS (cases=N)` with N >= 8).
- **Sibling Survey**:
  - Multiple sibling lanes (`tsukuroi`, `chousa`, `kama`, `kaidoku`) implement hermetic `--selftest` modes for CLI tools and gates using mock inputs and fixture trees.
  - Zero sibling lanes use designated multi-limb falsifier shims to prove that every bit in an operational trial vector is independently falsifiable.
- **Verdict**: Kagi's multi-leg trial falsifier shim vector pattern is unique and uncontested; its `--selftest` mode aligns with the fleet-wide hermetic gate standard.

---

## 5. Ground a Sibling Holds That Kagi Should Report Rather Than Absorb

1. **`kama-shokunin` Linux Kernel Anonymous File Sealing (`F_GET_SEALS` / `memfd_create`)**:
   - Kama implements file-descriptor sealing (`seals 15 = F_SEAL_SEAL | F_SEAL_SHRINK | F_SEAL_GROW | F_SEAL_WRITE`) to ensure server binaries exec'd from `/proc/<pid>/fd/<n>` cannot be modified on disk. Kagi reports this kernel sealing pattern as adjacent security infrastructure, but does not absorb it because OpenBao operates at the application/secret-custody layer rather than kernel VFS descriptor enforcement.
2. **`chousa-shokunin` Post-Freeze Counter Hardening (`c1-supplement.py`)**:
   - Chousa uses supplementary scripts to harden evaluation counters against replay forgery (QUALITY 80). Kagi reports this precedent, but does not absorb it because kagi supplements pre-freeze control batteries rather than evaluation counter logic.
3. **`kengaku-shokunin` Bubblewrap Sandbox Isolation (`--unshare-all`)**:
   - Kengaku enforces tool execution boundaries via Linux bubblewrap (`bwrap`) containerization. Kagi reports this sandbox isolation pattern, but does not absorb it because kagi executes throwaway dev servers under process-death signals (`setpriv --pdeathsig KILL`) and loopback socket isolation.
4. **`tsukuroi-shokunin` Proximity Window & Grammar Verification (`check-r75-routed-r76.py`)**:
   - Tsukuroi enforces an 80-line proximity window and grammatical regex for correction lines. Kagi reports this syntactic approach, but does not absorb it because kagi's correction convention relies on semantic "last occurrence wins" append-only history.
5. **`kumitate-shokunin` Process Membrane Boundary Sealing (`ufo membrane-seal`)**:
   - Kumitate manages UFO orchestrator authority boundaries via membrane leases. Kagi reports this runtime lease model, but does not absorb it because OpenBao token leases are distinct application-layer constructs.

---

## 6. Considerthese Section

Inspection of `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/`:

### Analysis of Newest File
- **Newest File**: `considerthese/2026-10-26.md` (reflection generated by Grok Bot, HEAD read `c303c92`).
- **Proposals Listed**:
  1. *Proposal 1: "A repair-only release path under a HOLD"*: Proposes that the operator allow narrow repair tickets when a policy HOLD is in effect.
     - *Status & Fit*: `SCORECARD.md:14` documents `lane-status: open — as-of:2026-11-07 — dispatch unblocked`. No policy HOLD is in effect. The proposal has no operative surface to act upon this round.
  2. *Proposal 2: "Machine-readable lane status"*: Proposes putting the HOLD state in `SCORECARD.md`.
     - *Status & Fit*: Already implemented in round 31 as the canonical `lane-status:` line (`SCORECARD.md:14-16`, `LOG.md:1661`).
  3. *Proposal 3: "Mark known-defective instrument output"*: Proposes appending `KNOWN_DEFECT: D1` to `release-clock.py` `CLEAN` verdicts.
     - *Status & Fit*: The underlying defect in `corpus/release-clock.py` (`STABLE_TITLE_RE` period suffix) was resolved at BASE in round 45 (as confirmed in round-60 report line 155). The premise is stale.
  4. *Proposal 4: "Create `considerthese/BACKLOG.md`" (carried from 2026-10-24)*: Proposes creating a dedicated tracking table for reflection suggestions.
     - *Selected Proposal*: Proposal 4 (`considerthese/BACKLOG.md`).
     - *Fit Verdict*: Does **not** fit round 61's claims. Round 61's budget is strictly allocated to C1 (routed record defect calibration) and C2 (OpenBao seal/unseal key-share custody capability).
     - *Lane-Bar Evidence Needed If Implemented*:
       If `considerthese/BACKLOG.md` were to be implemented, kagi's lane bar would require:
       a) A dedicated validation script (`python3 tools/backlog-audit.py --check`) ensuring all table rows adhere to strict schema columns (`id`, `proposed_date`, `proposal`, `status`, `last_touched`) with valid status enums (`proposed`, `accepted`, `rejected`, `superseded`, `parked`);
       b) A bidirectional link check verifying that every backlog entry points to an existing dated reflection in `considerthese/YYYY-MM-DD.md`;
       c) Proof that the addition of `BACKLOG.md` does not cause regression or drift in file census gates (`scripts/sources-census.sh`, `tools/doc-audit.py`, `plans/round-*-c1-check.py`);
       d) Explicit governance in `PROVINCE.md` establishing that the file is maintained only during daily reflections or milestone closures, preventing mid-round wave race conditions.

---

## 7. Fleet Collisions Check

- **Search for Counter `C2_SEAL_TRIAL`**:
  A fleet-wide grep across all 21 repositories (`grep -rnI --exclude-dir=.git --exclude-dir=.jj 'C2_SEAL_TRIAL' /home/vgpnk/Projects/shokunin/*-shokunin/`) produced 58 matches exclusively in `kagi-shokunin` (in `plans/round-61.md`, `SCORECARD.md`, and wave dispatch metadata). Zero matches exist in any sibling lane.
- **Search for `round-61` Claims**:
  Historical round-61 claims in sibling repositories (`audio`, `chousa`, `kaidoku`, `kake`, `kama`, `kasegi`, `kengaku`) were completed on prior dates and addressed unrelated domain capabilities (audio waveforms, Linux `openat2`, numstat edges, HTTP caching, llama.cpp memfd execution). None touch OpenBao, secrets, Shamir custody, or routed record defects.

## Collisions
None.

---

## 8. Non-Obvious Move (Cross-Lane Synthesis)

### 8.1 Evidence
1. **Dual-Listener Raft & In-Memory Port Collision Risk**:
   In Round 61, Claim C2 (`C2_SEAL_TRIAL`) requires executing OpenBao in production/standard server mode with `storage "raft"` (T1–T4) and also testing `storage "inmem"` (T5 rekey HTTP 405 refusal on both Raft and inmem).
   Standard `bao server` with `storage "raft"` binds two separate TCP sockets:
   - `listener "tcp"` (`address = "127.0.0.1:<api_port>"`)
   - `cluster_addr = "http://127.0.0.1:<cluster_port>"` (Raft gossip/consensus replication listener)
   If the trial script only allocates one ephemeral port for API and omits an explicit cluster port, OpenBao defaults cluster listening to `api_port + 1` or `8201`.
   When concurrent wave seats (`R61ExecCounterC2`, `R61ExecControls`, `R61Reviewer`, `R61MutCounters`, or T5's secondary inmem server) execute simultaneously, default binding risks immediate port collision (`bind: address already in use`), aborting server startup with exit 2 (`SETUP`).
2. **Sibling Multi-Port Ephemeral Allocation Pattern (`kama-shokunin` & `kake-shokunin`)**:
   In `kama-shokunin` (`tools/kama-llamacpp-live.py:220`) and `kake-shokunin` (`scripts/response_snapshot.py`), test harnesses binding multiple sockets simultaneously allocate ALL required ports in a single atomic Python helper (`socket.socket()` binding multiple ports, printing both, then closing) to guarantee distinct, non-overlapping ephemeral ports for both API and cluster channels.
3. **Raft Storage Directory Clean-Room Isolation (T1 Custody Check)**:
   T1 strictly checks: "no file under the storage path contains any of the five base64 shares (custody: shares are held by operators, never by the server)".
   If the Raft directory is not freshly isolated under a per-run dynamic `mktemp -d` subdirectory, stale WAL or cluster state from previous runs could leak or cause file inspection anomalies.

### 8.2 Affected Axes
- **Operability (C2)**: **Improved & Protected**. Prevents flaky test execution and intermittent `address already in use` or Raft cluster port collisions during multi-seat concurrent wave execution.
- **Calibration (C1)**: **Protected**. Guarantees that pre-freeze control runs and candidate counter runs never crash due to cluster socket race conditions.
- **Adjacency**: **Preserved**. Reuses proven ephemeral port allocation patterns from `kama-shokunin` without altering frozen predicates.

### 8.3 Proposed Move
In `corpus/openbao-seal-trial.sh`:
1. Allocate BOTH `BAO_API_PORT` and `BAO_CLUSTER_PORT` using an atomic dual-socket ephemeral port helper in Python:
   ```bash
   read -r PORT CLUSTER_PORT < <(python3 -c 'import socket
s1, s2 = socket.socket(), socket.socket()
s1.bind(("127.0.0.1", 0)); s2.bind(("127.0.0.1", 0))
print(s1.getsockname()[1], s2.getsockname()[1])
s1.close(); s2.close()')
   ```
2. In the Raft HCL configuration, explicitly configure:
   ```hcl
   storage "raft" {
     path = "$WORK/raft"
     node_id = "node1"
   }
   listener "tcp" {
     address = "127.0.0.1:$PORT"
     tls_disable = 1
   }
   api_addr = "http://127.0.0.1:$PORT"
   cluster_addr = "http://127.0.0.1:$CLUSTER_PORT"
   ```
3. In T5's inmem leg, allocate a fresh ephemeral port for the inmem server listener rather than reusing `$PORT` while the Raft server shuts down.

### 8.4 Risks & Mitigations
- *Risk*: A time-of-check to time-of-use (TOCTOU) port race if another host process grabs the ephemeral port in the milliseconds between `s.close()` and `bao server` bind.
- *Mitigation*: Retain the retry loop (`for _ in 1 2 3; do ...`) from `openbao-approle-trial.sh`, re-allocating fresh ports on each attempt.

### 8.5 Verification
- `bash corpus/openbao-seal-trial.sh` successfully initializes Raft storage on dynamic `$PORT` and `$CLUSTER_PORT` without port binding errors.
- T5 spins up inmem server cleanly and confirms HTTP 405 `unsupported operation`.
- Concurrent invocations by `R61ExecCounterC2` and `R61ExecControls` run in parallel without `address already in use` failures.

---

## 9. Patterns Worth Learning

1. **Atomic Multi-Socket Ephemeral Port Allocation** (from `kama-shokunin`):
   When an operational server requires multiple distinct listeners (such as OpenBao API port and Raft cluster replication port), bind and release all sockets in a single Python invocation rather than assuming `port + 1` is available.
2. **Hermetic State-Machine Stubbing for Multi-Subcommand CLIs** (from `tsukuroi-shokunin` and `kagi` round 60):
   To implement hermetic `--selftest` modes that do not require live binaries or background daemons, synthesize a lightweight Python stub in a temporary fixture `bin/` directory that emulates subcommands (`operator init`, `operator unseal`, `operator generate-root`, `operator rekey`) and status structures, enabling comprehensive selftest coverage across all verdict mappings.

---

SEAT-STATUS: complete

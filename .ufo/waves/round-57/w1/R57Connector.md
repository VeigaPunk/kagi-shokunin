# R57Connector — cross-lane overlap scan: audit devices and self-description gates

- **Seat**: R57Connector (connector) · kagi round 57 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`
- **Claim BASE**: `1cda9e7ae4767b4133e283bfbc08266d4c86362d` (round-56 verifier spot-check tip)
- **Predeclaration HEAD**: `7aa1f4726e1f6bcdc8411d1a8b21828d49785173` (epoch B amendments A1+A2)
- **Observed answering model**: `google-antigravity/gemini-3.8-flash`
- **Tools observed**: `python3` 3.14.8, `git` 2.56.0, `sha256sum` 0.8.0 (Arch x64). No tool installed or updated this seat (pacman transactions paused; standard utilities in PATH).
- **Scratch**: `/fast/scratch/hyaku/kagi-r57/R57Connector/` (cleaned before yield).

---

## 1. Declared Axes

The round's declared axes per `plans/round-57.md` are:
1. **C1 — Calibration**: The audited surface's numeric self-descriptions agree with their live machine authorities (`C1_CURRENT: value = MISMATCH+UNBOUND over POP when GUARD = 1, else FAIL`; target 0, BASE 3, population floor 8).
2. **C2 — Operability**: OpenBao audit-device custody trial executed on a dev server (`C2_AUDIT_TRIAL: value = PASS when the trial's real run is HOLDS 5/5 twice, each of the five falsifier shims flips exactly its designated test...`; target 5, BASE 0).

All six axes stand at 9 (rounds 36–56 convention). Stagnation nudge is not claimed. No retirement or split.

---

## 2. Cross-Lane Hit Table

All 20 sibling repositories under `/home/vgpnk/Projects/shokunin/*-shokunin` were scanned read-only for:
1. Audit-device trials (OpenBao/Vault `audit enable`, `log_raw`, `hmac-sha256`).
2. Gates binding committed self-descriptions to live machine authorities (case counts, receipt counts, epoch counts).

| Sibling Lane | Path:Line | Mechanism Class | Hit Text / Context | Verdict | Why / Distinguishing Boundary |
|---|---|---|---|---|---|
| `tsukuroi-shokunin` | `.ufo/waves/round-29/w2/RevMarkerO10/NEWS-v262:21348` | Mechanism 1 (audit) | `kernels with audit enabled break containers` | **Homonym / Non-overlap** | Linux kernel audit subsystem mentioned in systemd release notes; completely unrelated to OpenBao/Vault audit devices. |
| `tsukuroi-shokunin` | `.ufo/waves/round-36/w1/SrcSystemdNews/NEWS-v262.full:21348` | Mechanism 1 (audit) | `kernels with audit enabled break containers` | **Homonym / Non-overlap** | Duplicate systemd news archive entry; kernel audit only. |
| `kama-shokunin` | `.ufo/waves/round-25/a2-falsify/out/ReviewerRawHashes/check_receipt_raw.py:358` | Mechanism 1 (log_raw) | `"n_ctx_train_log_raw"` | **Identifier collision / Non-overlap** | Parameter for llama.cpp server context training logs. |
| `tameshi-shokunin` | `.ufo/evidence/round-43/calibration/measure.py:432` | Mechanism 1 (log_raw) | `log_raw = show(lane, rev, LOG_REL)` | **Variable collision / Non-overlap** | Python local variable holding raw bytes of `LOG.md` git blob. |
| `tameshi-shokunin` | `.ufo/evidence/round-44/calibration/measure.py:490` | Mechanism 1 (log_raw) | `log_raw = show(lane, rev, LOG_REL)` | **Variable collision / Non-overlap** | Same `LOG.md` byte extractor in round-44 calibration. |
| `kotoba-shokunin` | `.ufo/waves/round-81/build/Kb81R01NegSweep-fetch/agent-sdk-observability.md:245` | Mechanism 1 (log_raw) | `OTEL_LOG_RAW_API_BODIES` | **Identifier collision / Non-overlap** | OpenTelemetry environment variable for Claude Code API request logging. |
| `mori-shokunin` | `corpus/evidence/recheck-r32/S015.src:63` | Mechanism 1 (log_raw) | `SYSLOG_RAW=` | **Identifier collision / Non-overlap** | systemd journal original syslog field (`Added in version 240`). |
| `mori-shokunin` | `corpus/evidence/sources-r99/S635-sudo-eventlog.c:92` | Mechanism 1 (log_raw) | `ISSET(flags, EVLOG_RAW)` | **Identifier collision / Non-overlap** | sudo eventlog raw logging flag. |
| `kumitate-shokunin` | `.ufo/waves/round-44/probe/p44c-count.mjs:44,129` | Mechanism 1 (hmac-sha256) | `Seeded generator (replayable): HMAC-SHA256(seed, counter) stream` | **Cryptographic helper / Non-overlap** | Seeded PRNG stream for deterministic test-case permutation. |
| `kumitate-shokunin` | `.ufo/waves/round-44/probe/p44d-count.mjs:49,134` | Mechanism 1 (hmac-sha256) | `Randomness is a seeded HMAC-SHA256 stream` | **Cryptographic helper / Non-overlap** | Identical PRNG generator in variant probe. |
| `kumitate-shokunin` | `.ufo/waves/round-59/build/ScoutZenn/body.html:159` | Mechanism 1 (hmac-sha256) | `HMAC-SHA256などでこの値に署名し... requestStateCodec` | **Documentation quote / Non-overlap** | Quoted article describing MCP TypeScript SDK v2 requestState signing. |
| `kasegi-shokunin` | `.ufo/waves/round-87/c2/capability-check.py:57` | Mechanism 1 (hmac-sha256) | `X-Amz-Algorithm=AWS4-HMAC-SHA256` | **Secret scanner regex / Non-overlap** | Planted AWS SigV4 authorization header fixture for web traffic secret scanner. |
| `kasegi-shokunin` | `.ufo/waves/round-88/c2/candidate/capture-secret-scan.py:41` | Mechanism 1 (hmac-sha256) | `Azure Storage SAS signature, an HMAC-SHA256` | **Secret scanner regex / Non-overlap** | Azure SAS signature pattern matching in secret scanner. |
| *(All 20 siblings)* | *(entire tree)* | Mechanism 1 (OpenBao audit) | `bao audit enable`, OpenBao audit device trials | **ZERO HITS (Absent across fleet)** | No sibling repository has ever executed or specified an OpenBao or Vault audit device custody trial. |
| `kama-shokunin` | `tools/round42-selfdesc-reconcile.py:2-75` | Mechanism 2 (self-desc) | `round42-selfdesc-reconcile.py - kama round-42 C1 (calibration) counter` | **Prior art / Adjacent** | Reconciles SCORECARD.md head (banner, Planned, Retired, Saturation, Capabilities, Axes) against live repo state (`mismatches=0 met=True`). Reconciles scorecard sections, but lane-internal to kama. |
| `kama-shokunin` | `tools/round74-selfdesc-canon.py:2-101` | Mechanism 2 (self-desc) | `round74-selfdesc-canon.py - round-74 C1 (calibration): self-description canon` | **Adjacent** | Robust parser resolving capability repertoire regardless of markdown heading style; guards against hidden rows. |
| `kama-shokunin` | `tools/round73-receipt-claim-binding.py:2` & `round74-receipt-claim-binding.py:73` | Mechanism 2 (self-desc) | `round74-receipt-claim-binding.py — round-74 C2 (operability): RECEIPT_CLAIM_V2` | **Prior art / Adjacent** | Binds tip claims in self-record to the revision the cited receipt measured; enforces fail-closed on unbound/shifted claims (`unbound=0 stale=0`). |
| `kama-shokunin` | `tools/pre-report-gate.py:14-405` | Mechanism 2 (self-desc) | `PRE_REPORT round=<N> arms=14 failed=<f> uncommitted=<u>` | **Prior art / Architecture exemplar** | Standing gate composing 14 arms (selfdesc reconciler, newest-closure, receipt audit, worktree-landing, round74 v2). Exemplar of composing individual self-description checks. |
| `souji-shokunin` | `tools/souji-capability-agreement.py:1-105` | Mechanism 2 (self-desc) | `souji-capability-agreement.py — round-30 C1 calibration counter` | **Prior art / Adjacent** | Counts mismatches between SCORECARD rows and live execution outputs via `census/round-30/c1-rows.tsv` table-driven command execution. |
| `souji-shokunin` | `tools/souji-capability-cells.py:1-150` | Mechanism 2 (self-desc) | `souji-capability-cells.py — round-31 C1 calibration counter` | **Prior art / Adjacent** | Verifies SCORECARD capability cells against live observables at REV. |
| `tameshi-shokunin` | `tools/receipt-revision-gate.py:1-205` | Mechanism 2 (receipt-binding) | `receipt-revision-gate — bind a receipt to the revision it certifies` | **Adjacent** | Binds positive receipts to the certified git revision (or byte-identical revision on listed paths), preventing stale-receipt claims. |
| `kumitate-shokunin` | `scripts/proxy-check.mjs:1-650` | Mechanism 2 (scorecard recompute) | `proxy-check.mjs — the lane's own measurement-proxy re-computer` | **Prior art / Adjacent** | Recomputes 23 terms + 6 pins from the filesystem and checks them key-by-key against the machine-readable `kumitate-proxy-v1` block in SCORECARD.md. |
| `kotoba-shokunin` | `plans/round-62.md:C2 G-a` & `ConnSibling.md:55` | Mechanism 2 (self-derived count) | `Self-derived count: claimed count bound to a live re-derivation command` | **Adjacent / Descendant** | Binds claimed count to `git ls-tree` seat count; explicitly cites kagi's `corpus/self-counts.py` as progenitor technique class. |
| `kotodama-shokunin` | `tools/harness/claims-freshness.py:1-2705` | Mechanism 2 (premise gate) | `Pre-dispatch claims-freshness gate — part 1/3: input contract + baseline` | **Adjacent** | Evaluates whether each claim's `before` premise holds at baseline commit before dispatch. |
| `kagi-shokunin` *(in-lane)* | `corpus/self-counts.py` + `corpus/self-counts.tsv` | Mechanism 2 (in-lane basis) | `corpus/self-counts.py — binds current-tense document numbers to live sources` | **In-lane standing foundation (R25-01/02)** | Recognized by souji, tameshi, kama, and kotoba as the fleet's foundational class for binding stated prose numbers to ledger/row observables. |

---

## 3. Ownership Statement and Source URL Sweep

### 3.1 Domain Ownership
- **No Ownership Conflict**: No sibling repository claims OpenBao, Vault, or security audit-device custody ground in either `PROVINCE.md` or `SKILL.md`.
- **Exclusive Kagi Domain**: `kagi-shokunin/PROVINCE.md:3` explicitly establishes:
  > **Domain:** secrets & vault ops — the-janitor flows, credential hygiene evidence
  With Core specifically including `Vault/OpenBao token, lease and KV clocks` (round 49 token trial, round 51 response wrapping trial).
- **Universal Sibling Routing**: Sibling lanes explicitly disclaim vault operations and route them to kagi:
  - `kumitate-shokunin/PROVINCE.md:27` & `.ufo/waves/round-51/w1/RevScope.md:54`: *"kagi owns secrets & vault ops — the-janitor flows, credential hygiene"*.
  - `kasegi-shokunin/.ufo/waves/round-23/build/OverlapVault.md:18`: *"Kagi owns secrets and vault ops (/home/vgpnk/Projects/shokunin/kagi-shokunin/PROVINCE.md:3) and runtime auth plus credential custody (:63). Core there is 1Password machine-credential custody, SOPS/age rotation, and Vault/OpenBao token, lease, and KV clocks (:61)."*
  - `kama-shokunin/PROVINCE.md:96`: *"kama refuses to hold credentials for authenticated health checks and would route that need here through L0"*.

### 3.2 S115 / S116 Source URL Sharing
- **Source S115**: `https://openbao.org/docs/audit/`
- **Source S116**: `https://openbao.org/docs/commands/audit/`
- A literal regex grep across all 20 sibling repositories yielded **zero matches** for S115 or S116. Kagi is the sole holder and custodian of these sources across the entire fleet.

---

## 4. Non-Obvious Move (Cross-Lane & Sibling Synthesis)

### 4.1 Evidence
1. **C1 Unbound Accounting Defect**: Sentinel review (`R57Sentinel.md` F1) discovered that `plans/round-57-c1-check.py` emitted `STMT ... UNBOUND` lines when an authority was missing, but the summary output reported `unbound=0`, risking vacuous passes if `mismatches == 0`. Kama's `tools/round74-receipt-claim-binding.py` proves that any unresolvable authority must explicitly count as UNBOUND and fail the gate closed (`unbound > 0 => bad > 0 => exit 1`).
2. **C2 Substrate Divergence**: ExecTrial (`history://R57ExecTrial`) and Labrat observed that OpenBao 2.7.2 refuses API-based audit device enablement (`bao audit enable`) on default dev servers (`cannot enable audit device via API; use declarative, config-based audit device management instead`). The CLI path is reachable only when the dev server is launched with a configuration setting `unsafe_allow_api_audit_creation = true`. This was incorporated into pre-candidate Amendment A2.

### 4.2 Affected Axes
- **C1 Calibration**: **Improved**. Eliminates vacuous passes when authority files or paths are missing, ensuring numeric self-descriptions must strictly bind to an existing, valid authority.
- **C2 Operability**: **Improved**. Integrates the declarative server configuration requirement `unsafe_allow_api_audit_creation = true` so the custody trial executes against the real OpenBao 2.7.2 binary without relying on mock fallbacks, while preserving strict token containment and zero-secret stdout guarantees.
- **Harms**: None. All six axes remain at 9; pre-freeze controls remain 11 MATCH, 0 MISMATCH.

### 4.3 Proposed Move
1. In `corpus/current-claims.py` (C1 deliverable): Synthesize kama's fail-closed `UNBOUND` accounting pattern so that any absent authority receipt or token marks the statement `UNBOUND` and increments the summary `unbound` counter, ensuring `bad = mismatches + unbound > 0` fails the gate closed whenever an authority is missing.
2. In `corpus/openbao-audit-trial.sh` (C2 deliverable): Start `bao server -dev` passing `-config` pointing to a private scratch configuration file containing `unsafe_allow_api_audit_creation = true` (created with umask 077), satisfying OpenBao 2.7.2 requirements for T1–T5 while ensuring tokens remain strictly in scratch/env and stdout echoes no secret material.

### 4.4 Risks and Mitigations
- *Risk*: Amending frozen files in place would violate the pre-freeze freeze rules.
- *Mitigation*: The frozen instruments (`plans/round-57-c1-check.py`, `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`) remain completely untouched; these enhancements are incorporated into the candidate landing deliverables (`corpus/current-claims.py` and `corpus/openbao-audit-trial.sh`), which are evaluated by the frozen counters.

### 4.5 Verification
- `plans/round-57-controls.sh` (epoch B) verifies 11 MATCH, 0 MISMATCH.
- `python3 corpus/current-claims.py --selftest` passes 10/10 synthetic test cases.
- `bash corpus/openbao-audit-trial.sh --work <scratch>` prints `OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0` rc=0, and falsifiers `KAGI_AUDIT_SHIM=SH1..SH5` each flip their designated test to `BROKEN` rc=1.

---

## 5. One-Line Absorption Recommendation

Do not absorb sibling tools: kagi holds exclusive fleet ownership of secrets and vault operations (PROVINCE.md:3), and C1's audited-surface self-description gate is lane-specific; instead, synthesize kama's fail-closed `UNBOUND` accounting pattern into `corpus/current-claims.py` and enforce the OpenBao 2.7.2 `unsafe_allow_api_audit_creation = true` configuration requirement for C2.

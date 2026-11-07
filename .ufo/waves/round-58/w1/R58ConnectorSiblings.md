# R58ConnectorSiblings — Cross-Lane Overlap Scan: OpenBao/Vault ACL Policy Semantics & Gate Architectures

- **Seat**: R58ConnectorSiblings (connector) · kagi round 58 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
- **Claim BASE**: `1b13f5dad921f8901f56d30c428f89614dd74d8a` (round-57 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-58.md`
- **Declared axes**: C1 (calibration), C2 (operability)
- **Observed answering model**: `google-antigravity/gemini-3.8-flash`
- **Receipts**: `.ufo/waves/round-58/build/R58ConnectorSiblings/`
- **Scratch**: `/fast/scratch/hyaku/kagi-r58/R58ConnectorSiblings/` (cleaned before yield)

---

## 1. Declared Axes

The round's declared axes per `plans/round-58.md` are:
1. **C1 — Calibration**: The round-57 routed record defects (D1–D8) are resolved and re-checkable on the measured tree (`C1_ROUTED: value = UNRESOLVED over POP = 8 when GUARD = 1, else FAIL`; target 0, BASE 8).
2. **C2 — Operability**: Executed OpenBao ACL-policy semantics trial on a dev server (`C2_POLICY_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 twice, each of the five falsifier shims flips exactly its designated test...`; target 5, BASE 0).

Saturation line 9 on all six axes; stagnation waiver is not claimed.

---

## 2. Sweep Command and Evidence

The fleet-wide sibling scan was executed read-only across all 20 sibling repositories under `/home/vgpnk/Projects/shokunin/*-shokunin` inspecting `corpus/knowledge`, `corpus/SOURCES.md`, and `PROVINCE.md`.

Exact sweep command:
```bash
rg -i -n -w 'policies|acl|policy write|capabilities|Vault policy|OpenBao policy' \
  /home/vgpnk/Projects/shokunin/*-shokunin/corpus/knowledge \
  /home/vgpnk/Projects/shokunin/*-shokunin/corpus/SOURCES.md \
  /home/vgpnk/Projects/shokunin/*-shokunin/PROVINCE.md 2>/dev/null
```

Raw evidence receipt:
`.ufo/waves/round-58/build/R58ConnectorSiblings/sweep-raw.txt` (388 matching lines across 19 lanes, 2 lanes with 0 hits).

Auxiliary PROVINCE authorization & policy sweep command:
```bash
rg -i -n -C 1 '\bacl\b|\bpolic(y|ies)\b|\bopenbao\b|\bvault\b' \
  /home/vgpnk/Projects/shokunin/*/PROVINCE.md
```
Auxiliary receipt: `.ufo/waves/round-58/build/R58ConnectorSiblings/provinces-acl-policy.txt` (203 lines).

---

## 3. Per-Lane Hit Table

All 20 sibling repositories were evaluated against the target tokens: `policies`, `acl`, `policy write`, `capabilities`, `Vault policy`, `OpenBao policy`.

| Sibling Lane | Hits | Representative Path:Line | Mechanism / Term | Ground Classification | Verdict & Distinguishing Boundary |
|---|---|---|---|---|---|
| `audio-shokunin` | 0 | *(none)* | *(none)* | **Absent** | **No overlap**. No policies, ACLs, capabilities, or vault terms present. |
| `chousa-shokunin` | 12 | `corpus/knowledge/citation-chain-fidelity-r24.md:3`<br>`corpus/SOURCES.md:15` | `acl` (`aclanthology.org`), `capabilities` | **Homonym / Non-overlap** | Academic NLP publication venue (Association for Computational Linguistics anthology URLs); preflight parser capabilities. Zero security ACL relevance. |
| `game-dev-2d-shokunin` | 0 | *(none)* | *(none)* | **Absent** | **No overlap**. No matching terms. |
| `game-dev-3d-shokunin` | 20 | `corpus/knowledge/unreal-mcp/executability/editor-general.md:37,80` | `capabilities` | **Homonym / Non-overlap** | Unreal Engine MCP plugin toolset capabilities (Editor, Gameplay GAS, Meshes/Textures, Sequencer) and Bevy 0.18 glTF extension capabilities. |
| `kaidoku-shokunin` | 67 | `corpus/knowledge/2026-10-13-crash-evidence.md:14-15`<br>`corpus/knowledge/2026-10-13-r2-provider-capability-matrix.md:8` | `acl` (POSIX), `capabilities` (RE CLI), `Vault` (EVM/Obsidian) | **Non-overlap** | Linux POSIX file ACLs on coredumps (`user:vgpnk:r--`), pacman package `acl-2.4.0-1`; reverse-engineering agent CLI `rea capabilities` matrix; EVM multisig smart contract vaults (`VaultB`, `CarrierV`) and Obsidian asar vault. |
| `kake-shokunin` | 5 | `corpus/knowledge/response-header-expectations.md:111`<br>`corpus/SOURCES.md:87` | `policies` (CSP/security.txt), `capabilities`, `Vault` (mirror) | **Non-overlap** | HTTP security response header policies (CSP, Referrer-Policy, security.txt); Kimi mirror surface named `ufo-fsd.kimi.page` ("Central Vault"). |
| `kama-shokunin` | 7 | `corpus/knowledge/consumer-registry.md:153`<br>`corpus/knowledge/process-bound-listener.md:43`<br>`PROVINCE.md:190` | `capabilities` (LLM), `policies` (socket bind), `Vault` (janitor) | **Non-overlap / Disclaimed** | LLM model completion capabilities `["completion"]`; local HTTP listener wildcard address binding policies; references janitor drift during vault work. Routes vault ops to kagi. |
| `kasegi-shokunin` | 49 | `corpus/knowledge/anthropic-cvd-provenance-and-pacing.md:97`<br>`corpus/knowledge/cloud-signed-cookies-and-user-bound-sas.md:137`<br>`PROVINCE.md:48` | `policies` (CVD / Azure SAS), `capabilities`, `Vault` | **Adjacent / Disclaimed** | Coordinated Vulnerability Disclosure (CVD) timelines; Azure Stored Access Policies for SAS credentials. `PROVINCE.md:48` explicitly disclaims secrets & vault ops to kagi. |
| `kengaku-shokunin` | 18 | `corpus/knowledge/contamination-detection-and-transparency.md:54`<br>`corpus/knowledge/extraction-policy-comparison.md:21,74` | `acl` (`aclanthology.org`), `policies` (eval extraction) | **Homonym / Non-overlap** | ACL Anthology academic papers; JSON extraction parsing policies for model evaluation benchmarks. |
| `kotoba-shokunin` | 3 | `corpus/knowledge/description-trigger-discipline-round85.md:28`<br>`corpus/SOURCES.md:94`<br>`PROVINCE.md:63` | `capabilities` (agent skills), `Vault` | **Non-overlap / Disclaimed** | VS Code agent plugin skill capabilities. `PROVINCE.md:63` and `sibling-description-rewrites-round8.md:114` explicitly assign secrets and vault operations to kagi. |
| `kotodama-shokunin` | 14 | `corpus/knowledge/civilizations/igbo.md:5`<br>`corpus/knowledge/linguistics/toponymy-place-names.md:150`<br>`corpus/knowledge/myth-symbol/monsters-hybrid-beings.md:126` | `acl` (`aclanthology.org`), `policies` (lore/naming) | **Homonym / Non-overlap** | ACL Anthology paper on Igbo POS tagset; naming-board policies, Haudenosaunee medicine-mask policy, lexicon project acceptance rules. |
| `kumitate-shokunin` | 6 | `corpus/knowledge/handoff-binding-and-liveness.md:50`<br>`corpus/knowledge/kimi-config-plane.md:55,130` | `policies` (K8s analogy), `capabilities` (Kimi/MCP) | **Non-overlap** | Kubernetes validating admission policy mentioned as analogy; Kimi CLI config and MCP protocol client capabilities (`_meta`). |
| `lore-shokunin` | 2 | `corpus/SOURCES.md:24`<br>`corpus/knowledge/r87-provenance-chain-decision-table.md:231` | `acl` (`aclanthology.org`), `Vault` (in-lore holder) | **Homonym / Non-overlap** | ACL Anthology LongStoryEval paper; in-lore narrative entity identifier named `vault`. |
| `mado-shokunin` | 5 | `corpus/knowledge/input-debugging-boundaries-r15.md:34`<br>`corpus/knowledge/theme-wallpaper-plane.md:196,353` | `capabilities` (Wayland), `policies` (Chromium) | **Non-overlap** | Wayland `wl_seat.capabilities`; Chromium enterprise managed color policies (`/etc/chromium/policies/managed/color.json`). |
| `mori-shokunin` | 16 | `corpus/knowledge/commit-runway-read-r53.md:30`<br>`corpus/SOURCES.md:362,367`<br>`PROVINCE.md:68` | `policies` (kernel overcommit), `acl` (AWS WAF), `capabilities` (Linux), `Vault` | **Non-overlap / Disclaimed** | Linux kernel memory overcommit policy `OVERCOMMIT_NEVER`; AWS WAF Web ACL token expiration rules; Linux user namespaces. `PROVINCE.md:68` explicitly disclaims secrets/vault to kagi. |
| `revenger-shokunin` | 12 | `corpus/knowledge/round-72-tool-landscape.md:27`<br>`corpus/SOURCES.md:69,220,469` | `capabilities` (disassembler) | **Non-overlap** | Static reverse-engineering capabilities in Ghidra, capa, and `rea capabilities`. |
| `souji-shokunin` | 1 | `corpus/SOURCES.md:134`<br>`PROVINCE.md:36` | `policies` (git rev-parse), `Vault` | **Non-overlap / Disclaimed** | Git rev-parse qualification policies; `PROVINCE.md:36` explicitly disclaims credentials, secrets, tokens, and vault refs to kagi. |
| `tabi-shokunin` | 18 | `corpus/knowledge/csrf-defense-shape-boundary.md:75`<br>`corpus/knowledge/webdriver-bidi-capability-matrix.md:31` | `policies` (SameSite/quota), `capabilities` (WebDriver) | **Non-overlap** | Browser SameSite cookie policies; WebDriver/Marionette browser launch capabilities. |
| `tameshi-shokunin` | 3 | `corpus/knowledge/change-aware-resweep-cadence.md:42`<br>`corpus/knowledge/mutation-score-semantics.md:10` | `policies` (test mutation), `capabilities` | **Non-overlap** | Mutation test scoring and classification policies; SCORECARD capabilities table. |
| `tsukuroi-shokunin` | 85 | `corpus/knowledge/boot-plane.md:22`<br>`corpus/knowledge/root-dac-decision-r12.json:20,34`<br>`PROVINCE.md:85,123` | `acl` (POSIX file / Win32 SDDL), `capabilities` (Linux kernel thread), `Vault` | **Non-overlap / Disclaimed** | POSIX file ACLs (`/var/log/journal` wheel ACL, pacman package `acl-2.4.0-1`, root directory DAC/ACL permissions); Linux kernel `capabilities(7)` (`CAP_DAC_OVERRIDE`), systemd `CapabilityBoundingSet=`. `PROVINCE.md:85` covers root DAC/ACL detection; `PROVINCE.md:123` explicitly cites kagi's `PROVINCE.md:3`. |
| *(In-lane baseline)* `kagi-shokunin` | 45 | `corpus/knowledge/openbao-acl-policy-semantics.md:1,3`<br>`corpus/knowledge/vault-openbao-token-lease-lifecycle.md:52`<br>`PROVINCE.md:3,89,94-96` | `policies`, `acl`, `policy write`, `capabilities`, `OpenBao policy` | **Exclusive Holder (Same Authorization Ground)** | Sole holder of OpenBao/Vault ACL policy authorization semantics: deny-by-default, path globbing (`*`/`+`), deny precedence, capability union vs highest-priority match, and `bao policy write`. |

---

## 4. Ownership and Contention Verdict

### Verdict: **NONE (Uncontested)**

**Evidence & Analysis:**
1. **No Fleet Rivalry**: Zero sibling repositories possess any knowledge entry, source citation, or trial measuring OpenBao or HashiCorp Vault ACL policy authorization semantics, capability precedence, path matching, or policy upload commands.
2. **Universal Routing to Kagi**: Sibling `PROVINCE.md` files explicitly yield secrets and vault operations to `kagi-shokunin`:
   - `mori-shokunin/PROVINCE.md:68`: *"kagi \| Owns secrets, vault operations, and credential-hygiene evidence; mori never reads or reports credential material."*
   - `souji-shokunin/PROVINCE.md:36`: *"- Credentials, secrets, tokens, vault refs — kagi-shokunin's province."*
   - `kasegi-shokunin/PROVINCE.md:48`: *"- kagi — secrets and vault handling"*
   - `kotoba-shokunin/PROVINCE.md:63`: *"kagi owns secrets and vault ops, credential custody and hygiene evidence"*
   - `tsukuroi-shokunin/PROVINCE.md:123`: Cites `kagi-shokunin/PROVINCE.md:3` as owning *"secrets & vault ops — the-janitor flows, credential hygiene evidence"*.
   - `kumitate-shokunin/PROVINCE.md:27`: *"kagi owns secrets & vault ops — the-janitor flows, credential hygiene"*.
3. **Disambiguation of Near Terms**:
   - `tsukuroi-shokunin/PROVINCE.md:85` ("root-directory metadata and create-failure DAC/ACL") explicitly concerns Linux POSIX filesystem DAC/ACL permissions on `/` (e.g. `0555 root:root`), not vault access control.
   - `mori-shokunin/corpus/SOURCES.md:362` concerns AWS WAF Web ACL token expiration rules, not OpenBao/Vault.
   - All other `acl` occurrences in chousa, kengaku, lore, and kotodama are homonyms pointing to `aclanthology.org` (Association for Computational Linguistics).

Kagi is the uncontested, authoritative holder of OpenBao and Vault authorization semantics across the fleet.

---

## 5. Sibling Gate Survey: Routed Defects & Parameterized Self-Descriptions

Four distinct sibling gate architectures were analyzed to evaluate how other lanes structure durable routed defect ledgers and parameterized self-description checks:

### Shape 1: Dedicated Multi-Round Routed Ledger Gate (`kengaku-shokunin/plans/routed_open.py`)
```python
# Reads durable JSONL ledger (corpus/routed-findings.jsonl) tracking routed defects across rounds.
# Row schema: {id, class, source, opened_round, status: open|closed|refused|blocked, close, blocker, check, note}.
# Counts open items (status in {open, blocked}); prints: routed_open=<n> oldest_round=<r>.
# Enforces closure evidence: status=closed requires close commit/receipt; blocked/refused requires blocker.
# Optional dynamic execution: runs inline shell command row['check'], failing on status mismatch.
# Exit map: 0 clean; 1 invalid row, missing closure evidence, check mismatch, or open items; 2 setup.
# Withholds summary line on invalid state, preventing round reports from quoting broken ledgers.
```

### Shape 2: Verifier Spot-Check Limb-Decomposition Gate (`kasegi-shokunin/corpus/instruments/r47-routed-defects.py`)
```python
# Parses previous round's verifier spot-check lesson (round-46 D5–D8), mapping each to substantive limbs L1–L11.
# Operates strictly read-only over committed tree bytes (--root / --revision); never mutates git state.
# Content binding: absence checks verify removal of false text; presence checks verify replacement tokens.
# Verifies capture reproduction: checks manifest sha256 and ensures re-anchored citations resolve in capture.
# Summary output: prints "routed-defects total=11 fixed=<k> unresolved=<m> exit=0|1".
# Exit map: 0 iff unresolved == 0; 1 on any lingering false text or unlanded repair.
```

### Shape 3: Parameterized Round Harness & Self-Description Reconciler (`kama-shokunin/tools/pre-report-gate.py` & `round42-selfdesc-reconcile.py`)
```python
# Parameterized round gate: accepts --round <N>, --repo <lane>, --tip <rev> and derives audit paths dynamically.
# Extracts dynamic round horizon from SCORECARD: maxN = max(re.findall(r'^## Round (\d+)', scorecard_text)).
# Reconciles standing surfaces (banner, Planned, Retired, Saturation, Capabilities, Axes) against live derivations.
# Binds receipt paths: verifies every backticked .ufo/... token in round sections resolves at --tip.
# Fails closed on UNBOUND: any unbacked receipt or missing authority increments unbound counter (exit 1).
# Composes multi-arm verification into one pre-report summary: PRE_REPORT round=<N> arms=14 failed=<f> uncommitted=0.
```

### Shape 4: Bounded-Window Correction Verb Checker (`tsukuroi-shokunin/tools/check-r75-routed-r76.py`)
```python
# Checks prior round spotcheck defects (items 1-6) plus host state drift against committed revision blobs.
# Enforces bounded correction window: required replacement token must appear within 80 lines of its target.
# Strict correction verb taxonomy: every token block must carry a verb (supersede, erratum, correction, replaced).
# Validates receipt provenance: verifies referenced receipt hashes and checks that met=1 and ROUTED_OK hold.
# Output line: prints "ROUTED_STALE=<n> ROUTED_OK=<k>/<total>"; exits 0 only when ROUTED_STALE == 0.
```

---

## 6. Non-Obvious Move (Cross-Lane Synthesis)

### 6.1 Evidence
1. **Defect D7 Genesis**: In round 57, `corpus/current-claims.py` hardcoded its audited surface to round 56 (`## Round 56 — post-move`, `plans/round-56.md`, `corpus/lessons/round-56.md`), which blinded the gate to round 57's own stale registry count (defect D5).
2. **Peer Fix (I6)**: `R58ExecFixCode` is parameterizing `corpus/current-claims.py` to accept `--round N`. However, if `--round` is a mandatory argument or defaults to an old constant, standing verification hooks or manual runs risk passing obsolete flags or failing unexpectedly.
3. **Sibling Discovery Mechanism (`kama-shokunin`)**: In `tools/round42-selfdesc-reconcile.py`, Kama overcomes this by dynamically discovering the newest round from `SCORECARD.md`:
   `maxN = max(int(m.group(1)) for m in re.finditer(r'^## Round (\d+)', scorecard_text))`
   This allows unadorned runs to audit the active round automatically while `--round N` preserves historical verification.
4. **Fail-Closed UNBOUND Accounting**: Kama's `round74-receipt-claim-binding.py` proves that any unresolvable authority receipt or missing file must increment `unbound` and fail closed (`bad = mismatches + unbound > 0 => exit 1`).

### 6.2 Affected Axes
- **Calibration (C1)**: **Improved**. Eliminates the recurring risk of hardcoded round blindspots by dynamically binding unadorned gate runs to the latest declared round, while supporting explicit historical parameterization via `--round N`.
- **Operability (C2)**: **Preserved**. Operates independently of C2 trial execution while ensuring clean, reproducible verification.
- **Harms**: None. Frozen predicates in `plans/round-58.md` remain completely untouched.

### 6.3 Proposed Move
In `corpus/current-claims.py`:
1. Implement dynamic round default: make `--round` optional; when omitted, parse `SCORECARD.md` for `max(int(m.group(1)) for m in re.finditer(r'^## Round (\d+)', text))` and audit that round, while honoring an explicit `--round N` parameter when supplied.
2. Ensure fail-closed `UNBOUND` accounting: ensure any authority file that cannot be resolved (or is empty) increments `unbound` and triggers non-zero exit code (`bad = mismatches + unbound > 0`).

### 6.4 Risks and Mitigations
- *Risk*: Amending frozen counter `plans/round-58-c1-check.py` would violate freeze rules.
- *Mitigation*: The frozen check requires only that `corpus/current-claims.py` accepts `--round N` and derives surfaces from N; making `--round` default to the discovered latest round strictly satisfies I6 while making the tool resilient against manual omission.

### 6.5 Verification
- `python3 -I -B corpus/current-claims.py --root . --round 57` derives round 57 surfaces and exits with the evaluated calibration state.
- `python3 -I -B corpus/current-claims.py --root .` automatically derives the newest round without crashing.
- `python3 -I -B corpus/current-claims.py --selftest` passes all synthetic test cases rc 0.

---

## 7. The One Pattern Worth Learning

**Dynamic Round Discovery with Optional Parameterization** (from `kama-shokunin/tools/round42-selfdesc-reconcile.py`):
Rather than requiring every caller and script to manually pass `--round N` (or hardcoding constants that rot each round), self-description tools should discover the latest round from `SCORECARD.md` as the default, while accepting `--round N` as an explicit override for historical audits. This permanently closes the D7 defect class across future rounds.

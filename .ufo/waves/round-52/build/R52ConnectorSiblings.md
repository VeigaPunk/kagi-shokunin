# R52ConnectorSiblings — sibling-overlap, assimilation scan, and connector synthesis (round 52 wave 1)

Seat: R52ConnectorSiblings (connector; leaf member — no subagent dispatch).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Domain: secrets & vault ops (OpenBao/Vault, SOPS/age, 1Password CLI hygiene).
BASE: `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`.
Predeclaration: `52ebb412561d9601ad8658c30d1cfa0087af64d4` (frozen plan `plans/round-52.md`, counters `plans/round-52-c1.sh`, `plans/round-52-c2.sh`, pre-freeze controls `plans/round-52-controls.sh`).
Judged on: **adjacency, coverage**.
Milestones: C1 OpenBao KV v2 version-lifecycle trial (capability, S110); C2 rewrap statements agree with binary (D1).

Write scope strictly observed: only `.ufo/waves/round-52/build/R52ConnectorSiblings*` and scratch `$HYAKU_SCRATCH/kagi-r52/R52ConnectorSiblings/` written. No edits to `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `README.md`, `QUALITY`, `SOURCES.md`, registries, or fleet files. No git mutating commands executed anywhere. Refusal boundary observed: zero secrets, tokens, passwords, or keys read, copied, or logged.

---

## 1. Sibling Lane Corpus Grep

A complete read-only scan was conducted across all 20 sibling lane repos under `/home/vgpnk/Projects/shokunin/*-shokunin` (excluding `kagi-shokunin`) covering 243,748 files in their `corpus/` directories.
Search terms: `KV v2`, `kv undelete`, `kv destroy`, `max_versions`, `check-and-set`, `rewrap`.

### Summary of Searches across 20 Siblings (243,748 corpus files)

| Term | Command Pattern | Sibling Corpus Hits | Summary |
|---|---|---|---|
| `KV v2` | `grep -ril "KV v2" <sibling>/corpus` | **0** | No sibling holds KV v2 material. |
| `kv undelete` | `grep -ril "kv undelete" <sibling>/corpus` | **0** | No sibling mentions `kv undelete`. |
| `kv destroy` | `grep -ril "kv destroy" <sibling>/corpus` | **0** | No sibling mentions `kv destroy`. |
| `max_versions` | `grep -ril "max_versions" <sibling>/corpus` | **0** | No sibling mentions `max_versions`. |
| `check-and-set` | `grep -ril "check-and-set" <sibling>/corpus` | **0** | No sibling mentions `check-and-set`. |
| `rewrap` | `grep -ril "rewrap" <sibling>/corpus` | **15** | 15 hits across 6 siblings — **all false positives / unrelated domains** (see table below). |

### Detailed Hits Table: Sibling Repositories

| # | Location | Match Content | Class | Owner | Overlap Verdict |
|---|---|---|---|---|---|
| 1 | `game-dev-2d-shokunin/corpus/live/r25-export-critic/target-isolation/relroot_abstarget/project/out/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string; unrelated to secrets) |
| 2 | `game-dev-2d-shokunin/corpus/live/r25-export-scout/pair1-absolute/project/out/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 3 | `game-dev-2d-shokunin/corpus/live/r25-export-scout/pair2-absolute/project/out/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 4 | `game-dev-2d-shokunin/corpus/live/r25-export-scout/pair3-absolute/project/out/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 5 | `game-dev-2d-shokunin/corpus/live/r25-export-scout/pair4-relative-absolute/project/out/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 6 | `game-dev-2d-shokunin/corpus/live/r25-pair-reviewer/pairs/runroot-absolute-1/export/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 7 | `game-dev-2d-shokunin/corpus/live/r25-pair-reviewer/pairs/runroot-absolute-2/export/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 8 | `game-dev-2d-shokunin/corpus/live/runs/20261019T023223438217Z/scratch/out/fixture.x86_64` | Binary string match `rewrap` | none | game-dev-2d | **none** (compiled game-dev test binary string) |
| 9 | `kake-shokunin/corpus/lessons/round-23.md:33` | `exact or whitespace-only rewrap` | none | kake | **none** (Markdown/prose line wrapping; unrelated to secrets) |
| 10 | `kasegi-shokunin/corpus/lessons/round-14.md:25` | `Rewrap by hand keeping every path:line intact` | none | kasegi | **none** (mechanical text reflow and line wrapping) |
| 11 | `kasegi-shokunin/corpus/lessons/round-9.md:32` | `2026-09-14/15 rewrap wave` | none | kasegi | **none** (historical wave identifier for text formatting) |
| 12 | `kengaku-shokunin/corpus/evidence/round30/quote-mode-six-rows.txt:6,13,19` | Git commit log lines recording commit message rewrapping | none | kengaku | **none** (git commit message wrapping) |
| 13 | `kotodama-shokunin/corpus/knowledge/culture-material/funerary-material-culture.md:12` | Funerary anthropology: wrapping/rewrapping burial textiles | none | kotodama | **none** (anthropological funerary ritual dress) |
| 14 | `kotodama-shokunin/corpus/knowledge/civilizations/malagasy-madagascar.md:98,108,187` | Famadihana ritual: turning of the bones and rewrapping remains | none | kotodama | **none** (Madagascar cultural mortuary practice) |
| 15 | `tabi-shokunin/corpus/evidence/round-13/aria/node_modules/playwright/lib/transform/babelBundle.js` | JS bundler token/code rewrapper | none | tabi | **none** (Playwright babel AST transformation code) |

### Overlap Verdict
- **Sibling-owned:** **none**. No sibling repository owns, operates, or tests any aspect of KV v2 version lifecycle mechanics (`check-and-set`, `kv delete`, `kv undelete`, `kv destroy`, `max_versions`, or `metadata delete`) or Vault/OpenBao token response wrapping / rewrapping.
- **Owned by kagi:** All KV v2 version operations and OpenBao response-wrapping mechanisms are **owned by kagi outright**.

---

## 2. Shokuknow Staged Theme Scan (`merge/kagi`)

A read-only search was conducted in `/home/vgpnk/Projects/shokuknow/merge/kagi/` for staged themes matching KV versioning, OpenBao, or token rewrapping.

### Searches in `/home/vgpnk/Projects/shokuknow/merge/kagi/`

1. `grep -ri "openbao" /home/vgpnk/Projects/shokuknow/merge/kagi`: **0 matches** (exit 1).
2. `grep -ri "kv" /home/vgpnk/Projects/shokuknow/merge/kagi`: **0 matches** (exit 1).
3. `grep -ri "rewrap" /home/vgpnk/Projects/shokuknow/merge/kagi`: **0 matches** (exit 1).
4. `grep -ri "max_versions" /home/vgpnk/Projects/shokuknow/merge/kagi`: **0 matches** (exit 1).
5. `grep -ri "vault" /home/vgpnk/Projects/shokuknow/merge/kagi`: **1 match** in `knowledge/corpus/knowledge/oidc-federation-trust-policy.md:90-91`:
   - Match: `"It does not cover the **Vault-side** audience check on a JWT/OIDC login (lane rows S012/S022), which is the consuming side of the same idea."` (Scope demarcation only; no KV or OpenBao content).
6. `grep -ri "version" /home/vgpnk/Projects/shokuknow/merge/kagi`: **19 files matched**, consisting exclusively of OIDC federation specs, NIST SP 800-131A revisions, Cloud KMS lifecycle custody, BetterLeaks v1/v2 rule deltas, ISO 11770-3 edition chains, and TruffleHog verification versions. None touch KV v2 versioning or OpenBao.

### Assimilation Verdict
- **Assimilation verdict for merge/kagi:** `none`.
- **Exact command finding none:**
  ```bash
  grep -ri -E "openbao|kv|rewrap" /home/vgpnk/Projects/shokuknow/merge/kagi
  ```
  *(exit code 1, 0 matches)*.

---

## 3. Considerthese Review

The newest file in `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/` was read:
Path: `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/2026-10-26.md` (HEAD read `c303c92`, last commit `69b61db`).

### Proposal Inventory in `considerthese/2026-10-26.md`

1. **Proposal 1: "A repair-only release path under a HOLD."**
   - *Description:* Procedural proposal to allow operator release of narrow repair-only tickets during policy holds.
   - *Status:* Unimplemented procedural idea. Does not touch KV v2 or rewrap.
2. **Proposal 2: "Machine-readable lane status."**
   - *Description:* Put lane dispatch status in a machine-readable line in `SCORECARD.md`.
   - *Status:* Mined and adopted in round 31 (`lane-status:` line in `SCORECARD.md`).
3. **Proposal 3: "Mark known-defective instrument output."**
   - *Description:* Append `KNOWN_DEFECT: D1` to `release-clock.py` output.
   - *Status:* Unimplemented tool-wrapper idea for the release clock. Does not touch round 52 claims.
4. **Proposal 4: "Create `considerthese/BACKLOG.md`."**
   - *Description:* Consolidate ongoing suggestion status into a single status table.
   - *Status:* Unimplemented documentation hygiene suggestion. Does not touch round 52 claims.

### Carried-Over Suggestions Mentioned in `2026-10-26.md`
- 2026-10-25: differential tokenizer test, gate-output receipts, round-shape validation at plan freeze, `provider_events` in wave records, claim sensitivity pre-flight.
- Older carry-overs: `op` release clock on dotenv contract, byte cases, open-round age clock.

### Finding
**None** of the proposals in `considerthese/2026-10-26.md` fit this round's claims (C1: OpenBao KV v2 version lifecycle trial, C2: rewrap calibration statements agreement with pinned binary).

---

## 4. BASE Commit Audit for `max_versions` and KV v2

A complete `git grep -n -i -E "max_versions|kv v2|kv-v2"` was executed against BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b` in `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

### File Inventory at BASE and Linking Recommendations

| Path at BASE | Line(s) | Match Content Summary | Should New Entry Link It? | Rationale |
|---|---|---|---|---|
| `corpus/SOURCES.md` | L30, L157, L178-179 | S024 row (`max_versions (int: 0) – The number of versions to keep per key.`, `POST /:secret-mount-path/config`), plus historical lead notes | **YES (Link S024)** | **Crucial boundary link.** The new entry (`corpus/knowledge/openbao-kv-v2-version-lifecycle.md`) must cite S024 in its Scope section to establish that Vault's `max_versions` configuration parameter is a documentation fact about Vault, distinct from OpenBao 2.7.2's measured version-lifecycle capability. |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | L110, L274, L288 | L110 states KV issues no leases; L274/288 note round-51 response-wrapping trial uses dev server's KV mount | **NO** | Lease entry concerns token/lease lifecycles; its KV mention is only to clarify that KV issues no leases. The new entry is a dedicated file for KV v2 versioning. |
| `corpus/openbao-wrap-trial.sh` | L80 | Comment noting `put PATH VALUE -> 0 on success (KV v2 at the dev server's default secret/ mount)` | **NO** | Wrap trial uses KV v2 strictly as a scratch value store for nonces; does not exercise KV versioning. |
| `corpus/source-fetches.tsv` | L51 | S024 fetch record, quote hash, and locator | **NO** | Internal provenance ledger table; entries cite `SOURCES.md` rows, never internal TSVs. |
| `corpus/fired-reverify.tsv` | L10 | S024 reverify status (`teaching-holds`) | **NO** | Internal cache table. |
| `corpus/lessons/round-23.md` | L27, 31, 181, 183 | Historical lesson recording the addition of S024 | **NO** | Historical lesson narrative. |
| `corpus/lessons/round-23-verifier-spotcheck.md` | L113, 163 | Historical verifier spotcheck admitting S024 | **NO** | Historical verifier record. |
| `LOG.md` | L1205 | Governance entry for round 23 adding S024 | **NO** | High-level governance log. |
| `PROVINCE.md` | L95 | Province entry noting round-51 OpenBao response wrapping core capability | **NO** | Lane domain definition file. |
| `considerthese/2026-10-21.md` | L85 | Informal reflection note mentioning KV v2 retention | **NO** | Informal daily reflection. |
| `plans/round-51.md` | L73 | Mention of KV v2 mount in ceiling discussion | **NO** | Frozen plan of an earlier round. |
| Historical `.ufo/waves/` files (rounds 22–28, 30, 33, 37, 41, 46, 47, 51; ~194 files) | Various | Historical wave scratch files, clocks, captures, and reviews | **NO** | Ephemeral/immutable historical wave artifacts. |

---

## 5. Non-Obvious Move (UFO-FSD Connector Synthesis)

### Context & Evidence in Current Round Cache
In `plans/round-52-c1.sh`:
1. The counter extracts the measured revision into `$W/tree` (`git archive $1 | tar -x -C "$W/tree"` at line 64).
2. The trial is dispatched across eight modes with `--work "$d/work"`, where `$d="$W/run/$(rhex)"` (lines 108–121).
3. The trial's working directory is `$W/run/<rhex>/work`. From this location, the tree containing the knowledge entry under test is located at `../../../tree` (i.e. `$W/tree`).
4. In `plans/round-52-c1.sh:141-156`, the counter checks the knowledge entry:
   ```bash
   ENTRY="$T/corpus/knowledge/openbao-kv-v2-version-lifecycle.md"
   entry_line() { ... }
   for i in 1 2 3 4 5; do
     ...
     ev=$(entry_line "$id")
     ...
   done
   ```
   **This evaluation occurs at line 153, *after* all eight mode runs have executed.**
5. In sibling lane `kasegi-shokunin` (`corpus/instruments/freeze-check.py:1-33`), the manifest gate enforces `FC-BASE-MUTATED`: asserting that the counter leaves the base/candidate tree byte-for-byte untouched. In `chousa-shokunin` (`corpus/knowledge/capture-path-pin-r41.md`), evidence demonstrates that post-execution filesystem checks taken from shared scratch roots are vulnerable to self-modification by candidate code.

### Explicit Contradiction
The counter treats `entry_line` as a **static documentation contract check** (verifying that the committed knowledge entry documents the five mechanics for OpenBao 2.7.2), yet executes this check **after** running candidate code (`run "$m"` across 8 runs) with full write permissions to the filesystem directory holding the knowledge entry (`$W/tree`). A candidate trial that omits documentation lines or modifies the file during execution can forge a passing `entry=1` verdict.

### Proposed Move (One, Bounded)
**Enforce substrate-level immutability on `$T` and hoist documentation witness verification prior to trial dispatch.**

1. **Substrate Protection:** In `plans/round-52-c1.sh`, immediately following tree extraction at line 64:
   ```bash
   chmod -R a-w "$W/tree"
   ```
   This prevents any process invoked during the trial runs from mutating the measured knowledge entry, SOURCES registry, or test fixtures.
2. **Execution Hoisting:** Move the `ENTRY` / `entry_line` definition and evaluation (lines 141–148) above the run loop (line 135), recording `ENTRY_OK[T<n>]=1|0` statically before `run "$m"` is invoked.
3. **Second-Order Effects Across Surfaces:**
   - **Runtime surface:** Candidate trial code running in `--work "$d/work"` cannot write to `$T` or modify knowledge files.
   - **Contract surface:** The mathematical contract of `C1_OPENBAO_KV` is strictly preserved: `DISCRIMINATE(T)` continues to require that the committed entry documents `- T<n> ` and `OpenBao 2.7.2`. Target remains 5.
   - **Substrate surface:** Relies purely on standard POSIX filesystem permissions (`chmod a-w`), introducing zero external tools, containers, or daemon dependencies.
   - **Verification surface:** Restores causal separation between static documentation verification and dynamic runtime execution. Eliminates the forgery attack vector where candidate scripts append missing documentation lines during runtime.

### Affected Axes
- **Operability:** **Improves**. The capability counter becomes tamper-resistant against candidate self-modification.
- **Calibration:** **Improves / Neutral**. Closes a potential fail-open path without altering C2 calibration or truth-bound errata.
- **Adjacency:** **Improves**. Synthesizes kagi's capability counter with kasegi's `FC-BASE-MUTATED` standard and chousa's path-blindness isolation doctrine.
- **Depth / Freshness / Coverage:** **Untouched** (no negative side effects).

### Risks & Mitigations
- *Risk:* `rm -rf -- "$W"` during exit trap might fail if read-only permissions prevent directory removal.
  *Mitigation:* Prepend `chmod -R u+w "$W"` in the counter's cleanup trap before `rm -rf -- "$W"`.
- *Risk:* Plan freeze prohibits mutating `plans/round-52-c1.sh` during round 52 wave 1.
  *Mitigation:* Recommended as a bounded hardening move for the round-53 plan or pre-landing integration, matching kagi's disciplined frozen-plan governance.

### Verification Protocol
To verify the move:
1. Create a mutant fixture with `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` lacking the `- T1 ` line.
2. Provide a forged trial script that attempts `echo "- T1 OpenBao 2.7.2" >> $(dirname $(dirname $(dirname "$WORK")))/tree/corpus/knowledge/openbao-kv-v2-version-lifecycle.md` before reporting HOLDS.
3. Under the unfixed counter: the attack succeeds, `entry_line` reads 1, and C1 over-scores.
4. Under the proposed move: `chmod a-w` blocks the write (or pre-run evaluation reads 0), the attack fails, and C1 reads `entry=0`, correctly registering 0.

---

## 6. Limits of Scan & Verification

- Searches across 20 sibling repos were conducted via automated ripgrep/grep over 243,748 corpus files.
- `merge/kagi` was inspected read-only as text; no campaign tools were invoked.
- `considerthese/2026-10-26.md` was analyzed directly from the repository.
- BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b` was inspected using read-only `git grep`.
- Invocation receipts with exact commands, exit codes, and hit counts are recorded in `.ufo/waves/round-52/build/R52ConnectorSiblings/grep-receipts.txt`.

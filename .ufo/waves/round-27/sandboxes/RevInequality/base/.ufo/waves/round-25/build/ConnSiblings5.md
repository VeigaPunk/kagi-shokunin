# Sibling-overlap scan — kagi round-25 claims

Seat: `KagiR25.ConnSiblings5-2` | Base: `4587c61a348e4528717404a68912c373f3ef4d03`
Judged axes: calibration, operability, freshness | Read-only scan (no lane/sibling edits)
Sibling revisions: kaidoku `7787fea4`, kotodama `4ad26836`, souji `1988860e`

## 1. Per-lane findings

`kaidoku-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/knowledge/2026-10-13-rea-self-documentation.md:4` tool_count: 170, `corpus/lessons/round-16.md:37`). No doc-number gate in `corpus/`. In `.ufo/gates/c1-census-v10.py:51-120`: version-token census checks CURRENT vs DATED scopes, but no live command binding for doc-stated numbers.
- (b) Lone-clone / fleet citations: none found (grep exit 1). In `.ufo/gates/citation-drift/citation-drift-probe.py:28-36`, out-of-repo citations resolve via `@<slug>` snapshot files under `--snapshot-dir` verified by sha256 in `expected.json` (:24-27); no lone-clone or fleet-layout logic.
- (c) Release clocks: none found (grep exit 1). 33 `recheck: on-release` rows in `corpus/SOURCES.md:7-49` (S001-S007, S012-S013, S016-S022, S024-S027, S029-S032, S035-S041, S046-S047), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

`kotodama-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/knowledge/linguistics/semantics-pragmatics.md:14`, `corpus/knowledge/verification/index-sweep-verification.md:3-16`). In `reports/round-28/readme/sweep.py:1-45`: index & footer sweep verifies `corpus/README.md` counts footer `(total 199 files; directory totals 19/19/18/29/20/94)` against live tree counts (exit 0/1, `--selftest`).
- (b) Lone-clone / fleet citations: none found (grep exit 1). Citation tools (`tools/harness/basename-couples-resolver.py:1-35`, `tools/gates/provenance-audit.py:1-40`) resolve intra-corpus/fixture references only; no fleet-layout handling.
- (c) Release clocks: none found (grep exit 1). 9 `recheck: on-release` rows in `corpus/SOURCES.md:30-47` (S001-S004, S007, S010, S015, S018, S042), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

`souji-shokunin`:
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout: `corpus/knowledge/git-repo-structure-readonly.md:3`, `corpus/lessons/round-18.md:12`). In `tools/impl-35.sh:543-624` (`run_drift`): doc-number binding tool parses doc-claimed measurements (`${claimed_m}M .scratch`, prunable worktree counts) from SKILL.md and compares to live `du -sb` and `git worktree list`, emitting `DRIFT` (exit 3) or `ALIGNED`; `tools/impl-42.sh:179-324` (`run_reconcile`).
- (b) Lone-clone / fleet citations: gate `tools/souji-landing-gate.py:905-984, 2287` implements `--fleet-root PATH` where pointer paths starting with `../` (single escape) or `.ufo/waves/hyaku/` are verified against `fleet_root` and classified into `fleet` list (`ptr_fleet`, `classification: "fleet"`), while unresolvable pointers fail as `LG-DANGLING-PTR`. In a lone clone without `--fleet-root`, those pointers fail.
- (c) Release clocks: none found (grep exit 1). 83 `recheck: on-release` rows in `corpus/SOURCES.md:21-96` (S001-S010, S012-S014, S016-S037, S041-S087), but 0 release clocks or binding scripts.
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032.

## 2. Contested scope & reusable conventions

- Contested scope: none found. Sibling lanes explicitly yield secret/vault/credential scope to kagi:
  - `souji-shokunin/corpus/SOURCES.md:35` (S015): explicitly records `adjacent (kagi): revoke or rotate a leaked secret first; a git-filter-repo rewrite needs coordination and has side effects; souji routes this work and never does it`; `tools/souji-vault-verify.sh:34-35` refuses secret-shaped paths (`*.env`, `.envrc`, `*credential*`, `*secret*`, `id_*`, `*.pem`) and restricts "vault" strictly to Obsidian vaults (`moved-to-obsidian`).
  - `kaidoku-shokunin`: treats 1Password/Obsidian app asar as static analysis targets only (`corpus/knowledge/2026-10-13-r4-06-1password-asar.md:35`) and explicitly excludes/redacts credentials during CDP inspection (`corpus/knowledge/2026-10-13-r2-skill-references-deep.md:72`).
  - `kotodama-shokunin`: uses "secret" strictly in anthropological context (`corpus/knowledge/linguistics/sociolinguistics-registers.md:74`, `myth-symbol/celestial-symbolism-calendars.md:133`) and "credential" metaphorically (`corpus/knowledge/linguistics/orality-formulaic-language.md:76`).
- Reusable conventions to copy:
  1. Doc-claimed measurement extractor & live comparator (`souji-shokunin/tools/impl-35.sh:548-588, 590-624`): regex extraction of doc claims paired with bounded live commands (`du -sb`, `git worktree list`), emitting structured `DRIFT`/`ALIGNED` status and summary counters.
  2. Fleet citation classifier with explicit count metrics (`souji-shokunin/tools/souji-landing-gate.py:946-979, 1609-1630`): distinguishes lane-local vs fleet-resolved paths (`ptr_fleet` count in JSON summary), providing a clean antecedent for kagi C2's `fleet_absent=N` classification.
  3. Positive floor & blind instrument guards (`kaidoku-shokunin/.ufo/gates/c1-census-v10.py:65-85`): `BLIND-INSTRUMENT` check requiring >=1 evaluated locus per readable file to ensure regex/needle changes do not cause false green passes.
  4. Read-only index & footer live sweep with synthetic selftest (`kotodama-shokunin/reports/round-28/readme/sweep.py:1-45, 120-180`): checks current-tense summary blocks against live disk structure with `--selftest` in-memory controls.

## 3. Connector synthesis proposal

- Evidence: kagi C1 (`corpus/self-counts.py`) binds doc numbers to live rows/commands, while C2 (`claim-ledger.sh`) requires lone-clone vs fleet-layout handling. Souji (`impl-35.sh:548-624`) demonstrated regex-extracting doc quantities and comparing against live command execution, while `souji-landing-gate.py:946-979` established classifying citations into lane vs fleet sets. Kaidoku (`c1-census-v10.py:65-85`) proved that without a positive floor (`BLIND-INSTRUMENT`), regex-based census gates can silently pass when needles fail to match.
- Affected axes: improves calibration (C1 positive floor prevents silent passing if regex fails to match doc lines) and operability (C2 layout-classification robustness); zero harm to freshness (C3).
- Proposed move:
  1. In `corpus/self-counts.py` (C1), incorporate Kaidoku's positive floor rule: enforce that every declared pattern in `corpus/self-counts.tsv` must match at least once (and exactly once per line), returning `UNLOCATED` (exit 1) if a pattern matches 0 times, preventing blind passes.
  2. In `corpus/claim-ledger.sh` (C2), adopt Souji's clean separation: detect layout by checking for fleet root/sibling existence; when in lone-clone layout, classify unresolved fleet/sibling citations as `FLEET-ABSENT` with explicit summary counts (`fleet_absent=N`), exiting 1 (incomplete), keeping lane-local misses as `UNRESOLVED`.
- Risks: minimal; ensures strict contract adherence and stops unlocated regexes from decaying into silent passes.
- Verification: run `python3 corpus/self-counts.py --selftest` (with planted 0-match and multi-match cases) and `bash corpus/claim-ledger.sh citations` in both lone-clone and fleet sandbox layouts.

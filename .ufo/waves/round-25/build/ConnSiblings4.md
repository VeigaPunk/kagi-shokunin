# ConnSiblings4 — Sibling-Overlap Scan (Round 25)

Base revisions: kagi `4587c61`, game-dev-3d `3118be0`, kotoba `c61a973`, revenger `cf02419`.
Command: `git -C /home/vgpnk/Projects/shokunin/<lane> rev-parse HEAD` (rc=0).

## 1. Per-Lane Audit (a, b, c, d)

### game-dev-3d-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); on `corpus/`: rc=0 (`QUALITY.md:28` Q17 prose rule; `lessons/round-108.md:80` M15 quote), no count-binding gate. `reports/round-108/measure.sh:1-28` counts git blobs.
- (b) Lone-clone / fleet handling: None found.
  Command: `grep -rnE 'fleet|lone-clone|LAYOUT' corpus/ reports/` -> rc=1 (0 matches). `reports/round-108/census.sh:7` tests `[ -e "$p" ]` for local `used-by` paths only.
- (c) Release clocks: None found. `corpus/SOURCES.md:9-44` has 23 `on-release` rows (S001-S007, S011, S013-S019, S023, S024, S032-S036); 0 release clocks or recheck bindings.
- (d) Shared sources: None found. 0 shared URLs with kagi S005-S032 (Python URL set intersection, rc=0).

### kotoba-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); `corpus/` matches (`claim-census-round12.md:177`, `independent-verification-round12.md:214`) discuss historical stale numbers. `verifiers/verify_corpus_integrity.py:6-25` checks git ls-files and report counts against static `corpus-baseline.json:12-49`, not an inline live doc-count binder table.
- (b) Lone-clone / fleet handling: None in gate.
  `verifiers/verify_corpus_integrity.py:258-264` resolves report pointers (`resolve_pointer()` -> `is_file()`). Hardcoded `/home/vgpnk/Projects/...` pointers in `corpus-baseline.json:57` cause hard `report_dead` failures in isolated clones; no lone-clone classification or `FLEET-ABSENT` token.
- (c) Release clocks: None found. `corpus/SOURCES.md:14-23` has 4 `on-release` rows (S001, S005, S006, S008) and 2 `on-commit` rows; 0 release clocks or recheck bindings.
- (d) Shared sources: None found. 0 shared URLs with kagi S005-S032 (Python URL set intersection, rc=0).

### revenger-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); `corpus/SOURCES.md:16` S002 notes tool-count staleness in prose; `corpus/verify_*.py` are 11 fixture verifiers (EVM, PE resources, icons, JS graphs), no doc-count binder.
- (b) Lone-clone / fleet handling: None found.
  `corpus/verify_icon_languages.py:12` hardcodes historical corpus `HIST` path as identity token, never read through. No citation gate or fleet layout handling.
- (c) Release clocks: None found. `corpus/SOURCES.md:16-27` has 6 `on-release` rows (S002, S006, S008, S010, S011, S013); 0 release clocks or automated recheck tools.
- (d) Shared sources: None found. 0 shared URLs with kagi S005-S032 (Python URL set intersection, rc=0).

## 2. Reusable Conventions to Copy
1. Standard exit ladder: `kotoba-shokunin/verifiers/verify_corpus_integrity.py:89-94` (0=clean, 1=drift/stale, 2=unreadable/env) and `check_substrate_pins.py:12-30` (typed codes `VACUOUS`, `NO_BASELINE`, `BAD_PIN`). Reusable for kagi C1 `self-counts.py` and C3 `release-clock.py`.
2. Fenced code masking: `kotoba-shokunin/verifiers/verify_corpus_integrity.py:165,315-348` (CommonMark 4.5 `FENCE_RE` and `fenced_lines()` prevents doc examples in fences from triggering false matches).
3. Explicit token categorization: `kotoba-shokunin/verifiers/verify_corpus_integrity.py:203-234` (`token_exclusion_reason` / `token_path_class` avoids silent drops). Reusable for C2 citation classification.
4. Committed-blob inspection: `game-dev-3d-shokunin/reports/round-108/measure.sh:1-8` (`git show "$REF:$1"` ensures count checks evaluate immutable git refs, preventing dirty working tree drift).
5. Used-by existence audit: `game-dev-3d-shokunin/reports/round-108/census.sh:7` (splits `used-by` paths on comma/semicolon and asserts existence).

## 3. Contested Scope
None found. All 3 target lanes respect kagi's domain boundary over vault/secret/credential ops:
- `kotoba-shokunin/corpus/knowledge/sibling-description-rewrites-round8.md:42-53,104-107`: explicitly audits kagi as sole domain specialist for "secrets & vault ops", "1Password op refs, credential hygiene evidence", "vault auth and CDP bridge".
- `game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/PROVENANCE.md:21`: treats credentials strictly as operator-owned prerequisites (Epic Games account login for Unreal download).
- `revenger-shokunin`: zero mentions of vault, credential, 1password, openbao, or sops in core docs.

## 4. UFO-FSD Connector Move: C1/C2 Synthesis (Layout-Aware Self-Counts)
- Evidence: Under C2, in a lone clone `claim-ledger.sh` outputs `LAYOUT-SKIP <id> (fleet layout absent)`. Under C1 (`plans/round-25.md:25`), `corpus/self-counts.py` evaluates `ledger:<ID>` sources by running their commands. If a self-count TSV row binds to a `[fleet]` ledger row, running `self-counts.py` in a lone clone observes `LAYOUT-SKIP` rather than the integer regex capture, causing a false STALE or UNLOCATED failure (exit 1/2) that breaks C1 operability.
- Affected Axes: Calibration (C1), Operability (C2).
- Proposed Move: (1) Enforce that `corpus/self-counts.tsv` rows bind only to lane-local live sources (`rows:<path>` or lane-local `ledger:<ID>`); (2) If a `ledger:<ID>` live source outputs `LAYOUT-SKIP`, `self-counts.py` classifies it as `LAYOUT_SKIPPED` (exit 0, `layout_skipped=K`), preserving lone-clone operability without masking local drift.
- Risks & Verification: Risk of masking stale numbers is mitigated by requiring `layout_skipped=0` in fleet layout. Verification: plant doc number mutation (turns red exit 1); run in scratch lone clone (expect `layout_skipped=1`, exit 0). [UNRUN in leaf seat; reserved for L1 integration].

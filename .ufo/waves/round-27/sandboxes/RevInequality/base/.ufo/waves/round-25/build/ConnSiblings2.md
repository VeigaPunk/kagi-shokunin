# ConnSiblings2 — Sibling-Overlap Scan (Round 25)

Base revisions: kagi `4587c61`, chousa `ba33332`, kasegi `8bf9807`, mado `741122d`, tsukuroi `0cbc34d`.
Command: `git -C /home/vgpnk/Projects/shokunin/<lane> rev-parse HEAD` (rc=0).

## 1. Per-Lane Audit (a, b, c, d)

### chousa-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -rniE 'self-count|stale number|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); on `corpus/` + `tools/`: rc=1 (0 matches).
- (b) Lone-clone / fleet handling: None in gate.
  `tools/research-gate.sh:274,281,616-628` checks `ROOT`/`LANE_ROOT`; no lone-clone/`FLEET-ABSENT` token. `corpus/lessons/round-25.md:21,38` records clone `--root ..` failed with 17 refused hops; fixed by passing explicit fleet root, not layout classification.
- (c) Release clocks: None. `corpus/SOURCES.md:11-39` has 7 `on-release` rows (S001, S004, S008, S017, S019, S025, S029); 0 release clocks or automated recheck tools.
- (d) Shared sources: 0 shared URLs with kagi S005-S032 (Python script URL intersection, rc=0).

### kasegi-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -rniE 'self-count|stale number|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); matches in `corpus/knowledge/evidence-dir.md:5` and `corpus/lessons/round-1-aggregator-audit.md:28` are prose/narrative, no count-binding gate.
- (b) Lone-clone / fleet handling: Has mirror derivation in citation tool.
  `corpus/instruments/resolve.py:112-125` detects absent mirror root via `_derive_mirror()` (`MIRROR_ABSENT = not os.path.isdir(...)`). Missing external cites classify as `GONE` (`rel-unresolved`), and stdout logs `(ABSENT — mirror fallback disabled)`.
- (c) Release clocks: None. `corpus/SOURCES.md:7-36` has 14 `on-release` rows (S001, S002, S010, S013-S015, S019-S022, S024, S025, S029, S030); 0 release clocks or automated bindings.
- (d) Shared sources: 0 shared URLs with kagi S005-S032 (Python script URL intersection, rc=0).

### mado-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -rniE 'self-count|stale number|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); `corpus/` matches (`arc-synthesis.md:282`, `round-10.md:157`) are narrative errata; `tools/`: rc=1 (0 matches).
- (b) Lone-clone / fleet handling: None. `tools/mado-verify.sh:18,122` checks desktop config planes via `--root DIR`, no citation gate or fleet layout handling.
- (c) Release clocks: None. `corpus/SOURCES.md:17-59` has 51 `on-release` rows (e.g. S005, S018, S021-S029, S035, S037); 0 release clocks or automated bindings.
- (d) Shared sources: 0 shared URLs with kagi S005-S032 (Python script URL intersection, rc=0).

### tsukuroi-shokunin
- (a) Doc-count gate: None found.
  Command: `grep -rniE 'self-count|stale number|doc.*count' corpus/ scripts` -> rc=2 (`scripts` missing); `corpus/` matches are prose; `tools/check-root-dac-correction.py:331` matches are test fixture helper defs, not doc-count binding gates.
- (b) Lone-clone / fleet handling: None. `tools/check-section-citations.py:27-50` checks 2 specific historical section errata against JSON spec via `--revision`; no fleet/lone-clone handling.
- (c) Release clocks: None. `corpus/SOURCES.md:21-87` has 43 `on-release` rows. `tools/check-recheck-commands.py:1-45` audits that `recheck:` procedures avoid forbidden binaries (`pacman`), but does not bind or observe release feeds.
- (d) Shared sources: 0 shared URLs with kagi S005-S032 (Python script URL intersection, rc=0).

## 2. Reusable Conventions to Copy
1. Absent-tree layout detection: `kasegi-shokunin/corpus/instruments/resolve.py:112-125` (derive root via env/candidates, set `*_ABSENT` bool, classify absent-target tokens as distinct outcome, print explicit status header). Directly reusable for kagi C2 `claim-ledger.sh` fleet detection.
2. Dual-root candidate resolution: `chousa-shokunin/tools/research-gate.sh:616-628` (check `$ROOT` then fallback to `$LANE_ROOT`).
3. Centralized revision binding: `tsukuroi-shokunin/tools/_revision.py:20-40` (`check-ref-format` + `merge-base --is-ancestor` with ordered exit-2 finding IDs).

## 3. Contested Scope
None found. All 4 sibling lanes explicitly route secrets/vault/credentials to kagi:
- `chousa-shokunin/PROVINCE.md:14` (defers secret values to kagi); `tools/research-gate.sh:589-598` (denies secret/token paths).
- `kasegi-shokunin/PROVINCE.md:45` ("kagi — secrets and vault handling"); `claim-gates.md:43` (generic regex only).
- `mado-shokunin/PROVINCE.md:14` ("secrets in configs (shape-only, → kagi)"); `corpus/knowledge/province-accuracy-selfaudit.md:56,144`.
- `tsukuroi-shokunin/PROVINCE.md:25,47,123` ("secrets (→ kagi)"; adjacency ADJ-02/OUT-003 assigns secrets & vault ops to kagi); `adjacency-handoffs-fleet-r1.md:125-132`.

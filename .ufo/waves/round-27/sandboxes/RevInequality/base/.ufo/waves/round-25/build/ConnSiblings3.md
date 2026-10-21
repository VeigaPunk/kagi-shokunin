# ConnSiblings3 — Sibling-Overlap Scan (Round 25)

Base revisions: kagi `4587c61`, game-dev-2d `bce53b8`, kengaku `b571944`, mori `e4d9384`.
Command: `git -C /home/vgpnk/Projects/shokunin/<lane> rev-parse HEAD` (exit 0).

## 1. Per-Lane Audit (a, b, c, d)

### game-dev-2d-shokunin
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout `corpus/lessons/round-105-verifier-spotcheck.md:then checked the bounded documentation/counter corrections at 'f67c64ae'` is prose). No live count-binding gate.
- (b) Lone-clone / fleet citations: none found. No citation gates (`git grep -iE 'lone-clone|fleet-absent|fleet_absent|fleet layout'` -> rc=1, 0 matches; only historical `reports/round-102/mutations/r102-crit4-cite-census.py`).
- (c) Release clocks: none found. 26 `recheck: on-release` rows in `corpus/SOURCES.md:7-36` (S001-S014, S016-S024, S026-S030); 0 release clocks or recheck scripts (`find . -name "*release*clock*"` -> 0 matches; animation clocks only).
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032 (URL intersection rc=0).

### kengaku-shokunin
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; matches in `corpus/evidence/` are review narratives). However, kengaku has standing doc-number gate `plans/state_check.py:1386-1443,1532-1560`: `check_p3a` binds SCORECARD capability numeric tokens (`unique_samples=(\d+)`, `--selftest (\d+) checks`, `mismatch=(\d+)`) to receipts; `check_p3b` binds PROVINCE.md row claims (`\b(\d+)\s+rows?\b`, `holds\s+(\d+)\s+after round 25`) to live `SOURCES.md` census; exit ladder 0=clean, 1=mismatch/stale, 2=usage/empty (anti-vacuous).
- (b) Lone-clone / fleet citations: none found. No citation gate (`git grep -iE 'lone-clone|fleet-absent|fleet_absent|fleet layout'` -> rc=1, 0 matches).
- (c) Release clocks: none found. 7 `recheck: on-release` rows in `corpus/SOURCES.md:27-68` (S005, S006, S023, S026, S027, S028, S046); 0 release clocks or automated recheck tools (`find . -name "*release*clock*"` -> 0 matches).
- (d) Shared sources: 1 shared URL with kagi S005-S032: `https://docs.python.org/3/library/re.html`
  - kagi S027 (`corpus/SOURCES.md:33`): Python `re` `\s` on str patterns (Unicode whitespace class).
  - kengaku S046 (`corpus/SOURCES.md:68`): Python regex docs for Unicode `\s` matching CRLF.
  Both opened 2026-10-21 referencing Python 3.15.0 documentation.

### mori-shokunin
- (a) Doc-number gate: none found with exact grep `grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts` (exit 2, `scripts` missing; stdout matches are prose; `considerthese/2026-10-20.md:3` noted stale count in `SKILL.md` "104/104 at 8d22d18" vs live 105/105, but no automated binder exists).
- (b) Lone-clone / fleet citations: none found. No citation gates (`git grep -iE 'lone-clone|fleet-absent|fleet_absent|fleet layout'` -> rc=1, 0 matches).
- (c) Release clocks: none found. 6 `recheck: on-release` rows in `corpus/SOURCES.md:7-27,47` (S001, S002, S007, S009, S014, S033); 0 release clocks or recheck tools (`find . -name "*release*clock*"` -> 0 matches).
- (d) Shared sources: none found. 0 shared URLs with kagi S005-S032 (URL intersection rc=0).

## 2. Reusable Conventions to Copy
1. Live doc-number binding & anti-vacuous protocol: `kengaku-shokunin/plans/state_check.py:15-17,1386-1443,1532-1560` (extracts regex groups from doc text, compares with live census/receipts; exit 2 on empty population/zero matches to prevent silent pass).
2. Fail-closed git mirror resolution: `mori-shokunin/tools/mori-round17-jj-regressions.py:12-45` (resolves lane branch from `git config lane.branch` before guessing, fails closed if mirror missing/unresolvable).
3. Immutable schema typing & hash pins: `mori-shokunin/tools/mori-content-review.py:1-30` (strict schema contracts `mori-content-population-v1` / `mori-content-reviews-v1`).

## 3. Contested Scope
None found. All 3 target lanes explicitly cede vault, secret, and credential authority to kagi:
- `kengaku-shokunin/PROVINCE.md:26,140`: "kagi: Janitor consumer-side endpoint/credential config (round-9 routing)".
- `mori-shokunin/PROVINCE.md:15,68`: "credential material (→ kagi)"; "kagi | Owns secrets, vault operations, and credential-hygiene evidence; mori never reads or reports credential material or secret content."
- `game-dev-2d-shokunin/corpus/SOURCES.md:13`: restricts credential mention to Godot export presets boundary (`.godot/export_credentials.cfg` exclusion).

## 4. UFO-FSD Connector Move: C1/C2 Synthesis (Substrate Decoupling & Selftest Synchronization)
- Evidence: In `XSelfCounts.md:39,49-50`, C1 `self-counts.py` identified two blockers: (1) `SC-LEDGER-SELFTEST` binds `SKILL.md:243` to `ledger:R11-09` (`claim-ledger.sh --selftest`), which measures 151 at BASE, but C2's lone-clone test cases will immediately change this number; (2) `SC-CENSUS-SELFTEST` binds `SKILL.md:36` to `ledger:R11-03`, whose note carries `[substrate]`, triggering `self-counts.py` policy refusal (exit 2). Additionally, `kengaku-shokunin/plans/state_check.py:1532-1560` proved that uncoordinated doc numbers drift across milestone landings.
- Affected Axes: Calibration (C1), Operability (C2).
- Proposed Move: (1) In `corpus/claim-ledger.tsv:17` (`R11-03`), decouple the hermetic `--selftest` invocation from the `[substrate]` note tag (or add an un-tagged `ledger:R11-03-selftest` entry), allowing `self-counts.py` to evaluate the 16-case selftest cleanly without policy refusal; (2) Synchronize `SKILL.md:243`'s case tally directly with C2's final post-landing selftest count rather than BASE 151.
- Risks & Verification: Risk of running live substrate is zero because `--selftest` is proven offline; risk of count mismatch is zero by ordering. Verification: run `python3 corpus/self-counts.py` post-C2 landing; expect `SELF_COUNTS: CLEAN (claims=9 stale=0)` exit 0 [UNRUN in leaf seat; reserved for L1 integration].

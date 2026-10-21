# Sibling-Overlap Scan & Connector Move: ConnSiblings6

## Lane Revisions & Scope
- kagi-shokunin: `4587c61a348e4528717404a68912c373f3ef4d03` (BASE)
- kake-shokunin: `f7de3ab4e9f030a15a857a5a08631bd8e690f436`
- kumitate-shokunin: `2fa28e5761220ee5b1c625bbb81ed5677c4522d6`
- tabi-shokunin: `4ae99816b8994fdedc159156d8d9d242dd5c4782`

## 1. Per-Lane Audit of Claims (a)-(d)

### kake-shokunin
- (a) Doc-number binding gate: none found.
  Command: `cd /home/vgpnk/Projects/shokunin/kake-shokunin && grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts`
  Exit: 0. Stdout excerpt: `corpus/knowledge/ghp-custom-domain.md:1`, `corpus/lessons/round-8-aggregator-box3-coldrun.md:1`, `round-9-aggregator-corpus-verdict.md:1`, `round-23.md:1` (prose mentions of counts, no binding gate or script).
- (b) Lone-clone / fleet-layout citation handling: none found.
  Command: `cd /home/vgpnk/Projects/shokunin/kake-shokunin && grep -n 'lone-clone\|fleet.*layout\|fleet_absent' scripts/freshness-sweep.mjs`
  Exit: 1. `scripts/freshness-sweep.mjs:124-125,369-373` matches only absolute `~` or `/home/vgpnk/` paths; bare relative citations are informational (`relativeCites`, :377); no sibling/fleet citation resolution.
- (c) Release clocks in SOURCES.md: none found.
  5 rows have `recheck: on-release` (`corpus/SOURCES.md:9,10,27,34,35`), but `grep -ri 'release-clock' .` exit 1. No tool or binding table exists.
- (d) Shared sources (kagi S005-S032): none found (0/28 URLs match).

### kumitate-shokunin
- (a) Doc-number binding gate: none found.
  Command: `cd /home/vgpnk/Projects/shokunin/kumitate-shokunin && grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts`
  Exit: 0. Stdout excerpt: `corpus/lessons/round-8-aggregator-box3-coldrun.md:1`, `corpus/README.md:1`. Note: `scripts/claims-check.mjs:28` enforces `N members` in SCORECARD notes (`MEMBER_COUNT_DRIFT`), but no general doc self-count gate exists.
- (b) Lone-clone / fleet-layout citation handling: none found.
  Command: `cd /home/vgpnk/Projects/shokunin/kumitate-shokunin && grep -n 'lone-clone\|fleet_absent' scripts/cite-check.mjs`
  Exit: 1. `scripts/cite-check.mjs:272-277` requires `--fleet` (defaults to `dirname(self)` :265) and fails closed (exit 2) if missing. If parent exists, missing fleet docs grade `FLEET_MISSING` (:987, exit 1). No `lone-clone` layout mode or `LAYOUT-SKIP` mechanism.
- (c) Release clocks in SOURCES.md: none found.
  12 rows have `recheck: on-release` (`corpus/SOURCES.md:14-19,23,25-27,35,37,39,40,44`), but `grep -ri 'release-clock' .` exit 1. No clock tool exists.
- (d) Shared sources (kagi S005-S032): none found (0/28 URLs match).

### tabi-shokunin
- (a) Doc-number binding gate: none found.
  Command: `cd /home/vgpnk/Projects/shokunin/tabi-shokunin && grep -ri 'self-count\|stale number\|doc.*count' corpus/ scripts`
  Exit: 0. Stdout excerpt: matches in `corpus/knowledge/cdp-evidence-patterns.md`, `executor-test-sufficiency.md`, etc. `scripts/check-measurement-binding.mjs:1-40` binds counter script sha256 and measured revision to claims, not doc self-counts.
- (b) Lone-clone / fleet-layout citation handling: none found.
  Command: `cd /home/vgpnk/Projects/shokunin/tabi-shokunin && grep -n 'lone-clone\|fleet_absent' scripts/check-adjacency.mjs`
  Exit: 1. `scripts/check-adjacency.mjs:33-42,513-524` accepts `--fleet <dir>`. In lone clones without sibling dirs, missing siblings grade `siblingUnresolved` (:696, exit 1). No lone-clone layout detection, `fleet_absent` counter, or layout skip.
- (c) Release clocks in SOURCES.md: none found.
  37 rows have `recheck: on-release` (`corpus/SOURCES.md:15,18,27-31,34,35,37,38,40-42,44,45,...`), but `grep -ri 'release-clock' .` exit 1. No clock tool exists.
- (d) Shared sources (kagi S005-S032): none found (0/28 URLs match).

## 2. Reusable Conventions & Contested Scope
- **Reusable conventions:**
  1. `kumitate-shokunin/scripts/cite-check.mjs:60-65,982-990`: Separating `SELF_MISSING` (lane error) from `FLEET_MISSING` (fleet layout missing) — copies into kagi C2 `UNRESOLVED` vs `FLEET-ABSENT`.
  2. `tabi-shokunin/scripts/check-adjacency.mjs:41-42,1297-1340`: `GIT_CEILING_DIRECTORIES` guard against parent escape, plus disposable git fixtures in tmpdir for hermetic self-tests.
  3. `kumitate-shokunin/scripts/claims-check.mjs:28`: Deriving section count from markdown headers to verify declared counts.
- **Contested scope:**
  1. `kake-shokunin/PROVINCE.md:34-36`: Confirms "kagi owns secrets and credential custody"; flags "the the-musketeer Chrome profile lease is contested scope (kagi/tabi/kake)". Kake's "vault" is public mirror `veigapunk.kimi.page` (`corpus/knowledge/vault-properties.md:5-7`), not a secret store.
  2. `kumitate-shokunin/PROVINCE.md:28` & `corpus/knowledge/kimi-config-plane.md:410-411`: Routes all `api_key` rotation, token stores (`credentials/*.json`, `server.token`), and OAuth proxy security to kagi.
  3. `tabi-shokunin/PROVINCE.md:16` & `interaction-approval-table.md:100,144`: Refuses secrets ("secrets -> kagi"); 1Password presence is shape-only NMH config (`browser-surface-census.md:77-80`).

## 3. Connector Move: C1-C2 Lone-Clone Ledger Binding Synthesis
- **Evidence:** C1 (`plans/round-25.md:24-31`) binds doc counts via `ledger:<ID>`, executing ledger commands. C2 (`:38-55`) modifies `claim-ledger.sh` so `[fleet]` rows (e.g. `R11-08`) emit `LAYOUT-SKIP <id>` in lone clones.
- **Affected Axes:** Operability (C2), Calibration (C1).
- **Proposed Move:** In `corpus/self-counts.py`, teach `ledger:<ID>` resolution to handle `LAYOUT-SKIP` lines: if a bound ledger row produces `LAYOUT-SKIP <id>`, classify the self-count check as `LAYOUT-SKIPPED` rather than failing on missing numeric regex match. Share the exact fleet marker detection between `claim-ledger.sh` and `self-counts.py`.
- **Risks:** Masking genuine drift if a non-fleet row spuriously skips; mitigated by checking `[fleet]` tag membership in `corpus/claim-ledger.tsv`.
- **Verification:** UNRUN (design synthesis; verify in sandbox lone clone with `python3 corpus/self-counts.py --root <scratch>`).

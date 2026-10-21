# ScoutLesson — adversarial re-measurement of `corpus/lessons/round-23.md`

Round 23 falsification seat. Read-only on the lane except this report. No legacy
`verify`, no host-bound row, no install, no account/vault/handler probe, no
production edit; host-free gates, their selftests, read-only git, and the
declared-User-Agent public `curl` re-fetch only.

**Measured snapshot** (the lane was edited repeatedly during this audit; this
report pins the bytes below and records the earlier hashes where a defect was
fixed mid-audit):

| item | value |
|---|---|
| HEAD | `58bd8d70d310ecaac0316e4b576073cc75142332` |
| base in lesson | `d218603b74099ddca0bd8f869516fc41db0979bf` |
| lesson | `corpus/lessons/round-23.md`, 220 lines, sha256 `ae29c16c9f367df9088d21fa0c6cf42ca1d11e99517512fab325c7bf99866b86` |
| C1 gate | `corpus/closure-dispositions.py` sha256 `d79b08a78cfe2c4954f246d4b450d3fbcb4178a48092b675eb6ade98cc5521c4`; JSON sha256 `d6239244ccab18e4bddc26ffc8eab21de9dcfd4b55964fc1591fcca08408999d` |
| C2 gate | `corpus/sources-census.sh` sha256 `2d1bbbe36ed21c2755d604937dc10d91fa71645847c82124bf729f4c8e0b95bc` |
| provenance | `corpus/source-fetches.tsv`, 10 rows / 9 distinct URLs, sha256 `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` |
| verdict | `.ufo/waves/round-23/final-verification.json:3` → `measured_commit = e1884c6ecb7ccd717965b0d748bc193137118dbf` |
| measured at | `2026-10-21T01:17:20-03:00` (`date -Is`) |

The worktree differed from the HEAD blob during the audit (the integrator was
editing the lesson and gates live); all citations below are against the pinned
worktree hash, not the earlier HEAD blob.

## What I attacked

1. §Gate (L20-54): new-row URLs, quotes, normalization, hash-domain claims.
2. §Before → after (L56-62): C1/C2/C3 commands and counts.
3. §Routed defect dispositions D1-D9 (L64-142) and the typed JSON record.
4. §Mistakes (L144-162) and the "fourth mistake" sweep.
5. §C3 fixture contract (L163-170) and §Source accounting (L172-182).
6. §Falsification bounds (L184-220): whether each stated bound matches the code.

## Commands and exits (host-free/read-only)

Final run at the pinned snapshot (01:17:20):

| # | command | exit | observed |
|---|---|---|---|
| 1 | `git rev-parse HEAD` | 0 | `58bd8d70d310ecaac0316e4b576073cc75142332` |
| 2 | `python3 corpus/closure-dispositions.py` | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)` |
| 3 | `python3 corpus/closure-dispositions.py --selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` |
| 4 | `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`; no `W04` on stdout or stderr |
| 5 | `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| 6 | `grep -n 'W04' corpus/sources-census.sh` | 1 | no match — the lane gate has no W04 path |
| 7 | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims …/claims.tsv --stamps …/stamps.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md` | 0 | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)` |
| 8 | same under `env -i PATH=/usr/local/bin:/usr/bin:/bin` (no `HOME`) | 0 | identical CLEAN line |
| 9 | same under `strace -f -e trace=openat` | 0 | 551 trace lines; no successful `openat` outside the repo and `/usr`,`/lib*`,`/etc`,`/proc`,`/sys`,`/dev`,`/tmp` |
| 10 | fixture copy, one cell pointer removed | 1 | `UNCITED SCORECARD.md:8 depth …`; `BROKEN (… uncited=1 …)` |
| 11 | fixture copy, `R90-01` → `R90-99` | 1 | `MISSING-ID SCORECARD.md:8 R90-99` (and `:10`,`:12`); `BROKEN (… missing_ids=3 …)` |
| 12 | fixture copy, row expectation `^FX: OK$` → `^FX: NOPE$` | 1 | `FAIL R90-01 reason=verdict-not-final`; `BROKEN (… row_failures=1 …)` |
| 13 | fixture copy, `stamps.tsv` emptied | 2 | `claim-ledger: no stamp rows … (refusing to report coverage with an empty stamp set)` |
| 14 | `cd /home/vgpnk/Projects/shokunin && bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | 7 × `W04` (`S019`,`S020`,`S021`,`S022`,`S023`,`S025`,`S026`) + `kagi ok …/corpus/SOURCES.md` |
| 15 | base `SOURCES.md` (23 rows) in a temp root, same fleet census | 0 | **5** × `W04` (`S019`–`S023`) + `kagi ok` |
| 16 | `grep -c 'Fetch sha256:' corpus/SOURCES.md` / `grep -c '^\| S0' corpus/SOURCES.md` | 0 | 16 / 26 |
| 17 | `grep -c '^S0' corpus/source-fetches.tsv`; distinct `$4` | 0 | 10 rows; 9 distinct URLs |
| 18 | `test -e .ufo/waves/round-23/final-verification.json`; `grep -n measured_commit` | 0 | exists; `:3 "measured_commit": "e1884c6…dbf"` |
| 19 | `cd …/shokunin && git -C kagi-shokunin diff --stat d218603..HEAD -- corpus/lessons corpus/QUALITY.md` | 0 | `corpus/lessons/round-23.md \| 207 +++`; one file, 207 insertions, 0 deletions |
| 20 | same command from the lane root | 128 | `fatal: cannot change to 'kagi-shokunin': No such file or directory` |
| 21 | `git ls-files corpus/fixtures` | 0 | 5 tracked fixture files |
| 22 | `ls -ld /tmp/kagi-shokunin` | 0 | residue still present |

Re-fetch reproduction (declared UA `kagi-shokunin-round23/1.0 (documentation verification)`):

| row | raw bytes / sha256 | normalized sha256 | quote under `rendered-text-v1` |
|---|---|---|---|
| S024 | 586,146 / `aaf52ac2…c1008` exact | `7c5a19e2…a715` exact | present |
| S025 | 63,046 / `449ef132…85d9` exact | `ca496ad8…a403` exact | present |
| S026 | 47,384 / `52295218…f82c` exact | `ed949658…d2e3` exact | present |
| S017/S018/S019/S021/S022/S023 | raw + normalized exact | exact | present |
| S020 | two GETs `bb8a02db…`, `5d0799c8…` (raw differs) | `20b4fd86…` stable | present |

S020's two bodies are both 190,261 B and differ in exactly 44 bytes, all inside
one `/cdn-cgi/l/email-protection#<token>` fragment. This confirms the declared
volatile representation and the normalized-text rule.

## Findings

### F1 — HIGH: the seven-warning quote is now right, but the round-start count is wrong, the typed note still says five, and the end-state conjunction is unmeetable

- `corpus/lessons/round-23.md:66-78` now quotes **seven** W04 lines
  (`S019`,`S020`,`S021`,`S022`,`S023`,`S025`,`S026`). That is correct for the
  measured round end: command #14, exit 0, seven warnings + `kagi ok`. This
  fixes the earlier five-line omission; credit.
- `corpus/lessons/round-23.md:180-182` says "Census at round start: exit 0 with
  **seven** W04 warnings … census at round end must exit 0 with the same W04
  warnings and `rows=26`." The frozen base (`d218603`, 23 registry rows) emits
  **five** W04 lines (`S019`–`S023`), command #15, exit 0. The seven-warning set
  exists only after S024–S026 are added. "Round start = seven" is false by two
  warnings.
- The typed record contradicts both the lesson and the census:
  `corpus/closure-dispositions.json:49` (D1 row) still says "round report quotes
  the **five** W04 duplicate-URL warnings verbatim", while the lesson quotes
  seven and the end census emits seven. The gate passes because D1 only needs
  the id token at the anchor (the lesson's own presence-only bound, L186-191).
- The "same W04 warnings and `rows=26`" acceptance still joins two different
  tools: the lane census emits `rows=26` and **zero** W04 (command #4; the
  script has no W04 path, command #6); the fleet census emits seven W04 and no
  `rows=` metric (command #14). No single census command satisfies the stated
  conjunction.
- The lesson's parenthetical at L75-78 acknowledges S025/S026 are new
  correction rows, so the start/end distinction is internally visible.

### F2 — MEDIUM-LOW: D4's "per tuple" record is only category-level

- `corpus/lessons/round-23.md:94-98` gives commits but not the tuples: "four
  knowledge pins drifted at `f4a8dd9` … the round-18 lesson at `bad9088` …
  `LOG.md` at `584dd67`/`c2cab35`." The four pins are not named; no old/new
  values are given.
- The commit mapping is correct: `git show --stat f4a8dd9` touches
  `config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`,
  `janitor-env-contract.md`; `bad9088` touches `corpus/lessons/round-18.md`;
  `584dd67` and `c2cab35` touch `LOG.md`.
- The pointed record is not a per-tuple journal. The new
  `.ufo/waves/round-23/expectation-migrations.json` is a migration record for
  expected outputs (`R12-03`, `R13-01`, `R21-02`…), not for the four stale-pin
  tuples. No round-23 stale-pin journal naming the four files was found
  (`grep` over the round-23 LOG section, stamps, and `.ufo`).
- The gate passes because D4 only needs the token `D4` at the pointer
  (`corpus/closure-dispositions.json`, D4 row). Partial fix, not full.

### F3 — LOW: D9 names the wrong skip mechanism for R13-03

- `corpus/lessons/round-23.md:129` says "`R13-03` keeps its skip for host-bound
  rows"; the C3 before cell at L62 repeats "R13-03 skipped for host rows."
- R13-03's command is `bash corpus/claim-ledger.sh cells`
  (`corpus/claim-ledger.tsv:38`). Inside `cells`, a row that invokes the gate is
  reported as `SKIP-SELF` (`corpus/claim-ledger.sh:817`; selftest case
  `cells-self-row-skip`, `:1374`). A host-bound row is instead `DEFER`red with
  `reason=substrate-absent` (`:417`). R13-03's skip is self-invocation, not
  substrate.
- The "0 ledger rows executing `cells` host-free" before-state remains true;
  only the mechanism label is wrong.

### F4 — INFO: volatility is table-wide, not S020-only

- `corpus/lessons/round-23.md:45-54` explains the volatile representation using
  only S020. All 10 provenance rows are `decoded-http-body-volatile-v1`
  (`awk` count 10). The raw-volatility bound applies to the whole provenance
  table; the lesson's wording understates its scope.

## Resolved during this audit (not current findings)

The lane was edited repeatedly while this seat measured; the following defects
were real in earlier snapshots and are fixed in the pinned bytes:

| earlier defect | earlier evidence | current state |
|---|---|---|
| D1 quoted five W04 and omitted S025/S026 | lesson `d5520988`/`2f53cf69`, old L68-72 | now seven, L66-78; the remaining defect is the start count and the JSON D1 note |
| "seven distinct URLs" (actual 9) | lesson `d5520988`, old L165 | `round-23.md:174-177` now "nine distinct URLs"; `awk` = 9 |
| "four-file / one-row / empty stamps" (actual 5 files / 2 rows / 2 stamps) | lesson `d5520988`, old L151-153 | `round-23.md:159-162` now five-file / two-row / two-stamped; `git ls-files` = 5 |
| "no cross-capture equality" contradicted the census code and M23-1 | lesson `2f53cf69` L53-54 vs old `sources-census.sh:282,288` | code now has **no** same-URL equality block (`grep 'same-url'` only the header comment); `fetch-disagree` expects 1 finding; lesson L54/L148 and `source-fetches.tsv:21` agree |
| S024 called a correction row | lesson `2f53cf69` L167-168 | `round-23.md:174-175` now "one new frontier row, S024 … two correction rows, S025/S026" |
| "the 64-seat falsification wave confirmed" | lesson `2f53cf69` L179 | `round-23.md:186` now "reported on the three claims" |
| D6 `measured_commit: "pending"` | `final-verification.json` at the `e1884c6` snapshot | `:3` now `measured_commit = e1884c6…dbf` |
| D3 claimed rejection of `revision` and positional ids | lesson `d5520988` L86-89 | `round-23.md:86-92` now scopes it to a mode token and routes the id-shaped positional gap (`ClaimR11X09`) as debt; the typed record was downgraded `fixed`→`reported` mid-audit |
| sweep command empty because HEAD equalled the base | lesson `d5520988` L146-147 | from the fleet parent it now shows only `corpus/lessons/round-23.md` (207 insertions, 0 deletions); it still exits 128 from the lane root (cwd-relative `-C`), a usability note |
| fixture `STALE-POINTER` during the 01:03:17-01:03:24 tab/stamp race | `CELL_AUDIT: BROKEN … stale_pointers=1`, exit 1 | after the stamp refresh the exact row is CLEAN, exit 0; the stamp check worked as designed |
| peer-reported census crash (`SUPERSEDED` unbound) | earlier peer report | does not reproduce at the pinned census sha `2d1bbbe3…`; `grep 'SUPERSEDED'` no match; real-tree run CLEAN, exit 0 |

## Confirmations (attacks that failed)

- **C1** (`round-23.md:60`): gate CLEAN with 15 obligations, 6 fixed, 3
  reported, 1 operator-owned, 5 no-action, 0 rejected, 15 pointers; 14/14
  selftest. The 15 obligations are D1-D9 + SPOT-01..05 + ADJ; one typed JSON row
  per id; fixed pointers resolve by the shipped resolver
  (`corpus/closure-dispositions.py:104-126`). The fixed/reported split changed
  mid-audit (7/2 → 6/3, D3 downgraded); the lesson only quotes
  `obligations=15`, which holds.
- **C2** (`round-23.md:61`): 26 rows, 16 in-row pins, 10 provenance rows
  (S017-S026), no row uncovered by either, no row with both; 9 distinct URLs;
  59/59 selftest. The tsv's 10 `row_identity_sha256` values all match
  `sha256(id\tstatus\turl\n)`; the fetch re-check reproduces S024-S026 exactly
  (raw bytes, normalized digest, located quote) and S017-S023 except S020's
  declared raw volatility.
- **C3** (`round-23.md:62`, L159-170): five tracked fixture files; two claim
  rows; two stamps (`fx-ok.sh` inert, `stamp_pointed=1` from adjacency); the
  exact pinned CLEAN line, exit 0; `env -i` (no `HOME`) also CLEAN; `strace`
  shows no host data-file open; the three mandated mutations fail (exit
  1/1/1; empty stamps exit 2).
- **Gate quotes** (L27-29): S024/S025/S026 raw bytes, normalized digests, and
  quotes reproduce under the declared `rendered-text-v1` rule; S024's
  `delete_version_after` and S025's `<code>jwt</code>` are present on the
  re-fetched pages.
- **Legacy pins** (L110-116): S008 reproduces at 1,909 B / `63cb0a46…3440`;
  S012 `ec6e7b25…`, S013 `ae321512…`, S014 `e9472324…`, S016 `c083fdca…` match
  neither today's raw nor normalized body; S014's `e9472324…` is confirmed
  against seven tested representations (`SourceS014.md:66-69,187`).
- **D5**: 130 registry members (build 64 + falsify 66), 130 agentIds, 129
  unique registry keys; the build `CriticNoTrade` / falsify
  `KagiR22.CriticNoTrade-2` pair is present. 130 IDs under 129 names holds.
- **D6**: satisfied at the pinned verdict: `measured_commit = e1884c6…dbf`
  (the production commit), while HEAD `58bd8d7` is a later receipt/meta
  commit. The distinction is not spelled out in the lesson but the required
  commit is present.
- **D8**: `/tmp/kagi-shokunin` still exists; operator-owned.
- **D9**: R23-01 passes host-free; `final-verification.json:60` records R11-08
  as executed **fail** (`CITATION_GATE: BROKEN … unresolved=3`, inherited), so
  the lesson's inherited-red statement is corroborated.
- **Late bounds** (L201-220): the "16-row in-row branch is exercised only by
  the real-tree run" claim is accurate — the selftest registry has no in-row
  `Fetch sha256:` rows, and the real-tree run exercises all 16; the
  Python/mktemp description matches the `strace` (stat probes, no `$HOME`
  opens; one `/tmp` mktemp removed). The `~`/absolute-argument policy claim was
  not re-executed. [INFERENCE for that one sub-claim.]

## Bounds and remaining unknowns

- The lane changed under audit: lesson hashes `d5520988` → `2f53cf69` →
  `49632920` → `93df7d34` → `f0f967fb` → `ae29c16c`; HEAD `d218603` →
  `e1884c6` → `ea5b734` → `284d40e` → `def9bc2e` → `58bd8d7`. Findings F1-F4
  apply to the pinned lesson `ae29c16c` (220 lines) and HEAD `58bd8d7`. A later
  edit can change them; the hashes are the anchor.
- F2 (D4) is a documentation-completeness defect: `git show --stat f4a8dd9`
  recovers the four file names, but the pointed record does not state the
  per-tuple old/new values the routed D4 asked for.
- The normalized/raw same-URL equality arm is no longer in the gate
  (`grep 'same-url'` only the header comment); the lesson and tsv now agree.
  `fetch-disagree` still passes as a duplicate-provenance case, not a
  same-URL-disagreement case.
- `measured_commit` (`e1884c6`) and HEAD (`58bd8d7`) are different commits by
  design (production bytes vs receipt); D6 is satisfied only under that
  reading, which the lesson does not spell out.
- No legacy `verify` and no host-bound row were executed; no account, vault, or
  handler probe was made. All public re-fetches used the declared UA. No
  install or package transaction was performed.

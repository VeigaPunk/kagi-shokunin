# ClaimR15X02 — R15-02 audit (read-only, round-23 parent build)

Subject: `corpus/claim-ledger.tsv:34` — `bash corpus/checklist-run.sh --selftest`.

## Baseline (observed)

- HEAD `d218603b74099ddca0bd8f869516fc41db0979bf`, 2026-10-20 21:11:59 -0300
  (`round-22 verifier spot-check (integrator, hyaku): non-author admit/reject`),
  the base named at `plans/round-23.md:1`.
- Frozen population at base: `corpus/claim-ledger.tsv` was sha256
  `e6806968…c1dce8305`, 58 lines / 17844 bytes = `corpus/stamps.tsv:5`, with 43
  non-comment command rows (R15-02 among them). That is the 43-row population
  `plans/round-23.md` names.
- Target artifact unchanged: `corpus/checklist-run.sh` sha256
  `7e5ec98b9e1d0afaa4d4d0f0d91f897236e8a8b4c7912ccad94d86492fd576bf`,
  506 lines / 24697 bytes = `corpus/stamps.tsv:2` =
  `.ufo/waves/round-22/integration-manifest.json:67-70`; the round-22
  frozen-before stamp carries the same digest
  (`.ufo/waves/round-22/frozen/before/corpus/stamps.tsv:2`). The implementation
  is byte-identical from before round 22 through today.
- The worktree moved during this audit (mid-landing, not a clean checkout):
  `corpus/closure-dispositions.py` + `.json` 00:46, `corpus/SOURCES.md` 00:49,
  `corpus/fixtures/cells-hermetic/` 00:51-00:53, and `corpus/claim-ledger.tsv`
  00:53 — now 60 lines / 19451 bytes / sha256 `6fa0c24f…20ee0b`, with R23-01 at
  `:59` and R23-02 at `:60`. `corpus/claim-ledger.sh` was also rewritten in place
  at 00:53 (sha256 `c20c2d04…3a3b93`, 88480 bytes; stamped value
  `cf56f9ea…`, 88425). `corpus/stamps.tsv` is still the 20:19 file
  (`e680…`, 58 rows), so both ledger artifacts are unstamped at this instant and
  `verify` would print `STALE corpus/claim-ledger.tsv` and
  `STALE corpus/claim-ledger.sh` until the stamp lands (QM5/QM14).
  **R15-02 at `:34` is byte-identical to base**, as is `checklist-run.sh`; every
  R15-02 finding below is independent of the in-flight rows.

## Row text and implementation locus

Row 34: command `bash corpus/checklist-run.sh --selftest`; expect
`^CHECKLIST_SELFTEST: PASS \(34 cases\)$`; exit `0`; timeout `300`; note claims
scratch-fixture proof of the clean/ratio/list/only paths, ITEM-FAIL,
ITEM-LASTLINE, POLICY, DUPLICATE-REASON, RATIO, EXTRA, UNDECLARED,
DUPLICATE-ITEM, DUPLICATE-LEAD, three-way exit, SETUP and `--ratio`.

- Implementation: `corpus/checklist-run.sh:339` `selftest()`; fixtures
  `:347-411`; case block `:426-491`; counter `:414`.
- Terminal prints: `:494` (`CHECKLIST_SELFTEST: FAIL (%d/%d cases)`) and `:497`
  (`CHECKLIST_SELFTEST: PASS (%d cases)`), `:498` `return 0`. The printed count
  is the number of `run` invocations (`:412-422`), not an independent inventory.
- Count check: `grep -cE '^[[:space:]]*(CT=1 )?run "'` = 34 (33 plain plus
  `CT=1 run "row timeout"` at `:439`). Agrees with `corpus/README.md:33`
  ("--selftest (34 cases)") and `corpus/knowledge/checklist-execution.md:63`.

## Verdict on the four fields — SUPPORTED (high confidence)

- **Last line**: the PASS print is the final statement of the function; every
  child invocation is captured inside `run()` (`:412-422`), so combined
  stdout+stderr ends there. Exercised receipt records the identical string.
- **Exit 0**: `return 0` at `:498`; any `fails>0` takes `:494` and returns 1,
  which the ledger maps to `FAIL … reason=verdict-not-final`
  (`corpus/claim-ledger.sh:441-444`).
- **Timeout 300**: receipt `.ufo/waves/round-22/final-verification.json:186-201`
  — `exit: 0`, `last: "CHECKLIST_SELFTEST: PASS (34 cases)"`,
  `passed: true`, `seconds: 1.862`. Worst case is bounded by 34 child `bash`
  starts plus one `timeout 1` over `sleep 5` (`:438-439`); ~160x margin.
- Not re-executed in this read-only audit. Support rests on (a) a persisted
  receipt bound to the identical subject digest and (b) static derivation of the
  print path. The receipt's container commit attribution is disputed (D6:
  `final-verification.json` `.h1` = 8ada17a5 vs measured 4be5da3), but the
  subject digest is invariant across those revisions, so the verdict transfers.

## Note-vs-source mismatches (low severity, documentation only)

1. The note ends "…it moved 28 -> 29 (tri-exit) -> 33 (--ratio) during landing".
   The pinned and actual count is 34; the 34th case is `run "final clean"`
   (`:491`) and the `--ratio` group is four cases (`:477,479,481,484`), not
   three. The expect (34) is right; only the note's terminal value is stale.
2. The note lists `duplicate reason` inside `POLICY (...)`. DUPLICATE-REASON is
   a defect at exit 1 (header `:32-35`; `:236`; case `:453` expects 1), never a
   POLICY (exit 2, `:36`). `padded reason` (`:475`) is a real POLICY case the
   note does not name. `duplicate reason` is also listed twice (once inside the
   POLICY parenthetical, once as DUPLICATE-REASON).
3. Neither mismatch changes the verdict. If round 23 touches the note, append a
   correction (QM14 old/new record); do not rewrite the landing history.

## `[substrate]` deferral — correctly absent, and load-bearing

- `corpus/claim-ledger.sh:416-418` defers a row whose note contains the literal
  bracket tag, before policy check and execution. Brackets-only tagging is the
  contract (`corpus/knowledge/substrate-deferral.md:65`); prose mentions do not
  tag. R15-02 has no tag, so no host state can defer it.
- The selftest imports no host state: it writes only under `mktemp -d`
  (`:340-344`), rebuilds `SKILL.md`/`checklist.tsv` per fixture (`:347-411`),
  and passes `--tsv`/`--skill` to every child (`:416`). Fixture row commands are
  inline `printf`/`true`/`exit`/`sleep`; the three live-surface strings
  (`cat op.env`, `bash corpus/claim-ledger.sh verify`, `the-janitor run -- printenv`)
  are refused by `DENY_CHECK` (`:75`) before execution. No live substrate command
  runs on the current code path.
- Load-bearing today: the handler is absent (`test -x $HOME/.local/bin/the-janitor`
  false; same record at `.ufo/waves/round-22/build/Entry04.md:121-123`), so
  R15-01 (`[substrate]`) defers and R15-02 is the only executed proof of the
  checklist runner on this host. R15-03/04/05 prove declaration shape only:
  `--list` never extracts items (`:302-318`) and `--ratio` returns before the
  row loop (`:248-255`); `--ratio` does still exercise item extraction and the
  lead bijection over the real 16 items.

## SKIP-SELF — does not apply; obligation preserved

- `corpus/claim-ledger.sh:816-819` skips a cell-cited row only when field 2
  contains `claim-ledger.sh`. R15-02 names `checklist-run.sh`, so
  `cells_evidence` (`:802-842`) re-runs it with the row's own 300 s (`:426-427`).
- `SCORECARD.md:215` (Round 15 post-move, operability 8→9) cites `R15-02`;
  `line_ids` (`:631-632`) + `is_row` (`:619-623`) resolve it. That cell keeps a
  live command tooth only while this row executes.

## C3 retention (hermetic cells, `plans/round-23.md:32-38`)

The C3 landing is present in the worktree at 00:51-00:53: R23-01
(`corpus/claim-ledger.tsv:59`) runs `cells --root corpus/fixtures/cells-hermetic`
and pins `^CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0
missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0
self_skipped=0 orphans=0)$`. Its fixture is synthetic and local: `claims.tsv`
holds R90-01 (`bash corpus/fx-ok.sh`) and R90-02 (a `grep -cE` over the fixture's
own `adjacency.tsv`); neither is `[substrate]`-tagged, and no row names a real
gate, `$HOME`, the handler, the vault or the network. As landed (static reading;
not executed here), the "never run live substrate commands" bound holds.

Retention requirements (keep these; the current draft satisfies 1-2):

1. Do not widen the SKIP-SELF predicate (`claim-ledger.sh:816`, still
   `*claim-ledger.sh*` after the 00:53 edit) to `--selftest` or to sibling
   gates. It is the cheapest way to make a host-free fixture green and would
   silently remove R15-02 from `rows_run` while `CELL_AUDIT: CLEAN` still prints.
2. Keep R23-01's `rows_run=2 … self_skipped=0` counters. `CELL_AUDIT: CLEAN`
   alone does not require `rows_run>0` (`:1001-1012`), and the shipped
   `cells-self-row-skip` case (`:1374`) accepts the zero-execution shape. Without
   the counters, a fixture could be green while running nothing.
3. R23-01 proves the *machinery*; it must not substitute for the real cells run.
   The real run executes R15-02 through `SCORECARD.md:215`; a fixture-only green
   does not cover that row. Keep both (fixture pass + real row execution).
4. The fixture root must not cite real rows: `verify_claims` runs with
   `cd "$ROOT"` (`:426`), so a copied R15-02 row exits 127 at a fixture root.
   Policy still allows a `..`-escaping row (no `/` in `META_RE`, no `..` rule),
   so "hermetic" must mean "no row escapes the fixture root" — assert it.
5. Never copy the 43-row (now 45-row) ledger into the fixture: H1/H3/H4/H8 name
   handler paths and would fail, or on a substrate-present host execute live
   probes, breaking the "never run live substrate commands" bound.

## C1 retention (closure dispositions, `plans/round-23.md:4-14`)

- `corpus/closure-dispositions.py` (in worktree, 00:46) parses only `- D<N>`,
  discernment-table rows and `**ADMITTED.**` (`:76-102`). R15-02 is not an
  obligation and must not be enrolled as one (that would create a false
  missing/unknown disposition). R23-02 (`claim-ledger.tsv:60`) pins
  `obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0
  pointers=15`.
- Observed D9 disposition (`corpus/closure-dispositions.json:105-110`):
  `fixed`, pointer `corpus/claim-ledger.tsv`. `resolve_pointer` (`:104-121`)
  requires only that the pointed file contain the id token, and the only `D9`
  token in the ledger is R23-01's note (`claim-ledger.tsv:59`), so the pointer is
  effectively content-addressed to the fix row: deleting R23-01 leaves D9
  unresolved. Keep that. Residual: the check is file-level, so any future ledger
  row mentioning `D9` would satisfy the pointer without R23-01; a deletion test
  (or an "artifact absent at base `d218603b`" rule) is the guard.
- A `fixed` disposition must not be satisfiable by this row. No checklist
  artifact carries a `D<N>` token, and D9's pointer names the ledger, not
  R15-02 or `checklist-run.sh`; keep both facts. An unchanged artifact must not
  be accepted as a `fixed` pointer.
- R15-02 is active current evidence, not historical/rejected/superseded; any C1
  or C2 sweep that classifies claim rows must not route it as history.

## One consumer-visible risk + minimal synthetic falsifier

Risk (false-clean, real-run arm): on this host R15-02 is the only
always-executed, non-self-skipped deep row behind `SCORECARD.md:215` (R15-01
defers). The landed R23-01 pins the fixture arm (`rows_run=2 self_skipped=0`),
but it cannot pin the real arm: a later edit that widens SKIP-SELF — or that
tags R15-02 `[substrate]` — still yields `CELL_AUDIT: CLEAN … rows_run=0
self_skipped=1 …` (or `row_deferred=1`) exit 0 on the real scorecard: a green
operability cell with zero executed commands. The in-tree precedent is
`claim-ledger.sh:1374`, which accepts exactly that zero-execution shape.

Minimal synthetic falsifier for L1 (proposal, not executed here):

- `corpus/fixtures/r15-02/sc.md`: one `## Round 99 — post-move` section carrying
  the six axis rows, each citing `` `R15-02` `` (a cell with neither a row id nor
  a stamped path is UNCITED and fails; all six may cite the same row, and
  `cells_evidence` dedupes the id).
- `bash corpus/claim-ledger.sh cells --root <repo> \
   --claims <repo>/corpus/claim-ledger.tsv --stamps <repo>/corpus/stamps.tsv \
   --scorecard corpus/fixtures/r15-02/sc.md --docs corpus/fixtures/r15-02/sc.md`
  (`--scorecard`/`--docs` are cwd-relative, not root-relative; run from `<repo>`.)
- Required last line: `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 … rows_run=1
  row_deferred=0 row_failures=0 …)`.
- Mutants that must FAIL: (a) broaden the SKIP-SELF predicate (or otherwise
  skip the row) → `rows_run=0 self_skipped=1`; (b) append `[substrate]` to the
  row's note → on this handler-absent host `DEFER`, `rows_run=0 row_deferred=1`;
  both are `CELL_AUDIT: CLEAN` today. The `rows_run=1 row_deferred=0
  self_skipped=0` assertion kills both. A coarser mutant (drop the row from the
  claims file) fails earlier as `MISSING-ID`, not at this assertion.

## Historical vs current evidence

- Historical: round-22 executed receipt (`final-verification.json:186-201`,
  2026-10-20, 1.862 s); round-22 skip list naming R15-01 but not R15-02
  (`corpus/lessons/round-22-verifier-spotcheck.md:74`); round-22 safe-row plan
  entry (`safe-row-plan.json:82-89`, status `plan`, not a pass); round-15
  landing note `28 -> 29 -> 33`.
- Current: HEAD `d218603b`; the row's own artifacts still match their stamps
  (R15-02 at `claim-ledger.tsv:34` is byte-identical to base; `checklist-run.sh`
  `7e5ec98b…`/506/24697); the ledger file and `claim-ledger.sh` are mid-landing
  and unstamped (see Baseline); selftest source static count 34; `README.md:33`
  and `knowledge/checklist-execution.md:63` say 34.
- Not claimed: a fresh execution today. The bytes are unchanged since the
  receipt, which is the strongest available non-executing support.

## Unresolved / limits

- The runtime verdict is not re-measured here (read-only, no gate execution).
- The note's landing history (28→29→33) is unverified against intermediate
  commits: git history was not walked, and the row is byte-identical to the
  round-22 frozen copy, so any count drift predates round 22.
- `extract_items`' continuation-line branch (`:107-113`) has no selftest case;
  if the real `SKILL.md` items are single-line it is currently unexercised. It
  is covered indirectly by R15-05's real-declaration run, not by R15-02.
- The `delegated`/`direct` split (`:251-255`) is never non-zero in the 34
  fixtures (all expected lines say `delegated=0`); its non-zero case is pinned
  only by R15-05's real `delegated=3 direct=6`. A mutation `direct=k` survives
  R15-02 but fails R15-05.
- Tool installs: none. No packages, services, provider or host changes.

No contradiction serious enough to route to `agent://KagiR23` beyond this
report; both note mismatches are documentation-level and the verdict fields are
sound.

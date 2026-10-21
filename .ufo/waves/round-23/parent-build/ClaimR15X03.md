# ClaimR15X03 — R15-03 semantic audit (read-only)

Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300,
"round-22 verifier spot-check (integrator, hyaku): non-author admit/reject"). Working tree carried
only untracked `.ufo/waves/round-23/` and `plans/round-23.md`. No gate was executed, no production
file changed; this report is the only write. No tools installed.

## Row under audit

`corpus/claim-ledger.tsv:35`

```
R15-03  bash corpus/checklist-run.sh --list  ^CHECKLIST_LIST: rows=16 runnable=9 by_hand=7$  0  60
```

Note field as shipped: "the declaration table maps ids -> class -> lead -> expected verdict for all
16 items without executing anything; the counts here are what a reader checks against the ratio
line before trusting a score cell".

## Verdict justification — supported

- **Command → implementation.** `checklist-run.sh:501-506` dispatches `list) list_rows`.
  `list_rows` (`:300-318`) calls `load_rows`, prints one `ROW` line per declaration row, then at
  `:317` prints exactly `CHECKLIST_LIST: rows=%s runnable=%s by_hand=%s`. That printf is the last
  statement, so the list line is structurally last.
- **Data.** `checklist.tsv` holds 16 non-comment rows (lines 26-41), each with 8 non-empty
  tab-separated fields. Class counts are 9 `runnable` (E1,E4,E5,E8,H1,H3,H4,H7,H8) and 7
  `by-hand` (E2,E3,E6,E7,H2,H5,H6). So `rows=16 runnable=9 by_hand=7` is the exact output shape for
  the shipped data, not a copied number.
- **Exit 0.** `list_rows` returns 0 after the printf. Non-zero is reachable only through
  `load_rows`' policy path (`checklist-run.sh:120-181`, `BAD=1` then `return 2`) or an unreadable
  TSV (`SETUP`, `:124-127`); both return before any `ROW`/`CHECKLIST_LIST` line. The ERE and exit 0
  are therefore jointly reachable only in the clean state.
- **Timeout 60 s.** `--list` starts no subprocess and reads one repo TSV; the committed execution
  receipt measured 0.01 s (below). 60 s is loose but not wrong.
- **Ledger-side semantics.** `claim-ledger.sh:436-443` matches the ERE against the last non-blank
  line after exit equality; the ERE is `^...$` anchored, and the printed line has no trailing
  whitespace. No silence path.
- **Scope of the claim.** The row proves the *declaration table's* row count and class split. The
  note's clause "for all 16 items" is carried by `--ratio` (R15-05: `verify` extracts SKILL items
  and enforces `UNDECLARED`/`EXTRA`/lead bijection, `checklist-run.sh:184-219`) and by R15-01, not
  by this command — `list_rows` never reads `SKILL.md` (`$SKILL` is referenced only in `verify`,
  `:184-188`). This is a provenance nuance, not a false expectation: the note and the count are
  consistent at this revision (SKILL.md:423 section still holds 16 `- [ ]` bullets, lines 434-456).

## Evidence: historical vs current

- **Historical landing.** Commit `587fda0` (2026-09-28 22:56:34 -0300) shipped the row and recorded
  `bash corpus/checklist-run.sh --list ⇒ CHECKLIST_LIST: rows=16 runnable=9 by_hand=7` (LOG.md:544).
  `corpus/knowledge/checklist-execution.md:62` documents `--list` as "prints the map and runs
  nothing"; that entry's stamp is fresh (`stamps.tsv:14`, sha `485e219a…`, 206 lines / 14264 bytes
  = current bytes).
- **Current implementation/data unchanged.** `git log` shows `corpus/checklist-run.sh` and
  `corpus/checklist.tsv` changed only in `587fda0`; blob IDs at HEAD equal that commit
  (`78f2c45e…` and `440f1377…`). Row 35 is unchanged across `8ada17a5..HEAD` and identical to the
  frozen snapshot `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:35`.
- **Current executed receipt.** `.ufo/waves/round-22/final-verification.json`
  `safe_rows[id=R15-03]`: `exit=0`, `last=CHECKLIST_LIST: rows=16 runnable=9 by_hand=7`,
  `passed=true`, `seconds=0.01`; `.ufo/waves/round-22/safe-row-plan.json` lists the same command,
  ERE and timeout. The receipt binds integration landing `8ada17a5`; after it only
  `claim-ledger.sh`, `SCORECARD.md` and `claim-ledger.tsv` changed, none of which is this row's
  command or data. Round-22's authorized split was 31 executed / 12 skipped (11 `[substrate]` rows
  plus R13-03) — R15-03 is in the 31 (`corpus/lessons/round-22-verifier-spotcheck.md:74-77`).
- **Cells citation.** `SCORECARD.md:215` (Round 15 post-move) cites R15-03, so the real `cells`
  audit re-runs it (`claim-ledger.sh:806-828`).

## `[substrate]`, SKIP-SELF, hermetic mode

- **No `[substrate]` tag: correct and required.** `--list` reads only `checklist.tsv`; no `$HOME`
  access, no handler, no sibling gate. On `KAGI_SUBSTRATE=absent` it must run, not defer; adding the
  tag would turn a host-free obligation into an unmeasured absence (the deferral boundary in
  `corpus/knowledge/substrate-deferral.md` §Bounds 1-2).
- **SKIP-SELF: not matched, correctly.** The test is `TF[1] == *claim-ledger.sh*`
  (`claim-ledger.sh:816-818`); this command names `checklist-run.sh`, and `checklist-run.sh` does not
  invoke the ledger. The reverse direction is blocked by the checklist's own deny list
  (`DENY_CHECK=...|claim-ledger\.sh`, `checklist-run.sh:75`), so no checklist row can re-enter the
  ledger. Bounded residue: `cells` mode has no nesting refusal (only `verify`, `claim-ledger.sh:
  236-237`), so a *transitive* re-entry through a script a row calls would not be caught by the
  lexical SKIP-SELF test. Not reachable from R15-03 today; a C3 fixture must not create it.
- **Hermetic synthetic mode: absent at this revision.** No `corpus/fixtures/`; C3 is planned
  (`plans/round-23.md:32-37`, D9 at `corpus/lessons/round-22-verifier-spotcheck.md:183`). The
  obligation survives only under the conditions below.

## What C3 (`cells`) must retain

1. **Keep R15-03 live and untagged.** Population arithmetic: 43 command rows = 11 with
   `[substrate]` + 5 whose command text names `claim-ledger.sh` (R11-08, R11-09, R14-01, R13-03,
   R18-03) + the rest. The round-22 split was 31 executed / 12 skipped. R15-03 is one of the 31 and
   must not be moved into a fixture-only or deferred set.
2. **`--root` is cwd isolation, not data isolation.** `CLAIMS`/`STAMPS` default to `SCRIPT_DIR`
   (`claim-ledger.sh:104-105`, `:199-202`) while row commands execute with `cd "$ROOT"` (`:426`). A
   fixture invocation must pass `--claims`, `--stamps`, `--scorecard` and `--docs` (the selftest
   does exactly this, `:1361`). A fixture scorecard that cites R15-03 then needs byte-identical
   `corpus/checklist-run.sh` + `corpus/checklist.tsv` in the fixture, or the row is tested against a
   different declaration (false clean) or fails 127 at the fixture root (false fail).
3. **Do not let `CELL_AUDIT: CLEAN` imply full coverage.** `cells` executes only rows cited by
   checked cells (`claim-ledger.sh:806-820`); two real rows (R21-04, R22-04) are cited nowhere in
   SCORECARD and are never run by `cells`. `rows_run` counts selected rows *including deferred ones*
   (`C_N` increments at `:415` before the `DEFER` at `:416-418`), so exercised = `rows_run` −
   `row_deferred`. A C3 proof must state the 43-row disposition explicitly, not rely on the cells
   summary.
4. **Do not make R23-01 the sole cell evidence.** R23-01's command will name `claim-ledger.sh`, so a
   real `cells` run over a scorecard citing it will SKIP-SELF it (counted in `self_skipped`, never a
   failure). That is intended for `verify`, but it means R23-01 cannot be re-validated from inside
   `cells`.

## What C1 (closure dispositions) must retain

- R15-03 is **not** one of the nine routed defects, the five discernment decisions, or the
  adjudication ruling (`corpus/lessons/round-22-verifier-spotcheck.md:163-183`: only D9 mentions
  R13-03). The checker must not invent a disposition for it and must not cite its green as D9's
  closure evidence.
- D9's `fixed` pointer must resolve to the committed fixture path and to R23-01's actual command in
  the ledger tree. "15 obligations" / "43 rows audited" is exactly the claim-count assurance the C1
  requirement forbids; the pointer must be followed to a committed object.
- Preserve the existing pointer chain: `corpus/knowledge/checklist-execution.md:11` declares
  `Reverify: R15-01, R15-02, R15-03, R15-04, R15-05`; `docs` resolves every id against the ledger
  (`MISSING-ID` otherwise) and the entry is stamped fresh (`stamps.tsv:14`). A row rename or delete
  must remain visible through that chain.

## Consumer-visible risk (one risk, two branches) with minimal falsifier

**Risk.** The planned C3 fixture can print a green `CELL_AUDIT` that says nothing about R15-03, or a
red one that blames R15-03 for a fixture-root artifact, because `--root` moves the row's cwd but not
its claims/stamps data.

- *False clean*: fixture scorecard cites only fixture-local rows → `CELL_AUDIT: CLEAN
  (… rows_run=k …)` with R15-03 nowhere in the run; a round-23 cell citing R23-01 reads it as
  operability coverage.
- *False fail*: fixture scorecard cites R15-03 but the fixture root lacks `corpus/checklist-run.sh`
  (or has a copy whose `checklist.tsv` is not 16/9/7) → exit 127 / `ITEM-LASTLINE` →
  `CELL_AUDIT: BROKEN (row_failures=1)`, although the shipped row is green.

**Minimal synthetic falsifier proposal for L1** (not executed here; all outputs below are
[INFERENCE] derived from the cited code paths):

```bash
F=$(mktemp -d); mkdir -p "$F/corpus/fixtures/cells-hermetic"
printf 'RF-01\tbash corpus/fixtures/cells-hermetic/fx.sh\t^FIXTURE_ROW: OK$\t0\t30\tfixture row\n' \
  >"$F/corpus/claim-ledger.tsv"
: >"$F/corpus/stamps.tsv"
printf '#!/usr/bin/env bash\nprintf "FIXTURE_ROW: OK\\n"\n' >"$F/corpus/fixtures/cells-hermetic/fx.sh"
# $F/SCORECARD.md: one "## Round 23 — post-move" table, six axes, each cell citing `RF-01`
bash corpus/claim-ledger.sh cells --root "$F" --claims "$F/corpus/claim-ledger.tsv" \
  --stamps "$F/corpus/stamps.tsv" --scorecard "$F/SCORECARD.md" --docs "$F/SCORECARD.md"
```

Expected per code: `CELL_AUDIT: CLEAN (cells=6 … rows_run=1 row_deferred=0 row_failures=0 …)`.
Mutation 1 (must fail): change the cell pointer to `R15-03` while keeping the fixture ledger →
`UNCITED` → `CELL_AUDIT: BROKEN` exit 1 (proves the fixture's green is rooted in its own ledger,
not the real one). Mutation 2 (must fail): keep the `R15-03` pointer and drop `--claims`/`--stamps`
→ the real 43-row ledger is read and `bash corpus/checklist-run.sh --list` runs at `$F` → 127 →
`CELL_AUDIT: BROKEN (row_failures=1)` (the false-fail above). A C3 implementation is acceptable
only if it states which assertion it makes and keeps R15-03's real-root obligation in the 31-row
pass.

## Limits

- No gate was executed; the falsifier results are static derivations, not observations.
- Timeout headroom was not stress-tested; only the committed 0.01 s receipt exists.
- This audit covers R15-03 only; sibling rows, SOURCES rows, and C2 provenance are out of scope.
- The `--ratio` item-side check was read, not run; the 16-item statement is corroborated by
  R15-05's committed receipt (`8ada17a5`, exit 0, ratio line) plus the unchanged SKILL section.

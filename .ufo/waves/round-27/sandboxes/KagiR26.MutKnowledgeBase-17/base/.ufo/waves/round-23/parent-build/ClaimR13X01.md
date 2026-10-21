# ClaimR13X01 — R13-01: round-heading cardinality is a moving literal, not a scored-section invariant

**Observed revision:** `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20T21:11:59-03:00).
The working tree also held untracked r23 artifacts (`plans/round-23.md`, `.ufo/waves/round-23/`,
`corpus/closure-dispositions.{py,json}`, `corpus/__pycache__/`); they are not part of the frozen
population (43 command rows + 23 source rows). No production file was modified.

## Row under audit — `corpus/claim-ledger.tsv:29`

Six fields: `R13-01` | `grep -c '^## Round ' SCORECARD.md` | `^25$` | exit `0` | timeout `30` |
note. The note reads: *current round-heading cardinality: 23 at round-21 close, plus round-22
pre/post. Includes the preserved blocked round-20 attempt, which cells excludes from scored
sections only; malformed actual scored headings still fail closed.*

## Supported observations

1. **Last line `^25$`** holds at HEAD. Enumerated matches (25): Round 9–18 pre+post = 20
   (`SCORECARD.md:12,23,34,45,56,67,78,89,100,111,178,189,200,211,222,233,286,297,307,318`),
   the blocked round-20 heading = 1 (`:558`), Round 21 pre/post = 2 (`:615,:633`), Round 22
   pre/post = 2 (`:694,:725`). The correction headings `## Round-19 correction` (`:458`) and
   `## Round-21 correction` (`:663`) are hyphenated and do **not** match `^## Round `, so 25 is
   exact and not inflated by prose headings.
2. **But 25 is not the set `cells` walks.** `SEC_RE` (`corpus/claim-ledger.sh:690`) recognizes 24
   scored sections; the blocked heading is excluded by `BLOCKED_ATTEMPT_RE` (`:694`, `:737-738`).
   The row counts 24 scored + 1 unscored, while the note's phrase "scored sections only" describes
   the parser, not the count.
3. **Exit 0** is correct for a positive count; `grep -c` emits exactly one line, so the
   last-non-empty-line rule is the count itself. Note GNU grep exits 1 on zero selected lines, and
   `verify_claims` tests exit (`:428-435`) before the verdict (`:436-443`): a scorecard that lost
   every heading reports `FAIL … reason=exit-mismatch`, never `verdict-not-final`. That is a
   diagnosis mislabel, not a false pass.
4. **Timeout 30 s** is justified with a wide margin: single grep over a 96,871-byte file; the
   persisted r22 receipt measured 0.001 s. A missing file surfaces as exit 2, a stuck read as 124;
   both fail closed.
5. **Persistence is sound today.** `corpus/stamps.tsv:68` pins `SCORECARD.md` at
   sha256 `96cf354abf91e4a1…`, 822 lines, 96,871 bytes, and all three columns match the file.
   `.ufo/waves/round-22/final-verification.json` `safe_rows[8]` records R13-01 `exit=0`,
   `stdout="25\n"`, `last="25"`, `passed=true`, 0.001 s — but its `.h1=8ada17a` while r22 D6 records
   the measured bytes as `4be5da3`; that label defect is inherited, the count is unaffected.
   QM14 provenance exists: `.ufo/waves/round-22/round21-migrations.json` (20→23) and
   `.ufo/waves/round-22/pin-migrations-integration.json` (23→25, current note).

## Refuted (causality, not line count)

1. **The note over-credits the row.** "Malformed actual scored headings still fail closed" is a
   property of `cells` (R13-03), not of R13-01. `^## Round ` matches any such line; e.g.
   `## Round 11 — premove` leaves the count at 25 and this row passes. Fail-closed lives in
   `ROUND_RE`/`SEC_RE`/`BLOCKED_ATTEMPT_RE` and `die "unrecognised round heading"` (`:690-694`,
   `:735-740`).
2. **The outside count and the walked set have drifted apart.** `SCORECARD.md:115` (Round-13
   post-move calibration) still says "the 10 round sections that the audit walks are counted from
   outside by `R13-01`", but the row now counts an unscored heading too. A count asserted from
   outside is no longer a count of what the audit walks.
3. **No identity, pairing, or uniqueness tooth.** `section_check` (`:705-711`) resets `SEC_SEEN`
   per heading and checks only the six axis names; the cell loop (`:733-754`) keeps no round-number
   set and never compares pre-count to post-count. A count-preserving renumber or duplication is
   invisible to both gates.

## `[substrate]`, SKIP-SELF, hermetic mode

- **`[substrate]`:** the note is untagged and correctly so — the command depends only on a repo
  file. Deferral requires the literal tag (`:416-418`), so with `KAGI_SUBSTRATE=absent` or no
  handler the row still runs. It must stay untagged in C3 fixtures; tagging it would fake a
  dependency and silently shrink the population.
- **SKIP-SELF:** the skip test is `TF[1] == *claim-ledger.sh*` (`:816-820`); this row is a pure
  grep, so it is not skipped. It is cited by the Round-13 cell (`SCORECARD.md:115`), so
  `line_ids` puts it in `CEL_IDS` and `cells_evidence` re-runs it (`:802-831`). Consequence: a
  stale R13-01 fails **both** `CLAIM_LEDGER` and `CELL_AUDIT` (`row_failures>=1` → BROKEN,
  `:1006-1013`). The cell citation is the only link: if that line is edited away, the row leaves
  `rows_run` and the CLEAN regex still matches (`rows_run=[0-9]+`, `self_skipped=[0-9]+`, `:1011`).
- **Hermetic:** `cells --root F` sets `ROOT=F` and defaults `SCORECARD` to `$ROOT/SCORECARD.md`
  (`:240`), so R13-01 reads the fixture scorecard — structurally sound. But `cells` re-runs only
  cell-cited rows (14 of 43 in the last recorded run), so a green hermetic `cells` does not execute
  R13-01 at all unless the fixture ledger keeps the row and a fixture cell cites it, or the proof
  runs `verify` over all 43 rows. `CELL_AUDIT` has no `rows_total` field (`:1011`), so "all
  command-row obligations retained" is not expressible in its verdict today.

## What C3 must retain

1. The fixture's R13-01 must be byte-identical to the production row, and the fixture scorecard
   must satisfy its expectation — or the exclusion must be explicit, named, and counted. A fixture
   that rewrites `^25$` is not a preserved obligation.
2. **Structural conflict:** a committed frozen fixture and a per-round literal are mutually
   exclusive. The count grows by 2 every round (round 23 → 27), so a fixture frozen with a verbatim
   scorecard + verbatim row goes stale at the next re-pin, while a fixture-local edited expect
   silently changes the obligation. Only a round-count-invariant row survives both.
3. If C3 runs `verify` at the fixture root, use `KAGI_SUBSTRATE=absent`: tagged rows defer and are
   counted, R13-01 (untagged) still runs. Never tag R13-01.
4. R23-01's expected CLEAN line should declare the population (e.g. `rows_total=43`) or the proof
   should separately assert the 43-row set; otherwise a synthetic 6-cell fixture can print the exact
   CLEAN regex with R13-01 absent.

## What C1 must retain

- D9 (`corpus/lessons/round-22-verifier-spotcheck.md:183-184`) is the obligation that creates the
  hermetic cells path. The in-flight `corpus/closure-dispositions.json` (untracked at HEAD) marks
  D9 `fixed` with pointer `corpus/lessons/round-23.md#Routed defect dispositions`; at observation
  that lesson, `corpus/fixtures/`, and ledger row `R23-01` all do not exist. A resolver satisfied
  by file+anchor+obligation-token would close D9 with no executable artifact.
- For this row: if any disposition cites R13-01's count as closure evidence, the checker must
  resolve the row and compare its current expectation to the observation at the integration
  revision. "43 rows present" or "R13-01 is cited" is claim-count assurance, not closure.

## Consumer-visible false clean + minimal synthetic falsifier (proposal, not executed)

**One-line mutation:** `SCORECARD.md:56` `## Round 11 — pre-move` → `## Round 10 — pre-move`.

- R13-01: count still 25 → PASS.
- `cells`: both headings match `SEC_RE` (`:690`), each carries six axes, no uniqueness/pairing test
  (`:733-754`) → `CELL_AUDIT: CLEAN` with the same `cells=60`.
- Round 11's pre-move record is gone; Round 10 pre-move is double-counted. The stamps pin is
  bytes-only and is legitimately re-pinned each round, so it does not catch it.

**Fixture F for L1:** copy the frozen before-tree; apply that one-line edit; re-stamp
`F/SCORECARD.md` exactly as a round re-pin does; run
`bash corpus/claim-ledger.sh cells --root F --claims F/corpus/claim-ledger.tsv --stamps F/corpus/stamps.tsv --scorecard F/SCORECARD.md --docs F/SCORECARD.md`.
Current code is expected **[INFERENCE]** to print CLEAN and pass R13-01 inside it; the fixed
checker must exit 1 naming duplicate round 10 / missing round 11.

## Freshness / false-fail this round

Appending round-23 pre+post makes the count 27. R13-01 then fails `CLAIM_LEDGER` and — through the
`SCORECARD.md:115` citation — `CELL_AUDIT` (`row_failures=1`, exit 1). `plans/round-23.md:32-39`
(C3) does not name R13-01, so integration will hit this unless the row is re-pinned in the same
commit with a QM14 old/new record. Drift history: expected 20 while the file held 21/22
(`corpus/lessons/round-21.md:83`; `considerthese/2026-10-19.md:65`), then 20→23 and 23→25 in r22
(`corpus/lessons/round-22.md:66`; the two migration files above). That is the fourth consecutive
round with a hand-bump.

## Recommendation

1. **r23 integration (mandatory):** re-pin 25→27 with an old/new migration record in the same
   commit as the scorecard append; correct the note so the malformed-heading fail-closed tooth is
   attributed to `cells` (R13-03), and state the split as 24 scored + 1 blocked. This keeps the
   literal honest but does not fix causality.
2. **Structural (recommended, may follow r23):** replace the literal with a shape row
   `bash corpus/scorecard-shape.sh` printing
   `SCORECARD_SHAPE: CLEAN (rounds=N pre=N post=N blocked=1 duplicates=0)`; assert every
   `## Round ` line is either `SEC_RE` or the exact blocked heading, pre-count == post-count, and
   round numbers are unique. The expectation uses `[0-9]+`, not a round literal, so it stops moving
   and a renumber/duplication fails. `bash` is allowed (`:160`) and the command is policy-clean
   (`:163`, `:167`).
3. **C3:** run `verify` at the fixture root with `KAGI_SUBSTRATE=absent` (or assert R13-01
   explicitly in the hermetic run); never tag R13-01; make the CLEAN line declare the population.
4. **C1:** D9's pointer must resolve to the executable fixture + R23-01, not to prose that names
   D9; row-level closure must re-run the row.

## Limits

- No gate, handler, substrate, vault, or host command was executed: no `claim-ledger.sh`
  `verify|cells|selftest`, no fixture run, no row re-run. Evidence is committed files, git blobs,
  and persisted receipts.
- Disclosure: one plain read-only `grep -c '^## Round ' SCORECARD.md` was made during orientation
  (pure read of a committed file; nothing written, no gate); heading classification was then
  re-derived by enumerated `grep -n` reads.
- The false-clean is a code-path inference, not an observed execution; L1 must run the proposed
  fixture. D6's `.h1` mislabel is inherited, not re-measured. Untracked working-tree files are
  in-flight L1 state, not HEAD.
- No tool installs or updates were needed.

# CritNoHarm — round 27 build: does C1/C2 harm any axis?

Seat: KagiR26.CritNoHarm-17 (critic, read-only, lane-authored advice — not a judgment, not non-author closure).
BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. Reviewed at 2026-10-21T15:18Z against
BASE (`git show 0a47dd1:<path>`) **and** L1's live integration in the working tree
(uncommitted: claim-ledger.tsv, stamps.tsv, self-counts.tsv, release-clock.py, knowledge
entries, SCORECARD/LOG/lesson). "WT" = that working tree at review time; it may move.

Axes attacked: calibration (binder truth after integration), freshness (REGRESSED rule),
operability (default clock check; self-counts runtime under R25-02), ledger cells/citations,
adjacency (population exclusions in adjacency entries).

## Verdict

One concrete defect that **harms calibration and turns R25-02 red**; one citation defect
(conditional on a missing artifact); everything else attacked held. No gate was executed.

## Counterexample 1 (primary) — KN-LEDGER-REPRO-STAMPS is stale in the integrated tree

The round's own lesson stamp moves the number C1 just "corrected".

Evidence (all WT unless marked BASE):
- `corpus/self-counts.tsv:69` binds `corpus/knowledge/claim-ledger.md` `stamped=([0-9]+)` to
  `ledger:R12-03` (executed live: `grep -c '[^[:space:]]' corpus/stamps.tsv`; self-counts
  compares the claim to the *live output*, not the expect pin — BASE `corpus/self-counts.py:11-14,350-356`).
- `corpus/knowledge/claim-ledger.md:301` still states `stamped=89`.
- `corpus/stamps.tsv` now has 90 nonblank lines (it added `corpus/lessons/round-27.md`). I
  measured this with a plain `grep -c '[^[:space:]]' corpus/stamps.tsv` → `90`. This is the R12-03
  command text, run as a count; I did not run it as a gate.
- `corpus/claim-ledger.tsv:28` R12-03 is re-pinned to `^90$`; `.ufo/waves/round-27/expectation-migrations.json`
  `stamp_membership` says before 89 → after 90.
- The sibling copies of the same quantity were bumped: `SKILL.md:46` "90 stamps",
  `PROVINCE.md:52` "90 revision stamps", `corpus/README.md:65` "90 rows". Only the knowledge copy lags.
- The provenance repeats the lag: `corpus/lessons/round-27.md:51` says "stamped 33→89",
  `.ufo/waves/round-27/knowledge-migrations.json:42` gives new text `stamped=89`, and `LOG.md:1506` says "33→89 stamps".
- `SCORECARD.md:1090` forecasts "BASE docs stale knowledge numbers → after 0".

Consequence `[INFERENCE — self-counts not executed]`: `python3 corpus/self-counts.py` prints
`STALE KN-LEDGER-REPRO-STAMPS corpus/knowledge/claim-ledger.md:301 claimed=89 live=90` and ends
`SELF_COUNTS: STALE (claims=56 stale=1 …)` with exit 1. R25-02 (`^SELF_COUNTS: CLEAN \(claims=56 stale=0\)$`)
therefore fails, and the C1 counting command "after docs → stale0, exit0" (`plans/round-27.md:20-21`) is false
on the tree as integrated. The binder is working as designed: it caught the integrator. The harm is to
the calibration claim and its receipts, not to the gate.

Root cause: `knowledge/claim-ledger.md:301` drafted the correction against BASE stamps (89). Integration
then stamped the round-27 lesson, which increments exactly the quantity bound there. This repeats every
round: any round that stamps its lesson moves this number. The knowledge entry is itself stamped, so each
round must also edit and re-stamp it.

Smallest safe correction (L1 integrates):
1. `corpus/knowledge/claim-ledger.md:301`: `stamped=89` → `stamped=90`. Keep the round-10 history clause as is.
2. `corpus/lessons/round-27.md:51` "33→89" → "33→90". Change `knowledge-migrations.json:42` new text to match.
   `LOG.md:1506` is this round's own append, not yet landed; fix it the same way if L1 treats it as editable.
   Otherwise append a correction line (append-only rule).
3. Re-stamp `corpus/knowledge/claim-ledger.md`. The stamp count stays 90. R24-05's projection is the path
   column only (`corpus/row-identity.sh:71-73`), so its sha is unaffected `[INFERENCE: hash not recomputed]`.

Tradeoff to adjudicate (not a defect): binding a per-round-moving count inside a knowledge entry buys
recurring churn, and the same stamp count is now stated in four places. The alternative is to state no
current count in the line (point to R12-03/R21-04) and keep only the round-10 output as history. That
removes this binding rather than fixing it, which narrows the C1 population. That is the judge's call,
not mine.

## Counterexample 2 — lesson M27-2 cites a missing receipt (citations / provenance)

- `corpus/lessons/round-27.md:86` (M27-2 evidence cell) cites `.ufo/waves/round-27/c1-before.json`.
  At review time that file does **not exist**. Present: `c2-before.json`, `tools/c1-measure.py`,
  `tools/c2-measure.py`, `captures/metadata.json`, `knowledge-migrations.json`, `expectation-migrations.json`.
- Lessons are in the citation gate's doc set (`corpus/claim-ledger.sh:767`
  `DOCS_LIST+=(… corpus/knowledge/*.md … corpus/lessons/*.md)`).
- Consequence `[INFERENCE — citations not executed]`: if the file is still absent at landing, there is one
  unresolved `.ufo/` citation. The M27-2 "five STALE at BASE" claim then cites evidence that does not exist
  (false provenance).
- Correction: write the C1 before-receipt to exactly that path from `tools/c1-measure.py` (possibly
  XC1Measure's pending output), or change the citation to the receipt that actually exists. Do not land
  the citation unresolved.

## Attacks that held (no harm found)

- **R25-02 runtime/timeout.** `check()` caches outputs per ledger id (BASE `corpus/self-counts.py:349-351`).
  BASE executed 11 distinct ledger ids (R11-09, R12-03, R14-01, R15-02, R16-02, R21-03, R21-04, R24-01,
  R24-02, R25-01, R25-03). WT adds exactly one: R15-04, a 30s-timeout `grep -cE … corpus/checklist.tsv`.
  New R16-02/R11-09/R21-04/R12-03 bindings reuse cached output, and R16-03/R12-02 are `expect:` (never run).
  Marginal cost is one grep plus the six new release-clock selftest cases (offline; the downgrade observe
  case uses `StaticOpener`, `release-clock.py:1381-1396`). I see no new timeout risk against R25-02's 600s
  `[INFERENCE: not timed]`. R15-04 passes the policy: allowlisted `grep`, not `claim-ledger.sh`, no host tag
  (BASE `claim-ledger.tsv:36`).
- **Default clock check operability (R25-04 CLEAN30).** No row in BASE `corpus/release-clocks.tsv:2-31`
  has a numeric observation below a numeric anchor. S012's anchor `v1.21.x` is non-numeric, so
  `numeric_version` → None and the inequality rule applies (`release-clock.py:369-386`). S027/S028 have
  3.15.1 > 3.15.0. Every other feed row has observed == anchored. The new `regressed` receipt check
  (`release-clock.py:587-589`) is unreachable for the pinned receipt, whose verdicts must equal the table's
  `fired`/`not-fired` (`release-clock.py:410`). CLEAN30 should hold `[INFERENCE — not executed]`. The
  `RELEASE_CLOCK_OBSERVE:` summary gained `regressed=%d`, but nothing in the lane outside historical waves
  parses it (rg: only `release-clock.py:858`).
- **Observe exit claim.** `--observe` returns only fetch failures, but `main` re-evaluates the written
  receipt, and a `regressed` receipt adds REGRESSED. The process exits 1 (`release-clock.py:1656-1672`),
  so PROVINCE's "REGRESSED (exit 1)" is not an overclaim for observe either.
- **False REGRESSED on multi-branch feeds** (Python/Vault/OpenBao publish older-branch maintenance
  releases later). Neutralised: `parse_latest_version` takes the numeric max over all stable entries,
  not entry order (`release-clock.py:686-731`). Only a feed window cropped below the anchor turns
  REGRESSED, which is the intended finding. The lesson's Limits already scope it as "needs human
  re-verification", not a vendor rollback claim.
- **Locator uniqueness/meaning of new KN rows** (read, not executed): KN-LEDGER-REPRO-CLAIMS/STAMPS lazily
  capture the current value before the round-10 history on `claim-ledger.md:301` (65 / 89). KN-OPREF-*
  match `op-ref-consumption.md:276` and `:374` once each. KN-CENSUS-DRIFT-* match `surface-census.md:32`
  (15/20). `rows:` sources give drift-baseline 15 and drift-symbols 20 by my plain line count, consistent
  with `drift-gate.md:143` "of 15" and `surface-census.md:32`.
- **Adjacency entries.** The unbound 61/18 copies at BASE `adjacency-scope.md:256-257` sit under
  "Reproduction (2026-09-29)" and `:298-299` under "Evidence", both excluded by the declared rule
  (`self-counts.tsv` round-27 header). Bound copies: `:16-17` ("Current gates"), `:155`, `:269`.
  No unexplained omission.
- **New sources do not unbind the clock.** S042/S043 are `180d`, not `on-release` (`corpus/SOURCES.md:49-50`),
  so `on_release` stays 30 and no UNBOUND appears.

## Minor (not blocking)

- `KN-CHECKLIST-FALSIFY-ITEMS` binds the `items=` value of a falsifier's *expected output*
  (`checklist-execution.md:179`) to R15-04's row count. That relies on the documented items↔rows bijection,
  a second definition the SKILL anti-pattern warns about. `floor=8`/`runnable=6` on the same line stay
  unbound. It is acceptable only because the runner enforces the bijection.
- `adjacency-scope.md:16-17` "Current gates" sits inside a paragraph read "on 2026-09-29". Binding it as
  current tense is defensible but is a judgement a non-author may dispute.

## Not checked (unrun ≠ pass)

- No gate, selftest, or measure tool was executed: self-counts, release-clock (default/selftest),
  `claim-ledger.sh verify/cells/citations/docs`, sources-census, revision-audit, row-identity,
  `c1-measure.py`, `c2-measure.py`. The only commands run were plain `grep -c` line counts, git diff/show,
  and file reads.
- SCORECARD cell pointers for round 27 (`cells` mode) and R13-01/R24-06 heading counts were not verified.
- The new R21-02 census line (rows=43 …) and the S042/S043 capture digests were not verified.
- The C2 selftest cases' expected outputs were not checked against the harness (`run_case` semantics),
  nor were the six cases counted to 73.
- Separability overlays (C1-only / C2-only) were not checked; peer seats own that.
- Tooling: nothing installed or updated.

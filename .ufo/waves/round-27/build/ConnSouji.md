# ConnSouji — sibling-overlap scan: souji/mori freshness and doc-count gates vs kagi C1/C2 (round 27)

Seat: `KagiR26.ConnSouji-17` (connector, leaf). Lane-authored advice for L1, not non-author closure.
Scope: souji-shokunin and mori-shokunin, read-only. No sibling file was touched; no kagi production file was written.

## Observed revisions (2026-10-21)

| repo | observed | note |
|---|---|---|
| kagi-shokunin | BASE `0a47dd189356ea66ec83c3891eed54526e95b89b` = HEAD | worktree carries L1's uncommitted round-27 integration: 15 modified files plus untracked `.ufo/waves/round-27/`, `corpus/lessons/round-27.md`, `plans/round-27.md`. All BASE citations below are `git show 0a47dd18:<path>`; worktree observations are labelled as such and are not verified. |
| souji-shokunin | `81a2646d53f914a226b6faa96e69ee5d01e8d348` | dirty: one modified `.ufo` file plus untracked `census/operator-sweep-20261019/`; cited `corpus/`, `tools/`, `SKILL.md`, `PROVINCE.md` files at HEAD |
| mori-shokunin | `50b6f754e7188e8c6352fc8df7b7b5195e697fa8` | untracked `.scratch/` and round-22 evidence only; cited files at HEAD |

Commands: `git --no-optional-locks rev-parse HEAD` and `status --porcelain` per repo.

## Axes

- **Calibration** — C1: current-tense numbers in `corpus/knowledge/*.md` bound to their live source, stale ones corrected with an old-value history clause, one-digit mutation turns the binder STALE.
- **Freshness** — C2: a strict X.Y.Z observation below a strict X.Y.Z anchor becomes typed `REGRESSED` (exit 1), never fired/CLEAN.

## Inspected scope (exact)

- souji: `PROVINCE.md` (whole), `SKILL.md` gate registry (term greps only), `corpus/QUALITY.md:34`, `corpus/SOURCES.md` rows S040/S050/S061/S067/S074, `tools/souji-landing-gate.py:20-120,83-86,918-923,1033-1043`, `tools/souji-evidence-cache.py:1-16,44-46,100-103`, `tools/souji-rev-pin.py:1-30`.
- mori: `PROVINCE.md` (whole), `corpus/QUALITY.md:102-103,127-129`, `corpus/README.md:11-16`, `corpus/knowledge/surfaces-r7.md:5-15,195,317-325`, `corpus/SOURCES.md` rows S065/S068/S069/S073, `tools/mori-content-review.py:1-40`, `tools/mori-round13-regressions.py:172,530-570`, `.ufo/waves/round-19/frozen/content-population.json` (parsed: 194 paths, 0 under `corpus/knowledge`).
- fleet: `scripts/sources-census.sh:20-37,655-670`.
- kagi BASE: `PROVINCE.md:53-54`, `SKILL.md:47-48`, `corpus/QUALITY.md:118,120,126`, `corpus/self-counts.py` (docstring, `:88-90`, `:137-152`, `:323-338`), `corpus/self-counts.tsv:1-13`, `corpus/release-clock.py:341-346,362-363,518-527`, `corpus/release-clocks.tsv:9`, `corpus/knowledge/surface-census.md:31`, `corpus/knowledge/op-ref-consumption.md:374-376`; and the kagi worktree diff for `corpus/self-counts.tsv`, `corpus/release-clock.py`, `SKILL.md`, `PROVINCE.md`, `corpus/README.md`.
- Prior lane evidence: `.ufo/waves/round-26/build/ConnectClock.md` §CX2 (18 sibling `3.15.0`/`on-release` rows), not re-derived here.
- No gate, selftest, build, lint or formatter was run. The one numeric check below is a static TSV parse, not a gate execution.

## Overlap boundary evidence — C1 (calibration)

1. **No sibling gate binds numbers in its own docs.** The nearest sibling rules are consistency/review rules, not live-source binders:
   - souji `corpus/QUALITY.md:34` (Q10) requires "every number in SCORECARD prose appears in its table row" — a prose-vs-table self-consistency check, manual (`awk`/`grep` in the test column), no live artifact count and no knowledge-entry population.
   - mori `corpus/QUALITY.md:102-103` (Q40) requires a gate-registry row to be swept when its gate/selftest/source changes; `corpus/QUALITY.md:127-129` (Q46) requires a stale pending/version statement to be superseded by a dated appended note, and says "Sweep active province, index and knowledge prose too." Neither provides a machine binding to a live count.
   - mori's `tools/mori-round13-regressions.py:172,530-570` reads `SKILL.md` only to assert that its own registry row names the tool; `tools/mori-content-review.py:33-37` has a `CONTENT_REVIEW_STALE` class but it reviews a frozen wave population by path + `blob_sha256`; that population has 194 paths and **0** under `corpus/knowledge`, so it cannot bind a knowledge-entry number.
   - souji's `tools/souji-landing-gate.py:83-86,918-923,1033-1043` reads `SKILL.md`/`PROVINCE.md`/`corpus/README.md` for cited tool paths and parseability, never for stated counts. `tools/souji-evidence-cache.py:44-46,100-103` binds retained evidence to dependency **digests**, not document numbers.
2. **Sibling docs do carry unbound numbers, so the class is unsolved next door, not duplicated.** Examples: mori `corpus/knowledge/surfaces-r7.md:195` (`PASS (45 cases…) (was 30)`) and `:317-325` (56-case runs, `56/55` false red); mori `corpus/README.md:10-16` (per-round `10/10`, `25/25`, `25/27` index claims); souji `SKILL.md:216,222` (`all32 literal expectations`, `all225 literal decisions`). The mori knowledge examples are round-dated historical observations under a QM21-style rule, so they are not current-tense debt; they are evidence that no sibling gate would notice a one-digit current-tense mutation in a sibling knowledge entry — there is no check to run.
3. **Kagi's existing binder already accepts the knowledge population; C1 needs no second convention.** At BASE `corpus/self-counts.py:137-152` validates exactly three source kinds (`rows:<path>`, `ledger:<ID>`, `expect:<ID>`), `:323-338` resolves any repo-relative `doc` path and takes one locator match per line, and `corpus/self-counts.tsv:1-13` states that the ledger stays the single definition. Extending the same table to `corpus/knowledge/*.md` (as the in-flight table does with 18 `KN-*` rows) is an in-convention extension. A knowledge-specific binder would be the second convention.
4. **Reusable sibling convention: mori Q46's dated note.** Kagi `corpus/QUALITY.md:118` (QM21, BASE) already requires a history clause "with a newer value beside it"; mori Q46 requires a dated appended note naming observation time and closure. The compatible shape is **current value first, dated old value after** — the in-flight `corpus/knowledge/surface-census.md:32` (`(15 files, 20 symbol pins; 19 when this entry was written)`) is an instance. State the contradiction explicitly: Q46's "never rewritten into a claim about the current host" governs host/version observations; QM21 governs lane-artifact counts. Citing Q46 as a blanket "never rewrite" rule would forbid C1's correction; the shared part is only the retained old value and its date.
5. **Sibling staleness semantics are a different vocabulary and must not be reused.** souji `SAFE(stale)` is removal eligibility (scratch type + zero live refs + mtime; `SKILL.md:37,51`, `tools/souji-verify.spec.md:16,53`), and mori `CONTENT_REVIEW_STALE` is retention-review incompleteness. Kagi's `SELF_COUNTS: STALE` is a calibration verdict. Sharing the token across lanes would misstate all three; C1 should keep `STALE` lane-local.

## Overlap boundary evidence — C2 (freshness)

1. **No sibling holds a release clock.** The fleet census validates `recheck` syntax and reports symbolic cadences, but `scripts/sources-census.sh:34-37` says symbolic cadences "(e.g. on-release) are reported, never judged overdue"; `:663-665` only rejects an invalid cadence. Sibling `on-release` rows exist but no lane gate consumes them: souji `corpus/SOURCES.md:60,70,81,87` (S040/S050/S061/S067, Python 3.15.0 docs) and mori `corpus/SOURCES.md:71,74,75,79` (S065/S068/S069/S073, Python 3.15.0 docs). The round-26 connector already routed the 18-row sibling set (`.ufo/waves/round-26/build/ConnectClock.md` §CX2); this scan confirms the souji/mori subset at the current HEADs.
2. **Kagi BASE has no version ordering at all.** `corpus/release-clock.py:362-363` (`norm_version`) only strips a leading `v`; `:518-527` marks `fired` when the normalized observation differs from the anchor, so a lower release reads fired (and a lower `not-fired` row is `INCONSISTENT`). C2 is lane-local code, not a duplicate of a sibling instrument.
3. **Sibling version-supersession rows are not clocks.** souji S074 (`corpus/SOURCES.md:94`) supersedes S067 and mori S073 (`:79`) supersedes S069: this is documentation-page succession inside a source registry, not numeric release ordering. Reusing the `supersedes` label as a clock verdict would conflate page identity with release identity.
4. **Static population check (not a gate run).** Parsing BASE `corpus/release-clocks.tsv` (skipping comments/header) gives 30 data rows, 19 strict-X.Y.Z anchor/observation pairs, and **0** pairs with observation below anchor. C2 therefore does not flip any current row; `CLEAN30` is statically consistent with the new rule. S012 (`corpus/release-clocks.tsv:9`, anchor `v1.21.x`, observed `2.2.0`) is non-strict and must continue to take the inequality branch (`fired`), not `REGRESSED`.

## Counterexamples

- **CX1 — same-line history capture.** `corpus/self-counts.py:326-338` (BASE) records one match per *line* and reads the first capture. With locator `([0-9]+) items`, the line `2 (was 1) items` binds **1**, while `2 items (was 1)` binds **2**. The in-flight knowledge rows are safe because the current value is adjacent to its unit (`surface-census.md:32`; `op-ref-consumption.md:374-376` keeps the old 29 on the preceding line behind an anchored `^superseded:` locator), but no selftest proves the convention, and the table header does not state it. A future QM21 correction written as `35 (was 34) rows` would silently bind 34 and turn the after-docs run STALE (or, if the live count happened to be 34, false-CLEAN a wrong current claim).
- **CX2 — selftest-count self-reference.** Adding C1 selftest cases changes the live `R25-01` count 48; both `SKILL.md:47` and `PROVINCE.md:53` (BASE) state 48 and are bound to it by `SC-SELFCOUNTS-SELFTEST`/`PV-SELFCOUNTS-SELFTEST`. The docs must move in the same landing, exactly mori Q40's sweep rule. The same applies to the C2 selftest count at `SKILL.md:48`/`PROVINCE.md:54` (67 at BASE; the worktree already says 73, unverified).
- **CX3 — C2 branch order can mask a structural defect.** In the worktree diff, `is_regression` is checked before `anchor_ok`/date/verdict validation. A row whose SOURCES anchor does not name the numeric anchor, but whose observation is lower, would be typed `REGRESSED` rather than `INCONSISTENT` (both exit 1). The priority is a design choice; decide it and add a malformed-anchor downgrade control. BASE's equivalent ordering is visible at `corpus/release-clock.py:518-527`.
- **CX4 — `--observe` exit code.** In the worktree diff, `run_observe` returns only `failures` (receipts with `error`); a `regressed` receipt is counted and printed (`regressed=N`) but does not change the exit code. The typed exit-1 finding is produced on `evaluate` (table or retained receipt), not by the writer. If the round requires `--observe` itself to exit 1 on regression, this is a gap; otherwise it is a named limit, not a CLEAN.
- **CX5 — do not absorb sibling rows.** Adding the 18 sibling `3.15.0`/`on-release` rows to `corpus/release-clocks.tsv` would change kagi's default clock population and `CLEAN30`, and would make kagi's gate judge other lanes' source registries. Round-26 already routed them; keep them a report-to-L0 note only.

## In-lane verdict

**C1 and C2 stay in-lane.** No sibling gate reads kagi docs for numbers, and no kagi gate reads sibling corpora. The lanes' own texts already route this boundary: souji refuses credentials/vault refs (`PROVINCE.md:36-37`) and routes credential-shaped findings to kagi (`:55-56`); mori's adjacency row assigns kagi secrets/vault/credential evidence (`PROVINCE.md:68`). C1 and C2 add no credential surface and no vendor-truth claim. C1 is a table/doc extension in `corpus/...` under kagi's own documents; C2 is an additive rule in kagi's own `release-clock.py` over kagi's own `release-clocks.tsv`. The only shared fleet surface is `scripts/sources-census.sh`, which is read-only cadence syntax and symbolic reporting. The reusable convention is mori Q46's dated history note (with the scope caveat in §C1.4); souji Q10 is weaker and does not solve C1; souji `SAFE(stale)` and mori `CONTENT_REVIEW_STALE` must not be reused as kagi verdicts.

## Proposed move (one, bounded)

Adopt **one selector-discipline invariant across C1 and C2: the selector may capture only the current value; every historical value must sit outside its capture.**

- **C1 (calibration improvement):** state the row convention in the `corpus/self-counts.tsv` header — the locator captures the number the current-tense unit modifies, and a QM21 history value goes after it with its date (mori Q46 shape). Add two selftest cases: `doc="Count: 2 (was 1)\n"` → `CLEAN claimed=2`; and the red control `doc="2 (was 1) items\n"` with `locator=r"([0-9]+) items"` and live 2 → `STALE claimed=1`, proving that a history value between the current value and its unit is caught, not silently bound. If L1 prefers enforcement over convention, make a second match on the bound line `AMBIGUOUS`; that parser change must be measured against every existing locator first.
- **C2 (freshness preserved):** keep `numeric_version`'s strict `fullmatch` (worktree diff) and verify the invariant on the **real** row, not just the synthetic `1.2.x` control: S012 `v1.21.x` → `fired`, a strict downgrade row → `REGRESSED` exit 1. The synthetic control plus the real series anchor together prove "history/series outside the numeric selector."

Affected axes: calibration improves (the after-docs clean run and the one-digit mutation are both protected); freshness is preserved (series and old anchors stay outside REGRESSED). No harm identified. Cost: the self-counts selftest count moves 48 → 49/50 and both doc claims must be updated in the same landing (CX2); the C2 selftest count likewise.

## Risks

- The sibling observations are a HEAD snapshot; either lane may commit again before L1 integrates. Re-read before routing.
- The worktree already implements most of this shape; if landed as-is, the move reduces to the two C1 selftest cases, the table-header sentence, and the C2 real-row verification. It is not a rewrite.
- Parser-level enforcement (multi-match → `AMBIGUOUS`) could reject an existing locator I did not re-measure; I did not run the binder.
- The current-value-first rule protects the bound number only. A one-digit edit to a historical value intentionally stays CLEAN; that is the QM21 boundary, not coverage.

## Verification L1 should run after integration (none run by this seat)

- `python3 corpus/self-counts.py` on after docs → `CLEAN`; the same after table over BASE docs → `STALE N` with N recorded.
- One-digit mutation of a bound knowledge current value → `STALE` exit 1; mutation of a history value → `CLEAN` (declared limit).
- `python3 corpus/self-counts.py --selftest` → the new count; `python3 corpus/release-clock.py --selftest` → the new count.
- `python3 corpus/release-clock.py` default → `CLEAN30`; a strict downgrade evaluation → `REGRESSED` exit 1; S012 remains `fired`; `--observe` on a downgrade prints `regressed=1` (confirm intended exit).
- `SKILL.md:47-48` and `PROVINCE.md:53-54` claims equal the executed selftest counts (BASE values 48/67).

## What I did NOT check

- No sibling gate, selftest, build, lint or formatter was executed; no kagi gate was executed. The 30-row/19-strict/0-regression result is a static Python parse of the BASE TSV, not a release-clock run.
- I did not read every historical `tools/impl-*`, `cand-*`, `tests/results/*` candidate in souji; the active gate registry and named tools only.
- I did not verify the truth or currentness of sibling source rows, only their cadence/version text. No network.
- I did not review L1's in-flight code for correctness; diff lines were read only for the C1/C2 seam risks in CX1–CX4. The worktree's 73-case/18-binding claims are unverified.
- No host-private reads, no vault/account/handler/CDP contact, no sibling writes.

## Tooling

No installs or updates.

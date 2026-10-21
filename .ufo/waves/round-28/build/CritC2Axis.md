# CritC2Axis — round 28: does C2 belong under calibration or freshness?

Seat: KagiR28.CritC2Axis-7 (critic); advice written inside the lane, not a closure by a non-author. Paths are
at BASE `3553d499577084a6c98d7078906017840bbf7b28`, except `plans/round-28.md` (only at the claims commit
`bdf90f58…`) and the fleet-root files `AXES.md` and `PROTOCOL-APPENDIX.md` (read 2026-10-21).

## Verdict

**C2 is a freshness claim**, though it is labelled calibration (`plans/round-28.md:45`). So C1 and C2 are two
claims on one axis, which `AXES.md:32` says "count as one claim". No frozen command or fixture depends on the
label; it changes only the claim count and which axis gets credit. Crediting C2 to calibration would make the
calibration row itself an overreach (`AXES.md:15`).

## Strongest case for calibration (stated at full strength)

1. **An author's say-so currently exempts a value from checking.** The `derived:` prefix alone sets
   `anchor_ok = is_derived or …` (`corpus/release-clock.py:565-566`). Calibration covers "overreach caught"
   (`AXES.md:15`). C2 replaces "trusted because the author said so" with "checked against the lane's own record".
2. **Nothing live is touched.** Both sides of the check are committed text (`release-clocks.tsv` against
   `SOURCES.md`). The fixtures edit only the table and a mirrored receipt (`plans/round-28.md:61-68,93-101`).
   Freshness is defined as "re-verified against **live** surfaces" (`AXES.md:14`). C2 adds no live
   re-verification, because the `--observe` fetch path is unchanged.
3. **It corrects a false statement about a gap.** `corpus/lessons/round-27.md:215-216` says derived anchors
   are "unverifiable by design". `.ufo/waves/round-27/residual/CritFinalC2.md:113-114` showed that every live
   derived anchor is already named by its feed row. My model confirms this: 0 of 15 mismatch at BASE
   (control row below). Correcting a false gap statement is calibration ("gaps named honestly").
4. **Someone outside the claim already named calibration.** CritFinalC2 lists the impacted axes as
   "C2 freshness (claim scope) **and calibration** (the R25-04 pin cannot see it)" (`…/CritFinalC2.md:112`).
5. **The plan's analogy.** "bound to its pinned source, as QM21 binds numbers" (`plans/round-28.md:54-55`).

## Strongest case for freshness — and why each calibration point fails

- **QM21 excludes this case by its own wording.** QM21 binds "a current-tense number a committed doc states
  **about this lane's own artifacts**" (`corpus/QUALITY.md:118`). A derived anchor states the identity of an
  upstream release: "newest stable SOPS tag when the row was opened" (`corpus/release-clocks.tsv:5`). It is a
  fact about a third-party surface, not something the lane says about itself. So the analogy fails (answers
  calibration point 5).
- **R25-04 being blind doesn't decide the axis.** Round-27's `rollback` fixture printed the identical pinned
  summary with exit 0 (`.ufo/waves/round-27/c2-before.json` `/results/rollback`) and was booked as **freshness**
  (`SCORECARD.md:1091`). Every clock defect leaves R25-04 green (answers calibration point 4).
- **The "nothing live" argument proves too much.** Round-27 C2 was also offline fixtures (`plans/round-27.md:25-35`).
  So were round-23 C2 (fetch-provenance rows, `SCORECARD.md:844`) and round-24 C2 (`:884`). All three were
  booked as freshness. If the argument held, all three would need relabelling (answers calibration point 2).
- **Fixing the lesson's false sentence is a side effect, not what gets measured.** The frozen predicate counts
  clock verdicts (`plans/round-28.md:65-68`), not a self-assessment against repo state (calibration's signal,
  `AXES.md:15`); any freshness fix would falsify that sentence equally (answers calibration point 3).
- **The exemption guards a freshness floor.** Derived anchors feed `feed_floors()` (`corpus/release-clock.py:390-410`).
  The REGRESSED rule (`:567-574`) is the drift detector. G1–G4 are feed rollbacks, with the observation lowered
  to match the anchor. That is round-27's `rollback` class with the floor moved underneath it. What fails is
  that a stale stream is accepted as current, which is the freshness definition (answers calibration point 1).
- **Lineage.** Round 28 ships the "flip" of a limit named under round 27's **freshness** C2 ("bind every
  floor-contributing anchor to its feed row's anchored release … next-round candidate",
  `corpus/lessons/round-27.md:213-218`; `plans/round-27.md:25`). Derived anchors entered under freshness too
  (`SCORECARD.md:968`; `corpus/lessons/round-25.md:71-75`).
- **Lane precedent at BASE is consistent.** Calibration claims are the lane describing itself (`SCORECARD.md:642,
  845,885,969,1090`); claims binding a source, registry entry or release are freshness (`:844,884,968,1026,1091`).
  C2 binds a table cell to a registry feed row (`corpus/SOURCES.md:39-43`): freshness.

## Counterexamples executed (BASE sandbox; clock and census are BASE code)

Runner: `sandboxes/CritC2Axis/axis-fixtures.py`, output in `axis-fixtures.json`. "C2 model" applies
`plans/round-28.md:51-53` literally, using BASE's `version_is_named()`. **It models the predicate; it is not
the integrated patch**, so any "after" result is inferred.

| fixture | BASE clock | C2 model mismatches |
|---|---|---|
| control (receipt copy) | CLEAN30, exit 0 | none (all 15 derived anchors bind) |
| G1 SOPS → 3.13.2 / G2 Vault → 2.1.0 / G3 OpenBao → 2.7.0 / G4 curl → 8.22.0 | CLEAN30, exit 0, ×4 | exactly that group's ids, ×4 |
| G1..G4 **+src** (the same forgery plus a consistent edit to the feed row's anchor and quote in `SOURCES.md`) | CLEAN30, exit 0, ×4 | **none**, ×4 |
| O1: S008 derived `3.13.03`, observed equal, not-fired | CLEAN30, exit 0 | S008 |

1. **The binding target isn't pinned (impacted axis: freshness, inside the claim's scope).** The `+src` variants
   pass the C2 model, and `bash corpus/sources-census.sh` stays `SOURCES_CENSUS: CLEAN (rows=43 …)` with exit 0.
   This holds even though `corpus/source-fetches.tsv:76` still records `<title>v3.13.3</title>`, because the
   census never compares the capture quote with the anchor (`corpus/sources-census.sh:255-287`). So after C2,
   a two-file forgery (table plus receipt) becomes a three-file forgery, not an impossible one. "Bound to its
   pinned source" (`plans/round-28.md:54`) overstates this. This is **not** a defect in the frozen fixtures:
   they declare SOURCES.md untouched. It is a limit that should be named. Flip: require the feed row's anchor
   version to equal its `source-fetches.tsv` quote version. That would also be freshness, following the
   round-23/24 precedent.
2. **The contract's meaning changes (impacted axes: freshness and calibration of the note text).**
   A derived anchor is documented as "newest stable when the row was opened" (`corpus/release-clocks.tsv:5`;
   `corpus/lessons/round-25.md:71-75,225-227`, where "past feed states were not retained"). C2 instead checks
   "named by the feed row" fetched on 2026-10-21 (`corpus/SOURCES.md:39`). The two agree today only because
   every upstream release predates the row open dates (SOPS 07-23, Vault 10-15, OpenBao 10-01, curl 10-14,
   against rows opened 10-19..21). [INFERENCE] Suppose a row was opened before an upstream release and its
   feed row was fetched after it. The binding would force the anchor to a release the doc was never checked
   against. Smallest fix: the lesson and QM23 (`corpus/QUALITY.md:120`) should restate the derived contract as
   "the version named by its `feed_source_id` row at binding". A rearm then re-points the binding to a
   superseding feed row, as S040/S041 already did when moving from S036 to S039 (`corpus/release-clocks.tsv:30-31`).
3. **One defect, both claims (supports the one-axis reading).** O1 is CLEAN at BASE. C1's canonical-token rule
   (`plans/round-28.md:20-23`, which covers anchors) and the C2 model would both flag S008. Neither frozen
   fixture set contains O1: C1 uses S040, and G1–G4 use canonical versions. So the frozen separability
   overlays can pass while the two claims' defect classes overlap on derived rows.

## Smallest safe correction

Append a plan correction below `plans/round-28.md:91`, leaving frozen text and commands untouched: book C2
under **freshness**; under `AXES.md:32` the round carries **one** freshness claim measured by two frozen
commands; calibration stays at 9 with no claim. This is a fixable labelling defect, not a code defect. If C2
keeps the calibration label, the judge should not credit two distinct axes (`AXES.md:32`;
`PROTOCOL-APPENDIX.md:49`). A genuine calibration move (measuring committed derived-anchor statements such as
`lessons/round-27.md:215-216` and QM23 against repo state) needs a new counting command: next round.

## Commands run (all inside my sandbox or read-only against the lane)

- Read-only git (`rev-parse`, `diff --stat <BASE> HEAD`, `cat-file -e`, `show <BASE>:…`): all exit 0. The diff
  from BASE to HEAD is only `plans/round-28.md` plus the start census. `git archive <BASE> | tar -x`: exit 0.
- `python3 -I -B corpus/release-clock.py` (sandbox BASE tree, `env -i`): exit 0, CLEAN30.
  `python3 -I -B axis-fixtures.py`: exit 0; all 10 fixtures exit 0 with CLEAN30 and no traceback.
- `bash corpus/sources-census.sh` on the sandbox BASE and on `runs/G1-sops+src`: both exit 0, CLEAN.
  Reading `.ufo/waves/round-27/c2-before.json`: exit 0.

## Not checked

- No integrated C2 patch: the "after" results come from the predicate model only. Not run: XC2Patch's draft,
  `c2-measure.py`, `--selftest`, `claim-ledger.sh`, stamps/revision audit, `self-counts.py`.
- No live fetch or `--observe`; finding 2's future divergence is inference. I did not read the canonical Rust
  judge's source, so I don't know whether it checks axis distinctness by label or by content. I did not review
  C1's correctness or the frozen tools' code. No tools were installed or updated.

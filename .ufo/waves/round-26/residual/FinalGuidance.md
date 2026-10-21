# Round 26 residual — FinalGuidance (touched active docs: stale preserved-default / draft90d sweep)

Seat: `KagiR26.FinalGuidance` (critic). Candidate `d30c9892a7377b8b5a51817d1db8b81eaddcc397`,
BASE `1bf3eec48d3761580ffd375c88143232485ae814`. All reads are candidate blobs
(`git show`/`git grep` at the candidate). Lane-authored advice only; not non-author closure,
no judgment/admission. No production, index or jj writes; this file is the only write.
No build/test/lint/format was run; `final-measure.py` and `replay-current.sh` were read, never executed.
No tools installed or updated. (`skill://godspeed` did not resolve: no `godspeed/SKILL.md`
under `~/.omp`; the godspeed instructions in the assignment were followed as given.)

## Verdict

No touched active doc still promises the rejected preserve-default or draft90d candidate.
Every draft90d mention is framed as rejected, the plan correction explicitly supersedes
line 7, and the chronology wording matches the captured feed and receipts. There are no
continuous-monitor claims and no new-capability claims.

Residual defects: one stale preserved-default comment in a cited wave tool (G1), one
stale "active contracts" count label (G2), and one incomplete receipt-time statement (G3).
There are also two pending items L1 must close in the final suite: the future-release
fixture has not been run yet (G4), and several forward references to an append that does
not exist yet (G5). None of these needs a code-behavior change.

## Findings

### G1 — stale preserved-default comment in the cited replay wrapper (observed; fixable)

- Evidence: `.ufo/waves/round-26/tools/replay-current.sh:2`:
  `# Frozen round-26 evidence replay, not a replacement for the historical default.`
- Contradicts the landed cutover: `corpus/release-clock.py:28` (`DEFAULT_RECEIPT_SHA256 = "13b8540c…a169"`),
  `corpus/release-clock.py:450` (default path `.ufo/waves/round-26/observe-2.json`), `corpus/lessons/round-26.md:51-53`
  ("ACTIVE binding table, default receipt path/digest and R25-04 expectation migrate explicitly"),
  `.ufo/waves/round-26/expectation-migrations.json` `default_receipt` old→new. The same wrapper's
  own default root is the ACTIVE profile (`replay-current.sh:7`, `frozen=${2:-"$here/../rearmed"}`).
- Active docs direct readers to run this wrapper: `SKILL.md:804`, `corpus/README.md:208`, `SCORECARD.md:1026`, `LOG.md:1459`, `corpus/lessons/round-26.md:74`.
- [INFERENCE] The line looks like a leftover from the rejected preserve-default draft, which
  kept the round-25 receipt as default. Single-commit history does not show this directly.
- Impacted axes: freshness and operability (a reader may think the historical default is still active).
- Pin safety (observed): `replay-current.sh` is not in `corpus/stamps.tsv` or either
  `inputs.sha256`. `final-measure.py:65` uses its path only. Editing the comment changes no pin.
- Smallest safe correction: change only line 2, for example
  `# Round-26 snapshot replay of the existing gate (default: rearmed active profile; pass frozen/ for the historical 28-record replay). Not a monitor.`

### G2 — "Round-25 active contracts" still states 28 rows on S033–S037 (observed; low)

- Evidence: `corpus/README.md:170` heading `## Round-25 active contracts`; `corpus/README.md:181-184`:
  "the 28 `on-release` registry rows bound to S033–S037 release feeds …". The appended sentence at
  `:184` qualifies only the receipt as historical. The active profile is now 30 on-release rows, and
  S039 is an additional feed (`corpus/release-clocks.tsv` S040/S041 → `S039`; ledger `R25-04` expects `on_release=30`).
- The round-26 section (`corpus/README.md:194-215`) states the current truth, but this heading says
  "active", so the count reads as current tense.
- Impacted axes: calibration (current-tense self-description). [INFERENCE] `self-counts.tsv` does not bind this "28" (the gate was not run; I only observed that R25-01 is a 38-binding set).
- Smallest safe correction: change only `:182` to "the 28 (round 25; 30 at round 26 with S039, see §Round-26) `on-release` …", or rename the heading "Round-25 contracts (as landed)".
- Related, no action needed: `SKILL.md:785` heading `### Round-25 gate registry additions` now has a row (`:787`)
  describing the round-26 default. That is a mixed label, but the row content is accurate.

### G3 — the lesson names only the first round-26 receipt time (observed; low)

- Evidence: `corpus/lessons/round-26.md:133`: "The new Python observations are `2026-10-21T13:36:36Z`."
  That matches `.ufo/waves/round-26/observe-1.json` (S027/S028 at 13:36:36Z). The ACTIVE default receipt
  `.ufo/waves/round-26/observe-2.json` records S027/S028 at `13:43:24Z` and S040/S041 at `13:43:27Z`.
- This is not a chronology error: both times are after the 3.15.1 pubDate `09:59:50` and after the 3.14.9 pubDate `13:08:09`.
  The time of the current default receipt is simply not stated.
- Smallest safe correction: append "; the active rearmed receipt `observe-2.json` records 13:43:24Z/13:43:27Z."

### G4 — the future-release firing claim is code-derived; its fixture has not run (pending for L1)

- Claims: `SKILL.md:802` ("so a later stable release can fire"), `corpus/README.md:205-207`,
  `corpus/QUALITY.md:126` (QM24: "a later-release fixture must fire the successor"), `corpus/lessons/round-26.md:92`, `plans/round-26.md:30-32`.
- Code basis (observed by reading): `corpus/release-clock.py:729-734`. A feed observation is `fired` whenever
  the parsed version ≠ `anchored_version`. S040/S041 are anchored `3.15.1`, `not-fired` (`corpus/release-clocks.tsv`, last two rows).
- Fixture: `.ufo/waves/round-26/tools/final-measure.py:115-119` (`successors-fire-next-release`, fake
  `Python 3.15.2` feed) and `:120-125` (`missing-binding-S040/S041` → `UNBOUND`). Neither selftest
  covers this; the lesson (`:195-196`) says the selftest stays at 67 cases. No final measurement output is tracked at the candidate.
  `expectation-migrations.json` `verification` says "retained separately in final-verification.json once performed", and that file is absent.
- No inflation today: the docs use "can". However, QM24's "must" has no executed evidence until `final-measure.py` runs.
- Correction: L1's single final suite must include `final-measure.py <measured-rev>` and record its
  `successors-fire-next-release` and both `missing-binding-*` records. If it is omitted, change `SKILL.md:802`
  and `README.md:205-206` to "[code-derived, unexercised]".

### G5 — forward references to an append that does not exist yet (pending for L1)

- `SCORECARD.md:1033-1034`: "Before/after commands, exact exits and the pushed revision measured are recorded in the final outcome append below." The candidate's SCORECARD ends at `:1042` ("Planned next") with no append.
- `corpus/lessons/round-26.md:39-40` (`census-end.json`) and `:83-84`, `LOG.md:1458-1460`: also pending. `census-end.json` is absent at the candidate.
- These are phrased as future promises, which matches the round-25 pattern (`SCORECARD.md:980`, `:995`).
  They turn false only if L1 does not append. Appending to stamped `SCORECARD.md`/`LOG.md`/lesson requires a reviewed restamp.

## Exercised clean checks (observed at candidate)

- **Plan correction is explicit.** `plans/round-26.md:19-29` names CritNoAxisHarm, rejects draft90d (`:28`), and
  "supersedes line7's promise". Line 7 is the C1 paragraph ("default R25-04 remain historical … not rewritten to green").
  The reference is correct, and history is declared unrewritten (`:25-28`).
- **Every draft90d / preserve-default mention is rejection-framed:** `LOG.md:1439-1441`, `corpus/lessons/round-26.md:33-35, 92, 139-140, 183-184`,
  `corpus/SOURCES.md:71`, `corpus/QUALITY.md:126` (weak-signal column), `SKILL.md:48` (anti-pattern column), and
  `expectation-migrations.json` `registry.draft_rejected_cadence` (90d → on-release). The registry rows themselves are consistent:
  `corpus/SOURCES.md` S040/S041 recheck `on-release`, S039 `90d`.
- **Current-default labels are accurate** in `corpus/release-clock.py:28,450,1562`, `PROVINCE.md:54`,
  `SKILL.md:48,787,791-796`, `corpus/README.md:184,203`, `corpus/claim-ledger.tsv:83` (R25-04 note), and `corpus/lessons/round-26.md:51-54,198-201`.
  All of them name the round-26 rearmed receipt and say it is not live truth. `git grep observe-1.json` finds only round-dated history
  (`LOG.md:1382`, `SCORECARD.md:688,976`), the qualified `README.md:184`, and the lesson's first-receipt command (`:56`).
- **Chronology matches the captures.** In `.ufo/waves/round-26/captures/S039.body`, 3.14.9 is first with pubDate `13:08:09`, then 3.15.1 at `09:59:50`.
  The round-25 receipt has S027/S028 at `11:31:53Z` (3.15.0); round-26 `observe-1.json` is `13:36:36Z` (3.15.1).
  This matches `corpus/lessons/round-26.md:130-136` and `LOG.md:1427-1428`. "release-since-review" and "mismeasured" occur only negated (`LOG.md:1428`, lesson `:134`).
- **No monitor claims.** Every monitor/continuous mention in the touched docs is negated: `SKILL.md:813`, `SCORECARD.md:1030`, `corpus/README.md:108,213`, lesson `:103,170`.
- **No new-capability claims.** `SCORECARD.md:1021-1022,1036`, `plans/round-26.md:9`, lesson `:9-10`, `README.md:199-200`, `LOG.md:1448`.
  QM24 is a new criterion, but it is grounded in M26-3. Lesson `:173` says "no *ungrounded* new quality criterion", so there is no contradiction.
- **Counts match the artifacts.** `observe-1.json`: 28 observations, fired {S012,S027,S028}, 0 errors (lesson `:57`).
  `observe-2.json`: 30 observations, same fired set (lesson `:190-191`). `observe-run.json`: exit 1, RECEIPT-MISMATCH S027/S028, FAILED observed26 fired1 (lesson `:58-59`).
  15 `derived:` notes in `corpus/release-clocks.tsv` (lesson `:188`). `rearmed/expected.json` before/after (exit 1 with UNBOUND S040/S041 and four mismatches, observed26/bound28/fired1; then exit 0 CLEAN 30/30/fired3/derived15)
  matches `SCORECARD.md:1026`, lesson `:75-79`, `SKILL.md:805-807` and `README.md:208-209`. These are recorded expectations, not outputs I ran.
- **No silent demotion or re-anchor.** The `corpus/SOURCES.md` diff only adds rows. S027/S028/S036 keep status, recheck and used-by, following the S007→S032 precedent.
  This matches the R21-02 note (`claim-ledger.tsv:52`) and `expectation-migrations.json` `existing_status_recheck_used_by_changes: []`.
  `release-clocks.tsv` S027/S028 keep anchor `3.15.0`.
- **Routed-closure provenance holds.** Fleet commit `ff47be96994cfb99d7f6305c009c0c867eae64d8` `MANIFEST.json` `rounds[410]` is the round 25 kagi closure, reviewer CloseKagi25 (lesson `:121-122`, `LOG.md:1424-1425`).
- **C2 is still INCOMPLETE/48.** Stated in `plans/round-26.md:3,9`, lesson `:11-12,104`, `README.md:213-214`, `SCORECARD.md:1028`, `LOG.md:1448-1449`. Not closed.

## Commands run (read-only)

`git diff --stat/--name-status/-U0/-U1 1bf3eec…814 d30c989…397 -- <touched files>`; `git show d30c989…:<path>` for
the lesson, plan, SKILL/README excerpts, the receipts (parsed with `python3 -c json`), `final-measure.py`, `replay-current.sh`,
`expectation-migrations.json`, `rearmed/expected.json` and `captures/S039.body` (title/pubDate grep); `git grep -n -i -E`
for draft/90d/preserv/default/observe-1/round25 receipt/mismeasur/since review/monitor/continuous/capabilit/3.15.2;
`git -C .. show ff47be9…:MANIFEST.json` (rounds[410]). No network access, no host-private reads.

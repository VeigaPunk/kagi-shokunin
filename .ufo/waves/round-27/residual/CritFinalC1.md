# CritFinalC1 — round-27 residual falsification of C1 (knowledge-number binding)

Seat: KagiR26.CritFinalC1-27-t3 (critic, lane-authored advice; not non-author closure).
Candidate `144babcb892f0a30154880a9f94aa59ca8ddf9c5`, BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`.
Production files were read only. Scratch: `/fast/scratch/critc1-r27/`. No tools installed or updated.

## Verdict

The C1 counting claim reproduces exactly. The binder population (22 `KN-*` rows) is honest
as measured: nothing bound is stale at the candidate, and every round-27 history clause in
`knowledge-migrations.json` matches git except one.

The attack still found six defects outside or beside the binder:

- **One stale, unbound current-tense knowledge number in a bound entry:**
  `claim-ledger.md:288` "selftest case 21".
- **One history clause not true of any committed revision:** op-ref §10 "21 when §10 was
  written".
- **Four false or unsupported round-27 meta-statements** in `SCORECARD.md`, `corpus/README.md`
  and the lesson.

None of these invalidates the C1 before/after measurement. All of them are cheap text fixes.

## Instrument runs (exact argv, exit, last line)

All runs used cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`, `T=.ufo/waves/round-27/tools/c1-measure.py`, `O=/fast/scratch/critc1-r27`.
The wrapper exit is always 0 by design. The "inner" exit is `corpus/self-counts.py`'s exit as
recorded in the JSON.

| argv | wrapper exit | inner exit | last line / findings |
|---|---|---|---|
| `python3 $T 0a47dd18… 144babcb… base-docs $O/base.json` | 0 | 1 | `SELF_COUNTS: STALE (claims=60 stale=4 unlocated=0 ambiguous=0)`. STALE: KN-LEDGER-REPRO-SELFTEST claim-ledger.md:304 claimed=72 live=170; KN-OPREF-REPRO-SELFTEST op-ref-consumption.md:276 claimed=29 pinned=36; KN-CENSUS-DRIFT-SYMBOLS surface-census.md:32 claimed=19 live=20; KN-OPREF-FALSIFY-SELFTEST op-ref-consumption.md:296 claimed=21 pinned=36 |
| `python3 $T 144babcb… 144babcb… cand-docs $O/cand.json` | 0 | 0 | `SELF_COUNTS: CLEAN (claims=60 stale=0)`, findings 0 |
| `python3 $T 144babcb… 144babcb… mut-census-symbols $O/m1.json --mutate KN-CENSUS-DRIFT-SYMBOLS` (a `rows:` source; surface-census.md:32, 2→3) | 0 | 1 | `SELF_COUNTS: STALE (claims=60 stale=1 …)`, exactly `STALE KN-CENSUS-DRIFT-SYMBOLS` |
| `python3 $T 144babcb… 144babcb… mut-checklist-floor $O/m2.json --mutate KN-CHECKLIST-FALSIFY-FLOOR` (a `ledger:` source; checklist-execution.md:179, 8→9) | 0 | 1 | `SELF_COUNTS: STALE (claims=60 stale=1 …)`, exactly `STALE KN-CHECKLIST-FALSIFY-FLOOR` |
| `python3 $T 144babcb… 144babcb… mut-substrate-absence $O/m3.json --mutate KN-SUBSTRATE-ABSENCE-FILES` (an `expect:` host pin; substrate-deferral.md:50, 1→2) | 0 | 1 | `SELF_COUNTS: STALE (claims=60 stale=1 …)`, exactly `STALE KN-SUBSTRATE-ABSENCE-FILES` |

These match the lesson's §Executed claim measurements: BASE STALE 4 with the same four ids,
candidate CLEAN60, and each mutation produces exactly one finding naming its id.

I also ran one manual control. In a fresh clone of the candidate under
`/fast/scratch/critc1-r27/manual-AerX` I made two edits:

- `checklist-execution.md:179` `RATIO (runnable=6` → `runnable=7`
- `surface-census.md:76` `(9 of 15 rows;` → `(8 of 15 rows;`

Then I ran `env -i PATH=$PATH HOME=$T LC_ALL=C PYTHONDONTWRITEBYTECODE=1 python3 -I -B corpus/self-counts.py`. It exited 0 with `SELF_COUNTS: CLEAN (claims=60 stale=0)`. See counterexample 6.

## Counterexamples

### 1. `corpus/knowledge/claim-ledger.md:288` "pinned by selftest case 21" — stale and unbound in a bound entry

- **Where it came from.** The line was written at `301b9ec` (round 11). At that revision the
  21st `tcase` was `cite-multi-ref`, the line-ref separator fix the sentence describes, so it
  was true then.
- **Now.** In the candidate's `corpus/claim-ledger.sh` (static `tcase` order from :1584, with
  no conditional or dynamic `tcase` before :1604), case 21 is `stamp-stale` (:1604). The
  separator case `cite-multi-ref` is now the 32nd (:1615).
- **Inconsistent treatment.** The round relabelled the sibling positional index on line 81 of
  the same file ("case `verdict-not-final` (the 16th case when written)"). It left :288
  current-tense and false.
- **Missing from the debt list.** The lesson's §C1 named-debt list does not mention :288. The
  BUILD scout did flag it (`build/KnowClaimLedger.md:154,202`, D5 "two conventions"), but only
  as a convention gap, not as false today.
- **Impacted axis:** calibration. QM26 excludes positional indexes by rule, but QM21 still
  forbids a false current-tense statement.
- **Smallest fix:** "pinned by selftest case `cite-multi-ref` (the 21st case when written)".

### 2. op-ref §10 "36 cases (21 when §10 was written)" — not true of any committed revision

- **Same commit for §9 and §10.** `git log -S` shows both §9's "29 cases" and §10's
  "comparator on 21" first entered in `4b8c018`, which carried the uncommitted round-12 set.
- **What that revision counts.** `corpus/op-ref-probe.sh` there counts 29 selftest cases
  statically: 16 canned `tcase`, 3 setup `tcase`, policy-ref-token `tcase` + 1, and 4
  `policy_case` × 2. So at the only revision where §10 existed in git, the selftest was 29,
  not 21.
- **Where 21 comes from.** 21 equals the count without the four sentinel `policy_case` pairs.
  It was plausibly true of an uncommitted draft [INFERENCE]. The round-22 erratum already calls
  it "an intermediate historical count".
- **Two conventions in one round.** For `surface-census.md` "9 json" and "16 published hashes",
  the round labels numbers that were never true at commit as **misstated**. Here it asserts a
  writing-time truth that git cannot show.
- **Smallest fix:** "(21 as first written — an intermediate draft count; the selftest shipped
  with 29, round-22 erratum)".

### 3. `SCORECARD.md:1090` calibration cell says "18 reviewed `knowledge/*.md` numbers (`KN-*`)"

- **The final count is 22.** `grep -c '^KN-' corpus/self-counts.tsv` is 22, and LOG.md:1504,
  README.md:219 and lesson :53/:138 all say 22.
- **Where 18 came from.** It is the mid-build table size (`build/ConnSouji.md:38`,
  `CritC1Population.md:83`, `CritCounting.md:34` all say "18 `KN-*`").
- **Effect.** The axis evidence cell understates the landed population, and nothing binds it
  (SCORECARD is outside the self-counts population).
- **Fix:** 18 → 22, over eight entries.

### 4. `corpus/README.md:221` "unbindable round-10 outputs are labelled as such" — false label

- The landed `claim-ledger.md:301-303` label is "round-13-close output".
- Lesson :62-63 and M27-3 say the "round-10" label was wrong (the gate shipped in round 11;
  the values first appear in round 13), and that it was corrected before landing.
- The README index sentence kept the withdrawn label.
- **Fix:** "round-13-close outputs".

### 5. Lesson §C1 named debt misstates a correct index; README "five stale"

- **The `:226` index is correct.** `corpus/lessons/round-27.md:75` names
  "`surface-census.md:226` 'selftest case 14' and `:280` 'selftest 10' (off by one per
  KnowSurfaceCensus)". KnowSurfaceCensus row 250 says `:226` is "verified correct
  (`fused-shape-row`)".
- **My static count agrees.** `corpus/surface-census.sh:768-845` runs: 10 `sqlite-unavailable`,
  11 `required-table-gone`, 14 `fused-shape-row`. Only `:280` is off by one; `:117` (case 10)
  and `:140` (case 11) are correct.
- **The README "five" has no matching set.** `corpus/README.md:220` says "five stale ones were
  corrected". The lesson and LOG list four bound corrections (72→170, 29→36, 21→36, 19→20),
  plus the claims/stamped pointer line and two misstated markings. No reading gives exactly
  five.
- **Fixes:** drop `:226` from the debt sentence; change "five" to "four (plus the per-round
  pointer line)".

### 6. Unbound current-tense numbers on or next to bound lines (true today; forward-looking)

These two are not stale; they are bindability gaps beside the binder:

- **Derived number.** `checklist-execution.md:179` `runnable=6` is derived as R15-05's
  runnable 9 minus 3. The locator for KN-CHECKLIST-FALSIFY-FLOOR/ITEMS absorbs it with `.*?`.
- **Data-file count.** `surface-census.md:76` "9 of 15 rows" was introduced this round. 9 is
  checkable from `corpus/drift-baseline.tsv` (9 rows with a sha) and 15 from `rows:`.
  `drift-gate.md:143` "6 of 15" only binds its denominator.

The manual control above confirms that mutating either number leaves the binder CLEAN60. If
the checklist ratio or the baseline hash set moves, these go stale silently, just as the 19
symbol pins did. This is a named-population tradeoff (lesson §Limits), not a defect in the
claim. The smallest correction is to add them to the next round's population.

## History clauses verified true (git-observable)

| clause | evidence |
|---|---|
| claim-ledger.md:81 `verdict-not-final` "16th case when written" | `301b9ec` claim-ledger.sh `tcase` #16 = `verdict-not-final` (39 cases total, matching the R11-09 note "39 until round 12") |
| claim-ledger.md:304 "72 at round-13 close" | `4b8c018` (round-13 close) = 72 `tcase`/`tcase_last` |
| claim-ledger.md:301 "round-13-close output read claims=17 stamped=33" | `4b8c018` and `baec94f` ledger data rows 17, stamps 33 (I did not re-run the round-13 `ids/cited/labeled`, `cites=700 docs=43` or `cells=60…` values) |
| substrate-deferral.md:85 "cases 95-97 when written" | `fecee87` (round 18): `defer-substrate-absent/-present/-line` = cases 95–97 of 97, counting `tcase_last` |
| op-ref :276 "29 when §9 was written" | `4b8c018` op-ref-probe.sh = 29 cases |
| surface-census.md:32 "19 when this entry was written" | `03477c0` drift-symbols.tsv 19 rows; now 20 (R18-01 `symbols_bad=20`) |
| surface-census.md:5 "8 json [first written as 9, misstated]" | `03477c0` and candidate state-shape kinds: 9 sqlite / 8 json / 3 log / 1 lock / 1 marker = 22 |
| surface-census.md:76 "9 of 15 … '16' was misstated" | `03477c0` and candidate drift-baseline: 9 of 15 rows carry a sha |

Unbound copies that are still correct at the candidate: adjacency-scope.md:256-257 and :298-299
(61, 18/18); drift-gate.md:4 (15/20 rows), :170 (13 = R11-05), :176 (20); substrate-deferral.md:9
(15/20 = R18-01); surface-census.md:11 and :252 (16 = R11-03, inside dated sections).

## Not checked

- I did not re-run historical gates to confirm round-13 `ids/cited/labeled_ids`,
  `cites=700 docs=43`, or `cells=60 …`. Only row counts were checked.
- `claim-ledger.md:6` "9 rows at that revision; 14 at round-12 close" was not checked against
  git. It is pre-round-27 text: the round-11 commit shipped 11 rows against a different
  claim-ledger.sh (540 lines, not 436), and round 12 has no commit, so neither value can be
  observed in git.
- I did not re-inventory the 17 entries that hold no in-population number, beyond a grep sweep
  for gate-summary tokens and count nouns.
- I did not execute the 51 adjacency-scope proposals or the drift-gate and surface-census
  candidates.
- I did not run host rows. `expect:` pins (R11-03, R12-02, R16-03, R18-01) were read, not
  executed.
- I did not run `separability.py` or `c2-measure.py`, which are outside this seat's item.
- Case ordinals are static source-order counts, not executed selftest output.

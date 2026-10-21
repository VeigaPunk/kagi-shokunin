# CritFinalDocs — round-27 residual docs sweep (lane-authored advice, not closure)

Seat: KagiR26.CritFinalDocs-27-t3. Target: candidate
`144babcb892f0a30154880a9f94aa59ca8ddf9c5` (HEAD of the lane checkout), BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`. All production text was read from
Git blobs (`git show 144babc:<path>`), not from the working tree. The working
tree carries uncommitted edits to `corpus/lessons/round-27.md` and the wave
tools (see F9). Scratch: `/fast/scratch/CritFinalDocs/`. No tools were installed
or updated. No gates were run inside the lane checkout.

## Instruments executed (scratch clones under /fast/scratch)

cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`, B=`0a47dd189356ea66ec83c3891eed54526e95b89b`,
C=`144babcb892f0a30154880a9f94aa59ca8ddf9c5`, T=`.ufo/waves/round-27/tools`.
Every wrapper exited 0; the child self-counts/release-clock exit is inside the line.

| argv | wrapper exit | last line |
|---|---|---|
| `python3 $T/c1-measure.py $B $C base-docs /fast/scratch/CritFinalDocs/c1-base.json` | 0 | `C1_MEASURE base-docs: exit=1 bindings=60 knowledge=22 stale_knowledge=4 findings=4 \| SELF_COUNTS: STALE (claims=60 stale=4 unlocated=0 ambiguous=0)` |
| `python3 $T/c1-measure.py $C $C cand-docs /fast/scratch/CritFinalDocs/c1-cand.json` | 0 | `C1_MEASURE cand-docs: exit=0 bindings=60 knowledge=22 stale_knowledge=0 findings=0 \| SELF_COUNTS: CLEAN (claims=60 stale=0)` |
| `python3 $T/c2-measure.py $B base /fast/scratch/CritFinalDocs/c2-base.json` | 0 | `C2_MEASURE base: downgrades_accepted_clean=4/4 regressed_exact=0/4 control_clean=True default_exit=0` |
| `python3 $T/c2-measure.py $C cand /fast/scratch/CritFinalDocs/c2-cand.json` | 0 | `C2_MEASURE cand: downgrades_accepted_clean=0/4 regressed_exact=4/4 control_clean=True default_exit=0` |
| `python3 $T/separability.py $C /fast/scratch/CritFinalDocs/sep.json` | 0 | `SEPARABILITY c1-only: knowledge=22 stale_knowledge=0 clock_selftest='RELEASE_CLOCK_SELFTEST: PASS (67 cases)' downgrades_accepted=4/4` / `SEPARABILITY c2-only: regressed_exact=4/4 accepted=0/4 control_clean=True selftest='RELEASE_CLOCK_SELFTEST: PASS (76 cases)' knowledge=0 self_counts='SELF_COUNTS: STALE (claims=38 stale=2 unlocated=0 ambiguous=0)'` |
| `python3 $T/c1-measure.py $C $C mut-<ID> /fast/scratch/CritFinalDocs/mut/<ID>.json --mutate <ID>` for each of the 22 `KN-*` ids (via `xargs -P 6`) | 0 ×22 | every child `exit=1` with exactly one finding naming the mutated id: **18 `STALE`, 4 `UNLOCATED`** (`KN-BREADTH-FALSIFY`, `KN-LEDGER-REPRO-SELFTEST`, `KN-SCOPE-CURRENT-FALSIFY`, `KN-SCOPE-TABLE-FALSIFY`); summary line `SELF_COUNTS: STALE (…)` in all 22 |

Operator note: my first 22-id batch omitted `--mutate` (all CLEAN, i.e. unmutated runs). I discarded it and reran correctly; the results above come from the rerun only.

These reproduce the L1's untracked receipts `c1-before.json` (stale 4), `c1-after.json` (CLEAN60), `c2-before.json` (4/4 CLEAN at BASE: lie fired=4, rollback fired=3, unfire fired=1, nonnumeric fired=3) and `c2-after.json` (0/4, exact REGRESSED sets).

## Findings (claims the code or receipts do not back)

### F1 — SCORECARD round-27 table carries pre-critic numbers; three cells contradict the receipts (calibration and freshness axes)
- `SCORECARD.md:1090` "R25-02 population extended to **18** reviewed `knowledge/*.md` numbers". Counterexample: `git show 144babc:corpus/self-counts.tsv | rg -c '^KN-'` → **22**. Ledger `R25-02` note says "+ 22 KN-* knowledge-entry bindings -> 60", and lessons:53, LOG:1504 and README:219 all say 22.
- `SCORECARD.md:1091` "numeric downgrade fixtures accepted CLEAN at BASE **2/2** → after **0/2**". The candidate's `c2-measure.py` has four downgrade fixtures (`DOWNGRADES = ("lie","rollback","unfire","nonnumeric")`). Measured: **4/4 → 0/4** (my runs above; `c2-before.json`/`c2-after.json`). The 2/2 matches the pre-critic three-fixture tool (lie/rollback/control); the candidate docstring still says "three fixtures", which the working tree later fixed.
- `SCORECARD.md:1091` "R25-03 selftest 67 → **73**". The code diff adds 7 `run_case` + 2 `observe_one` cases = 9; ledger `R25-03` pins `PASS \(76 cases\)`; separability c2-only prints `PASS (76 cases)`; SKILL:48, PROVINCE:54, lessons:94 and LOG:1514 say 76.
- `SCORECARD.md:1097` promises the "measured revision, exact exits and separability overlays are appended below after the measured revision lands; no unrun result is stated here". At the candidate nothing is appended, yet the table above already states results (18, 2/2, 67→73) that no committed receipt produced. The SCORECARD is also unmodified in the working tree.
- Impacted axes: calibration and freshness (the score document misreports its own evidence). Smallest correction: change the three cells to 22, 4/4 → 0/4 and 67 → 76, citing `c1-before/after.json`, `c2-before/after.json` and `separability.json`, and append the measured block the text promises.

### F2 — README round-27 says "five stale" and "round-10 outputs"; the receipts and the lesson say four, and round-13
- `corpus/README.md:220` "**five** stale ones were corrected with the old value kept beside the new one". `c1-before.json` and my rerun report **stale=4** (`KN-CENSUS-DRIFT-SYMBOLS`, `KN-LEDGER-REPRO-SELFTEST`, `KN-OPREF-FALSIFY-SELFTEST`, `KN-OPREF-REPRO-SELFTEST`). lessons:53-57 and LOG:1506-1507 list exactly four (72→170, 29→36, 21→36, 19→20). The only possible fifth, `claim-ledger.md:301`, was replaced by a pointer (`claims=N … stamped=M`), not "old value beside the new one". The uncommitted lesson tail itself says the per-round counts "are outside this count".
- `corpus/README.md:221-222` "unbindable **round-10** outputs are labelled as such". The candidate knowledge text labels them **round-13-close** output (`knowledge/claim-ledger.md:301-303`, erratum at :507-508). lessons:62-64 states that "the first draft's 'round-10 output' label was wrong … and is corrected before landing". README still carries the withdrawn label (calibration).
- Smallest correction: "four stale ones … ; the per-round claim/stamp counts became ledger pointers; round-13-close outputs are labelled as such".

### F3 — lessons:26 still scopes S043 as "CPython-style", contradicting the S043 registry row
- `corpus/lessons/round-27.md:26` "ADMIT tier A for **CPython-style** release-segment ordering". `corpus/SOURCES.md` S043 scopes the row to "Ordering of final release segments of Python software distributions" and adds "**Not a CPython interpreter release policy**". The L1's uncommitted lesson addendum claims "S043's 'CPython-style' scope was narrowed before landing". The committed lesson Gate row was not narrowed. Impacted axis: freshness/sources (tier scope must match the registry, QA2/QA9).
- Smallest correction: reword lessons:26 to the SOURCES.md scope (an append-only erratum line if the lesson is treated as a receipt).

### F4 — lessons:75-76 misattributes "off by one" to `surface-census.md:226`
- Lesson: "`surface-census.md:226` 'selftest case 14' and `:280` 'selftest 10' (off by one per KnowSurfaceCensus)". The cited scout report (`git show 144babc:.ufo/waves/round-27/build/KnowSurfaceCensus.md`, line 250) says `226 | case 14 | positional index, **verified correct** (fused-shape-row)`. Only `:280` is off by one (its §C2, lines 271-277: case 10 is `sqlite-unavailable`, case 11 `required-table-gone`, contradicting the entry's own `:140`). The named-debt list overstates one defect and credits the scout with a finding it did not make.
- Smallest correction: "`:280` 'selftest 10' (off by one; `:226` case 14 verified correct) per KnowSurfaceCensus".

### F5 — M27-2 and the plan say a one-digit mutation turns "exactly that id STALE"; 4 of 22 bindings report UNLOCATED instead
- `corpus/lessons/round-27.md:105` M27-2 fix column: "`c1-measure.py --mutate <id>` for every KN id must turn exactly that id STALE". Also `plans/round-27.md:19` ("turns the binder STALE") and `SCORECARD.md:1090` ("must turn STALE"). Measured (table above): all 22 go red with exactly one finding for that id, but four are `UNLOCATED`, not `STALE`, because their backreference locators (`\(([0-9]+)/\1`, `# \1 scratch cases → PASS (\1 cases)`) refuse a line whose two copies disagree. The binder's summary word is still `STALE` (self-counts.py:35 "1 STALE (including UNLOCATED/AMBIGUOUS)"), so the plan and SCORECARD wording survives on the summary verdict. The per-id M27-2 sentence does not. The uncommitted lesson tail already says "18 STALE and 4 UNLOCATED".
- Severity: wording (the red control is real for all 22). Smallest correction: "exits 1 with exactly one finding naming that id (18 STALE, 4 UNLOCATED)".

### F6 — the M27-1/M27-2 forward reference "final Gate below" dangles at the candidate
- `corpus/lessons/round-27.md:104-105` say "(final Gate below)". The committed lesson (126 lines, stamped `e8d5c547…` in `corpus/stamps.tsv`) has no such section; its only Gate section is the sources Gate at :16. The measured section exists only in the uncommitted 176-line working tree (`73a86047…`). This is false provenance at the frozen candidate: a reader of 144babc finds no measured gate.

### F7 — the three exclusion lists for the C1 population disagree, though lessons:39 presents them as one rule
- lessons:39 "Population rule (`corpus/self-counts.tsv` header; QM26)". The lists differ:
  - lessons:42-49 has eight classes, including **spelled numbers** and **host/substrate observations**.
  - `corpus/QUALITY.md:133` (QM26) has five classes and names **neither** spelled numbers nor host/substrate observations.
  - The `corpus/self-counts.tsv` round-27 header has four classes and names neither "no lane-local pinned source" nor "per-round counts".
- Counterexample: `checklist-execution.md:80` "Seven rows are `by-hand`" and `op-ref-consumption.md:297` "fifteen seeded mutations" are excluded only by the lesson's spelled-number class. A reviewer applying QM26 (the durable criterion) would put them in population. Also, the header excludes "host/substrate observations" while `KN-SUBSTRATE-ABSENCE-FILES` binds `expect:R18-01` (a `[host]` absence pin) and `KN-SUBSTRATE-CENSUS-SELFTEST` binds `expect:R11-03` (`[substrate]`). The distinction between a lane count with a host pin and a host observation is defensible but written nowhere.
- Smallest correction: give QM26 and the self-counts.tsv header the lesson's full class list, or cut the lesson to QM26's list and move "spelled" items into named debt.

### F8 — "excluded by rule, not omission" (lessons:42): unbound derived numbers sit on bound lines
- `knowledge/checklist-execution.md:173` "Add a **17th** … `UNDECLARED (items=**17** rows=16)`": `KN-CHECKLIST-FALSIFY-ROWS` captures `rows=16` but hard-codes the literals `17th` and `items=17` in its locator.
- `:179` "`RATIO (runnable=**6** floor=8 items=16)`": `floor` and `items` are bound (R15-05, R15-04); `runnable=6` (= R15-05 runnable 9 − 3) is not.
- If a 17th checklist item lands (R15-04 → 17), `items=16`/`rows=16` go STALE but "17th"/"items=17" stay silently wrong, and that locator stops matching only by accident. If runnable becomes 10, `runnable=6` stays silent. None of these falls in a named exclusion class (they are current-tense expected outputs, derived from pinned sources), and none is in the named-debt list.
- Also, `KN-CHECKLIST-FALSIFY-ITEMS` binds the SKILL-item count `items=16` to `ledger:R15-04`, which counts **checklist.tsv rows**, a second definition that agrees only under the gate's bijection (SKILL.md:47's don't-column: "binding to a second definition of the quantity").
- Severity: low (C1 claims a reviewed population; lessons:111-112 concedes judgment calls). Smallest correction: name these as debt, or say "derived arithmetic on a bound line" is an exclusion class.

### F9 — process: post-freeze uncommitted edit to a stamped production file
- `corpus/lessons/round-27.md` in the working tree (176 lines, sha256 `73a86047…`) differs from its stamp (126 lines, `e8d5c547…`). Any `claim-ledger.sh verify` run in the lane checkout (not run by me) would report the lesson STALE until it is restamped. The added text also changes production claims after "production is frozen". It carries corrections that F5/F6 need, but it is not part of 144babc. `.ufo/waves/round-27/tools/c2-measure.py` was also edited after the candidate (docstring only; `separability.py` imports the working-tree copy, and the measured behaviour is identical).
- Smallest correction: land the addendum as a reviewed restamped commit (or a successor candidate) before closure measures 144babc. Otherwise closure reads the dangling F6 reference.

### F10 — minor
- `plans/round-27.md:33-34` "**live** default receipt still CLEAN30". The default is the pinned round-26 receipt, "NOT live vendor truth" (SKILL:48, PROVINCE:54, R25-04 note). Measured default exit 0, CLEAN30/fired3 in both runs. Only the word "live" is wrong.
- `knowledge/op-ref-consumption.md` at the candidate ends without a trailing newline after the new erratum. The erratum says "both §9 and the §11 '36' are bound" but omits the third binding `KN-OPREF-FALSIFY-SELFTEST` (§10, :296).

## Checked and backed (no counterexample found)
- Stamps 89→90 and claim rows 65 (PROVINCE:52, SKILL, README:65): `rg -vc` over the candidate blobs gives 90/65. Ledger R12-03 `^90$`, R21-04 `^65$`.
- Sources 41→43 (lessons:31, SCORECARD:1093): S-rows 41→43. R21-02 pins `rows=43`.
- Selftest 67→76 (SKILL:48, PROVINCE:54, lessons:94, LOG:1514): 9 added cases in the diff; c1-only overlay prints 67 and c2-only prints 76.
- self-counts selftest 48 (SKILL:47, PROVINCE:53): `corpus/self-counts.py` is unchanged base→candidate, R25-01 pins 48, and the binder accepts any repo-relative doc, so the knowledge extension is data-only.
- 22 bindings over 8 entries (lessons:53, LOG:1504, README:219-220): verified (per-entry counts 4/5/4/1/1/3/2/2).
- 25 entries and 25 Know* scout reports (lessons:50-51, LOG:1505): verified. 17 = 25 − 8.
- Every knowledge line cited in lessons:53-81 matches the candidate text (claim-ledger.md:81,301,303,304; op-ref:276,296; surface-census:5,32,76,119,226,280; substrate-deferral:85; sops:68-70; vault:76-78; checklist:80; handler-trust:306; config-layering:125-126). credential-isolation.md has 78 lines.
- C2 code wording (QM25, SKILL:48, PROVINCE:54, lessons:85-98): `is_regression` requires both values to be strict X.Y.Z; `feed_floors` takes the max over well-formed `clock=feed` rows per exact feed URL; a REGRESSED row is excluded from observed/fired and fails the run; `observe_one` floors on the anchor and the table's previous observation and types the result `regressed`; `main` exits 1 because `evaluate` adds REGRESSED for a `regressed` receipt.
- Observe-mode feed floor: in `--observe`, the feed floor is applied to the table's stored observation, not the fresh one. I found no live counterexample. Any offline-CLEAN table already has every row's stored observation at or above its feed floor, so the previous-observation floor subsumes it. On the current table: Python 3.15.1, Vault 2.2.0 (S012 prev 2.2.0), OpenBao 2.7.1, SOPS 3.13.3.
- M27-1 fired counts (lie 4, rollback 3, unfire 1) match `c2-before.json`. QM25/QM26 cite M27-1/M27-2 (LOG:1517).
- Lessons:7-9: fleet `MANIFEST.json` `rounds[419]` is round 26 kagi, admitted, verification by CloseTabi21, four `outside_spotcheck` items all `agree`, notes "Open L0: none new".
- Lessons:18-26: `captures/metadata.json` gives accessed_at 2026-10-21T15:13:51Z, HTTP 200, the declared UA, and quote_words 9 with located_count 1 for S042. Body sha256 matches source-fetches.tsv (`f9d4b8b1…`, `4e53ed83…`). S043 body contains "Last updated on Oct 12, 2026". The S043 quote is 19 words.
- LOG:1519-1521: `build-refusals.json` has tries 1-16 with `failed_jobs` 67, then try 17 with 0 ("Spawned 67 background agents").
- M27-4: `misroot-sweep.txt` sha `56f224c3…` equals the candidate blob of `build/ScribeLesson.md`. The fleet path `.ufo/waves/round-27` is absent.
- All Crit*/Src* seat reports cited by the lesson exist in the candidate tree.

## Not checked
- Full-ledger `claim-ledger.sh verify` / `citations` / `cells`, `sources-census.sh`, `release-clock.py --selftest` at the candidate in a full fleet layout. I relied on the selftest counts printed by the separability overlays and on ledger pins.
- Whether S042/S043 quotes still locate on the live pages today (no network fetch; peer CritFinalSources' item).
- Live `--observe` behaviour (network; refused by contract).
- A complete digit census of the 17 "no in-population number" entries. F8 is a spot counterexample, not a census.
- The truth of the excluded/debt numbers themselves (e.g. whether "fifteen seeded mutations" is still true), and the first-draft history in M27-3 ("stamped=89", "round 10").
- SCORECARD/LOG text outside the round-27 sections, and the round-27 build seat reports beyond the ones cited above.

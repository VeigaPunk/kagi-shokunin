# Round 70 — kagi (secrets & vault ops) — `## Mistakes` DRAFT (seat R70ScribeLesson)

Seat: `R70ScribeLesson` (scribe, lesson draft). Lane: `kagi-shokunin`.
Drafted from the lane's own record; the L1 (`KagiR70`) integrates.

Source of the two defects drafted here: `corpus/lessons/round-69-verifier-spotcheck.md`
§5 items 1–2 (the round-69 closure's routed defects), read against the lane's committed
bytes and the fleet report's committed bytes.

**Numbering note for the L1.** The L1's plan Amendment A1 already reserves `M70-1` for the
S170/S105 registry finding ("mined as M70-1", `plans/round-70.md:128`). This seat's three
entries are therefore numbered **M70-2, M70-3, M70-4**. They are distinct from M70-1:
M70-1 is about *which registry row* was added; M70-2/M70-3/M70-4 are about *how a count
a report states is derived*. M70-4 overlaps M70-1's territory only in the 25→26 census
drift (also raised by `R70ReviewerSrc` SR-2) — the difference is that M70-4 is the
count-binding rule with an instrument, where SR-2 is the observation that the plan's
after-census line does not mention the drift. If the L1 prefers to merge them, M70-4's
check and the SR-2 measurement should travel together.

**Verification of the two routed counts (both measured by this seat, commands and output
below).** The routed counts are both confirmed as miscounts, and the mechanisms differ.

---

## M70-2 — a report count taken over the wrong column of the ledger it cites

- **class**: `record` (calibration of a published count)
- **evidence**: The fleet report `.ufo/reports/round-69/kagi.md:65` reads
  "`.ufo/waves/round-69/claim-falsification.tsv`: 13 rows, … eight `falsifies-wording`
  rows all point to the honest stop in `plans/round-69.md`; two `falsifies-number`
  rows are the L1's own final readings." The cited ledger's column 3 holds **six**
  `falsifies-wording` rows, not eight; its thirteen data rows are 6
  `falsifies-wording` + 2 `falsifies-number` + 5 `neutral`.

  The number "eight" is not a reading of any column: it is
  `falsifies-wording (6) + falsifies-number (2)` — the count of the *falsifying* rows
  (every non-`neutral` row), labelled with the `falsifies-wording` class name. The
  report's own sentence names both classes and still sums to eight, so the reader
  cannot tell which eight were counted. The report's "13 rows" is right; the class
  split is wrong.

  Commands and output (receipt:
  `.ufo/waves/round-70/w1/R70ScribeLesson/receipts-count-verification.txt`):

  ```
  $ awk -F'\t' '$1 !~ /^#/ && NF>0 {print $3}' .ufo/waves/round-69/claim-falsification.tsv | sort | uniq -c
        2 falsifies-number
        6 falsifies-wording
        5 neutral

  $ awk -F'\t' '$1 !~ /^#/ && NF>0 && $3=="falsifies-wording"' .ufo/waves/round-69/claim-falsification.tsv | wc -l
  6

  $ git show 7bd34832c94b81d4cf9bf34113c4952a7f6d9b04:.ufo/waves/round-69/claim-falsification.tsv \
      | awk -F'\t' '$1 !~ /^#/ && NF>0 {print $3}' | sort | uniq -c     # the committed bytes at BASE
        2 falsifies-number
        6 falsifies-wording
        5 neutral
  ```

  The routed defect (`corpus/lessons/round-69-verifier-spotcheck.md:138`) says only
  "has six"; the class-mislabelling mechanism above is this seat's own measurement and
  is why the fix is a per-class command rather than a corrected numeral.
- **captured-by**: `none` on the count itself. QM62 (`corpus/QUALITY.md`) binds a
  count of *verdict lines* a report states to "a stated command over the receipt it
  cites"; the report cites the ledger but states no command, and the count it states
  is over a class the ledger's own column distinguishes — so QM62's shape
  ("`grep -c '^FAIL' <receipt>`") would have produced the correct six, had it been
  followed. QM62 covers *verdict lines*; a **per-class row count of a ledger** is
  outside its population, and QA6 ("A count carries its command") names the
  obligation without a check that can fail.
- **fix**: every per-class count a report states is produced by a named command over
  the committed ledger, one command per class, with the class token in the needle:
  `awk -F'\t' '$3=="falsifies-wording"' <ledger> | wc -l`. The classes a report
  states must also sum to the row total it states — a per-class split that does not
  account for every row is a defect, not a rounding.
- **shown able to fail**: `.ufo/waves/round-70/w1/R70ScribeLesson/check-report-counts.py`
  (receipt `receipts-check-report-counts.txt`):

  ```
  $ python3 check-report-counts.py /home/vgpnk/Projects/shokunin/.ufo/reports/round-69/kagi.md \
      .ufo/waves/round-69/claim-falsification.tsv
    MEASURED rows=13 falsifies-wording=6 falsifies-number=2 neutral=5
    STATED   rows=13 falsifies-wording=8 falsifies-number=2 neutral=None
    IMPLIED   unstated-classes=3 (measured neutral=5)
  MISMATCH falsifies-wording stated=8 measured=6
  MISMATCH implied-neutral=3 measured-neutral=5
  REPORT_COUNTS: FAIL (2 mismatch(es))            rc=1
  ```

  On the corrected wording (control `controls/corrected-report-snippet.md`, "six
  `falsifies-wording` rows") it reads `REPORT_COUNTS: CLEAN` rc=0. The check also
  reads the *population*, not the receipt name: the same wrong count with the ids
  relabelled still reads FAIL.

---

## M70-3 — a census-warning count read off the tail of a receipt instead of over its population

- **class**: `record` (calibration of a published count)
- **evidence**: The fleet report `.ufo/reports/round-69/kagi.md:97` reads
  "→ `kagi ok`, exit 0 (two pre-existing W04 warnings on S156/S164)
  (`.ufo/waves/round-69/final/census-round-end.txt`)". The cited receipt holds **25**
  `W04` lines, `S019` through `S164`; `S156` and `S164` are its **last two rows**.
  The "two" is the tail of the file read as the whole population, and the two ids
  named are the last two ids in it — a tail-read, not a count.

  The routed defect (`corpus/lessons/round-69-verifier-spotcheck.md:140`) also
  records that the round-start receipt `base/census-round-start.txt` captured stdout
  only. This seat confirms the stream and adds the tail mechanism:

  ```
  $ grep -c 'W04' .ufo/waves/round-69/final/census-round-end.txt
  25
  $ grep -n 'W04' .ufo/waves/round-69/final/census-round-end.txt | tail -3
  24:kagi	W04	S155 duplicate url eutils.ncbi.nlm.nih.gov/... across scopes
  25:kagi	W04	S156 duplicate url www.ncbi.nlm.nih.gov/.../PMC2757457/unicode across scopes
  26:kagi	W04	S164 duplicate url www.ncbi.nlm.nih.gov/.../PMC2757457/unicode across scopes
  ```

  And, measured this round, **the W04 lines are on stdout**; stderr is empty and the
  census exit is 0 (`.ufo/waves/round-70/base/census-round-start.stdout.txt` = 25
  `W04` lines, `.stderr.txt` = 0 bytes, `.rc` = `rc=0`). The round-69 round-start
  receipt was 77 bytes and held only the `kagi ok` line and `EXIT=0` — the W04
  population was never captured at round start, which is why the "pre-existing"
  adjective had no baseline to stand on.
- **captured-by**: `none`. QM62 again covers the *form* ("a stated command over the
  receipt it cites") but the receipt the report cites is a receipt whose population
  it did not count; QM46 covers diff-stat sentences re-derived by `git diff
  --numstat` — a different sentence shape. QA6's "A count carries its command" is
  the only obligation in force, and it carries no mechanism that would have produced
  "25" instead of "two".
- **fix**: a census-warning count is stated with the command that produced it
  (`grep -c 'W04' <receipt>`) and the receipt's own stdout is the receipt; where the
  receipt was captured with stdout and stderr separated, the count is taken from the
  stdout file. A count that names ids must name the population's span (e.g.
  "S019…S164"), and a count whose named ids are the last *n* rows of a longer
  population is a tail-read and fails.
- **shown able to fail**: `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04.py`
  (receipt `receipts-check-census-w04.txt`):

  ```
  $ python3 check-census-w04.py /home/vgpnk/Projects/shokunin/.ufo/reports/round-69/kagi.md \
      .ufo/waves/round-69/final/census-round-end.txt
    MEASURED W04 lines=25
    STATED   count=2 named_ids=['S156', 'S164']
  MISMATCH W04 stated=2 measured=25
  MISMATCH tail-read named_ids=['S156', 'S164'] are the LAST 2 of 25 W04 rows (population not counted)
  CENSUS_W04: FAIL                              rc=1
  ```

  On the corrected wording ("25 pre-existing W04 warnings on S019…S164") it reads
  `CENSUS_W04: CLEAN` rc=0. A third control — the same wrong count with the ids
  relabelled to `S019/S020` — still reads FAIL, so the check reads the population and
  not the receipt's name or the id spelling.

---

## M70-4 — a census-warning count carried from the round-start receipt into a report that names a later revision

- **class**: `record` (revision binding of a published count)
- **evidence**: The round-70 base census receipt
  `.ufo/waves/round-70/base/census-round-start.stdout.txt` holds 25 `W04` lines.
  The **candidate** revision `0d225553c22f686df24454040102d0502eda5c42` holds **26**:
  the round's own new row S170 re-uses the URL already registered as S105
  (`https://openbao.org/docs/api/secret/pki/`), so the census adds a 26th
  cross-scope duplicate-url warning naming S170.

  ```
  $ grep -c 'W04' .ufo/waves/round-70/base/census-round-start.stdout.txt     # round start
  25
  # census re-run over the CANDIDATE tree (git archive -> scratch -> sources-census.sh validate):
    MEASURED W04 lines=26
    BASE     W04 lines=25
    ADDED    ids=['S170']
  CENSUS_DRIFT: FAIL (base=25 rev=26 added=['S170'] removed=[])
  ```

  Note that this does **not** make the census red: the census verdict line reads
  `kagi ok` and the exit is 0 in both receipts — `W04` is a warning that does not
  affect a clean lane (`scripts/sources-census.sh:33`). So a report can state a
  "pre-existing warnings" count that is silently one short of the tree it names,
  with every gate green. (Independently: S170's capture body is **byte-identical** to
  the lane's existing S105 capture — both `sha256 9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123`,
  620683 B — so the round re-opened a body the lane already held. That is a
  registry-hygiene observation for the L1 and the registry seat, not this seat's
  claim; this seat reports it as measured.)
- **captured-by**: `none`. QM60 binds a *stated evidence reading* in the lane's own
  capability table to a re-executed command and requires revision-bound counts to
  "be stated with the revision they hold at"; the fleet report's census sentence
  carries no revision at all, and QM60's population is the capability table, not the
  report's census line. QM21 binds current-tense numbers about the lane's *own*
  artifacts to `corpus/self-counts.tsv` — the census-warning population is a
  cross-lane reading, outside that file.
- **fix**: a count of census warnings is stated with the revision it holds at, and
  the revision is the one the report's before/after table names; a count taken from
  the round-start receipt is a *round-start* reading and may not be presented as the
  landed reading when the round's own rows move the population.
- **shown able to fail**: `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04-drift.py`
  (receipt `receipts-check-census-w04-drift.txt`). It extracts the lane tree at a
  named revision (`git archive`), re-runs the census against that scratch root, and
  compares the `W04` population with the receipt's:

  ```
  ## A) CONTROL: the round-70 base receipt against the BASE revision it was taken at
    MEASURED W04 lines=25   BASE W04 lines=25
  CENSUS_DRIFT: CLEAN                                rc=0

  ## B) the same receipt against the CANDIDATE revision 0d225553
    MEASURED W04 lines=26   BASE W04 lines=25
    ADDED    ids=['S170']
  CENSUS_DRIFT: FAIL (base=25 rev=26 added=['S170'] removed=[])   rc=1
  ```

  The control is the important half: the same receipt reads CLEAN against the
  revision it was taken at and FAIL against the revision the report names. The
  instrument therefore discriminates drift from a stale-receipt mistake.

---

## QUALITY.md criterion candidate (text only — for the L1 to land or reject)

> **QM101** — A count a report states about another round's or its own committed
> evidence is bound to a **named command over committed bytes**, and the command's
> **population** is the population the sentence names. A per-class row count names
> the class in its needle (`awk -F'\t' '$3=="<class>"' <file> | wc -l`) and the
> classes a report states sum to the row total it states; a count of warning or
> verdict lines in a receipt names the receipt's file and the count's own span
> (`S019…S164`), never a tail of it; and a count whose population can move with the
> round's own rows is stated with the **revision it holds at**, re-derived over that
> revision's tree rather than carried from an earlier receipt. A count with no
> command, a count whose needle selects a different population than the sentence
> names, and a count of a receipt's last *n* rows presented as the receipt's
> population all fail.
>
> *weak-material signal*: "eight `falsifies-wording` rows" against a ledger whose
> column 3 holds six (the number is the falsifying total, 6 + 2, under the wrong
> class name); "two pre-existing W04 warnings on S156/S164" against a receipt holding
> 25 `W04` lines whose last two rows are S156 and S164; a round-start census
> receipt's warning count presented as the landed revision's.
>
> *lesson*: `corpus/lessons/round-70.md` §Mistakes M70-2, M70-3, M70-4; checks able
> to fail: `.ufo/waves/round-70/w1/R70ScribeLesson/check-report-counts.py`,
> `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04.py`,
> `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04-drift.py` (receipts
> `receipts-check-report-counts.txt`, `receipts-check-census-w04.txt`,
> `receipts-check-census-w04-drift.txt`).

### Why QM101 and not QM62 alone

QM62 already requires "a stated command over the receipt it cites" for verdict-line
counts. It does not reach these three defects because (a) its population is *verdict
lines*, not the **per-class row count of a ledger** (M70-2), (b) it does not require
the needle's population to be the population the sentence names, so a tail-read
passes (M70-3), and (c) it binds a count to a receipt, not to the **revision the
report names**, so a receipt whose population moves with the round's own rows can be
carried forward stale (M70-4). QM101 adds the class-scoped needle, the
population-identity rule, the tail-read rule and the revision binding. It is
additive to QM62 and QM60, and it does not restate QA6 (which names the obligation
without a check that can fail).

---

## Artifacts this seat produced

| path | what |
|---|---|
| `.ufo/waves/round-70/w1/R70ScribeLesson/check-report-counts.py` | M70-2 check: per-class ledger counts vs the report's stated counts, + class-sum check |
| `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04.py` | M70-3 check: receipt population vs the report's stated W04 count, + tail-read and population-identity rules |
| `.ufo/waves/round-70/w1/R70ScribeLesson/check-census-w04-drift.py` | M70-4 check: census re-run over a named revision's tree vs a receipt's W04 population |
| `.ufo/waves/round-70/w1/R70ScribeLesson/receipts-count-verification.txt` | the two routed counts, measured (V1 falsifies-wording, V2 W04, V3 stream) |
| `.ufo/waves/round-70/w1/R70ScribeLesson/receipts-check-report-counts.txt` | M70-2: FAIL on the filed report, CLEAN on the corrected wording |
| `.ufo/waves/round-70/w1/R70ScribeLesson/receipts-check-census-w04.txt` | M70-3: FAIL on the filed report, CLEAN on the corrected wording, FAIL on the relabelled control |
| `.ufo/waves/round-70/w1/R70ScribeLesson/receipts-check-census-w04-drift.txt` | M70-4: CLEAN at BASE, FAIL at the candidate (S170 adds the 26th row) |
| `.ufo/waves/round-70/w1/R70ScribeLesson/controls/corrected-report-snippet.md` | the corrected wording (the CLEAN control for M70-2/M70-3) |
| `.ufo/waves/round-70/w1/R70ScribeLesson/controls/relabelled-report.md` | wrong count, ids relabelled (the FAIL control: the check reads the population, not the ids) |
| `.ufo/waves/round-70/w1/R70ScribeLesson/mistakes-draft.md` | this draft |

No lane file outside this seat's directory was written; no product code, counter,
plan, lesson, registry or SCORECARD file was edited; no git or jj mutation was run
(read-only `git log`/`show`/`archive`/`ls-tree`/`cat-file` only).

## Limits of this seat's measurement (named, not covered)

- The two routed defects are measured against the **fleet repo's** committed report
  (`.ufo/reports/round-69/kagi.md`, committed) and the **lane's** committed ledger
  and receipts. The round-70 report does not exist yet, so this seat cannot say
  whether the L1's round-70 report repeats the round-69 numbers — the draft's
  fixes and checks are what the L1 must run against its own report before filing.
- M70-4 measures the census-warning **population** drift only. Whether S170 should
  have been a new registry row at all (the body is byte-identical to the lane's
  existing S105 capture) is a registry question for the L1 and the registry seat;
  this seat reports the measurement and does not claim a verdict.
- `check-census-w04-drift.py` re-runs the fleet census against an extracted lane
  tree; it therefore measures the **lane's** `W04` rows in isolation. Cross-lane
  `W04` scope interactions are read from the real fleet-root census run, whose
  receipt this seat also holds (25 rows at round start). The drift check's own
  control at BASE reproduces 25, which is the population the round-start receipt
  records.

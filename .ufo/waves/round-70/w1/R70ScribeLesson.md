Author: R70ScribeLesson (scribe — round-70 lesson `## Mistakes` draft)

# Round 70 — kagi — seat R70ScribeLesson

Seat: draft the round-70 lesson's `## Mistakes` section from the lane's own record (the L1
integrates). Lane `kagi-shokunin`, branch master. No claim of mine; no axis move claimed.

## What I did

Drafted three mistake entries from the lane's own record and one `corpus/QUALITY.md`
criterion candidate, and built a committed instrument for each entry that is **shown able
to fail** (a FAIL on the wrong statement, a CLEAN on the corrected statement, and where
the defect is subtle a second control that stays red).

Draft: `.ufo/waves/round-70/w1/R70ScribeLesson/mistakes-draft.md`.
Criterion candidate: QM101 text, in that draft, §"QUALITY.md criterion candidate".

## The two routed counts, verified

Both routed defects (round-69 spot-check §5 items 1–2) confirmed as miscounts. Commands,
outputs and receipts are in `.ufo/waves/round-70/w1/R70ScribeLesson/receipts-count-verification.txt`.

### 1. `falsifies-wording` rows: the report says eight, the ledger holds six

```
$ awk -F'\t' '$1 !~ /^#/ && NF>0 {print $3}' .ufo/waves/round-69/claim-falsification.tsv | sort | uniq -c
      2 falsifies-number
      6 falsifies-wording
      5 neutral
```

Committed bytes at BASE (`git show 7bd34832c94b81d4cf9bf34113c4952a7f6d9b04:.ufo/waves/round-69/claim-falsification.tsv`)
read the same 6/2/5. The report sentence is `.ufo/reports/round-69/kagi.md:65` (fleet repo,
committed): "eight `falsifies-wording` rows".

**Mechanism (my measurement, beyond the routed "has six").** Eight is not a reading of any
one column: it is `falsifies-wording (6) + falsifies-number (2)` — the count of every
*falsifying* (non-`neutral`) row — labelled with the `falsifies-wording` class name. The
report names both classes in the same sentence and still sums to eight, so the reader
cannot tell which eight were counted. Its "13 rows" is right; its class split is wrong.

### 2. Census W04 warnings: the report says two, the receipt holds 25

```
$ grep -c 'W04' .ufo/waves/round-69/final/census-round-end.txt
25
$ grep -n 'W04' .ufo/waves/round-69/final/census-round-end.txt | tail -3
24:kagi	W04	S155 duplicate url eutils.ncbi.nlm.nih.gov/... across scopes
25:kagi	W04	S156 duplicate url www.ncbi.nlm.nih.gov/.../PMC2757457/unicode across scopes
26:kagi	W04	S164 duplicate url www.ncbi.nlm.nih.gov/.../PMC2757457/unicode across scopes
```

Report sentence: `.ufo/reports/round-69/kagi.md:97` — "(two pre-existing W04 warnings on
S156/S164)".

**Mechanism (my measurement).** S156 and S164 are the **last two rows of the file**. The
"two" is a tail-read of the receipt, not a count of its population.

**Stream confirmed (this round).** The W04 lines go to **stdout**; stderr is empty and the
exit is 0: `.ufo/waves/round-70/base/census-round-start.stdout.txt` = 25 `W04` lines,
`.stderr.txt` = 0 bytes, `.rc` = `rc=0`. The round-69 round-start receipt was 77 bytes /
2 lines (the `kagi ok` line and `EXIT=0`) — the W04 population was never captured at round
start, so the report's "pre-existing" had no baseline to stand on.

### 3. A third defect I found in the lane's own record (not routed)

The round-70 base receipt holds 25 W04 lines; the **candidate** revision `0d225553` holds
**26** — the round's own new row S170 re-uses the URL already registered as S105
(`https://openbao.org/docs/api/secret/pki/`), so the census adds a 26th cross-scope
duplicate-url warning naming S170:

```
kagi	W04	S170 duplicate url openbao.org/docs/api/secret/pki across scopes
```

This does **not** make the census red — the verdict line reads `kagi ok`, exit 0, in both
receipts (`W04` is a warning that does not affect a clean lane,
`scripts/sources-census.sh:33`). So a report can state a "pre-existing warnings" count one
short of the tree it names, with every gate green.

Separately measured and reported for the L1/registry seat, not claimed as mine: S170's
capture body is **byte-identical** to the lane's existing S105 capture
(`.ufo/waves/round-49/capture/S105.body` vs `.ufo/waves/round-70/capture/S170.body`, both
`sha256 9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123`, 620683 B). The
round re-opened a body the lane already held. Whether S170 should have been a new registry
row at all is a registry question for the L1 and the registry seat; this seat reports the
measurement only.

## Instruments (each shown able to fail)

| entry | instrument | FAIL on | CLEAN on |
|---|---|---|---|
| M70-2 | `check-report-counts.py` | the filed round-69 report (`stated=8 measured=6`, plus the class-sum mismatch) — rc 1 | corrected wording ("six `falsifies-wording` rows") — rc 0 |
| M70-3 | `check-census-w04.py` | the filed round-69 report (`stated=2 measured=25`, plus the tail-read finding) — rc 1 | corrected wording ("25 … on S019…S164") — rc 0; a **second control** (same wrong count, ids relabelled to S019/S020) still FAILs, so the check reads the population, not the ids or the receipt's name |
| M70-4 | `check-census-w04-drift.py` | the round-70 base receipt against the candidate `0d225553` (`base=25 rev=26 added=['S170']`) — rc 1 | the same receipt against BASE `7bd34832` (`25 == 25`) — rc 0 |

The M70-3 control is the load-bearing half: the same receipt reads CLEAN at the revision
it was taken at and FAIL at the revision the report would name, so the instrument
discriminates population drift from a stale-receipt mistake.

Receipts: `receipts-check-report-counts.txt`, `receipts-check-census-w04.txt`,
`receipts-check-census-w04-drift.txt`, all under this seat's directory.

## QUALITY.md criterion candidate (text only)

**QM101** — A count a report states about another round's or its own committed evidence is
bound to a **named command over committed bytes**, and the command's **population** is the
population the sentence names. A per-class row count names the class in its needle
(`awk -F'\t' '$3=="<class>"' <file> | wc -l`) and the classes a report states sum to the row
total it states; a count of warning or verdict lines in a receipt names the receipt's file
and the count's own span (`S019…S164`), never a tail of it; and a count whose population
can move with the round's own rows is stated with the **revision it holds at**, re-derived
over that revision's tree rather than carried from an earlier receipt. A count with no
command, a count whose needle selects a different population than the sentence names, and a
count of a receipt's last *n* rows presented as the receipt's population all fail.

*Weak signal*: "eight `falsifies-wording` rows" against a ledger whose column 3 holds six
(the number is the falsifying total, 6 + 2, under the wrong class name); "two pre-existing
W04 warnings on S156/S164" against a receipt holding 25 `W04` lines whose last two rows are
S156 and S164; a round-start census receipt's warning count presented as the landed
revision's.

*Why not QM62 alone*: QM62 already requires "a stated command over the receipt it cites"
for verdict-line counts, but its population is *verdict lines* (not the per-class row count
of a ledger, M70-2), it does not require the needle's population to be the population the
sentence names (a tail-read passes, M70-3), and it binds a count to a receipt rather than
to the revision the report names (a receipt whose population moves with the round's own
rows can be carried forward stale, M70-4). QM101 is additive to QM62 and QM60 and does not
restate QA6.

**Numbering note for the L1**: the L1's plan Amendment A1 already reserves `M70-1` for the
S170/S105 registry finding (`plans/round-70.md:128`); this seat's entries are therefore
**M70-2, M70-3, M70-4**. M70-4 overlaps `R70ReviewerSrc` SR-2 (the 25→26 drift) — the
difference is that M70-4 is the count-binding rule with a shipped instrument, where SR-2 is
the observation that the plan's after-census line does not mention the drift. If the L1
merges them, M70-4's check should travel with SR-2's measurement.

## Touched surfaces (write scope)

Written, all under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70ScribeLesson/`:
`mistakes-draft.md`, `check-report-counts.py`, `check-census-w04.py`,
`check-census-w04-drift.py`, `receipts-count-verification.txt`,
`receipts-check-report-counts.txt`, `receipts-check-census-w04.txt`,
`receipts-check-census-w04-drift.txt`, `controls/corrected-report-snippet.md`,
`controls/relabelled-report.md`. Plus this report at
`.ufo/waves/round-70/w1/R70ScribeLesson.md`.

Nothing else in the lane, nothing in the fleet repo, no sibling lane, no `~/.omp`.
No product code, counter, plan, lesson, registry row or SCORECARD file was edited.
No git or jj mutation: read-only `git log`/`show`/`archive`/`ls-tree`/`ls-files`/
`cat-file` only; `git archive` writes into scratch, never into a repo. No `bao server`
was started by this seat. Scratch `/fast/scratch/hyaku/kagi-r70/R70ScribeLesson` removed
on exit.

## Out of scope / left to the L1

- The round-70 report does not exist yet, so I cannot say whether the L1's report repeats
  the round-69 numbers; the three checks are what the L1 must run against its own report
  before filing.
- The `corpus/lessons/round-70.md` file and the QM101 row are the L1's to land; I drafted
  text only and wrote nothing into `corpus/`.
- The S170-vs-S105 registry question (a new registry row over an already-held body) is
  routed to the L1 and the registry seat, not claimed here.

## Findings

FINDING SL-1 neutral the round-69 report's "eight `falsifies-wording` rows" is the falsifying total (6 wording + 2 number) under the wrong class name; the ledger's column 3 holds 6.
FINDING SL-2 neutral the round-69 report's "two pre-existing W04 warnings on S156/S164" is a tail-read of a 25-line W04 population; S156 and S164 are the receipt's last two rows.
FINDING SL-3 neutral the W04 census lines go to stdout with stderr empty and rc 0, so the round-69 round-start receipt (77 bytes, no W04 lines) left the "pre-existing" baseline unrecorded.
FINDING SL-4 neutral the candidate revision 0d225553 carries 26 W04 rows against the round-70 base receipt's 25; the census verdict stays "kagi ok" rc 0, so the drift is invisible to every green gate.
FINDING SL-5 neutral S170's capture body is byte-identical to the lane's existing S105 capture (same sha256, 620683 B); the new row re-uses a URL already registered and adds the 26th W04 row.
FINDING SL-6 neutral QM62 does not reach these defects — its population is verdict lines, it does not bind a needle's population to the sentence's, and it binds a count to a receipt rather than to the named revision.
FINDING SL-7 neutral each drafted mistake has a committed instrument that FAILs on the filed wording, CLEANs on the corrected wording, and (M70-3, M70-4) holds red under a second control.

SEAT-STATUS: complete the two routed counts are verified with commands and receipts, three mistake entries and one QM101 candidate are drafted, and each entry has an instrument shown able to fail

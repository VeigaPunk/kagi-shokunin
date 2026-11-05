# K38ScoutRelease — R37-V2 release-clock disposition, independently verified and extended

Seat: K38ScoutRelease (scout, wave `build`, kagi round 38 attempt 1).
Subject: the release-clock disposition (R37-V2) that `corpus/lessons/round-38.md` records.
Candidate commit under test: `b944735` (landed). Claim BASE `a916f4a`.
Verdict on the lesson's R37-V2 reasoning: **PARTLY SUPPORTED** (see §5).

Scope: read-only research. No lane file, git/jj state, sibling lane, or fleet-repo tracked file was
written. All mutations were made in scratch copies of the candidate tree. Scratch root
`/fast/scratch/hyaku/kagi-r38/K38ScoutRelease/` was removed on exit.

## 1. Method

Extraction (read-only git):

    cd /home/vgpnk/Projects/shokunin/kagi-shokunin
    git rev-parse --show-toplevel            -> /home/vgpnk/Projects/shokunin/kagi-shokunin
    git archive b944735 | tar -x -C $S/ext

`git archive` is a read-only operation; the working tree was never mutated. `git status --porcelain`
at the end shows only the orchestrator's own untracked `.ufo/waves/round-38/build*` entries — no tracked
lane file changed.

Every experiment below ran the gate in a **scratch copy** of the extracted tree, with `TMPDIR` and
`HYAKU_SCRATCH` pointed at the scratch root:

    python3 -I -B corpus/release-clock.py            # cwd = the scratch tree

Raw stdout+exit-code receipts: `receipts/00-baseline.txt`, `10-a-s027-feedonly.txt`,
`11-b-s027-feed+anchor.txt`, `12-c-repoint.txt` (+ `12-c-repoint-list.txt`),
`13-d-coupled-anchor.txt`, `14-e-coupled-verdict-stale-receipt.txt`, `15-f2-fresh-receipt.txt`.
Live re-observation receipts: `receipts/observe-live-coupled.json`, `receipts/observe-live-i.json`.

### Baseline at the candidate

    $ (in ext) python3 -I -B corpus/release-clock.py
    RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)
    EXIT=0

Identical to the committed `verify-base.txt` receipt (which reads the same line, `verify_rc=0`) and to
the line the lesson attributes to BASE. So BASE and the candidate agree on this instrument: the
release-clock table and `corpus/release-clock.py` are **unchanged** between `a916f4a` and `b944735`
(`git diff --stat a916f4a b944735 -- corpus/release-clocks.tsv corpus/release-clock.py` is empty; only
`corpus/SOURCES.md` differs, by the two new rows S092/S093). R37-V2 is therefore still open debt at the
candidate — the round did not land it, exactly as the lesson states.

## 2. Experiment table (exact outputs)

Legend: `S027 feed id only` = change `corpus/release-clocks.tsv` col 3 (`feed_source_id`) S036→S091,
everything else untouched. Counts are the number of lines of each typed finding printed by the gate.

| # | experiment | exit | stdout lines | DERIVATION | INCONSISTENT | RECEIPT-MISMATCH | last line |
|---|---|---|---|---|---|---|---|
| 0 | baseline (candidate `b944735`, unmodified) | 0 | 1 | 0 | 0 | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` |
| a | S027 `feed_source_id` S036→S091, `anchored_version` kept `3.15.0` | 0 | 1 | 0 | 0 | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` |
| b | (a) **plus** S027 `anchored_version` 3.15.0→3.15.2 | 1 | 2 | 0 | **1** | 0 | `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=14 derived=15)` |
| c | **all 15** rows whose `feed_source_id` ∈ {S034,S035,S036,S039} re-pointed to their superseding row (S034→S089, S035→S090, S036→S091, S039→S091), anchors kept | 1 | 11 | **10** | 0 | 0 | `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=20 fired=5 derived=5)` |

Experiment (c) printed exactly these ten finding lines, in this order:

    DERIVATION S013
    DERIVATION S014
    DERIVATION S015
    DERIVATION S016
    DERIVATION S021
    DERIVATION S022
    DERIVATION S023
    DERIVATION S024
    DERIVATION S025
    DERIVATION S026

Experiment (b) printed `INCONSISTENT S027` then the FAILED summary line.

**Experiment (c) reproduces the lesson's row exactly**: the lesson's table says the 15-row re-point
yields "the round-37 closure's 10 DERIVATION findings" and the round-37 lesson
(`corpus/lessons/round-37.md:108`) independently records "Re-pointing the feed ids alone breaks
`DERIVATION` (10 findings: the derived binding needs the anchored version)". My count is 10, and the
ids match the derived subset of the 15.

**Experiments (a) and (b) reproduce the lesson's table rows exactly**: (a) "still `CLEAN`, `fired=15`
(the feed row is not the verdict input for this row)"; (b) "`INCONSISTENT S027`; `RELEASE_CLOCK: FAILED
(… observed=29 fired=14 …)`". Both confirmed by exit code (0 and 1) and by the exact counts.

Mechanism (read from `corpus/release-clock.py`, `evaluate()`): for a `feed` row, `is_derived` is
`values["note"].startswith("derived:")` (line 615). When true, the row's `anchored_version` must equal
the *feed row's* anchor cell (`derived_anchor_bound`, line 349; `DERIVATION` at line 625) — the rule
applies only to derived anchors. When false, `anchor_ok` falls back to `version_is_named` against the
**clock row's own** registry anchor cell (line 616), which a feed-id swap does not touch. That is why
(a) is CLEAN: S027's note begins `original named Python 3.15.0 anchor retained`, not `derived:`, so
S027 is checked against its own SOURCES.md anchor cell (which names 3.15.0) and not against S091's.

## 3. The 15 feed-bound clock rows, derived / non-derived split

All 15 rows with `feed_source_id` ∈ {S034, S035, S036, S039}, from `corpus/release-clocks.tsv` at the
candidate. `derived` = the row's `note` begins with `derived:` (the only trigger for the DERIVATION
rule).

| id | feed_source_id | anchored_version | observed_version | verdict | note starts `derived:` | DERIVATION under (c)? |
|---|---|---|---|---|---|---|
| S012 | S034 | v1.21.x | 2.2.1 | fired | no | no |
| S013 | S034 | 2.2.0 | 2.2.1 | fired | **yes** | **yes** |
| S014 | S035 | 2.7.1 | 2.7.2 | fired | **yes** | **yes** |
| S015 | S035 | 2.7.1 | 2.7.2 | fired | **yes** | **yes** |
| S016 | S035 | 2.7.1 | 2.7.2 | fired | **yes** | **yes** |
| S021 | S035 | 2.7.1 | 2.7.2 | fired | **yes** | **yes** |
| S022 | S034 | 2.2.0 | 2.2.1 | fired | **yes** | **yes** |
| S023 | S034 | 2.2.0 | 2.2.1 | fired | **yes** | **yes** |
| S024 | S034 | 2.2.0 | 2.2.1 | fired | **yes** | **yes** |
| S025 | S035 | 2.7.1 | 2.7.2 | fired | **yes** | **yes** |
| S026 | S035 | 2.7.1 | 2.7.2 | fired | **yes** | **yes** |
| S027 | S036 | 3.15.0 | 3.15.2 | fired | no | no |
| S028 | S036 | 3.15.0 | 3.15.2 | fired | no | no |
| S040 | S039 | 3.15.1 | 3.15.2 | fired | no | no |
| S041 | S039 | 3.15.1 | 3.15.2 | fired | no | no |

**Counts: 10 derived, 5 non-derived (S012, S027, S028, S040, S041).** All 15 verdicts are `fired`;
all 15 rows are bound (`bound=30`, `unbound=0`).

The mapping between the two columns is exact: the 10 DERIVATION findings in (c) are precisely the 10
`derived:` rows, and the 5 non-derived rows produced no DERIVATION finding. The DERIVATION rule applies
only to derived anchors — confirmed both by code reading and by the exact id-for-id match.

Whole-table context: exactly 15 of the 30 rows carry a `derived:` note (the 10 above plus S008–S011
on S033 and S029 on S037), and 15 do not. The gate's `derived=15` counter at baseline is therefore a
coincidence of the count of derived rows among the 30, not the count of feed-bound derived rows.

## 4. Would any non-derived row be harmed by the feed-id-only re-point?

**No.** Under (c) the five non-derived rows (S012, S027, S028, S040, S041) produced no finding of any
kind — the only findings were the 10 DERIVATION lines. Their verdicts stay `fired`, they stay `observed`,
and their anchors stay bound to their own registry anchor cells.

The reason is structural, and it is the useful part of the disposition: a feed-id swap changes the
row's *feed*, but a non-derived row's `anchored_version` is validated against the **clock row's own**
SOURCES.md anchor cell, not against the feed's. So a non-derived row is inert to the re-point. The
harm lands only on derived rows, whose anchors are *defined* by the feed row's anchor cell.

Two boundary notes, both measured:

- The non-derived rows are inert to the re-point, but they are **not** inert to the *anchor* edit.
  Re-pointing S027/S028/S040/S041 to S091 and setting their `anchored_version` to 3.15.2 (the value
  S091's anchor cell names) makes their own registry anchor cells stale, and the gate then reports
  `INCONSISTENT S027`, `INCONSISTENT S028`, `INCONSISTENT S040`, `INCONSISTENT S041` (experiment (h),
  below). This is why the re-point is a *coupled* change and not a one-cell edit: the non-derived rows
  require their SOURCES.md anchor cells updated too.
- S012 is the one row that is inert in a stronger sense: its anchor `v1.21.x` is a non-numeric series
  anchor, so `numeric_version()` returns None and it never enters the numeric floor/ordering logic.
  It stayed `fired` in every variant I ran.

## 5. Verdict on the lesson's R37-V2 reasoning: PARTLY SUPPORTED

The claim under test (plan `plans/round-38.md:23-26`): *"a re-point to S089–S091 changes the clock's
anchor and verdict (a fired clock would stop firing)"*, and the lesson's table row: *"S027 feed id only
→ S091 (anchor kept 3.15.0) … still `CLEAN`, `fired=15` (the feed row is not the verdict input for this
row)"*.

**Supported, exactly as measured:**

- The feed-id-only re-point of the 15 rows produces **10 DERIVATION findings and FAILED** (c). The
  lesson's and the round-37 lesson's "10 DERIVATION findings" figure is confirmed id-for-id.
- The single-row S027 feed-id-only re-point leaves the gate **CLEAN, fired=15, exit 0** (a). The
  parenthetical "the feed row is not the verdict input for this row" is exactly right for a non-derived
  row, and the reason is the code path in §2.
- Changing S027's anchor as well gives `INCONSISTENT S027` and `observed=29 fired=14` (b), i.e. the
  "silently un-fires a fired clock (15 → 14)" reading of the lesson. The clock is *not* silently
  un-fired in the sense of a silent verdict flip: the gate names the row and exits 1. The fired count
  drops because the row is excluded from `observed`, not because it re-reads as `not-fired`.
- The disposition — R37-V2 **not claimed and not re-pointed**, on the grounds that neither re-point is
  a freshness move — is sound and is confirmed by the measurements above.

**Where the sentence overreaches — the reason for PARTLY, not full, SUPPORTED:**

The plan's sentence says a re-point *"changes the clock's anchor and verdict (a fired clock would stop
firing)"*. Measured, a feed-id-only re-point changes **neither** the anchor nor the verdict column of
any row: the anchor and verdict cells of all 15 rows are byte-identical before and after (c), and the
five non-derived rows are untouched in every respect. What the re-point changes is the *relationship*
between a derived row's anchor and its feed's anchor cell, and the gate's response is a typed
`DERIVATION` finding — an error, not a re-verdict. The clock stops firing only in the sense that it
stops being counted as fired, and only because it becomes invalid (10 of 15 rows drop out of
`observed`: 30→20, fired 15→5).

So the parenthesis "a fired clock would stop firing" is true *of the coupled change* (the anchor edit
plus the verdict edit plus a fresh receipt), not of the bare feed-id re-point. My extension experiments
separate the two and show the coupled change does land the gate CLEAN with the fired clocks re-read as
`not-fired` — but only with a fresh receipt and, for the four non-derived Python rows, updated
SOURCES.md anchor cells. Nothing in the lesson records that coupling; the lesson records only the
single-row (a)/(b) experiments plus the derived-binding reason.

**Supporting extensions** (each measured; none in the lesson):

| # | extension | exit | counts | last line |
|---|---|---|---|---|
| d | (c) + the 10 derived rows' `anchored_version` set to the new feed's version (2.2.1 / 2.7.2), verdict left `fired` | 1 | INCONSISTENT 10 | `RELEASE_CLOCK: FAILED (… observed=20 fired=5 derived=5)` |
| e | (d) + those 10 rows' verdict set to `not-fired`, **stale** pinned receipt | 1 | RECEIPT-MISMATCH 10 | `RELEASE_CLOCK: FAILED (… observed=20 fired=5 derived=5)` |
| f2 | same tree as (e) but with a **fresh** receipt (the round-36 receipt re-stamped `not-fired` for the 10 rows) | 0 | none | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=5 derived=15)` |
| g | (e) + `observed_at` → 2026-11-05 on all 30 rows + a **live** re-observed receipt | 0 | none | `RELEASE_CLOCK: CLEAN (… observed=30 fired=5 derived=15)` |
| h | all 15 re-pointed, **including** the 4 non-derived Python rows' anchors → 3.15.2, `observed_at` → 2026-11-05, live receipt | 1 | INCONSISTENT 4 (S027, S028, S040, S041) + RECEIPT-MISMATCH 30 | `RELEASE_CLOCK: FAILED (… observed=0 fired=0 derived=0)` |
| i | (h) **plus** the four non-derived rows' SOURCES.md anchor cells updated to name 3.15.2, live receipt | 0 | none | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=1 derived=15)` |

Reading of the extensions: (d) shows that moving the anchor alone is not enough (a `fired` verdict whose
observed version equals the new anchor is INCONSISTENT — the gate demands `not-fired` when
observed == anchored); (e) shows the coupled change is receipt-bound; (f2)/(g) show that with a fresh
receipt the coupled change is CLEAN with `fired=5` — the fired clocks do stop firing, exactly as the
plan's parenthesis claims, but only via the coupled path; (h) shows the four non-derived Python rows
block the coupled change until their registry anchor cells are updated; (i) shows the whole coupled
change does land CLEAN once SOURCES.md is included — at `fired=1` (S012 alone still fires).

Experiment (i) is the honest form of "a fired clock would stop firing": in a fully coupled re-point
with a live re-observation, `fired` goes 15 → 1 and `derived` stays 15. It is a table-wide, registry-wide,
receipt-wide change — not a one-cell edit — which is why the lane's disposition of not claiming it in
round 38 is defensible.

## 6. Independent corroboration of the round-38 live-re-observation receipt

The lesson cites `.ufo/waves/round-38/controls/observe-r38.json` ("30 records, failed=0") and states
"30 of 30 records carry the same `parsed_version`, `verdict` and `located` flag as the pinned round-36
receipt". I re-checked this against the committed files:

- `observe-r38.json` sha256 = `213ee154c7b99e507f57bcdc6d9be66a6bf1c1cfb3d1a6156b477b2082b2c24e`,
  30 observations; `fired` count 15; all records dated `2026-11-05`.
- Against the pinned round-36 receipt: **same `parsed_version` 30/30, same `verdict` 30/30, same
  `located` 30/30, zero differing records**. The lesson's claim is confirmed exactly.
- The pinned round-36 receipt's own sha256 (`3f611eec…`) equals `DEFAULT_RECEIPT_SHA256` in
  `corpus/release-clock.py`, so the default pin is intact.
- **One caveat the lesson does not record:** the committed `observe-r38.stdout` shows that running the
  gate against `observe-r38.json` itself (as `--receipt`, with its digest) produces **30
  `RECEIPT-MISMATCH` lines and `RELEASE_CLOCK: FAILED (… observed=0 fired=0 derived=0)`, exit 1** —
  the same 30-line failure the lesson's own observe stdout already shows. The reason is mechanical:
  `receipt_matches` compares `receipt_date(receipt.observed_at)` to the row's `observed_at`, and the
  new receipt is dated 2026-11-05 while the table rows still say 2026-11-04. The new receipt is
  therefore *not* a drop-in replacement for the pinned one without also updating `observed_at` on all
  30 rows — which is exactly the coupling (i) above demonstrates. The lesson correctly calls the new
  receipt "evidence, not a new pin"; this check shows the coupling is one step larger than the lesson
  states (an `observed_at` column edit is required too, and the lesson's own §Gate table does not
  mention it).

Live re-observation I performed myself (network available on this host):

- `curl -fsSL --compressed` of the three feeds: vault atom sha256
  `3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce` (= the round-36 receipt's S012
  digest, unchanged), openbao atom `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e`,
  python RSS `9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e`. All three equal the
  round-37 capture digests recorded in the lesson.
- Parsed with the lane's own extractor (`corpus/release-clock.py:parse_latest_version`): vault newest
  stable **2.2.1**, openbao **2.7.2**, python **3.15.2** — i.e. the values S089/S090/S091 name, and
  strictly newer than the S034/S035/S036/S039 values (2.2.0 / 2.7.1 / 3.15.0 / 3.15.1) the clocks are
  still pinned to. The supersession the re-point assumes is real and current.
- Live `--observe` on the coupled tree wrote 30 observations with `failed=0`.

## 7. Findings summary

1. The lesson's three recorded experiments are **reproduced exactly**: baseline CLEAN/fired=15; (a)
   S027 feed-id-only CLEAN/fired=15/exit 0; (b) `INCONSISTENT S027` + FAILED observed=29 fired=14;
   and the 15-row re-point's **10 DERIVATION findings**, matching the round-37 closure's figure id for
   id. The lesson's derived/non-derived mechanism (DERIVATION applies only to `derived:` rows) is
   confirmed by code reading and by the exact 10-row match.
2. The disposition **not to re-point in round 38** is sound: a re-point is not a freshness move, and it
   is a coupled change spanning `corpus/release-clocks.tsv`, `corpus/SOURCES.md` (4 non-derived rows'
   anchor cells), `observed_at` (all 30 rows) and a fresh receipt.
3. The plan's sentence *"a re-point to S089–S091 changes the clock's anchor and verdict (a fired clock
   would stop firing)"* is **PARTLY SUPPORTED**: a feed-id-only re-point changes neither the anchor nor
   the verdict cell — it produces typed `DERIVATION` findings, and only the 10 derived rows are
   affected at all. The "fired clock stops firing" behaviour is real, but belongs to the *coupled*
   change with a fresh receipt (measured: `fired` 15 → 1, CLEAN), which the lesson does not record.
4. **New, unreported by the lesson:** the coupled change also needs the four non-derived Python rows'
   SOURCES.md anchor cells updated (experiment h → i), and `observed_at` on all 30 rows (experiment
   g). The lesson's "coupled change" framing names the table and the receipt but not the registry
   column nor the date column. The round-37 closure's R37-V2 wording ("as one coupled change with the
   receipt re-observation in a full tree") is the more complete of the two descriptions; the round-38
   lesson's table does not name the registry/date edits.
5. **New:** the committed round-38 receipt `observe-r38.json` does **not** validate against the current
   table (30 RECEIPT-MISMATCH, FAILED, exit 1) because of the `observed_at` date, which the lesson does
   not state. This is harmless under the lesson's own framing ("evidence, not a new pin") but should
   not be mistaken for a usable receipt.
6. `fired=15` in the gate summary counts rows whose verdict is `fired` and observed ≠ anchored; the
   `derived=15` counter counts rows with a `derived:` note among the valid rows — a coincidence of the
   30-row table, not a semantic equality with "the 10 derived feed-bound rows".

## 8. Reproducibility notes

- No tool was installed or upgraded for this seat (nothing in the task required one).
- All commands were `git archive` (read-only), `git log`/`git diff`/`git rev-parse`/`git status`
  (read-only), `curl -fsSL --compressed` (read-only fetches to scratch), and
  `python3 -I -B corpus/release-clock.py` in scratch copies.
- Scratch root `/fast/scratch/hyaku/kagi-r38/K38ScoutRelease/` was deleted on exit
  (`trap 'rm -rf -- "$S"' EXIT`); the receipts needed for this report were copied into
  `.ufo/waves/round-38/build/K38ScoutRelease/receipts/` first.
- The lane's working tree was not modified; `git status --porcelain` shows only the orchestrator's
  untracked `.ufo/waves/round-38/build*` entries.

## 9. Remaining unknowns

- Whether a lane-authorised coupled change is intended for round 39, and whether the four non-derived
  Python rows' SOURCES.md anchor cells and the `observed_at` column are in scope for it, is a lane
  decision this seat does not make.
- I did not attempt the R37-V4 anchor-immutability amendment (round-39 routing) or the `2.2.10`
  boundary control (mutant M5); out of this seat's scope.
- Whether the round-38 receipt's `observed_at` mismatch is intended to be fixed by a future re-pin or
  by leaving the pinned round-36 receipt as the only usable one is not stated in the lesson.

# FinalHistory — residual attack: historical evidence preservation and migration causality

Seat: `KagiR26.FinalHistory` (critic, lane-authored advice; not non-author closure).
BASE `1bf3eec48d3761580ffd375c88143232485ae814`; candidate `d30c9892a7377b8b5a51817d1db8b81eaddcc397`.
All reads used `git show <rev>:<path>` / `git diff`/`git rev-parse` against the two commits. No build, test,
lint, formatter, or gate script was executed. No production, index or jj writes. No tool installs.

## Verdict

No history rewrite found. The round-25 receipt, round-25 lesson and every round-25 wave file are
byte-identical between BASE and candidate. Every changed ledger row, table row, default path/digest
is journaled old→new. One wording defect remains: candidate docs say the original round-25
receipt/code/tables are "separately replayable", but no named command replays the original receipt.
Severity is low and it is fixable by changing words; it is not a tradeoff the judge must reject.

## Observed checks (exact)

| # | Check | Observed result |
|---|---|---|
| H1 | `git diff --stat B C -- .ufo/waves/round-25 corpus/lessons/round-25.md` | empty (no change) |
| H2 | blob/sha256 of `.ufo/waves/round-25/observe-1.json` at B and C | both blob `09a7251f…`, sha256 `b74c8ee3…8b349f92` = BASE `DEFAULT_RECEIPT_SHA256` (B `corpus/release-clock.py:28`) |
| H3 | `.ufo/waves/round-26/frozen/observe-round25.json` | blob `09a7251f…`, identical to H2 |
| H4 | `frozen/release-clock.py` vs B `corpus/release-clock.py` | both blob `5436878f…` |
| H5 | `frozen/before/corpus/{SOURCES.md,release-clocks.tsv,rendered-text-v1.py,source-fetches.tsv}` vs B `corpus/*` | all four blobs identical (`48c355b5`, `35288f18`, `427ca0d6`, `a10a951f`) |
| H6 | `rearmed/release-clock.py`, `rearmed/after/corpus/*` vs C `corpus/*` | identical (`40c1ba12`, `394465ab`, `883b23e0`, `427ca0d6`, `e2c584db`); `rearmed/before/corpus/release-clocks.tsv` = B table `35288f18` |
| H7 | `rearmed/observe-2.json` vs `.ufo/waves/round-26/observe-2.json` | blob `e02f4dec…`, sha256 `13b8540c…2648a169` = C `DEFAULT_RECEIPT_SHA256` (C `corpus/release-clock.py:28`) |
| H8 | every line of `frozen/inputs.sha256` and `rearmed/inputs.sha256` recomputed from C blobs | 11/11 and 10/10 `OK`; manifest self-digests `cbb420c5…` / `2e476782…` equal the pins at `.ufo/waves/round-26/tools/replay-current.sh:13` / `:10` |
| H9 | `-` lines in `git diff -U0 B C` over LOG.md, SCORECARD.md, QUALITY.md, README.md, SKILL.md, SOURCES.md, source-fetches.tsv, lessons/ | LOG/SCORECARD/QUALITY/SOURCES/source-fetches/lessons are append-only. In-place edits are limited to SKILL.md:46, :48 and :787 (current-tense guidance) and README.md:65 and :184 |
| H10 | S027/S028/S036 rows in `corpus/SOURCES.md` B vs C | unchanged; S039–S041 appended at C `corpus/SOURCES.md:46-48` |
| H11 | each `ledger_rows.*.old` in `.ufo/waves/round-26/expectation-migrations.json` is a B ledger line, each `.new` a C line, and the changed-id set equals the journal keys | all 8 true; changed ids = {R12-03, R13-01, R21-02, R22-03, R24-05, R24-06, R24-15, R25-04} = journal keys |
| H12 | B→C `corpus/release-clocks.tsv` | only S027/S028 modified (observed 3.15.0→3.15.1, not-fired→fired, note replaced; anchor column stays 3.15.0) plus S040/S041 appended (C `corpus/release-clocks.tsv:24-25,30-31`) |
| H13 | receipt timestamps (S027/S028 observed_at) | round-25 `11:31:53Z` 3.15.0 not-fired; round-26 observe-1 `13:36:36Z` 3.15.1 fired; observe-2 `13:43:24Z` 3.15.1 fired, S040/S041 `13:43:27Z` not-fired. Order matches lesson `corpus/lessons/round-26.md:130-136` and `observe-run.json` / `observe-rearmed-run.json` |
| H14 | `git grep observe-round25` at C | referenced only by `frozen/inputs.sha256:10` and `frozen/expected.json:14` |
| H15 | files the BASE gate reads under `--root` (`rg 'root /'` on B code) | `corpus/SOURCES.md` (:59), `corpus/release-clocks.tsv` (:100), `corpus/source-fetches.tsv` (:135), `corpus/rendered-text-v1.py` (:594) plus the receipt; `--root` at :1559/:1583 |

Migration causality as observed:
1. BASE code against the BASE table took a new 28-record receipt, which failed on S027/S028 (`observe-run.json`).
2. The table and default were then migrated.
3. A third fetch produced the 30-record `observe-2.json`, which is CLEAN against the migrated table (`observe-rearmed-run.json`).
4. The default digest pins that receipt (H7).

Nothing in the record states a new observation earlier than the thing it depends on.

## Finding F1: "separately replayable" overstates what the snapshot can replay (low, fixable)

Counterexample. C `SCORECARD.md:1026` says "original round25 receipt/code/tables remain separately
replayable". C `corpus/lessons/round-26.md:137-139` says "keep its matching code/tables together in
the frozen replay". The only named replay is `replay-current.sh`, which has two receipt choices:
`observe-2.json`, or `observe-1.json` when that file is absent
(`.ufo/waves/round-26/tools/replay-current.sh:9-14`). With the frozen-root argument it therefore replays the
round-26 receipt `observe-1.json` against the BASE/rejected-draft tables. That is the "historical28-record drift
demonstration" (C `SKILL.md:807-809`, `corpus/README.md:211-212`) and it is expected to fail
(`frozen/expected.json:17-24`). It does not replay `observe-round25.json` (H14). No file records the original
R25-04 outcome as a replay expectation: `frozen/expected.json` has `before`/`after` only, and the old string
exists only as text in `expectation-migrations.json:35`.

Observed: the bytes are preserved (H3–H5, H8). Inference, not executed: the manual command
`python3 -B .ufo/waves/round-26/frozen/release-clock.py --root .ufo/waves/round-26/frozen/before --receipt .ufo/waves/round-26/frozen/observe-round25.json --receipt-sha b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92`
should reproduce `RELEASE_CLOCK: CLEAN (on_release=28 bound=28 unbound=0 observed=28 fired=1 derived=15)`.
The reasoning is that the code, all four root inputs and the receipt are BASE-identical (H4, H5, H15) and that the date
check (B `release-clock.py:388`) compares the receipt date against the table date, both 2026-10-21.

Impacted axes: freshness and calibration, specifically provenance wording. The docs present byte retention as a demonstrated replay.

Smallest safe correction (L1 picks one; production is frozen):
- (a) Add the manual command above and its expected line to the round-26 lesson and/or LOG, and have L1's final suite run it once. Or:
- (b) Change SCORECARD:1026 and lesson:138 to "retained byte-for-byte with matching code/tables; the frozen-root wrapper replays the round-26 observation against them".

Both avoid editing manifest-pinned snapshot bytes. Do not add an `observe-round25` mode to the wrapper unless it is built and run in the final suite.

## Observations that are not defects (no change requested)

- O1. `frozen/` is called a "historical snapshot" (C `PROVINCE.md:54`), but it also holds round-26 artifacts: `observe-1.json` and the rejected preserve-default `after/` table.
  - That table's notes and `frozen/expected.json:34` still say "round26 current profile" / "Current profile".
  - C `corpus/lessons/round-26.md:64-70,181-188` labels it superseded and "never as the active profile", so the current-vs-history boundary is disclosed.
  - Editing those bytes would break the manifest pin `cbb420c5…`, so leaving them is correct.
- O2. C `corpus/README.md:184` adds a sentence to the end of a round-25 bullet. The original words stay verbatim and the addition says the receipt is historical. This is an annotation, not a rewrite. Putting it under the round-26 heading would be stricter, but it is not required.
- O3. R25-04 keeps its round-25 id but now pins the round-26 receipt (30/fired=3).
  - Round-25 prose such as C `corpus/README.md:181-184` ("the 28 `on-release` registry rows") stays as dated history.
  - This follows the existing ledger convention: rows are current-tense and migrations are journaled (round-24 `recovery-migrations.json`; R21-02 was migrated in round 25). The journal entry is exact (H11).
- O4. The journal's `binding_changes` (`expectation-migrations.json:46-60`) records observed_version and verdict for S027/S028 but not the replaced note text. The old note survives in `frozen/before/corpus/release-clocks.tsv` and in git history, so nothing is lost; it is just not journaled.
- O5. Forward references are worded as pending, not as passes: `final-verification.json` (`expectation-migrations.json:86`), `census-end.json` (lesson:39-40), and "Exact outputs … appended after final immutable measurement" (lesson:83-84, LOG). No unrun pass claim was found in the files reviewed.
- O6. Round-25 C2 is still INCOMPLETE/48 in lesson:11-12, lesson:104, LOG and SCORECARD calibration. It is not credited CLEAN.

## Checks not run

I did not run `replay-current.sh`, the manual historical replay, `release-clock.py`, selftests, `claim-ledger.sh` or `self-counts.py`. Per the lane contract these are L1's final suite. If correction (a) is chosen, the manual replay in F1 should go into that suite.

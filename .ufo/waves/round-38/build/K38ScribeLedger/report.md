K38ScribeLedger — round-38 build wave, prose-number audit (read-only)
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin  branch master  candidate b944735
Verdict (top line): of 33 table rows, 25 AGREE (row 32 partly: record count 30 agrees, pin comparison not checked). 1 DISAGREE: SCORECARD.md:1452 round-36 C1 "reads 6 at HEAD"; live reading 3 at BASE. 2 NOT REPRODUCED (rows 12, 14: BASE values of the round-38 counters; instruments absent at a916f4a). 3 NOT CHECKED (rows 8, 31, 32-pin). 2 ABSENT (rows 27, 28: no stamp count in the round-38 prose). Zero prose mismatches at the candidate.

Scope note: the assignment names two report paths (`build/K38ScribeLedger/report.md` at the top, `build/K38ScribeLedger.md` at the bottom). The seat write scope admits only `build/K38ScribeLedger/`, so the report is written there and not at the sibling path.

No lane tracked file was edited. No git mutation was run. Read-only git was used only through `git archive` into scratch; the scratch root /fast/scratch/hyaku/kagi-r38/K38ScribeLedger/ was removed before yield. No tool or package was installed.

## 1. Live commands (exit codes from the shell)

| Command (cwd = lane) | Exit | Live output (verbatim) |
|---|---|---|
| `wc -l < corpus/stamps.tsv` | 0 | `122` |
| `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | 0 | `86` |
| `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` | 0 | `93` |
| `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12)` |
| `bash plans/round-38-c1.sh` | 0 | `5` |
| `bash plans/round-38-c2.sh` | 0 | `3` |
| `bash plans/round-36-c1.sh` (candidate) | 0 | `0` |
| `bash plans/round-36-c2.sh` (candidate) | 0 | `0` |
| `python3 -I -B corpus/quote-locate.py` | 0 | `QUOTE_LOCATE: CLEAN located=5 rows=5` |
| `bash corpus/laneguard.sh --selftest` | 0 | `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok` |
| `bash corpus/laneguard.sh --selftest --no-mutate` | 1 | `LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok` |
| `python3 -I -B -c 'import json; json.load(open(".ufo/waves/round-38/expectation-migrations.json"))'` | 0 | parses; dict, 7 top-level keys, 5 entries in `migrations`, `appended_rows` = R38-01..R38-04 |

Note on the do-nothing control: its printed value is `detected=0`, which matches SCORECARD.md:709. The process exit is 1, not 0. The claim text names the value, so this is recorded as an observation, not a mismatch.

Measured at BASE `a916f4a` (`git archive a916f4a… | tar -x` into scratch; tracked files only; no fleet sibling beside the lane):

| Command | Exit | Output |
|---|---|---|
| `bash plans/round-36-c1.sh` | 0 | `3` |
| `bash corpus/self-description-sweep.sh \| tail -1` | (pipeline) | `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)` |
| `python3 corpus/self-counts.py` | (filtered) | `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` |
| `bash plans/round-36-c2.sh` | 0 | `0` |
| `bash plans/round-38-c1.sh` | 127 | `No such file or directory` (file introduced at predeclaration 8c48b7d, not at BASE) |
| `bash plans/round-38-c2.sh` | 127 | `No such file or directory` (same) |

Round-36 C1 reading = SD5 + stale = 3 + 0 = 3 (header of plans/round-36-c1.sh: "The non-owned SD6 class is NOT part of this reading").

## 2. Claim-by-claim table

Legend: AGREE = live value equals the prose. DISAGREE = live value differs. NOT REPRODUCED = the value cannot be reproduced from the artifacts named. NOT CHECKED = not measured in this audit.

| # | Location (file:line) | Claimed text | Live value | Command, exit | Verdict |
|---|---|---|---|---|---|
| 1 | SKILL.md:46 | `122 stamps` | 122 | `wc -l < corpus/stamps.tsv`, 0 | AGREE |
| 2 | SKILL.md:46 | `86 claims` | 86 | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv`, 0 | AGREE |
| 3 | PROVINCE.md:73 | `122 revision stamps + 86 claim rows` | 122 / 86 | as rows 1–2 | AGREE |
| 4 | corpus/README.md:64 | `86 rows` (ledger) | 86 | as row 2 | AGREE |
| 5 | corpus/README.md:65 | `122 rows` (stamps) | 122 | as row 1 | AGREE |
| 6 | corpus/lessons/round-38.md:81 | `rows=93, A=89, mined=89, captures=93` | rows=93 A=89 mined=89 captures=93 | `bash corpus/sources-census.sh`, 0 | AGREE |
| 7 | corpus/lessons/round-38.md:81 | `entries_sourced=14` and `legacy=21` unchanged | entries_sourced=14 legacy=21 | as row 6 | AGREE |
| 8 | corpus/lessons/round-38.md:80 | START census `rows=91 … captures=91` | not re-measured (BASE tree not census-run) | — | NOT CHECKED |
| 9 | corpus/SOURCES.md registry (S-rows) | 93 | 93 | `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`, 0 | AGREE |
| 10 | corpus/SOURCES.md:99–100 | S092, S093 tier A | rows read `… \| A \|` | `grep -nE '^\| *S09[0-3] *\|'` | AGREE |
| 11 | SCORECARD.md:1461 | C1 post-move `0 → 5` | `plans/round-38-c1.sh` = 5 | row above, exit 0 | AGREE |
| 12 | SCORECARD.md:1461 | C1 BASE `0` (`a916f4a`) | file absent at BASE (exit 127) | git archive run | NOT REPRODUCED |
| 13 | SCORECARD.md:1462 | C2 post-move `0 → 3` | `plans/round-38-c2.sh` = 3 | exit 0 | AGREE |
| 14 | SCORECARD.md:1462 | C2 BASE `0` | file absent at BASE (exit 127) | git archive run | NOT REPRODUCED |
| 15 | SCORECARD.md:1452 | round-36 C1 "reads 6 at HEAD" (pre-move) | **3** at `a916f4a` (SD5=3, stale=0) | `bash plans/round-36-c1.sh` in git archive, exit 0 | **DISAGREE** (see §3) |
| 16 | SCORECARD.md:1452, 1462 | round-36 C1 brought back to frozen `0` | `plans/round-36-c1.sh` = 0 at candidate | exit 0 | AGREE |
| 17 | SCORECARD.md:1452 | round-36 C2 `0`, not stated as a pre-move number in §1452 | `plans/round-36-c2.sh` = 0 (candidate and BASE) | exit 0 | AGREE |
| 18 | SCORECARD.md:1465 | registry `91 → 93` | 93 | row 9 | AGREE (post); 91 not re-measured |
| 19 | SCORECARD.md:1465 | captures `91 → 93` | captures=93 | row 6 | AGREE (post); 91 not re-measured |
| 20 | SCORECARD.md:1461 | quote gate `QUOTE_LOCATE: CLEAN located=5 rows=5` | same | `python3 -I -B corpus/quote-locate.py`, 0 | AGREE |
| 21 | SCORECARD.md:708 | `QUOTE_LOCATE: CLEAN located=5 rows=5` | same | as row 20 | AGREE |
| 22 | SCORECARD.md:709 | lane guard `detected=3 mutants=3 clean=ok` | same | `bash corpus/laneguard.sh --selftest`, 0 | AGREE |
| 23 | SCORECARD.md:709 | `--no-mutate` ⇒ `detected=0` | `detected=0 mutants=3 clean=ok` (exit 1) | `--selftest --no-mutate`, 1 | AGREE on the value; exit 1 is an observation |
| 24 | LOG.md:1735 | rows `91 → 93` | 93 | row 9 | AGREE |
| 25 | LOG.md:1735 | `R21-04` `82 → 86` | 86 | row 2 | AGREE |
| 26 | LOG.md:1735 | "three prose counts rebound to 86 (SKILL.md:46, PROVINCE.md:73, corpus/README.md:64)" | all three read 86 (rows 2–4) | as row 2 | AGREE |
| 27 | LOG.md:1731–1737 (round-38 entry) | stamps `122` | no stamp count appears in the round-38 LOG entry | `grep -n '122' LOG.md` restricted to 1731–1745: no match | ABSENT (not a mismatch; the claim is not made in this entry) |
| 28 | corpus/lessons/round-38.md | stamps `122` | no match for `122` or `stamps` | grep, no match | ABSENT |
| 29 | corpus/lessons/round-38.md:9 | `R21-04 86` | 86 | row 2 | AGREE |
| 30 | SCORECARD.md:1461 (`PREFREEZE: CLEAN (controls=7 mismatch=0)`) | prefreeze gate verdict | stored receipt `controls/prefreeze-gate.txt` ends with this line | `tail -3` of the stored receipt | AGREE (receipt read; controls not re-run) |
| 31 | SCORECARD.md:1461 | forged quote, bytes, registry each read `4` at predeclaration | not re-measured (controls not re-run; stored receipt only shows the gate verdict) | — | NOT CHECKED |
| 32 | SCORECARD.md:1461 | live re-observation of 30 clocks "matches the pinned round-36 receipt on 30 of 30" | `controls/observe-r38.json` holds 30 observations, all `http_status` 200; verdict tally `fired 15, quote-located 10, not-fired 5` | python3 read of the stored file | Record count AGREE (30). The "30 of 30 match pin" comparison NOT CHECKED (no pin diff run) |
| 33 | ledger rows R38-01..04 | four rows appended | all present (`grep -nE '^R38-0[1-4]'`) | grep | AGREE |

Migration record check (`.ufo/waves/round-38/expectation-migrations.json`), comparing `new` with the live column 3 (`expect`) of `corpus/claim-ledger.tsv` by string equality:

| ledger row | `new` equals live expect | `old` equals live expect | live expect (abridged) |
|---|---|---|---|
| R21-02 | True | False | `^SOURCES_CENSUS: CLEAN \(rows=93 A=89 … captures=93 …\)$` |
| R31-02 | True | False | same census line |
| R33-02 | True | False | same census line |
| R34-03 | True | False | same census line |
| R21-04 | True | False | `^86$` |

All five migrated rows have `expect == new` exactly; `old` no longer matches, as expected for a migration. Each ledger row has 6 tab-separated fields. The four appended rows R38-01..R38-04 are present in the ledger.

## 3. Mismatch list

Mismatch 1 (the only DISAGREE):
- Location: SCORECARD.md:1452, round-36 pre-move cell for calibration: "`bash plans/round-36-c1.sh` reads 6 at HEAD after the round-37 calibration row omitted the three routed reds (SD5=3)".
- Live value: `bash plans/round-36-c1.sh` = **3** (exit 0) at `a916f4a`, measured in a `git archive` copy in scratch. Reading = SD5 (3) + stale (0). The sweep line is `SELF_DESCRIPTION: MISMATCH n=6 (… SD5=3 SD6=3 …)`.
- What the number 6 corresponds to: the sweep's total `n=6`, which includes the SD6 class (3). The counter's own header excludes SD6 ("The non-owned SD6 class is NOT part of this reading: it is preserved, never counted here"). [INFERENCE] The SCORECARD's 6 most likely quotes the sweep total, not the counter reading.
- Caveat: the archive measured tracked files only and had no fleet root beside it. The lane's live layout was not available for the pre-move state because HEAD has since moved to the candidate. The discrepancy is therefore reproduced in one layout only.
- Candidate value: `bash plans/round-36-c1.sh` = 0, so the post-move statement "brought back to its frozen 0" holds at the candidate.

No other numeric prose mismatch was found at the candidate.

## 4. Items not reproduced or not checked (explicit)

- BASE `0` for `plans/round-38-c1.sh` and `plans/round-38-c2.sh` (SCORECARD.md:1461–1462). Not reproducible: the instruments are introduced by the predeclaration commit 8c48b7d, so the files do not exist at `a916f4a`. A "0 at BASE" reading would require the predeclaration's instruments run against a916f4a, which was not done.
- Pre-move census `rows=91` (lesson:80) and SCORECARD `91 → 93` pre-value: not re-measured at BASE.
- Forged-control values (`4` each): not re-run; only the stored `PREFREEZE: CLEAN (controls=7 mismatch=0)` receipt was read.
- "30 of 30 records unchanged against the pinned round-36 receipt": the stored observation file has 30 records; the pin diff was not executed.
- `fleet census` (migration record `fleet_census` field): not run.

## 5. Install record

None. No tool, package or runtime was installed or upgraded. No pacman transaction was run.

## 6. Files touched

- Written: `.ufo/waves/round-38/build/K38ScribeLedger/report.md` (this file).
- Created: directory `.ufo/waves/round-38/build/K38ScribeLedger/` (seat directory, allowed).
- Scratch: `/fast/scratch/hyaku/kagi-r38/K38ScribeLedger/` created and removed (contained the BASE git archive only; 0 bytes of receipts copied because none were needed).
- Not touched: lane tracked files, lane git/jj state, lane index, fleet repo, sibling lanes, `~/.local/bin`.

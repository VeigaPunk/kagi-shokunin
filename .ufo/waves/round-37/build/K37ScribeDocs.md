# K37ScribeDocs — round 37 documentation drafts (seat report)

Seat: K37ScribeDocs (scribe, leaf member, no subagent dispatch). Lane: kagi (`/home/vgpnk/Projects/shokunin/kagi-shokunin`), branch `master`, candidate `9efcea7`, BASE `911ab519b6b07694c3cb9f7d9a7c56e142ad957c`, plan `e2030d2`, predeclaration `04489d4`. Judged on: freshness. Claim under test: C2 freshness, release-feed registry anchors 3 → 0 (frozen; not reinterpreted).

## Verdict

- Drafts written: three files under `.ufo/waves/round-37/build/K37ScribeDocs/` (scorecard, log, readme frontier). Final line `DOCS DRAFTS: WRITTEN`.
- The counter re-measurement by this seat agrees with the L1 numbers: BASE 3 (at `04489d4` and `e2030d2`), candidate 0 (at `9efcea7`). The C2 target is met at the committed candidate.
- Frontier: NO CHANGE (reason in `readme-frontier.md`).
- Findings F1–F7 (§Findings): F1 is a wording defect in the lesson (BASE counter reading names a tree the counter is not in); F3 is a scorecard prose sentence the capability row makes stale; F4 is a stray untracked file in the lane tree. None changes a number; none was fixed by this seat.

## Scope and bounds

- Wrote only under `.ufo/waves/round-37/build/K37ScribeDocs/` and this report at `.ufo/waves/round-37/build/K37ScribeDocs.md`.
- No write to lane tracked files, the lane index, git or jj state, the fleet repo, or any sibling lane. No git mutation. Read-only git (`log`, `show`, `diff`, `rev-parse`, `ls-files`) and `git archive` into scratch only.
- Scratch root `/fast/scratch/hyaku/kagi-r37/K37ScribeDocs/` (all extractions and copies; no file larger than 50 MB); removed before yield.
- Installs or upgrades: none. No pacman, no `~/.local/bin` write.

## Inputs read

- `LOG.md` tail (round-36 entry shape: heading `## Round 36 (2026-11-04) — …`, leading `- Claims frozen in …` bullets).
- `SCORECARD.md`: round-35 post-move (lines 1368–1383), round-36 pre-move (1385–1396), round-36 post-move (1398–1409), the `## Capabilities` table (line 696–708).
- `corpus/README.md` §Frontier (line 120–122).
- `plans/round-37.md`, `corpus/lessons/round-37.md`, `plans/round-37-c2.sh`, `corpus/SOURCES.md` rows S034, S035, S039, S089, S090, S091.

## Measurements executed by this seat

All counter runs used a `git archive` extraction of the named commit under scratch. Commands run from the scratch directory, not the fleet root.

1. Frozen counter at each revision (`git archive <rev> | tar -x -C <scratch>/<rev>`, then `bash plans/round-37-c2.sh`):

```
== 04489d4   bash plans/round-37-c2.sh -> 3   rc=0
== e2030d2   bash plans/round-37-c2.sh -> 3   rc=0
== 9efcea7   bash plans/round-37-c2.sh -> 0   rc=0
```

2. BASE `911ab51` tree has no `plans/round-37-c2.sh` (`bash: plans/round-37-c2.sh: No such file or directory`, rc=127). The counter and its receipt were copied from `04489d4` into a `911ab51` extraction (`git show 04489d4:plans/round-37-c2.sh`, `git show 04489d4:.ufo/waves/round-37/controls/observe-r37.json`):

```
== counter copied into 911ab51 extraction -> 3   rc=0
```

`git diff --stat 911ab51 04489d4 -- corpus/SOURCES.md corpus/` prints nothing, so the registry is byte-identical between BASE and the predeclaration.

3. Receipt integrity: `sha256sum .ufo/waves/round-37/controls/observe-r37.json` →
`cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203` (matches the frozen pin). Receipt contents: format `release-clock-observations-v1`, 30 observations. The release-feed records (`url` match, `parsed_version` set) number 15: vault 5 (`2.2.1`), openbao 6 (`2.7.2`), python.org 4 (`3.15.2`). Each surface carries exactly one version across its records (the counter exits 2 otherwise, and exited 0).

4. Candidate row shape: `git diff --stat 911ab51 9efcea7 -- corpus/SOURCES.md` → `corpus/SOURCES.md | 3 +++`, three insertions only (S089, S090, S091). Each new row has the source cell naming the feed URL, anchor `Entry titled v2.2.1` / `Entry titled v2.7.2` / `Item titled Python 3.15.2` (anchor cell, index 6 of the `|`-split line), the `teaches` cell (index 7) opening `supersedes S034 —`, `supersedes S035 —`, `supersedes S039 (feed anchor) —`, and `used-by` `corpus/lessons/round-37.md`.

5. Located quotes, checked against the candidate's captured bodies (`git show 9efcea7:.ufo/waves/round-37/capture/<id>.body`, python `bytes.find`):

```
S089-vault.body   len 297221 sha256 3cbfdd86d1b45309 offset 726 count 1   <title>v2.2.1</title>
S090-openbao.body len 543805 sha256 a54d1a5314ca7016 offset 729 count 1   <title>v2.7.2</title>
S091-python.body  len 3354   sha256 9ba8856e586659ab offset 1583 count 1  <title>Python 3.15.2</title>
```

The body sha256 prefixes match `corpus/lessons/round-37.md` §Gate and the `corpus/source-fetches.tsv` rows (`3cbfdd86d1b4530999d9…`, `a54d1a5314ca701684fe…`, `9ba8856e586659ab78…`).

6. Census, fleet validator, BASE and candidate. The validator needs `shokunin.conf` in its root, so for BASE a scratch root was built with the `911ab51` tree at `kagi-shokunin/` and a copy of `shokunin.conf` (read-only use of the fleet script; no write).

```
BASE  (scratch root, 911ab51):  rc=0   W04 lines = 16   'kagi ok …/corpus/SOURCES.md'
CAND  (live path, 9efcea7 SOURCES): rc=0   W04 lines = 19   'kagi ok …/corpus/SOURCES.md'; no non-W04 finding line
```

7. Lane census (`bash corpus/sources-census.sh`, run in extractions):

```
911ab51: SOURCES_CENSUS: CLEAN (rows=88 A=84 B=2 C=2 queued=1 mined=84 rejected=3 entries_sourced=14 legacy=21 captures=88 inrow=16 inrow_only=0 inrow_nonreproducing=12)  rc=0
9efcea7: SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)  rc=0
```

8. Control receipts (read from `.ufo/waves/round-37/controls/`, not re-run by this seat): `nowork.out`=3, `forge-g1-superseded.out`=3, `forge-g2-wrong-url.out`=3, `forge-g3-knowledge.out`=3, `positive-partial-vault.out`=2, `positive-full.out`=0; `setup-receipt-missing` and `setup-receipt-tampered` exit 2 with no stdout (`c2-controls.txt`); `prefreeze-gate.txt` = `PREFREEZE: CLEAN (controls=6 mismatch=0)`. The controls file records `LANE-GUARD: tracked tree and master unchanged`.

## Draft contents and the number each line rests on

| Draft line | Number | Source |
|---|---|---|
| counter BASE 3 | 3 | measurement 1 and 2 (this seat); `plans/round-37.md` §C2 |
| counter candidate 0 | 0 | measurement 1 (this seat); `positive-full.out` |
| controls 3/3/3/3/2/0, setup exit 2 | as listed | measurement 8 |
| W04 16 → 19; rc 0 | 16, 19 | measurement 6 |
| lane census rows 88 → 91, captures 88 → 91 | 88, 91 | measurement 7 |
| coverage entries_sourced 14 | 14 | measurement 7 (unchanged) |
| all six axes 9 → 9 | 9 | `SCORECARD.md` round-36 post-move (lines 1398–1409): "Scores stay 9 → 9" |
| freshness last change `round 36` | — | round-36 post-move records a measured move on freshness (`R36-02`/`R36-03`); the table has no "Last change" column (see §Findings F2) |
| capability first working round 37 | — | `plans/round-37.md` §Capability; the prose sentence `latest first-working round … is 33` in SCORECARD is the one to update |

## Findings (for the L1; none fixed by this seat)

- **F1 — BASE counter reading is not reproducible from the BASE tree as written.** `plans/round-37.md` §C2 says BASE 3 "measured at `04489d4`" (correct), but `corpus/lessons/round-37.md` §Before → after says "Counter … at BASE `911ab51`, measured in a `git archive` extraction with the frozen counter: 3". The counter file and the receipt do not exist in the `911ab51` tree (`rc=127`). The 3 is reproduced only by copying `plans/round-37-c2.sh` and the receipt from `04489d4` into the extraction (measurement 2). Suggest the lesson say so; the number is unchanged.
- **F2 — the round-36 post-move table has no "Last change" column.** The brief asked for last-change rounds "as shown in the round-36 post-move table". I used the round-36 pre-move "Last change" values for the four axes the post-move table records as unchanged, and round 36 for freshness and calibration (measured moves in the post-move table). Stated in the scorecard draft. The L1 may choose otherwise.
- **F3 — the SCORECARD capabilities prose.** The `## Capabilities` table prose at SCORECARD line 708 says "The latest first-working round in this table is 33". Adding the round-37 row makes it 37; the draft says so. This is a required edit that the plan's capability row does not mention.
- **F4 — hygiene in the lane working tree (not written by this seat).** `git status --porcelain` at `9efcea7` shows untracked `plans/round-37.controls.tsv.tmp` (0 bytes, timestamp 04:59) and untracked wave files (`.ufo/waves/round-37/build-dispatch.json`, `build-run.stderr`, `build-spec.json`, `build.ready`, `build.ready.dispatched`, `build/`, `controls/prefreeze-gate.txt`). The `.tmp` is a stray artifact the L1 should remove; the wave files are the wave's own. Not tracked, not committed by this seat.
- **F5 — the controls' setup message.** `setup-receipt-tampered.err` prints the same text as the missing-receipt case (`C2 SETUP: receipt missing or sha mismatch`), so stderr alone cannot tell the two apart. Exit codes (2) are what the frozen controls check; no change requested.
- **F6 — teaches and quote checks passed.** The three `teaches` cells open `supersedes S0NN —` as the plan requires; the located quotes (measurement 5) and body sha256 prefixes agree with the lesson and the `source-fetches.tsv` rows. No defect found in the candidate rows.
- **F7 — no counter-attack on the claim by this seat.** Scribe scope only; no adversarial runs were made. The lesson's stated ceiling stands: the counter does not check `teaches` correctness or the author's opening of the source.

## Notes on the drafts

- `scorecard-round37.md`: pre-move table (six axes, 9 each, pointers to `plans/round-37.md` and `corpus/lessons/round-37.md`), post-move table for C2 (freshness 9 → 9, measured 3 → 0, receipts and commits `04489d4`, `e2030d2`, `9efcea7`), the other five axes unchanged, and the capability row text exactly as assigned.
- `log-round37.md`: LOG-style entry covering predeclaration, freeze, candidate, controls, census before/after, refused candidate shapes, calibration hold routed to round 38, the R36 errata, and M37-1..M37-3. The wave's seat settlement is left to the L1 (not observed by this seat).
- `readme-frontier.md`: `NO CHANGE`. The single Frontier bullet's claim and round-25 entry set are unchanged by this round; no frontier entry is invented.

## Hand-off

- Main agent to run once after the wave: `bash plans/round-37-c2.sh` (expect 0), `bash plans/round-37-controls.sh` battery (expect 3/3/3/3/2/0), `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (expect exit 0, 19 W04), `bash corpus/sources-census.sh` (expect `CLEAN (rows=91 …)`).
- Non-author spot-check remains pending per the lesson.

DOCS DRAFTS: WRITTEN

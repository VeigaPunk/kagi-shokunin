# R59ScribeLesson — w1 report (C1/C2 lesson draft)

Seat: scribe (lesson). Lane `kagi-shokunin`, branch `master`, claim BASE
`5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`, frozen predeclaration `af7b6651`. Read-only on git/jj:
no `git add/commit/stash/push`, no mutating `jj`, no writes outside this seat's paths.

## Deliverable

`corpus/lessons/round-59.md` drafted at
`.ufo/waves/round-59/build/R59ScribeLesson/round-59.md` for the L1 (`KagiR59`) to land. Structure, in
the order the item requires: title naming both claims and their axes (C1 calibration, C2 operability);
`source:` line (S121, S122, the round-58 spot-check, both pages opened 2026-11-07); §Claims (C1's five
items with derived numbers and the frozen predicate, C2's five tests, shim vectors and clean-room leg);
§Gate (two admits with located quotes, the entry admit, two checked rejects); §Mistakes (one row,
four fields); §Routed dispositions (R1–R31); `SEAT-STATUS: complete`.

## Numbers: where each came from

| number in the draft | receipt |
|---|---|
| rows 117 / 120 / 120 / 122; `+S` 6 and 2 | `build/R59ScribeLesson/derived-base.txt`, `registry-delta.txt` |
| controls 20 / 9 / 7 and the 20- then 21-row id census | `build/R59ScribeLesson/derived-base.txt`, `controls-composition.txt` |
| 101 minutes (11:54:48 → 13:36:19) | `derived-base.txt` (the two lines in the spot-check) |
| every Gate quote (`count=1`) | `build/R59ScribeLesson/locate-receipt.txt` (my locate runs on `.ufo/waves/round-59/capture/`) |
| capture status/bytes/sha256 | the scout's `capture/*.headers` + `sha256sum` (same values as `build/R59ScoutSources/sources.md` §1) |
| reject status/bytes/sha256/rendered size/keyword counts | `build/R59ScribeLesson/reject-probe.txt` (the transit CLI page and the seal page, fetched by this seat) |
| C1 BASE, diagnostic and reference readings | `build/R59ExecCounterC1/{driver-base-5fa6e658,base-guard-reading-current-tree,reference-fixed-tree,reference-forged-i2,reference-f5probe}.txt` |
| C2 trial, shims, no-bao, clean-room | `build/R59ExecTrial/receipt-*.txt`, `notes.md` |
| C2 counter readings | `build/R59ExecCounterC2/receipt-{base,candidate,shim-vectors,no-bao,cleanroom}.txt`; non-author lane-tree run `build/R59ReviewerCounters/attacks.md:59` |
| attack findings | the seat reports under `.ufo/waves/round-59/w1/` |

No quote, verdict or number was invented; where a reading does not exist the draft says so.

## Calibration state recorded (not claimed as green)

- **C1** — BASE `value=FAIL population=5 … guard=0` (diagnostic `value=5`); the positive reference reads
  `value=0 … guard=1`. On the lane tree the only recorded guard-bearing readings are **3**
  (counter receipt 14:09, reviewer 14:12), and the draft states that, not 0. Three items read 0 at that
  capture for format reasons (wrapped bullets, no `CITATION_GATE:` line, no supplement receipt at the
  time) — the lesson's M59-1 records the format-blind item read as the round's mined mistake.
- **C2** — the trial's own receipts are complete and exact: two real runs `HHHHH`, `SH1..SH5` →
  `BHHHH/HBHHH/HHBHH/HHHBH/HHHHB`, no-bao `SETUP` rc 2 with zero `TRIAL` lines, clean-room refusal
  `* encryption key not found` from a second `bao server -dev`. The counter's own `value=5` was a
  reference-fixture reading; a non-author run on the lane tree also reads `value=5`, and the draft says
  the L1's own run is the one to commit.

## Open items the L1 must close before landing (routed in the draft)

1. **R20 / I4** — `.ufo/waves/round-59/final/citation-gate-r59.txt` currently contains
   `claim-ledger: unexpected positional argument for citations` (59 B); I4 cannot hold until a correct
   `bash corpus/claim-ledger.sh citations` writes a last `CITATION_GATE: … unresolved=<U> …` line and the
   lesson's D4 line carries the same U.
2. **Final C1 reading** — replace the recorded `value=3` with the reading the final `plans/round-59-c1.sh`
   run prints, and name the mode (`--no-challenge` for the diagnostic census).
3. **R23** — no recorded run of the revised (14:16) battery reads a final `CONTROLS: match=N mismatch=0`;
   run5 stops after `C1-F6`. The plan requires that line before a candidate is measured.
4. **R22** — the challenge copy follows a symlinked lesson and writes outside the copy (reviewer A12).
5. **R25/R29** — the C2 summary is `grep -q`-read (two holes) and “two independent real runs” is an
   unnamed ceiling.
6. **R18** — the counter seat's own candidate receipt is a fixture reading; the L1's run on the landed
   trial is the one to record.

## Landed copy

The L1 landed `corpus/lessons/round-59.md` at 14:19 from an earlier snapshot of this draft (before the
last edits). I messaged `KagiR59` to re-copy
`.ufo/waves/round-59/build/R59ScribeLesson/round-59.md` before committing; the deltas are the non-author
C2 counter reading (R18), the entry's measured size, R20's gate status, R23's citation of the lane's own
run4, and the trailing `SEAT-STATUS` line. I did not write the lane lesson myself.

## Read for this seat

`plans/round-59.md`; `corpus/lessons/round-58-verifier-spotcheck.md`; `corpus/lessons/round-58.md`;
`corpus/lessons/round-57.md` (peer lesson for shape); `corpus/rendered-text-v1.py` (locate);
the two captures; and every seat report and receipt under `.ufo/waves/round-59/` present at 14:20 -03. The mutation seat (`R59MutCounters`) had published no report or receipt by then, so no mutant finding is routed.

## Tooling and scratch

No tool was installed, upgraded or downgraded (pacman transactions are paused host-wide; nothing was
needed). Scratch `/fast/scratch/hyaku/kagi-r59/R59ScribeLesson/` was created and is removed; no citable
evidence was written under `/tmp`. No secret value, token, cookie, session id or vault/item/field name
appears in any artifact this seat wrote.

SEAT-STATUS: complete

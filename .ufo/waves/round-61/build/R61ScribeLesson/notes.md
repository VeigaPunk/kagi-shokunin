# R61ScribeLesson — notes: what this seat could not ground

Seat: `R61ScribeLesson` (scribe, kagi round 61 attempt 1). Files owned:
`corpus/lessons/round-61.md`, this seat's receipts under
`.ufo/waves/round-61/build/R61ScribeLesson/`, and the seat report
`.ufo/waves/round-61/w1/R61ScribeLesson.md`. No product file, plan, registry, LOG,
SCORECARD or knowledge entry was edited by this seat; no git/jj mutation was run.

## 1. Ungrounded or only partly grounded in the lesson

- **The wave record.** `.ufo/waves/round-61/w1-results.json` did not exist when the lesson
  was written, so `## Wave` reads `pending results (the L1 appends the measured record)`.
  The planned mix quoted there is derived from `w1-dispatch.json` and is labelled as the
  plan, not the record. **No dead-seat count is stated** — it can only be derived from the
  results file.
- **The C1 reading is on the working tree, not a committed revision.** The lesson quotes
  `C1_ROUTED: value=0 population=7 … guard=1` from
  `python3 -I -B plans/round-61-c1-check.py --root . --repo .` run at 17:15 against the
  uncommitted tree. The committed-revision reading is the L1's to take. The checker's
  `i2=1` also depends on the checker's own I2 legs having been repaired during the wave
  (M61-6): on the 17:11 checker the same tree read `i2=0`.
- **C2 is cited as state, not as a verdict.** This seat did not run
  `plans/round-61-c2.sh`. The trial's `HOLDS holds=5 broken=0 error=0` line is from
  `build/R61ExecTrial/receipt-real-1.txt` (trial seat's receipt); the counter's value is
  not quoted anywhere in the lesson.
- **The trial's own `--selftest` was not re-run on the final bytes.** The seat ran it once
  mid-edit (63 cases, 4 failed, while the seat was still editing) and did not repeat it, to
  avoid racing the trial seat's scratch. The trial seat's receipt is the evidence.
- **The C2 counter's mutated-copy leg** is cited from
  `build/R61ExecC2Selftest/selftest-mutant.txt` (`C2_SELFTEST: FAIL (cases=28 failed=8)`
  with named FINDINGs), which is an earlier 28-case build than the landed 36-case script;
  this seat did not re-run the mutation on the final bytes.
- **The rejected page's body is not retained in the lane.** The fetch is recorded by
  command, HTTP status, byte count and sha256 in
  `build/R61ScribeLesson/reject-candidate.txt`; re-checking it requires a re-fetch, and the
  flip condition covers a revision that changes the page.

## 2. Sequence worth recording

`capture/notes.md` did not exist when this seat began (16:50–16:56) and appeared at 16:59.
The Gate quotes were therefore first derived from the capture bodies with the seat's own
tag-strip locator, then re-aligned to the scout's ledger rows (raw anchor, byte, line,
`rendered-v1` count) once the notes landed. Both locators agree; the lesson cites the
scout's rows and the re-resolution is receipted in `gate-quotes.txt`.

## 3. Self-caught mistake (M61-4a)

The seat's first locator wrote `S125.body.txt`, `S126.body.txt` and `S127.body.txt` beside
the captures in `.ufo/waves/round-61/capture/` (a sibling-owned directory). They were
removed in the same minute; the three capture sha256s are unchanged
(`mistake-writescope.txt`). The fix (`outpath.sh`) refuses any output path outside the
seat's scratch root and is demonstrated on both legs.

## 4. Tooling

No tool was installed or upgraded. Commands used: `git` (read-only), `python3`, `bash`,
`curl` (one fetch, the rejected candidate), `sha256sum`, `grep`, `sed`, `ls`, `find`.
Scratch `/fast/scratch/hyaku/kagi-r61/R61ScribeLesson/` is deleted before yield.

SEAT-STATUS: complete

# Erratum E46-1 — round-45 receipt `.ufo/waves/round-45/final/measured-at-candidate.txt`

Addresses spotcheck §5 item 3 (`corpus/lessons/round-45-verifier-spotcheck.md:104`,
under the heading `:100`) routed defect 3: "empty LANE-control block and an out-of-order `stamp rc=2`
line; correct by erratum in round 46, never by rewrite".

Scope: this erratum is additive. `.ufo/waves/round-45/final/measured-at-candidate.txt`
is **not rewritten** and stays byte-identical to its committed content; no file
under `.ufo/waves/round-45/` is modified by round 46. The receipt is a historical
transcript; the corrections below are the reading a reader of that receipt should
take, and each names a committed pointer that carries the value.

## Defect 1 — empty LANE-control block, line 6

Quoted verbatim, with line numbers:

```
6	$ bash plans/round-45-c1.sh LANE (pre-candidate control at tree)
7	$ census root form
```

Line 6 is an invocation header with **no output line beneath it**: the next line
(7) is the next command header. The receipt therefore records that the
pre-candidate lane-tree control ran, but not what it printed.

Correct reading. The block stands for the pre-candidate LANE reading of the C1
counter, and that reading is committed elsewhere:

- `.ufo/waves/round-45/controls/c1-base.txt:1` —
  `C1_BIJECTION: value=0 detected=0 positive=1 real=CLEAN (rc A=0 B=0 C=1 tree=LANE; real-last='CLAIMS_DECLARED: CLEAN (claims=15)'; ...)`
- the same BASE value, restated in the frozen plan:
  `plans/round-45.md:31` — "BASE measured: `bash plans/round-45-c1.sh LANE` →
  `value=0 detected=0 positive=1 real=CLEAN`", and `plans/round-45.md:127` —
  "BASE values after A1 are the same (`controls/c1-base.txt` value=0; `controls/c2-base.txt` value=0), re-run and recorded."

So the missing output line is `value=0 detected=0 positive=1 real=CLEAN`
(`tree=LANE`, `claims=15`), not a verdict that is absent from the record. The
candidate-tree reading of the same counter is present in the same receipt at
`measured-at-candidate.txt:3` (`value=2 detected=2 positive=1 real=CLEAN ...
tree=072bb0bc...`), so the receipt's C1 story (0 at BASE → 2 at the candidate)
remains readable once line 6 is read against `controls/c1-base.txt:1`.

[INFERENCE] The empty block is a lost copy of `controls/c1-base.txt:1`, not a
failed run: `controls/c1-base.txt` is the only receipt in
`.ufo/waves/round-45/controls/` that carries a `C1_BIJECTION` line for the LANE
tree (`ls` lists `c1-base.txt`, `c2-base.txt`, `census-start.txt`,
`claims-declared-base.txt`, `quote-locate-base.txt`, `capture-r45`), and its
`real-last` field is backed independently by
`controls/claims-declared-base.txt:1` — `CLAIMS_DECLARED: CLEAN (claims=15)`,
the same gate line `c1-base.txt:1` reports as `real-last`.

## Defect 2 — out-of-order `stamp rc=2`, line 35

Quoted verbatim, with line numbers:

```
34	CLAIMS_DECLARED_SELFTEST: PASS (8 cases)
35	stamp rc=2
36	$ stamp-drift.py <archive of 072bb0bc1860fcc33418b659cec0dd40d5c0f944>
```

Two defects in one line: (a) the exit-status line is printed **before** the
header of the invocation it would belong to (line 36), so it precedes its own
command rather than following its output; (b) the value `rc=2` does not match
the recorded run.

Correct reading:

- `.ufo/waves/round-45/final/stamp-drift-at-candidate.txt:1-2` —
  `STAMP_DRIFT: rows=123 drift=0` then `stamp rc=0`.
- Rows are consistent with the tree: `wc -l corpus/stamps.tsv` → `123`
  (measured 2026-11-06), matching the receipt's `rows=123`; a nonzero drift
  count would have been exit 1, not 2.
- `rc=2` is not a stamp verdict. The tool used for that leg returns 2 only for a
  usage error or a missing `corpus/stamps.tsv`
  (`.ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py:24-26` usage →
  `return 2`; `:29-31` missing stamps file → `return 2`), returns 1 when
  `drift != 0`, and 0 when `drift == 0` (same file, docstring `:5-8`). No printed
  invocation on line 36 or elsewhere in the receipt yields rc=2, and the receipt
  prints no `DRIFT` line and no `STAMP_DRIFT: missing` error text, so line 35
  cannot be read as the outcome of the command at line 36.

The correct pair of lines for this leg is `STAMP_DRIFT: rows=123 drift=0` /
`stamp rc=0`, taken from `final/stamp-drift-at-candidate.txt:1-2`. Line 35
should be treated as a transcription artifact of the receipt builder, not as a
failed stamp gate.

## What this erratum does not do

- Does not rewrite, patch, restamp or delete any part of
  `.ufo/waves/round-45/final/measured-at-candidate.txt` or
  `.ufo/waves/round-45/`; neither file is touched by round 46.
- Does not invalidate either counter reading: C1 at the candidate is
  `measured-at-candidate.txt:3`, C2 is `measured-at-candidate.txt:5`, the
  stamp leg is `final/stamp-drift-at-candidate.txt:1-2`, all CLEAN.
- Does not re-run `plans/round-45-c1.sh`, `plans/round-45-c2.sh` or the
  stamp-drift witness; no command was executed to write this erratum. All values
  quoted above are read from committed files, and every pointer is `path:line`.

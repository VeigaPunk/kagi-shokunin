# ExecReplay — independent BASE replay (round 33, kagi-r33-build)

Seat: `ExecReplay` (leaf). No lane edits, no commits. Frozen BASE
`76f4eeae7aa9af4dbb9423f5632b55791824253a`; round-32 replay revision
`32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`. Plan read first:
`plans/round-33.md` (commit `880824b`), plus `plans/round-33.controls.tsv`,
`plans/round-32.controls.tsv`, `plans/round-32.md` (commit `507dd9f`) and
`corpus/lessons/round-32.md`.

Method: both revisions were extracted with `git archive <rev> | tar -x` into a
scratch tree; every value below was measured on an extracted tree with plain
`grep`/`awk`/`ls`/`test`/`bash`. No script written by the L1 was used for a measurement,
and the sweep counters were not taken from any receipt — only compared to one afterwards.
The only non-plain command is the lane's own round-32 counter
`corpus/self-description-sweep.sh`, which the plan names as the counter for these values
(sha256 `61f83578583b35028bb841b6c54ef8a532b2d3fa1db3c069534ff501f5bbad26`, byte-identical
in `76f4eea` and in the working tree at measurement time).

Receipts: `.ufo/waves/round-33/build/replay/` (`sweep-32c35fe.out/.err`,
`sweep-76f4eea.out/.err`, `controls-76f4eea.txt`, `sweep-replay.txt`).

## Values

`L1 receipt` = the value as committed by the L1 (`.ufo/waves/round-33/controls/base-values.txt`
for the four round-33 controls; `plans/round-32.md` l.31/34 and `plans/round-32.controls.tsv`
for the two round-32 declared values). `measured` = my own read on the extracted tree at the
revision named in the row. Paths in commands are relative to the measured tree root.

| # | value | L1 receipt | measured | agree/differ | command | exit |
|---|---|---|---|---|---|---|
| 1 | `nist_entries` @ `76f4eea` | 0 | 0 | **agree** | `ls corpus/knowledge/nist-*.md 2>/dev/null \| wc -l` (the glob itself exits 2: no match) | 0 (glob 2) |
| 2 | `registry_rows` @ `76f4eea` | 72 | 72 | **agree** | `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` | 0 |
| 3 | `prefreeze_artifact` @ `76f4eea` | 0 | 0 (file absent) | **agree** | `test -e corpus/prefreeze-control.sh` → 1 → counted 0 | 1 |
| 4 | `frontier_nist` @ `76f4eea` | 1 | 1 | **agree** | `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -c 'NIST'` | 0 |
| 5 | `sd5` @ `32c35fe` | **3** | **1** | **differ** (expected: the M32-2 red witness) | `bash …/corpus/self-description-sweep.sh --root <tree@32c35fe>` then `grep -o 'SD5=[0-9]*' \| cut -d= -f2` | sweep 1, extract 0 |
| 6 | `total` @ `32c35fe` | **10** | **8** | **differ** (expected: the M32-2 red witness) | same sweep run, `sed -n 's/.*n=\([0-9][0-9]*\).*/\1/p'` | sweep 1, extract 0 |

Supplementary (same L1 receipt, not one of the six required values):

| value | L1 receipt | measured | agree/differ | command | exit |
|---|---|---|---|---|---|
| capabilities rows naming `prefreeze-control.sh` @ `76f4eea` | 0 | 0 | **agree** | `awk '/^## Capabilities$/,/^## Saturation$/' SCORECARD.md \| grep -c 'prefreeze-control.sh'` | 1 |
| SD-sweep exit code @ `76f4eea` | **0** (`sweep_exit=0`) | **1** | **differ** | `bash …/self-description-sweep.sh --root <tree@76f4eea>`; MISMATCH is `exit 1` per the script's own header (l.28) and its verdict block (l.389) | 1 |

## Sweep verdict lines (verbatim, last non-empty stdout line)

At `32c35fe` (round-32 replay):

```
SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)
```

exit 1. Byte-identical to the line the round-32 lesson records for itself
(`corpus/lessons/round-32.md:30`) — the replay reproduces the delivered counter's own
BASE reading, independently.

At `76f4eea` (round-33 BASE):

```
SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=2)
```

exit 1. The two hit lines are
`corpus/lessons/round-30-verifier-spotcheck.md:41` and
`corpus/lessons/round-32-verifier-spotcheck.md:54`, both against
`corpus/README.md:64/65/67 (local)` — the two integrator-owned files the plan names.

## Disagreements with the L1 receipt

1. **Rows 5 and 6 (declared, not a receipt error).** The round-32 freeze declared `SD5=3`
   and `total=10`; the counter measures `SD5=1` and `total=8`. This is the intended red
   witness, and my independent read supplies exactly the pair the round-33 C1 target (b)
   expects the new gate to name (`sd5 expect=3 measured=1`, `total expect=10 measured=8`).
   The gate's planned `PREFREEZE: MISMATCH (controls=2 mismatch=2)` is therefore factually
   reachable at `32c35fe`.
2. **`sweep_exit=0` in `base-values.txt` is wrong.** At `76f4eea` the sweep exits **1**
   (its documented contract: any nonzero `n` → `exit 1`; both my runs, at `32c35fe` and
   `76f4eea`, exited 1). The receipt's *verdict line* and all scalar fields agree with my
   measurement; only the recorded exit code does not. Most likely capture artifact
   [INFERENCE]: `$?` read from a pipeline (`… | tee`) rather than from `bash …` itself.
   No plan predicate reads this field, so no target is met/unmet differently — but it is a
   fourth instance of the receipt-records-an-unmeasured-value class this round targets, and
   the frozen receipt should be corrected by the L1 in a commit that names `plans/round-33.md`
   (not by me; I hold no lane write scope).

Everything else agrees exactly: 72 rows, 0 NIST entries, artifact absent, 1 Frontier NIST
line, 0 capabilities rows, and the `n=2` SD6 pair.

## Calibration detail: which round-32 declaration was wrong

The round-32 plan declared six per-check BASE values; my replay at `32c35fe` reproduced five
of them exactly and missed only SD5:

| check | declared @ round-32 freeze | measured @ `32c35fe` | verdict |
|---|---|---|---|
| SD1 | 2 | 2 | agree |
| SD2 | 2 | 2 | agree |
| SD3 | 0 | 0 | agree |
| SD4 | 1 | 1 | agree |
| SD5 | **3** | **1** | differ |
| SD6 | 2 | 2 | agree |
| total | **10** | **8** | differ |

So the estimate error is localized to one cell (SD5: three red ids assumed absent from the
calibration row, one actually absent), not a general drift — useful for sizing the new gate's
value: it catches a single-cell estimate error inside an otherwise correct table, which a
coarse "did the total move" check would also catch but could not attribute.
Note the SD6 residual *moves* between the two revisions: at `32c35fe` the second line names
`corpus/lessons/round-31.md:121` (not a verifier file), at `76f4eea` it names
`round-32-verifier-spotcheck.md:54`. Both totals are 2; the plan's BASE sentence describes
the `76f4eea` state and is correct there.

## Bounds

- The round-32 BASE tree contains **no** `corpus/self-description-sweep.sh` (absent at
  `32c35fe`; added between `32c35fe` and `76f4eea`). The replay therefore necessarily runs
  the lane's delivered counter against the round-32 tree — which is exactly what the M32-2
  red witness means, and why the plan's `round-32.controls.tsv` addresses the script via
  `$LANE` and the tree via `$BASE`. My run used the same split.
- I did not exercise `corpus/prefreeze-control.sh` itself (its `--base`/`--controls`/
  `--selftest` behavior, its `NORESULT` handling, its extraction): that artifact did not
  exist in the working tree at measurement time (absent, as at BASE) and belongs to the other
  seats. My replay validates only the *inputs and expected outputs* the gate will be judged
  against.
- The sources census (`kagi ok`, exit 0) was not re-run: it reads the live working tree while
  the wave edits it, so a reading now is not a BASE reading and is out of this seat's item.
- `base-values.txt` was read as data. Its scalar fields are not trusted anywhere above except
  as the comparison column.

## Declarations

No lane-tracked file was written or modified (`git status --porcelain` shows only untracked
`.ufo/waves/round-33/` paths, none created by this seat except this report and `replay/`).
Read-only git only (`show`/`log`/`archive`/`rev-parse`/`cat-file`/`ls-files`/`status`).
No vault contact (`op` not invoked), no secret or reference read, no handler contact
(expected absence). No network access. No tool installed or upgraded. Scratch dir
`/fast/scratch/hyaku/kagi-r33/ExecReplay/` removed before exit; all receipts copied here
first.

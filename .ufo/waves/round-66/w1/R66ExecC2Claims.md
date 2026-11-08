# R66ExecC2Claims — C2 counter seat, kagi round 66 wave w1

**Status: superseded by Amendment A2.** The C2 instrument at
`plans/round-66-c2.sh` is the L1's `C2_PREFILE` counter (sha256
`2a9101f14a4c5237787badf8b37963d841b2e5d3935c3eea245d1eef2aefe4e1`), not the
`C2_CLAIMS` counter this seat wrote. The seat's bytes are preserved as
history at `./c2-claims-counter-3c6bb7a0.sh.txt` (sha256
`3c6bb7a080ff68706f14f6418ec8ccc2a850637d4a96b6e1fa5d188733087f94`), and
this report is the record of what that instrument measured.

No commit, no push, no mutating git/jj command was run by this seat.

## Why the instrument changed (measured, not assumed)

When this seat started, `plans/round-66.md` ended at "Amendments: None at
freeze." §C2 froze `C2_CLAIMS: exact=…` — compare `claims.json` against the
plan's frozen headings — and I built that counter.

`plans/round-66.md` was then amended in the working tree (mtime
`2026-11-08 06:34:18`, 439 lines; the freeze blob `ddcd46bb` still ends at
"None at freeze", so the amendments are **not** in that commit), and
**Amendment A2** withdrew §C2:

> §C2's `C2_CLAIMS: exact=1` reads **1 on the untouched working tree** — the
> round's `claims.json` already carries the frozen headings and targets, so
> writing it *is* the only work and a do-nothing control reaches the target.
> That is the M65-1 vacuity class.

A2 is right and the measurement is mine: the live reading of my counter on
the untouched tree was `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3
guard=0` — `exact=1` with no work performed. A target a do-nothing control
reaches is the defect class round 65 mined as M65-1; the L1's re-freeze onto
the pre-file gate's `pass` + `claims-declared CLEAN (claims=59)` is not
reachable before the wave settles and the ledger exists.

A2 also quotes this seat's own guard readings (`guard-c prefile=0 rc=2`,
`guard-d claims-declared=0 rc=0 claims=56`) as evidence that the frozen
legs were unsatisfiable at grading time. Both readings are correct; the
counter's fixture run showed the legs *could* read 1 on a conforming tree
(`fixture-full-pass.txt`), but a leg that only passes once the L1's
integration has landed cannot be the claim's own target.

Disposition executed: the A2 instrument restored verbatim at
`plans/round-66-c2.sh` (byte-identical to the L1's file, `bash -n` clean),
this seat's counter preserved as history, and the L1 (`KagiR66`) informed
that Amendment A2/A4 are working-tree-only.

## What the withdrawn counter measured (kept — the shapes are reusable)

`bash plans/round-66-c2.sh [--tree DIR] [--plan REL] [--claims REL] [--selftest]`
derived the expectation from the plan text only:

| source in `plans/round-66.md` | derived field |
|---|---|
| heading `## Ck — <axis>: <suffix>` | axis + title suffix |
| best printed line, restricted to the section's own label tag: (1) backticked `prints `TAG: …``, (2) `Output line: `TAG: …``, (3) line-anchored label | title tag + target body |
| K1's backticked `<name>=<n>` token | `(BASE <literal>)` |

`exact=1` required byte-equal title, byte-equal target, equal axis, entry key
set exactly `{axis,title,target}`, equal claim-id population, and — after a
wave seat's mutant — a wrapped document whose only top-level key is `claims`.

Measured readings on its final bytes (`3c6bb7a0…`), receipts beside this
file:

| reading | result | rc |
|---|---|---|
| live tree (the vacuity A2 names) | `C2_CLAIMS: exact=1 claims=3 titles=3 targets=3 guard=0` | 1 |
| selftest (synthetic fixtures) | `C2_CLAIMS_SELFTEST: PASS (cases=14)` | 0 |
| BASE cross-reading (round-65 plan + claims) | `exact=0 titles=0 targets=0`, C1/C2/C3 named | 1 |
| stale title | `exact=0 titles=2`, `mismatch C2 title` | 1 |
| dropped claim | `exact=0 claims=2`, `missing=C2` | 1 |
| flat extra claim | `exact=0 claims=4`, `extra=C4` | 1 |
| wrapper + sibling note | `exact=0`, `extra-top-level=note` | 1 |
| wrapper + top-level claim | `exact=0`, `extra-top-level=C4` | 1 |
| wrapper alone | `exact=1` | 1 (guards c/d 0 on the fixture) |
| missing claims.json | `SETUP missing-claims` | 2 |
| conforming fixture fleet | `exact=1 … guard=1` | 0 |
| read-only tree copy | same verdicts, no write error | 1 |

Mechanisms worth carrying into the A2 instrument (this seat's offer, not a
patch): the stale-title mutation, the drop/extra-claim population probes,
the wrapper-sibling rule, the read-only no-write proof, and the
case-insensitive `PREFILE-FALSIFICATION: pass` match — Amendment A4 item 1
requires exactly that case-insensitivity, and the withdrawn counter measured
it that way (`PREFILE-FALSIFICATION:\s*pass\b`, `re.I`).

## Defects found against this seat's own bytes (fixed before withdrawal)

1. Predicate label read as the printed body → `targets=0` on an exact tree
   (reported by `R66MutC2`; fixed by the three-tier source rule).
2. `selftest = sys.argv[3]` left the string `"0"` truthy → every main run
   executed the selftest and exited 0 with no verdict (caught by re-run).
3. Relative `$BASH_SOURCE[0]` under `--tree` → rc=127 (reported by
   `R66MutC2`; fixed with `readlink -f`).
4. Wrapper sibling keys survived `as_claims()` → a fourth claim beside
   `{"claims": …}` read exact=1 (input mutant, `R66MutC2`; fixed and
   covered by three selftest cases).
5. guard-b's mutation base and the C3 stale-phrase extraction (reported by
   `R66MutC2`; base is now the live file only when it is exact, and the
   phrase extractor crosses the line wrap).

## External change observed

At 06:35:01 the L1's `C2_PREFILE` instrument replaced the C2_CLAIMS bytes at
`plans/round-66-c2.sh`; this seat misread that as a collision, restored its
own bytes at 06:35:33, and was corrected by `KagiR66` and `R66ExecControls`.
The L1's bytes were restored verbatim at 06:38 and are the live file. The
episode is recorded here rather than argued: the instrument that belonged at
that path was the L1's, and the seat's own bytes now live only in this
receipt directory.

## Receipts

`.ufo/waves/round-66/w1/R66ExecC2Claims/`:

- `c2-claims-counter-3c6bb7a0.sh.txt` — this seat's counter, history
- `c2-prefile-instrument-2a9101f1.sh.txt` — the L1's A2 instrument, verbatim
- `counter-sha256.txt` — both digests and which file each names
- `selftest.txt`, `live-candidate.txt`, `base-crossreading.txt`,
  `k2-stale-title.txt`, `k2-drop-claim.txt`, `k2-wrapper-only.txt`,
  `k2-wrapper-sibling.txt`, `k2-wrapper-toplevel-claim.txt`,
  `k3-extra-claim.txt`, `k4-missing-claims.txt`, `fixture-full-pass.txt`,
  `readonly-nowrite.txt` — the withdrawn counter's readings, each with its
  exit code on the last line.

## Hand-off

- The path holds the L1's A2 instrument; this seat will not write there
  again.
- Integration must commit `plans/round-66.md` itself: Amendments A1–A4 are
  working-tree additions after `ddcd46bb`, which still ends at "None at
  freeze".
- Nothing else is outstanding from this seat.

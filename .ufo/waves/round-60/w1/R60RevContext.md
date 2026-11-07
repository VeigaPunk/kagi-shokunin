# R60RevContext — round-60 w1 report (kagi)

Seat: revenger (calibration, adjacency), leaf member. Read-only: no lane file edited, no git/jj
mutation, no subagent dispatch. Claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`.
Full reconstruction: `.ufo/waves/round-60/build/R60RevContext/intent.md`.

## What I did

Reconstructed the intent behind the seven round-59 routed defects (spot-check §7 D1–D7) from the
round-59 author's own artifacts — the spot-check, the fleet report, `LOG.md` §Round 59,
`.ufo/waves/round-59/w1-results.json`, `final/`, the lesson, `SCORECARD.md`, `SKILL.md`, the
round-59 seat reports and build receipts — then judged the landed round-60 corrections against
(a) the frozen item condition as `plans/round-60-c1-check.py` implements it and (b) the reading a
reader gets without running the checker. I ran the checker read-only (`--no-challenge`, the guard
leg, `--selftest`), the transit selftest from the lane tree, and the checker on the pre-freeze
battery's synthetic fixed tree.

## Judged repairs (landed at this reading)

| id | verdict |
|---|---|
| D1 | **Fact restored.** `LOG.md:1967-1969` states `results=14 dead seats=0`, names `w1-results.json`, keeps the superseded line. An earlier draft re-quoted the literal `__DEAD__`, which would have moved the "last `__DEAD__` line" anchor inside the block; the seat fixed that (the block now says "unfilled dead-seats placeholder token"). Checker `i1 HOLD`. The line uses the guard's `dead seats=` label, which the checker accepts tolerantly; a strict I1 `dead=<D>` reader would not (plan defect, below). |
| D2 | **Count restored, intent lost.** `corpus/lessons/round-59.md:208` states the receipt's 33 and supersedes R31, but the landed line dropped the earlier "no receipt ever read 32" clause and now says only "the routed row's smaller count is superseded". It passes I2, but a reader can read it as "the receipt was 32 and is now 33" — false: the only committed receipt (`selftest.txt:4`) reads 33 and no receipt ever read 32. See `## Mislleading-but-passing` item 1. |
| D3 | **Pending (L1-owned).** No `corpus/lessons/round-60.md` yet; checker `i3=0`. The checker is line-scoped: one **physical** line must contain `R20`, `R21`, `R22` and "duplicate"; the battery's own fixed tree fails I3 because its naming sentence wraps (checker on the battery tree: `i3 FAIL … R20/R21/R22-duplicate-line=no`, K1-REF `1 guard=1`). The lesson must also use bare `R<digits>` ids (`ID_TOKEN_RE = R\d+` reads `R60-01` as `R60`). |
| D4 | **Count restored.** `SCORECARD.md:1980` supersedes the 21 with `20 controls (4 K + 8 C1-F + 8 C2-F)`; checker `i4 HOLD`. Minor provenance loss: the 21 was the 14:16 revision's real 21-id census (including `C1-F7b`), not a pure miscount; the errata calls it an "overcount" without naming `C1-F7b`. |
| D5 | **Pending (L1-owned).** No `supersedes the round-59 gate-evidence pointer` line or round-60/final receipts; checker `i5=0`. Reading risks recorded in intent.md: a `SCOPE …` last line is a summary, not the scope gate's `ADJACENCY_SCOPE:` verdict; the "never written" referent is ambiguous (round-59 receipts vs the round-60 files that must exist); the round-60 receipts measure the round-60 tree, not the r59 tree. |
| D6 | **Pending (L1-owned).** No SCORECARD line containing `75165a07`; checker `i6=0`. The measured-commit reconstruction is in intent.md: the table describes `160caf75…` for C1 (the `c1-driver: measured=revision` line) and an unbound revision for C2 (`c2-landed.txt` has no revision line); `75165a07` carries the receipts, it is not the measured revision. `measured=revision 160caf75…` is the right correction for C1; the C2 half needs the re-run branch or an explicit unbound statement, and I6 does not read it. The I6 anchor does not exist at BASE (`grep -c 75165a07 SCORECARD.md` ⇒ 0); the checker requires the repair to add the anchor before its stating line and forbids the stating line from containing `75165a07`. |
| D7 | **Intent restored.** The transit trial now has a fixture-driven `--selftest`: 9 cases over a stub-`bao` harness (no real `bao`, no network), asserting exit codes and output shapes; `TRANSIT_SELFTEST: PASS (cases=9)` rc 0 (my run and `build/R60ExecTransitSelftest/selftest.txt`). A mutated verdict mapping (BROKEN branch rc=1→0) exits 1 with five `FINDING TRANSIT-ST-SHIM-SHn` lines. The real trial after the edit still reads `HOLDS holds=5 broken=0 error=0`. `SKILL.md:847` now names `--selftest` and the 9-case stub harness, and no longer carries `none — its own five shims`. Checker `i7 HOLD`. |

## Mislleading-but-passing (the list is not empty)

1. **`corpus/lessons/round-59.md:208` (D2).** Passes I2; reads as "the receipt's count was 32 and
   changed to 33". Truth: no receipt ever read 32; the 32 was a lesson transcription error. The
   correct line states the 32 was never in a receipt and the routed row is withdrawn.
2. **`SCORECARD.md:1980` (D4, minor).** Passes I4; the 21 is called an "overcount" with no
   `C1-F7b`/14:16 provenance, so a reader may believe the battery never had 21 controls.
3. **D5 (pending).** A `SCOPE …`-only last line passes I5 without the gate's `ADJACENCY_SCOPE:`
   verdict; a line that says "the gate readings are now receipted" without the r59/r60-tree
   distinction implies the r59 readings are verified; "never written" without a referent can read
   as the round-60 files. The correct line names the r59 receipts as never written, the round-60
   receipts as new readings of the round-60 tree, and the receipt carries the gate's own verdict.
4. **D6 (pending).** A correction stating only the C1 `measured=revision 160caf75…` passes I6 but
   leaves the C2 citation (`75165a07`, `c2-landed.txt`) wrong; a reader may think both claims are
   bound. The correct line states the C1 hash and that the C2 receipt is unbound (or re-runs C2
   at the tip).
5. **D3 (pending).** A line naming `R20`, `R21`, `R22` and "duplicate" without mapping each
   duplicate to its finding passes I3 but leaves the r59 table ambiguous. The correct line maps
   the duplicates (second R20 = the 14:16 citation-gate regeneration failure; second R21 = the
   wrapped-bullet class M59-1; second R22 = the symlink challenge-copy defect).

Not on the list: D1 (the reader sees 0 dead and the authority) and D7 (the selftest is a real
fixture harness; the mutant receipt proves it can fail).

## Plan defects reported, never amended

1. **I1 field vs guard field.** I1 reads `results=<R> dead=<D>`; the guard flips `dead seats=<n>`.
   The checker reconciles both (`RESULTS_LINE_RE = results=(\d+)(\s+)(dead(?:\s+seats)?=)(\d+)`)
   and records the deviation in its docstring and `checker-notes.md`. A strict I1 reader would
   leave the landed `dead seats=0` line unresolved.
2. **I6 anchor absent at BASE.** `SCORECARD.md` has no `75165a07`; the plan's motivating bullet
   mislocates the fleet report's table to SCORECARD. The item is reachable only because the repair
   manufactures its own anchor (self-certifying premise).
3. **I5's `SCOPE` prefix is not the scope gate's verdict.** The gate prints `ADJACENCY_SCOPE: …`;
   I5 reads `SCOPE`. The battery's synthetic fixture uses the prose form, so the battery cannot
   tell a real gate receipt from a hand-written summary.
4. **I3's `R\d+` regex vs the lane's `R<round>-<n>` ids.** The r60 lesson must use bare
   `R<digits>` ids or the id column reads one repeated id.
5. **D6's evidence mislocation.** The plan's motivating bullet says the round-59 Before → after
   table names `75165a07` "in SCORECARD.md"; the table is in the fleet report. The routed defect
   is real in substance; the quoted location is wrong.
6. **I5's `never written` referent.** The line must name three round-60 files that exist and say
   `never written`; a bytes-only check cannot tell whether the phrase qualifies the r59 receipts
   or the r60 files (the scout's A4).

## State at this reading

- Checker diagnostic on the working tree: `value=3 population=7 i1=1 i2=1 i3=0 i4=1 i5=0 i6=0
  i7=1 guard=0`; the three zeros are the L1-owned items not yet on disk.
- Checker `--selftest`: `C1_CHECK_SELFTEST: PASS (37 cases)` rc 0. BASE census (`driver-base-a677c78e.txt`):
  `value=7 population=7`, both legs.
- Battery's synthetic fixed tree: `value=1 … i3=0` (the wrapped I3 naming line); K1-REF reads
  `1 guard=1` for the same reason.
- Transit selftest: `PASS (cases=9)` rc 0; mutant: 5 `FINDING` lines, rc 1; real trial: HOLDS 5/5.

SEAT-STATUS: partial — D1, D2, D4, D7 judged against the landed corrections; D3, D5, D6 are
L1-owned and not on disk at this reading. `intent.md` §Pending conditions gives the checker's
exact requirements; re-run `python3 -I -B plans/round-60-c1-check.py --root . --repo .` after the
L1 lands the lesson and the SCORECARD I5/I6 lines.

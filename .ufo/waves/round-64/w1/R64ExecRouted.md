# R64ExecRouted — wave report

Seat: executor, axes calibration + freshness. Deliverable:
`plans/round-64-routed.sh` — the receipt for the round-63 verifier spot-check's
routed defects D-63-1 (the lookup-table guard vacuum, M63-6), D-63-2 (the C2
nested-battery recursion, M63-LEN) and D-63-3 (the carried reviewer errata).
Work items, not a claim: the round's claims are `C1_HELDOUT` and `C2_REFUSAL`.
Receipt with every command and output:
`.ufo/waves/round-64/build/R64ExecRouted/routed.md`.

## What was written

`plans/round-64-routed.sh` (401 lines, bash + embedded `python3 -I -B`), sha256
`2689cdec055eadd5bb3e5b2881e3432fad1a1fa298e6116ac499b22ca3d0db05`. Three legs,
each able to fail, plus a `ROUTED:` verdict line and the 0/1/2 exit map.

- **`d1` — D-63-1.** Requires `plans/round-64-c1.sh` (or its build receipt) to
  name the A4 vehicle and code a `vehicle` leg; re-derives the vehicle
  **independently** (its own literal table of the committed tables' replacement
  strings, constant `PASS (cases=91)`, `value=1` on a hit) and requires
  `accepted=0 rejected=0` on the round-63 tables (so it *is* a vehicle) while
  `heldout>=1` on the sealed held-out set (`h`/`q` split printed). Verifies the
  held-out sha256 first; a seal mismatch reads `d1=0 seal=mismatch`, never a
  pass and never a hidden SETUP. A counter with no vehicle leg reads `d1=0`.
  Cost is small: the vehicle reads only `LOG.md`, `plans/round-60.md`,
  `corpus/lessons/round-60.md` (measured: the counter's vehicle also reads
  `SKILL.md`, which carries 0 of the 15 table strings), so its fixture trees
  are ~1 MB roots, not 24 full-tree copies.
- **`d2` — D-63-2.** One `timeout 1200` invocation of
  `<copy>/plans/round-64-c2.sh --tree <copy>` on a single `cp -a` scratch copy
  (with `.git`, so the copied counters' `git archive` legs behave identically)
  must print exactly one `C2_REFUSAL:` line with rc 0/1; then
  `C2_RECURSION_BOUND=0 timeout 240` must print none and exit 124. Each half
  runs in its own session and the process group is killed on timeout, so a
  recursive child cannot outlive the leg. A hanging tree reads `d2=0`.
- **`d3` — D-63-3.** The six round-63 final receipts must exist with their
  label lines and be cited (lesson §Routed dispositions D-B row + `LOG.md`).
  Nothing is substituted for an absent receipt: it is named and reads `d3=0`.

## Measured

| tree | `ROUTED:` | rc |
|---|---|---|
| the lane tree, run alone (authoritative) | `d1=1 d2=1 d3=0` | 1 |
| `golden` fixture (all three legs satisfiable) | `d1=1 d2=1 d3=1` | 0 |
| `d1-no-vehicle-leg` (counter prints the target line, no vehicle leg) | `d1=0 d2=1 d3=1` | 1 |
| `d1-fresh-lookup` (committed table extended with the five held-out H rows) | `d1=0 d2=1 d3=1` | 1 |
| `d2-hang` (counter re-enters on both paths) | `d1=1 d2=0 d3=1` | 1 |
| `d3-no-controls` (the missing `controls.txt`) | `d1=1 d2=1 d3=0` | 1 |

The authoritative lane reading (`2026-11-08T03:58:01-03:00`, 8m34, counters
`round-64-c1.sh` `e03a4d6…` / `round-64-c2.sh` `e2d8171…`):

```
routed-leg d1: counter=ok src=counter+receipt a4=1 lookup=1 seal=match table=15 r63 accepted=0 rejected=0 heldout_vehicle=5 h=5 q=0 setup_bad=0
routed-leg d2: bounded lines=1 rc=0 line=[C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)] unbound lines=0 rc=124 bound_off=1
routed-leg d3: receipts=5/6 absent=controls lesson-db=1
ROUTED: d1=1 d2=1 d3=0
```

So D-63-2's landing is real end-to-end: one bounded invocation reached
`killed=5 population=5 guard=1 … terminates=1 bound=1`, rc 0, in 8m34s, and
with `C2_RECURSION_BOUND=0` under `timeout 240` it produced no verdict line
(rc 124). D-63-1's instrument is in place and the A4 vehicle is refused on the
held-out set (`heldout_vehicle=5`: the five H forgeries accepted and the three
Q benign rewrites also accepted — the vehicle never rejects, so it reaches 5,
not 0). D-63-3 reads 0 (finding 1).

The vehicle re-derivation on the committed tables (`table=15`) reads
`unmodified value=0`, every H row `value=0` and every Q row `value=0`, i.e.
`h=5 q=0`. None of the eight H/Q replacement strings is, or contains, a
committed table string (measured), so the held-out set is not vacuous.

## Findings (reported, not amended)

1. **D-63-3's "six receipts (present)" is off by one.** Five of the six exist;
   `.ufo/waves/round-63/final/controls.txt` does not (`git ls-files` lists
   five). The round-63 LOG records why: the battery's full candidate run
   re-enters the C2 recursion and was scrapped as the candidate receipt. So
   D-63-3 is not "nothing open" — its controls receipt is a casualty of
   D-63-2's ceiling. `d3` reads 0 and names it; the disposition (land a bounded
   `controls.txt`, or record the receipt as superseded by the round-64 bounded
   battery) is the L1's. The other five receipts are present with their label
   lines and are cited (the lesson names them by stem in its D-B row; it cites
   `c1-residual.txt` and `c2-refusal.txt` by full path).
2. **The C2 counter's guard/kill fields are load-sensitive; the termination
   claim is not.** Run alone, the leg reproduces `killed=5 … guard=1 …` exactly.
   Two runs taken while this seat had four other measurements in flight read
   `killed=5 guard=0 real=0` and `killed=3 guard=0 selftest=0 …`, with the same
   one verdict line and the same `terminates=1 bound=1`. Isolated, the
   components pass (`C2R64_SELFTEST: PASS (cases=21)`; `C1_COUNTER_SELFTEST:
   PASS (15/15 checks)`), and the C2 seat's own isolated receipt reads
   `killed=5 guard=1 … terminates=1 bound=1` at 501 s. The mechanism is the
   counter's fixed windows (`timeout 5` on the fixture-battery composition) and
   the real trial's readiness loop. The L1 should take the integration reading
   on a quiet host and record it verbatim; a `guard=0` under load is not
   evidence the bound failed.
3. **Named ceiling on `d2`.** A stub that prints one `C2_REFUSAL:` line and
   exits 0 passes `d2=1` (the `golden` fixture is such a stub). Stub refusal is
   the counter's own selftest/guard and `plans/round-64-controls.sh`, not this
   leg.
4. **Named ceiling on `d1`.** `d1` proves the instrument exists and that the A4
   vehicle is refused on the held-out set; it cannot prove the counter's leg is
   wired to its verdict rather than printed (the counter's `--selftest` and the
   controls battery carry that). And the plan's own ceiling stands: a lookup
   table carrying a new entry per held-out fixture would still reach
   `heldout=0` — the `d1-fresh-lookup` fixture demonstrates this leg refuses
   that table, which is a statement about the derivation, not a grammar proof.
5. **Operational note.** No edits to sibling files, no `git`/`jj` mutation, no
   `/tmp` evidence. A bash script must not be edited while a process is
   executing it: one fixture run (the first `d2-hang`) was polluted by an edit
   made during its execution and printed a shell parse error after its verdict;
   it was discarded and every reading above was re-taken on the frozen
   `2689cdec…` bytes. No tool was installed or upgraded (no pacman, no `uv`).

## Files

- `plans/round-64-routed.sh` (new, 401 lines) — the routed receipt.
- `.ufo/waves/round-64/build/R64ExecRouted/routed.md` — every command, every
  output, the fixture construction, the findings in full.
- `.ufo/waves/round-64/w1/R64ExecRouted.md` — this report.

Scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ExecRouted/`
(fixtures, vehicle roots, copy probe, d2 copy) deleted before yield.

SEAT-STATUS: complete

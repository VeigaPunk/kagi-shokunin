# R66ExecControls — pre-freeze control battery (kagi round 66, attempt 1)

Seat: executor, one file owned — `plans/round-66-controls.sh`. Receipts in
`.ufo/waves/round-66/w1/R66ExecControls/`. No other lane path written; no
git/jj mutation; no tool installed.

## What landed

`plans/round-66-controls.sh` (sha256 `9f0c614a…6a0f11a`): nine controls, three
per claim — one no-work, one forgery, one valid — plus one prior-battery
regression row. Every claim is measured by the mechanism its amended predicate
names, not by a re-interpretation:

| claim | measurement (predicate as amended) | predeclared failure |
|---|---|---|
| C1 (§C1 + A1) | `plans/round-66-c1.sh --tree T --scratch S --base-tree B` | `drift=0` on a byte-identical BASE tree |
| C2 (A2 + A4) | fleet `prefile-falsification.py --lane kagi --round 66` **and** `corpus/claims-declared.sh --root T` | not-`pass` with `findings>=1` at BASE |
| C3 (A3) | lane gate `corpus/sources-census.sh verify --root T` | `FAILED (findings>=1)` at BASE |

Control contract, per claim:

- **NOWORK** — the claim's own command run on a `git archive d549ee6` extraction
  (materialized once under scratch, laid out as `<fleet>/kagi-shokunin` so the
  pre-file gate resolves it as it resolves the real lane). The frozen failing
  value must read back. A do-nothing tree that reaches the target is reported
  by name (M65-1 class), never smoothed over.
- **FORGE** — a mutated copy the mechanism must refuse:
  C1 repoints the registry + fetch anchor strings at
  `.ufo/waves/round-64/capture/S148.body` (A1 guard (d)) and requires
  `drift=0` **with** `digest-mismatch` naming that path; C2 deletes one claim's
  rows from a ledger copy and requires `FINDING claim-uncovered` + exit 1;
  C3 deletes the `cites:` line from a knowledge entry and requires
  `findings>=1`.
- **VALID** — the instrument's self-test passes **and** the measured tree prints
  its verdict with the guard set. This is the "not a blanket refusal" leg: it
  fails, naming the red guard leg, when the tree has not yet earned the claim.

## Retained evidence

`.ufo/waves/round-66/w1/R66ExecControls/`

- `controls-live.txt` — full battery on the lane tree: `SKIPS: 1`,
  `CONTROLS: match=8 mismatch=1`, rc 1.
- `selftest.txt` — `CONTROLS_SELFTEST: PASS (cases=29)`.
- `instruments.sha256` — the battery and every instrument it measures, by digest
  (counter `221a2cd7…`, round-64 battery `e37d497d…`, lane census `e9ae2620…`,
  claims-declared `dae84157…`, pre-file gate `1e1427dd…`).

Live readings (verbatim in the receipt):

```
C1-NOWORK  drift=0 on BASE                          match
C1-FORGE   wrong-path anchor → drift=0, digest-mismatch named   match
C1-VALID   selftest pass; guard=1; drift=1           match
C2-NOWORK  BASE gate setup findings=4                match
C2-FORGE   skip — no claim-falsification.tsv filed yet
C2-VALID   gate=setup findings=3; declared=56        MISMATCH
C3-NOWORK  BASE census FAILED findings=4 rows=155    match
C3-FORGE   cites: removed → findings=8 FAILED        match
C3-VALID   census CLEAN findings=0 rows=156          match
PRIOR-SELFTEST  round-64 fixtures PASS (cases=36)    match
```

## The one mismatch, and why it is the right reading

`C2-VALID` fails at this moment, naming exactly what is missing: the wave has
not yet filed `w1-results.json`, `claim-falsification.tsv` or
`.ufo/reports/round-66/kagi.md`, and `claims-declared` reads `claims=56` against
the target 59. That is A2's target unearned, not a defect in the control — the
receipt prints the three `FINDING` lines that stand between the tree and `pass`.
`C2-FORGE` skips for the same reason (a ledger that does not exist cannot be
mutated), and says so instead of passing vacuously.

## Operability

```
bash plans/round-66-controls.sh              # measure this lane's tree
bash plans/round-66-controls.sh --tree DIR   # measure another tree
bash plans/round-66-controls.sh --selftest   # fixtures only, no lane instruments
```

Exit 0 iff no mismatch, 1 on any mismatch, 2 SETUP. `R66_CONTROLS_RECEIPT`
re-points the receipt; `R66_CONTROLS_BASE_TREE` supplies a pre-extracted BASE
tree; `R66_PROBE_TIMEOUT` bounds each instrument. Scratch is
`$HYAKU_SCRATCH/kagi-r66/R66ExecControls/`, `TMPDIR` is exported into it, and
it is removed on exit (`R66_CONTROLS_KEEP=1` keeps it for debugging).

The `--selftest` is 29 fixture cases and needs no lane instrument: it pins the
three verdict-line parsers (including A4's lowercase `pass`), the accounting
contract, and five end-to-end fixtures — a BASE-value tree, a claim-met tree, a
do-nothing tree that wrongly reaches the target (the NOWORK control must catch
it), an instrument-free tree (everything skips, nothing passes), and a
prior-battery row.

## Things the L1 should know

1. **The plan moved under this seat.** `plans/round-66.md` gained A1–A4 in the
   working tree after the freeze commit `ddcd46b`. The battery was re-targeted
   to the amended predicates (C1 keeps its counter; C2 and C3 are measured by
   the lane's own gates). Anything reading claim text must read the working
   tree, not the commit.
2. **Two error classes this battery caught in itself, before landing.** The
   first draft's NOWORK leg measured the *live* tree and called it BASE — that
   is M65-1 in the control layer, and it would have reported a passing
   do-nothing control. It also lost instrument exit codes by capturing them
   inside a command substitution, which made a non-terminating counter read as
   success. Both are fixed and both are pinned by fixtures
   (`fx-e-nowork-mismatch`, `fx-ok-c2forge-match`).
3. **C1's own provenance shape drives the C1 forge.** The control reads the
   counter's `c1-carrier: row=<id> path=<p>` line. A counter that renames that
   line makes the control `skip no-carrier-binding` — loud, never a silent
   pass. Named ceiling, not a hidden coupling.
4. **`plans/round-66-c2.sh` is not this seat's file.** It was classed a path
   collision at 06:35 while I worked; I never wrote it. Per R66ExecC2Claims the
   C2_PREFILE bytes belong to the L1. My C2 controls do not consume that file
   at all, so the collision does not touch this battery either way.

## Risks

- `C2-VALID` and `C2-FORGE` flip only after the L1 files the wave results,
  ledger and report, and adds the three `claims-declared` rows plus the
  `## Round 66 — post-move` SCORECARD section (A4 item 2 measured that both
  surfaces are required). Until then the battery reads `partial` by design.
- `C1-NOWORK` asserts `drift=0` only; the BASE `match` field currently reads 0
  (no binding exists to refuse), which is correct for a do-nothing tree but
  means the NOWORK leg does not pin `match` parity.
- The BASE fleet layout assumption (`<fleet>/kagi-shokunin`) is the gate's own
  resolution. If the gate gains a `--root`, `ensure_base_tree` can drop the
  layout trick.

## Tooling

None installed. bash, coreutils, python3 from the host.

Report: .ufo/waves/round-66/w1/R66ExecControls.md

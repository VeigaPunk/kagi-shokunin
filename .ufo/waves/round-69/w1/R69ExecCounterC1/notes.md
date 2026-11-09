# C1_RECORD counter — guard evidence (what each guard proved)

Counter: `plans/round-69-c1.sh`. Frozen predicate: `plans/round-69.md` §C1.
Receipts in this directory are the observable evidence; this note records what
each guard measured and how.

## How to re-run

- `bash plans/round-69-c1.sh --selftest` → `selftest.txt` (29 cases).
- BASE control: `git -C <lane> archive 264917aa | tar -x -C <scratch>` then
  `bash plans/round-69-c1.sh --tree <base> --verbose` → `run-base.txt`.
- Candidate: `bash plans/round-69-c1.sh --tree . --verbose` → `run-candidate.txt`,
  `legs-verbose.txt`.

## Guard (a) — Amendment A2 surface map

`plans/round-68.md` must carry `## Amendment A2 — post-closure repairs
(round 69)` whose body (from that heading to EOF) names every changed surface
with old → new. The counter checks the heading text and requires, in the body:
`SCORECARD.md`, `corpus/lessons/round-68.md`, `LOG.md`, `base-derivation.md`,
`claims.json`, `predicate_ok`, `R68-02`, `QUALITY.md`, the `→` arrow and the
words old/new.

- BASE: heading absent → guard (a) = 0.
- Candidate: heading present, all eight surfaces named with old → new → 1
  (R69ExecRecord's A2 append, `a2.txt`).

## Guard (b) — the candidate prints its own zero line

The unmodified measured tree must read `mismatches=0` with guard (a) = 1.
Mid-wave it reads `mismatches=2` (L11/L12 pending, below), so (b) = 0. This is
the honest mid-wave state, not a bug: the QUALITY bar and the wave settlement
have not landed.

## Guard (c) — no-work control (`mismatches=13` at BASE)

On the `git archive 264917aa` extraction every leg must fail with its mismatch
detail. Measured: all 13 legs fail (see `run-base.txt` verbose), verdict
`C1_RECORD: mismatches=13 population=13 guard=0`, exit 1. At BASE the L9 row
names the 3600 s round-68 counter; the non-executing conjuncts fail first
(no journal) so that command is **never executed** — measured wall time is a
few seconds, not 3600.

## Guard (d) — decoy control (L1 section scoping)

A scratch copy relocates the L1 honest-stop repair: `unprovable` is stripped
from the round-68 calibration row (`RELOCATED-TO-R67`) and the honest-stop text
is planted in the round-67 calibration row. Then only `LEG L1` is evaluated in
subset mode on that copy. It must read `fail`.

- Candidate: `GUARD d=1, decoy-L1-fail=1, relocated=1` — the relocated text in
  round-67 does not green L1, which is scoped to the round-68 section.
- BASE: the plant alone still fails L1 (`relocated=0`, vacuous but consistent).
- A whole-file keyword scan would false-pass here; the counter parses the
  `## Round 68 — post-move` section and its `| calibration` row only.

## Guard (e) — misplacement control (L3 file scoping)

A scratch copy removes the lesson's `## Correction (round 69)` block and plants
an equivalent correction in `LOG.md` (which is L4's file, not L3's). Then only
`LEG L3` is evaluated. It must read `fail`.

- Candidate: `GUARD e=1, misplace-L3-fail=1, relocated=1`.
- L3 reads `corpus/lessons/round-68.md` only; the LOG copy does not green it.

## Guard (f) — selftest (≥ 12 cases, constant-verdict mutant, sub-population)

`--selftest` prints `C1_RECORD_SELFTEST: PASS (29 cases)`, N = 29 ≥ 12.
Fixture coverage includes:

- the constant-verdict mutant: a fixture tree whose SCORECARD prints the
  frozen target line without reading must still fail L1 (section-scoped parse,
  not a literal search), and a tree naming the target cannot green
  (`constant-verdict-prints-target-still-fails-l1`);
- a sub-population case: a tree satisfying only one leg reads 0 of 1 on that
  leg (`sub-population-fixture-refused`); the verdict aggregation is
  `POP = 13 = len(LEG_ORDER)`;
- the L2 empty-set non-vacuity pair (reviewer A7): naming nothing fails, and
  the explicit empty-set statement passes;
- the L5 both-counters pair: naming only one BASE reading fails; naming both
  passes;
- the L9 cost bound: without the journal the row's command is never executed
  (proved with a `touch` marker file that must not appear), with the journal
  the row executes and matches its expect;
- the L4 no-re-run case (M69-5): the count is parsed from the committed
  receipt bytes only; the counter never shells to the round-68 counter's
  selftest (whose live count, 59, has drifted from the committed 56).

## Cost and constraints

- Measured wall time: selftest a few seconds; BASE full run a few seconds;
  candidate full run a few seconds (well under the ~120 s ledger budget).
- Never runs `corpus/claim-ledger.sh verify`; never runs
  `plans/round-68-c1.sh --selftest`. `grep` of the counter source for both
  returns no executable invocation.
- L9 executes the row's own command with the row's own timeout **only** when
  the non-executing conjuncts (exactly one row, literal anchored expect,
  journal old_expect present) all hold. The row's command here is
  `bash plans/round-69-c1.sh --tree . --legs L1,L3`, which cannot recurse
  (subset mode without L9 is exempt from the nested-invocation refusal; the
  full mode is refused under `R69_C1_NESTED=1`).
- Guards (d)/(e) run only the leg they test, in subset mode, on scratch copies.
- No network; bash + python3 stdlib only; no writes outside `--scratch` and
  stdout.

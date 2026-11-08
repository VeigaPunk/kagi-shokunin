# R64Critic — attack report (C1 calibration, C2 operability)

Seat `R64Critic`, kagi round 64 attempt 2. Read-only over the lane; every probe ran on a copy in
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64Critic/` (deleted before yield). No lane commit,
no mutating git/jj, no host mutation, no tool installs. Full evidence, commands, tables and the
per-fixture census: `.ufo/waves/round-64/build/R64Critic/critique.md`.

**Seal disclosure.** I read `plans/round-64-heldout.tsv` to build falsification probes — not for
the checker's benefit, and no row of it appears here. The C1 checker seat's prohibition is
untouched by me; **C1-1** is a leak that does reach that seat through a permitted file.

Measured this session: the seal sha `b0f51e2a…93c2` re-derives; all 20 held-out rows re-derive on
a slim tree (19 agree with `census-a1.md`, P4 differs); `heldout=8` at BASE is real;
`C2R63_SELFTEST PASS (cases=13)`, `CONTROLS_SELFTEST PASS (cases=25)`, `C1_HELDOUT_SELFTEST PASS
(cases=19)`, `C2R64_SELFTEST PASS (cases=21)`; `c2-e2e-head.txt` = `rc=124`; `--fleet` is accepted
by the BASE checker (M63-9 closed); the wave is 16 seats with attack 4/16 = 25 % (B-2 closed).

## Findings — high

- **C1-1 the seal leaks through the committed census.** `R64ExecC1Grammar`'s prompt forbids the
  sealed table and directs the seat to `.ufo/waves/round-64/base/census-a1.md`, asserting it "names
  each class, not each fixture string". Measured: **6 of 8** held-out distinguishing strings appear
  verbatim in that committed file (F2 `, which is not the case`; F8 `, the record denies it`; F10
  `and, seen elsewhere, 4/16 = 25 %`; B4 `a different seat than`; P6 `— not the other way round —`;
  B5 `not less than`; P7's full replacement inclusive parenthetical at `:43-45`), and the other two
  (F6 duplicated mechanism, the same P7) are described precisely. A seat can therefore build an
  8-entry lookup, reach `heldout=0 guard=1`, and truthfully report it never read the seal.
  **Fix:** redact the census to class-level prose, re-commit, point the seat at the redacted file,
  and have the L1 grep the seat's checker for the redacted string set (`leak=0` required).
- **C1-10 guard (c)'s 600 s budget is below the instrument it measures.** `leg_resid` runs the
  round-63 counter on the slim tree under `RESID_TIMEOUT=600`; one checker invocation on that tree
  costs **26.08 s** (measured) and that counter makes 25–26 expensive invocations ⇒ **652–678 s
  derived**; a direct end-to-end run was still running at my 300 s shell cap with no verdict line.
  `leg_vehicle` pays the same cost again. Result: `RESID=0` by timeout on a perfect candidate ⇒
  `guard=0` ⇒ the C1 target is unreachable. **Fix:** raise the budget above the measured total, or
  measure only the round-63 measure leg (17 invocations ≈ 450 s); record seconds in the receipt.
- **C2-1 the landed guard (d) is not the frozen guard (d), and the frozen one is unsatisfiable.**
  The battery's fixture-only branch (`round-63-controls.sh:571-584`) skips `probe_counters` and
  `ctrl_prior`; since `C1_HAVE`/`C2_HAVE` are set only in `probe_counters` (`:459/:461/:469`), the
  four NOWORK/REAL controls all `report_skip` and **no `PRIOR-*` row is emitted** ⇒ the only
  terminating battery run emits `SKIPS: 4`. The landed counter instead measures
  `round-62-controls.sh --selftest` (a different, fixture-driven battery) — a constant leg. Either
  the frozen text is unimplementable or the frozen leg was silently substituted. **Fix:** report the
  predicate defect; implement guard (d) as "the fixture-only run exits 0 (mismatch=0) with skips
  named and counted".
- **C2-2 the bound lives in the measured tree, not in the counter.** `plans/round-64-c2.sh:328`
  calls `battery_run` with **no timeout**; the only bound is `R63_CONTROLS_FIXTURE_ONLY=1`, which
  the *tree's* battery must honour (entire effect: one `if` at `round-63-controls.sh:571`; the
  `round-63-c2.sh:198` pass-through is inert on this path). A tree with an unpatched battery
  (including BASE) hangs the counter until the external `timeout 1200` — so `terminates 0→1`
  measures "the tree carries round-63's patched battery", and two round-63 instruments changed with
  no `supersedes` row or registry re-pin (`SKILL.md:878/879` still pin the old tallies). **Fix:**
  give `battery_run` its own timeout; record both new hashes and add a `supersedes` note.

## Findings — medium

- **C1-2** the frozen counting rule does not require fail-closed: a checker that prints *nothing*
  on the forged rows measures `heldout=3` under the literal rule (5 H invisible; measured), and
  `heldout=0` if it also swallows the benign rows. The landed counter **does** fail closed
  (`measure_heldout` → `AF_ERR` → `setup_die`), but nothing in the predicate mandates it. Fix: pin
  it in the registry row and one `--selftest` case.
- **C1-3** separability margin is **one token**: exhaustive threshold search over three features
  bottoms out at `heldout=2` (monotone length rule closes 5/5 forgeries, misrejects P6/P7); B4 Δ=4
  vs B5 Δ=3, F2 Δ=5 = P6 Δ=5. One rule plus two exceptions reaches 0 with no polarity reasoning.
  Fix: name it in the ceiling list; have the counter print which i-bit failed per H row (distinct
  items are the grammar's signature).
- **C1-4** fixture ids `F1..F10/P1..P6/B3..B5` are reused by `round-63-residual.tsv`/`-benign.tsv`
  **with entirely different fixtures**; the frozen predicate names ids only. Fix: use the plan's
  `H1..H5/Q1..Q3` labels in every derived artifact and qualify the table.
- **C1-6** C1 is coupled to a C2 script: stripping `plans/round-60-c2.sh` makes the unmodified copy
  read `value=1 i2=0` (measured), and the checker executes that counter's `--selftest` twice per
  invocation. **Answering the separability question: yes, C1 needs a C2 file**; the plan declares
  no such dependency.
- **C1-8** guard (e) refuses the vehicle's needle, not its class: a 23-entry table (16 committed +
  8 held-out) passes every leg; round-63's `chal` leg is absent from the round-64 guard.
- **C2-3** the predicate's leg-sum cross-check ("killed equals the sum measured by the round-63
  counter's own selftest legs on the same tree") is unimplemented — `killed` is self-reported.
- **C2-4** l3/l4 are near-constant: the stub's target line is compared to hard-coded BASE
  constants, so any tree carrying the battery reads `mismatch`; under the bound they are also
  measured on a battery whose probe was skipped.
- **C2-5** the C2 guard is self-reported: plan (b) is not a counter guard at all (it is
  `ctrl_c2_bound` in the battery, `round-64-controls.sh:542`), plan (c) is implied not asserted, and
  plan (d) is substituted. A stub that prints the frozen line and sleeps under bound=0 satisfies
  every counter-side guard; the refusals (`C2-F7`, `C2-NOWORK`) sit outside the predicate.
- **C2-7** guard (c) depends on `$HOME/.local/bin/bao` (sha prefix `9c5f3628…`, matching
  `PIN_BAO`) and on the tree's `plans/round-57-c2.sh`; undeclared in round 64's plan.

## Findings — low

- **C1-5** the plan text carries no seal step (the landed counter does; the round-64 battery only
  comments that it never reads the table — its receipt pins no sha). Fix: emit the seal sha in the
  battery receipt.
- **C1-7** the plan floor (`cases>=91`) and the counter floor (`>=109`) disagree: a 91–108-case
  checker satisfies the frozen plan and fails the instrument.
- **C1-9** `census-a1.md`'s P4 row (`value=1, i2=0`) does not reproduce on the documented slim tree
  (measured `value=0`, all bits 1). P4 is outside H∪Q, so the claim is unharmed.
- **C2-6** `killed=5` keeps the five leg ids, but l3/l4's measured artifact changed (full battery →
  fixture-only battery); K3 only voids a *dropped* leg.

## Do-nothing control verdict

- **C1: the byte-identical no-work control does NOT meet the target** — measured `heldout=8`
  (unmodified `value=0`; five H rows `value=0`; three Q rows `value>=1`) and `guard=0` (its 102
  cases are under the counter's 109 floor). Adding seven dummy selftest cases flips `guard` to 1
  without moving `heldout`. **The cheapest control that DOES meet it is a no-grammar lookup fed by
  the committed census** (C1-1): BASE behaviour on the 16 committed fixtures plus an 8-entry table
  reads `heldout=0 guard=1`, and the A4-vehicle leg still reads `heldout=5` because it is a
  different table. The error/crash shortcut is refused by the landed fail-closed measure leg (C1-2).
- **C2: the byte-identical no-work control does NOT meet the target** (no verdict line; the battery
  re-enters). **The cheapest control that does meet it is a stub** — print
  `C2_REFUSAL: killed=5 population=5 guard=1 (… terminates=1 bound=1)` and sleep when
  `C2_RECURSION_BOUND=0`: that satisfies the predicate's literal text and the landed guard (a)-(d),
  and only the battery's out-of-predicate controls refuse it. So the C2 target is reachable without
  bounding any recursion, and neither the plan nor the counter's guard says so.

## Impacted axes

calibration: C1-1, C1-2, C1-3, C1-4, C1-6, C1-8, C1-10. operability: C2-1, C2-2, C2-3, C2-4, C2-5,
C2-7. C1-5/C1-7/C1-9/C2-6 are declaration or record defects, not axis harm. Disposition C1-1,
C1-10, C2-1 and C2-2 before the candidate reading: C1-1 decides whether the C1 claim can be worded
as it stands, C1-10 whether its guard can read 1 at all.

SEAT-STATUS: complete

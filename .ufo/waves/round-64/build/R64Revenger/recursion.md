# R64Revenger — C2 recursion reverse-engineering (round 64, BASE 09cbee8)

Seat: R64Revenger. Scope: read-only reverse-engineering of the round-63 C2
counter recursion; measured depth on a scratch copy; per-cycle verdict on the
plan's proposed bound (`C2_RECURSION_BOUND` + `R63_CONTROLS_FIXTURE_ONLY`).
Lane files read at BASE: `plans/round-63-c2.sh` (240 lines),
`plans/round-63-controls.sh` (590), `plans/round-62-controls.sh` (904),
`plans/round-62-c2.sh` (331), `plans/round-62-c1.sh` (484),
`plans/round-61-c2.sh` (478), `plans/round-63-c1.sh` (660),
`plans/round-64.md` §C2, plus `plans/round-64-controls.sh` (668) for the
round-64 wiring. No lane file modified. Held-out file NOT read (seat discipline;
recursion analysis needs no fixture bytes). Tooling: none installed; bash,
python3, `ps`, `wc`, `du` only (RULES.md read first; no pacman/uv used).

## 1. Call graph (as it exists at BASE, with line numbers and conditions)

Notation: `Caller:LINE -> Callee [mode] (condition)`. All paths are
`plans/<script>` unless noted. `TREE` = `--tree` argument; `CAND` = battery's
tree argument; `WORK`/`SCR` = per-run scratch (removed on EXIT).

### 1.1 plans/round-63-c2.sh (C2R63) — 8 invocations

| Edge | Line | Callee | Mode | Governing condition |
|---|---|---|---|---|
| C2R63 -> C1R62 | 180 | `plan/round-62-c1.sh` (in `$WORK/l1` full-tree copy) | `--selftest --tree $TREE` | unconditional in verdict mode (leg l1); `L1_OK` needle must match exactly once or SETUP |
| C2R63 -> C1R62 | 192 | same (in `$WORK/l2` copy) | `--selftest --tree $TREE` | unconditional (leg l2); needle guard `setup_die needle-l2` |
| C2R63 -> CTL63 | 198 | `plans/round-63-controls.sh` | `<tree>` (full battery) | `if [ -f $TREE/plans/round-63-controls.sh ]` (L197); legs l3/l4 read from its `CONTROL C2-F6/C1-F8` lines |
| C2R63 -> checker | 219 | `plans/round-61-c1-check.py` | `--selftest` | unconditional (leg l6) |
| C2R63 -> C1R62 | 225 | `$TREE/plans/round-62-c1.sh` | `--selftest --tree $TREE` | unconditional (guard a) |
| C2R63 -> C2R63 | 227 | `$TREE/plans/round-63-c2.sh` | `--selftest` | unconditional (guard b); self-invocation, child is fixture-only (L100-146 early exit) — mode-guarded, terminates |
| C2R63 -> C2R62 | 229 | `$TREE/plans/round-62-c2.sh` | `--tree $TREE` | unconditional (guard c; real trial + G + M-A/M-B; heaviest leg) |
| C2R63 -> CTL62 | 232 | `$TREE/plans/round-62-controls.sh` | `--selftest` | unconditional (guard d); fixture-only, terminates |

C1R62 (`round-62-c1.sh`) runs the checker (`round-61-c1-check.py`) on fixture
copies and its own stub legs; it never invokes C2R63, CTL63, or CTL62. It is a
DAG leaf (heavy: tar-copies the tree per fixture, 5 B + 3 P + stub trees).
C2R62 (`round-62-c2.sh`) invokes C2R61 only (L232 `--selftest`, L281/L293
mutant `--selftest`, L304 stub-tree `--tree`, L313 real-trial `--tree`); no
back edge. C2R61 (`round-61-c2.sh`) invokes trial runs (L339/L346,
`openbao-seal-trial.sh` under `timeout 900/300`) plus its guarded stub leg
(L440, `R61_C2_NOSTUB=1` self-invocation, depth ≤2) and selftest cases
(L231-233, `--tree` on empty dirs, terminating). CTL62 (`round-62-controls.sh`)
invokes C2R61 (probes L466 `--selftest`, mutants L532/L546/L712, stub-tree
trials L557/L736, real trial L762 `timeout 2400`), C1R62 (L633/L644,
`ctrl_c1_f6`), and C2R62 (L803/L807, `ctrl_c2_f5`); no back edge to CTL63 or
C2R63.

### 1.2 plans/round-63-controls.sh (CTL63), main() L534-568

| Edge | Line | Callee | Mode | Governing condition |
|---|---|---|---|---|
| CTL63 -> C1R63 | 452 | `$C1_INSTR` (=`plans/round-63-c1.sh`) | `--tree $CAND`, `timeout 2400` | `probe_counters()`, `if [ -n $C1_INSTR ] && bash -n` (L450); shared by NOWORK/REAL controls |
| CTL63 -> C2R63 | 460 | `$C2_INSTR` (=`plans/round-63-c2.sh`) | `--tree $CAND`, `timeout 2400` | `if [ -n $C2_INSTR ] && bash -n` (L458); same `probe_counters()` |
| CTL63 -> CTL62 | 324 | `plans/round-62-controls.sh` (on `$snap` copy) | `<snap>`, `timeout 2400` | `ctrl_prior()`, `if [ ! -f $CAND/$PRIOR_REL ]` skip else unconditional (L315-318) |
| CTL63 -> stub | 375 | stub copy of C1R63 | `--tree $CAND`, `timeout 60` | `ctrl_c1_f8`; stub dispatch intercepts every non-selftest invocation and exits 0 — no recursion |
| CTL63 -> stub | 412 | stub copy of C2R63 | `--tree $CAND`, `timeout 60` | `ctrl_c2_f6`; same stub shape — no recursion |

`main()` order (L561-568): `probe_counters` (C1 then C2) -> stub controls ->
NOWORK/REAL -> `ctrl_prior`. The C2 probe is the only CTL63 edge that can
return to C2R63. `--selftest` (L87-91) routes to `selftest_main()` only
(fixture trees; L256/L283/L294 run the full battery on fixture stubs, not
counters — bounded, no recursion).

### 1.3 plans/round-61-c2.sh self-loop (NOT a cycle — mode-guarded)

`stub leg (L402ff) -- if [ "${R61_C2_NOSTUB:-}" != 1 ] -> L440
R61_C2_NOSTUB=1 bash $SELF --tree $SCR/stubtree`. The inner invocation sees
`R61_C2_NOSTUB=1` and skips its own stub leg. Depth ≤2 by construction.
Similarly C2R63 L227 spawns `--selftest`, which exits at L100-146 before any
leg runs. Both are graph self-loops but are NOT recursion cycles: no verdict-
mode invocation can re-enter them.

## 2. Cycles — every cycle named

**Cycle 1 (the only true cycle): C2R63 ->(198) CTL63 ->(460) C2R63.**

- Entry point A: `bash plans/round-63-c2.sh --tree <candidate>` (verdict mode).
  Path to re-entry: L198 runs the full CTL63 battery; CTL63 `probe_counters()`
  (L449-466) runs `timeout 2400 bash $C2_INSTR --tree $CAND` — i.e. C2R63 in
  verdict mode again. The inner C2R63 hits L198 again, spawning CTL63 again,
  whose probe runs C2R63 again. Each nesting level also re-runs the L1/L2/L6
  legs (two full-tree `cp -a` of the 346 MB lane per level), the CTL63 C1
  probe (`C1R63`, a full 16-fixture counter verdict), the stub controls, and
  the CTL63 `ctrl_prior` delegation to CTL62 (a full prior battery with its
  own real-trial C2 legs). There is no depth counter, no re-entry guard, and
  no timeout inside the chain narrower than 2400 s (the probe's own
  `timeout 2400`); the outer `timeout 900/1500/240` in the receipt is what
  killed it (`rc=124`). Tree growth per level is ≥3 full-tree copies (L1, L2,
  PRIOR snap) plus C1R63's per-fixture copies, so a `/fast` scratch fills
  superlinearly; the bound is CPU/scratch, not fork-bomb.

**No other cycle exists at BASE.** Specifically the following look like
cycles but are not:

- C2R63 L227 (`--selftest` self-invocation): mode-guarded, terminates.
- C2R61 L440 (`R61_C2_NOSTUB=1` self-invocation): env-guarded, depth ≤2.
- CTL63 -> CTL62 -> C2R61/C2R62/C1R62: DAG tail (C2R62/C2R61/C1R62 never call
  back to CTL63/C2R63), extremely heavy but finite.
- CTL63 -> C1R63 (L452): tail (C1R63 never calls back to CTL63/C2R63),
  heavy (16 fixtures, each a tree copy + checker run) but finite.
- CTL62 -> C2R62 -> C2R61: DAG, no back edge.

The plan (§C2) names this single cycle correctly. What the plan does not
name is that the cycle body also drags two unbounded *tails* (C1R63 verdict
via L452 and the CTL62 prior battery via L324) that must complete before
each recursion level can return — even a bounded recursion would still take
minutes per level (see §4).

## 3. Measured recursion depth (scratch copy, instrumented)

Method: slim/work tree (~2.8 MB, 169 files: `LOG.md`, `SKILL.md`, `plans/*`
round-60..64 scripts, `corpus/openbao-seal-trial.sh`, fleet report — every
file the chain touches) under scratch; PID loggers prepended to copies of
`round-63-c2.sh`, `round-63-controls.sh`, `round-63-c1.sh`,
`round-62-controls.sh`, `round-62-c1.sh`, `round-62-c2.sh`, `round-61-c2.sh`
(`depth-fast.log`); live `ps` sampling every 2 s. The lane itself was never
modified. Two runs:

- **Full-leg run** (`timeout 120 bash plans/round-63-c2.sh --tree $WORK`,
  120 s): `depth.log` shows only `C2R63(3702498) -> C1R62(3702690)`
  (leg l1's C1 selftest). The L1 leg's C1 selftest alone (its own fixture
  copies + checker runs) consumed the entire 120 s before the L198 battery
  leg was even reached; `rc=124`, no verdict line. This is the same hang the
  L1 measured at 240 s (`c2-e2e-head.txt`: `rc=124`).
- **Isolated-cycle run** (L1/L2/L6 legs stubbed out in the *copy* only, so
  the L198 battery leg is reached immediately; `timeout 90`, 2 s sampler):
  `depth-fast.log` (9 invocations) + final `ps` snapshot prove live nesting:

```
556344 C2R63 (L0) -> 556814 CTL63 (L1) --[C1 probe 557291 returned]--> 905211 C2R63 (L2)
  -> 905647 CTL63 (L3) --[C1 probe 905908 returned]--> 1085297 C2R63 (L4)
  -> 1085742 CTL63 (L5) -> 1085949 C1R63 (L6, probe)
```

Observed depth at 70 s: **3 nested C2R63 verdict invocations, 3 CTL63
batteries, 7 processes deep (C2/CTL/C2/CTL/C2/CTL/C1)**. Cadence is ~25 s
per level, set by the CTL63 C1 probe (`C1R63` verdict) completing before the
C2 probe starts (`main()` order L561: C1 first). The cycle is sequential
(each level's C1 probe returns before its C2 probe starts), not parallel —
depth grows by one per probe-return, unbounded.

### 3.1 The recursion SURVIVES the timeout (measured, `orphan-chain.log`)

`timeout 90` fired at 90 s and the top-level shell exited `rc=124`, but the
nested chain did **not** die: it was reparented to PID 1487 and kept
recursing. Snapshot taken 2 min 47 s after the outer kill:

```
 905202    1487  timeout 2400 bash .../round-63-c2.sh --tree ...   <- root, reparented
 905211  905202  bash .../round-63-c2.sh --tree ...
 905647  905211  bash .../round-63-controls.sh ...
1085290  905647  timeout 2400 bash .../round-63-c2.sh --tree ...
...
1882400 1882385  bash .../round-63-c2.sh --tree ...              <- level 6
1882801 1882400  bash .../round-63-controls.sh ...
1883109 1882801  timeout 2400 bash .../round-63-c1.sh --tree ...
1883142 1883109  bash .../round-63-c1.sh --tree ...
1912166 1883142  python3 ... checker ... meas.F1.tree
```

Tally: **6 nested C2R63 verdict levels, 20 live processes, one new level
every ~25 s, 167 s after launch** (and still growing when killed). The
mechanism: the outer `timeout` signals its own child's process group, but
every nested invocation is launched through `timeout 2400` (CTL63 L452/L460),
and GNU `timeout` puts its child in a *new* process group — so the outer
group signal stops at the first nested `timeout`; the rest reparents to init
and continues. `[INFERENCE]` on the pgid mechanism (GNU timeout semantics);
the survival + reparenting itself is observed. A shell `EXIT` trap does not
run on the untrapped SIGTERM, so each surviving level also leaves its
`$WORK` behind: 6 leaked `kagi-r63/R63ExecC2Counter/run-*` dirs (5.5 MB each
on the 2.8 MB slim tree — i.e. `l1`+`l2` copies; ~700 MB per level on the
346 MB lane, plus the C1R63 fixture trees).

**Consequences for the C2 claim:** (a) `rc=124` at BASE is a kill of only
the top shell; the recursion continues as an orphan chain and must be
reaped with `pkill`/process-group kill, not by the counter; (b) any round-64
"terminates inside timeout 1200" measurement must confirm no orphan chain
remains afterwards, otherwise a "terminated" reading is measured while a
runaway chain is still consuming CPU/scratch (this seat's run left one and
killed it manually; evidence `orphan-chain.log`); (c) a bounded run that
still trips its own budget leaks the same way, so the bound must be checked
by the refutation control's exit, not by `timeout` alone.

## 4. Timing evidence (tree-copy cost + `timeout 1200` reachability)

Measured on this host (NVMe `/fast`, fleet load present — shardmates running
checkers concurrently):

- Full lane tree: **346 MB, 30,078 files, 229 MB of it `.ufo`**;
  `time cp -a` measured **1.83 s / 2.24 s / 2.69 s** (3 runs). Tree-copy
  cost as the plan §Bounds names it is *not* the bottleneck: even the
  multiplicative per-level copies (3+ per recursion level) cost ~2.5 s
  each.
- Cheap floors: `bash plans/round-63-c2.sh --selftest` PASS (cases=13) and
  `bash plans/round-63-controls.sh --selftest` PASS (cases=25) each exit
  in under a few seconds; checker `--selftest` PASS (cases=102) similarly
  fast. The heavy cost is *verdict* mode, not selftest mode.
- The cycle body dominates: each CTL63 level runs (a) a full `C1R63`
  verdict — its `measure_residual()` copies the tree once up front (L156-170)
  and then once per fixture (`apply_fixture` L221 `cp -a`, 16 fixtures, each
  deleted after use), i.e. **~17 full-tree copies ≈ 5.5 GB of writes at
  346 MB per copy** plus 16 checker runs and 6 guard legs; (b) `ctrl_prior`
  = a full CTL62 battery whose `C2-F4` real-trial leg runs C2R61 verdict
  mode (`timeout 2400`, 9 trial runs each starting bao servers) and whose
  `C2-F5` leg runs C2R62 verdict mode twice; and (c) the recursion itself.
- Measured under fleet load: the full-leg run spent **>120 s inside leg
  l1 alone** (C1R62 `--selftest`, which itself copies fixture trees and
  runs the checker repeatedly) before reaching the L198 battery leg — on a
  2.8 MB slim tree, not the 346 MB lane. So a *single* L1 leg can approach
  the plan's 1200 s budget when the host is loaded; tree-copy cost is the
  small term, **checker-run count under load is the large one**.
- Therefore: **with the bound, `timeout 1200` is reachable only if the
  bounded battery leg excludes both probes (`C1R63` and `C2R63`) and PRIOR,
  or if the host is not loaded.** The round-64 counter must measure its
  own wall clock on the candidate; a bound that closes the cycle but keeps
  the C1 probe + L1/L2 + guard-c real trial is marginal at 1200 s on this
  host. Flagged for the C2 seat as the decisive budget risk, not a
  recursion defect.

## 5. Per-cycle interception verdict for the proposed bound

Proposed bound (plan §C2, L156-162): env flag `C2_RECURSION_BOUND` (default
1). At 1 the counter's controls-battery leg delegates to fixture/confinement
controls only and never re-enters a counter; at 0 it delegates to the full
battery. Round-64 battery carries the refutation control (mismatch when
bound=0 under a 240 s timeout). `R63_CONTROLS_FIXTURE_ONLY` is the
battery-side predicate (the plan phrase "fixture/confinement controls only").

**Cycle 1 (C2R63 <-> CTL63): INTERCEPTED — conditionally.** The interception
point is uniquely CTL63 `probe_counters()` L460 (the `timeout 2400 bash
$C2_INSTR --tree` line) or, equivalently, C2R63 L198's delegation
(`bash $TREE/plans/round-63-controls.sh $TREE`). Either branch closes the
cycle *provided both sides land*:

- `C2_RECURSION_BOUND=1` must make the *round-64* C2 counter
  (`plans/round-64-c2.sh`, not yet written — only `round-64-controls.sh`
  exists at BASE) invoke the battery as
  `R63_CONTROLS_FIXTURE_ONLY=1 bash plans/round-63-controls.sh …` instead of
  the bare full-battery invocation at the L198 position, and
- `round-63-controls.sh` (BASE bytes) must honor
  `R63_CONTROLS_FIXTURE_ONLY=1` by short-circuiting `probe_counters()`' C2
  leg (and the C1 leg if fixture-only is to exclude *all* counter re-entry;
  the C1 probe is a tail, not a cycle, but it is a full verdict).

Neither predicate exists at BASE
(`grep -rn FIXTURE_ONLY plans/` = empty; `round-64-c2.sh` does not exist).
So on a BASE tree the flag is inert by construction, and the K1 reading
(`terminates=0` at BASE) holds vacuously rather than non-decoratively —
this is consistent with the plan's K1, but the C2 seat must implement the
battery-side branch in the *round-63* file it ships (or in the round-64
battery's copy of it); a counter-side-only flag that still invokes
`round-63-controls.sh` unmodified on the battery leg does NOT intercept
Cycle 1, because BASE CTL63 has no fixture-only branch to read. **This is
the one finding for the C2 seat: the bound must land in
`plans/round-63-controls.sh` `probe_counters()` (skip the C2 leg, and the
C1 leg under fixture-only), not only in the new `round-64-c2.sh`.** Without
the battery-side edit the claim holds only on a tree whose battery was
patched, and guard leg (d) ("existing controls still match, 0 skips") must
then be argued against patched-badge bytes.

Open, not a cycle but a timing hazard for `timeout 1200`:

- **Unintercepted tail 1 — CTL63 L452 (C1 probe).** If fixture-only keeps
  the C1 leg (`C1R63 --tree`, full 16-fixture verdict), the bounded counter
  still pays a full C1 verdict inside the battery leg. That leg alone is
  of the order of minutes and, combined with C2R63's own L1/L2 legs (each a
  full-tree copy + C1R62 selftest; the full-leg run showed L1 alone >120 s)
  and guard-c (`C2R62 --tree`, real bao trial), may still exceed
  `timeout 1200` on a loaded host. The claim's `terminates=1` within
  `timeout 1200` is reachable *if* the bounded battery leg excludes both
  probes; if it keeps the C1 probe, reachability is marginal and
  load-dependent. The C2 seat must measure, not assume.
- **Unintercepted tail 2 — CTL63 `ctrl_prior` (L324 -> CTL62 full battery).**
  If fixture-only keeps PRIOR, the CTL62 battery's C2-F4 (real trial,
  `timeout 2400`) and C2-F5 (two C2R62 verdicts) run inside every
  bounded invocation — minutes to tens of minutes per run, again risking
  `timeout 1200`. The round-64 battery already avoids this by delegating
  PRIOR as `--selftest` only (`round-64-controls.sh` L364:
  `timeout 2400 bash plans/round-63-controls.sh --selftest` — fixture
  trees only, bounded). The round-64 C2 counter must do the same for its
  R63 delegation (selftest or fixture-only skipping PRIOR), or the 1200 s
  budget is not credible. Flagged as a timing finding, not a cycle.
- **Refutation leg coverage (plan guard (b) / K2).** `C2-BOUND` in
  `round-64-controls.sh` L484 (`C2_RECURSION_BOUND=0 timeout 240 bash
  $C2_INSTR --tree`) measures the *round-64* counter. On the candidate it
  must hang (rc=124, no verdict line). That generation path is the same
  Cycle 1 via the round-64 counter's battery leg; the battery-side branch
  is what makes bound=0 vs bound=1 differ. If the battery-side branch is
  missing, bound=0 and bound=1 read identically (both hang) and the
  refutation control fires `mismatch` — the claim fails closed, as
  designed. No action needed beyond landing the branch.

**New-cycle risk to avoid (finding for the C2 seat):** the round-64 C2
counter must NOT delegate its battery leg back to `plans/round-64-controls.sh`
in verdict mode: `round-64-controls.sh` `probe_counters()` (L536-543) runs
`$C2_INSTR --tree` (= round-64 C2), so a round-64-C2 verdict leg that invokes
the round-64 battery would create a *new* cycle
`R64-C2 <-> R64-CTL` mirroring Cycle 1. The plan's battery leg delegates to
the round-63 battery; keep it that way, or apply the same fixture-only
branch to the round-64 battery's probe.

## 6. Summary

- Call graph (§1) carries every BASE invocation with line numbers;
  **exactly one true cycle: `round-63-c2.sh:198 -> round-63-controls.sh:460
  -> round-63-c2.sh`**. The plan names it correctly. Two self-loops
  (C2R63:227, C2R61:440) are mode/env-guarded and terminate.
- Measured depth: **6 nested C2R63 verdict levels / 20 processes in 167 s**
  (isolated-cycle run; 3 levels at the 70 s sampler snapshot), sequential,
  unbounded; the **chain survives the outer `timeout` kill** (root reparented
  to PID 1487, kept spawning a level per ~25 s) and leaves its `run-*` dirs
  behind. The full-leg run dies in L1's C1 selftest before reaching the
  battery leg, reproducing the committed `rc=124` receipt.
- Proposed bound intercepts the cycle **if and only if** the battery-side
  `R63_CONTROLS_FIXTURE_ONLY` branch lands in
  `plans/round-63-controls.sh` `probe_counters()`; a counter-side-only flag
  is inert against BASE battery bytes. The two unbounded tails (CTL63 C1
  probe, CTL63 PRIOR->CTL62) are not cycles but gate the `timeout 1200`
  reachability and must be excluded or bounded by the fixture-only
  delegation, as the round-64 battery already does for PRIOR (`--selftest`
  only, L364). The round-64 C2 counter must not create a new cycle back to
  `round-64-controls.sh`.
- Timing: full tree copy ~**2 s** (346 MB, 30k files) — not the
  bottleneck; the per-level C1 verdict + CTL62 prior battery dominate and
  decide the 1200 s budget.

SEAT-STATUS: complete

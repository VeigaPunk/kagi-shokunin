# R64Revenger — round 64 wave 1 (kagi-r64-w1)

Seat: revenger. Task: reverse-engineer why the round-63 C2 counter recurses and
whether the round-64 bound closes **every** re-entry path. Read-only: no lane
file edited; receipt + evidence under
`.ufo/waves/round-64/build/R64Revenger/` (`recursion.md`, `depth-fast.log`,
`depth-full-leg.log`, `ps-samples.log`, `orphan-chain.log`, `measurements.txt`).
Held-out TSV **not read** (seat discipline; recursion analysis needs no fixture
bytes). No tool installed (RULES.md read first; bash/python3/ps only).

## Call graph (BASE 09cbee8) — every invocation, line, condition

`plans/round-63-c2.sh` (C2R63), 8 edges:

| line | callee | mode | condition |
|---|---|---|---|
| 180 | `round-62-c1.sh` (in `$WORK/l1` copy) | `--selftest --tree` | verdict mode, leg l1; needle must match exactly once |
| 192 | `round-62-c1.sh` (in `$WORK/l2` copy) | `--selftest --tree` | leg l2; `setup_die needle-l2` |
| **198** | **`round-63-controls.sh`** | **`<tree>` full battery** | `[ -f $TREE/plans/round-63-controls.sh ]` (L197); l3/l4 read C2-F6/C1-F8 |
| 219 | `round-61-c1-check.py` | `--selftest` | leg l6 |
| 225 | `round-62-c1.sh` | `--selftest --tree` | guard a |
| 227 | `round-63-c2.sh` | `--selftest` | guard b; mode-guarded (exits L100-146) — self-loop, terminates |
| 229 | `round-62-c2.sh` | `--tree` | guard c (real bao trial) |
| 232 | `round-62-controls.sh` | `--selftest` | guard d (fixture-only) |

`plans/round-63-controls.sh` (CTL63) `main()` L534-568:
L452 `round-63-c1.sh --tree $CAND` (`timeout 2400`, `probe_counters`, condition `[ -n $C1_INSTR ] && bash -n`);
**L460 `round-63-c2.sh --tree $CAND` (`timeout 2400`, `probe_counters`)**;
L324 `round-62-controls.sh <snap>` (`ctrl_prior`, `timeout 2400`);
L375/L412 stub copies of C1/C2 counters (`timeout 60`, stub dispatch exits 0 — no recursion).

Tails: `round-62-c2.sh` → `round-61-c2.sh` (L232/281/293/304/313);
`round-61-c2.sh` → trial (`timeout 900/300`) + env-guarded self (`R61_C2_NOSTUB=1`, L440, depth ≤2)
+ selftest cases L231-233; `round-62-controls.sh` → C2R61 (L466/532/546/557/712/736/762),
C1R62 (L633/644), C2R62 (L803/807). None of these calls back to CTL63 or C2R63.

## Cycles — enumerated

1. **`round-63-c2.sh:198 → round-63-controls.sh:460 → round-63-c2.sh`** — the
   only true cycle. Entry: any verdict-mode C2R63 invocation. CTL63's probe
   re-enters C2R63 verdict mode with a 2400 s timeout; the inner run reaches
   L198 again. No depth counter, no re-entry guard, no narrower timeout.
2. **Non-cycles (verified):** C2R63:227 self-loop (mode-guarded); C2R61:440
   self-loop (env-guarded); CTL63→C1R63:452 (tail); CTL63→CTL62:324→C2R62→C2R61
   (DAG); CTL63→stub:375/412 (stub exits). The plan names cycle 1 correctly;
   it does not name the two heavy tails that must finish inside every level.

## Measured depth (instrumented scratch copy, PID loggers + 2 s `ps` sampling)

- Full-leg run `timeout 120`: `rc=124`, only `C2R63 → C1R62` logged — **still
  inside leg l1 at 120 s**, never reached the battery leg (matches the L1's
  240 s `rc=124`, `base/c2-e2e-head.txt`).
- Isolated-cycle run (L1/L2/L6 stubbed in the copy only): **3 nested C2 levels
  / 7 processes at 70 s**; after the outer `timeout 90` killed the top shell,
  the chain **survived, reparented to PID 1487, and kept recursing** — final
  tally **6 nested C2 verdict levels, 20 live processes, 167 s after launch**,
  one new level per ~25 s (`orphan-chain.log`). Each surviving level also
  leaks its `$WORK` dir (EXIT trap not run on untrapped SIGTERM): 6 leaked
  `kagi-r63/R63ExecC2Counter/run-*` dirs. This seat reaped its own chain
  (`kill` by unique scratch path; verified 0 left).

## Per-cycle interception verdict

- **Cycle 1: intercepted iff the battery side lands.** `C2_RECURSION_BOUND=1`
  must make the round-64 counter delegate as
  `R63_CONTROLS_FIXTURE_ONLY=1 bash plans/round-63-controls.sh …`, and
  `round-63-controls.sh` must honor that flag in `probe_counters()` (skip the
  **C2** probe at L460; skip the C1 probe at L452 too if fixture-only is to
  mean "no counter re-entry"). At BASE neither predicate exists:
  `grep -rn FIXTURE_ONLY plans/` = 0 hits; `plans/round-64-c2.sh` does not
  exist. A counter-side-only flag that still calls BASE `round-63-controls.sh`
  **does not intercept** — the flag is unread on the battery side. This is the
  finding for the C2 seat.
- **Tail hazards not intercepted by the cycle bound:** CTL63:452 (full C1R63
  verdict, ~17 full-tree copies + 16 checker runs) and CTL63:324 (`ctrl_prior`
  → full CTL62 battery incl. C2-F4 real trial `timeout 2400` and two C2R62
  verdicts). Neither is a cycle, both gate `timeout 1200`. The round-64 battery
  already avoids the PRIOR cost by delegating `--selftest` only
  (`round-64-controls.sh:364`); the round-64 C2 counter must do the same.
- **New-cycle risk:** the round-64 C2 counter must not delegate back to
  `plans/round-64-controls.sh` in verdict mode — `round-64-controls.sh`
  `probe_counters` (L536-543) runs `$C2_INSTR --tree`, which would recreate the
  same cycle as `R64-C2 ↔ R64-CTL`.

## Timing

Full lane tree 346 MB / 30,078 files; `cp -a` measured **1.83 / 2.24 / 2.69 s**
(not the bottleneck). Copy-count per C1R63 verdict ≈ 17 full copies ≈ 5.5 GB of
writes; per recursion level ≈ 2-3 more full copies. The real cost under fleet
load is checker-run count: **leg l1 alone exceeded 120 s** on a 2.8 MB slim tree.
Verdict: `timeout 1200` is reachable only if the bounded battery leg excludes
both probes (and PRIOR is selftest-only); otherwise the claim is marginal on a
loaded host and must be measured, not assumed. Also: the BASE `rc=124` is a kill
of the top shell only — any "terminated" measurement must verify no orphan chain
survives.

SEAT-STATUS: complete

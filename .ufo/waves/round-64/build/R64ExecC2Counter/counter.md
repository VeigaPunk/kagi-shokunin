# R64ExecC2Counter — C2 recursion bound, receipts (round 64, attempt 2)

Seat: R64ExecC2Counter (executor, operability). Lane `kagi-shokunin`, claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`. Frozen plan `plans/round-64.md`
§C2 (commit `dff0929`, Amendment A1). All commands below ran with cwd
`/fast/scratch/hyaku/kagi-r64/R64ExecC2Counter` unless stated; child scratch was
rooted at `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r64/R64ExecC2Counter/scratch`
so every instrument scratch (kagi-r62/…, kagi-r63/…) nests inside the seat scratch.

## Files (final, frozen)

| path | sha256 | lines |
|---|---|---|
| `plans/round-64-c2.sh` | `e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b` | 451 |
| `plans/round-63-c2.sh` | `b8c8393be630b978e03bbf9abf961741252ffe625712e4d751b69815c742c373` | 240 |
| `plans/round-63-controls.sh` | `f0aa230764a8e8949fc3b80ac1a579f5ef2c79d3a8ad2d1e69a9516e45d49569` | 615 |

`plans/round-63-c2.sh` diff is one added line in the l3/l4 leg:
`R63_CONTROLS_FIXTURE_ONLY="${R63_CONTROLS_FIXTURE_ONLY:-}" bash "$TREE/plans/round-63-controls.sh" "$TREE" >"$WORK/battery.out" 2>&1`
(no behaviour change when the variable is unset/empty). `plans/round-63-controls.sh`
gains the documented `R63_CONTROLS_FIXTURE_ONLY` mode (skip `probe_counters` and
the PRIOR delegation; C1-F8/C2-F6 still run) and its `--selftest` is unchanged.

## Measured tree

Full BASE extraction, no writes during measurement:

```
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 09cbee831d57be7c4edfbe77bf238f46bf729047 | tar -x -C tree-base
# 209 MB, 10,980 files
cp plans/round-64-c2.sh plans/round-63-c2.sh plans/round-63-controls.sh tree-base/plans/
find tree-base -newermt '2026-11-08 02:20' -type f | wc -l   # => 0 (tree untouched)
```

The run invokes the lane's `plans/round-64-c2.sh` against `--tree tree-base`;
the tree carries the two round-63 instruments it measures plus the same counter
bytes (the tree's own `plans/round-64-c2.sh` copy is not read by any leg).

## 1. Counter selftest (frozen bytes)

```
$ bash plans/round-64-c2.sh --selftest
C2R64_SELFTEST: PASS (cases=21)
RC=0                                    # receipt selftest.txt
```

Cases cover: verdict-line shape; `terminates`/`bound` field parse (bound=0 reads
0); one negative vector per leg position (`killed` drops by 1); C2-F6/C1-F8
mismatch positive and negative; `leg_fires` finding/rc vectors; guard and exit
composition; the delegation composition (`bound_mode 1`=fixture, `0`=full); a
fixture battery that terminates at bound=1 under `timeout 5` and does not
terminate at bound=0 under the same timeout; `C2_HARDENED` `real=` parse.

## 2. End-to-end verdict, bound=1 (claim measurement)

```
$ /usr/bin/time -f 'WALL %e' timeout 1200 bash plans/round-64-c2.sh --tree tree-base
c2-refusal: tree=/fast/scratch/hyaku/kagi-r64/R64ExecC2Counter/tree-base scratch=.../run-20261108T030952Z-2113817 bound=1 elapsed=501s
c2-refusal: guard a=1 r63selftest=1 b=1 c=1 d=1 e=1 real-attempts=1 real-rc=0
C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)
E2E_RC=0
WALL 502.19
```

Receipt `e2e-bound1-final.txt`. One invocation, one verdict line, inside
`timeout 1200`; `terminates=1` is the counter's own budget check against the
frozen 1200 s.

## 3. Refutation, bound=0

```
$ C2_RECURSION_BOUND=0 /usr/bin/time -f 'WALL %e' timeout 240 bash plans/round-64-c2.sh --tree tree-base
REFUTE_RC=124
verdict-lines=0
52 bytes: only /usr/bin/time's own status line; the counter printed nothing
WALL 240.03
```

Receipt `e2e-bound0-refute.txt`. The bound is load-bearing: with the full battery
delegation the run does not reach its verdict line inside 240 s.

Battery causality pair, measured directly on the same tree:

```
$ R63_CONTROLS_FIXTURE_ONLY=1 timeout 60 bash tree-base/plans/round-63-controls.sh tree-base
CONTROL C1-F8 ... verdict=mismatch
CONTROL C2-F6 ... verdict=mismatch
SKIPS: 4
CONTROLS: match=0 mismatch=2
FIXTURE_RC=1                                       # receipt battery-fixture-only.txt
$ timeout 120 bash tree-base/plans/round-63-controls.sh tree-base
FULL_RC=124, 0-byte stdout (no CONTROLS summary)   # receipt battery-full-120s.txt
```

The fixture-only delegation terminates in ~2 s and still runs both stub
controls; the full battery re-enters its counter probe and does not produce a
summary in 120 s.

## 4. Carried round-63 instrument readings (unchanged gates)

```
$ bash plans/round-63-c2.sh --selftest
C2R63_SELFTEST: PASS (cases=13)      RC=0
$ R63_CONTROLS_FIXTURE_ONLY="" bash plans/round-63-controls.sh --selftest
CONTROLS_SELFTEST: PASS (cases=25)   RC=0
```

## 5. Real trial (carried guard c / kill rule K4)

Direct, on the measured tree:

```
$ bash tree-base/plans/round-62-c2.sh --tree tree-base
C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)
RC=0, WALL 109.22
```

The carried round-63 leg ran `grep value=5|shims=5|vectors=ok/5` against this
counter's *output*; those tokens exist only in its `--selftest` fixture and in
the measured counter's internal `C2_SEAL_TRIAL:` line, so the leg could never
pass (round-63 never produced a verdict, so it was never observed). The counter
now reads the equivalent `real=1` field from `C2_HARDENED:`.

Host-load sensitivity, measured: the trial read `real=0` (rc 1) three times at
load averages 130–157 (e2e runs of 261 s and 715 s, and a direct reproduction at
load 149); it read `real=1` at load ~100 and in the passing run (attempt 1 of 2).
The leg therefore retries once and the provenance line names the attempt count
(`real-attempts=1` in the passing run).

## 6. Budget composition (why the wave)

`plans/round-62-c1.sh --selftest` is checker-bound: ~24 ~20 s checker
measurements. Measured serially at load 51–74: `WALL 488.01` on the full lane
tree; `WALL 161.62` on an 18-file slim tree (checker cost dominates; tree size
is secondary). The counter issues three such runs — l1, l2 and carried guard (a)
— and they are independent (separate copies, read-only measured tree, distinct
instrument scratch tags), so they run as one parallel wave. Serial arithmetic
(3 × 488 s + the 109 s trial) exceeds the frozen 1200 s budget; the composed run
measured 501 s. The legs stay individually readable: l1/l2 are separate mutant
processes with separate finding lines.

## Commands run (chronology, with rc)

| # | command | rc / reading |
|---|---|---|
| 1 | `bash plans/round-62-c1.sh --selftest --tree .` (lane tree, timing) | `C1_COUNTER_SELFTEST: PASS (15/15 checks)`, WALL 488.01 |
| 2 | `bash plans/round-62-c1.sh --selftest --tree tree-slim` | PASS 15/15, WALL 161.62 |
| 3 | `bash plans/round-63-c2.sh --selftest` | PASS cases=13, rc 0 |
| 4 | `bash plans/round-63-controls.sh --selftest` | PASS cases=25, rc 0 |
| 5 | e2e bound=1 (pre-reorder bytes) | rc 1, `killed=5 … guard=0 … real=0 … terminates=1 bound=1`, 261 s |
| 6 | e2e bound=1 (real trial hoisted, token-grep leg still defective) | rc 1, `real=0`, 715 s |
| 7 | `bash tree-base/plans/round-62-c2.sh --tree tree-base` | rc 0, `real=1`, 109 s |
| 8 | e2e bound=1 (pre-final sha `4d2affb5…`, real=field parse + retry) | rc 0, `killed=5 guard=1 … terminates=1 bound=1`, 619 s |
| 9 | e2e bound=1 (frozen sha `e2d8171f…`) | rc 0, verdict line above, 501 s |
| 10 | `C2_RECURSION_BOUND=0 timeout 240 …` (frozen sha) | rc 124, 0 verdict lines, 240 s |
| 11 | battery pair (fixture-only / full 120 s) | rc 1 (2 s) / rc 124 (0 bytes) |
| 12 | `bash plans/round-64-c2.sh --selftest` (frozen sha) | `PASS (cases=21)`, rc 0 |

## Defects / risks disclosed

- **Round-63 carried guard (c) was dead code.** Its token greps cannot match the
  round-62 counter's output; repaired to the equivalent `real=1` field parse.
  Not a frozen-predicate amendment: K4's substance (the trial still reads
  value=5 shims=5 vectors=ok/5) is what the field encodes.
- **Guard (a) cost vs budget.** The carried round-62 C1 selftest is ~488 s
  serially; three such runs exceed the 1200 s budget. The parallel wave is the
  only composition that fits; a host with one usable core would not fit.
- **Real-trial host-load sensitivity.** Measured failures at load ≥130; one
  retry, attempt count in provenance. A load ≥150 run can still read `real=0`
  and `guard=0` — honest, not suppressed.
- **Plan §C2 guard (d) "0 skips"** cannot hold in fixture-only mode: the battery
  reports `SKIPS: 4` (NOWORK/REAL depend on the skipped probe). The counter
  carries the round-63 guard (d) (round-62 controls selftest) and the round-63
  battery *selftest* as the fixture evidence for plan (d).
- The bound at 0 is the old behaviour by construction; the refutation is the
  external 240 s measurement, not a runtime guard (a runtime 240 s hang would
  spend the budget it protects).

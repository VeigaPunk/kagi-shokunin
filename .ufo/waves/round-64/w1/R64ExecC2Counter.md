# R64ExecC2Counter — bounded C2_REFUSAL counter (round 64 attempt 2)

Seat: executor (operability, C2). Lane `kagi-shokunin`, claim BASE
`09cbee831d57be7c4edfbe77bf238f46bf729047`, frozen plan
`plans/round-64.md` §C2 (commit `dff0929`, Amendment A1). Leaf seat: no
subagents, no commits, no mutating git/jj anywhere.

## Files

| path | sha256 |
|---|---|
| `plans/round-64-c2.sh` (new, 451 lines) | `e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b` |
| `plans/round-63-c2.sh` (one-line pass-through) | `b8c8393be630b978e03bbf9abf961741252ffe625712e4d751b69815c742c373` |
| `plans/round-63-controls.sh` (fixture-only branch) | `f0aa230764a8e8949fc3b80ac1a579f5ef2c79d3a8ad2d1e69a9516e45d49569` |

Receipts: `.ufo/waves/round-64/build/R64ExecC2Counter/` (`counter.md`,
`e2e-bound1-final.txt`, `e2e-bound0-refute.txt`, `battery-fixture-only.txt`,
`battery-full-120s.txt`, `selftest.txt`).

## Change

`plans/round-64-c2.sh` carries the five round-63 legs unchanged (l1/l2 CM2a/CM2b
mutant selftests, l3/l4 the round-63 battery's `C2-F6`/`C1-F8` mismatch, l6 the
I6-conjunct drop), the carried guard set (round-62 C1 selftest, own selftest +
round-63 C2 selftest, real trial, round-62 controls selftest) and adds:

- `C2_RECURSION_BOUND` (default 1). At 1 the l3/l4 delegation runs the measured
  tree's `plans/round-63-controls.sh` with `R63_CONTROLS_FIXTURE_ONLY=1`
  (`probe_counters` skipped; the two stub controls still run); at 0 the full
  battery (the old behaviour, which re-enters a counter and does not terminate);
  other values SETUP. `bound=` in the verdict line names the effective value.
- Exactly one verdict line
  `C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… selftest=… real=… terminates=… bound=…)`,
  exit 0 iff guard=1 ∧ killed=5 ∧ terminates=1; `terminates` is the counter's
  own check that it reached the line inside the frozen 1200 s budget.
- `--selftest` (21 cases): verdict-line shape; bound/terminates parse (bound=0
  reads 0); a negative vector per leg position; C2-F6/C1-F8 mismatch positive
  and negative; guard/exit composition; delegation composition; a fixture
  battery that terminates at bound=1 under a 5 s timeout and does not at
  bound=0.
- The three checker-bound round-62 selftests (l1, l2, guard (a)) run as one
  parallel wave: serial arithmetic 3 × 488 s + 109 s trial exceeds 1200 s; the
  composed run measured 501 s.

`plans/round-63-c2.sh`: the battery invocation gains the
`R63_CONTROLS_FIXTURE_ONLY` pass-through (one line; output line and exit codes
unchanged, `--selftest` still `C2R63_SELFTEST: PASS (cases=13)`).
`plans/round-63-controls.sh`: documented `R63_CONTROLS_FIXTURE_ONLY=1` mode —
`probe_counters` and the PRIOR delegation are skipped, `C1-F8`/`C2-F6` still
run, NOWORK/REAL record skip; unset behaviour unchanged (`CONTROLS_SELFTEST:
PASS (cases=25)`).

## Measurements (full BASE tree: git archive `09cbee8`, 209 MB / 10,980 files, zero writes)

- `timeout 1200 bash plans/round-64-c2.sh --tree tree-base` ⇒ rc 0, 501 s:
  `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)`.
- `C2_RECURSION_BOUND=0 timeout 240 … --tree tree-base` ⇒ rc 124, zero verdict
  lines (52 bytes = `/usr/bin/time`'s own report). The bound is load-bearing.
- Battery causality pair: fixture-only rc 1 in ~2 s (`CONTROLS: match=0
  mismatch=2`, `SKIPS: 4`); full battery rc 124 in 120 s with 0-byte stdout.
- `bash plans/round-64-c2.sh --selftest` ⇒ `C2R64_SELFTEST: PASS (cases=21)` rc 0.
- `bash plans/round-63-c2.sh --selftest` ⇒ `PASS (cases=13)` rc 0;
  `plans/round-63-controls.sh --selftest` ⇒ `PASS (cases=25)` rc 0.

## Defects and risks (disclosed, not amended)

1. **Carried round-63 guard (c) was dead code:** it greps `value=5 shims=5
   vectors=ok/5` in the round-62 counter's output, but those tokens exist only in
   its `--selftest` fixture and in the measured counter's internal
   `C2_SEAL_TRIAL:` line. The counter reads the equivalent `real=1` field from
   `C2_HARDENED:` (K4's substance). Round-63 never produced a verdict, so the
   dead leg was unobserved.
2. **Real-trial host-load sensitivity:** failures measured three times at load
   averages 130–157; success at load ~100 and in the passing run (attempt 1).
   One retry; `real-attempts=` in the provenance line. A run at high load can
   honestly read `real=0` / `guard=0`.
3. **Guard (a) cost:** 488 s serially at load 51–74; the frozen 1200 s budget
   fits only the parallel wave. A single-core host would not fit.
4. **Plan §C2 guard (d) "0 skips":** impossible in fixture-only mode (battery
   reports `SKIPS: 4`); the counter carries the round-63 guard (d) and the
   round-63 battery selftest as plan (d)'s fixture evidence.
5. The tree's own `plans/round-64-c2.sh` copy is an earlier build artifact and
   is not read by any leg; the lane copy is the measured instrument.

SEAT-STATUS: complete

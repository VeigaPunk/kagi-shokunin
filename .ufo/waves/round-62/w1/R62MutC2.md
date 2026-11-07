# R62MutC2 — mutation battery over the hardened C2 counter

Seat: `R62MutC2` (mutation-tester). Round 62, attempt 1, lane `kagi-shokunin`.
Claim BASE `60b5b7b60b76629633110a5b4adac883193c8b2a`; frozen plan `plans/round-62.md`
(predeclaration `8e5463c7937dccdd97fd5a812b8091f83b708aa7`).

Scope: read-only. No lane file was edited; no git/jj mutation was run in the lane, a sibling
lane, or any index. Every mutant is a byte copy under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r62/R62MutC2/` (removed before yield). The battery
receipt is `.ufo/waves/round-62/build/R62MutC2/mutants.md`; raw captured lines are in
`build/R62MutC2/raw/`; mutant hashes are in `build/R62MutC2/mutant-sha256.txt`.

## Instruments probed

| instrument | sha256 | note |
|---|---|---|
| `plans/round-61-c2.sh` at BASE | `c7d9e272…` | 389 lines, no markers, guard = `legs_ran` + sha |
| `plans/round-61-c2.sh` hardened | `20614697f3720aa446501b3c3246748c762a025b99065a19556476d9ff3f4f29` | 478 lines, 25970 B; markers wrap only the function bodies |
| `plans/round-62-c2.sh` driver | `59553ef46b8e4052cb6bf0b863e90ad973347bd5c14d623b12e8384f46404c57` | 293 lines, 14818 B |
| `bao` v2.7.2 | `9c5f3628…` | round-57 pin; the only real-trial input |

Fixtures (labelled, scratch only): `stubtree` (valid-sha256 stub trial that prints nothing),
`obstree` (all guard observables except `SEAL_SELFTEST`), `s5tree` (`cases=5`), `sh3tree` (SH3
flips T2), `bao-wrapper` (different sha256, same behaviour).

## Census

- **Hardened battery: 12 mutants, killed 8, survived 4.** `MUTANTS: killed=8 survives=4
  population=12` (derived in `mutants.md`).
- **BASE battery: 10 mutants, killed 4, survived 6** — the survivors are the C2-4/C2-5 classes
  the round targets (guard near-constant, selftest does not execute the aggregation).
- All 8 mutants the seat assignment names were applied: decide-constant (H-1), shim-constant
  (H-2), guard-ignores-SEAL_SELFTEST (H-3a/H-3b), selftest-skips-negatives (H-4), M-A needle
  zero (H-5), exit-always-0 (H-6), G-leg-unmutated-tree (H-7), real-leg-skipped (H-8). Four
  extras: guard-always-1 (H-9), constant-verdict selftest (H-11), M-B needle zero (H-12), and
  the s5 cross-check of H-3b.

## What the battery establishes

1. **C2-5 closed.** H-1 and H-2 (the plan's M-A/M-B constant replacements) each make the
   hardened counter's own `--selftest` exit non-zero with named `R61-C2-ST-` FINDINGs
   (`failed=6` on the six decide negatives; `failed=3` on the three shim cases). The same two
   replacements pass `PASS (cases=11)` at BASE. The selftest now executes the aggregation.
2. **C2-4 closed.** H-9 (guard -> `guard=1`) is killed by the stub tree (`guard=1` on the
   mutant, `guard=0` pristine). H-8 (real-trial leg skipped) is killed by the real tree
   (`guard=0` on the mutant, `guard=1` pristine) because the guard requires
   `real_ok`/`ops_ok`/`t2_ok`, not a captured rc. Both survived at BASE.
3. **The driver's own legs work.** Pristine driver: `C2_HARDENED: killed=3 population=3
   guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` rc 0. H-11 (constant-verdict counter) is refused
   (`ma=0 mb=0`, `guard=0`), which is the plan's guard leg (c). H-7 (G leg reading the
   unmutated tree) reads `g=0`, so the leg's polarity is correct.

## Survivors (defects, with fixes)

- **S1 — H-3b: the counter guard's `SEAL_SELFTEST` observable is removable.** Dropping both the
  grep and the `selftest_ok` conjunct leaves `guard=1` on the obs fixture and on the s5
  fixture. The driver's G stub trips every observable at once, so it cannot isolate the
  conjunct. **Fix:** add an obs-style fixture to the driver's legs (all observables but the
  selftest line) and require `guard=0`; or make the guard read the selftest leg's file with no
  flag indirection.
- **S2 — H-3a: the guard's `SEAL_SELFTEST` grep is dead weight.** Removing it alone is
  behaviourally identical (`selftest_ok` carries the same observable). **Fix:** one source of
  truth — keep the flag and delete the grep, or derive the flag from the grep; do not carry
  both, because a future edit that drops the flag silently loses the requirement (S1).
- **S3 — H-5: a zero-match M-A needle reads as a non-kill, not SETUP.** `apply_mut` failure is
  treated as "leg absent" (`ma=0`), so the driver prints `killed=2 … guard=0` rc 1 instead of
  SETUP rc 2. The claim fails closed, but an instrument defect is indistinguishable from a
  surviving mutant. **Fix:** `apply_mut … || setup needle-ma`.
- **S4 — H-12: the same defect on the M-B needle.** `mb=0`, `killed=2 … guard=0` rc 1, not
  SETUP. **Fix:** `apply_mut … || setup needle-mb`.

## Other findings

- **F3 — the H-7 run's guard leg (b) read `real=0`.** The H-7 mutant makes the G leg run the
  measured counter on the unmutated tree (a full ~92 s real run); the subsequent real leg then
  failed in that run. The G-leg reading (`g=0`) separated cleanly and is the H-7 detector; the
  `real=0` is a baseline failure of a different leg, recorded not counted. A G leg that reads
  the unmutated tree doubles the driver's real-trial cost.
- **F4 — the N>=17 floor lives in the driver, not the counter.** H-4 (all 8 negative
  aggregation cases removed) leaves the counter's own selftest at `PASS (cases=13)` rc 0; only
  the driver's leg (a) refuses it. A consumer of the counter without the driver has no floor.
- **F6 — the driver's 16-case selftest does not run the measured counter.** The M-A/M-B/G/real
  legs are only exercised by a full driver run (~100 s), which is why H-5/H-12/H-7 are visible
  only in the driver's output line.

## Tooling and scratch

No tool was installed, upgraded or removed. The only binaries used are the pinned `bao`
(v2.7.2, sha256 `9c5f3628…`) and the host's `bash`/`git`/`python3`/`sha256sum`/`awk`.
Scratch `/fast/scratch/hyaku/kagi-r62/R62MutC2/` is deleted before yield; no citable evidence
was written under `/tmp`.

SEAT-STATUS: complete

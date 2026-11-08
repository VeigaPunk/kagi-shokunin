# R63MutC2 — mutation battery over the C2 instruments

Seat `R63MutC2` (mutation-tester), round 63 attempt 1, lane `kagi-shokunin`. Claim BASE
`0c07aab8df64b673a54a5113aebd7f34b622adbc`; frozen plan `plans/round-63.md` (predeclaration
`12c9e4284d6de52ba61fcc656165cd24e8b74480`; Amendment A3 read at 20:16:41 UTC). Read-only on
lane source: every mutant is a byte copy under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63MutC2/`; no lane file was edited and no
git/jj mutation was run in the lane, a sibling lane, or any index. Full table with bytes
deltas, hashes and raw lines: `.ufo/waves/round-63/build/R63MutC2/mutants.md`.

## 1. Counter half — BLOCKED

`plans/round-63-c2.sh` is absent from the lane working tree at 20:18:47 UTC, and the owning
seat `R63ExecC2Counter` is parked with no scratch directory and no build directory. The L1
ruling records the cause as a provider-route failure, quoted verbatim:

```
[zai/glm-5.3-flash] 429 Weekly/Monthly Limit Exhausted
```

reset `2026-11-12 17:59:03` (the same 429 killed two tabi r81 executor seats in the same
window). This is a provider failure, not a seat defect, a timeout, or a quality rejection.
The eleven assigned round-63 counter mutants (force each leg to 1, force `killed=6`, force
`guard=1`, skip the battery delegation, make L5 read `killed=2` instead of SETUP, drop the
real-trial leg) cannot be built, so the C2 claim's kill rules K1/K2 have no instrument to
witness them this round. The counter half is BLOCKED, not survived.

Recorded defect for a re-dispatched seat. Plan Amendment A3 item 6 names L6's needle as the
BASE line `ok = len(qualifying) >= 3 and bool(superseded) and not denied`; that line occurs
**0 times** in the candidate `plans/round-61-c1-check.py` (measured). The candidate's I6
conjunct is `ok = len(qualifying) >= 3 and not denied and superseded_ok` (repo-None branch:
`ok = len(stamps) >= 3 and bool(superseded) and not denied \` plus `and superseded_ok`), so
a plan-literal L6 mutation matches 0 times and cannot fire. Fix: derive the needle from the
candidate's actual conjunct, keeping the BASE checker's `C1_CHECK_SELFTEST: PASS (cases=75)`
as the no-work control. With the candidate anchor the mutation makes the candidate checker
print `C1_CHECK_SELFTEST: FAIL (cases=100 failed=3
names=f9-forgery-unresolved,f10-forgery-unresolved,i6-superseded-stamp-conjunct-isolated)`
rc 1, so the leg is implementable.

## 2. Controls battery — complete

`plans/round-63-controls.sh` sha `74ed1624…`; `plans/round-62-c2.sh` at BASE sha `b26d4220…`.
Detectors: D1 the instrument's own `--selftest`; D2 a fixture run against a known pristine
line.

| id | mutation | D1 | D2 | verdict |
|---|---|---|---|---|
| B1 | remove `[ "$ma_applied" = 1 ] \|\| setup needle-ma` (`round-62-c2.sh:279`, −41 B) | `C2R62_SELFTEST: PASS (cases=16)` rc 0 | `s3tree`: `C2_HARDENED: killed=2 population=3 guard=0 (ma=0 mb=1 g=1 selftest=1 real=1)` rc 1 vs pristine `C2_HARDENED: SETUP needle-ma` rc 2 | survived D1; killed D2 |
| B2 | empty `main()`'s control list (seven `ctrl_*` calls, −103 B) | `CONTROLS_SELFTEST: PASS (cases=11)` rc 0 | `ftree`: `SKIPS: 0` / `CONTROLS: match=0 mismatch=0` rc 0 vs pristine `match=3 mismatch=4` rc 1 | survived D1; vacuous pass |
| B3 | drop only the two new stub controls (`ctrl_c1_f8`, `ctrl_c2_f6`, −42 B) | `CONTROLS_SELFTEST: PASS (cases=11)` rc 0 | `ftree`: no `C1-F8`/`C2-F6` lines; `CONTROLS: match=3 mismatch=2` rc 1 | survived D1; controls silently absent |

B1 is the S3 class the round targets: a zero-match needle read as a surviving mutant
(`killed=2 … guard=0` rc 1) instead of SETUP (`SETUP needle-ma` rc 2). Its intended detector
is the round-63 counter's L5 leg, which is BLOCKED with the counter. B2/B3 show the battery's
selftest never asserts the control set `main()` runs, so a battery with zero controls exits 0.

Fixes per survivor:

- **B1**: add a `round-62-c2.sh --selftest` case that runs the driver on an s3 fixture tree
  and requires `SETUP needle-ma` rc 2 (or make the round-63 counter's L5 leg exercise the
  s3 fixture in its own selftest).
- **B2/B3**: add a selftest case that runs `main()` on a fixture tree and asserts the expected
  control-id set (`C1-F8`, `C2-F6`, `C1-NOWORK`, `C2-NOWORK`, `C1-REAL`, `C2-REAL`,
  `PRIOR-*`), with `C1-F8`/`C2-F6` required to read `mismatch`.

## 3. Measured counter (`plans/round-62-c2.sh`) — complete, 12 mutants

All twelve read `C2R62_SELFTEST: PASS (cases=16)` rc 0 under D1: the driver's selftest does
not execute its legs or guard. Under D2 on `fast62` (pristine `killed=0 population=3 guard=0
(ma=0 mb=0 g=0 selftest=0 real=0)` rc 1): M1/M2/M3 force `ma`/`mb`/`g` → `killed=1`; M4 forces
`killed=3`; M5 forces `guard=1`; M6 skips both delegations → `killed=2 (ma=1 mb=1)`; M7
(needle-ma guard removed) is killed only on `s3tree` (`killed=2 … guard=0` rc 1 vs `SETUP
needle-ma` rc 2); M8 drops the real leg → `real=1`; M9 forces `selftest=1`; M10 forces
`refused=1` → **survived** (masked on every fixture: `selftest=0`/`real=0` on `fast62`, and
the `needle-ma` SETUP on `s3tree`); M11 exits 0; M12 prints a constant target line.

Survivor fix (M10 and the class): add fixture-tree cases to the driver's `--selftest` that
run the legs and assert the verdict line; for M10 use a tree whose counter selftest passes
but does not catch the M-A mutation (`ma=0`, `selftest=1`, `real=1`) and require `guard=0`.

## 4. Leg polarity on the candidate (evidence for the blocked counter)

Candidate `plans/round-62-c1.sh` sha `d0a0d120…`, baseline `C1_COUNTER_SELFTEST: PASS
(15/15 checks)` rc 0:

- L1 (CM2a, `stub=1`): `FINDING R62-C1-ST-stub-composition` / `FAIL (14/15 checks)
  failed=stub-composition` rc 1.
- L2 (CM2b, `SL_OK=1` appended before `stub_leg`'s closing `}`): `FINDING
  R62-C1-ST-stub-leg-negative-vector` / `FAIL (14/15 checks) failed=stub-leg-negative-vector`
  rc 1.
- L6 (GM5, candidate anchor): `C1_CHECK_SELFTEST: FAIL (cases=100 failed=3
  names=…,i6-superseded-stamp-conjunct-isolated)` rc 1.

So the three legs' polarity is correct on the candidate bytes; only the round-63 counter that
would run and count them is missing.

## 5. Tooling and scratch

No tool was installed, upgraded or removed. Binaries used: host `bash`, `git`, `python3`,
`sha256sum`, and the pinned `bao` v2.7.2 (`9c5f3628…`). Scratch
`/fast/scratch/hyaku/kagi-r63/R63MutC2/` is deleted before yield; no citable evidence was
written under `/tmp`; no secret value or token appears in this report.

COUNTER-STATUS: BLOCKED provider 429 Weekly/Monthly Limit Exhausted, reset 2026-11-12 17:59:03
BATTERY-STATUS: complete
SEAT-STATUS: partial counter half BLOCKED by the provider 429 (plans/round-63-c2.sh absent); battery and measured-counter halves complete

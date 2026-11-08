# R63MutC2 — mutation battery: C2_REFUSAL counter (BLOCKED), controls battery (complete), measured counter (complete)

Seat `R63MutC2` (mutation-tester), round 63 attempt 1, lane `kagi-shokunin`.
Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc`; frozen plan `plans/round-63.md`
(predeclaration `12c9e4284d6de52ba61fcc656165cd24e8b74480`; Amendment A3 read at 20:16:41 UTC,
uncommitted at write time). Read-only on lane source: every mutant is a byte copy under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63MutC2/`; no lane file was edited and no
git/jj mutation was run in the lane, a sibling lane, or any index.

Detector discipline. Each mutant is measured by two detectors, recorded separately:

- **D1 `--selftest`** — the instrument's own self-invocation mode. Killed iff it exits
  non-zero with a named finding line.
- **D2 fixture run** — the instrument on a fixture tree whose pristine reading is known.
  Killed iff the mutant's verdict line, field, or exit code differs from the pristine line.

Baselines measured before any mutant:

| fixture | pristine line | rc |
|---|---|---|
| `fast62` (60b5b7b tree, stub trial; round-62 driver) | `C2_HARDENED: killed=0 population=3 guard=0 (ma=0 mb=0 g=0 selftest=0 real=0)` | 1 |
| `s3tree` (round-61-c2.sh with the `# BEGIN-DECIDE`/`# END-DECIDE` marker lines removed; round-62 driver) | `C2_HARDENED: SETUP needle-ma` | 2 |
| `ftree` (stub counters + stub prior battery; round-63 controls) | `CONTROLS: match=3 mismatch=4` | 1 |
| `round-63-controls.sh --selftest` | `CONTROLS_SELFTEST: PASS (cases=11)` | 0 |
| `round-62-c2.sh --selftest` | `C2R62_SELFTEST: PASS (cases=16)` | 0 |

Instrument hashes (sha256):

| instrument | sha256 |
|---|---|
| `plans/round-62-c2.sh` at BASE `0c07aab` | `b26d42207ff51168811ebd1a32bd2969ee103497662d46f175ac2dd29d1ebe9c` |
| `plans/round-63-controls.sh` (working tree 20:12:46) | `74ed1624ba1eee5e8e78b52af9e18ec1f8dd5ee8048c568f2b1f557f5d783abb` |
| `plans/round-62-c1.sh` (candidate, 20:05:44) | `d0a0d1204378465cf0ff90b54bad52210e2ad0e7caf00127523151ac16875fd3` |
| `plans/round-61-c1-check.py` (candidate, 20:06) | `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6` |
| `plans/round-63-c1.sh` (candidate, 20:17:52) | `652665ecbb1f3a4a810c6ef478bdccd6f8a08c2d35d29bb9512380f3f411e298` |
| `bao` v2.7.2 (round-57 pin) | `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` |

## 1. Round-63 C2_REFUSAL counter — BLOCKED

`plans/round-63-c2.sh` is absent from the lane working tree at 20:18:47 UTC
(`ls plans/round-63-c2.sh` → no such file). The owning seat `R63ExecC2Counter` is parked
with no scratch directory and no `.ufo/waves/round-63/build/R63ExecC2Counter/`.

Cause, per the L1 ruling (provider text quoted verbatim):

```
[zai/glm-5.3-flash] 429 Weekly/Monthly Limit Exhausted
```

reset `2026-11-12 17:59:03`. The same 429 killed two tabi r81 executor seats in the same
window. This is a provider-route failure, not a seat defect, a timeout, or a quality
rejection; no amount of polling produces the artifact.

Consequence. The eleven assigned round-63 counter mutants cannot be built:

| id | intended mutation | intended detector |
|---|---|---|
| C-L1 | force `l1=1` after the L1 computation | `--selftest` non-zero named finding; BASE-tree run reads `killed=0` |
| C-L2 | force `l2=1` | same |
| C-L3 | force `l3=1` | same |
| C-L4 | force `l4=1` | same |
| C-L5 | force `l5=1` (A2: leg not in the population; the L5 instrument is the round-62 driver's `needle-ma` guard) | same |
| C-L6 | force `l6=1` | same |
| C-K | `killed=$((...))` → `killed=6` | same |
| C-G | `guard=$(...)` → `guard=1` | same |
| C-B | skip the battery delegation and read `l3=1; l4=1` | same |
| C-L5K | replace the L5 SETUP path with a `killed=2` verdict | `--selftest`; s3-tree run must read SETUP rc2 |
| C-R | drop the real-trial leg and read `real=1` | `--selftest`; fixture run must read `real=0` |

The C2 claim's kill rules K1/K2 (a BASE tree reads `killed=0`; each leg survives at BASE and
is killed on the candidate) therefore have no instrument to witness them this round. The
counter half of this seat is BLOCKED, not survived.

Recorded defect for a re-dispatched seat (plan Amendment A3 item 6 vs the candidate checker).
A3 names L6's needle as the BASE line

```
ok = len(qualifying) >= 3 and bool(superseded) and not denied
```

That line occurs **0 times** in the candidate `plans/round-61-c1-check.py` (measured). The
candidate's I6 conjunct is `ok = len(qualifying) >= 3 and not denied and superseded_ok`
(the repo-None branch is `ok = len(stamps) >= 3 and bool(superseded) and not denied \` plus
`and superseded_ok`). A plan-literal L6 mutation therefore matches 0 times on the candidate
tree and cannot fire. Fix: derive the needle from the candidate's actual conjunct (or accept
both forms), keeping the BASE checker's `C1_CHECK_SELFTEST: PASS (cases=75)` as the no-work
control. Measured with the candidate's actual anchor, the mutation makes the candidate
checker print `C1_CHECK_SELFTEST: FAIL (cases=100 failed=3
names=f9-forgery-unresolved,f10-forgery-unresolved,i6-superseded-stamp-conjunct-isolated)`
rc 1, so the leg is implementable.

## 2. Controls battery mutants — complete

`plans/round-63-controls.sh` (sha `74ed1624…`). Every mutant is a byte copy; D1 and D2 as
above.

| id | exact bytes delta | D1 `--selftest` | D2 fixture run | verdict |
|---|---|---|---|---|
| B1 | `plans/round-62-c2.sh:279` line `[ "$ma_applied" = 1 ] \|\| setup needle-ma` removed (41 bytes) | `C2R62_SELFTEST: PASS (cases=16)` rc 0 | `s3tree`: `C2_HARDENED: killed=2 population=3 guard=0 (ma=0 mb=1 g=1 selftest=1 real=1)` rc 1 (pristine: `C2_HARDENED: SETUP needle-ma` rc 2) | **survived D1; killed D2** |
| B2 | `main()` control list emptied: the seven `ctrl_*` call lines removed (103 bytes) | `CONTROLS_SELFTEST: PASS (cases=11)` rc 0 | `ftree`: `SKIPS: 0` / `CONTROLS: match=0 mismatch=0` rc 0 (pristine: `CONTROLS: match=3 mismatch=4` rc 1) | **survived D1; vacuous pass D2** |
| B3 | the two new stub controls dropped only: `ctrl_c1_f8` + `ctrl_c2_f6` calls removed (42 bytes) | `CONTROLS_SELFTEST: PASS (cases=11)` rc 0 | `ftree`: no `C1-F8`/`C2-F6` lines; `CONTROLS: match=3 mismatch=2` rc 1 | **survived D1; controls silently absent** |

B1 is the S3 class the round targets: a zero-match needle read as a surviving mutant
(`killed=2 … guard=0` rc 1) instead of SETUP (`SETUP needle-ma` rc 2). The round-62 driver's
own selftest does not catch it; the intended detector is the round-63 counter's L5 leg, which
is BLOCKED with the counter.

B2/B3 are the same class on the battery: the selftest asserts parsers, the stub builder,
report counting and the delegation shape, but never asserts the control set that `main()`
runs, so a battery with zero controls exits 0 (`match=0 mismatch=0`).

Fixes per survivor:

- **B1**: add a selftest case to `plans/round-62-c2.sh` that runs the driver on an s3
  fixture tree and requires `C2_HARDENED: SETUP needle-ma` rc 2 (or keep the round-63
  counter's L5 leg as the detector and make its own selftest exercise L5 on the s3 fixture).
- **B2**: add a selftest case that runs `main()` on a fixture tree and asserts the expected
  control-id set (`C1-F8`, `C2-F6`, `C1-NOWORK`, `C2-NOWORK`, `C1-REAL`, `C2-REAL`,
  `PRIOR-*`); a battery emitting fewer ids fails with a named finding.
- **B3**: same id-set assertion, specifically requiring `C1-F8` and `C2-F6` to be present
  and to read `mismatch` on the fixture tree.

## 3. Measured-counter mutants (`plans/round-62-c2.sh`) — complete

Twelve mutants of the measured counter's own legs and guard, built on the BASE bytes
(sha `b26d4220…`) and run on `fast62` (pristine `killed=0 population=3 guard=0
(ma=0 mb=0 g=0 selftest=0 real=0)` rc 1) and, where noted, `s3tree` (pristine `SETUP
needle-ma` rc 2). All twelve read `C2R62_SELFTEST: PASS (cases=16)` rc 0 under D1: the
driver's selftest does not execute its legs or guard.

| id | exact bytes delta | D2 observed line | verdict |
|---|---|---|---|
| M1 | `if [ "$mrc" -gt 0 ] && finding_named "$SCR/ma.out"; then ma=1; fi` → `ma=1` (−61 B) | `C2_HARDENED: killed=1 population=3 guard=0 (ma=1 mb=0 g=0 selftest=0 real=0)` rc 1 | killed D2 |
| M2 | same for `mb` (−61 B) | `C2_HARDENED: killed=1 … (ma=0 mb=1 g=0 …)` rc 1 | killed D2 |
| M3 | `if [ "$grc" = 1 ] && [ "$gv" = 0 ]; then g=1; fi` → `g=1` (−45 B) | `C2_HARDENED: killed=1 … (ma=0 mb=0 g=1 …)` rc 1 | killed D2 |
| M4 | `killed=$((ma + mb + g))` → `killed=3` (−15 B) | `C2_HARDENED: killed=3 population=3 guard=0 (ma=0 mb=0 g=0 selftest=0 real=0)` rc 1 | killed D2 |
| M5 | `guard=$(guard_calc …)` → `guard=1` (−53 B) | `C2_HARDENED: killed=0 … guard=1 (ma=0 mb=0 g=0 selftest=0 real=0)` rc 1 | killed D2 |
| M6 | both M-A/M-B delegations replaced by `:` and both `if` lines by `ma=1`/`mb=1` (−322 B) | `C2_HARDENED: killed=2 … (ma=1 mb=1 g=0 selftest=0 real=0)` rc 1 | killed D2 |
| M7 | `[ "$ma_applied" = 1 ] \|\| setup needle-ma` removed (−41 B) | fast62 identical to pristine; `s3tree`: `C2_HARDENED: killed=2 population=3 guard=0 (ma=0 mb=1 g=1 selftest=1 real=0)` rc 1 vs pristine `SETUP needle-ma` rc 2 | killed D2 (s3tree) |
| M8 | real-trial block replaced by `real_flag=1` (−370 B) | `C2_HARDENED: killed=0 … (ma=0 mb=0 g=0 selftest=0 real=1)` rc 1 | killed D2 (`real=1` vs `0`) |
| M9 | `selftest_flag=0` → `selftest_flag=1` (0 B) | `C2_HARDENED: killed=0 … (ma=0 mb=0 g=0 selftest=1 real=0)` rc 1 | killed D2 (`selftest=1` vs `0`) |
| M10 | `refused=0` → `refused=1` (0 B) | fast62 identical; s3tree `SETUP needle-ma` rc 2 (identical) | **survived** |
| M11 | `exit "$(exit_code "$guard" "$killed")"` → `exit 0` (−32 B) | `C2_HARDENED: killed=0 population=3 guard=0 (ma=0 mb=0 g=0 selftest=0 real=0)` rc **0** | killed D2 (exit code) |
| M12 | `verdict_line …` → a constant `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` (+9 B) | the constant line, rc 1 | killed D2 |

M10 is the one survivor. On every available fixture its forced `refused=1` is masked: on
`fast62` the guard is already 0 through `selftest=0`/`real=0`, and on `s3tree` the driver
SETUPs at `needle-ma` before `refused` is computed. The mutation is not strictly equivalent
(`refused` can change the guard when `selftest=1`, `real=1` and `ma=0`), but no fixture
reaches that state.

Fix for M10 and for the whole measured-counter class: add fixture-tree cases to
`plans/round-62-c2.sh --selftest` that run the legs and assert the verdict line (the
round-62 driver's selftest currently exercises only helpers). For M10 specifically, use a
tree whose counter selftest passes but does not catch the M-A mutation (`ma=0`,
`selftest=1`, `real=1`; e.g. the candidate counter with its `stub-composition` case removed)
and require `guard=0`.

## 4. Leg polarity on the candidate tree (evidence for the blocked counter)

Measured on the candidate files (sha `d0a0d120…` / `eb08094c…`), baseline
`C1_COUNTER_SELFTEST: PASS (15/15 checks)` rc 0:

| leg | mutant | observed | verdict |
|---|---|---|---|
| L1 (CM2a) | `stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1` → `stub=1` | `FINDING R62-C1-ST-stub-composition` / `C1_COUNTER_SELFTEST: FAIL (14/15 checks) failed=stub-composition` rc 1 | fires |
| L2 (CM2b) | `SL_OK=1` appended before `stub_leg`'s closing `}` | `FINDING R62-C1-ST-stub-leg-negative-vector` / `C1_COUNTER_SELFTEST: FAIL (14/15 checks) failed=stub-leg-negative-vector` rc 1 | fires |
| L6 (GM5) | candidate anchor `ok = len(qualifying) >= 3 and not denied and superseded_ok` → `ok = len(qualifying) >= 3 and not denied` | `C1_CHECK_SELFTEST: FAIL (cases=100 failed=3 names=f9-forgery-unresolved,f10-forgery-unresolved,i6-superseded-stamp-conjunct-isolated)` rc 1 | fires with the candidate anchor; the A3 BASE-line anchor matches 0 times (defect recorded in §1) |

## 5. Tooling and scratch

No tool was installed, upgraded or removed. Binaries used: host `bash`, `git`, `python3`,
`sha256sum`, and the pinned `bao` v2.7.2 (`9c5f3628…`). Scratch
`/fast/scratch/hyaku/kagi-r63/R63MutC2/` holds the extracted BASE tree, the fixture trees,
the mutant copies and the raw outputs; it is deleted before yield. No citable evidence was
written under `/tmp`; no secret value or token appears in this receipt.

COUNTER-STATUS: BLOCKED provider 429 Weekly/Monthly Limit Exhausted, reset 2026-11-12 17:59:03
BATTERY-STATUS: complete (B1-B3 measured; B1 killed by the s3-tree fixture run, B2/B3 survive the battery's own selftest)
MEASURED-COUNTER-STATUS: complete (M1-M12; 11 killed by the fixture run, M10 survived, all 12 survive the driver's own selftest)
SEAT-STATUS: partial counter half BLOCKED by the provider 429 (plans/round-63-c2.sh absent); battery and measured-counter halves complete

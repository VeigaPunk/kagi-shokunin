# Round 62 — mutation battery over the hardened C2 counter (seat R62MutC2)

Read-only seat: no lane file was edited; no git/jj mutation was run in the lane, a sibling
lane, or any index. Every mutant is a byte copy under
`/fast/scratch/hyaku/kagi-r62/R62MutC2/` (deleted before yield), placed at its real relative
path inside a repo skeleton (`plans/round-61-c2.sh` beside `plans/round-57-c2.sh`, so the
counter's `$0`-relative `REPO` and its `PIN_BAO` read resolve). The same bounded detector ran
on the pristine and the mutated bytes.

**Verdict rubric.**
- *killed* — a detector separates the mutant from the pristine bytes in the contract-red
  direction: the counter's own `--selftest` goes PASS -> FAIL printing a named `FINDING`; the
  guard moves 1 -> 0 on a fixture that must read 0 (or 0 -> 1 on a fixture that must read 0,
  for a guard-constant mutant); the counter's exit code moves non-zero -> 0 on a failing tree;
  a driver leg token moves killed -> not-killed; or the driver's guard fails on the mutant.
- *survives* — no detector separates the readings in the direction the mutant's contract
  names (behaviourally identical, or the mutant only moves a reading no detector asserts).
  A survivor is a coverage finding, not a contract change.
- *inconclusive* — the pristine baseline is not the contract reading the detector needs.

**Detectors.**
- `selftest` — `bash <counter-copy> --selftest` (fixture-driven, no bao, no network).
- `stub` — `bash <counter-copy> --tree <stubtree>`: a tree whose
  `corpus/openbao-seal-trial.sh` is a valid-sha256 stub that prints nothing and exits 0
  (sha256 `5fd8b3b7…`). The G-leg fixture.
- `obs` — `bash <counter-copy> --tree <obstree>`: a labelled fixture trial that prints every
  observable the guard is supposed to require EXCEPT `SEAL_SELFTEST: PASS (cases=N)`, and logs
  the ops argv shapes through the counter's PATH shim (every `bao` call carries `--help`; no
  server is started). Isolates the guard's selftest observable.
- `s5` — the obs tree with a `SEAL_SELFTEST: PASS (cases=5)` line (below the N >= 8 floor).
- `sh3` — the obs tree where `KAGI_SEAL_SHIM=SH3` flips T2 (vector `HBHHH`, not `HHBH`).
- `real` — `bash <counter-copy> --tree <tree>`: the real trial (throwaway OpenBao servers,
  127.0.0.1, scratch only). ~92 s per full run.
- `driver` — `bash <driver-copy> --tree <tree>`: the round-62 driver's own legs (~100 s: its
  guard leg (b) runs the measured counter on the real trial).

**Instrument bytes probed.**

| instrument | sha256 | note |
|---|---|---|
| `plans/round-61-c2.sh` at BASE (`60b5b7b6`) | `c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6` | 389 lines, no markers, guard = `legs_ran` + sha |
| `plans/round-61-c2.sh` hardened | `20614697f3720aa446501b3c3246748c762a025b99065a19556476d9ff3f4f29` | 478 lines, 25970 B; markers wrap only the function bodies |
| `plans/round-62-c2.sh` driver | `59553ef46b8e4052cb6bf0b863e90ad973347bd5c14d623b12e8384f46404c57` | 293 lines, 14818 B |
| stub trial fixture | `5fd8b3b790b3e6fce5967dccf3e1909b747952069e6b3ca9446a42410fff6c29` | prints nothing, exits 0 |
| obs fixture | `186d00ab3b8c6dc3b41d3f1a2e31abf05bdb1ccd25401472541cb09d276d2d3c` | all observables but SEAL_SELFTEST |
| s5 fixture | `150cfdd3c9e9cdeeb2c52005d644c0947c3b6b39ed1799e7d081b2dcb97dca93` | obs + `cases=5` |
| sh3 fixture | `ee80c081a274cd8e9b652162e1d18c73f20406b65cd9faf8b5604909968f3619` | obs + SH3 flips T2 |
| `bao` v2.7.2 | `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` | round-57 pin |

## BASE census (the pre-hardening bytes)

Pristine BASE readings: `--selftest` -> `C2_SELFTEST: PASS (cases=11)` rc 0; stub tree ->
`value=0 … guard=1` rc 1; obs tree -> `value=0 … selftest=0 guard=1` rc 1; real tree ->
`value=5 … shims=5 vectors=ok/5 … guard=1` rc 0 (92.3 s).

| id | substitution (BASE bytes) | detector | pristine | mutant | verdict |
|---|---|---|---|---|---|
| B-A | the value aggregation (`pass=0 … value=5`) -> `value=5` | selftest | PASS 11 | PASS 11 | survives |
| B-B | final `exit 1` -> `exit 0` | stub rc | rc 1 | rc 0 | killed |
| B-C | drop `st summary-reject c_summary_reject` (the negative summary case) | selftest | PASS 11 | PASS 10 | survives |
| B-D | `run()` -> `: > OUT; return 0` (real-trial leg skipped, empty outputs) | real guard | guard=1 | guard=1 | survives |
| B-E | guard expression -> `guard=1` | stub guard | guard=1 | guard=1 | survives (equivalent) |
| B-F | selftest body -> `echo PASS (cases=11); exit 0` | selftest | PASS 11 | PASS 11 | survives |
| B-G | shim loop (`shims_ok=0 …`) -> `shims_ok=5` | selftest | PASS 11 | PASS 11 | survives |
| B-H | shim loop drops the vector comparison | sh3 `shims=` | shims=4 | shims=5 | killed |
| B-I | `[ "$sn" -ge 8 ]` -> `[ "$sn" -ge 1 ]` | s5 `value=` | value=0 | value=5 | killed |
| B-J | drop the bao-pin check | stub `rc` under `R61_BAO=<wrapper>` | SETUP rc 2 | verdict rc 1 | killed |

BASE census: 10 applied, 4 killed, 6 survive. The survivors are exactly the C2-4 (guard
near-constant: B-D, B-E) and C2-5 (selftest does not execute the aggregation: B-A, B-C, B-F,
B-G) classes the round's claim targets. Raw log: `base-battery.log`.

## Hardened census (the candidate bytes)

Pristine hardened readings: `--selftest` -> `C2_SELFTEST: PASS (cases=21)` rc 0; stub tree ->
`value=0 … guard=0` rc 1; obs tree -> `value=0 … selftest=0 guard=0` rc 1; s5 tree ->
`value=0 … selftest=0 guard=0` rc 1; sh3 tree -> `value=0 … shims=4 vectors=4/5 guard=0` rc 1;
driver `--selftest` -> `C2R62_SELFTEST: PASS (cases=16)` rc 0; driver on the pristine tree ->
`C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` rc 0.

| id | substitution (hardened bytes) | detector | pristine | mutant | verdict |
|---|---|---|---|---|---|
| H-1 | block strictly between `# BEGIN-DECIDE`/`# END-DECIDE` -> `  echo 5` (the plan's M-A) | selftest | PASS 21 | FAIL 21 failed=6: `FINDING R61-C2-ST-decide-{pass,shims,none,selftest,ops,t2w}` | killed |
| H-2 | block strictly between `# BEGIN-SHIMS`/`# END-SHIMS` -> `  shims_ok=5` (the plan's M-B) | selftest | PASS 21 | FAIL 21 failed=3: `FINDING R61-C2-ST-shims-{ok,bad,summary}` | killed |
| H-3a | guard drops the `grep -qE '^SEAL_SELFTEST: PASS \(cases=[0-9]+\)' …` line | obs guard | guard=0 | guard=0 | survives (equivalent: `selftest_ok` carries the same observable) |
| H-3b | guard drops the same grep line **and** `[ "$selftest_ok" = 1 ] \|\| guard_obs=0` | obs guard | guard=0 | **guard=1** | **survives** |
| H-3b (s5) | the same H-3b mutant, second fixture | s5 guard | guard=0 | **guard=1** | **survives** (cross-check, not a separate mutant) |
| H-4 | selftest drops all 8 negative aggregation cases (`st decide-pass…t2w`, `st shims-bad`, `st shims-summary`) | selftest N, then driver | PASS 21 | PASS 13 (counter); driver `selftest=0`, guard=0, rc 1 | **killed by the driver's guard (a) N>=17 floor**; the counter's own selftest survives (F4) |
| H-5 | driver `OPEN_DEC='# BEGIN-DECIDE'` -> `'# BEGIN-DECIDX'` (M-A needle matches zero times) | driver rc/line | killed=3 guard=1 rc 0 | `killed=2 population=3 guard=0 (ma=0 mb=1 g=1 selftest=1 real=1)` rc 1 — **not SETUP** | **survives** (against the SETUP detector) |
| H-6 | final `[ "$value" = 5 ] && [ "$guard" = 1 ] && exit 0` / `exit 1` -> `exit 0` | stub rc | rc 1 | rc 0 | killed |
| H-7 | driver G leg `--tree "$SCR/gtree"` -> `--tree "$ROOT"` (reads the unmutated tree) | driver `g=` | g=1 | `g=0` (`killed=2 … guard=0 (ma=1 mb=1 g=0 selftest=1 real=0)` rc 1) | killed (the leg's polarity refuses the unmutated tree; the run's `real=0` is a separate baseline failure, see F3) |
| H-8 | `run()` -> `: > OUT; return 0` (real-trial leg skipped, empty outputs) | real guard | guard=1 | guard=0 (`value=0 … real=0 ops=0 t2w=0 … guard=0`) | killed |
| H-9 | the whole guard block (`guard=0 … && [ "$guard_obs" = 1 ] && guard=1`) -> `guard=1` | stub guard | guard=0 | guard=1 | killed |
| H-11 | insert `echo "C2_SELFTEST: PASS (cases=21)"; exit 0` after the selftest scratch mkdir | driver ma/mb | ma=1 mb=1 | `killed=1 … guard=0 (ma=0 mb=0 g=1 selftest=1 real=1)` rc 1 | killed (the driver's M-A/M-B legs refuse the constant-verdict counter) |
| H-12 | driver `OPEN_SHIM='# BEGIN-SHIMS'` -> `'# BEGIN-SHIMX'` (M-B needle matches zero times) | driver rc/line | killed=3 guard=1 rc 0 | `killed=2 population=3 guard=0 (ma=1 mb=0 g=1 selftest=1 real=1)` rc 1 — **not SETUP** | **survives** (against the SETUP detector) |

Exact commands (all with `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r62/R62MutC2`):

```
bash work/hardened/H1/plans/round-61-c2.sh --selftest
bash work/hardened/H2/plans/round-61-c2.sh --selftest
bash work/hardened/H3a/plans/round-61-c2.sh --tree work/obstree
bash work/hardened/H3b/plans/round-61-c2.sh --tree work/obstree
bash work/hardened/H3b/plans/round-61-c2.sh --tree work/s5tree
bash work/hardened/H4/plans/round-61-c2.sh --selftest
bash work/hardened/driver/plans/round-62-c2.sh --tree work/trees/H4
bash work/hardened/H5/plans/round-62-c2.sh --tree work/trees/pristine
bash work/hardened/H6/plans/round-61-c2.sh --tree work/stubtree
bash work/hardened/H7/plans/round-62-c2.sh --tree work/trees/pristine
bash work/hardened/H8/plans/round-61-c2.sh --tree work/trees/pristine
bash work/hardened/H9/plans/round-61-c2.sh --tree work/stubtree
bash work/hardened/driver/plans/round-62-c2.sh --tree work/trees/H11
bash work/hardened/H12/plans/round-62-c2.sh --tree work/trees/pristine
```

Mutant bytes (sha256 of each copy) are in `mutant-sha256.txt`; the raw captured lines are in
`raw/`.

## Survivors

**S1 — H-3b: the counter guard's selftest observable is removable.** Dropping both the
`SEAL_SELFTEST` grep and the `selftest_ok` conjunct leaves the guard reading `guard=1` on the
obs fixture (all other observables present, no selftest line) and on the s5 fixture
(`cases=5`, below the N>=8 floor). The guard's remaining conjuncts (`real_ok`, `none_ok`,
`ops_ok`, `t2_ok`, `shims_ok`) are all satisfied by a trial that fakes everything except the
selftest line, so the selftest requirement is not independently witnessed. The driver's G leg
uses a prints-nothing stub, which trips every observable at once, so it cannot isolate this
conjunct. **Fix:** add an obs-style fixture to the driver's legs (a tree whose trial prints the
T2 markers and logs the ops argv shapes but no `SEAL_SELFTEST` line) and require `guard=0` on
it; or make the guard read the selftest leg's captured file for the line with no flag
indirection and delete the duplicate. **Able to fail:** the obs fixture reads `guard=0` on the
pristine bytes and `guard=1` on the mutant.

**S2 — H-3a: the guard's `SEAL_SELFTEST` grep is dead weight (equivalent mutant).** Removing
the grep alone changes nothing, because `selftest_ok` is computed from the same file and the
same regex. This is not a false negative — the observable is still required — but the duplicate
conjunct is a maintenance hazard: a future edit that drops `selftest_ok` silently loses the
requirement (which is S1). **Fix:** keep one source of truth (the flag) and delete the grep, or
keep the grep and derive the flag from it; do not carry both.

**S3 — H-5: a zero-match M-A needle reads as a non-kill, not SETUP.** `apply_mut` returns 1
when a marker count is not exactly 1, and the driver's `if apply_mut …; then` treats that as
"leg absent", so the output is `killed=2 … guard=0 (ma=0 …)` rc 1. The claim fails closed
(guard=0, rc 1), but the driver cannot distinguish an instrument defect (the needle no longer
matches the measured counter) from a surviving mutant, and the assignment's expected detector
(SETUP, exit 2) does not fire. **Fix:** `apply_mut … || setup needle-ma` (and `needle-mb` for
the SHIMS leg); the driver already has a `setup` path and the plan's K2 says 0 or >1
occurrences must fail closed.

**S4 — H-12: the same defect on the M-B needle.** `killed=2 … guard=0 (mb=0 …)` rc 1, not
SETUP. **Fix:** the same `setup needle-mb` guard.

## Findings (non-survivor)

**F1 — the C2-5 class is closed.** H-1 and H-2 (the plan's M-A/M-B constant replacements) each
make the counter's own `--selftest` exit non-zero with named `R61-C2-ST-` FINDINGs (6 and 3
cases). At BASE the same two replacements passed `PASS (cases=11)` (B-A/B-G), so the hardened
selftest now executes the aggregation it guards.

**F2 — the C2-4 class is closed.** H-9 (guard -> `guard=1`) is killed: the stub tree reads
`guard=1` on the mutant and `guard=0` on the pristine bytes. H-8 (real-trial leg skipped) is
killed: the real tree reads `guard=0` on the mutant and `guard=1` on the pristine bytes,
because the guard requires `real_ok`/`ops_ok`/`t2_ok`, not a captured rc. At BASE both mutants
survived (B-D/B-E).

**F3 — one driver run's real leg failed after the G leg's full real run (H-7).** The H-7
mutant makes the G leg run the measured counter on the unmutated tree, which is a full real
run (~92 s); the subsequent guard leg (b) then read `real=0` in that run (`killed=2 … guard=0
(ma=1 mb=1 g=0 selftest=1 real=0)`). The G-leg reading (`g=0`) is the detector for H-7 and it
separated cleanly; the `real=0` is a baseline failure of a different leg and is recorded, not
counted as a kill. A driver G leg that reads the unmutated tree is therefore both a polarity
test and a runtime hazard: it doubles the driver's real-trial cost.

**F4 — the N>=17 floor lives in the driver, not the counter.** H-4 (all 8 negative aggregation
cases removed) leaves the counter's own `--selftest` at `PASS (cases=13)` rc 0; only the
driver's leg (a) (`N >= 17`) refuses it (`selftest=0`, guard=0). A consumer of the counter
without the driver has no floor: the counter's selftest will pass with any subset of its cases.

**F5 — the constant-verdict counter is refused by the driver's M-A/M-B legs.** H-11 (selftest
prints `PASS (cases=21)` and exits before executing anything) reads `killed=1 … guard=0
(ma=0 mb=0 …)` rc 1: the legs stop firing, `refused=0`, and the guard fails. This is the
plan's guard leg (c).

**F6 — the driver's own selftest does not cover the measured-counter legs.** Its 16 cases
exercise `apply_mut`, `selftest_n`, `verdict_field`, `finding_named`, `guard_calc`,
`exit_code` and `verdict_line` on fixtures, but no case runs the measured counter; the M-A/M-B/
G/real legs are only exercised by a full driver run (~100 s). That is why H-5/H-12 (needle
zero) and H-7 (G tree) are only visible in the driver's output line, not in its selftest.

MUTANTS: killed=8 survives=4 population=12

SEAT-STATUS: complete

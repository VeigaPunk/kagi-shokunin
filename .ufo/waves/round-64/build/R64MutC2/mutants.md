# R64MutC2 — mutation battery over the round-64 C2 instruments

Seat `R64MutC2` (mutation-tester, operability), round 64 attempt 2, lane
`kagi-shokunin`, claim BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`.
Frozen plan `plans/round-64.md` (commit `dff0929c0e084822b0fe32e0d164534c768f97fe`, Amendment A1) read before work. Read-only on lane source: every mutant is a byte copy
under `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64MutC2/`; no lane file was
written, and no mutating git/jj command was run anywhere.

Measured instruments (sha256 at freeze):

| instrument | sha256 | bytes |
|---|---|---|
| `plans/round-64-c2.sh` | `e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b` | 23406 |
| `plans/round-64-controls.sh` | `e37d497dc6bf56e02b26d8fec8ed24cf66d252968287302b74267ef158d8a678` | 38652 |

The counter was first mutated and validated on snapshot `061f0ad5…` (the first revision
after the owner seat fixed the `verdict_field` defect this seat reported; see §5); the
owner then landed the parallel-wave (l1/l2 + guard-(a)), real-trial-order, hardened-field
and two-attempt-trial revisions. The owner declared the bytes above FROZEN at
2026-11-08T03:09-03; every mutant was rebuilt against them and the whole sweep re-run on
them (anchor match 17/17; `freezedesc.py` records the sites). The battery sha above was
settled and re-measured on the same pass.

## 0. Detector trees (synthetic, under scratch)

A full tree byte-identical to BASE cannot discriminate these mutants: at BASE the
`round-63-controls.sh` lacks the `R63_CONTROLS_FIXTURE_ONLY` branch, so the counter's
battery delegation re-enters a counter and the run produces no verdict line at all
(measured: §1, K1). The bounded detectors therefore run on purpose-built stub
trees whose prerequisite instruments carry the exact needle bytes the legs mutate:

- `fx/A`: no battery, no trial, checker unaffected by the l6 mutation — pristine reads
  `killed=0 guard=0`; the forced-value mutants move one field each.
- `fx/C`: battery (fixture-only branch, both stub controls `mismatch`), a trial stub that
  satisfies the `value=5 shims=5 vectors=ok/5` greps, a checker that FAILs when the I6
  conjunct is dropped, and a `round-62-c1.sh` stub whose selftest FAILs only when the
  l1/l2 needles are rewritten — pristine reads the frozen target line
  `killed=5 population=5 guard=1 (… terminates=1 bound=1)` rc 0.
- `fx/D`: like fx/C but the battery's own `--selftest` FAILs, so pristine reads
  `guard=0 selftest=0` — the g_e guard leg's discriminating tree (D5).
- `fx/P`: a battery-carrying tree whose prior battery hangs unless
  `R63_CONTROLS_FIXTURE_ONLY=1` is passed (the recursion shape the pass-through prevents).
- D1 is the instrument's own `--selftest`; D4 is the frozen refutation invocation
  (`C2_RECURSION_BOUND=0`, no verdict line inside the bound).

Every mutant run is a file-redirected `timeout -k 5` invocation; no detector uses a
pipe, so a killed child's grandchild cannot stall the measurement.

## 1. Pristine baselines

| detector | command | rc | observed |
|---|---|---|---|
| `--selftest` (D1) | `bash plans/round-64-c2.sh --selftest` | 0 | `C2R64_SELFTEST: PASS (cases=21)` |
| `--tree fx/A` (D2) | `bash plans/round-64-c2.sh --tree fx/A` | 1 | `C2_REFUSAL: killed=0 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` |
| `--tree fx/C` (D3) | `bash plans/round-64-c2.sh --tree fx/C` | 0 | `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` |
| `--tree fx/D` (D5, g_e guard leg) | `bash plans/round-64-c2.sh --tree fx/D` (g_e guard leg) | 1 | `C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=0 real=1 terminates=1 bound=1)` |
| `C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4) | `C2_RECURSION_BOUND=0 timeout 25 bash plans/round-64-c2.sh --tree fx/C` | 124 | `none` |

**K1 (BASE tree, full extracted `09cbee8`, 209 MB, frozen counter):** `timeout 300 bash
plans/round-64-c2.sh --tree <BASE>` ⇒ `rc=124`, **no verdict line**; the BASE tree's
`plans/round-63-controls.sh` has 0 occurrences of `R63_CONTROLS_FIXTURE_ONLY`, so the
fixture-only flag cannot stop the probe re-entry (`evidence/base-tree-rc124.log`). Same
detector limit as the frozen plan's kill rule K1: a BASE-identical tree must read
`terminates=0`, so it cannot witness a mutant that only changes a verdict field. The C2
owner seat's 501 s `rc 0` is on the `09cbee8` extraction **plus the three candidate
files** (its `round-63-controls.sh` carries the fixture-only branch), i.e. a
candidate-shaped tree, not a byte-identical BASE tree; the owner's `counter.md` documents
the composition, so the two readings agree and no defect is open. The stubs are the
measurable tree.

## 2. Counter mutants (`plans/round-64-c2.sh`)

`differing` names the detector whose (rc, line) differs from the pristine row; every
other detector matched the pristine row exactly. `Δ` is the byte delta against the
pristine snapshot; the before (pristine) and after (mutant) sha256 are committed as
`evidence/hashes.txt`.

| id | mutation | site | Δ | differing detector | observed line | verdict |
|---|---|---|---|---|---|---|
| M1 | force l1 = 1 (append `; l1=1` to the l1 leg's firing line) | `plans/round-64-c2.sh:414` | +6 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=1 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M2 | force l2 = 1 (append `; l2=1` to the l2 leg's firing line) | `plans/round-64-c2.sh:415` | +6 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=1 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M3 | force l3 = 1 after the battery block (leg no longer observed) | `plans/round-64-c2.sh:334` | +5 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=0 l3=1 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M4 | force l4 = 1 after the battery block (leg no longer observed) | `plans/round-64-c2.sh:334` | +5 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=0 l3=0 l4=1 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M5 | force l6 = 1 after the checker-selftest branch | `plans/round-64-c2.sh:399` | +5 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=1 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M6 | force killed = 5 (`killed=$(killed_calc …)` -> `killed=5`) | `plans/round-64-c2.sh:446` | -43 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=5 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M7 | force guard = 1 (`guard=$(guard_calc …)` -> `guard=1`) | `plans/round-64-c2.sh:445` | -54 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=0 population=5 guard=1 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M8 | force terminates = 1 unconditionally (`terminates=$(terminates_calc …)` -> `terminates=1`) | `plans/round-64-c2.sh:447` | -47 B | — | all four detectors identical to pristine | **SURVIVED** |
| M9 | set the bound default to 0 (`${C2_RECURSION_BOUND:-1}` -> `:-0`) | `plans/round-64-c2.sh:100` | +0 B | `--tree fx/A` (D2), `--tree fx/C` (D3) | `C2_REFUSAL: killed=0 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=0)` (rc 1); also differs: `--tree fx/C` (D3) | **KILLED** |
| M10 | bound read only at parse time and never from the environment (`BOUND=${C2_RECURSION_BOUND:-1}` -> `BOUND=1`); the literal 'ignore a later change' mutant is equivalent because the code already caches at parse | `plans/round-64-c2.sh:100` | -23 B | `C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4) | `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` (rc 0) | **KILLED** |
| M11 | skip the battery delegation (`battery_run "$TREE" …` replaced by `brc=0`) | `plans/round-64-c2.sh:330` | -7 B | `--tree fx/C` (D3), `C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4) | `C2_REFUSAL: killed=3 population=5 guard=1 (l1=1 l2=1 l3=0 l4=0 l6=1 selftest=1 real=1 terminates=1 bound=1)` (rc 1); also differs: `C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4) | **KILLED** |
| M12 | drop the real-trial leg (the two-attempt loop + `hardened_field` check replaced by a no-op) | `plans/round-64-c2.sh:348` | -228 B | `--tree fx/C` (D3) | `C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M13 | drop the `R63_CONTROLS_FIXTURE_ONLY=1` pass-through in both `battery_run` branches | `plans/round-64-c2.sh:185,191` | -56 B | `--selftest` (D1), `--tree fx/C` (D3) | `C2R64_SELFTEST: FAIL (cases=21 failed=1)` (rc 1); also differs: `--tree fx/C` (D3) | **KILLED** |
| M14 | drop the `g_e` conjunct from the selftest-leg composition (`[ "$g_e" = 1 ] || selftest_leg=0` -> no-op) | `plans/round-64-c2.sh:443` | +4 B | `--tree fx/D` (D5, g_e guard leg) | `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` (rc 0) | **KILLED** |

Counter result: **13 killed / 1 survived of 14 mutants**
(14 built; ≥10 required).

Full per-detector evidence for every mutant (every line plus rc) is committed as
`evidence/detector-table.tsv` in this receipt directory; the discriminating line for
each mutant is above.

## 3. Battery mutants (`plans/round-64-controls.sh`)

| id | mutation | site | Δ | own `--selftest` | fixture P run | verdict |
|---|---|---|---|---|---|---|
| B1 | empty `main()`'s control list (all eight control calls, `probe_counters` … `ctrl_prior`) | `plans/round-64-controls.sh:740` | -152 B | **FAIL** (36 cases, 25 `FINDING`s; first `R64C-CTL-ST-e2e-base-f9-mismatch`) rc 1 | fx/P: `CONTROLS: match=0 mismatch=0` rc 0 — the mutant is a vacuous pass | **KILLED (selftest)** |
| B2 | force `C2-BOUND` to report `match` unconditionally (inserted before its bound=0 invocation) | `plans/round-64-controls.sh:567` | +100 B | **FAIL** (36 cases, 4 `FINDING`s incl. `R64C-CTL-ST-e2e-cand-bound-mismatch` and `R64C-CTL-ST-e2e-decorative-bound-mismatch`) rc 1 | fx/P: `CONTROLS: match=5 mismatch=3` rc 1 (forced `match` masked here; the selftest fixtures carry `terminates=1` and catch it) | **KILLED (selftest)** |
| B3 | drop the `R63_CONTROLS_FIXTURE_ONLY=1` pass-through in `ctrl_prior`'s fixture-only delegation | `plans/round-64-controls.sh:431` | -28 B | **PASS** (36 cases) rc 0 — not caught | fx/P: pristine re-emits `CONTROL PRIOR-C1-F8 … verdict=mismatch` (`CONTROLS: match=4 mismatch=4` rc 1); mutant `rc=124`, no `CONTROLS:` summary inside 30 s | **SURVIVED (selftest); killed by the fixture-P probe** |

## 4. Survivors and fixes

### S1 — M8, `terminates` is a tautology in every emitting path (survived)

`terminates` is computed at the verdict site from `SECONDS - T0` against 1200 s, but the
only way the process prints the line after 1200 s is for the caller not to enforce
`timeout 1200`; with the frozen invocation it is killed and prints nothing. So every run
that emits a line emits `terminates=1`, and forcing the field to 1 is equivalent.
**Fix (owner-reviewed):** extract the verdict emission into a helper that takes the
elapsed seconds as an argument, and add one `--selftest` case calling it with 1201 s and
asserting `terminates=0` plus exit 1. An environment budget override was considered and
rejected by the owner: it would let a caller fake `terminates=1`, and the frozen predicate
fixes the budget at 1200 s. With the frozen invocation M8 is behaviourally equivalent —
its survival is a coverage note about the field's self-report, not a defect in the legs.

### S2 — B3, the fixture-only pass-through is untested (survived the battery's selftest)

The battery's `--selftest` fixtures use prior-battery stubs that never re-enter a
counter, so dropping `R63_CONTROLS_FIXTURE_ONLY=1` from `ctrl_prior` changes nothing in
the selftest (36/36 PASS), while on a tree whose prior battery carries the branch it
hangs: pristine `mode=fixture-only` re-emits the PRIOR row, the mutant reads `rc=124`
with no `CONTROLS:` summary inside 30 s (fixture P). **Fix:** add a selftest case that
builds exactly fixture P's prior battery (contains the branch string; sleeps unless the
flag is set) and asserts the PRIOR-* row is re-emitted under a 30 s outer timeout.

### Equivalence note — the literal 'bound read once' mutant

The counter already resolves `BOUND=${C2_RECURSION_BOUND:-1}` once at parse time; there
is no later re-read, so the assignment's literal mutant would be textually identical to
the pristine. The load-bearing variant (M10, `BOUND=1`: the environment is never read)
was built and is killed by D4. A future refactor that makes the delegation re-read the
environment dynamically would need a selftest that changes the variable in-process.

## 5. Defects observed in the window (reported, not mutated)

- **D-64-M1 — `verdict_field` left the closing paren on the last field.** At counter sha
  `3f5843d244c3668575630213b972003b928b050ffb2b38da37fabc2d75268ca6`, `--selftest` read
  `C2R64_SELFTEST: FAIL (cases=21 failed=1)` / `FINDING R64-C2-ST-field-terminates-bound`:
  `bound=` is the last verdict field, so `verdict_field … bound` yielded `1)`/`0)` and
  every ghost guard was 0 (target line unreachable). Reported to `R64ExecC2Counter`,
  fixed by the owner at `061f0ad5…` (`tr ' ()' '\n'`); baseline then PASS (21), target
  line reproduced on fx/C.

- **D-64-M2 — battery selftest failed on its own fixture.** At battery sha
  `813ad8d6853ce97808b21a27fb3020112bf407363699471d1aa8fa8f8dcb2860` the pristine
  `--selftest` read `FAIL (cases=29 failed=1)` / `FINDING R64C-CTL-ST-e2e-empty-rc0`
  (case C expected rc 0 but the shared PRIOR stub emitted a mismatch). Fixed by the
  owner (`7c247aea…`, distinct PRIOROK stub); PASS thereafter.

- **D-64-M3 — case D's 240 s timeout left the stub's `sleep 999` holding the captured
  pipe**, so `--selftest` ran ~999 s instead of ~240 s (measured: my runs at
  `813ad8d6` were still in case D after 121 s and were killed at 900 s). Fixed by the
  owner with the `R64_BOUND_TIMEOUT` fixture knob; the settled selftest ran in 5.5 s

  and later revisions in ≤6 s.

## 6. Coverage reading

- The counter's `--selftest` (21 cases) caught **1 of 14**: M13, with
  `FINDING R64-C2-ST-fixture-battery-terminates` (its fixture battery honours the
  pass-through, so the bound composition is exercised end-to-end at helper level).
  The other 12 kills are the fixture-tree runs D2/D3/D4/D5. The selftest asserts the
  helpers, the verdict shape and the bound composition, not the leg/guard/trial wiring
  to the line — the same class as the round-63 finding that a driver's selftest does
  not execute its legs (R63MutC2 §3) — so the fixture-tree run remains the gate.
- The battery's `--selftest` (36 cases) caught **2 of 3**: the empty-control-list and the
  forced-`match` mutants fail with named `FINDING R64C-CTL-ST-*` lines; the
  pass-through removal survives (§4 S2).
- A surviving mutant is a coverage finding, not permission to change the frozen contract:
  no predicate, POP, kill rule, fixture or item condition was amended.

## 7. Tooling, scratch and restoration

- No tool was installed, upgraded or removed. Binaries used: host `bash`, `python3`,
  `sha256sum`, `timeout`, `diff`, `grep`; the pinned `bao` was never invoked by this seat.
- All mutants, trees and logs live under
  `/fast/scratch/hyaku/kagi-r64/R64MutC2/`; the directory is deleted before yield.
- No citable evidence was written under `/tmp`; no secret value, token or vault name
  appears here. All lane reads were `read`/`cp` from the lane; the lane's instrument
  bytes changed only by their owner seats' edits (shas in §head and in §5).
- Before/after hashes: pristine snapshot sha → mutant sha, per mutant, in the tables; the
  scratch copies are disposable by tasking and were not restored (the lane was never
  modified).

SEAT-STATUS: complete

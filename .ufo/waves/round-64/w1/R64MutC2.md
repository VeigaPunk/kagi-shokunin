# R64MutC2 — mutation report (round 64, w1)

Seat `R64MutC2` (mutation-tester, operability). Read-only on lane source: every
mutant is a byte copy under `${HYAKU_SCRATCH}/kagi-r64/R64MutC2/`; no lane file
was written and no mutating git/jj command was run. Full table, per-detector
evidence and byte deltas: `.ufo/waves/round-64/build/R64MutC2/mutants.md`.

Measured instruments (sha256 at freeze): `plans/round-64-c2.sh`
`e2d8171f4da7b5501906d643c98fe6f822b46baf266f19f2fe81ca5bb7f37e4b`, `plans/round-64-controls.sh` `e37d497dc6bf56e02b26d8fec8ed24cf66d252968287302b74267ef158d8a678`.

## Detectors

D1 `--selftest`; D2 `--tree fx/A` (pristine `killed=0 guard=0`); D3 `--tree fx/C`
(pristine frozen target `killed=5 population=5 guard=1 … terminates=1 bound=1`,
rc 0); D4 `C2_RECURSION_BOUND=0 --tree fx/C` (pristine: no verdict line, rc 124).
A full BASE tree cannot discriminate a field mutant — it produces no verdict line
(measured: `timeout 240 … --tree <BASE>` rc 124), so the stub trees are the
measurable tree.

## Counter mutants

| id | mutation | expected detector | observed | verdict |
|---|---|---|---|---|
| M1 | force l1 = 1 (append '; l1=1' to the l1 leg's firing line) · +6 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=1 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M2 | force l2 = 1 (append '; l2=1' to the l2 leg's firing line) · +6 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=1 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M3 | force l3 = 1 after the battery block (leg no longer observed) · +5 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=0 l3=1 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M4 | force l4 = 1 after the battery block (leg no longer observed) · +5 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=0 l3=0 l4=1 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M5 | force l6 = 1 after the checker-selftest branch · +5 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=1 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=1 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M6 | force killed = 5 ('killed=$(killed_calc …)' -> 'killed=5') · -43 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=5 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M7 | force guard = 1 ('guard=$(guard_calc …)' -> 'guard=1') · -54 B | `--tree fx/A` (D2) | `C2_REFUSAL: killed=0 population=5 guard=1 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M8 | force terminates = 1 unconditionally ('terminates=$(terminates_calc …)' -> 'terminates=1') · -47 B | — | no detector differs from pristine | **SURVIVED** |
| M9 | set the bound default to 0 ('${C2_RECURSION_BOUND:-1}' -> ':-0') · +0 B | `--tree fx/A` (D2), `--tree fx/C` (D3) | `C2_REFUSAL: killed=0 population=5 guard=0 (l1=0 l2=0 l3=0 l4=0 l6=0 selftest=0 real=0 terminates=1 bound=0)` (rc 1) | **KILLED** |
| M10 | bound read only at parse time and never from the environment ('BOUND=${C2_RECURSION_BOUND:-1}' -> 'BOUND=1'); the literal 'ignore a later change' mutant is equivalent because the code already caches at parse · -23 B | `C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4) | `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` (rc 0) | **KILLED** |
| M11 | skip the battery delegation ('battery_run "$TREE" …' replaced by 'brc=0') · -7 B | `--tree fx/C` (D3), `C2_RECURSION_BOUND=0 --tree fx/C`, 25 s (D4) | `C2_REFUSAL: killed=3 population=5 guard=1 (l1=1 l2=1 l3=0 l4=0 l6=1 selftest=1 real=1 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M12 | drop the real-trial leg (the two-attempt loop + 'hardened_field' check replaced by a no-op) · -228 B | `--tree fx/C` (D3) | `C2_REFUSAL: killed=5 population=5 guard=0 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=0 terminates=1 bound=1)` (rc 1) | **KILLED** |
| M13 | drop the 'R63_CONTROLS_FIXTURE_ONLY=1' pass-through in both 'battery_run' branches · -56 B | `--selftest` (D1), `--tree fx/C` (D3) | `C2R64_SELFTEST: FAIL (cases=21 failed=1)` (rc 1) | **KILLED** |
| M14 | drop the 'g_e' conjunct from the selftest-leg composition ('[ "$g_e" = 1 ] || selftest_leg=0' -> no-op) · +4 B | `--tree fx/D` (D5, g_e guard leg) | `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)` (rc 0) | **KILLED** |

Counter: **13 killed / 1 survived** of 14.

## Battery mutants

| id | mutation | expected detector | observed | verdict |
|---|---|---|---|---|
| B1 | empty 'main()''s control list (all eight control calls, 'probe_counters' … 'ctrl_prior') · -152 B | own `--selftest`; fixture-P probe | **FAIL** (36 cases, 25 `FINDING`s; first `R64C-CTL-ST-e2e-base-f9-mismatch`) rc 1 | **KILLED (selftest)** |
| B2 | force 'C2-BOUND' to report 'match' unconditionally (inserted before its bound=0 invocation) · +100 B | own `--selftest`; fixture-P probe | **FAIL** (36 cases, 4 `FINDING`s incl. `R64C-CTL-ST-e2e-cand-bound-mismatch` and `R64C-CTL-ST-e2e-decorative-bound-mismatch`) rc 1 | **KILLED (selftest)** |
| B3 | drop the 'R63_CONTROLS_FIXTURE_ONLY=1' pass-through in 'ctrl_prior''s fixture-only delegation · -28 B | own `--selftest`; fixture-P probe | **PASS** (36 cases) rc 0 — not caught | **SURVIVED (selftest); killed by the fixture-P probe** |

Per-mutant before/after sha256 and the full five-detector table:
`.ufo/waves/round-64/build/R64MutC2/evidence/hashes.txt` and
`…/evidence/detector-table.tsv`.

## Survivors and fixes

- **M8** (`terminates=1` forced): equivalent in every emitting path — the caller's
  `timeout 1200` kills an over-budget run before it can print, so the field is
  always 1 when printed. Fix (owner-reviewed): a verdict-emission helper taking the
  elapsed seconds, plus one selftest case calling it with 1201 s and asserting
  `terminates=0` rc 1; an env budget override was rejected (it would let a caller
  fake `terminates=1`).
- **B3** (drops `R63_CONTROLS_FIXTURE_ONLY=1` in `ctrl_prior`): the battery selftest
  uses prior-battery stubs that never re-enter a counter, so it PASSes (36/36); on a
  tree whose prior battery carries the branch the mutant hangs (fixture P: pristine
  re-emits `PRIOR-C1-F8`, mutant `rc=124` no summary inside 30 s). Fix: add that
  fixture to the selftest and assert the PRIOR row under a 30 s outer timeout.

## Defects observed (reported to the owners, not mutated)

- `verdict_field` kept the closing paren; `bound=` is the last field, so the counter's
  selftest read FAIL and the target line was unreachable at sha `3f5843d2…`; fixed by
  `R64ExecC2Counter` at `061f0ad5…` (baseline PASS(21), target line reproduced).
- The battery's pristine selftest read FAIL at `813ad8d6…` (`e2e-empty-rc0`), and
  case D's 240 s timeout left the stub's `sleep 999` holding the pipe (~999 s run);
  both fixed by `R64ExecControls` (`R64_BOUND_TIMEOUT`; PASS(34) in 5.5 s).

## Restoration

No lane file was modified by this seat; all mutants and logs are under
`/fast/scratch/hyaku/kagi-r64/R64MutC2/` (deleted before yield). Scratch copies are
disposable by tasking; the lane bytes changed only by their owner seats' edits.
No `/tmp` evidence, no secret value or token.

SEAT-STATUS: complete

# round-48 counter mutation test — K48MutCounters

Seat: K48MutCounters (mutation tester). Scope: one probe per claimed invariant on the frozen
counters; no lane file was edited (writes: this report dir only).

## Setup

- Lane scratch clone: `git clone --shared` of the lane at `52991e5da64cbacaa724b28b407cf5765fd21b41`
  into `$HYAKU_SCRATCH/kagi-r48/K48MutCounters/clone` (toplevel asserted = the clone).
- Frozen instrument sha256 in the clone reproduce the predeclaration pins exactly:
  c1 `527188fe…`, c2 `15f7a0c3…`, controls `72623061…`, c2-fixture `445ec7d5…`.
- 17 mutants (11 C1, 6 C2) written under `clone/mut/` so each counter copy resolves `LANE` to the
  clone exactly like the frozen script; each mutant was run through a copy of
  `plans/round-48-controls.sh` whose only edit is the path of the counter under test (C1 line or the
  `cp … .frozen` line); the fixtures path stays absolute and points at the clone's own
  `.ufo/waves/round-48/controls/fixtures`. Batch: `bash plans/ctl2-<id>.sh 76da518f` in the clone.
- Each mutant ran the full 16-control suite (10 C1 + 6 C2) so kills are counted across both halves.

## Mutant table (frozen controls)

| id | target | diff | change | killed by |
|---|---|---|---|---|
| M01-c1 | `round-48-c1.sh` | `@@ -128 +128 @@` | drop the setup_ok conjunct from the final conjunction | **SURVIVED** |
| M02-c1 | `round-48-c1.sh` | `@@ -122 +122 @@` | drop the entry-section evidence conjunct (entry_line ignored) | F3-no-entry-section, F6-wrong-version-entry |
| M03-c1 | `round-48-c1.sh` | `@@ -120 +120 @@` | T1's falsifier replaced by SH3 (updatekeys-no-op) — shim for T1 swapped with T3's | **SURVIVED** |
| M04-c1 | `round-48-c1.sh` | `@@ -120 +120 @@` | T3's falsifier replaced by SH1 (updatekeys-also-rotates) — shim for T3 swapped with T1's | **SURVIVED** |
| M05-c1 | `round-48-c1.sh` | `@@ -97 +97 @@` | DUP verdict accepted as HOLDS (multiple HOLDS lines for one test count as discriminating) | **SURVIVED** |
| M06-c1 | `round-48-c1.sh` | `@@ -50,2 +50 @@` | drop both sha256 pin checks (pins pinned-on-arrival) | F7-unpinned-binary |
| M07-c1 | `round-48-c1.sh` | `@@ -128 +128 @@` | drop the nosecret conjunct (AGE-SECRET-KEY leak no longer zeroes the value) | F8-secret-printed |
| M08-c1 | `round-48-c1.sh` | `@@ -122 +122 @@` | require only the real run's HOLDS (drop the shim's BROKEN requirement) | F5-weak-T5 |
| M09-c1 | `round-48-c1.sh` | `@@ -103 +103 @@` | drop the fail-closed final-line check on the real run | F4-silent-producer |
| M10-c1 | `round-48-c1.sh` | `@@ -57 +57 @@` | absent trial script reports SETUP instead of the BASE value=0 absent=1 | 0-do-nothing |
| M11-c1 | `round-48-c1.sh` | `@@ -106 +106 @@` | SETUP_OK drops the exit-code half: any shimless run without HOLDS counts as setup-ok | **SURVIVED** |
| N01-c2 | `round-48-c2.sh` | `@@ -67 +67 @@` | exact MATCH replaced by substring containment | **SURVIVED** |
| N02-c2 | `round-48-c2.sh` | `@@ -55 +55 @@` | stated reading taken from the first occurrence, not the last | P-reference, F3-partial, F4-wrong-number |
| N03-c2 | `round-48-c2.sh` | `@@ -64 +64 @@` | MISSING stated reading counts as MATCH | F1-delete-pairs |
| N04-c2 | `round-48-c2.sh` | `@@ -46 +46 @@` | search the whole SCORECARD.md instead of the ## Capabilities section | F2-readings-outside-section |
| N05-c2 | `round-48-c2.sh` | `@@ -63 +63 @@` | empty/timeout executed reading becomes 0 instead of SETUP | **SURVIVED** |
| N06-c2 | `round-48-c2.sh` | `@@ -65 +65 @@` | drop the K04 token match mode (exact compare for K04) | 0-do-nothing, P-reference, F1-delete-pairs, F2-readings-outside-section, F3-partial, F4-wrong-number |

Counts per counter across the 17 mutants (C1 controls only see C1 mutants, C2 controls only C2 mutants):

| control | mutants killed |
|---|---|
| `K1-0-do-nothing` | 1 |
| `K1-P-reference` | 0 |
| `K1-F1-constant-holds` | 0 |
| `K1-F2-path-bypass` | 0 |
| `K1-F3-no-entry-section` | 1 |
| `K1-F4-silent-producer` | 1 |
| `K1-F5-weak-T5` | 1 |
| `K1-F6-wrong-version-entry` | 1 |
| `K1-F7-unpinned-binary` | 1 |
| `K1-F8-secret-printed` | 1 |
| `K2-0-do-nothing` | 1 |
| `K2-P-reference` | 2 |
| `K2-F1-delete-pairs` | 2 |
| `K2-F2-readings-outside-section` | 2 |
| `K2-F3-partial` | 2 |
| `K2-F4-wrong-number` | 2 |

Survivors under the frozen control set (each killed by a proposed control, measured):

| mutant | why it survives | proposed killing control | measured |
|---|---|---|---|
| M01-c1 | value=0 anyway on every frozen fixture: each fixture that discriminates also makes the shimless run non-SETUP (F1: none_rc=0) or keeps the shim verdict non-BROKEN, so dropping the setup_ok conjunct changes no frozen reading | K1-F9-none-rc-silent — forged trial: real dir 5×`TRIAL Tn HOLDS` + final line, every shim dir 5×BROKEN, shimless dir silent exit 0; expect **0** | pristine=0 (setup_ok=0), M01=**5**, M11=**5** — measured |
| M03-c1 | shim substitution stays inside T1's BROKEN set: the reference trial is already BROKEN under sh3 as well as sh1 (matrix row T1), and the predicate only asks for BROKEN under the designated shim | K1-F11-diagonal-falsifiers — forged trial emitting BROKEN only on the designated diagonal (shN→TN) and HOLDS elsewhere, shimless exit 2; expect **5** | pristine=**5**, M03=**4** — measured |
| M04-c1 | same as M03 for T3: the reference trial is BROKEN under sh1 as well as its designated sh3 | K1-F11-diagonal-falsifiers — expect **5** | pristine=**5**, M04=**4** — measured |
| M05-c1 | no frozen fixture emits two `TRIAL Tn` verdict lines for one test, so the DUP branch is never taken | K1-F10-duplicate-holds — forged trial: real dir emits `TRIAL T1 HOLDS` twice and T2..T5 once, one BROKEN per test under each shim, shimless exit 2; expect **4** | pristine=**4** (T1 DUP), M05=**5** — measured |
| M11-c1 | setup_ok only loses its exit-code half; no frozen fixture has a shimless run that exits 0 without HOLDS *and* a discriminating real/shim pair | K1-F9-none-rc-silent (same fixture as M01; kills both) — expect **0** | pristine=0, M11=**5** — measured |
| N01-c2 | substring MATCH is never exercised: every frozen fixture states either the exact executed line, a number (K06/K08 paths) or a wholly different number | K2-F5-prefix-reading — fixture stating K07's reading as the strict prefix `CLAIMS_DECLARED: CLEAN` (executed `CLAIMS_DECLARED: CLEAN (claims=21)`) inside `## Capabilities`; expect **1** | pristine=**1**, N01=**0** — measured |
| N05-c2 | no frozen fixture produces an empty executed reading for any of K01..K10 | K2-F6-empty-executed-reading — fixture commit replacing `corpus/quote-locate.py` with a script that prints nothing; expect **SETUP** (exit 2) | pristine=**SETUP** `reason=empty-or-timeout-K02`, N05=**value=3** — measured |

## Evidence

### Shim × test discrimination matrix (reference tree, pristine counter internals)

```
MATRIX T1 real=HOLDS entry=1 sh1=BROKEN sh2=HOLDS sh3=BROKEN sh4=HOLDS sh5=HOLDS
MATRIX T2 real=HOLDS entry=1 sh1=HOLDS sh2=BROKEN sh3=HOLDS sh4=HOLDS sh5=HOLDS
MATRIX T3 real=HOLDS entry=1 sh1=BROKEN sh2=HOLDS sh3=BROKEN sh4=BROKEN sh5=HOLDS
MATRIX T4 real=HOLDS entry=1 sh1=HOLDS sh2=HOLDS sh3=BROKEN sh4=BROKEN sh5=HOLDS
MATRIX T5 real=HOLDS entry=1 sh1=HOLDS sh2=HOLDS sh3=HOLDS sh4=BROKEN sh5=BROKEN
C1_SOPS_AGE_TRIAL: value=0 discriminating=0 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2
```
The reference trial's falsifiers are not disjoint: T1 breaks under sh1 AND sh3, T3 under sh1/sh3/sh4,
T4 under sh3/sh4, T5 under sh4/sh5. A shim substitution that stays inside a test's BROKEN set can never
be observed by the frozen predicate (which only asks for BROKEN under the designated shim), which is
exactly what the two surviving shim-swap mutants demonstrate.

### Proposed-control runs (measured, one clean pass on the final fixtures)

```
PROPOSED P1 ctl=pristine rc=0 VAL=0 | C1_SOPS_AGE_TRIAL: value=0 discriminating=5 pins=1 setup_ok=0 nosecret=1 real_rc=0 none_rc=0 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P1 ctl=M01-c1   rc=0 VAL=5 | C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=0 nosecret=1 real_rc=0 none_rc=0 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P1 ctl=M11-c1   rc=0 VAL=5 | C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=0 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P2 ctl=pristine rc=0 VAL=4 | C1_SOPS_AGE_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=DUP,shim=BROKEN,entry=1,ok=0 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P2 ctl=M05-c1   rc=0 VAL=5 | C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P3 ctl=pristine rc=0 VAL=1 | C2_CAPABILITY_READINGS: value=1 keys=10 rev=042f4e5a14a240accc1ea3276a18d7e12456ff36
PROPOSED P3 ctl=N01-c2   rc=0 VAL=0 | C2_CAPABILITY_READINGS: value=0 keys=10 rev=7891a61e03ec3f1d4d239f5e428b78c65b8a94e8
PROPOSED P4 ctl=pristine rc=2 VAL=SETUP | C2_CAPABILITY_READINGS: SETUP reason=empty-or-timeout-K02
PROPOSED P4 ctl=N05-c2   rc=0 VAL=3 | C2_CAPABILITY_READINGS: value=3 keys=10 rev=92df374cb28bb5d0d7be7892f94c9645e7c972d3
PROPOSED P5 ctl=pristine rc=0 VAL=5 | C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P5 ctl=M03-c1   rc=0 VAL=4 | C1_SOPS_AGE_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=HOLDS,entry=1,ok=0 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
PROPOSED P5 ctl=M04-c1   rc=0 VAL=4 | C1_SOPS_AGE_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=HOLDS,entry=1,ok=0 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```
### Coverage notes

- `K1-P-reference`, `K1-F1-constant-holds` and `K1-F2-path-bypass` killed **none** of the 11 C1 mutants:
  the reference and the two forged-producer fixtures only constrain readings that every survivor keeps
  intact, and the final conjunction masks F1 (its shimless run exits 0, so pristine and every
  BROKEN-blind mutant both read 0). They are not redundant with the rest of the suite but they carry no
  discriminating power against this mutant set.
- The reference trial's five falsifiers are **not disjoint** (matrix above): a shim that falsifies T1
  also falsifies T3/T4 (sh3). Because the predicate asks only for BROKEN under the *designated* shim,
  no control built from the reference trial can observe a shim substitution that stays inside that
  BROKEN set; the diagonal fixture is the cheap control that restores the discrimination.
- Two earlier fixture revisions of the duplicate-HOLDS probe (shimless branch fell through to the shim
  arm, so `setup_ok=0` masked the DUP row) were discarded; only the pass above is reported.

### Hashes

| artifact | sha256[:16] |
|---|---|
| mutants/M01-c1.sh | `02842a8cbae5d077` |
| mutants/M02-c1.sh | `77b2a38dff09edc7` |
| mutants/M03-c1.sh | `1bfb0d9d8381186b` |
| mutants/M04-c1.sh | `78d58fc42a4de78d` |
| mutants/M05-c1.sh | `21396078d86407a2` |
| mutants/M06-c1.sh | `c19a02d596d735ed` |
| mutants/M07-c1.sh | `9a356b4949a701aa` |
| mutants/M08-c1.sh | `36caf05b3ba32a6a` |
| mutants/M09-c1.sh | `e26a73f7a9c4c7ad` |
| mutants/M10-c1.sh | `e80e0023ce5a3f79` |
| mutants/M11-c1.sh | `1fb4d8597551f9d4` |
| mutants/N01-c2.sh | `408eb26727cd45a5` |
| mutants/N02-c2.sh | `4c72985665c9d6c3` |
| mutants/N03-c2.sh | `4598d194c59ab4c4` |
| mutants/N04-c2.sh | `eed0d4c8ad45c0b6` |
| mutants/N05-c2.sh | `877637e2cf54e6d9` |
| mutants/N06-c2.sh | `6e29fbda0ed6dfdb` |
| proposed/fx-none-silent-trial.sh | `ea50cc532a1e0880` |
| proposed/fx-dup-trial.sh | `e22163c4db3dacf7` |
| proposed/fx-diagonal-trial.sh | `d508faaefe5ae55e` |
| proposed/c2-fixture2.py | `8a5472d8bddc9c83` |
| clone/plans/round-48-c1.sh | `527188fe635f6e7b` (frozen pin) |
| clone/plans/round-48-c2.sh | `15f7a0c3a6050a57` (frozen pin) |
| clone/plans/round-48-controls.sh | `7262306130a5107f` (frozen pin) |

Restoration: mutants live only in the scratch clone (`clone/mut/`, `clone/plans/ctl2-*.sh`) and
`$S/mutants/`; the lane's `plans/` files were read-only and still hash to the frozen pins above.
No AGE-SECRET-KEY string appeared in any captured output (`grep -rl AGE-SECRET-KEY` over all run logs: none).

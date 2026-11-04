# MutSweep — round-34 BUILD mutation probe
## Result

Selftest survivors: **M5, M6**. M1–M4 fail the shipped selftest. All six change the planted fixture counts, so the external fixture detector kills all six; this does **not** erase the two selftest coverage findings. No predicate/counter was changed. Axes: calibration, operability, coverage.
## Input and baseline

Frozen contract read first: `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-34.md`. Delivered script captured on polling attempt 7; no BASE fallback used. Delivered and captured SHA-256: `7d627d0b85e204272d1869b35b05f29820f4d2c6ddb1798ccac514a2f364bb99`. All six copies initially had that hash.

Commands below use these exact absolute bindings (scratch removed after report persistence):

```bash
export TMPDIR=/fast/scratch/hyaku/kagi-r34/MutSweep/tmp
S=/fast/scratch/hyaku/kagi-r34/MutSweep
P=$S/delivered/self-description-sweep.sh
```

Pristine commands: `bash "$P" --selftest`, `bash "$P" --root "$S/fix/clean"`, `bash "$P" --root "$S/fix/defect"`. Exit codes respectively 0, 0, 1. Defect exit 1 is expected.
### selftest-pristine

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 ok
CASE SD9 ok
SELFTEST: PASS (10 cases)
```
### root-clean-pristine

```text
SELF_DESCRIPTION: CLEAN n=0
```
### root-defect-pristine

```text
MISMATCH SD7 corpus/hidden-gate.sh mentions --selftest but SKILL.md never names hidden-gate.sh
MISMATCH SD8 corpus/README.md:14 range 'M42-1..M42-3' missing upper endpoint row '| M42-3 '
MISMATCH SD8 corpus/README.md:15 range 'M43-1..M43-2' row '| M43-5 ' exceeds upper endpoint M43-2
MISMATCH SD9 corpus/knowledge/entry-c.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-d.md missing verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)
```
## Fixture design

Clean: registered fake-gate.sh mentions --selftest; valid M40-1..M40-2 rows; entry-a has Reverify R29-1 with no trio (outside gate); entry-b has R33-2 and the complete trio. Existing SD1–SD6 fixture material is clean.

Defect tree adds: unregistered hidden-gate.sh; M42-1..M42-3 with only M42-1/M42-2 rows; M43-1..M43-2 with M43-5 beyond the endpoint; R33-4 entry-c missing all provenance; R33-5 entry-d with source: only. Expected SD7/SD8/SD9 = 1/2/2, observed 1/2/2. No fixture script contacts any network or vault.

## Mutation matrix

For each k, commands executed were `bash "$S/mut/M$k.sh" --selftest`, `bash "$S/mut/M$k.sh" --root "$S/fix/clean"`, and `bash "$S/mut/M$k.sh" --root "$S/fix/defect"`. Every last line is recorded below. “Survivor” follows the assignment definition: selftest remains PASS.

| Mutant | Expected detector | Selftest observed (exit; last line) | Root clean observed (exit; last line) | Root defect observed (exit; last line) | Selftest survivor? |
|---|---|---|---|---|---|
| M1: Delete SD7 loop | SD7 case fails; defect SD7 drops 1→0 | 1; `SELFTEST: FAIL (10 cases)` | 0; `SELF_DESCRIPTION: CLEAN n=0` | 1; `SELF_DESCRIPTION: MISMATCH n=4 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=0 SD8=2 SD9=2)` | No |
| M2: SD7 counts every top-level corpus shell/Python path without mention/registry guards | Clean case fails; SD7 false positives increase | 1; `SELFTEST: FAIL (10 cases)` | 1; `SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=2 SD8=0 SD9=0)` | 1; `SELF_DESCRIPTION: MISMATCH n=7 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=3 SD8=2 SD9=2)` | No |
| M3: SD8 accepts every token without lesson/row validation | SD8 case fails; defect SD8 drops 2→0 | 1; `SELFTEST: FAIL (10 cases)` | 0; `SELF_DESCRIPTION: CLEAN n=0` | 1; `SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=2)` | No |
| M4: Drop only SD8 k > m row scan | SD8 case fails; defect SD8 drops 2→1 | 1; `SELFTEST: FAIL (10 cases)` | 0; `SELF_DESCRIPTION: CLEAN n=0` | 1; `SELF_DESCRIPTION: MISMATCH n=4 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=1 SD9=2)` | No |
| M5: Require SD9 trio on every entry, removing admission-round gate | Below-round-30 clean entry becomes false positive | 0; `SELFTEST: PASS (10 cases)` | 1; `SELF_DESCRIPTION: MISMATCH n=1 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=0 SD8=0 SD9=1)` | 1; `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=3)` | **Yes** |
| M6: SD9 checks source: only | Source-only entry loses SD9 hit | 0; `SELFTEST: PASS (10 cases)` | 0; `SELF_DESCRIPTION: CLEAN n=0` | 1; `SELF_DESCRIPTION: MISMATCH n=4 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=1)` | **Yes** |

## Coverage findings

- **M5:** missing negative assertion: an entry whose admission is R29 (or no qualifying admission) and lacks the trio must remain clean. Shipped common selftest tree has no such knowledge entry; removing the round gate still passes all 10 cases. External clean fixture changes n=0→1 (SD9=1).
- **M6:** missing per-key assertions: retain source: while omitting verified-at: and/or recheck: and expect SD9. Shipped SD9 fixture omits all three, so a source-only checker still passes. External defect SD9 changes 2→1.

The SD8 case does exercise k > m: M30-1..M30-1 against rows M30-1 and M30-2; M4 correctly fails CASE SD8.

M3 construction correction: an initial exploratory edit replaced only the endpoint predicate (`elif ! :`), inadvertently leaving the k > m scan active; it passed selftest and reduced external SD8 2→1. That was not the assigned M3. Before the final M3 measurement above, the complete lesson/row validation block was removed so all tokens are accepted; final M3 fails CASE SD8 and reduces SD8 2→0. No exploratory result is counted as the assigned mutant.

## Actual mutation receipts
### M1

Commands (with the absolute S/TMPDIR bindings above):

```bash
bash "$S/mut/M1.sh" --selftest
bash "$S/mut/M1.sh" --root "$S/fix/clean"
bash "$S/mut/M1.sh" --root "$S/fix/defect"
```
selftest:

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)
CASE SD8 ok
CASE SD9 ok
SELFTEST: FAIL (10 cases)
```
root-clean:

```text
SELF_DESCRIPTION: CLEAN n=0
```
root-defect:

```text
MISMATCH SD8 corpus/README.md:14 range 'M42-1..M42-3' missing upper endpoint row '| M42-3 '
MISMATCH SD8 corpus/README.md:15 range 'M43-1..M43-2' row '| M43-5 ' exceeds upper endpoint M43-2
MISMATCH SD9 corpus/knowledge/entry-c.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-d.md missing verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=4 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=0 SD8=2 SD9=2)
```
### M2

Commands (with the absolute S/TMPDIR bindings above):

```bash
bash "$S/mut/M2.sh" --selftest
bash "$S/mut/M2.sh" --root "$S/fix/clean"
bash "$S/mut/M2.sh" --root "$S/fix/defect"
```
selftest:

```text
CASE clean FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=1 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=0))
CASE SD1 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=1 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=0))
CASE SD2 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=1 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=0))
CASE SD3 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=1 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=0))
CASE SD4 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=1 SD5=0 SD6=0 SD7=1 SD8=0 SD9=0))
CASE SD5 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=1 SD6=0 SD7=1 SD8=0 SD9=0))
CASE SD6 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=1 SD7=1 SD8=0 SD9=0))
CASE SD7 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=2 SD8=0 SD9=0))
CASE SD8 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=1 SD9=0))
CASE SD9 FAIL (rc=1 last=SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=1))
SELFTEST: FAIL (10 cases)
```
root-clean:

```text
MISMATCH SD7 corpus/claim-ledger.sh mentions --selftest but SKILL.md never names claim-ledger.sh
MISMATCH SD7 corpus/fake-gate.sh mentions --selftest but SKILL.md never names fake-gate.sh
SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=2 SD8=0 SD9=0)
```
root-defect:

```text
MISMATCH SD7 corpus/claim-ledger.sh mentions --selftest but SKILL.md never names claim-ledger.sh
MISMATCH SD7 corpus/fake-gate.sh mentions --selftest but SKILL.md never names fake-gate.sh
MISMATCH SD7 corpus/hidden-gate.sh mentions --selftest but SKILL.md never names hidden-gate.sh
MISMATCH SD8 corpus/README.md:14 range 'M42-1..M42-3' missing upper endpoint row '| M42-3 '
MISMATCH SD8 corpus/README.md:15 range 'M43-1..M43-2' row '| M43-5 ' exceeds upper endpoint M43-2
MISMATCH SD9 corpus/knowledge/entry-c.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-d.md missing verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=7 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=3 SD8=2 SD9=2)
```
### M3

Commands (with the absolute S/TMPDIR bindings above):

```bash
bash "$S/mut/M3.sh" --selftest
bash "$S/mut/M3.sh" --root "$S/fix/clean"
bash "$S/mut/M3.sh" --root "$S/fix/defect"
```
selftest:

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)
CASE SD9 ok
SELFTEST: FAIL (10 cases)
```
root-clean:

```text
SELF_DESCRIPTION: CLEAN n=0
```
root-defect:

```text
MISMATCH SD7 corpus/hidden-gate.sh mentions --selftest but SKILL.md never names hidden-gate.sh
MISMATCH SD9 corpus/knowledge/entry-c.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-d.md missing verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=2)
```
### M4

Commands (with the absolute S/TMPDIR bindings above):

```bash
bash "$S/mut/M4.sh" --selftest
bash "$S/mut/M4.sh" --root "$S/fix/clean"
bash "$S/mut/M4.sh" --root "$S/fix/defect"
```
selftest:

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)
CASE SD9 ok
SELFTEST: FAIL (10 cases)
```
root-clean:

```text
SELF_DESCRIPTION: CLEAN n=0
```
root-defect:

```text
MISMATCH SD7 corpus/hidden-gate.sh mentions --selftest but SKILL.md never names hidden-gate.sh
MISMATCH SD8 corpus/README.md:14 range 'M42-1..M42-3' missing upper endpoint row '| M42-3 '
MISMATCH SD9 corpus/knowledge/entry-c.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-d.md missing verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=4 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=1 SD9=2)
```
### M5

Commands (with the absolute S/TMPDIR bindings above):

```bash
bash "$S/mut/M5.sh" --selftest
bash "$S/mut/M5.sh" --root "$S/fix/clean"
bash "$S/mut/M5.sh" --root "$S/fix/defect"
```
selftest:

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 ok
CASE SD9 ok
SELFTEST: PASS (10 cases)
```
root-clean:

```text
MISMATCH SD9 corpus/knowledge/entry-a.md missing source: verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=1 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=0 SD8=0 SD9=1)
```
root-defect:

```text
MISMATCH SD7 corpus/hidden-gate.sh mentions --selftest but SKILL.md never names hidden-gate.sh
MISMATCH SD8 corpus/README.md:14 range 'M42-1..M42-3' missing upper endpoint row '| M42-3 '
MISMATCH SD8 corpus/README.md:15 range 'M43-1..M43-2' row '| M43-5 ' exceeds upper endpoint M43-2
MISMATCH SD9 corpus/knowledge/entry-a.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-c.md missing source: verified-at: recheck:
MISMATCH SD9 corpus/knowledge/entry-d.md missing verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=3)
```
### M6

Commands (with the absolute S/TMPDIR bindings above):

```bash
bash "$S/mut/M6.sh" --selftest
bash "$S/mut/M6.sh" --root "$S/fix/clean"
bash "$S/mut/M6.sh" --root "$S/fix/defect"
```
selftest:

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 ok
CASE SD9 ok
SELFTEST: PASS (10 cases)
```
root-clean:

```text
SELF_DESCRIPTION: CLEAN n=0
```
root-defect:

```text
MISMATCH SD7 corpus/hidden-gate.sh mentions --selftest but SKILL.md never names hidden-gate.sh
MISMATCH SD8 corpus/README.md:14 range 'M42-1..M42-3' missing upper endpoint row '| M42-3 '
MISMATCH SD8 corpus/README.md:15 range 'M43-1..M43-2' row '| M43-5 ' exceeds upper endpoint M43-2
MISMATCH SD9 corpus/knowledge/entry-c.md missing source:
SELF_DESCRIPTION: MISMATCH n=4 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=1)
```
## Hashes and exact restoration

Mutated SHA-256 values:

```text
97565a0738f2aeb14ace4540dd3b139554f15d8dbcecd26e15e37b4bfacb8a8c  /fast/scratch/hyaku/kagi-r34/MutSweep/mut/M1.sh
543da2e6fd46a155762b38e6c1b228621664d9f724b1d2a52e71cbab0a3b81af  /fast/scratch/hyaku/kagi-r34/MutSweep/mut/M2.sh
d21dd27266a421e9d828e0059a254bdac470f8c614978bbbc7c132f09e9ecf35  /fast/scratch/hyaku/kagi-r34/MutSweep/mut/M3.sh
511c29558498799cf37069302b6ab34fb069f58e217d621b5b4e46b943e3e2fa  /fast/scratch/hyaku/kagi-r34/MutSweep/mut/M4.sh
9380fde5f98b371d5314bbb3ced63136b7704b30903347c1bd0eb52536b07117  /fast/scratch/hyaku/kagi-r34/MutSweep/mut/M5.sh
6fca81470cf6adc07125412257fe1d721ff20c00f01b91c28c36224c56b27037  /fast/scratch/hyaku/kagi-r34/MutSweep/mut/M6.sh
```

Each scratch mutant was restored using `cp -p "$S/delivered/self-description-sweep.sh" "$S/mut/M$k.sh"`; then the **same three detectors** were re-executed against restored bytes. Every restored copy hashes to the pristine SHA-256 above. All restored selftests exit 0, clean fixtures exit 0, defect fixtures exit 1. Delivered lane bytes were never edited and final lane-file SHA-256 still equals the pristine hash.

| Restored copy | Selftest last line | Clean last line | Defect last line | SHA-256 matches pristine? |
|---|---|---|---|---|
| M1 | `SELFTEST: PASS (10 cases)` | `SELF_DESCRIPTION: CLEAN n=0` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)` | True |
| M2 | `SELFTEST: PASS (10 cases)` | `SELF_DESCRIPTION: CLEAN n=0` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)` | True |
| M3 | `SELFTEST: PASS (10 cases)` | `SELF_DESCRIPTION: CLEAN n=0` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)` | True |
| M4 | `SELFTEST: PASS (10 cases)` | `SELF_DESCRIPTION: CLEAN n=0` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)` | True |
| M5 | `SELFTEST: PASS (10 cases)` | `SELF_DESCRIPTION: CLEAN n=0` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)` | True |
| M6 | `SELFTEST: PASS (10 cases)` | `SELF_DESCRIPTION: CLEAN n=0` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=2 SD9=2)` | True |

## Scope and self-evaluation

No installs/updates, network, vault contact, git mutations, full-suite/build/lint/format runs or lane-tracked edits. A scratch bash syntax parse was additionally run before the initial matrix; not claimed as behavioral evidence. Raw behavioral receipts are embedded here rather than written to extra lane paths. Scratch cleanup uses Python finally after report persistence.

Self-evaluation (1–5): accuracy 4 (M3 construction error explicitly corrected and separated); completeness 4 (six assigned mutants and pristine/restored detectors recorded, fixtures removed by scope); clarity 4 (long verdict lines widen the required table); actionability 4 (two precise missing assertions, no contract changes); conciseness 4 (raw receipts intentionally duplicate table summaries). Overall 4.0. Highest-impact improvement: add SD9 below-gate and partial-trio cases. Would the user agree? Evidence supports these qualified scores; no admission judgment is made.

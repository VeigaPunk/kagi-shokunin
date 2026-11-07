# R58MutCounter — C1_ROUTED checker, mutation test (kagi round 58, attempt 1)

Seat: mutation-tester (calibration). Read-only on the lane instruments; every
mutant is a fresh rsync copy under `/fast/scratch/hyaku/kagi-r58/R58MutCounter/`
(deleted before yield). Receipts: `.ufo/waves/round-58/build/R58MutCounter/`.

Instrument under test, pinned (the lane moved during the wave; three revisions
were tested, all with the same eight-item verdict):

| pin | checker sha256 | wrapper sha256 | base |
|---|---|---|---|
| **primary** (lane at 12:38) | `6b9c0c9d25149a0115eee3d8b952d5c00f6f7dbc93eabb20116a55a3a5145586` | `48eab526ff9bb8c10a7ed9462addafe9f035223f835c7540c0b044e958df0d15` | `cand04` (full tree, rounds 56-58) |
| earlier (12:35) | `59f6eba4…` | same | `cand04` |
| earlier (executor pin) | `d37829c0…` | same | `cand03` |

Detector: `python3 -I -B <pinned checker> --root <mutant> --verbose`, plus
`bash <pinned wrapper> --tree <mutant>` for the driver legs. An independent
literal audit (`tools/audit.py`) is used only to state what each mutation changes.

## Baseline (`cand04`, pin `6b9c0c9d`)

```
C1_ROUTED: value=0 population=8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1   rc=0
CHALLENGE ok (unresolved=0): coverage-row tip count -> 120: broken-copy value=1 (expect 1)
```

## Mutation table — one mutation per item, substance broken, wording plausible

| item | mutation | expected | observed | verdict |
|---|---|---|---|---|
| I1 | LOG Round-57 record: both epoch-C receipt path tokens `controls-prefreeze-epochC*.txt` -> `…epochD*.txt`; `epoch C` token and wording kept | `i1=0`, value 1 | `value=1 population=8 i1=0 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1` rc1 | killed |
| I2 | `controls-prefreeze-epochC-final.txt`: `plans/round-57.md` pin `…b173` -> `…b170`; other four pins and `CONTROLS: match=15 mismatch=0` kept | `i2=0`, value 1 | `value=1 … i2=0 … guard=1` rc1 | killed |
| I3 | lesson S117 Gate quote `audit device's` -> `audit backend's` (15/16 words kept; quote absent from `S117.body`) | `i3=0`, value 1 | `value=1 … i3=0 … guard=1` rc1 | killed |
| I4 | lesson §Sources `Registry 114 → 117` -> `… → 116` (landing count wrong; measured 119 and gates.txt 116 untouched) | `i4=0` | `value=FAIL population=8 … i4=0 … guard=0` rc1 | killed |
| I5 | SKILL gate row: `--selftest` spelling -> `none of its own`; entry command, script name, verdict map kept | `i5=0`, value 1 | `value=1 … i5=0 … guard=1` rc1 | killed |
| I6 | `current-claims.py`: derived lesson surface -> literal `"corpus/lessons/round-56.md"` in the surface list | `i6=0`, value 1 | `value=1 … i6=0 … guard=1` rc1 | killed |
| I7 | lesson S115 Gate row: live heading -> old drift `Enabling and disabling audit devices` (all occurrences) | `i7=0`, value 1 | `value=1 … i7=0 … guard=1` rc1 | killed |
| I8 | `adjacency.tsv` opencode basis `SCORECARD.md:70` -> stale `SCORECARD.md:54` | `i8=0` | `value=1 … i8=0 … guard=1` rc1 | killed |

**All eight item predicates can fail; no item survives its own substance mutation.**
The I4 reading is `value=FAIL` because the frozen guard says "when GUARD=1, else
FAIL" and once I4 fails no wrong-count delta can add +1 (`guard=0`). Diffs:
`build/R58MutCounter/MUTATIONS.diff`; raw records `battery-batt07.jsonl`.

Isolation (`build/R58MutCounter/c9aud-i*.out`): base all 1; each mutant flips
exactly its target token, no cross-flip, and still satisfies the other seven items'
literal plan conditions.

## Survivors

Three shape-reads survived the two earlier pins; **the primary pin closes all
three with its own bindings**, and the probes confirm it:

| probe | mutation | earlier pins | primary `6b9c0c9d` |
|---|---|---|---|
| S1 (I3) | S117 access date `2026-11-07` -> `2026-11-06` | holds (`i3=1`) | killed (`i3=0`) via `set(DATE_RE.findall(s117)) & set(...)`, line 314 |
| S2 (I5) | entry-command script -> `corpus/other-claims.py` | holds (`i5=1`) | killed (`i5=0`) via the command-cell read, lines 401-405 |
| S3 (I1) | epoch-C receipt path -> `controls-prefreeze-epochC-gone.txt` | holds (`i1=1`) | killed (`i1=0`) via the existence check, lines 253-254 |

Readings: `c7-x{1,2,3}.out` (primary) vs `c3-x*.out` / `c4-x*.out` (earlier).
Exact old lines, bindings and the independently derived patch bundles
(`checker-patched.58e530b2.py`, `checker-patched.8a2fa2e1.py`, both verified) are
in `build/R58MutCounter/SURVIVORS.md`. **No survivor remains on the final bytes;
no patch routing is open.** The L1 should keep the three bindings when landing.

Residual remarks (not survivors): R1 `item8` hard-codes `FLEET_ROOT`
(`/home/vgpnk/Projects/shokunin`; the L1's conformance ruling — make it
env-overridable and name the bound); R2 `--no-challenge` exits 1 on a clean tree
(declared diagnostic semantics; the wrapper ignores it); R4 I4's tip/end class
reads the live registry count, so freeze `corpus/SOURCES.md` before the final
reading. R3 (I6 scanning every constant) is withdrawn: the tested pins exclude the
docstring and the selftest fixtures.

## Guard readings

**(a) input file removed** (`corpus/lessons/round-57.md`):
`C1_ROUTED: value=FAIL population=5 i1=1 i2=1 i3=x i4=x i5=1 i6=0 i7=x i8=1 guard=0`
rc1 (I6 reads 0 because its `--round` probe then cannot run); wrapper leg1
identical, challenge skipped, final `value=FAIL … guard=0` rc1.

**(b) printer stub** (constant `value=0 population=8 … guard=1`, ignores `--root`):
run directly it looks green; through the wrapper leg2 reads `broken-copy value=0 !=
value+1 (1)` -> `value=FAIL … guard=0` rc1. The stub is killed by the wrapper's
independent challenge leg, not by its own line.

**(c) I4 wrong count in the challenge copy only**: on the green base the checker
prints `CHALLENGE ok … broken-copy value=1 (expect 1)`; on the I4 mutant it prints
`CHALLENGE FAILED … broken-copy value=1 (expect 2)` -> `value=FAIL … guard=0`.
The wrapper's own copy reads `1 == 1` on green and `1 != 2` on the I4 mutant.

Wrapper legs: green `value=0 … guard=1` rc0; I4 mutant `value=FAIL … guard=0` rc1;
lesson removed `value=FAIL pop=5 … guard=0` rc1; stub `value=FAIL … guard=0` rc1
(`build/R58MutCounter/c8-wrap-*.out`, `GUARD-READINGS.md`).

## Method notes and restoration

- Two first-pass mutations were artifacts, not survivors: the initial I1/I7
  replaced only the first of two occurrence tokens in the same bullet, so the item
  correctly still held. Final mutations replace all occurrences in the record/row.
- A pruned copy without `.ufo/waves/round-56` reads `i6=0` on the tested pins
  (I6's `--round` probe runs round 56 through the tree's gate). Copy the whole tree
  (`git archive` and the wrapper's tar copy both include it); a copy-scope bound.
- No lane file was written: instruments, `LOG.md`, `SCORECARD.md`, `SKILL.md`,
  `corpus/*` were only read; the instrument hash was unchanged before and after
  each battery (`59f6eba4`, then `6b9c0c9d`). All mutants, witnesses and challenge
  copies lived under scratch and are deleted (disposable copies, no restore due).
- No tool install/upgrade was needed (no pacman/uv/npm call).
- Reproduce: copy the whole worktree, apply one hunk from `MUTATIONS.diff`, then
  `C1_CHALLENGE_PARENT=<scratch> python3 -I -B <pinned checker> --root <copy> --verbose`.

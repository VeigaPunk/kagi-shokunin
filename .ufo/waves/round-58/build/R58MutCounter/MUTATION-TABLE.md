# R58MutCounter — C1 mutation table (round 58, attempt 1)

Primary pin: checker `plans/round-58-c1-check.py` sha256
`6b9c0c9d25149a0115eee3d8b952d5c00f6f7dbc93eabb20116a55a3a5145586` (1022 lines,
lane state at 12:38), wrapper `plans/round-58-c1.sh` sha256
`48eab526ff9bb8c10a7ed9462addafe9f035223f835c7540c0b044e958df0d15`.
Base: `cand04`, an rsync snapshot of the lane worktree including
`.ufo/waves/round-56..58` (I6's `--round` probe needs round-56); per-file pins in
`BASE-cand04-pins.txt`. Detector:
`python3 -I -B <pinned checker> --root <mutant> --verbose`, cwd = mutant,
`C1_CHALLENGE_PARENT` under scratch. Each mutant is a fresh rsync copy; the lane
tree and its instruments were never written.

Earlier revisions tested with the same result (the instrument moved during the
wave): `d37829c0…` (executor-pinned; `battery-batt04.jsonl`, base `cand03`) and
`59f6eba4…` (reviewer-hardened; `battery-batt06.jsonl`). Both are kept in
`INSTRUMENT-PINS.md`.

## Baseline (`cand04`, pin `6b9c0c9d`)

```
C1_ROUTED: value=0 population=8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1   rc=0
CHALLENGE ok (unresolved=0): coverage-row tip count -> 120: broken-copy value=1 (expect 1)
```

The same baseline with no `ADJ_*`/`C1_*` environment is identical.

## Item mutations (one per item; each breaks only that item's substance)

| item | mutation (scratch copy only) | expected | observed (pin `6b9c0c9d`) | verdict |
|---|---|---|---|---|
| I1 | `LOG.md` Round-57 record: both epoch-C receipt path tokens `controls-prefreeze-epochC*.txt` -> `controls-prefreeze-epochD*.txt`; the `epoch C` token and all wording stay | `i1=0`, value 1 | `value=1 population=8 i1=0 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1 guard=1` rc1 | **KILLED** |
| I2 | `controls-prefreeze-epochC-final.txt`: `plans/round-57.md` pin `…b173` -> `…b170`; other four pins and `CONTROLS: match=15 mismatch=0` unchanged | `i2=0`, value 1 | `value=1 … i2=0 … guard=1` rc1 | **KILLED** |
| I3 | lesson S117 Gate row quote word `audit device's` -> `audit backend's` (15/16 words unchanged; the quote no longer occurs in `S117.body`) | `i3=0`, value 1 | `value=1 … i3=0 … guard=1` rc1 | **KILLED** |
| I4 | lesson `## Sources` `Registry 114 → 117` -> `Registry 114 → 116` (landing count wrong; measured count and gates.txt attribution untouched) | `i4=0` | `value=FAIL population=8 … i4=0 … guard=0` rc1 | **KILLED** (FAIL is the frozen else-branch: once I4 fails the challenge's +1 cannot fire) |
| I5 | `SKILL.md` gate row: the `--selftest` spelling in the selftest cell -> `none of its own`; entry command, script name, verdict map stay | `i5=0`, value 1 | `value=1 … i5=0 … guard=1` rc1 | **KILLED** |
| I6 | `corpus/current-claims.py`: lesson surface `f"corpus/lessons/round-{rnd}.md"` -> `"corpus/lessons/round-56.md"` (literal round-56 path in the surface list) | `i6=0`, value 1 | `value=1 … i6=0 … guard=1` rc1 | **KILLED** |
| I7 | lesson S115 Gate row: live heading `Enabling/Disabling audit devices` -> old drift `Enabling and disabling audit devices` (every occurrence in the row) | `i7=0`, value 1 | `value=1 … i7=0 … guard=1` rc1 | **KILLED** |
| I8 | `corpus/adjacency.tsv` opencode row basis `SCORECARD.md:70` -> `SCORECARD.md:54` (stale pointer; owner/status/claim/token unchanged) | `i8=0` (stale_basis>0) | `value=1 … i8=0 … guard=1` rc1 | **KILLED** |

Exact diffs: `MUTATIONS.diff`. Raw records: `battery-batt07.jsonl`.

## Isolation (independent literal audit, `tools/audit.py`)

Base `cand04`: `i1..i8 = 1`. Each mutant flips exactly its target token and no
other; no cross-flip; the mutated copy still satisfies every other item's literal
plan condition.

```
AUDIT i1 i1=0 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1
AUDIT i2 i1=1 i2=0 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1
AUDIT i3 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 i8=1
AUDIT i4 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 i8=1
AUDIT i5 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 i8=1
AUDIT i6 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 i8=1
AUDIT i7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 i8=1
AUDIT i8 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=0
AUDIT cand04 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 i8=1
```

## Survivors

The three conjuncts that survived the earlier pins (I3 date, I5 entry command, I1
receipt-path existence) are **closed in the primary pin `6b9c0c9d`** by its own
bindings; the probes now read `value=1` with `i3=0`, `i5=0`, `i1=0`
(`c7-x*.out`). Details and the exact lines are in `SURVIVORS.md`. No patch routing
remains for the final bytes.

## Notes

- Two first-pass mutation artifacts were **not** survivors: the initial I1/I7
  mutations replaced only the first of two occurrence tokens inside the same
  bullet, so the item correctly still held. The final mutations replace all
  occurrences in the record/row.
- A pruned tree copy (round-56 files removed) reads `i6=0`: I6's `--round` probe
  runs the tree's `current-claims.py` over round 56. Copy the whole tree (the
  wrapper's tar copy and `git archive` both do); a copy-scope bound, not a defect.
- Earlier pin `410b05e7` (12:19) read value 1..4 on valid trees (single-line Gate
  rows, single-line docstring sentence, every-constant literal scan, relocated I8).
  All four are repaired in the tested pins; those readings are history.

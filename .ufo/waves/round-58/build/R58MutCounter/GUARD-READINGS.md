# R58MutCounter — guard readings (a/b/c and the wrapper legs)

Primary pins: checker `6b9c0c9d…`, wrapper `48eab526…`, base `cand04` (full tree,
`.ufo/waves/round-56..58` included). Every leg was run against scratch copies only.

## (a) an item input file removed

`corpus/lessons/round-57.md` deleted from a copy (`ga`).

```
C1_ROUTED: value=FAIL population=5 i1=1 i2=1 i3=x i4=x i5=1 i6=0 i7=x i8=1 guard=0   rc=1
```

I3/I4/I7 skip (`x`), population 5 < 8, value FAIL, guard 0; I6 also reads 0
because its `--round` probe runs the (now absent) round-57 surface through the
tree's `current-claims.py`. On the earlier pin `d37829c0` (no round probe) the same
removal reads `i6=1`. Wrapper leg1 the same; its challenge leg is skipped
("skipped (value=FAIL or population=5)") and the driver line is
`value=FAIL … guard=0`, rc 1 (`c8-wrap-ga.out`). Fail closed.

## (b) a printer stub as the checker

Stub (`ins-stub4/plans/round-58-c1-check.py`) prints a constant
`C1_ROUTED: value=0 population=8 i1=1 … i8=1 guard=1`, ignores `--root` and
`--no-challenge`.

- Run directly it looks green: `value=0 population=8 … guard=1`, rc 0.
- Through the wrapper (same tree, stub as the sibling checker):
  leg1 parses the stub line (value 0, pop 8, all tokens 1);
  leg2's independent broken copy reads `value=0` and fails `count+1 = 1`
  (`challenge broken-copy value=0 != value+1 (1)`);
  final line `value=FAIL population=8 … guard=0`, rc 1.
  The wrapper's leg2 is the leg that catches a stub, and it does.

## (c) I4 statement changed to a wrong count, challenge copy only

The checker's internal challenge does exactly this (coverage-row tip count ->
measured+1 = 120, nothing else changed):

- Green base: `CHALLENGE ok (unresolved=0): coverage-row tip count -> 120:
  broken-copy value=1 (expect 1)` -> `guard=1`.
- I4 mutant (`Registry 114 → 116`): `CHALLENGE FAILED (unresolved=1): … broken-copy
  value=1 (expect 2)` -> `value=FAIL … guard=0`, rc 1.

The wrapper's independent copy does the same, two ways:
- green: `challenge broken-copy value=1 == value+1 (1)`;
- I4 mutant: `challenge broken-copy value=1 != value+1 (2)` -> `value=FAIL … guard=0`.

## Wrapper legs (pinned `48eab526`)

| tree | leg1 (`--no-challenge`) | challenge | stub leg | final | rc |
|---|---|---|---|---|---|
| green `cand04` | `value=0 pop=8` all 1s, guard=0 | `broken-copy value=1 == 1` | stub fails | `value=0 population=8 … guard=1` | 0 |
| I4 mutant | `value=1 … i4=0` | `1 != 2` | stub fails | `value=FAIL … i4=0 guard=0` | 1 |
| lesson removed | `value=FAIL pop=5 i3=i4=i7=x i6=0` | skipped | not evaluated | `value=FAIL pop=5 … guard=0` | 1 |
| printer stub | stub line (looks green) | `0 != 1` | stub fails | `value=FAIL pop=8 … guard=0` | 1 |

Note: leg1 runs the checker `--no-challenge`, where the checker deliberately exits 1
on a clean tree (guard=0 by design); the wrapper ignores that rc and certifies GUARD
from legs 2-3. A consumer that reads a bare `--no-challenge` exit code as the verdict
would misread it (residual R2 in the report).

# Round-68 BASE derivation (L1, independent of any seat)

Claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`, extracted with
`git archive` to `/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e`.

Counting command (L1's own python, not a counter, not the gate):

```
python3 - <<'PY'   # derives verified / col15 over the BASE tree
... shaped(col16) rows -> exists+regular, raw sha256==col10, size==col11,
    col13 quote locates under col14 (rendered via BASE rendered-text-v1.py,
    raw-literal by bytes); then col15 == rendered-text-v1 digest(file)
PY
```

Measured 2026-11-08:

```
BASE verified= 36 rendered= 31 col15match= 31
```

with no defect rows in the shaped population (every one of the 36 binds).
The 37th row that *declares* a lane-tree capture is S166, whose col 16 is
prose: `§1.2 Concept Overview; capture .ufo/waves/round-67/capture/S166.body`.
It is the +1 of C1's `verified` and of `col15` after the recut.

Gate readings at BASE (receipts in this directory):

- `census-start.txt` — `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)` / `SOURCES_CENSUS: CLEAN (rows=157 …)`, rc 0.
- `selftest.txt` — `SOURCES_CENSUS_SELFTEST: PASS (89 cases)`, rc 0.
- `fleet-wrapper.txt` — `kagi ok`, rc 0.
- `c1-base-round67-counter.txt` — the round-67 counter on the BASE tree
  (`C1_READTHROUGH: bound=36 located=36 caught=0/6 guard=0`, rc 1): the
  no-work control for C1's target.

Col-15 blindness witnesses at BASE (each must read CLEAN on the BASE gate):

- a col-15 cell replaced by another row's valid hex64 digest;
- a col-16 cell with one trailing space;
- the whole `source-fetches.tsv` saved with CR at line ends.
Receipts under `.ufo/waves/round-68/base/mut/` once the round's own
instrument confirms them; the revenger and reviewer seats re-derive them
independently.

## BASE blindness witnesses (measured 2026-11-08 by the L1)

Each witness is a FULL copy of the BASE extraction with exactly one mutation
of `corpus/source-fetches.tsv`; the BASE gate reads CLEAN on all three. These
are the classes C1 closes. Receipts in `.ufo/waves/round-68/base/mut/`.

| witness | mutation | BASE gate reading |
|---|---|---|
| `trailing-space.txt` | S113 col 16 += one space | `SOURCES_CAPTURES: CLEAN (path_rows=35 bound=35 located=35 prose=122)`; `SOURCES_CENSUS: CLEAN` rc 0 |
| `crlf.txt` | whole TSV saved with CR at every line end | `SOURCES_CAPTURES: CLEAN (path_rows=0 bound=0 located=0 prose=157)`; `SOURCES_CENSUS: CLEAN` rc 0 |
| `col15-swap.txt` | S155 col 15 <- S164's valid hex64 | `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)`; `SOURCES_CENSUS: CLEAN` rc 0 |

No-work control for the C1 target: the round-67 counter on the BASE tree reads
`C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=0` rc 1 (its own guard
compares to the round-67 literals), and the round-68 counter must read
`caught=0/6` with `verified=36 col15=31` there — a target the BASE state cannot
reach by doing nothing.
Correction (round 69): the bullet above misquotes `c1-base-round67-counter.txt` as `caught=0/6`; that receipt reads `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=0` (`.ufo/waves/round-68/base/c1-base-round67-counter.txt:21`). The round-68 BASE counter reads `caught=0/6` (`C1_VERIFIED: verified=36 col15=31 caught=0/6 guard=0`, `.ufo/waves/round-68/w1/R68ExecCounterC1/base-run.txt:19`).

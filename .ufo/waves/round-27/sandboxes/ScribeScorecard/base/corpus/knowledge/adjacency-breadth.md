# adjacency breadth — measured coverage inside shared directories

Source basis: `corpus/scope-gate.sh` (v2, round 17) +
`corpus/adjacency.tsv` (`# breadth` pins) + `corpus/surface-census.tsv`
(the 35-row declared universe), read-only against the live host on 2026-09-29.
The gate observed four required leaf directories, 182 direct children, 8
census-declared child buckets and 174 undeclared children. It did not read a
child's bytes, follow a child symlink, or commit a child-name manifest.

Reverify: R17-01, R17-02, R17-03, R16-01, R16-02, R16-03

## Why this half exists

Round 16 made every census row owned or shared, but it measured only rows that
already existed in the census. The four shared directory roots were explicitly
`# no-enumerate`; their breadth was prose:

| leaf directory | direct children | declared child buckets | undeclared |
|---|---:|---:|---:|
| `$HOME/.config/opencode` | 20 | 4 | 16 |
| `$HOME/.local/bin` | 105 | 2 | 103 |
| `$HOME/.agents` | 4 | 1 | 3 |
| `$HOME/.local/share/the-musketeer/chrome-profile` | 53 | 1 | 52 |
| **total** | **182** | **8** | **174** |

Before round 17, `grep -cE '^# breadth[[:space:]]+.HOME/'
corpus/adjacency.tsv` was 0 and no corpus command counted those directories.
A reader had to trust the four ratios in prose. The new declarations make the
ratios a verdict while preserving the ownership boundary: undeclared children
are counted, not absorbed into this lane's census.

## Data grammar

A pin is an exact four-field directive:

```
# breadth<TAB><dir><TAB>children=<N><TAB>declared=<M>
```

- `dir` MUST equal a required leaf `# no-enumerate` directory.
- `children` is the number of direct directory entries. `find -P` at
  `mindepth=1,maxdepth=1` supplies NUL-delimited names, so dotfiles and names
  containing tabs/newlines count once. Child symlinks count as entries and are
  never followed.
- `declared` counts distinct direct children that either equal a census row or
  lexically contain at least one census row. Multiple descendants under one
  direct child count once.
- Values are canonical decimal integers in `0..2147483647`; `declared` cannot
  exceed `children`.
- Extra/reordered fields are invalid. Directive fields are not citation slots;
  unchecked `lane:` or basis data cannot be smuggled after the counts.

The live declared buckets are:

- opencode: `opencode.json`, `agents/`, `plugin/`, `tools/`;
- local bin: `the-janitor`, `tac-check`;
- agents: `AGENTS.md`;
- chrome profile: `NativeMessagingHosts/`.

Those names explain the calculation here; the gate never prints them and the
TSV stores only counts. A committed name manifest would disclose the operator's
tool/application inventory and is deliberately refused.

## Required membership is derived

The breadth row set does not declare its own completeness. A `# no-enumerate`
directory requires a breadth pin exactly when it has neither a strict descendant
`# no-enumerate` directory nor a strict descendant census `# scan` directory.
That rule derives the four rows above.

Four aggregate ancestors are intentionally exempt:

- `$HOME/.config` — child no-enumerate `opencode` and scan `the-janitor`;
- `$HOME/.local/state` — scan descendants `the-janitor` and `tac`;
- `$HOME/.local/share` — child no-enumerate `the-musketeer`;
- `$HOME/.local/share/the-musketeer` — child no-enumerate `chrome-profile`.

Their observed counts (94/2, 15/2, 48/1, 2/1) are measurement evidence, not
pins. Pinning those churn-heavy aggregates would convert unrelated host activity
into routine false alarms. Deleting all breadth rows still fails:
`BREADTH-MISSING` is derived from the eight no-enumerate and four scan rows, not
from whether any breadth row survives.

## Rules and failure tokens

| rule | invariant | token |
|---|---|---|
| R10 extension | `$HOME` itself cannot be `# no-enumerate` | `ENUM-CLASH` |
| R12a | exact four-field schema; no duplicate row | `BAD-ROW` |
| R12b | pin is on a no-enumerate dir, not a scan dir or exempt aggregate | `BREADTH-NOENUM`, `BREADTH-SCAN`, `BREADTH-SCOPE` |
| R12c | every derived leaf has one pin | `BREADTH-MISSING` |
| R12d | canonical range and `declared <= children` | `BREADTH-INVALID` |
| R13a | root exists, is a real directory, is not a symlink, resolves inside HOME, and can be enumerated | `BREADTH-HOST-MISSING`, `BREADTH-NOT-DIR`, `BREADTH-UNVERIFIED` |
| R13b | live child count equals its pin | `BREADTH-CHILDREN-DRIFT` |
| R13c | live declared count below its pin is loss; above it is expansion | `BREADTH-DECLARED-DRIFT`, `BREADTH-EXCEEDS` |

Any token is exit 1. Missing inputs or inability to create the private temporary
NUL list are setup failures, exit 2. Clean is exit 0.

## Output contract

Default verify prints the breadth summary before the partition's terminal line:

```
BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174 missing=0 invalid=0 drift=0 exceeds=0 unverified=0)
ADJACENCY_SCOPE: CLEAN (... breadth_required=4 breadth_pins=4 ...)
```

`--breadth` additionally prints one count-only `ADJACENCY_BREADTH` line per
required directory and the sorted literal member set. Its final line is the
same `BREADTH_AUDIT` verdict so ledger row `R17-01` checks the measurement, not
an intermediate print.

## Bounds — what the measurement does not prove

1. **Counts are not membership.** Deleting one undeclared child and adding
   another leaves `children` unchanged. Names are refused for privacy, so a
   same-cardinality swap is invisible.
2. **Declared means census-linked, not handler-reachable.** The gate proves a
   child contains a declared row, not that every byte below it is loaded.
3. **An undeclared count is not ownership.** The 174 children remain foreign or
   out of scope; kagi neither inventories nor claims them.
4. **Hard drift is deliberately noisy.** A new unrelated binary under
   `.local/bin` makes the gate red until a reviewer re-measures. This buys
   prompt visibility at the cost of manual re-pinning; nothing schedules the
   gate.
5. **A child symlink is a dirent.** It counts once and is not followed. The live
   Chrome `SingletonSocket` may point outside HOME without exposing its target;
   only a breadth-root symlink is refused.
6. **The partition and breadth checks are orthogonal.** A breadth row can match
   while its group citation is stale, but the overall `ADJACENCY_SCOPE` verdict
   still fails because R6 fires.
7. **Host access is required.** A lone clone cannot reproduce live counts. A
   missing or unreadable root is never fabricated as zero.
8. **Aggregate coverage is intentionally absent.** The four exempt ancestors
   are derived and named, but their live totals are not committed promises.
9. **No scheduling.** Verification remains on-demand/operator-run.

## Reproduction

```bash
cd ~/Projects/shokunin/kagi-shokunin
bash corpus/scope-gate.sh
# BREADTH_AUDIT: CLEAN (... children=182 declared=8 undeclared=174 ...)
# ADJACENCY_SCOPE: CLEAN (...)                                    exit 0

bash corpus/scope-gate.sh --breadth
# 4 ADJACENCY_BREADTH lines; sorted ADJACENCY_BREADTH_SET;
# BREADTH_AUDIT: CLEAN (...)                                      exit 0

bash corpus/scope-gate.sh --selftest
# SCOPE_SELFTEST: PASS (61 cases)                                 exit 0

bash corpus/scope-gate.sh --falsify
# SCOPE_FALSIFY: PASS (caught=18/18 failed=0)                     exit 0
```

The 18 falsifiers are the round-16 nine plus nine breadth mutations: a removed
pin, child-count drift, both declared-count directions, a pin on an exempt
aggregate, a pin outside no-enumerate scope, an extra directive field, whole-HOME
scope widening, and a new census row under an already-live direct child.

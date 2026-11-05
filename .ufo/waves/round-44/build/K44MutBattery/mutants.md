# K44MutBattery — round-43 survivor reproduction + round-44 battery attack

Seat: K44MutBattery (leaf, mutation-tester). Work tree: predeclaration
`ae9e9eb319826a7ded0a47ba2d043c44aa1c3bae` in sandbox
`/fast/scratch/hyaku/kagi-r44/K44MutBattery/work` (shared clone of the lane; deleted before
yield). Lane tree untouched. Raw outputs: `raw/` next to this file (file names cited below).
All commands run with `HYAKU_SCRATCH` inside the sandbox; no tool installs (bash, git,
python3, coreutils only).

## 1. Mutant construction (frozen recipes, `raw/recipe-verify.txt`)

Byte-copy of the clone's `plans/round-43-c2.sh` placed inside the clone's `plans/` as
`r44b-real` (sha256 `2424b89b…e5086`, identical to the committed counter bytes), then the
battery's own python recipe block applied verbatim (markers count==1 asserted; post-conditions
asserted by the recipe itself and re-checked by grep):

- `r44b-mut-y1` sha256 `28f51a78…c27af` — N1 stale-refusal block cut (`# N1: stale fixture`
  … `N1=$?`), final condition `[ "$P1" = "0" ] && [ "$N2" = "1" ]`; no `"$N1"` remains.
- `r44b-mut-y2` sha256 `4730a2be…c3d5f` — N2 silent-refusal block cut, final condition
  `[ "$P1" = "0" ] && [ "$N1" = "1" ]`; no `"$N2"` remains.

Fixture-gate templates extracted from the battery bytes (heredocs `g-as` / `g-asi` /
`g-always`; `raw/gate-extract.txt`): accept-stale sha256 `522eb01b…b2012`,
accept-silent `6e2dd8ca…52024`, always-refuse `d784e012…a6eb0`.

## 2. Survivor receipts — 12-cell grid (`raw/grid-survivor.txt`, counter × gate at ae9e9eb3)

| counter | own gate | accept-stale (paired for y1) | accept-silent (paired for y2) | always-refuse |
|---|---|---|---|---|
| real (`r44b-real`) | **1** | **0** | **0** | **0** |
| y1 (`r44b-mut-y1`) | **1** (M43-7 survivor state) | **1** (paired mutant) | 0 (wrong pair) | **0** |
| y2 (`r44b-mut-y2`) | **1** (M43-7 survivor state) | 0 (wrong pair) | **1** (paired mutant) | **0** |

Every cell rc=0, stdout exactly one digit. All frozen expectations met: both round-43
counter-mutation survivors reproduced (each still reads 1 on the real gate), each killed only
by its paired negative fixture gate plus the always-refuse blanket, and the real counter reads
0 under each fixture gate (the `R_* = 0` legs the battery counts).

Isolation (`raw/grid-survivor.txt`): wrong pairs read 0 — y1×accept-silent = 0, y2×accept-stale
= 0. The battery's counting conditions reference only the paired gates, so no wrong-pair kill
can be credited; confirmed by direct execution.

## 3. Battery re-measurement at the predeclaration and claim BASE (`raw/battery-predecl.txt`)

| receipt | revision | value | frozen/smoke expectation | agree? |
|---|---|---|---|---|
| c1-real | ae9e9eb3 | **2** | 2 (smoke R2 `edecb282`) | yes |
| c1-skipfix | ae9e9eb3 | **0** | 0 (M43-7 state) | yes |
| c1-only-stale | ae9e9eb3 | **1** | 1 (smoke) | yes |
| c1-only-silent | ae9e9eb3 | **1** | ≤1 (counter header) | yes |
| c1-base | d54109d | **0** | 0 (committed receipt `.ufo/waves/round-44/controls/c1-base` = 0) | yes |
| c1-skipfix | d54109d | **0** | 0 (committed receipt `c1-skipfix` = 0) | yes |

The battery discriminates both survivors at the predeclaration tip (which already carries the
instrument, the round-43 counter bytes and the gate). **Zero disagreements** against the
committed BASE receipts (`measured-at.txt`: c1-base 0, c1-skipfix 0) and the smoke matrix.

## 4. Attacks on the battery itself

Method note: the battery's self-byte leg compares the invoked file against
`<CAND>:plans/round-44-c1.sh`, so a mutated battery is measurable only at a candidate-like
fixture carrying the mutated bytes at that path. Fixtures: scratch clones, one commit each,
identity `K44MutBattery (round-44 fixture) <k44mutbattery.fixture@invalid>` (declared;
deleted before yield; toplevel asserted). A first B1 attempt invoked against the predecl bytes
was correctly REFUSED by the self-byte leg (rc=2, no stdout) — kept as
`raw/battery-mut-b1-selfrefuse-at-predecl.txt`. Two earlier B2/B3 attempts failed on a
scripting bug (unquoted heredoc expanded `$D` inside the edit anchor; fixtures stayed pristine,
readings were the pristine battery's 2/0/1) — preserved as
`raw/battery-mut-B{2,3}-pristine-run-edit-broken.txt` and `…-edit-broken-attempt.txt`;
v2 reruns guard on bytes-differ and HEAD-advanced.

### B1 — drop the y1 always-refuse blanket leg (fixture `a46a28b3…01cab`)

Diff (`raw/battery-mut-b1-edit.txt`): line 183
`if [ "$R_AS" = "0" ] && [ "$Y1_AS" = "1" ] && [ "$Y1_AL" = "0" ]; then` → `… && [ "$Y1_AS" = "1" ]; then` (y2 side untouched).

| receipt | value | pristine battery value |
|---|---|---|
| B1-real | **2** | 2 |
| B1-skipfix | **0** | 0 |
| B1-only-stale | **1** | 1 |

**SURVIVING DEFECT (coverage finding).** The blanket-leg-dropped battery is indistinguishable
from the pristine battery on the entire frozen matrix — no committed receipt kills it; the
always-refuse legs are not load-bearing for any frozen receipt. Materiality demonstrated
(`raw/z-gate-ignoring.txt`): a gate-ignoring counter (`z`: `OVER=${CONTROLS_REPLAY_GATE:-}`
→ `OVER=`; and `z-y1`: z put through the frozen y1 recipe) reads **1 under every gate including
always-refuse** — the pristine battery refuses a y1-shaped gate-ignoring counter (needs
`Y1_AL=0`), B1 would credit it (needs only `Y1_AS=1`) and overcount. This is inside the
declared ceiling (counter shapes outside the frozen vocabulary) but it is a defect of the
battery's own matrix: the blanket proof is exercised by no receipt.

### B2 — widen accept-stale to accept-everything (fixture `d0422a02…9b16`)

Diff (`raw/battery-mut-B2-edit.txt`): the gate's silent-shape refusal `exit 1` → `exit 0`
(accepts everything).

| receipt | value |
|---|---|
| B2-real | **1** (≠ 2 → KILLED, kill-rule (a), receipt c1-real) |
| B2-skipfix | 0 |
| B2-only-stale | **0** (≠ 1 → also fails c1-partial) |

### B3 — widen BOTH fixture gates to accept-everything (fixture `73fe6a22…d7b`)

| receipt | value |
|---|---|
| B3-real | **0** — the mutated battery reads 0 at the candidate-like fixture, as required |
| B3-skipfix | 0 |
| B3-only-stale | **0** (≠ 1 → fails c1-partial too) |

Both gate-widening attacks fail the frozen matrix (fail-visible). The contrast with B1 is the
finding: gate-side blunting is caught by the frozen receipts; blanket-leg removal is invisible
to every one of them.

## 5. Comparison with committed evidence — disagreements

None. My c1-base / c1-skipfix at d54109d reproduce the committed receipts (`0`/`0`); my
predecl readings 2/0/1(/1) reproduce the smoke matrix (R2: real 2, skip-fixtures 0,
only-stale 1). The only new facts are the B1 surviving defect and the B2/B3 kill readings
above.

## Verdicts

- y1, y2: reproduced as round-43 counter-mutation survivors (read 1 on the real gate); each
  discriminated exactly by its paired fixture gate + blanket (killed: (1→0) with paired gate
  held against the mutant-reads-1 and blanket-refuses legs).
- Battery attack B1: **survived** — named defect with evidence (blanket legs unmeasured by the
  frozen matrix; gate-ignoring counter overcount demonstrated).
- Battery attacks B2, B3: **killed** by the frozen matrix (c1-real ≠ 2; B3 additionally reads
  0 at the candidate-like fixture).
- Restoration: nothing in the lane was modified; sandbox and fixtures deleted before yield
  (restoration evidence = pristine lane `git status` clean; byte-identity of the worktree
  counter copy recorded in `raw/recipe-verify.txt`).

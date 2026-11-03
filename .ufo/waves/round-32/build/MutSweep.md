# MutSweep — C1 self-description predicate: mutation check (round 32, kagi)

Seat: MutSweep (mutation-tester, leaf; no sub-spawns). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; frozen contract `plans/round-32.md` (commit `507dd9f`).
Scratch: `/fast/scratch/hyaku/kagi-r32/MutSweep/` — six `git clone --shared` clones (`base.git`, `m1.git`…`m5.git`),
each `checkout --detach 32c35fe…`; `git rev-parse --show-toplevel` printed the clone path before any edit.
Vault contact: none; `op` not invoked. No tool installs were needed (no pacman/uv/npx run).

## Method

1. `count-sd-used.sh` (in this directory; run from the scratch dir as `count-sd.sh`) — independent plain-grep
   derivation of SD1–SD5 written from the plan wording only (`0` exit on every root).
2. Delivered counter `--root <clone>` — first the version pinned at mtime 19:40:28 (v1), then the revision at 19:42:34 (v2);
   both are byte-pinned in this directory (`self-description-sweep.pinned.sh`, `self-description-sweep.v2.pinned.sh`).
3. SD6 measured by `bash corpus/claim-ledger.sh citations` run inside each clone for `m1`…`m5` and on pristine `base.git`;
   restored bytes are proven identical to the pristine tree by sha256, which is the restored SD6 measurement.
4. Each mutant was applied in a clone, measured, then reverted with `git -C <clone> checkout -- .`.

## BASE (pristine clone, all five files hashed)

| check | plain-grep derivation | delivered counter (v1 and v2) | plan's frozen BASE |
|---|---|---|---|
| SD1 | 2 (`PROVINCE.md:90` names both themes) | 2 | 2 |
| SD2 | 2 (`corpus/README.md:117,118`) | 2 | 2 |
| SD3 | 0 (7 tokens, every path resolves) | 0 | 0 |
| SD4 | 1 (`M31-6`, `corpus/lessons/round-31.md:214`) | 1 | 1 |
| SD5 | **1** whole row / 3 status cells only | **1** | **3** |
| SD6 | 2 (`UNRESOLVED` lines) | 2 | 2 |
| **sum** | **8** (row) / 10 (status cells) | **8** | **10** |

Counter verdict at BASE, exit 1:

```
SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)
```

**Plan-vs-code discrepancy (reported, not fixed).** SD5's code searches the whole latest calibration row
(`SCORECARD.md:1285`). That row's Evidence cell already reads "the summary stays `POLICY` while
R29-01/R29-02 are operator-blocked", so R29-01 and R29-02 are *named in the row*; only R25-02 is absent.
The plan's frozen `SD5 = 3` / sum 10 is reproducible only by reading the three status cells and ignoring the
Evidence cell. Consequence: the plan's declared BASE sum (10) is not what the delivered counter prints (8);
the do-nothing control (`n > 0`) and the C1 target (`n = 0`) are unaffected, because R5's fix (a round-32
calibration row naming all three reds) satisfies both readings. Neither the plan nor the counter was edited here.

## Kill matrix (BASE → mutant → restored)

| mutant | file : edit | expected check | plain-grep before → after | counter (v2) n and delta | killed |
|---|---|---|---|---|---|
| M-SD1 | `PROVINCE.md`: insert `- **Frontier — mutant:** secret-scanning detection` after line 90 | SD1 | SD1 2 → **3**; SD2/3/4 unchanged; SD5 1 unchanged | n=9, `SD1=3` — `MISMATCH SD1 PROVINCE.md:91 theme 'secret[- ]scanning' …` | **yes** |
| M-SD2 | `corpus/README.md`: insert `- **Field-name detection** — moved to core in round 32 (mutant fixture; no entry landed); adjacent to no sibling.` inside `## Frontier` | SD2 | SD2 2 → **3**; SD1/3/4 unchanged | n=9, `SD2=3` — `MISMATCH SD2 corpus/README.md:119 …` | **yes** |
| M-SD3 | `SHONEN.md`: append `  Evidence: corpus/no-such-file.md §Mutant (planted mismatch; no such file).` | SD3 | SD3 0 → **1**; SD1/2/4 unchanged | n=10, `SD3=1` — `MISMATCH SD3 SHONEN.md:13 token 'corpus/no-such-file.md' does not resolve under the root` | **yes**, not isolated (also `SD6=3`) |
| M-SD4 | `corpus/lessons/round-31.md`: append `- **Mutant fixture (planted, no table row):** M31-9 is named here only; …` | SD4 | SD4 1 → **2**; SD1/2/3 unchanged | n=9, `SD4=2` — `MISMATCH SD4 corpus/lessons/round-31.md:285 id 'M31-9' …` | **yes** |
| M-SD5 | `SCORECARD.md:1285`: `R29-01/R29-02 are operator-blocked` → `R29-01 is operator-blocked` | SD5 | whole row 1 → **2**; status-cell reading 3 → 3 (**no move**) | n=9, `SD5=2` — `MISMATCH SD5 SCORECARD.md:14 red id 'R29-02' is absent from the latest calibration row (SCORECARD.md:1285)` | **yes** (row reading only) |
| M-SD6 | none — per the item, SD6 is covered by the citations gate | SD6 | 2 at BASE; unchanged by M-SD1/2/4/5 | `SD6=2` on every mutant except M-SD3 | not mutated |

Mutant hashes (sha256 of the single mutated file; each clone showed exactly one dirty path):

```
M-SD1 39c154548bbf80982ef149702eca29c1653235d4cac8072c65903704e6d8fbf8  PROVINCE.md
M-SD2 88b36244e98baef16d7b027300c9dc204b3f878c0112297f045a8ee23b954c0d  corpus/README.md
M-SD3 01938c4b8bb9838ab459463c23b7d029ee1c5ae2252b2e5b17d8c3256fc6396e  SHONEN.md
M-SD4 d370157ce675d9129f5f9f37d3f61276e1e5616f8999a943decb65f9ba45e3ad  corpus/lessons/round-31.md
M-SD5 acd3c68514fc6c51b93bfa97dcff17e46fefcb5f4c1af1c7a4546fce50c2cc2a  SCORECARD.md
```

All five mutants were replicated into a second clone per mutant (`m1.git`…`m5.git`) and their files verified
byte-identical to the primary mutant hashes above before the delivered-counter runs.

## SD6 / cross-check coupling

| root | `UNRESOLVED` lines | `CITATION_GATE:` |
|---|---|---|
| `base.git` (pristine) | 2 | `BROKEN (cites=1988 docs=84 unresolved=2 ephemeral=0 labeled=20)` |
| M-SD1 (PROVINCE) | 2 | identical to BASE |
| M-SD2 (README) | 2 | identical to BASE |
| M-SD3 (SHONEN) | **3** — adds `UNRESOLVED SHONEN.md:13 corpus/no-such-file.md (local)` | `BROKEN (cites=1989 docs=84 unresolved=3 …)` |
| M-SD4 (round-31) | 2 | identical to BASE |
| M-SD5 (SCORECARD) | 2 | identical to BASE |

Every root printed `CITATION_LAYOUT: lone-clone fleet_absent=65` (scratch clones have no fleet root), the same
layout class the lane's own lone-clone runs report; fleet-only citations are unchecked in either layout.
Gate exit code was captured at BASE (1); the `m1`…`m5` runs lost their exit-code files (receipt defect on my side),
so for those roots only the printed gate line and count are claimed.

**SD3 is not single-check-isolating.** A missing `corpus/…` token is by construction also an unresolved citation,
so the SD3 fixture moves SD6 as well (2 → 3). The delivered selftest cannot see this: its fixture tree ships a stub
`corpus/claim-ledger.sh` that prints `CITATION_GATE: CLEAN (… unresolved=0 …)`, so `plant_sd3`'s expected
`MISMATCH n=1` passes. The other SD3 token forms (`LOG.md`, `SKILL.md`, `PROVINCE.md`) all resolve at BASE, so a
non-coupling SD3 fixture would have to plant a token outside the citation graph.

## Supplementary probe (not part of the matrix): is SD5 alive at all?

Inserting `(R29-02)` into the same calibration row's *What moved* cell moved the status-cell reading 3 → 2
(whole-row reading stayed 1, since the Evidence cell still names it), then reverted. The detector responds; the
BASE value depends only on which columns the counter searches. So M-SD5 is a genuine kill under the delivered
whole-row reading and a *no-op* under the reading that reproduces the frozen `SD5 = 3`.

## Restore evidence

After every mutant: `git -C <clone> checkout -- .` → `git status --porcelain` printed no lines.
Final six-clone state, all byte-identical to BASE:

```
PROVINCE.md               3e08f6af200371d4dba5d2d0cdeee893252c58861bf0cea51fb4e7b107993d33
corpus/README.md          dc05373dd174e604dc6ba8b8a60d6a428ec38de7e5be16bd6e1a9e7a30485920
SHONEN.md                 1bb89fc5c006f4a9f22a9e121f4533c15f65993a1db1b3d32fa81c57bb5c4277
corpus/lessons/round-31.md 4e6cb7ff533030898337000eee57145898b267669fd620a4c78a86fb62296560
SCORECARD.md              365f591ca811f10bd00567ecb2a96e5a1546f8e9050e0a696df1b6026854a506
```

Restored plain-grep counts in every clone (base, m1…m5): `SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 (row) | 3 (status cells) SD6=2`.
Machine receipt for all six roots (head, dirty-line count, five hashes, counts): `restore-check.txt` in this directory.
The lane tree was never mutated: `git -C <lane> status --porcelain` lists `?? .ufo/waves/round-32/` plus other seats'
in-progress edits (`PROVINCE.md`, `corpus/README.md`, `corpus/lessons/round-31.md`) — none written by this seat.

## Delivered counter versions measured

| pin | sha256 | mtime | note |
|---|---|---|---|
| v1 | `42b32a9b81a9f0f62d986f6e588f2c6fc462675b7b0675abe0371c8f98794386` | 19:40:28 | first run of all six roots |
| v2 | `61f83578583b35028bb841b6c54ef8a532b2d3fa1db3c069534ff501f5bbad26` | 19:42:34 | byte-identical to `corpus/self-description-sweep.sh`; re-ran all six roots |

`diff v1 v2` touches only the SD6 hit string (`"$loc $detail"` instead of `"$loc $rest"`); every verdict, count and
exit code is unchanged between the two versions. A repeat v2 batch re-confirmed the same verdict lines for five of
the six roots (its `m3` child was cut short with the parent shell, 5/6 captured).
Both versions print `SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)` at BASE, exit 1.

## Findings handed to the L1 (no predicate, counter or kill rule edited)

1. SD1, SD2, SD3, SD4 and SD5 each have a planted mismatch that moves its own count and (SD1/2/4/5) nothing else.
2. SD3's corpus-path fixture also trips SD6; the selftest's stubbed ledger hides the coupling.
3. SD5's frozen BASE (3) does not match the delivered code (1) at BASE; the plan's sum 10 is printed as 8.
   Either a plan corrigendum (`SD5=1`, sum 8) or a counter change (search the status cells only) is required;
   the round's R5 fix closes the claim either way. Operator/L1 decision — not taken here.
4. Code-reading observation (not measured): SD1 selects Frontier lines by `case $line in *Frontier*` (case-sensitive,
   any bullet line), not by the bold label; `PROVINCE.md:88`'s prose "The frontier bullet below" is lowercase and
   therefore does not fire. A future bullet whose prose capitalises "Frontier" would be counted.

## Commands run (clone roots under `/fast/scratch/hyaku/kagi-r32/MutSweep`; `TMPDIR` set to its `tmp/`)

| command | exit |
|---|---|
| `git clone --shared <lane> <clone> && git -C <clone> checkout --detach 32c35fe…` (×6) | 0 |
| `bash count-sd.sh <clone>` (BASE, m1…m5, s5b, six post-restore runs) | 0 |
| `bash corpus/claim-ledger.sh citations` (in `base.git`, 90.0 s) | 1 |
| `bash corpus/claim-ledger.sh citations` (in `m1.git`…`m5.git`, parallel) | not captured (see §SD6) |
| `bash self-description-sweep.pinned.sh --root <clone>` (BASE, m1…m5) | 1 each (`MISMATCH`) |
| `bash self-description-sweep.v2.pinned.sh --root <clone>` (BASE, m1…m5, twice) | 1 each (`MISMATCH`) |
| `git -C <clone> checkout -- .` (restores, ×11) | 0 |

## Not run (by design of this seat)

Full gates, `--selftest` of the delivered counter (the sweep seat's receipt), `op` probes, any lane edit, any commit.

## Cleanup

The six shared clones and the per-mutant work files were removed with the seat's scratch directory
(`rm -rf /fast/scratch/hyaku/kagi-r32/MutSweep`) after every receipt above, both counter pins, the two counting
scripts and the mutant diffs/hashes were copied into this directory. The contract's `trap … EXIT` shape would have
deleted the clones after the first shell call, so it was applied once at exit instead of per call.


# Round 33 — frozen claims contract (kagi, attempt 1)

Frozen BASE: `76f4eeae7aa9af4dbb9423f5632b55791824253a` (round-32 close, lane `master`,
local = remote at freeze). Frozen before any round-33 data: this file, `plans/round-33.controls.tsv`,
`plans/round-32.controls.tsv` and the START receipts under `.ufo/waves/round-33/controls/` are
committed alone, first, under `round-33: plan + frozen claims`. Any later change to a predicate,
counter, kill rule or target is a new lane commit that names this file's commit; it is not a
re-freeze (QUALITY QM29). Lane identity: `kagi-shokunin <kagi@shokunin.local>`.

All six axes stand at 9 (saturation line 9, stagnation window N=3). The last capability entered
round 29 (`feed-token-agree.py`); rounds 30, 31 and 32 completed with none, so the **stagnation
nudge fires** this round (AXES.md §The stagnation nudge): the lowest-axis obligation is waived and
the round must be a frontier/capability move. Both claims are sized inside that waiver.

## Inputs read before freeze

- `corpus/lessons/round-32-verifier-spotcheck.md` (non-author closure of round 32): C1 not admitted
  (frozen n=0 unmet, SD6 residual), C2 verified; routed defects **R32-1** (no planner seat), **R32-2**
  (Mistakes-row shape: `captured-by` must name a criterion id or `none`, plus a QUALITY criterion for
  the pre-freeze-control class), **R32-3** (S072 scope-cell precision), **R32-4** (stale SCORECARD
  prose "latest first-working round is 25"), **R32-5** (note only).
- BASE gate readings, measured this round at `76f4eea` and committed with this plan
  (`.ufo/waves/round-33/controls/base-values.txt`, `census-start.txt`):
  `SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=2)` (both SD6 lines are
  integrator-owned verifier files: `round-30-verifier-spotcheck.md:41`,
  `round-32-verifier-spotcheck.md:54`); registry rows 72; `corpus/knowledge/nist-*.md` 0;
  `corpus/prefreeze-control.sh` absent; `corpus/README.md ##Frontier` NIST lines 1;
  sources census `kagi ok` exit 0.

## C1 — capability acquisition (+ calibration): freeze-time BASE control execution

**What exists now:** nothing. `test -e corpus/prefreeze-control.sh` → exit 1 at BASE. Every round's
BASE expectation is written by hand into a plan and was, at round 32, frozen as an *estimate*
(SD5=3/total=10) that the delivered counter measured as 1/8 — the wave found it and the round
recorded it as M32-2 with no mechanism to catch the class (R32-2).

**What lands:** `corpus/prefreeze-control.sh` — a gate that takes a frozen controls file
(`id<TAB>expect<TAB>command`), extracts the named revision with `git archive` into `$TMPDIR`/`--work`
scratch, runs every command with that extraction as cwd (`$BASE` and `$LANE` exported), reads the
last non-empty stdout line's final integer, and compares it with the declared `expect`. Plus
`corpus/knowledge/prefreeze-controls.md` (schema, verdict table, bounds, falsifiers) and one row in
the SCORECARD capabilities table.

**Frozen predicate** (identical sentence in the script's header, this plan and the receipt label):

> PREFREEZE: CLEAN (controls=N mismatch=0) — every declared BASE value equals the value its own
> counting command measures on the extracted BASE tree.

**Counting commands** (run from the lane root; each is also the receipt label):

    bash corpus/prefreeze-control.sh run --base 76f4eeae7aa9af4dbb9423f5632b55791824253a \
      --controls plans/round-33.controls.tsv
    bash corpus/prefreeze-control.sh run --base 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b \
      --controls plans/round-32.controls.tsv
    bash corpus/prefreeze-control.sh --selftest
    awk '/^## Capabilities$/,/^## Saturation$/' SCORECARD.md | grep -c 'prefreeze-control.sh'

**BASE (before):** artifact absent (`test -e` exit 1); capabilities-table rows naming it 0.

**Target:** (a) the round-33 controls run prints `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0;
(b) the round-32 controls run prints `PREFREEZE: MISMATCH (controls=2 mismatch=2)` exit 1, naming
`sd5 expect=3 measured=1` and `total expect=10 measured=8` — the M32-2 replay, the fix shown able to
fail; (c) `--selftest` prints `PREFREEZE_SELFTEST: PASS (cases=N)` exit 0 with N ≥ 8; (d) the
capabilities-table count is ≥ 1.

**Kill rule:** any of (a)–(d) unmet at the measured revision → C1 not admitted and reported as a
partial move; no re-scope after data. **Do-nothing control:** the BASE readings above — leaving the
tree alone keeps the artifact absent and the count 0, so the target is unreachable without the work.
The measured red witness at `32c35fe` is committed as a receipt this round
(`.ufo/waves/round-33/final/c1-red-witness.txt`).

**Sourced claim:** the capability's knowledge entry cites `S072`-class provenance only for the
round-32 replay; the claim itself is an executable gate, so no new source is required for it.
**Named ceiling:** the harness proves declared-vs-measured agreement for numeric counters only; a
command that prints no integer is `NORESULT` (SETUP, exit 2), never a pass; it cannot judge whether
the declared *predicate* is the right one.

## C2 — coverage/expansion: NIST key-management ground frontier → core

**What exists now:** `corpus/knowledge/nist-*.md` 0 files; the NIST key-management lead is a
`corpus/README.md ## Frontier` bullet ("NIST key-management draft status — distinguish final
guidance from IPDs before adopting controls") and a `PROVINCE.md` Frontier line. Registry holds 72 rows.

**What lands:** the §10 assimilation of ONE theme — the staged `merge/kagi/` NIST key-management
family-status package — as two in-round re-grounded knowledge entries:
`corpus/knowledge/nist-key-management-guidance-status.md` and
`corpus/knowledge/nist-key-management-parts-withdrawal.md`; the ten registry rows those two entries
cite (staged S061/S062/S063/S079/S080/S083/S084/S085/S086/S087, renumbered by document to continue
the lane registry at S073–S082); one capture row per adopted id in `corpus/source-fetches.tsv`; a
`PROVINCE.md` Core bullet; and removal of the discharged Frontier bullet in both `PROVINCE.md` and
`corpus/README.md` (QUALITY QM33 — a frontier-to-core move removes the frontier entry the same round).

The staged entry `nist-key-management-family-status.md` is **refused as staged**: its Part 2/Part 3
rows print "(Final)" and omit the withdrawal wrapper that its own sibling entry documents; flip —
a version whose Part 2/Part 3 rows carry the withdrawal date and the Rev. 1 successor.
`nist-key-management-part2-part3-substance.md` is deferred under the 1–3 entry cap (not a reject).

**Frozen predicate** (identical sentence in this plan, the round lesson's Gate and the receipt label):

> NIST_CORE: CLEAN — the two named entries exist, every id they cite resolves in the registry as
> `mined`, the discharged Frontier bullet is gone from both files, and the fleet census exits 0.

**Counting commands** (run from the lane root unless noted):

    ls corpus/knowledge/nist-key-management-guidance-status.md \
       corpus/knowledge/nist-key-management-parts-withdrawal.md | wc -l
    grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md
    awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md | grep -c 'NIST'
    bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate \
      --root /home/vgpnk/Projects/shokunin kagi

**BASE (before):** 0 entries; 72 registry rows; 1 Frontier NIST line; census exit 0
(`entries_sourced=10 legacy=21 captures=101`).

**Target:** 2 entries; **82** registry rows (+10); **0** Frontier NIST lines; census exit 0 with
`entries_sourced=12` and `captures=111`; and `bash corpus/self-description-sweep.sh` keeps
`SD1=0 SD2=0` (the sweep's theme list does not include NIST, so its total stays n=2 with the same
two integrator-owned SD6 lines — the round does not claim n=0).

**Kill rule:** any of the four target readings unmet at the measured revision → C2 not admitted and
reported honestly; the entries are not trimmed to a narrower target after data.
**Do-nothing control:** a junk-row commit (ten rows appended, no entries, Frontier bullet kept) meets
the row count but fails the entry count, the `used-by`/`entries_sourced` handshake and the Frontier
reading; a no-parse replay of the staged rows fails the census (campaign rows carry escaped pipes and
prose recheck cells).

**Sourced claim:** C2 rests on the ten adopted rows, every source re-opened **this round** with my
own access date and a ≤25-word located quote; the round lesson's Gate records each admit and the one
refusal.

## Frontier step (`corpus/SOURCES.md` contract v1)

- **Census before:** `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
  → exit 0, rows = 72, `entries_sourced=10 legacy=21 captures=101` (receipt committed with this plan).
- **Census after:** exit 0, rows = 82, `entries_sourced=12`, `captures=111`. Every `status` /
  `recheck` / `used-by` change is logged old→new in the round lesson.
- **Mistake mined:** M33-1 — an unmeasured BASE expectation frozen as fact, and a plan target that
  counts an author-inaccessible file. Evidence: `corpus/lessons/round-32-verifier-spotcheck.md` §2
  C1 (n=1 residual), §6 R32-2; the BASE replay of the round-32 declared values reproduces it.
  Captured-by: **QM34** (landed this round, R32-2) for the pre-freeze class; the inaccessible-counter
  half is recorded with `captured-by: none` because no criterion covers it yet. Fix shown able to
  fail: `corpus/prefreeze-control.sh` on `plans/round-32.controls.tsv` at `32c35fe` → MISMATCH 2/2.
- **Sourced claim:** C2.
- **Considerthese:** `considerthese/` proposals are operator input, never edited; this round mines at
  most one still-unimplemented proposal. Selection and verdict land in the round lesson's Gate.
- **Assimilation:** yes — one theme, two entries, ten rows, per §10; the id-collision check, the
  scratch transform and the census gate all run before the first append, receipts under
  `.ufo/waves/round-33/assimilation/`.

## Routed items handled (not claims)

- **R32-1** — the wave carries no `planner` seat: the orchestrator ruling of 2026-10-19 (the validator
  refuses `planner`; `SWARM_ROLES` in `ufo-swarm-wave.mjs` holds the ten proposal roles) makes this
  the standing topology, and the L1 holds the canonical §3 planner seat. Recorded here at freeze as
  the deviation R32-1 permits.
- **R32-2** — QUALITY criterion **QM34** for the pre-freeze-control class with a red-before state
  (the round-32 plan's declared values against the delivered counter); the round-32 lesson's
  `captured-by` cells for M32-2/M32-3 are edited to `QM34` / `none`, logged old→new in the round-33
  lesson (§Migrations).
- **R32-3** — `S072`'s scope cell: the parenthetical that says the build the installed binary
  reports is narrowed to the version token `op --version` actually prints; old→new logged.
- **R32-4** — the stale capabilities-prose sentence is repaired in the round-33 SCORECARD section.
- **R32-5** — note only; no in-place corpus rewrite this round.

## Operator-owned (not lane work this round)

`R25-02`, `R29-01`, `R29-02` stay red / policy-blocked (gate-policy registration); the SD6 residual
lives in two integrator-owned verifier files this lane may not edit. Both are stated in the report;
route around, never treat as answered.

## Round shape

One v1 wave `kagi-r33-build` under `scripts/hyaku/ufo-wave-policy.json` (band 8–16): **13 seats** —
2 scout (source re-open/captures; lane data-walk), 3 executor (the gate + selftest, the round-32
replay, the capture/registry transform in scratch), 3 scribe (the two entries, the SOURCES append
block, the lesson/QUALITY/SCORECARD drafts), 1 connector (sibling-overlap scan), 2 reviewer,
1 critic, 1 mutation-tester. Attack seats 2+1+1 = 4/13 = **31 %** (≥25 %); connectors 1 (≤2);
no residual call; no `labrat` lane seat (nested probe only). Seats are leaves; no seat commits,
pushes, or touches a sibling repo or the fleet root.

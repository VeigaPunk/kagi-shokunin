# ScribeLesson — round 36 (kagi) — scoped findings

Verdict: **the round-36 lesson body is drafted and delivered.** Draft:
`.ufo/waves/round-36/build/ScribeLesson/round-36.md`; full seat report with
every command, rc and limitation: `.ufo/waves/round-36/build/ScribeLesson/report.md`;
raw outputs: `.ufo/waves/round-36/build/ScribeLesson/receipts/`.

## Numbers (measured by this seat)

| reading | command | value | rc |
|---|---|---|---|
| BASE C1 | `git archive 09f27e2` → scratch; `bash plans/round-36-c1.sh` | `4` | 0 |
| BASE C2 | same; `bash plans/round-36-c2.sh` | `15` | 0 |
| BASE sweep | same; `bash corpus/self-description-sweep.sh` | `n=6 (SD5=3 SD6=3 …)`, 3 `MISMATCH SD5 SCORECARD.md:14 … (SCORECARD.md:1374)` | 1 |
| BASE self-counts | same; `python3 corpus/self-counts.py` | `STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70`; `SELF_COUNTS: POLICY (claims=63 stale=1 … policy=2 setup=0)` | 2 |
| candidate C1 (F1–F4 only) | scratch tree; `bash plans/round-36-c1.sh` | `0` | 0 |
| candidate C2 (F1–F4 only) | scratch tree; `bash plans/round-36-c2.sh` | `0` | 0 |
| candidate C1 **with** the L1's three new ledger rows and the three count declarations still at 79 | scratch tree; `bash plans/round-36-c1.sh` | `3` (stale 3: `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64` claimed 79 vs live 82) | 0 |
| candidate C1 after those three declarations are re-bound to 82 | scratch tree; `bash plans/round-36-c1.sh` | `0` | 0 |
| release-clock gate | live lane worktree; `python3 corpus/release-clock.py` | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` | 0 |
| live census selftest | `bash corpus/sources-census.sh --selftest` | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` | 0 |
| live lane sweep | worktree; `bash corpus/self-description-sweep.sh` | `n=5 (SD5=0 SD6=5 …)` | 1 |
| round-34 close sweep | `git archive aa43fdb` → scratch | `n=3 (SD5=0 SD6=3 …)` | 1 |

## Findings (3 mistakes drafted)

- **M36-1** — `SCORECARD.md:14` names `R25-02,R29-01,R29-02`; the round-35
  calibration row (`SCORECARD.md:1374` at BASE, the last `## Round` section)
  names none, so SD5 reads 3. Repaired at round 32 (`SCORECARD.md:1314`) and
  held at rounds 33 (`:1342`) and 34 (`:1357`); round 35's fresh row re-opened
  it, because the sweep reads only the last section. captured-by: `none`.
- **M36-2** — `SCORECARD.md:701` said 59 cases against a live 70. The copy was
  last written at round 23 (`7af07b4`); the census grew to 70 at round 24
  (`a3eb6c7`) and the copy stayed at 59 for twelve rounds. The cell sat outside
  every self-count check for fifteen rounds (21–35). captured-by: `QM21`.
- **M36-3** — an earlier attempt edited the frozen counters after the freeze
  commit `cb8cb65`: commit `404a7b94b09af4df692e6d5b04f59b143531462c` (only
  `refs/jj/keep/404a7b9…`, **not** an ancestor of `master`) added
  `root=${LANE_ROOT:-…}` to `plans/round-36-c1.sh:12` / `-c2.sh:12`. The
  committed bytes are identical at `cb8cb65` and `09f27e2` and were re-proved by
  re-execution (4 / 15). captured-by: `QM29`.

## Two items the L1 must decide (marked **unknown** in the draft)

1. **The S034/S035/S040/S041 registry touch did not land.** The plan's
   §Frontier step names those rows for a `recheck`/`used-by`/observation touch,
   but the `recheck` cells hold cadences (`90d`, `on-release`), not dates; the
   only dated cell is `opened`. An in-round edit wrote 2026-11-04 into `opened`
   (wrong column) and the census accepted it (exit 0 — both columns accept ISO
   dates); the edit was reverted (`git diff corpus/SOURCES.md` empty; file
   sha256 `b974504e40f250aa2402c9c08fddb54c546f1144a2f5e0b1910283c48629ef72` =
   the `HEAD` blob). The draft records each row's `opened` and `recheck` cells
   old→new as unchanged and marks the intended re-dating unknown.
2. **SD6 is layout-sensitive.** `git archive` extraction reads SD6 = 3; the live
   lane reads SD6 = 5 (two extra lines are the round-34/round-35 verifier
   spot-check files' absolute `/home/vgpnk/…/corpus/SOURCES.md` citations).
   The frozen C1 kill rule names 5 — the live-lane reading. Recorded as a
   limitation, not re-scored.

## Scope

No lane production file was created, edited, moved or deleted; git was read-only
(`status`/`log`/`show`/`diff`/`merge-base`/`for-each-ref`/`rev-parse`/
`ls-files`/`archive`; no commit, push, checkout, switch, reset, stash, clean).
`## Gate` is left as `TODO: filled from the fetch receipts` for the L1 to paste
the located quotes — this seat opened no URL and quotes no vendor text; the
S034/S035/S040/S041 anchor-staleness line in Boundaries is attributed to the
ScribeGate receipts this seat read. No tool installed or upgraded; no pacman
transaction (pacman guard host-wide paused). Scratch
`/fast/scratch/hyaku/kagi-r36/ScribeLesson/` removed after the receipts were
copied into the build dir.

## Dead ends / unrun

- `bash corpus/claim-ledger.sh verify` in the live lane worktree exceeded the
  300 s tool cap and was killed mid-run; its partial tail shows the inherited
  reds but **no complete final line** — no verify verdict is claimed here.
- Live-lane BASE `self-counts` was not separately executed; the BASE reading
  cited is from the `09f27e2` extraction.
- The census-accepted wrong-column edit was not re-run by this seat against the
  edited bytes; that statement is the L1's report, cited as such.
- Several long sweeps/counters exceeded 300 s and were backgrounded by the
  tool (`bg_31659`, `bg_31732`, `bg_32284`, `bg_32533`, `bg_32826`, `bg_33075`,
  `bg_33126`); their outputs were read when delivered, never polled.

## sha256

- `round-36.md` (lesson draft) `ba84be011e8dc8eb18134c340be0dc32097fdaac0fd463afcfb30f787034259c`
- `report.md` — authoritative hash in the manifest below (self-referential file)
  (full list incl. receipts: `.ufo/waves/round-36/build/ScribeLesson/receipts/sha256.txt`)
- frozen plan `plans/round-36.md` `3ddc2da27ae91b8b22123340e1201ae63186ff54dc56ea928719fda05b4b7a5e`
- frozen counter `plans/round-36-c1.sh` `206cbcc53c31fad848fa8312ce0a7625a718a8211b2d4d6384021f4a0dbd086d`
- frozen counter `plans/round-36-c2.sh` `ac010f163c03313ef97251c1cce7aacfb7d01f99d65fdad313bbd8e4284c01c6`
- committed receipt `observe-live.json` `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`
- discarded LANE_ROOT c1 variant `bfa1ec8d04c8757dc391be02167ffb4066a3ebf9fe2920c938e59298f53575c2`
- discarded LANE_ROOT c2 variant `a11034c3d5d3f544d4923d6a42fbbd4e6d168a344e86f7c88aa164d8117e7bde`

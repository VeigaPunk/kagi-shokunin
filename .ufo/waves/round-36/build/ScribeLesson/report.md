# ScribeLesson — round 36 (kagi) lesson-body draft

Seat: ScribeLesson (leaf). Lane repo **read-only** to this seat; no lane file
was created, edited, moved or deleted. Deliverables are new files only, under
`.ufo/waves/round-36/build/ScribeLesson/`. Git was read-only throughout
(`git -C <abs>` with `status`/`log`/`show`/`diff`/`merge-base`/`for-each-ref`/
`rev-parse`/`ls-files`/`archive`); no commit, push, checkout, switch, reset,
stash or clean. Scratch `/fast/scratch/hyaku/kagi-r36/ScribeLesson/` was
removed after the receipts below were copied into this directory.

## Verdict

The round-36 lesson body is drafted and delivered in
`.ufo/waves/round-36/build/ScribeLesson/round-36.md`, in the shape of
`corpus/lessons/round-35.md` (heading block with the frozen BASE and plan
commits, then the round's sections), with the five required sections:
`## Claims`, `## Mistakes` (M36-1…M36-3), `## Migrations`, `## Gate`
(`TODO: filled from the fetch receipts`), `## Next`. Every number, path,
commit and cell value in the draft was measured or read by this seat; the two
places where the truth was not determinable are marked **unknown** in the
draft itself.

## Numbers measured by this seat

| measurement | command | result | rc |
|---|---|---|---|
| BASE C1 | `git archive 09f27e2` → scratch; `bash plans/round-36-c1.sh` | `4` | 0 |
| BASE C2 | same extraction; `bash plans/round-36-c2.sh` | `15` | 0 |
| BASE sweep | same extraction; `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)` + 3 `MISMATCH SD5 SCORECARD.md:14 … (SCORECARD.md:1374)` lines | 1 |
| BASE self-counts | same extraction; `python3 corpus/self-counts.py` | `STALE SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=59 live=70`; `SELF_COUNTS: POLICY (claims=63 stale=1 unlocated=0 ambiguous=0 policy=2 setup=0)` | 2 |
| candidate C1 (F1–F4 only, no ledger rows) | scratch tree = `git archive 09f27e2` + the three L1 files; `bash plans/round-36-c1.sh` | `0` | 0 |
| candidate C2 (same tree) | `bash plans/round-36-c2.sh` | `0` | 0 |
| candidate self-counts (same tree) | `python3 corpus/self-counts.py` | `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`; `OK SA-CAP-CENSUS-SELFTEST SCORECARD.md:701 claimed=70 live=70` | 2 |
| candidate + the L1's three ledger rows (79→82) | scratch tree with `corpus/claim-ledger.tsv` as the L1 left it | `STALE SC-SKILL-CLAIMS SKILL.md:46 claimed=79 live=82`, `PV-CLAIMS PROVINCE.md:73`, `RD-LEDGER-ROWS corpus/README.md:64` — 3 stale, `SELF_COUNTS: POLICY (claims=63 stale=3 …)` | 2 |
| release-clock gate, live lane worktree | `python3 corpus/release-clock.py` | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` | 0 |
| live census selftest | `bash corpus/sources-census.sh --selftest` | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` | 0 |
| live lane C1 / C2 (worktree, uncommitted) | `bash plans/round-36-c1.sh` / `bash plans/round-36-c2.sh` | `0` / `0` | 0 / 0 |
| live lane sweep (worktree) | `bash corpus/self-description-sweep.sh` | `SELF_DESCRIPTION: MISMATCH n=5 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=5 SD7=0 SD8=0 SD9=0)` | 1 |
| round-34 close sweep | `git archive aa43fdb` → scratch; sweep | `n=3 (… SD5=0 SD6=3 …)` — the round-34 row still named the reds | 1 |
| census count at round-24 | `git archive a3eb6c7` → scratch; `bash corpus/sources-census.sh --selftest` | `PASS (70 cases)` — the census grew to 70 at round 24 while the SCORECARD copy stayed at 59 | 0 |

### The decisive contrast

The L1's three ledger rows (`R36-01`, `R36-02`, `R36-03`) raise the live claim
count 79 → 82, which invalidates the three count declarations that the append
itself made stale (`SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64`).
Measured: with the ledger rows but the three declarations still at 79, the
self-counts reading is `stale=3` and the C1 counter reads **3, not 0**; with the
declarations re-bound to 82 (as the L1's worktree now has them) the reading is
`stale=0` and C1 reads **0**. The lesson's Migrations table records the
re-binding as part of the same landing, because the append and the re-binding
are one migration.

## Findings

1. **M36-1 (self-declaration).** `SCORECARD.md:14` names `R25-02,R29-01,R29-02`;
   the round-35 calibration row (`SCORECARD.md:1374` at BASE, the last
   `## Round` section) names none, so SD5 reads 3. The class was repaired at
   round 32 (`SCORECARD.md:1314`, "red-id naming repaired") and held at rounds
   33 (`SCORECARD.md:1342`) and 34 (`SCORECARD.md:1357`; the round-34 close
   sweep reads SD5=0) — round 35's fresh row re-opened it, because the sweep
   reads only the *last* section.
2. **M36-2 (number-drift).** `SCORECARD.md:701` said 59 cases against a live 70.
   The copy was last written at round 23 (`7af07b4`, where the ledger also
   pinned 59); the census grew to 70 at round 24 (`a3eb6c7`) and the prose copy
   stayed at 59 for twelve rounds. The cell was introduced at round 21
   (`c41af82`, 40 cases) and sat outside every self-count check for fifteen
   rounds (21–35): `corpus/self-counts.tsv` (`82745e2`) bound SKILL.md,
   PROVINCE.md, corpus/README.md and later `corpus/knowledge/*.md`, never
   SCORECARD.md.
3. **M36-3 (frozen-instrument drift).** An earlier attempt edited the frozen
   counters after the freeze commit `cb8cb65`: commit
   `404a7b94b09af4df692e6d5b04f59b143531462c` (parent `cb8cb65`; reachable only
   as `refs/jj/keep/404a7b9…`, **not** an ancestor of `master`) changed the
   `root=` line of `plans/round-36-c1.sh:12` and `plans/round-36-c2.sh:12` to
   `root=${LANE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}`. Discarded bytes
   sha256 `bfa1ec8d04c8757dc391be02167ffb4066a3ebf9fe2920c938e59298f53575c2`
   (c1) and `a11034c3d5d3f544d4923d6a42fbbd4e6d168a344e86f7c88aa164d8117e7bde`
   (c2). The committed instrument bytes are byte-identical at `cb8cb65` and at
   `09f27e2` (`206cbcc53c31fad848fa8312ce0a7625a718a8211b2d4d6384021f4a0dbd086d`,
   `ac010f163c03313ef97251c1cce7aacfb7d01f99d65fdad313bbd8e4284c01c6`;
   `grep -c LANE_ROOT` = 0 in both), so the `LANE_ROOT="$BASE"` prefix in
   `plans/round-36.controls.tsv` is inert against the frozen scripts. The
   committed bytes were re-proved by re-execution (BASE `4` / `15`, rc0).
4. **SD6 is layout-sensitive.** A `git archive` extraction reads SD6 = 3; the
   live lane checkout reads SD6 = 5. The extra two lines are the round-34 and
   round-35 verifier spot-check files' absolute
   `/home/vgpnk/…/corpus/SOURCES.md` citations, classed as an unresolved
   sibling only when the lane root *is* the live lane path. The frozen C1 kill
   rule names SD6 = 5 (live-lane reading); it does not match an extraction
   reading of 3. Flagged in the draft's Boundaries section, not re-scored.
5. **The S034/S035/S040/S041 registry touch did not land.** The plan's
   §Frontier step names those four rows for a `recheck`/`used-by`/observation
   touch, but the `recheck` cells carry cadences (`90d`, `on-release`), not
   dates; the only dated cell is `opened`. An in-round edit wrote 2026-11-04
   into `opened` (the wrong column) and the census accepted it (exit 0, because
   both columns accept ISO dates); the edit was reverted —
   `git diff corpus/SOURCES.md` is empty and the file sha256
   `b974504e40f250aa2402c9c08fddb54c546f1144a2f5e0b1910283c48629ef72` equals the
   `HEAD` blob. The draft records the four rows' `opened` and `recheck` cells
   old→new (unchanged) and marks the intended re-dating **unknown** — the
   decision is the L1's.
6. **Gate is a TODO by design.** `## Gate` carries
   `TODO: filled from the fetch receipts` and names where the located quotes
   live (`.ufo/waves/round-36/build/ScribeGate/`), so the L1 pastes them. This
   seat opened no URL and quotes no vendor text. The S034/S035/S040/S041
   anchor-staleness statement in Boundaries is attributed to the ScribeGate
   receipts this seat read, not to a fetch of its own.

## Out of scope / not done by this seat

- No lane production file written (`SCORECARD.md`, `LOG.md`, `SKILL.md`,
  `PROVINCE.md`, `corpus/*`, `plans/*` are untouched).
- The `## Gate` quote block is intentionally not filled — it is the L1's paste
  from the fetch receipts.
- No source was re-opened over the network; no credential, vault, account,
  handler or private reference was read or touched.
- No tool was installed or upgraded; no pacman transaction (the pacman guard is
  host-wide paused). `curl`, `git`, `python3`, `sha256sum` and the lane's own
  committed scripts were sufficient.

## Dead ends and limitations

- The first BASE extraction job (`bg_31659`) was backgrounded by the tool
  because it exceeded 300 s (the sweep's citation gate is slow); its result
  arrived and was used. Two later long sweeps (`bg_31732`, `bg_32826`,
  `bg_32533`, `bg_32284`) were likewise backgrounded and delivered their output
  asynchronously — no polling was done.
- `bash corpus/claim-ledger.sh verify` in the live lane worktree exceeds the
  300 s tool cap and was killed mid-run (`bg_32455`); its partial tail shows
  the pre-existing inherited reds (`R25-02` FAIL, `R29-01`/`R29-02` POLICY,
  `R11-08`/`R21-04`/`R22-03`/`R24-06`/`R24-14`/`R24-15`/`R25-04` FAIL,
  `R13-01` FAIL, host-skips) but **no complete final line was captured**, so
  this seat makes no claim about the full verify verdict.
- BASE `self-counts` was captured only from an extraction of `09f27e2`; the
  live-lane BASE equivalent was not separately executed.
- The `SOURCES.md` wrong-column edit was observed only in its *reverted* state
  in the worktree and in the L1's own round-36 lesson draft text; this seat
  did not run the census against the edited bytes, so the "census accepted it
  (exit 0)" statement is the L1's report, cited as such in the draft.

## Artifacts

- `.ufo/waves/round-36/build/ScribeLesson/round-36.md` — the lesson-body draft
  (the L1's paste source).
- `.ufo/waves/round-36/build/ScribeLesson/report.md` — this report.
- `.ufo/waves/round-36/build/ScribeLesson/receipts/` — raw outputs of the
  measurements listed above, copied out of scratch before the scratch was
  removed.

### sha256

| file | sha256 |
|---|---|
| `.ufo/waves/round-36/build/ScribeLesson/round-36.md` | `ba84be011e8dc8eb18134c340be0dc32097fdaac0fd463afcfb30f787034259c` |
| `.ufo/waves/round-36/build/ScribeLesson/report.md` | self-referential — the authoritative hash is in `receipts/sha256.txt`, written after this file's final edit |
| `plans/round-36.md` (frozen plan) | `3ddc2da27ae91b8b22123340e1201ae63186ff54dc56ea928719fda05b4b7a5e` |
| `plans/round-36-c1.sh` (frozen counter) | `206cbcc53c31fad848fa8312ce0a7625a718a8211b2d4d6384021f4a0dbd086d` |
| `plans/round-36-c2.sh` (frozen counter) | `ac010f163c03313ef97251c1cce7aacfb7d01f99d65fdad313bbd8e4284c01c6` |
| `.ufo/waves/round-36/controls/observe-live.json` (committed receipt) | `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727` |
| `corpus/self-counts.tsv` (working tree) | `77ad6e22e92b64c3610c3464ca6d2e131f3caa906de594f5cdcd5449f76b0bec` |
| discarded LANE_ROOT c1 variant | `bfa1ec8d04c8757dc391be02167ffb4066a3ebf9fe2920c938e59298f53575c2` |
| discarded LANE_ROOT c2 variant | `a11034c3d5d3f544d4923d6a42fbbd4e6d168a344e86f7c88aa164d8117e7bde` |

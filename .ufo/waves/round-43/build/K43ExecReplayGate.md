# K43ExecReplayGate — C2 freshness gate (`corpus/controls-replay.sh`)

Axes (godspeed): calibration / freshness / operability — this seat works **freshness**.
Parallel moves: gate implementation + counter proof + both mutant gates, all through the
frozen `plans/round-43-c2.sh` via `CONTROLS_REPLAY_GATE`. No move that improved one
function broke another: usage exit 2 and restore keep the clean exit 0; step (e) kept
the stale/silent refusal behaviour.

## Gate

`corpus/controls-replay.sh` (bash, `set -u`; invoked ONLY as
`bash <path> --clone <dir>`, any other invocation prints usage to stderr and exits 2).
Per frozen plan §C2: (a) requires `<dir>/plans/round-42-controls.sh` and
`<dir>/plans/round-41-controls.sh`; (b) snapshots every file under both controls dirs;
(c) deletes every file under both dirs; (d) runs both runners, each must exit 0;
(e) all 8 manifest files must exist again and `cmp`-match the snapshot;
(f) restores the snapshot (verification is non-destructive, incl. dropping files the
runners left behind that were not in the snapshot); (g) exits 0 clean / 1 refused / 2 setup.
Scratch root `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r43/controls-replay.<pid>`,
trap-cleaned; writes nothing outside `<dir>` and scratch; bash + coreutils only.
The gate is clone-agnostic (no special-casing of the counter's three invocation shapes).

## Proof through the frozen counter (`plans/round-43-c2.sh`, override)

| run | gate | result | expected |
|---|---|---|---|
| 3a run 1 | real gate | **1** | 1 |
| 3a run 2 | real gate | **1** | 1 (determinism: same value) |
| 3b mutant A (step (e) removed) | no-comparison | **0** | 0 (N1 stale fixture catches it) |
| 3c mutant B (`exit 1`) | blanket-refuse | **0** | 0 (P1 fails) |

Usage: `bash corpus/controls-replay.sh` → usage on stderr, rc 2.
Restore: `git status` shows only `?? corpus/controls-replay.sh`;
`git diff --quiet HEAD -- .ufo/waves/round-42/controls .ufo/waves/round-41/controls` rc 0;
sample receipts re-derived: `round-42/controls/c2-derivation-D.txt` = 1,
`round-41/controls/c2-base-19025d9.txt` = 1.

## Deliverables (under `.ufo/waves/round-43/build/K43ExecReplayGate/`)

- `controls-replay.sh` (144 lines, executable)
- `gate.diff` — `git diff HEAD` for the new file (intent-to-add; the file is untracked at
  the predeclaration commit, so the diff is the full file)
- `gate-sha256.txt` — sha256 of the gate bytes
- `receipts.txt` — exact commands, outputs, rc values, and last lines the check depends on

SHA256 (gate bytes, sandbox path): see `gate-sha256.txt` in the deliverable dir.

## Tooling (operator rule, 2026-10-19; pacman guard 2026-10-20)

No installs this seat (bash + git + coreutils already present). Host-heavy lane
claim-ledger verify / self-counts NOT run (per seat rules). Lane tree untouched
(every write went to scratch or the deliverable dir). Scratch deleted on exit.

## Risks / blockers

- Gate relies on the runners being re-runnable in a clone without network; the frozen
  runners use `git archive`/`git show` against the clone's own object store, which the
  `git clone --shared` in the counter guarantees.
- `find -type f -delete` + snapshot-copy preserves file set; directories themselves are
  not snapshotted (runners do `mkdir -p`), so an empty-dir difference would not be
  detected — named, not a silent gap; the counter pins the manifest set only.

SEAT-STATUS: complete

Report: .ufo/waves/round-43/build/K43ExecReplayGate.md

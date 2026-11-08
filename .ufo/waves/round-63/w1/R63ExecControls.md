# R63ExecControls — round-63-controls.sh (pre-freeze control battery)

Seat: R63ExecControls (executor, operability). Lane: kagi-shokunin, claim BASE
`0c07aab8`, frozen plan `plans/round-63.md` @ `12c9e428` (+ Amendments A1–A3 that
landed during the wave: A2 drops C2 leg L5 → population 5, target killed=5;
A3 adds C1 guard leg (f) `chal=`).

## Files changed

- `plans/round-63-controls.sh` — NEW, 590 lines, sha256
  `cb8134ad1ce486d9e5fe6f4397bf3af4ae8fa034c15e565cc1439e90d4b2cb87`.
  The only lane path this seat owns.
- `.ufo/waves/round-63/build/R63ExecControls/controls.md` — receipt (every
  command + output).
- `.ufo/waves/round-63/build/R63ExecControls/base-run.txt` — the extracted-BASE
  battery run.

## Behavior

`bash plans/round-63-controls.sh [TREE]` (default: lane tree) emits
`CONTROL <id> expect=<…> observed=<…> verdict=match|mismatch|skip` per control,
`CONTROLS: match=N mismatch=M`, exit 0 iff mismatch=0 / 1 on mismatch / 2 SETUP.
`--selftest` is fixture-driven (stub counters + stub trees under scratch, no
lane instruments, no bao): `CONTROLS_SELFTEST: PASS (cases=25)`, failing cases
print `FINDING R63C-CTL-ST-<case>`.

Controls: `C1-F8`/`C2-F6` (printer-stub / constant-verdict copies of the round-63
counters must read `mismatch` vs the frozen BASE census), `C1-NOWORK`/`C2-NOWORK`
(unmutated counters must reproduce `accepted=10 rejected=6 population=10/6` and
`killed=0 population=5`), `C1-REAL`/`C2-REAL` (positive controls: verdict line
with `guard=1`), `PRIOR-<id>` (delegates to `<tree>/plans/round-62-controls.sh`
on a private snapshot, re-emits all 14 `CONTROL` rows plus `DETAIL` rows with
verdicts preserved).

Design points worth noting:

- **Instrument resolution**: the measured tree's own counter copy when present,
  else the lane's (`$REPO`) copy — so `bash plans/round-63-controls.sh
  <extracted-BASE-tree>` exercises the lane's committed counters against BASE
  bytes, which is exactly the acceptance invocation.
- **Single probe**: each unmutated counter runs once (`probe_counters`); parsed
  fields live in `U1_*`/`U2_*` so the stub controls' `R1_*`/`R2_*` parses cannot
  clobber NOWORK/REAL readings (bug found and fixed via selftest).
- **Stub construction**: byte copy + shebang dispatch printing the frozen stub
  line — a printer-stub *copy* per the frozen control text, not a hand-written
  line.
- Selftest copies the battery into each fixture tree so `REPO` resolves inside
  the fixture — fully deterministic regardless of lane state.

## Evidence

- `bash -n` clean; `--selftest` → `CONTROLS_SELFTEST: PASS (cases=25)` rc 0
  (verified from a foreign cwd too).
- Fixture-tree run (stub counters at BASE census + real round-62 battery):
  `C1-F8`/`C2-F6` `verdict=mismatch`, NOWORK×2/REAL×2 `verdict=match`, 14
  `PRIOR-*` rows re-emitted, `CONTROLS: match=4 mismatch=2`, rc 1.
- Extracted-BASE run (`git archive 0c07aab8`): all six round-63 controls
  `verdict=skip` (instruments absent at BASE — expected), PRIOR delegation
  emitted all 14 rows (`match=5 mismatch=7` — the round-62 battery's own
  candidate-side controls mismatch on BASE bytes, faithfully re-emitted).
  Full output in `base-run.txt`.

## Risks / notes for the L1

- **Acceptance-tree caveat**: on a *bare* `0c07aab8` extraction the round-63
  controls skip (counters don't exist there). The acceptance pattern (F8/F6
  `mismatch` + NOWORK `match`) requires the tree to carry
  `plans/round-63-c1.sh`/`round-63-c2.sh` — i.e. the post-instrument-landing
  tree, or any tree via the `$REPO` fallback when run from the lane. If the L1
  reads the acceptance literally on a bare BASE extraction, the NOWORK controls
  will read `skip`, not `match` — flagging rather than amending the frozen
  expectation.
- **PRIOR cost**: the delegation runs the full round-62 battery including its
  real bao trial legs (~7–19 min under sibling-seat load). The `timeout 2400`
  inside `ctrl_prior` covers it; the L1's gate should budget accordingly.
- **Observed flake (not mine)**: the round-62 battery's `C2-F4` real-trial leg
  read `value=5 shims=5 vectors=ok/5` (match) in one run and `value=0` (mismatch)
  in another on identical BASE bytes — likely bao contention with sibling seats.
  My battery re-emits whatever the prior battery prints; no masking.
- No tool installs were needed (bash/python3/git only). No pacman transactions.

SEAT-STATUS: complete

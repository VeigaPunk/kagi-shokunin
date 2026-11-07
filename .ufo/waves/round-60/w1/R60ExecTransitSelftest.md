# R60ExecTransitSelftest — scoped findings (kagi round 60, wave w1)

Seat: R60ExecTransitSelftest (leaf executor). Item: plans/round-60.md §C1 I7 — give
`corpus/openbao-transit-trial.sh` a real `--selftest` and re-register the SKILL.md gate
row (spot-check D7). BASE a677c78e.

## Files changed

- `corpus/openbao-transit-trial.sh`
  - `--selftest` mode: 9 fixture-driven cases over an isolated stub-`bao` harness (no
    OpenBao binary, no HTTP; loopback listener only for the trial's `ss` readiness
    probe). Each case asserts the trial subprocess's exit code and output shape;
    failures print `FINDING TRANSIT-ST-<ID>`; pass prints
    `TRANSIT_SELFTEST: PASS (cases=9)` and exits 0.
  - Shim selector: unknown non-empty `KAGI_TRANSIT_SHIM` is now `SETUP` rc 2 before any
    tool check; SH1..SH5 mapping unchanged; the `SHIM="${KAGI_TRANSIT_SHIM:-}"` anchor
    line is preserved verbatim for `plans/round-58-controls-supplement.sh`.
  - Selftest work-root default is seat-agnostic
    (`$HYAKU_SCRATCH/kagi-transit-trial/selftest-work`, mktemp-unique per run) — see
    Incident below.
- `SKILL.md` — round-59 gate-registry transit row, `selftest` cell only: names
  `bash corpus/openbao-transit-trial.sh --selftest`; other cells and table shape intact.

## Incident (fixed before yield)

First draft used a seat-named default work root; R60ReviewerC1's in-flight `--selftest`
runs (no `--work`) wrote fixtures into my seat scratch, which I deleted at cleanup —
their runs fail-closed with spurious findings (never a silent pass). Fixed: default root
is now seat-agnostic; peer notified. Receipts were regenerated on the final bytes.

## Behavior delivered (all exercised, receipts below)

- `bash corpus/openbao-transit-trial.sh --selftest` → `TRANSIT_SELFTEST: PASS (cases=9)`,
  rc 0. Covers: shim selector (SH1..SH5 each flip exactly their own test → exit 1 with
  `BROKEN holds=4 broken=1 error=0`; unknown value → SETUP rc 2), verdict/exit mapping
  (holds=5 → 0, one broken → 1, ERROR → 2), no-bao PATH leg (rc 2, `SETUP no bao on
  PATH`, no HOLDS line). 9 ≥ 6.
- Fail-power: scratch copy with the verdict mapping broken (BROKEN branch rc=1→0) →
  exit 1 with `FINDING TRANSIT-ST-SHIM-SH1..SH5` (receipt `selftest-mutant.txt`,
  regenerated on final bytes).
- Real trial re-run after the edit: T1–T5 + CLEANROOM all HOLDS,
  `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc 0; bao sha256
  matches the pinned 2.7.2 (`9c5f36287c…41b788`) — receipt `trial-still-holds.txt`.

## Evidence (all under .ufo/waves/round-60/build/R60ExecTransitSelftest/)

- `selftest.txt` — clean `--selftest` run on final bytes: PASS (cases=9), rc=0.
- `selftest-mutant.txt` — mutation diff + mutant `--selftest` run on final bytes:
  FAIL, rc=1, five named findings.
- `trial-still-holds.txt` — real trial run post-edit: HOLDS 5/5 + cleanroom, rc=0,
  bao version + sha256 header.
- `notes.md` — design, incident, compatibility, secrets, risks.

## Checks the integrator should run

- `bash plans/round-60-c1.sh` (or the c1-checker with `--root <tree>`) — I7 should read
  resolved once this lands (selftest PASS + SKILL.md row carries `--selftest` and no
  `none — its own five shims`).
- Re-run `bash corpus/openbao-transit-trial.sh` once more at integration if desired
  (already re-run post-edit: HOLDS 5/5, receipt above).
- `plans/round-58-controls-supplement.sh` / `plans/round-59-controls.sh` legs that wrap
  the trial still see the same main-flow contract (verified by reading; the anchor line
  is unchanged and the no-bao leg is byte-identical).

## Risks / blockers

- None blocking. Known ceiling (documented in notes.md): the stub is a CLI-level test
  double for the trial's own surface; a future trial CLI addition fails closed with a
  named finding. Selftest requires python3 and loopback `bind()` only; missing
  python3/timeout/ss/setpriv/pgrep/bash yields `TRANSIT_SELFTEST: SETUP <reason>` rc 2.
- Tool installs: none (all prerequisites pre-existing; pacman guard respected).

SEAT-STATUS: complete

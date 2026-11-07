# R60ExecControls — pre-freeze control battery run notes

Seat: executor (controls battery), kagi round 60 wave 1. Scope held:
`plans/round-60-controls.sh`, this build receipt (`battery.txt`, `notes.md`), and
`.ufo/waves/round-60/w1/R60ExecControls.md`. No lane commit; no git/jj mutation
anywhere; no writes outside scope; nothing installed or updated (no pacman, no
uv, no npm — the tooling authorization went unused).

## Final receipt (this directory, `battery.txt`)

- `bash plans/round-60-controls.sh` over the lane working tree, run
  2026-11-07 ~16:1x–16:5x local.
- **`CONTROLS: match=20 mismatch=0`, battery exit rc=0** (0 iff mismatch=0).
- `CONTROLS-NORESULT: count=0` — every declared control ran.
- No `INSTRUMENT-DRIFT` lines: the five pinned instrument hashes at battery
  start equal the on-disk bytes at battery end.

## Controls run (all 20, none NORESULT)

| control | expect | observed | note |
|---|---|---|---|
| K1-BASE | 7 | 7 | checker diagnostic on a BASE copy (git archive, read-only) |
| K2-BASE | 0 | 0 | counter on a BASE copy: trial absent, no server work |
| K1-REF | 0 guard=1 | 0 guard=1 | synthetic fixed tree (all seven fixes, numbers derived from the copy's own receipts); guard challenge fires |
| K2-REF | 5 | 5 | tree carrying the trial through the full counter (real dev servers) |
| C1-F1..F5 | 1 | 1 | one item's substance broken per tree in a LAST satisfied-looking statement |
| C1-F6 | FAIL-with-id | FAIL-with-id | verdict-mapping mutation (`_st_want BASELINE "TRIAL T1 HOLDS"` → BROKEN): rc=1, `FINDING TRANSIT-ST-BASELINE` |
| C1-F7 | stub-fails-challenge | stub-fails-challenge | fixed=0, challenge copy (I1 `dead=` 0→1)=1, constant-0/guard-1 stub=0 |
| C1-F8 | 1 | 1 | correction block before the `__DEAD__` line it corrects does not resolve |
| C2-F1 | <5 | <5 | SH5 shim dropped by wrapper: vector cannot flip exactly T5 |
| C2-F2 | SETUP/rc2 | SETUP/rc2 | no-bao PATH, no HOLDS line (K1) |
| C2-F3 | <5 | <5 | `--selftest` refused by wrapper |
| C2-F4 | <5 | <5 | single-run wrapper refuses the second empty-shim real run |
| C2-F5 | 0 | 0 | HOLDS lines without the summary line |
| C2-F6 | <5 | <5 | SH1 made to flip a second test |
| C2-F7 | SETUP/rc2 | SETUP/rc2 | foreign-sha bao via a fake `$HOME/.local/bin/bao` (counter pin check) |
| C2-F8 | 5 | 5 | ambient `BAO_*`/`VAULT_*` exported around the full counter |

NORESULT policy (for the L1's re-runs): a control whose required instrument is
not on disk prints `observed=NORESULT`, is scored neither matched nor
mismatched, and is listed on a `CONTROLS-NORESULT` line; if nothing can run the
battery exits 2 (SETUP). An earlier same-day run (against the half-landed wave)
printed 20/20 NORESULT and exited 2 by design; the receipt above supersedes it.

## Fixtures and derivations

- The fixed tree is synthetic (round-59 convention): BASE copy + correction
  text built by the battery, every number derived at run time from the copy's
  own files (`w1-results.json` census 14/0, selftest receipt 33 cases,
  controls receipt 20, `c1-landed.txt` measured revision) — never hardcoded.
- The I1 correction line carries `results=<R> dead=<D> dead seats=<D>`: the
  landed checker's I1 regex reads the first `dead…=` digit after `results=`,
  which is the token its frozen guard challenge mutates.
- The I5 fixture receipts end `RELEASE_CLOCK: …`, `DOC_AUDIT: …`,
  `ADJACENCY_SCOPE: …` (the scope gate's own verdict token), each with numeric
  `key=value` fields; fixture bytes live only in battery scratch and are
  removed on exit.
- Scratch: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecControls/battery.$$`,
  `trap rm -rf` on exit; `TMPDIR` pointed there; no `/tmp` anywhere.

## Instrument alignment history (same wave, recorded for the L1)

The sibling instruments were landing while this battery was being written and
first run; the battery re-pins hashes at every start and now prints
`INSTRUMENT-DRIFT` lines when the pinned bytes change mid-run.

- 15:2x first run: 4 of 5 instruments MISSING → all controls NORESULT (exit 2).
- 15:39 run (checker `63ef4304…`): 18/20 matched; C1-F1 exposed the wrapped
  I3 sentence in my own fixture (M59-1 wrapped-bullet class), C1-F6 exposed my
  extraction bug (the finding id lives on the `FINDING` line, not the FAIL
  line); R60ReviewerC1 additionally caught C1-F7 flipping `dead seats=` where
  the checker reads `dead=`.
- Checker amended mid-wave (`63ef4304…` → `52d4fd5c…`): I5's scope receipt
  token became `ADJACENCY_SCOPE:` and I6's anchor became the single-line
  `supersedes the round-59 measured-commit citation` phrasing (the checker
  seat dropped the `75165a07` anchor, which was unsatisfiable at BASE — the
  same defect this seat had reported from the BASE tree). Fixtures aligned.
- 16:1x final run: 20/20 match, rc 0, no drift.

## Verification handed to the L1

Re-run `bash plans/round-60-controls.sh` after the instruments and records are
committed; expect `CONTROLS: match=20 mismatch=0`, no NORESULT lines, no
INSTRUMENT-DRIFT lines, exit 0. Wall cost of a full run is roughly 35–45
minutes (the C2 legs execute real `bao server -dev` trials through the full
counter; per-leg timeouts cap each counter call at 900 s and each checker call
at 300/600 s).

# R63ExecRouted — wave report

Seat: executor, axes calibration + freshness. Deliverable:
`plans/round-63-routed.sh` — the receipt for the round-62 verifier spot-check's
three routed defects (D-A report counts, D-B missing gate receipts, D-C
undercounted case enumeration). Plus receipts under
`.ufo/waves/round-63/build/R63ExecRouted/routed.md`.

## What was written

`plans/round-63-routed.sh` (200 lines, bash + embedded python3, same shape as
`plans/round-62-routed.sh`). Three legs, each able to fail:

- `da` — re-derives `1454→1710` (`plans/round-61-c1-check.py`) and `389→478`
  (`plans/round-61-c2.sh`) from committed bytes via `git show <rev>:<path>`;
  requires the round-63 lesson's correction line to carry all four measured
  values and the `git show … | wc -l` command; a line restating the report's
  `1822`/`520` figures reads `da=0`.
- `db` — requires `.ufo/waves/round-63/final/{c1-residual,c2-refusal,controls,
  release-clock,doc-audit,claims-declared}.txt` to exist, each carry its label
  line (`C1_RESIDUAL:` … `CLAIMS_DECLARED:`), and `LOG.md` to cite each path.
- `dc` — parses `cases=N` / `N/N checks` on the lesson's selftest lines and
  requires the lesson's enumerated case list (list items with a case-like
  token) to reach the largest cited count; shorter reads `dc=0`.

Output `ROUTED: da=<0|1> db=<0|1> dc=<0|1>`; exit 0 iff all three are 1, else 1;
2 on SETUP (bad tree/repo, missing python3/git).

## Evidence

- BASE (`966c469`, lesson and `final/` absent): `ROUTED: da=0 db=0 dc=0` rc 1.
- fixed-tree scratch (lesson correction + 6 receipts + LOG cites + 13-item case
  list vs `cases=10`): `ROUTED: da=1 db=1 dc=1` rc 0.
- `da-stale` (correction restates `1822`/`520`): `da=0` rc 1.
- `dc-short` (`cases=50` cited, 5 items enumerated): `dc=0` rc 1.
- `db-miss` (`controls.txt` absent): `db=0` rc 1.

Every command and output is in
`.ufo/waves/round-63/build/R63ExecRouted/routed.md`. Scratch
`/fast/scratch/hyaku/kagi-r63/R63ExecRouted/` deleted before yield. No tool
installs. `bash -n` clean.

## Risks / blockers

- `da` wants the four numbers and the command on ONE lesson line; if the scribe
  wraps the correction the leg reads `da=0` — keep it one line.
- `dc` counts list items carrying a case-like token; the lesson's enumeration
  must reach the max `cases=N` cited on a selftest line (fails closed at 0).
- `db` label match tolerates leading whitespace but the verdict token must open
  the line.
- The script is untracked; the L1 commits it (`plans/round-63-routed.sh` is the
  only lane file this seat touched, plus its own receipts).

Files changed: `plans/round-63-routed.sh` (new),
`.ufo/waves/round-63/build/R63ExecRouted/routed.md` (new), this report.

SEAT-STATUS: complete

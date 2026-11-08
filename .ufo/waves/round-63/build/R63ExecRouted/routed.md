# R63ExecRouted — routed-defect receipt (round-63, D-A / D-B / D-C)

Seat: R63ExecRouted (executor). Lane: kagi-shokunin @ `966c469155d7d6a506b61572d9a05192b28a0589`
(wave in flight; the L1 owns all commits). Deliverable: `plans/round-63-routed.sh`
(untracked at write time; the L1 commits it).

Defects receipted (from `corpus/lessons/round-62-verifier-spotcheck.md` §6):

- **D-A** — report counts that do not re-derive. Round-62 report said checker
  `1454 -> 1822` lines and counter `389 -> 520`; committed bytes read
  `1454 -> 1710` and `389 -> 478`. Leg `da` re-derives both pairs from committed
  bytes and requires the round-63 lesson's correction line to carry both measured
  values and the `git show … | wc -l` command; a line restating the report's
  figure reads `da=0`.
- **D-B** — four gate verdict lines with no committed receipt (the class recurs;
  round 63 names six). Leg `db` requires
  `.ufo/waves/round-63/final/{c1-residual,c2-refusal,controls,release-clock,doc-audit,claims-declared}.txt`
  each to exist, carry its label line, and be cited from `LOG.md`.
- **D-C** — undercounted case enumeration. Leg `dc` parses the `cases=N` /
  `N/N checks` figures the round-63 lesson cites on selftest lines and requires
  the lesson's enumerated case list (list items carrying a case-like token) to
  reach the largest cited count; a shorter list reads `dc=0`.

## BASE reading (working tree at `966c469`, before any fix lands)

```
$ bash plans/round-63-routed.sh
ROUTED: da=0 db=0 dc=0 (da:lesson=no missing_rev=[] db:receipts=0/6
  c1-residual.txt=miss c2-refusal.txt=miss controls.txt=miss
  release-clock.txt=miss doc-audit.txt=miss claims-declared.txt=miss
  dc:max_cases=0 enum_items=0)
rc=1
```

`corpus/lessons/round-63.md` does not exist yet (the scribe seats draft it) and
`.ufo/waves/round-63/final/` does not exist — all three legs correctly read 0.

## Re-derived counts (leg `da` inputs, measured this seat)

```
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 60b5b7b:plans/round-61-c1-check.py | wc -l
1454
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show c840739:plans/round-61-c1-check.py | wc -l
1710
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 60b5b7b:plans/round-61-c2.sh | wc -l
389
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show c840739:plans/round-61-c2.sh | wc -l
478
```

Matches the spot-check's re-measurement (`1454 -> 1710`, `389 -> 478`), not the
report's `1822`/`520`.

## Scratch trees and per-leg fail/pass readings

Scratch root: `/fast/scratch/hyaku/kagi-r63/R63ExecRouted/` (deleted before yield).
`--repo` always `/home/vgpnk/Projects/shokunin/kagi-shokunin` (the legs' `git
show` runs against the lane repo; `--tree` selects the file tree read).

### fixed-tree — all three legs pass (rc 0)

`fixed-tree/` carries a `corpus/lessons/round-63.md` whose D-A line names
1454/1710/389/478 with `git show … | wc -l`, a `cases=10` selftest citation and
13 enumerated case items; six receipts with label lines; LOG.md cites all six.

```
$ bash plans/round-63-routed.sh --tree $SCRATCH/fixed-tree --repo $REPO
ROUTED: da=1 db=1 dc=1 (da:c1=1454->1710 c2=389->478 lesson=yes missing_rev=[]
  db:receipts=6/6 …all ok… dc:max_cases=10 enum_items=13)
rc=0
```

### da-stale — leg `da` fails on a correction restating the report's figure (rc 1)

`da-stale/` is `fixed-tree` with the D-A line rewritten to `1454 -> 1822` /
`389 -> 520` (the report's wrong figures) — it names a command but not the
measured values.

```
$ bash plans/round-63-routed.sh --tree $SCRATCH/da-stale --repo $REPO
ROUTED: da=0 db=1 dc=1 (da:c1=1454->1710 c2=389->478 lesson=yes …
  dc:max_cases=2 enum_items=4)
rc=1
```

### dc-short — leg `dc` fails when the enumeration is shorter than the count (rc 1)

`dc-short/` cites `C1_CHECK_SELFTEST: PASS (cases=50)` but enumerates only 5
case items.

```
$ bash plans/round-63-routed.sh --tree $SCRATCH/dc-short --repo $REPO
ROUTED: da=1 db=1 dc=0 (… dc:max_cases=50 enum_items=5)
rc=1
```

### db-miss — leg `db` fails when one receipt is absent (rc 1)

`db-miss/` is `fixed-tree` minus `.ufo/waves/round-63/final/controls.txt`.

```
$ bash plans/round-63-routed.sh --tree $SCRATCH/db-miss --repo $REPO
ROUTED: da=1 db=0 dc=1 (… db:receipts=5/6 controls.txt=miss …)
rc=1
```

## Risks / notes for the L1

- `da` requires all four measured numbers AND a `git show`/`wc -l` command on a
  single lesson line that also mentions D-A / round-62 / correction / count. If
  the scribe splits the correction across lines the leg reads `da=0`; the fix is
  to keep the correction on one line (the spot-check's "correction line").
- `dc` counts list items (lines opening `- `/`* `/`N. `/`|`) that carry a
  case-like token (letter+digit or hyphenated id or `FINDING<n>`). The lesson's
  case list must reach the largest `cases=N`/`N/N checks` figure cited on a
  selftest line. Prose mentions of `cases=` on non-selftest lines do not set the
  floor.
- `db` label match is `lstrip().startswith(label)` — the receipt's verdict line
  must begin the line (leading whitespace tolerated).
- Leg `dc` fails closed when the lesson cites no selftest count at all
  (`max_cases=0` → `dc=0`): a lesson that names no `cases=N` cannot satisfy
  "name every case the counts claim".
- Tool installs: none (python3/git only).

SEAT-STATUS: complete

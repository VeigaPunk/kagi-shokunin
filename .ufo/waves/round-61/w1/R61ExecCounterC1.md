# R61ExecCounterC1 — C1 counter and checker for kagi round 61

Seat: executor, wave w1, kagi round 61. Claim BASE
`c940f51689d702f1786989d56ad4663833c1452e`; frozen predicate
`plans/round-61.md` §C1 (commit `8595018164f7421864254c6c5ca762b8f201e8be`).

## Files changed (all inside the lane, all named by my item)

- `plans/round-61-c1.sh` — thin driver (sha256 `e6c853236181d8a5bdec99e711da2376546a8bbfb2856be28a2e253710fa487f`)
- `plans/round-61-c1-check.py` — the seven-item checker with `--selftest`
  (sha256 `d525ee2870bc928042938ef1d04bf1fce6c2d603e17cccfc4c586563fcb89812`)
- `.ufo/waves/round-61/build/R61ExecCounterC1/` — receipts: `receipts.md`,
  `base-c1-driver.txt`, `base-census-nochallenge.txt`, `selftest.txt`,
  `challenge-resolved-good-tree.txt`, `challenge-only-i5-unresolved.txt`,
  `legc-needle-vs-working-counter.txt`

Nothing else written; no git/jj mutation anywhere in the lane (the only `git`
mutations are commits inside a scratch fixture repo whose toplevel is asserted
before each commit).

## Behavior

`plans/round-61-c1.sh [revision | --tree DIR]` materialises the measured tree
into `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecCounterC1/<tag>/tree`
(`git archive` for a revision, tar copy for `--tree`, VCS internals excluded,
copy target refused at/inside the measured tree) and runs
`plans/round-61-c1-check.py --root <tree> --repo <lane>` in guard-bearing mode.
Exit 0 iff guard=1 and value=0; 1 otherwise; 2 SETUP.

The checker evaluates the seven frozen items over POP=7, each derived at run
time: I1 (R37 supersession line with `results=<R> output=<B>` and `mutants.md`,
R/B from `w1-results.json`), I2 (`plans/round-60-c2.sh --selftest` rc 0 with
`C2_SELFTEST: PASS (cases=N)` N>=6; SKILL.md registry row carries `--selftest`
and no `none of its own`; a copy with the verdict mapping inverted exits
non-zero with named `FINDING C2-ST-*`), I3 (`## Amendment A7` after the §A6
block naming `A3 item 2`/`form`/`l1-probe.txt`/`withdrawn`, plus the lesson line
naming `M60-2`/`A3 item 2`/`second instance`), I4 (quality-trend correction
quoting `no new record defect`, naming D1/D2/D3, stating `three`), I5 (LOG
correction naming `818d2a82`/`14a6c07d` stating `insertions=<I> deletions=<D>`
and `rewritten in place`, I/D derived via `git diff --numstat 14a6c07d 818d2a82
-- LOG.md`), I6 (stale-lane correction naming the 15:03:17 launch line plus >=3
`-03:00` stamps each in `git log --format=%ci a677c78e..818d2a82`), I7
(attack-share correction stating the derived `A/16`, `B/16`, `18.75`, `25`).
The guard: on a copy whose only delta is the I5 `deletions=1` -> `deletions=2`
digit, the checker prints exactly value+1, and an always-0 printer stub fails
that challenge. `--no-challenge` prints the diagnostic count with guard=0;
`--json` emits one object; `--selftest` builds fixture trees (honouring
`TMPDIR`/`--work`) plus a fixture git repo with tags literally named
`a677c78e`/`14a6c07d`/`818d2a82` and proves every item reads 0 and 1, every
named forgery class fails closed, and both guard legs fire.

## Retained evidence (all under `.ufo/waves/round-61/build/R61ExecCounterC1/`)

- BASE driver reading: `C1_ROUTED: value=FAIL population=7 i1=0 i2=0 i3=0 i4=0
  i5=0 i6=0 i7=0 guard=0`, rc 1 (`base-c1-driver.txt`).
- K2 census, `--no-challenge` on the BASE tree: `C1_ROUTED: value=7
  population=7 i1=0 … i7=0 guard=0`, rc 1 (`base-census-nochallenge.txt`).
- Selftest: `C1_CHECK_SELFTEST: PASS (52 cases)`, rc 0 (`selftest.txt`).
- Guard challenge, resolved tree: `copy delta deletions 1->2 … value=1 expect=1;
  stub value=0 fails=True`, `value=0 … guard=1`, rc 0
  (`challenge-resolved-good-tree.txt`); with i5 alone resolved: `value=7
  expect=7; stub value=0 fails=True`, `value=6 … guard=1`, rc 1
  (`challenge-only-i5-unresolved.txt`).
- Leg-C needle against the D2 fix's working-tree bytes: needle occurs exactly
  once; mutated copy rc 1 with 8 `FINDING C2-ST-*` lines
  (`legc-needle-vs-working-counter.txt`; calibration receipt, the landed reading
  measures a committed revision).

## Instrument changes demanded by measurement (pre-landing)

L1 and R61MutCounters independently measured two I2-unreadable defects; both
fixed and re-receipted: `C2_PASS_RE` digit order (`(cases=N)`), and the registry
cell split now ignores escaped `\|` (real SKILL.md row 855 carries one in its
entry-command cell, which had shifted the selftest column onto the verdict-map
cell). Also fixed: fixture-repo dir not created before `git init` (selftest rc 1
at L1's 17:1x measurement), and two selftest case expectations corrected against
measured behavior (only-i3 resolved set; i2-absent premise).

## Risks

- The I2 leg-C needle is a vec-body fragment (`verdict "$1" "T$i" | cut -c1)"`,
  exactly-once) chosen to match the counter's own declared MUTVEC witness; if a
  later edit of `plans/round-60-c2.sh` reformats `vec()`, leg C fails closed
  (I2 unresolved) rather than false-passing — the fixer keeps `vec()` stable.
- Without `--repo`, I5/I6 fall back to shape-only readings and the guard cannot
  fire (`value=FAIL guard=0`); the driver always passes `--repo`, and this is
  recorded in the checker docstring and receipts.
- The working tree was being actively edited by siblings during capture; all
  receipts measure either the BASE archive or scratch fixtures, never the
  working tree (the one working-tree receipt is marked calibration-only).

## Blockers

None. Integration checks for the L1: `bash plans/round-61-c1.sh c940f516…` rc 1
with the FAIL line (BASE control), `bash plans/round-61-c1.sh --tree
<candidate>` expected `value=0 … guard=1` rc 0 once the seven fixes and the
`plans/round-60-c2.sh --selftest` land, and
`python3 -I -B plans/round-61-c1-check.py --selftest` rc 0.

SEAT-STATUS: complete

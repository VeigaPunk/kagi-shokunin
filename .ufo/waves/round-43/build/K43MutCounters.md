# K43MutCounters — seat report (round 43, kagi, attempt 1)

Task: mutation-test the three frozen round-43 counters before candidate scoring. Lane untouched;
all work in sandbox /fast/scratch/hyaku/kagi-r43/K43MutCounters (shared clone detached at
dd6ccb92bf04a061e9f1e66913d15f097397b1b3; `git rev-parse --show-toplevel` asserted = sandbox work
dir before every write; every git call named `-C` or ran with cwd inside the sandbox). Deliverable
file set only — the L1 copies, commits and measures.

## Result in one line

9 mutants run (plus 1 malformed variant recorded): **7 killed, 2 survivors (both C2: y1 N1-skip,
y2 N2-skip)**; every frozen kill rule reproduced its committed receipt, and the two survivors name
the exact missing C2 control (a targeted negative fixture gate per bad shape).

## C1 (calibration) — frozen exposures reproduce; my mutants killed

Baseline pristine new counter reproduced all six committed receipts (real 6, K1 0, K3 0, fakeC 5,
blanket 0/0). m3-new (guard-drop) is killed **only** by c1-new-K1 (6 vs pristine 0) and survives
real/K3/fakeC — exactly the frozen single-kill design (committed c1-new-m3-K1=6). m5-new
(token-drop) is killed **only** by c1-new-K3 (committed c1-new-m5-K3=6). Own mutants: x1
(`echo "$n"`→`echo 6`) survives the real gate and K1 (the guard exits before the final echo) but is
killed by c1-new-K3, c1-new-fakeC (6≠5) and c1-blanket-accept (6≠0); x2 (increment deleted
outright) is a malformed crash mutant (bash rejects the empty then-block, rc 2, no integer output)
— recorded, superseded by x2b (`n+1`→`n+0`), which prints 0 and is killed by c1-new-real (0≠6) and
c1-new-fakeC (0≠5). No C1 survivor.

## C2 (freshness) — two counter mutants survive the whole frozen battery

I wrote a correct §C2 gate (receipts/gates/c2gate.sh: snapshot the two controls dirs → delete →
run the clone's round-42/41 runners, each must exit 0 → the eight manifest receipts must exist and
byte-match → restore) and ran it against the pristine counter at CAND=dd6ccb9: **N=1** — the eight
frozen manifest receipts re-derive byte-identically through the clone's runners, independently
confirming the plan's C2 manifest claim; blankets read 0/0 as committed. Mutants: y3 (accept P1
rc∈{0,1}) is killed by c2-blanket-1 (prints 1 vs committed 0). **y1 (skip the N1 stale check) and
y2 (skip the N2 silent check) print 1 (=target) with the correct gate and reproduce c2-base=0,
c2-blanket-0=0, c2-blanket-1=0 — survivors.** Discriminating probes (not part of the frozen
battery): a stale-accepting gate (replay-verifies only round-42 blanket receipts) flips y1 to 1
while pristine reads 0; a silent-accepting gate (commit-compare without replay) flips y2 to 1 while
pristine reads 0. Coverage finding: blanket-1 refuses every invocation and therefore kills only a
P1-weakening; killing an N1/N2-skip needs one targeted negative fixture gate per bad shape. This is
a counter-battery coverage gap, adjacent to (not covered by) the plan's declared gate-side
special-casing ceiling. Named, not patched — the frozen battery is not mine to amend mid-round.

## C3 (operability) — the executed leg and the blanket control both load-bearing

Baseline pristine reproduced c3-base=0 (lane dd6ccb9), c3-pos=1, c3-blanket=4 on trees built per
the runner recipe (FIXES verbatim). z1 (executed selftest leg deleted) reads blanket=**5** — killed
by c3-blanket's "never 5". z2 (leg-1 pattern `TMPDIR:-/tmp`→`/tmp`) reads blanket=**3** — killed
because corpus/prefreeze-control.sh retains 3 residual `/tmp` byte-sequences (`"$tmp/tmp"`,
`TMPDIR=$tmp/tmp` ×2) in the all-greps-fixed tree. No C3 survivor.

## Honesty / provenance

- Exact commands and full stdout/rc tables: receipts/c1-matrix.txt (exit 0), c2-battery.txt
  (exit 0), c3-matrix.txt (exit 0); drivers, fixture gates and all 10 mutant scripts copied
  alongside. receipts/ c1/c3 are fresh re-runs of the same drivers (identical readings to the
  first pass); c2-battery.txt is the output file of the single background run.
- C2 battery ran once per cell; the correct-gate cells each executed both lane runners three times
  (clean/stale/silent fixtures) inside sandbox clones; no lane path was written by any runner
  (both runners resolve pinned revisions via git show; verified by reading them before running).
- No tooling installed or upgraded (bash 5, python3, git only). No pacman transaction.
- Sandbox deleted before yield (`rm -rf -- $S`); deliverables are self-contained.

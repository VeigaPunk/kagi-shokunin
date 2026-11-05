# 01 — frozen counters: C1 / C2, candidate vs BASE vs predeclaration

Extraction (read-only):
  cd /home/vgpnk/Projects/shokunin/kagi-shokunin
  git rev-parse --show-toplevel -> /home/vgpnk/Projects/shokunin/kagi-shokunin
  git archive 6742fdef0e261dd06a38a0fb0b66b1bc027d1bee | tar -x -C $S/ext

## Candidate (6742fde), frozen counters
  $ cd $S/ext && bash plans/round-39-c1.sh   -> 3      (rc 0)
  $ cd $S/ext && bash plans/round-39-c2.sh   -> 3      (rc 0)
  => C1 3/3 and C2 3/3 reproduced exactly (declared targets 3, BASE 0).

## BASE reading (no instrument present)
BASE has neither instrument, per `git ls-tree 06144518…` (all six paths empty):
  corpus/anchor-pins.sh, corpus/anchor-pins.tsv, corpus/claims-declared.sh,
  corpus/claims-declared.tsv, plans/round-39-c1.sh, plans/round-39-c2.sh
Counter script placed on a BASE-shaped root (only the counter scripts, no corpus/):
  $ bash base-root/plans/round-39-c1.sh -> 0      (rc 0)
  $ bash base-root/plans/round-39-c2.sh -> 0      (rc 0)
=> BASE 0 reproduced for both counters.

## Frozen pre-freeze gate, reproduced at the predeclaration (1909e38)
  $ cd $S/pre && BASE=$S/pre bash plans/round-39-controls.sh c1_nowork  -> 0
  $ cd $S/pre && BASE=$S/pre bash plans/round-39-controls.sh c2_nowork  -> 0
  $ cd $S/pre && bash plans/round-39-c1.sh                            -> 3
  $ cd $S/pre && bash plans/round-39-c2.sh                            -> 3
  $ PREFREEZE_REPO=<lane> bash corpus/prefreeze-control.sh run \
        --base 1909e3876341cc90246516886def37a7c9ea92f9 --controls plans/round-39.controls.tsv
      OK c1_nowork expect=0 measured=0
      OK c1_positive_three expect=3 measured=3
      OK c2_nowork expect=0 measured=0
      OK c2_positive_three expect=3 measured=3
      PREFREEZE: CLEAN (controls=4 mismatch=0)
=> the plan's frozen gate receipt ("PREFREEZE: CLEAN (controls=4 mismatch=0)", rows
   c1_nowork 0, c1_positive_three 3, c2_nowork 0, c2_positive_three 3) is reproduced.
Note: `corpus/prefreeze-control.sh` derives the repository from its own location unless
PREFREEZE_REPO is set, so from a scratch extraction PREFREEZE_REPO must point at the lane
checkout (the plan's stated command line omits it; it only works when run in place).

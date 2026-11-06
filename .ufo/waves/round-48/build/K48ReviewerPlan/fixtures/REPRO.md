Fixture commits are built in a scratch clone (toplevel asserted before every commit):
  D=$(mktemp -d "$S/fx.XXXXXX") && git clone -q --shared <lane> "$D" && git -C "$D" checkout -q --detach 76da518fcc3029e738648bd6fd4ba5571df01c1c
  C2 counter: copy plans/round-48-c2.sh into "$D/plans/" (LANE=dirname/.. = the fixture clone), run
    HYAKU_SCRATCH=<scratch> bash "$D/plans/round-48-c2.sh.frozen" <fixture-commit>
  C1 counter: bash plans/round-48-c1.sh --tree <tree>   (tree = git archive 76da518 + fixture trial + ref entry section)
Readings are inserted with fixtures/payload/ins.py <SCORECARD.md> <payload.txt> (UTF-8 safe; inserts inside ## Capabilities).

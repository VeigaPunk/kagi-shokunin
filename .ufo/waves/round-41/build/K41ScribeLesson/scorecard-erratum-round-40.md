## Erratum to the Round 40 post-move block (appended; the filed bytes are not rewritten)

The round-40 post-move section (`SCORECARD.md` §Round 40 — post-move, line 1516) states: "The frozen predicates, counters, kill rules and targets are `plans/round-40.md` and are not amended after data."
That sentence is contradicted by round 40's own lesson, which records **M40-3**: the C3 counter's verdict grep doubled `_SELFTEST`, so it read `0` at one candidate measurement, was repaired to read `2`, and that pre-repair reading is kept in `.ufo/waves/round-40/build/candidate-fast-gates.txt`.
The correction is an **appended erratum**, naming M40-3 as an instrument repair that took one candidate reading before the fix — never a rewrite of the filed round-40 bytes; routed by `corpus/lessons/round-40-verifier-spotcheck.md` §7 item 3.

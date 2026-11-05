# Seat K42MutCounters — kagi round 42, pre-freeze mutation attack on the two frozen counters

Question: do the frozen controls kill broken counters before candidate scoring? Method: 8 mutants of
`plans/round-42-c1.sh` (5) and `plans/round-42-c2.sh` (3), each a full script copy at
`plans/c?-M<n>.sh` in an isolated scratch clone at 98dd4de (toplevel verified), run with the real
BASE gate and the two blanket gates exactly as `plans/round-42-controls.sh` wires them. Kill rule as
frozen: killed = any control differs from its expected value.

**Verdicts.** Killed: c1-M1 (always 5), c1-M2 (inverted F5 rule), c1-M4 (F5 dropped, prints 5),
c2-M1 (always 1), c2-M2 (trusts the worktree's committed receipt). **Survivors (coverage findings,
not contract changes): c1-M3 (P0 gate dropped: 4/0/0), c1-M5 (token check dropped: 4/0/0), c2-M3
(derivation dropped: 0).** Full table, wirings, and survivor reasons:
`.ufo/waves/round-42/build/K42MutCounters/mutants.md`; raw outputs in
`.ufo/waves/round-42/build/K42MutCounters/receipts/` (commands.log lists every command with rc).

**Named defects (surviving mutants).**
1. c1-M3 + c1-M5: the C1 battery's discrimination is value-only. The blanket-refuse fixture refuses
   token-lessly, so the per-token grep alone (M3) or the P0 gate alone (M5) each suffice to read
   4/0/0; no frozen control refuses P0 with a valid frozen token (the only shape separating
   pristine 0 from mutant 1 — demonstrated in `c1-M3.refuse-token.txt` / `pristine-c1.refuse-token.txt`).
2. c2-M3: the D-side of the C2 counter is unexercised by the battery (BASE R=3 fails ==1 anyway;
   no control creates D≠1 or a candidate-edited round-41 counter).
3. Ceiling probe: a runner patched to write the constant 1 (`c2-ceiling-receipt-value.txt` = 1,
   worktree-only patch in scratch, no commit) passes the pristine counter (D=1, R=1 → 1) with
   c2-base=0 and D=1 holding — the plan's declared ceiling, receipted. Honest note: the assignment's
   predicted "counter-M1 survives a source-blind control" did **not** occur — c2-base (0) kills
   counter-M1; the survival exists on the runner side, exactly where the plan names its ceiling.

**Freshness/calibration.** Pristine runs at 98dd4de reproduce all five frozen receipts exactly
(c1 4/0/0 · c2 0 · D 1 · worktree R 3). No re-measurement drift.

**Provenance/honesty.** Mutants are the pinned 98dd4de (pre-A1) bytes; at the claim BASE every
reading is A1-invariant (candidate copy == frozen counter there), disclosed in mutants.md. Lane tree
untouched: sandbox `diff-index HEAD` empty; pristine c1 hash equals the lane's; the lane c2 hash
difference is A1 (fdbb83d), not this seat. All runs rc=0; scratch deleted on exit. No tool installs.

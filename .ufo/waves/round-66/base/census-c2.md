# Base census C2 — claims.json vs frozen plan (round 66)

Measured over `.ufo/waves/round-65/claims.json` against `plans/round-65.md`
with Amendments A1–A3. The three round-65 claims' claims.json titles:
- C1 "class-matrix held-out defeats structural vehicle" — matches the plan
  heading; target "matrix=0, population=8, GUARD=1 (BASE matrix=5
  population=8 guard=0)" differs from the plan's guard=1-at-BASE census
  note (the claim fails pre-amendment on guard 0, post-amendment the BASE
  reading carries guard=1) — STALE in target, not title.
- C2 "routed-leg population proves the six round-64 receipts" — Amendment
  A2 supersedes the six round-64 receipts with the round-63 five-receipt
  derived population and re-freezes the predicate onto the round-63 D-B
  population mismatch. The claims.json title is STALE.
- C3 "volatile=1, VOLATILE_SHAPE match=1 passages=182 texts=180" —
  Amendment A1 restates the predicate from live-fetch to committed
  capture: the landed counter prints `match=1 … date=20261108`, never
  `volatile=1`. The target text is STALE.
Do-nothing control: a copy of claims.json whose titles match the frozen
plan+amendments reads exact=1 with the plan unchanged — the claim moves
only by the claims.json being rewritten to the current text. A mutation
reverting one title to the stale wording reads exact=0 naming the claim id.

# K44MutBattery — scoped findings (round 44, attempt 1)

Full evidence: `.ufo/waves/round-44/build/K44MutBattery/mutants.md` + `raw/` (12 receipts).
Sandbox `/fast/scratch/hyaku/kagi-r44/K44MutBattery` deleted before yield; lane tree untouched.

## What was reproduced

1. **Round-43 counter-mutation survivors (y1, y2) rebuilt from the frozen recipes** in
   `plans/round-44-c1.sh`, applied to a byte-copy of the clone's `plans/round-43-c2.sh`
   (recipe rc 0, markers count==1, post-conditions "no `\"$N1\"` / no `\"$N2\"`" hold;
   shas in `raw/recipe-verify.txt`). Gate templates extracted from the battery bytes
   (`raw/gate-extract.txt`).
2. **Survivor state confirmed**: y1 and y2 each read 1 with the clone's own
   `corpus/controls-replay.sh` gate (the M43-7 survivor state), 0 under always-refuse, 1 under
   their paired negative fixture gate (y1×accept-stale, y2×accept-silent), and 0 under the
   wrong pairs (y1×accept-silent, y2×accept-stale) — the battery cannot credit a wrong-pair
   kill. All 12 grid cells at expectations (`raw/grid-survivor.txt`).
3. **Battery re-measured at ae9e9eb3**: real 2, skip-fixtures 0, only-stale 1, only-silent 1;
   at claim BASE d54109d: 0 and 0. **Zero disagreement** with the committed BASE receipts
   (`c1-base`=0, `c1-skipfix`=0) and the smoke matrix (2/0/1 at R2).

## Surviving defect named (attack on the battery itself)

**B1 — the always-refuse blanket legs are load-bearing for nothing the frozen matrix
measures.** Dropping the y1 blanket condition `[ "$Y1_AL" = "0" ]` (one line, fixture commit
`a46a28b3a3fe1edbeec476cd3f8944c408501cab`) leaves every frozen receipt unchanged: real 2,
skip-fixtures 0, only-stale 1 — byte-for-byte the pristine battery's readings, so no committed
receipt kills it. Materiality is real, not theoretical: a gate-ignoring counter
(`OVER=${CONTROLS_REPLAY_GATE:-}` → `OVER=`), and its y1-recipe derivative, read 1 under
*every* gate including always-refuse (`raw/z-gate-ignoring.txt`) — the pristine battery refuses
that shape, the B1 battery credits it and overcounts. This sits inside the declared ceiling
(counter shapes outside the recipe vocabulary) but the *matrix's* blindness to blanket-leg
removal is a battery defect, not a counter one. No contract change proposed from a leaf; the
L1 may want a receipt that exercises the blanket legs (e.g. a fixture counter forced to read 1
under always-refuse) if a slot opens.

## Attacks that died (fail-visible)

- **B2** — accept-stale widened to accept-everything (`exit 1` → `exit 0`, fixture
  `d0422a02d88276ffbe3e3b3fd159c9d8953b9b16`): real 1 ≠ 2 → killed by kill-rule (a)
  (c1-real); only-stale 0 ≠ 1 → also fails c1-partial.
- **B3** — both fixture gates widened (fixture `73fe6a22c1619e107fe788df9aa76d8ff05e4d7b`):
  the mutated battery reads **0** at the candidate-like fixture and 0 at only-stale — dead
  twice over.

## Method notes for the record (honesty)

- The battery's self-byte leg makes a mutated battery measurable only at a candidate-like
  fixture carrying the mutated bytes at `plans/round-44-c1.sh`. I created one-commit scratch
  fixtures with declared identity `K44MutBattery (round-44 fixture)
  <k44mutbattery.fixture@invalid>` (deleted before yield; `git rev-parse --show-toplevel`
  asserted before each commit). First B1 attempt against predecl bytes was correctly refused
  rc 2 (`raw/battery-mut-b1-selfrefuse-at-predecl.txt`) — the self-leg fails closed.
- Two B2/B3 attempts failed on a driver-script bug (unquoted heredoc expanded `$D` in the edit
  anchor; fixtures stayed pristine, readings were the pristine battery's). The false-start
  receipts are preserved (`raw/battery-mut-B{2,3}-pristine-run-edit-broken.txt`,
  `…-edit-broken-attempt.txt`); v2 reruns assert mutated-bytes-differ and HEAD-advanced.
- No tool installs (operator authorization not exercised). Only lane-read + sandbox +
  deliverable paths written.

SEAT-STATUS: complete

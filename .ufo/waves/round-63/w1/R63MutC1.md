# R63MutC1 — mutation battery (scoped findings)

Seat `R63MutC1`, mutation-tester (attack seat), wave `kagi-r63-w1`, kagi round 63
attempt 1. Read-only over the lane; no lane file written, no git/jj command run.
Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc` (extracted with `git archive`).

Full receipt with every mutant's exact bytes delta, observed line and verdict:
`.ufo/waves/round-63/build/R63MutC1/mutants.md` (supporting transcripts
`checker-battery.txt`, `cand-battery.txt`, `counter-battery-v2.txt`, `counter-battery-final.txt`, `probes.txt` in the
same directory).

## Census

| battery | bytes | population | killed | survived | inconclusive |
|---|---|---|---|---|---|
| checker, BASE | `f2afd9b8` (cases=75) | 25 | 21 | 4 | 0 |
| checker, candidate | `eb08094c` (cases=102) | 23 | 20 | 3 | 0 |
| counter | `a78a7c47` (total=10) | 12 | 2 | 10 | 0 |
| counter | `9d37e5f9` (total=27) | 16 | 0 | 0 | 16 (baseline `STUB: unbound variable`) |
| counter | `92b5a82e` (total=27) | 16 | 12 | 4 | 0 |
| counter | `652665ec` (total=28) | 16 | 12 | 4 | 0 |

## Findings

1. **Two live counter defects blocked the verdict during the wave, both reported and
   fixed by the owner.** `a78a7c47:395 stub: unbound variable` (no composition line) and
   `9d37e5f9:473 STUB: unbound variable` (`stub_calc` set `stub`, the verdict read
   `$STUB`). The second made every mutant reading inconclusive; it is fixed at
   `92b5a82e`/`652665ec`, where `--selftest` reads `PASS (27/27)` / `PASS (28/28)` and the
   verdict line prints.
2. **The counter's selftest now kills the counting, composition, gate, stub, parse and
   leg-unit classes** (12/16 on `652665ec`), including the round-62 CM2a/CM2b survivors
   (`stub-composition`, `stub-leg-negative-vector`).
3. **Four call-site constants still survive the counter's selftest** (`guard=1`;
   `PRIOR=1`; `PARA=1`; `REAL=1` substituted for the `leg_*` calls in the verdict run).
   The selftest exercises the helpers directly, so the verdict wiring is untested: a
   counter that prints `guard=1` unconditionally passes `PASS (28/28)`. Fix: one
   self-invocation verdict case (run the counter's own verdict mode on a witness tree
   where one leg must read 0; assert exit 1 and `guard=0`), or make the verdict run call
   the helpers through the same composition the selftest pins.
4. **The candidate checker closes every construct the round adds** (20/23 killed on
   `eb08094c`), including the round-62 GM5 I6 superseded-stamp conjunct (N11 killed by
   `f9`, `f10`, `i6-superseded-stamp-conjunct-isolated`). The three survivors:
   - `N16` I7 subject window 8 -> 1000: **live** — a pair >8 tokens after its subject is
     accepted (pristine `i7=0`, mutant `i7=1`). Fix: one case with the pair 9..12 tokens
     after the subject asserting FAIL.
   - `N04` `_asserted` quote mask dropped: **equivalent** — the mask is redundant with
     `_negated_before`'s own mask and `_denied_after` scans only after the token.
   - `N05` `_negated_before` internal mask dropped: **live at unit level**, equivalent
     through `_asserted`. Fix: one direct unit case with a quoted negator, or delete the
     redundant mask.
5. **BASE survivors reproduce the round-62 routing**: GM5 (I6 superseded conjunct) is
   live, and two new live gaps are added — the I3 anchor test (`M11`) and the I1
   last-row-wins rule (`M22`); the QM74 duplicate (`M18`) is equivalent.
6. **Cosmetic latent defect**: the candidate checker binds the I5 mechanism regex to
   `REWITTEN_IN_PLACE_RE` (missing `R`) at both definition and use; a later edit that
   spells one occurrence correctly raises `NameError` in `item5`.
7. **The candidate checker's selftest reached the frozen floor late**: `cases=76` at
   `f0409a45` (floor 91) and `NameError: mk_fleet` at `3ebe0885`; both reported to the
   owner. `eb08094c` reads `PASS (cases=102)`.

## Scratch and restoration

All work under `/fast/scratch/hyaku/kagi-r63/R63MutC1/` (deleted before yield; the
counter's own scratch was redirected there via `HYAKU_SCRATCH`). No citable evidence
under `/tmp`; no secret value, cookie, token, session id or vault/item/field name in any
artifact. Lane instruments were read-only; the hashes measured are the executors' bytes.

SEAT-STATUS: complete

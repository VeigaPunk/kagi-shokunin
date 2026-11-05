# K39MutInstruments — mutation probe of the round-39 C1/C2 instruments and counters

Round 39, kagi lane. Seat: mutation-tester. Candidate `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee`
("round-39: candidate — registry contract S094, tagged axis self-assessment, usage correction and
lessons"). BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`. Predeclaration
`1909e3876341cc90246516886def37a7c9ea92f9`. Frozen plan `plans/round-39.md` read in full; targets not
reinterpreted (target 3, BASE 0). No tools installed (bash/git/awk/sed sufficient). No commits, no git
mutations, no production edits; the single git operation was a read-only `git archive` of the candidate.

## Baseline (pristine candidate)

Extracted once via `git archive 6742fdef… | tar -x` into scratch. All seven frozen files byte-identical
between the candidate extraction and the lane working tree (sha256 compared, 7/7 SAME):
`plans/round-39-c1.sh`, `plans/round-39-c2.sh`, `corpus/anchor-pins.sh`, `corpus/claims-declared.sh`,
`corpus/anchor-pins.tsv`, `corpus/claims-declared.tsv`, `plans/round-39.controls.tsv`.

| Reading | Output | Expectation |
|---|---|---|
| `bash plans/round-39-c1.sh` (pristine) | `3` rc=0 | 3 (target) |
| `bash plans/round-39-c2.sh` (pristine) | `3` rc=0 | 3 (target) |
| C1 nowork (instrument+pin file removed) | `0` rc=0 | 0 (BASE) |
| C2 nowork (instrument removed) | `0` rc=0 | 0 (BASE) |

**Frozen C1 and C2 reproduced** (3/3, controls 0/0). No baseline failure, therefore no inconclusive
mutants; every verdict below is a real kill or survival.

## Mutant battery

Detector = the frozen counter in the same scratch tree (`bash <tree>/plans/round-39-c{1,2}.sh`),
expectation 3 on a healthy tree, 0 on a neutered/no-work tree. Mutants were applied to copies
(`mut-*`), never to the pristine extraction; each mutation verified by `diff -u` to be exactly the
single intended delta (receipts `logs/diffs/*.diff`).

### C1 side — instrument `corpus/anchor-pins.sh`, counter `plans/round-39-c1.sh`

| Mutant | Mutation (smallest behavior-bearing point) | Detector | Verdict |
|---|---|---|---|
| C1-M1 | digest comparison dropped: `[ "$got" != "$want" ]` → `[ -n "" ]` | counter `0` (≠3) | **KILLED** |
| C1-M2 | pin S035 skipped in the read loop (`case … \|S035) continue`) | counter `2` (≠3) | **KILLED** |
| C1-M3 | verdict block removed — always `CLEAN`, exit 0 | counter `0` (≠3) | **KILLED** |
| C1-CT1 | counter drops planted mutant M2 (`mutant M2 …` line removed) | counter `2` (≠3) | **KILLED** |
| C1-CT2 | counter hardcodes `echo 3` | positive `3`, nowork `0` — passes both frozen control rows | **SURVIVED** (control blind spot, see below) |

Direct-gate evidence: pristine gate on a planted S034 rewrite (`v2.2.0→v2.2.1`, planted with the
counter's own sed program) prints `DRIFT S034` / `ANCHOR_PINS: DRIFT (pins=3 drift=1)` rc=1; the C1-M1
gate on the same planted copy prints `ANCHOR_PINS: CLEAN (pins=3)` rc=0 — digest check demonstrably
dead. C1-M2 gate on the pristine tree prints `ANCHOR_PINS: CLEAN (pins=2)` — a pin silently vanishes
while the header still claims pins=N. C1-M3 still emits the per-row `DRIFT S034` line but exits 0; the
counter counts only `rc==1 ∧ DRIFT`, so the exit-code conjunction is load-bearing (a text-only counter
would have scored C1-M3 as detected=3 and survived).

### C2 side — instrument `corpus/claims-declared.sh`, counter `plans/round-39-c2.sh`

| Mutant | Mutation | Detector | Verdict |
|---|---|---|---|
| C2-M1a | scorecard-axis equality dropped (`if [ "$tagged" != "$axis" ]` → `[ -n "" ]`) | counter `2` (X1 escapes) | **KILLED** |
| C2-M1b | equality weakened to substring `[[ "$tagged" != *"$axis"* ]]` | counter `3` | **SURVIVED** — coverage finding |
| C2-M2 | section binding removed (`## Round <round> — post-move` gating deleted; all table rows scanned) | counter `0` — positive control fails | **KILLED** |
| C2-M3 | verdict block removed — always `CLEAN`, exit 0 | counter `0` (≠3) | **KILLED** |
| C2-CT1 | counter drops planted mutant X2 (`mutant X2 x2` line removed) | counter `2` (≠3) | **KILLED** |
| C2-CT2 | counter hardcodes `echo 3` | positive `3`, nowork `0` — passes both frozen control rows | **SURVIVED** (control blind spot, see below) |

Direct-gate evidence: C2-M2 on a pristine replica of the counter's fixture prints
`MISMATCH 39 C2 tagged-rows-2` (the Round-38 decoy row `[C2] older row, must not be read` is now read)
rc=1, so the counter's positive control trips and prints 0 — the kill is real but reason-blind: the
counter cannot attribute the failure to lost section binding vs any other breakage.

**C2-M1b slippage proof** (receipts `probe-c2m1b-fixture/`, `logs/runs/C2-M1b-*.txt`): fixture whose
Round-39 SCORECARD row's first cell is `calibration (relabelled in place)` — pristine gate prints
`MISMATCH 39 C2 scorecard-axis-calibration (relabelled in place)-not-calibration` rc=1; the C2-M1b gate
prints `CLAIMS_DECLARED: CLEAN (claims=2)` rc=0. Any axis cell that merely *contains* the declared axis
passes the weakened gate. The three planted relabels are cross-word (freshness ↔ calibration ↔
operability), so the counter's reason-blind "any MISMATCH" criterion cannot distinguish exact equality
from containment conformance.

### Cross-probes exposing the CT2 blind spot

`mut-X-C1CT2` = C1-CT2 counter + C1-M3 always-CLEAN instrument; `mut-X-C2CT2` = C2-CT2 counter + C2-M3
always-CLEAN instrument. A true counter prints 0 on both (no detection possible); both mutants print
`3`. The frozen control pair (nowork 0 / positive 3) under-determines the counter: a counter that
hardcodes its target passes `c*_nowork` and `c*_positive_three` simultaneously.

## Verdict summary

- **Killed (8):** C1-M1, C1-M2, C1-M3, C1-CT1, C2-M1a, C2-M2, C2-M3, C2-CT1.
- **Survived (3):** C2-M1b (instrument weakening invisible to the reason-blind counter);
  C1-CT2, C2-CT2 (target-hardcoded counters invisible to the two frozen control rows).
- **Inconclusive (0):** baselines all passed.

## Coverage findings (surviving mutants are findings, not contract changes)

1. **C2 counter is equality-blind.** Add a containment-class planted mutant (axis cell that contains
   but does not equal the declared axis, e.g. `calibration (relabelled in place)`) to the counter's
   mutant set; the frozen gate already kills it (MISMATCH), so a fourth planted mutant would have
   killed C2-M1b. Candidate frozen-counter amendment for round 40; nothing changed here.
2. **Counter hardcoding is unobservable by the frozen controls.** A third control row of the shape
   "counter against a neutered (always-CLEAN) instrument → expect 0" would kill CT2-class mutants on
   both counters. Routed as an observation only.
3. **C1-M3 nuance:** the per-row `DRIFT <id>` line plus exit-code conjunction in the counter is what
   kills the always-CLEAN gate; preserving both signals in any future counter rewrite is load-bearing.

## Boundaries respected

- One extraction only; mutants lived exclusively in scratch copies under
  `/fast/scratch/hyaku/kagi-r39/K39MutInstruments/mut-*`.
- Pristine candidate tree re-hashed after the entire battery: all 8 recorded files identical to
  before-hashes (`logs/before-hashes.txt` vs `logs/after-hashes.txt`, sha256 -c clean) — counters and
  probes never wrote into the tree.
- No sibling/production/lane writes; only this seat's report and receipts were written in the lane.
- Scratch (including all `mut-*` trees and probe fixtures not copied out) deleted before yielding;
  receipts preserved under `.ufo/waves/round-39/build/K39MutInstruments/`.

Receipts: `logs/diffs/` (15 exact-delta diffs), `logs/runs/` (22 run transcripts),
`logs/before-hashes.txt`, `logs/after-hashes.txt`, `logs/mutant-hashes.txt`,
`probe-c2m1b-fixture/` (slippage fixture).

Report: .ufo/waves/round-39/build/K39MutInstruments.md

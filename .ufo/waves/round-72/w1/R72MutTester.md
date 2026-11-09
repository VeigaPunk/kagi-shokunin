Author: R72MutTester (mutation-tester)

# Scope

Mutation test of the two frozen round-72 counters, `plans/round-72-c1.sh` (C1 freshness) and `plans/round-72-c2.sh` (C2 calibration), against the 20 frozen controls in `plans/round-72-controls.sh`. Each mutant was built in scratch from a pristine copy of the frozen counter (sha256 of the lane copies: c1 `cc83b638…`, c2 `6ac7c51b…`, controls `77c6cacaa…`). The lane, the frozen files, the fleet repo and the L1 scratch were not written. Base and candidate trees were `git archive` of b2f3dd66 and a947a42c into scratch. Mutant diffs are in `.ufo/waves/round-72/w1/R72MutTester/mutants/*.diff`; receipts are in `.ufo/waves/round-72/w1/R72MutTester/receipts/`.

Run discipline: the controls runner was run against the mutant copy of each counter, with the runner's own `HERE` pointing at the mutant directory. Pristine counter baseline on the candidate tree: C1 value=10 rc0, C2 value=0 rc0 (matches `.ufo/waves/round-72/final/c{1,2}-candidate.txt`). Pristine 20/20 control set was reproduced by the unmodified runner earlier in the seat's prior receipts (`.ufo/waves/round-72/controls/receipts/summary.txt`, 20/20 MATCH); I did not re-run it unmodified.

Coverage caveat: a full 20-control sweep was run for C1-MT1 only. The other mutants were run on the controls that can plausibly distinguish them, plus P1/Q1 as positive references. A mutant reported "survived" means no control in the run killed it; for C1-MT6, C1-MT8, C2-MT3, C2-MT4 and C2-MT5 I also checked by reading the control receipts that no unrun control has the discriminating property (see per-mutant notes). Runtime was roughly at the 40-minute budget; I did not split the ledger sub-legs of C1 into single-field mutants.

# C1 mutants (`plans/round-72-c1.sh`)

Kill = a control whose expected verdict no longer matches (rc or verdict regex).

| mutant | leg weakened | controls run | result |
|---|---|---|---|
| C1-MT1 | ARMED/SOURCED-independent `not-newer` check deleted | all 20 | SURVIVED (20/20 MATCH) |
| C1-MT2 | SOURCED check deleted (mined/opened/URL/absent-in-BASE) | F7, F0, P1 | KILLED by F7 (value 10, expected 4) |
| C1-MT3 | LIVE per-id check deleted | F6, P1 | KILLED by F6 (value 10, expected 4) |
| C1-MT4 | VERIFIED ledger binding reduced to rearmed/fid/url/verdict (sha, bytes, fetched_at, path confinement dropped) | F4, P1 | KILLED by F4 (value 10, expected 9) |
| C1-MT5 | GATE forced to 1 | F3, F8, P1 | KILLED by F8 (value 10, expected 0); F3 still 0 |
| C1-MT6 | FRESH forced to 1 | F0, F3, F10, P1 | SURVIVED (4/4 MATCH) |
| C1-MT7 | CENSUS byte-identity pin deleted | F9, P1 | KILLED by F9 (value 10, expected SETUP rc2) |
| C1-MT8 | VERIFIED quote_count equality weakened to >=1 | F4, F5, P1 | SURVIVED (3/3 MATCH) |

Per-mutant notes:

- C1-MT1 survived a full 20/20 run. Mechanism: `not-newer` only fires when every other leg is already satisfied at an anchor equal to the BASE anchor. Every control either fails `not-armed` (F0 anchors = BASE, observed 2.2.1 ≠ anchor), or sets anchors to a value newer than BASE (F1, F6, F7 etc.). No control produces an armed, sourced, live, ledger-bound row at a non-newer anchor. The "newer than BASE anchor" wording of ARMED is therefore not proven by any control.
- C1-MT6 survived. FRESH changes the outcome only when gate=1 and some receipt observation is dated before 2026-11-09. The only old-dated receipt in the controls is the BASE round-54 receipt, and it occurs only in F0 and F3, both gate=0 (BASE tree has no round-72 receipt pinned; F3 ships the round-54 default). Checked in `F0-base.txt`, `F3-stale-receipt-pin.txt` (gate=0, fresh=0). So no control has the discriminating combination (gate=1 and fresh=0). The FRESH leg is unproven.
- C1-MT8 survived. The equality `str(n) == qc` is only falsified by a ledger row whose quote_count disagrees with the located count while the located count is >=1. Controls F4 (digest) and F5 (quote absent, n=0) do not do that: F5 is killed by n>=1 anyway. The candidate's own ledger has quote_count=3 for S024 and it locates 3 times, so the candidate passes either way. The exact-equality wording is unproven.
- C1-MT2 kill is by F7, which is the in-place anchor edit on S035 and the only control that makes a non-mined or non-new feed visible via the SOURCED leg. Kill is real.
- C1-MT4: the mutant removes sha/bytes/fetched_at/path together; only F4 (forged sha) fired, so the sub-legs for bytes, fetched_at window and path confinement are individually unproven. This is a coverage note (neutral), not a survivor of the combined mutant.

# C2 mutants (`plans/round-72-c2.sh`)

| mutant | leg weakened | controls run | result |
|---|---|---|---|
| C2-MT1 | PINS check deleted (both sha pins) | G1, G2, Q1 | KILLED only by reason text: G1/G2 still rc2 but the printed SETUP reason moves to shape/gate-exit, not the pins line |
| C2-MT2 (as first written) | shape regex deleted | G3, G5, Q1 | Invalid kill: deleting the regex left BASH_REMATCH empty, so Q1 (positive) itself failed with an empty verdict line. Collateral; discarded |
| C2-MT2b | shape weakened to any trailing fields, still captures stale= | G3, G5, Q1 | KILLED by G3 only through the redundant ok+stale check (ok+stale=59, expected 61); G5 killed via policy ids. The field-level shape (unlocated=0 ambiguous=0 setup=0 policy=2) is not individually proven |
| C2-MT3 | claims=63 fixed to claims=[0-9]+ in the shape regex | G1, G4, Q1 | SURVIVED (3/3 MATCH). G1 is caught by the pins check before shape runs, so the claims=63 binding is never exercised |
| C2-MT4 | policy-id check (PV-FEEDTOKEN-SHAPES / -SELFTEST) deleted | G5, G4, Q1 | SURVIVED on the id leg. G5 is still killed, but via the shape regex (policy=1 fails the fixed `policy=2` field), not the ids |
| C2-MT5 | gate exit==2 check deleted | G2, G5, Q1 | SURVIVED (3/3 MATCH). G2 is killed by pins first; G5 by shape; no control has a valid POLICY summary with a non-2 exit while pins pass |

Notes:
- C2-MT1: the kill is real in the runner's sense (text mismatch), but the pins leg is not isolated, since G1 and G2 are the only pin controls and under the mutant they report a different leg.
- C2-MT3, C2-MT4 and C2-MT5 survived their subsets. I verified by reading the control receipts that no control in the 20 changes claims away from 63 with pins intact, no control holds a valid POLICY line with a changed policy id list, and no control produces a valid summary with gate exit ≠2. The corresponding legs are unproven by the frozen controls.

# Survivor ledger

Surviving mutants (no control kills them): C1-MT1 (not-newer), C1-MT6 (FRESH), C1-MT8 (quote_count equality), C2-MT3 (claims=63 binding), C2-MT4 (policy id list), C2-MT5 (gate exit==2). Partial: C2-MT2b (field-level shape only covered by redundant ok+stale), C1-MT4 sub-legs (bytes, fetched_at window, path confinement), C2-MT1 (pins leg only observable through reason text).

Recommendations for the controls runner (not applied; the runner and counters are frozen): add a not-newer control (anchor equal to BASE with otherwise-armed row), a FRESH control (gate=1 with a receipt dated 2026-11-08), a quote_count-mismatch control (ledger quote_count=2 with 3 located), a claims-count control (claims≠63 with pins intact is not reachable; a pins-intact ledger change suffices), a policy-id-change control with policy=2, and a gate-exit-0 control with a valid summary and pins intact.

# Restoration evidence

All mutants were built in `/fast/scratch/hyaku/kagi-r72/R72MutTester`. The lane's frozen counters (`plans/round-72-c1.sh`, `plans/round-72-c2.sh`, `plans/round-72-controls.sh`) were read only; sha256 at read time matched the values above. No lane file, no fleet file and no L1 scratch was written. No tools were installed.

FINDING MT-1 falsifies-wording C1 ARMED "newer than BASE anchor" leg (C1-MT1 not-newer deleted) survives all 20 frozen controls; no control has an armed, sourced, live, ledger-bound row at a non-newer anchor
FINDING MT-2 falsifies-wording C1 FRESH leg (C1-MT6 forced to 1) survives F0, F3, F10 and P1; no control has gate=1 with a receipt dated before 2026-11-09
FINDING MT-3 falsifies-wording C1 VERIFIED quote_count equality (C1-MT8 weakened to >=1) survives F4, F5 and P1; no control has located count >=1 that differs from quote_count
FINDING MT-4 neutral C1 SOURCED is killed only by F7, LIVE only by F6, and the ledger binding only by F4 (combined mutant); bytes, fetched_at window and path-confinement sub-legs are individually unproven
FINDING MT-5 falsifies-wording C2 claims=63 binding in the shape regex (C2-MT3) survives G1, G4 and Q1; G1 is caught by pins before shape runs
FINDING MT-6 falsifies-wording C2 policy-id leg (PV-FEEDTOKEN-SHAPES / -SELFTEST, C2-MT4) survives; G5 is killed only by the fixed policy=2 field of the shape regex
FINDING MT-7 falsifies-wording C2 gate exit==2 leg (C2-MT5) survives G2, G5 and Q1; G2 is caught by pins first
FINDING MT-8 neutral C2 pins leg (C2-MT1) is killed only through a changed reason string (G1/G2 rc still 2); C2 shape field-level checks (unlocated, ambiguous, setup) are proven only by the redundant ok+stale check (C2-MT2b, G3)
SEAT-STATUS: partial scoped mutation run complete for all 13 mutants with 6 survivors and 2 partial kills; full 20-control sweep only for C1-MT1 because of the runtime budget

# Round 35 — calibration: producer-result integrity

BASE: `063c407494276d0c616e6c712a2e5d7aeb7e3768` (master on Linux).
Predeclaration controls committed and pushed at `63ba87afce53842007ec27c09e3469132d149abd` before this declaration or candidate implementation. Instrument identity and producer identity: `.ufo/waves/round-35/controls/input-identity.json`. Rejection-history inputs: MANIFEST rounds indices1208/1217/1225 and the pinned round32/33/34 non-author spotchecks; their rejected claims remain rejected.

## C1 — calibration (one claim)

Predicate: `MEASUREMENT_RESULT mismatches=0 invalid_false_clean=0 positive_matches=2 cases=9`.

Counter (from lane root):

```
python3 .ufo/waves/round-35/controls/measure.py --script corpus/prefreeze-control.sh --base 063c407494276d0c616e6c712a2e5d7aeb7e3768 --out .ufo/waves/round-35/final/after.json --work /fast/scratch/hyaku/kagi-r35/L1
```

Before: `mismatches=5 invalid_false_clean=5 positive_matches=2 cases=9`, exit1, complete actual public `prefreeze-control.sh run` outputs in controls/before.json. No-work and numeric-CLEAN forgery are already executed. Independent expected rc and finding IDs are literal in the frozen instrument, not copied from gate output. After: exact predicate above, exit0. Kill rule: any mismatch, missing case, unexpected rc/finding, changed instrument bytes or refused positive control means C1 not verified. No target or counter amendment after this freeze.

Changed surface: the lane's declaration-to-observation calibration gate currently certifies five invalid producer results as CLEAN. Its new production contract accepts only a single nonempty integer stdout line with no stderr and rc0, or rc1 with zero (grep count); empty output, diagnostics, SETUP/POLICY-shaped lines and other rc fail closed with NORESULT and final SETUP exit2. This contract cannot detect a dishonest producer that intentionally emits a valid plain integer with rc0, including a pipeline masking upstream failure; no such universal soundness is claimed. Historic last-integer receipts stay historical, not retroactively regraded. Existing positive valid-zero, grep-empty and count-mismatch cases remain.

## Populations and scope

One causal population: nine fixed public-path cases, five invalid false-CLEAN witnesses and two valid acceptance controls; empty-output and wrong-count are retained refusal controls. No registry append, no provenance migration, no new knowledge entry or population-target claim. SOURCES and capture populations will be measured independently; they are reporting invariants, not hidden exact claim targets. S088 own-work source is reopened this round; its executable and knowledge entry ground this claim. Append-only lessons/history and non-owned SD6 bytes remain unchanged. R25-02 FAIL and R29-01/R29-02 POLICY boundaries remain explicitly routed, never cleared or suppressed.

## Wave and frontier

One v1 wave, twelve seats: executor3, scribe2, scout2, connector1, reviewer2, critic1, mutation-tester1; four attack seats (33.3%). L1 holds canonical planner; separately dispatched planner role is validator-forbidden. This is an explicitly recorded minimum-role deviation, not a general waiver (R34-3). Every seat has a distinct evidence output, no concurrent production writers. Source curation uses reopened own-work S088, current source/claim bar and immutable source definitions. Assimilation: none; the round repairs held calibration ground. External terminal operations stay refused; safe generated plain dotenv probe only, no vault/ref reads or account contact.

All six scores stand9; calibration is one of the tied lowest axes. No stagnation waiver, capability entry, promotion or outside admission is asserted. Non-author closure must judge separately.

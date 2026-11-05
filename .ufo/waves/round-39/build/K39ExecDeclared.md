# K39ExecDeclared — round 39 C2 re-execution at candidate

Seat: re-execute the C2 frozen counter and the actual `corpus/claims-declared.sh` gate at
candidate; check the clean fixture and each of X1–X3 with exact stdout/rc; determine whether the
counts measure lane calibration or merely instrument operability. Scope only; no verdict claimed.

## Pins and freshness

- Candidate `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee` (= lane HEAD, branch `master`); BASE
  `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`; predeclaration `1909e3876341cc90246516886def37a7c9ea92f9`;
  frozen plan `7c11e769cd7c2450cf46faabcd3b43fca993f388`.
- One extraction only: `git -C <lane> archive 6742fdef… | tar -x` into
  `/fast/scratch/hyaku/kagi-r39/K39ExecDeclared/candidate`. No clone; no git mutation anywhere.
- Lane tracked tree clean vs HEAD (only untracked `.ufo/waves/round-39/*` wave artifacts, not mine).
- Instrument blobs identical worktree↔candidate: `corpus/claims-declared.sh` `3c2c8b99…`,
  `corpus/claims-declared.tsv` `0d5760fe…`, `plans/round-39-c2.sh` `7190abcc…`,
  `plans/round-39-controls.sh` `09b5a9a5…` (`git rev-parse` vs `git hash-object`). sha256 of the
  candidate files in `sha256-instruments-candidate.txt`.

## Results at candidate (exact stdout / rc)

| check | command (cwd = candidate tree) | stdout | rc |
|---|---|---|---|
| gate | `bash corpus/claims-declared.sh --root .` | `CLAIMS_DECLARED: CLEAN (claims=2)` | 0 |
| counter | `HYAKU_SCRATCH=<seat scratch> bash plans/round-39-c2.sh` | `3` | 0 |
| c2_nowork | `BASE=<candidate> bash plans/round-39-controls.sh c2_nowork` | `0` | 0 |

Gate matches the kill-rule line exactly (`claims=2`, real rows 39/C1/freshness and 39/C2/calibration);
counter meets target 3; do-nothing control 0. Receipts: `gate-at-candidate.txt`,
`counter-at-candidate.txt`, `nowork-at-candidate.txt`.

## Fixture ladder (counter's `fixture()` replicated verbatim; gate from candidate tree)

| run | stdout | rc |
|---|---|---|
| CLEAN | `CLAIMS_DECLARED: CLEAN (claims=2)` | 0 |
| X1 (scorecard row axis calibration→operability) | `MISMATCH 39 C2 scorecard-axis-operability-not-calibration` + `CLAIMS_DECLARED: MISMATCH (claims=2 mismatch=1)` | 1 |
| X2 (plan heading calibration→operability) | `MISMATCH 39 C2 plan-heading-not-calibration` + `CLAIMS_DECLARED: MISMATCH (claims=2 mismatch=1)` | 1 |
| X3 ([C1] tag removed from freshness row) | `MISMATCH 39 C1 tagged-rows-0` + `CLAIMS_DECLARED: MISMATCH (claims=2 mismatch=1)` | 1 |

`detected=3` reproduced from outside the counter: its rule is `rc==1 && stdout contains MISMATCH`,
and all three mutants satisfy it. Receipt: `manual-fixture-ladder.txt`.

## Added probes (fixture-only, not part of the frozen counter)

- **P1** — relabel of the Round-38 fixture row (not in the manifest) → `CLEAN (claims=2)` rc=0.
  Confirms the plan's named ceiling: history before round 39 is not gated.
- **P2** — coordinated relabel of manifest row + plan heading + SCORECARD row
  (calibration→operability) → `CLEAN (claims=2)` rc=0. Confirms the plan's named ceiling: the gate
  checks agreement of declared axis with the tagged row; it cannot judge whether the axis is the
  right one, and a consistent rewrite is invisible to it.

## Calibration or operability?

1. `detected=3` measures **instrument sensitivity** (detection power on planted synthetic mutants),
   not lane calibration. Lane calibration is measured only by the gate run against the lane's own
   text — `CLEAN (claims=2)` at candidate, where the SCORECARD round-39 rows tagged `[C1]` freshness
   and `[C2]` calibration agree with the manifest and the plan headings
   (`lane-round39-rows-at-candidate.txt`). The two are separable: a lane can read counter=3 while its
   own text mismatches; the kill rule (gate must read CLEAN at landing) is what binds the lane.
2. The count is nonetheless stronger than bare operability (the gate merely exiting): nowork=0
   (absent instrument prints 0), clean fixture CLEAN rc=0 (no false positive), and each mutant's
   MISMATCH line is **correctly attributed** — right round, right claim, right reason. The counter
   itself counts `rc==1 && MISMATCH` without checking attribution; this seat's ladder closes that
   gap for X1–X3.
3. X3 is a tag-removal (untagged claim), not an axis relabel: `detected=3` bundles two relabel
   classes and one untagged-row class under one integer. This is as the plan defines X3; observation,
   not a defect.
4. Residual calibration risk is exactly the P2 ceiling: a post-score amendment that rewrites
   manifest + heading + row together reads CLEAN. The plan handles it by kill rule/policy ("an
   amendment: C2 is then unmet, not re-declared"), not by the instrument. No in-slice defect
   survives.

## Defects

None surviving in this slice. Observations (recorded, not defects): counter does not verify MISMATCH
attribution (covered here by the ladder); P1/P2 empirically confirm both plan-named ceilings; X3
conflates mutation classes as planned.

## Housekeeping

No tool installs (none needed); no pacman transactions; no sysctl/service mutations; no commits;
no writes outside the seat receipts directory, this report, and the seat scratch. Scratch
`/fast/scratch/hyaku/kagi-r39/K39ExecDeclared/` deleted after receipts were preserved.

## Receipts (paths relative to lane root)

- `.ufo/waves/round-39/build/K39ExecDeclared/sha256-instruments-candidate.txt`
- `.ufo/waves/round-39/build/K39ExecDeclared/gate-at-candidate.txt`
- `.ufo/waves/round-39/build/K39ExecDeclared/counter-at-candidate.txt`
- `.ufo/waves/round-39/build/K39ExecDeclared/nowork-at-candidate.txt`
- `.ufo/waves/round-39/build/K39ExecDeclared/manual-fixture-ladder.txt`
- `.ufo/waves/round-39/build/K39ExecDeclared/lane-round39-rows-at-candidate.txt`

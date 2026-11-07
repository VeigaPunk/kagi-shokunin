# R60ExecControls — pre-freeze controls battery (`plans/round-60-controls.sh`)

Seat: executor (controls battery), kagi round 60 wave 1. Write scope held: the
one declared file `plans/round-60-controls.sh`, this report, and the build
receipts under `.ufo/waves/round-60/build/R60ExecControls/`. No lane commit, no
git/jj mutation anywhere (the BASE tree is materialized read-only via
`git archive`), no writes outside scope. Tooling: **nothing installed or
updated** (python3/git/tar/coreutils as shipped); the operator tooling
authorization went unused.

## Result

`bash plans/round-60-controls.sh` over the lane working tree, measured against
the landed instrument bytes, ends:

```
CONTROLS: match=20 mismatch=0        (exit 0; CONTROLS-NORESULT: count=0; no INSTRUMENT-DRIFT)
```

Instrument pins at run start (sha256, also in the receipt):

| instrument | sha256 |
|---|---|
| `plans/round-60-c1-check.py` | `52d4fd5c6660e6a9235ae6cbf7e4e504c245b06cc6aa871fa83df721489fa658` |
| `plans/round-60-c1.sh` | `c11da5c60db536c97ef3e22c0f2d6ab0704e56b1508ce6e93a65847d0e39d599` |
| `plans/round-60-c2.sh` | `a6fc9825972a20e87a35cef89032365b3611bb909606bd7738e54d1a653501f2` |
| `corpus/openbao-approle-trial.sh` | `49ea928f28f42c7cce91459fe577a6d80023db3844229047718f483bfed0e54f` |
| `corpus/openbao-transit-trial.sh` | `bb18fba0df33bf429eba67325d931ec39fab75792b0c7b09af17ef8fe8195549` |

All 20 declared controls (K1-BASE, K2-BASE, K1-REF, K2-REF, C1-F1..F8,
C2-F1..F8) ran and matched their pre-declared expectations; full lines in
`.ufo/waves/round-60/build/R60ExecControls/battery.txt`, run notes and the
NORESULT/SETUP policy in `…/notes.md`.

## What the battery does

- Scoring contract per the plan: each control is one shell function printing
  `CONTROL <id> expect=<x> observed=<y>`, scored by exact string equality (the
  only normalization is the plan's declared "<5" class); the runner ends with
  `CONTROLS: match=N mismatch=M`, exits 0 iff M=0, 1 otherwise, 2 SETUP.
- Every control works on copies under
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecControls/battery.$$`
  (trap-removed on exit, `TMPDIR` pointed there, no `/tmp`, nothing written
  inside the measured tree).
- The K1-REF fixed tree is synthetic (round-59 convention, so the battery never
  depends on candidate work having landed): BASE copy + the seven corrections
  built by the battery, every number derived at run time from the copy's own
  receipts (14 results / 0 dead, 33 selftest cases, 20 controls, the
  `c1-landed.txt` revision) — no hardcoded facts.
- The shim environment variable (`KAGI_APPROLE_SHIM`) is derived at run time
  from the landed counter, not assumed; C2 wrappers delegate to the real trial
  at the same tree path so the counter measures what it believes is the shipped
  trial.
- Per-leg timeouts (checker 300/600 s, counter 900 s, trial 300 s, selftest
  120 s) so one hung instrument leg cannot hang the battery; timed-out legs
  read `timeout` and mismatch loudly.

## Defects this seat found and routed

1. **I6 anchor unsatisfiable at BASE (predicate-shape defect, now resolved by
   the checker seat).** The plan's I6 condition anchored on "the round-59 line
   containing `75165a07`" — no `SCORECARD.md` line at BASE `a677c78e` contains
   that hash (measured: `git show a677c78e:SCORECARD.md | grep -c 75165a07` ⇒
   0), so the item could never resolve on any tree. Reported to the L1 early;
   the checker seat's amended bytes dropped that anchor for the satisfiable
   `supersedes the round-59 measured-commit citation` phrasing, and the frozen
   predicate's guard semantics (I1's `dead=` digit) are unchanged.
2. **Derived-number traps for the record-repair seat** (both bit this seat's
   own fixture builder first):
   - `grep -oE '[0-9]+'` over `C1_CHECK_SELFTEST: PASS (33 cases)` also picks
     up the digit inside the token `C1` — derive case counts with an anchored
     sed on the `PASS (N cases)` shape instead.
   - The M59-1 wrapped-bullet class recurs anywhere: the I3 "names R20, R21,
     R22 and the word duplicate" sentence must be ONE physical line, or the
     checker cannot see it (`R20/R21/R22-duplicate-line=no`).
3. **Reviewer-confirmed control defects fixed in-flight** (R60ReviewerC1
   findings, all three verified fixed by the final run): C1-F7 must flip the
   checker's I1 token (`dead=`), not `dead seats=`; C1-F6's mutation must hit
   the selftest's verdict mapping (`_st_want BASELINE "TRIAL T1 HOLDS"`), not
   the first `HOLDS` after a `selftest`-matching line (a comment); C1-F6's
   finding-id extraction must scan for the `FINDING <id>` line (the id is not
   on the FAIL-summary line).

## Instrument churn note for the L1

The wave's instruments were landing while this battery was first written and
run: one run measured a half-landed set (all controls correctly NORESULT,
exit 2 SETUP), the next measured checker `63ef4304…` (18/20, two battery-side
defects, one reviewer-caught), the final run measured `52d4fd5c…` and the
landed trial/counter bytes (20/20). The battery re-pins all five instrument
hashes at every start, re-hashes at exit, and prints `INSTRUMENT-DRIFT` lines
if the bytes changed mid-run (none in the final run). **The battery must be
re-run after the L1 commits**; expect `match=20 mismatch=0`, no NORESULT, no
drift, exit 0. Wall cost ≈ 35–45 minutes (the C2 legs run real
`bao server -dev` trials through the full counter).

Named ceilings (unchanged from the plan): K2 (shape-keyed output) and K3
(fabricated receipts) are beyond a counter battery — K1-REF's synthetic
receipts are trusted by construction, and the receipts themselves plus the
non-author probe own the fabrication class.

SEAT-STATUS: complete

# R60ExecCounterC2 — scoped findings (kagi round 60, wave w1)

Seat: R60ExecCounterC2 (leaf executor). Item: plans/round-60.md §C2 — the counter that
measures the frozen `C2_APPROLE_TRIAL` predicate. BASE a677c78e. Contract locked with
R60ExecTrial (peer message) before their trial bytes landed: `KAGI_APPROLE_SHIM=SH1..SH5`
(unknown value → SETUP rc2), summary prefix
`OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0` (their ` bao=<ver>` suffix is
grep-prefixed away), `--selftest` → rc0 + `APPROLE_SELFTEST: PASS (cases=N)`, N ≥ 8,
no-bao PATH → SETUP rc2 with zero TRIAL/HOLDS lines.

## Files changed

- `plans/round-60-c2.sh` (new, the seat's one lane file) — the C2 counter.
- Receipts under `.ufo/waves/round-60/build/R60ExecCounterC2/`:
  `base-absent.txt`, `candidate.txt`, `none.txt`, `ambient.txt`, `shims.txt`, plus
  `stub-logic.txt` (counter-logic validation on scratch stubs, disclosed as
  counter-dev fixtures, not the lane instrument).

## Counter behavior

- Input `[revision]` (BASE a677c78e when omitted) or `--tree DIR`; the revision is
  materialised into scratch via `git archive | tar` (never a lane work-tree mutation);
  the trial is read from `<tree>/corpus/openbao-approle-trial.sh` and never executed
  from the lane tree directly.
- Ten legs under `env -i`, run in shuffled order, each with its own HOME/TMPDIR/work
  and a per-leg bin dir: two real runs, one ambient run (placeholder
  `BAO_ADDR/BAO_TOKEN/BAO_NAMESPACE/VAULT_ADDR/VAULT_TOKEN/VAULT_NAMESPACE/VAULT_SECRET_ID`
  exported, must read like a real run), one none leg (bin dir without bao), one
  selftest leg (no bao on PATH — enforces the trial's fixture-driven selftest), and
  five shim runs.
- Required per real run: exactly five `TRIAL T<n>` verdict lines (no NONE, no DUP),
  vector HHHHH, summary prefix HOLDS holds=5 broken=0 error=0, rc 0. Shim runs must
  exit 1 and flip exactly their designated test (SH1→BHHHH … SH5→HHHHB). None leg:
  rc 2 + `SETUP` + no `HOLDS` anywhere. Selftest: rc 0 + exactly one PASS line with
  N ≥ 8. Secret scan over every captured stdout/stderr: no `hvs.`/`hvb.` token shape,
  no `secret_id` value printed as a UUID shape; any hit forces value=0.
- Output: `C2_APPROLE_TRIAL: value=V tests=5 pass=P shims=K vectors=ok|K/5 selftest=S
  guard=G (real= real2= ambient= none= secret= sh1=… sh5=)`; exit 0 iff value=5, 1
  otherwise, 2 SETUP. Absent trial → `value=0 … guard=0 (absent)` rc 1; bad
  revision/tree → `guard=0 (bad-revision|bad-tree)` rc 1; missing tools/scratch, bao
  missing, bao sha256 ≠ pin, or bao present in /usr/bin|/bin → SETUP rc 2. The pin is
  read from `plans/round-57-c2.sh` (`PIN_BAO=9c5f3628…41b788`, OpenBao 2.7.2) so the
  C2-F7 control can drive it via `R60_BAO=` without touching ~/.local/bin.
- Scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r60/R60ExecCounterC2/c2-counter.$$`,
  `umask 077`, TMPDIR inside, `trap rm -rf` on exit, no hardcoded /tmp.

## Behavior delivered (all exercised; receipts cited)

- BASE (no arg): `value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0
  (absent)`, rc 1 — `base-absent.txt`.
- Candidate tree = BASE archive + `corpus/openbao-approle-trial.sh` (lane bytes,
  sha256 `a228e312847adc309e3243a1add74356e4eabb30a3ab50067e77baec6a63e660`):
  `value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1
  ambient=1 none=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB)`,
  rc 0 — `candidate.txt`. The counter ran green against the trial seat's landed bytes
  with zero counter changes after the contract exchange. An earlier identical-green
  reading at trial bytes `bd2d6647…` was superseded when the trial seat landed its
  ST_BASH selftest fix (15:31); the full battery (candidate, ambient, five direct
  shims, none leg) was re-taken serially at the final bytes — all green. R60ExecTrial
  corroborates with independent real runs (`holds=5 broken=0 error=0` ×2), the five
  shim receipts, `--selftest PASS (cases=45)` and a selftest-mutant receipt under
  `.ufo/waves/round-60/build/R60ExecTrial/`.
- Caller-ambient run (same candidate, placeholder BAO_*/VAULT_* exported by the
  caller): identical value=5 line, rc 0 — `ambient.txt`.
- None leg: `OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH`, rc 2, no TRIAL/HOLDS
  lines — `none.txt` (direct trial invocation; the counter re-measures the same leg
  internally, `none=1`).
- Per-shim: counter-measured vectors exactly BHHHH/HBHHH/HHBHH/HHHBH/HHHHB plus
  direct serial runs of the real trial, each flipping exactly its own test, rc 1 —
  `shims.txt`.
- Counter logic fail-closed checks on scratch stubs: a stub whose SH1 flips two tests
  reads `shims=4 vectors=4/5 value=0` rc 1 (C2-F6 shape); `--tree /nonexistent` reads
  `guard=0 (bad-tree)` rc 1 — `stub-logic.txt`.

## Defects found and fixed in my own work (before receipts were taken)

- `selftest_ok` was initialised 0 and never set 1 (`… || selftest_ok=0` idiom on an
  already-zero variable) — caught because the stub-validation run read `selftest=0`
  against a passing selftest; restructured to a positive if.
- `tlines()` ERE `'( |\$)'` in single quotes passed a literal `$` to grep (no EOL
  anchor); fixed to `'( |$)'`. The `verdict()` occurrence is double-quoted (as in the
  r59 counter) so the shell already collapses `\$` → `$`.

## Risks / notes for the integrator

- **Incident (peer impact, disclosed).** At ~15:45–15:47 I deleted my seat scratch
  `/fast/scratch/hyaku/kagi-r60/R60ExecCounterC2` — but the counter's scratch root is
  a seat-name constant, so *every* invocation of the counter by any seat writes there.
  A sibling's live counter run (pid 466787, `--tree <lane>`) died from it, and
  R60MutCounters' in-flight mutant legs from the same window lost their leg logs;
  R60MutCounters/R60ExecControls/R60SentinelTrial were notified to rerun any
  pre-15:47 readings. My own receipts were all taken serially before the deletion and
  are unaffected. I will not touch that namespace again this wave; final cleanup of
  `kagi-r60/R60ExecCounterC2/` belongs to the L1 after all counter runs (mine and the
  battery/mutation legs) are done. Lesson for the house pattern: a counter's scratch
  namespace is shared across all its runners — seat cleanup must be
  integrator-owned, not seat-owned.
- **T3 TTL margin is load-sensitive.** With THREE trial processes running
  concurrently (my own parallel receipt jobs), one SH5 leg read T3 BROKEN
  (`sh5=HHBHB`); the same leg passed on every serial rerun. The counter runs its legs
  serially, so counter readings are unaffected; but any harness that runs
  trial-bearing legs in parallel (e.g. a controls battery) can see spurious T3 flips.
  Suggest R60ExecControls serialise C2 legs.
- K2 (bao resolved through PATH only; absolute-path/shape-keyed forgery) and the
  independence of the two real runs are declared ceilings — receipts + non-author
  probe classes, not counter-checkable; the counter header says so.
- The counter's SETUP guards (`bao-in-/usr/bin|/bin`, sha256 pin, `R60_BAO` override)
  are what C2-F7 needs; I did not run the battery — that is the controls seat.
- Receipts were secret-scanned clean (no `hvs.`/`hvb.`, no secret_id-UUID prints, no
  Cookie/Set-Cookie); placeholder ambient values are non-secret-shaped by design.

## Checks the integrator should run

- `bash plans/round-60-c2.sh` (BASE → absent, rc 1) and
  `bash plans/round-60-c2.sh --tree <candidate tree carrying the trial>` (value=5,
  rc 0) after committing the trial — ~2.5 min serial.
- The pre-freeze battery (`plans/round-60-controls.sh`) over both counters; C2-F1..F8
  shapes above are the expected legs.

SEAT-STATUS: complete

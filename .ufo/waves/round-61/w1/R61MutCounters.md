# R61MutCounters — scoped findings (wave w1, round 61)

Full report with diffs and raw outputs: `.ufo/waves/round-61/build/R61MutCounters/mutants.md`
and `…/raw/mutants/<id>/` (mutant.diff, pristine/mutated detector outputs, sha256 pair).

## What was mutation-tested (copies only; no lane file edited)

| instrument (sha256 probed) | mutants | killed | survived | inconclusive |
|---|---|---|---|---|
| `plans/round-61-c1-check.py` `d525ee28…` | 9 | 9 | 0 | 0 |
| `plans/round-61-c2.sh` `c7d9e272…` | 6 | 4 | 1 | 1 |
| `corpus/openbao-seal-trial.sh` `a3bc8825…` | 5 | 5 | 0 | 0 |
| `plans/round-61-controls.sh` `4239f674…` (probed) | 2 | 2 | 0 | 0 |

`MUTANTS: total=22 killed=20 survived=1 inconclusive=1`

## Calibration findings the L1 should route

1. **C2 guard is vacuous** (survived mutant C2-M6). `guard=1` iff `legs_ran = 1` (always true —
   every mode always runs) and `TRIAL_SHA` is 64 hex (always true). The guard cannot fail, so it
   certifies nothing. Line: `[ "$legs_ran" = 1 ] && printf '%s' "$TRIAL_SHA" | grep -qE
   '^[0-9a-f]{64}$' && guard=1`.
2. **C2 `--selftest` (11 cases) does not cover any of the five scoring conjuncts**: all five
   scoring mutants (one-real-run, drop shim vector, accept stub bao, ignore secret scan, accept
   selftest cases=5) PASS it. It tests helpers only.
3. **Trial `--selftest` (63 cases) does not cover the T-body assertions**: all five trial
   mutants (drop duplicate-share, drop non-persistence, drop 503, accept wrong OTP, drop inmem
   rekey leg) PASS it. Missing cases: T1-nopersist, T2-dup, T3-503, T4-wrong-otp, T5-inmem-405.
   The defect-injection fixtures (`fixtures/defect/*`) are the only kills.
4. **Two C1 I2 defects measured and fixed during the wave** (reported to R61ExecCounterC1):
   `C2_PASS_RE` expected `(N cases)` vs the frozen `(cases=N)`; `_scan_registry_table` split on
   `|` ignoring `\|` (SKILL.md row 855 shifted the selftest column). Final bytes read `i2=1`,
   `--selftest PASS (52 cases)`.
5. **Trial T4 HTTP endpoint defect measured and fixed** (reported to R61ExecTrial):
   `/v1/sys/generate-root` without a token is 403; `/attempt` and `/update` are 405 on this
   build; the working shape is the CLI with `-nonce` + share on stdin `-`, and
   `-decode=<enc> -otp=<otp>` returning JSON `{"token": …}`. Final bytes: T4 HOLDS.
6. **Counter ops witness vs HTTP unseal** (measured, resolved): with the trial unsealing over
   curl, the counter read `ops=0`; the final trial uses `bao operator unseal`, so the witness
   passes.

## Caveats stated, not hidden

- C2-M2's kill was taken on the earlier counter bytes `c9f34d06…`; the final-byte re-run was cut
  when the run budget expired.
- C2-M1 is **inconclusive**, not a survivor: the `second-broken` fixture's marker is consumed by
  the counter's no-bao leg, so both real runs flip; the fixture needs a `command -v bao` guard.
- The battery was probed on `4239f674…`; the file has since moved to `20fd5c6f…`, and the two
  mutated lines (`report_skip`, the summary printf) are unchanged.

SEAT-STATUS: complete

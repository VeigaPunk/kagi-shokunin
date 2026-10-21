# FPolicyRowsRun — C1 executed-row accounting

Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Axes: operability (skip safety), freshness (frozen-code versus inherited receipts), calibration (executed/failed/skipped cardinalities).
Recommendation: bounded PASS for the executed-row counter; FAIL for the universal policy/reporting claims below. No admission or saturation judgment.
LSP unavailable: `read xd://lsp` returned “No such tool”; device inventory also exposes no LSP. References/definitions/diagnostics therefore unavailable; text inspection is not semantic-server proof.

## Findings, by severity

**MEDIUM — FAIL: self-skip bypasses the policy refusal path.** `corpus/claim-ledger.sh:938-941` removes a selected self-invocation before `verify_claims` applies policy at `:509-519`. The same fixture row, `bash -x corpus/claim-ledger.sh --selftest`, is POLICY/bash-option under `verify` (exit 2), but SKIP-SELF/CLEAN under `cells` (exit 0). The rejection definition is `:256-259`; the claim that static policy runs first for EVERY row is `:509-510`. This inherited skip-before-validation ordering survives the reviewed diff. It hides a refused row as a self-skip, rather than inflating `rows_run`; no forbidden command was executed.
Falsifier: the identical selected invalid self row must retain a POLICY refusal/exit 2 in `cells`, before recursion prevention. Probe receipts: `self-policy-verify.stdout`, `self-policy-cells.stdout` below.

**LOW — FAIL of literal host-reporting contract, not execution safety:** the same prefilter also precedes host-note classification (`:167`, `:528-534`). Changing the inert self row's note to `[substrate]` still produces SKIP-SELF, `self_skipped=1 host_skipped=2`, although three selected rows now carry host tags. Current caller `corpus/claim-ledger.tsv:38` (R13-03) is exactly this overlap. Thus `host_skipped` is not a count of every selected host-tagged row, and the unconditional HOST-SKIP wording in `plans/round-24.md:14-16` has an exception. Execution remains zero for that row.
Falsifier: host-tagged self rows receive the claimed HOST-SKIP classification, or reporting explicitly accounts for the self-skip precedence instead of equating host tags with `host_skipped`.

## Observed bounds and controls

- PASS: canonical `verify_claims` resets `C_RUN` at `corpus/claim-ledger.sh:495`, increments only after policy/host/defer branches at `:536`, launches at `:538-539`; `cells_evidence` copies that counter at `:952`, not selected-row count `C_N`.
- PASS: control has two executed rows (one logging script, one source-reader), two HOST-SKIPs, one self-skip, and one uncited row that does not run. `rows_run=2`, not selected count 5 or six score cells.
- PASS: adding an exit-7 mismatch and a one-second timeout gives `rows_run=4 row_failures=2`; both launches remain counted. Markers are exactly `ok,fail,timeout`; the fourth execution is the reader. No host/substrate/self/policy marker appears.
- PASS internally / bounded observability: adding a non-self policy refusal leaves xtrace `C_RUN=4` and the same markers, exit 2. `CELL_AUDIT: POLICY` at `:1125-1128` omits rows_run/deferred/host/self counters; CLEAN/BROKEN at `:1130-1136` expose them. Do not claim a black-box public rows_run assertion for POLICY output.
- STATIC ONLY: DEFER precedes `C_RUN` at `:532-536`; its selftest is `:1587`. Without explicit host authorization, `[substrate]` rows hit HOST-SKIP first, so this permitted probe cannot exercise DEFER. No authorization flag was passed and the full selftest was not executed.
- Relevant regression definitions reviewed: reader `:1583`, host exclusion `:1585`, defer exclusion `:1587`, positive self-skip `:1517`; no new test covers invalid-self or host-tagged-self overlap.
- Freshness bound: committed `tripwire-after.txt:1-5` names revision `735123d53238`, not the frozen revision. It reports zero population executions, complete=4/4, but all four gate runs exit 1; cells reports 11/12 population HOST-SKIPs. It is a bounded safety receipt, not a clean gate or fresh frozen-revision runtime pass. `tripwire-before.txt:5` reports BASE total=35.
- Instrument bound: `.ufo/waves/round-24/tools/host-tripwire.sh:41-55` counts stub command signatures, not arbitrary host reads or independent row identities; `:59-63` separately counts distinct population skip IDs. No full tripwire/harness rerun here.
- C2 recapture and C3 identity-population correctness, resume continuity, and saturation are outside this assigned slice; no passes claimed for them.

## Exact bounded execution and retained evidence

Definitions: `L=/home/vgpnk/Projects/shokunin/kagi-shokunin`; `S=/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyRowsRun-9`; `F=$S/rows-run-fixture`.
Setup, each command exit 0 (clone output “done.”; checkout output “HEAD is now at c5ef9e9 …”):
```sh
env -i PATH=/usr/bin:/bin HOME=$S/home git clone --no-hardlinks $L $S
env -i PATH=/usr/bin:/bin HOME=$S/home mkdir -p $S/home $S/tmp
env -i PATH=/usr/bin:/bin HOME=$S/home git -C $S -c advice.detachedHead=false checkout c5ef9e92201b6c36396301f12b23740565bf86a0
```
Reviewed actual script diff with `env -i PATH=/usr/bin:/bin HOME=$S/home git diff --no-ext-diff --unified=3 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105 c5ef9e92201b6c36396301f12b23740565bf86a0 -- corpus/claim-ledger.sh` (cwd `$S`, exit 0).
One bounded fixture probe, cwd `$S`, exit 0:
```sh
env -i PATH=/usr/bin:/bin HOME=$S/home TMPDIR=$S/tmp python3 rows-run-probe.py
```
The retained driver creates only sandbox fixtures; each child uses env-i-equivalent explicit environment (`PATH`, empty `HOME`, sandbox `TMPDIR`, `KAGI_SUBSTRATE=absent`, sandbox `FIXTURE_LOG`). Fixture-local `corpus/claim-ledger.sh` is an inert logger, never the production selftest. Exact six child argv/environment strings and full stdout are retained in `$F/results.json`; individual stdout/trace/launch logs use the case names below.

| Case | Exit | Exact final stdout line |
|---|---:|---|
| control | 0 | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=1 orphans=1 host_skipped=2)` |
| launched-failures | 1 | `CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=4 row_deferred=0 row_failures=2 stale_pointers=0 self_skipped=1 orphans=1 host_skipped=2)` |
| policy-refused | 2 | `CELL_AUDIT: POLICY (cells=6 row_pointed=6 stamp_pointed=0 policy=1)` |
| host-self-overlap | 0 | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=1 orphans=1 host_skipped=2)` |
| self-policy-verify | 2 | `CLAIM_LEDGER: POLICY (claims=6 policy=1 stamped=1)` |
| self-policy-cells | 0 | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=1 orphans=1 host_skipped=2)` |

Only this report was written in the lane. No production/index/fleet changes, host-private gate, account/handler/CDP operation, package install, service/config change, background job, or delegated work. No tools installed or updated.

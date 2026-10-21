# C1 probe — `rows_run` accounting

## Result

BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` counts selected rows before either `DEFER` or `POLICY` can skip command execution. In a hermetic cells fixture, one deferred row made `rows_run=3` although only two commands launched. Adding a cited policy-refused row made the internal count `4` for those same two launches; `cells` correctly returned policy exit 2, but its POLICY summary omits `rows_run`.

## Scratch experiment

Cloned the specified BASE to `/fast/scratch/kagi-r24/seats/ProbeRowsRun` with `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/ProbeRowsRun && git -C /fast/scratch/kagi-r24/seats/ProbeRowsRun checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`; exit 0. Edited only the clone's hermetic fixture: added R90-03, `bash corpus/fx-ok.sh ... [substrate]`, and cited it at `SCORECARD.md:8` (`claims.tsv:3`).

From the clone root, ran:

```sh
mkdir -p /fast/scratch/kagi-r24/seats/ProbeRowsRun/home /fast/scratch/kagi-r24/seats/ProbeRowsRun/tmp
# Then:
env HOME=/fast/scratch/kagi-r24/seats/ProbeRowsRun/home TMPDIR=/fast/scratch/kagi-r24/seats/ProbeRowsRun/tmp KAGI_SUBSTRATE=absent bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims corpus/fixtures/cells-hermetic/claims.tsv --stamps corpus/fixtures/cells-hermetic/stamps.tsv --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md --docs corpus/fixtures/cells-hermetic/SCORECARD.md
```

Cells exit 0. Retained output (`/fast/scratch/kagi-r24/seats/ProbeRowsRun/deferred.stdout:1-2`):

```text
DEFER R90-03 reason=substrate-absent
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=3 row_deferred=1 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
```

Then added R90-04, `echo policy-refusal ...`, and cited it on the same scorecard row (`claims.tsv:4`, `SCORECARD.md:8`). Repeated the same command under `bash -x`, redirecting stdout/stderr to the clone's `policy.stdout`/`policy.trace`; captured the cells process status before the wrapper exited. Cells exit 2. Output (`policy.stdout:1-3`):

```text
DEFER R90-03 reason=substrate-absent
POLICY R90-04 reason=first-token:echo
CELL_AUDIT: POLICY (cells=6 row_pointed=6 stamp_pointed=1 policy=1)
```

The xtrace confirms exactly two allowed subprocess launches (`policy.trace:3404,3503`), while `C_N` reached 3 before the defer (`3581`), then 4 before policy (`3656`); `C_DEFER=1` (`3587`), `C_POLICY=1` (`3666`), `CL_ROWS_RUN=4` (`3674`), followed by the POLICY summary and `exit 2` (`3716-3717`). The deferred and refused commands were not launched. HOME and TMPDIR were scratch-only; `KAGI_SUBSTRATE=absent` was explicit. No host command or network access was needed.

## Source and recommendation

BASE `corpus/claim-ledger.sh:415-418` increments `C_N` before the DEFER branch; `:420-423` increments it before continuing on POLICY; `:425-427` is the actual command-launch path; `:828` assigns `CL_ROWS_RUN=$C_N`. Therefore `rows_run` currently means selected claim rows, not executed rows. `:1001-1004` emits a POLICY verdict and exit 2 without `rows_run`; CLEAN/BROKEN summaries at `:1006-1012` expose it.

Define `rows_run` as selected rows whose command subprocess is launched: initialize a dedicated run counter with the other claim counters and increment immediately before the `timeout … bash -o pipefail -c` invocation, after DEFER/POLICY skips. This includes a launched command that later fails or times out; it excludes deferred, policy-refused, and self-skipped rows. Assign `CL_ROWS_RUN` from that counter, not `C_N`.

Suggested `tcase` expectations:

- **Deferred row:** with the two existing fixture commands plus cited R90-03 and `KAGI_SUBSTRATE=absent`, exit 0; assert the CLEAN summary has `rows_run=2 row_deferred=1 row_failures=0` (the observed BASE output above is the failing expectation: `rows_run=3`). In the selftest's one-executed-row variant, pin `rows_run=1 row_deferred=1` and exit 0.
- **Policy refusal:** with the same two launchable rows, the deferred row, and cited R90-04, keep exit 2 and `policy=1`. The current POLICY summary has no rows_run field, so an ordinary `tcase` cannot assert policy exclusion there. To pin the count black-box, extend that summary with `rows_run` and `row_deferred`, then use `tcase_last` expecting `CELL_AUDIT: POLICY (cells=6 row_pointed=6 stamp_pointed=1 rows_run=2 row_deferred=1 policy=1)` with expected exit 2. If preserving POLICY output is required, the exit/policy tcase can remain, but only the CLEAN/BROKEN path directly asserts the public rows_run value.

## Scope

No files in the lane were edited except this advisory report. The scratch clone contains only the probe fixture edits and retained stdout/xtrace evidence. No tools were installed; no selftest, build, lint, or formatter was run.
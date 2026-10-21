# FPolicySkipSelf — round 24 fresh falsification

Axes: operability (whether the selected row is executed), freshness (frozen source vs. prior receipts), calibration (whether `self_skipped` means a real self-invocation).

Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`. Lane `git rev-parse HEAD` returned the frozen revision (exit 0).

## Finding — MEDIUM: `SKIP-SELF` trusts the command spelling, not the resolved target

`corpus/claim-ledger.sh:196-212` tokenizes and normalizes the command text; `cells_evidence` at `:930-942` skips whenever that text parses to `bash corpus/claim-ledger.sh`. It never resolves `$ROOT/$INV_SCRIPT` or confirms that the target is this gate. Thus a fixture root with no `corpus/claim-ledger.sh` produces a false self-skip and can report CLEAN without running the cited command. The supported `cells --root` fixture path makes this observable; this does not establish the same failure for the default lane root.

The selftest does not falsify this: setup `:1337` puts only `cells_evidence\n` in `$R/corpus/claim-ledger.sh`; `cells-self-row-skip` at `:1517` still expects `SKIP-SELF` for a `bash corpus/claim-ledger.sh --selftest` row. The new reader regression at `:1338,1582-83` does correctly pin a reader as `rows_run=1 self_skipped=0`.

### Isolated probe (all executions `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/.home`)

Clone/checkout command: `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/repo && git -C /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/repo checkout -q c5ef9e92201b6c36396301f12b23740565bf86a0 && git -C /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/repo rev-parse HEAD` → exit 0, frozen revision.

Reader + real-gate control: `bash corpus/claim-ledger.sh cells --root /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/actual --claims /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/actual/claims.tsv --stamps /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/actual/stamps.tsv --scorecard /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/actual/SCORECARD.md --docs /fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/actual/SCORECARD.md` (from the cloned repo) → exit 0; `SKIP-SELF R90-04`; `CELL_AUDIT: CLEAN (... rows_run=1 ... self_skipped=1 ... host_skipped=0)`. R90-03 `grep -c cells_evidence corpus/claim-ledger.sh` ran; R90-04 targeted an actual copy of the frozen gate.

Missing-target counterexample: same command/flags with `--root`, `--claims`, `--stamps`, `--scorecard`, and `--docs` replaced by `/fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9/missing` equivalents → exit 0; `SKIP-SELF R90-05`; `CELL_AUDIT: CLEAN (... rows_run=0 ... self_skipped=1 ... host_skipped=0)`. That fixture intentionally has no `corpus/claim-ledger.sh`. Direct row command from that root, `bash corpus/claim-ledger.sh --selftest`, returned 127 with `bash: corpus/claim-ledger.sh: No such file or directory`. This is a concrete false positive, not the old reader false positive.

Falsifier for a correction: repeat the missing-target fixture; it must not emit `SKIP-SELF`/CLEAN with `rows_run=0` (it should be attempted and fail, or be explicitly refused). Keep the actual-target invocation as the positive control and the reader case as the negative control.

## Verified bounds, residual risk, gaps

The original ProbeSkipSelf BASE receipt records the old substring bug. On frozen `c5ef…`, the reader/control probe above shows that regression fixed: reader runs; a real gate invocation is skipped. The remaining finding is target identity under a non-default `--root`.

Host-tripwire receipts read: `tripwire-before.txt` records BASE total 35 (`verify_absent=1`, `verify_present=22`, `cells_absent=1`, `cells_present=11`); `tripwire-after.txt` records total 0 and 4/4 runs with no host scripts, but is labeled `rev=735123d53238`, not frozen `c5ef…`. Therefore a fresh C1 host-tripwire result for the frozen revision is UNKNOWN; no real-lane verifier/cells or host/private gate was run.

LSP unavailable: `read xd://lsp` returned “No such tool” and no LSP device was mounted; semantic references/definitions/diagnostics could not be requested. No grep result is used as semantic proof. No tools installed; no production code edited. Probe changes were confined to `/fast/scratch/kagi-r24-recovery/FPolicySkipSelf-9`.

# FIncompleteReceipt — verify row classification

## Verdict
- **Axes:** calibration (truth of verdict attribution), operability (actionable failure output), freshness (frozen candidate identity).
- **Candidate:** `82745e2c60e726b49499b8f309529935dc4eff2b`; **BASE:** `4587c61a348e4528717404a68912c373f3ef4d03`.
- **Finding:** generic `exit=3` classification is overly broad for diagnostics (P2); with the tested expected exit `0`, it does **not** falsely return CLEAN.

## Evidence
- Clone/checkout argv: `mkdir -p /fast/scratch/kagi-r25/FIncompleteReceipt/home && git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r25/FIncompleteReceipt/lane && git -C /fast/scratch/kagi-r25/FIncompleteReceipt/lane checkout -q 82745e2c60e726b49499b8f309529935dc4eff2b && git -C /fast/scratch/kagi-r25/FIncompleteReceipt/lane rev-parse HEAD` — exit **0**, stdout `82745e2c60e726b49499b8f309529935dc4eff2b`.
- Reviewed frozen diff: `git -C /fast/scratch/kagi-r25/FIncompleteReceipt/lane diff --unified=3 4587c61a348e4528717404a68912c373f3ef4d03 82745e2c60e726b49499b8f309529935dc4eff2b -- corpus/claim-ledger.sh` — exit **0**. The added branch (`corpus/claim-ledger.sh:600-609`) accepts any final nonblank line matching `^[A-Z_]+: INCOMPLETE \(` when `rc=3` and expected exit is not 3, then prints a fleet-layout cause. `:1222-1225` makes that outcome exit 1, not CLEAN.
- Synthetic root: `/fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root`; one pinned `corpus/pin.txt`, one explicit `docs.md`, one claim row per run, and `stamps.tsv`. No production files, real-tree gates, host facts, or network were used. Stubs are registered in the one-row claims fixtures as `bash corpus/<stub>.sh`, expected exit `0`, expected final line `^UNEXPECTED_PASS$`.

### PASS — intended citation-shaped incomplete output does not CLEAN
- Stub output: `CITATION_GATE: INCOMPLETE (synthetic fixture)`; stub exits **3**.
- Exact verify argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FIncompleteReceipt/home bash /fast/scratch/kagi-r25/FIncompleteReceipt/lane/corpus/claim-ledger.sh verify --root /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root --claims /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/claims-incomplete.tsv --stamps /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/stamps.tsv --docs /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/docs.md`
- Stdout: `LAYOUT-INCOMPLETE R99-01 exit=3 (fleet layout absent: the row could not check fleet-only evidence)`; `CLAIM_LEDGER: INCOMPLETE (claims=1 layout_incomplete=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`.
- Verify exit **1** (`EXIT=1` capture); wrapper exit **0**. PASS: expected classification and never CLEAN.

### PASS — unrelated terminal output remains an exit mismatch
- Stub output: `ARBITRARY: FAILURE (unrelated fixture)`; stub exits **3**.
- Exact verify argv: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FIncompleteReceipt/home bash /fast/scratch/kagi-r25/FIncompleteReceipt/lane/corpus/claim-ledger.sh verify --root /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root --claims /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/claims-unrelated.tsv --stamps /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/stamps.tsv --docs /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/docs.md`
- Stdout: `FAIL R99-01 reason=exit-mismatch exit=3 want=0`; `CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0 stamped=1 stale=0 missing=0 unresolved_ids=0 labeled_ids=0 host_skipped=0)`.
- Verify exit **1** (`EXIT=1` capture); wrapper exit **0**. PASS: no CLEAN.

### FAIL — non-layout `INCOMPLETE` is misreported as missing fleet layout
- A third stub returned **3** with terminal `SYNTHETIC_CHECK: INCOMPLETE (business precondition failed; no layout claim)`. Exact argv was the first command above with `--claims /fast/scratch/kagi-r25/FIncompleteReceipt/lane-probe/root/claims-nonlayout.tsv` substituted; all other argv was identical.
- Stdout again said `LAYOUT-INCOMPLETE R99-01 exit=3 (fleet layout absent: the row could not check fleet-only evidence)` and `CLAIM_LEDGER: INCOMPLETE (claims=1 layout_incomplete=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`; verify exit **1** (`EXIT=1` capture), wrapper exit **0**.
- Concrete defect: the `[A-Z_]+` label matcher at `corpus/claim-ledger.sh:606` does not establish that the command was the citations gate or that the failure was layout-related. It converts a non-layout check failure into a false cause and suppresses the ordinary `FAIL ... exit-mismatch` row. The R11-08 registered caller is specifically `bash corpus/claim-ledger.sh citations` (`corpus/claim-ledger.tsv:22`); selftests exercise intended lone-layout and fleet cases (`corpus/claim-ledger.sh:1784-1786`) but no non-layout `INCOMPLETE` negative control. Constrain the classification to evidence identifying the citations-gate result (or otherwise make the cause explicit).

## Limits / verification gaps
- `xd://lsp` returned “No such tool”; LSP status, references, definition, and diagnostics are **UNRUN**. Text grep was only a literal fallback, not semantic proof.
- Full `verify`, `citations`, `cells`, and overall wave claims are **UNRUN** as required by lane bounds. This isolates verifier classification; it does not establish the full lone-clone output or adjudicate C1/C3.
- No tools installed or updated.

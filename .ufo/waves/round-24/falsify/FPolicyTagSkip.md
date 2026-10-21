# FPolicyTagSkip — round-24 C1 falsification

Axes: operability, freshness, calibration.

## Findings (severity order)

### MEDIUM — default `verify` still admits an outside-root citation probe

`host_free_args()` classifies `bash corpus/claim-ledger.sh citations` as host-free (`corpus/claim-ledger.sh:174,183-184,217-221`). The live untagged R11-08 row is exactly that command, and its note says it requires the fleet checkout (`corpus/claim-ledger.tsv:22`). `citations` resolves `.ufo/*`, `ufo/*`, and sibling paths through `$ROOT/../.ufo` / `$ROOT/../$t` existence checks (`claim-ledger.sh:591-600`), then runs those checks while scanning docs (`:648-700`). Default `verify` reaches the command-launch path for rows not refused/skipped (`:536-539`). This probes filesystem metadata outside the lane even though the row is not one of the 12 frozen host IDs. It does not establish that outside file contents are opened.

The zero tripwire total is bounded to its frozen command population and stub list (`.ufo/waves/round-24/tools/host-tripwire.sh:41-55`); it does not instrument `claim-ledger.sh citations`. Thus it cannot establish a no-outside-root-read claim for all default `verify` behavior.

### LOW — “all 12 HOST-SKIPped” is false for `cells` (though no host execution is observed)

`tripwire-after.txt:1-5` records verify absent/present as 12/12 population skips and zero host commands executed; cells absent/present record only 11/12 HOST-SKIP lines, zero host commands executed, and `rows_run=32`. `verify-final.txt:1-12,33` separately shows 12 HOST-SKIP IDs. `R13-03` is itself a tagged `bash corpus/claim-ledger.sh cells` row (`claim-ledger.tsv:38`); `cells_evidence()` detects that invocation and emits `SKIP-SELF` before calling `verify_claims` (`claim-ledger.sh:930-942`), so it cannot emit HOST-SKIP there. The scorecard claim that all 12 IDs are HOST-SKIPped (`SCORECARD.md:882`) overstates diagnostic coverage; `cells` does not run R13-03, so this is not evidence of host execution.

## Rows-run/accounting and controls

Current source increments `C_RUN` only after policy refusal, host skip, and substrate deferral (`claim-ledger.sh:511-539`); `cells_evidence()` assigns `rows_run` from that counter (`:950-952`). New selftests define a present-substrate default-skip control, an environment-not-consent negative, a cells control with one ordinary row plus one host skip, and an absent-substrate rows-run/defer assertion (`:1569-1572,1584-1587`). The cells policy-error summary omits `rows_run` (`:1125-1128`), so its value is not externally asserted on that error path.

Existing tripwire evidence (`tripwire-after.txt`) reports complete=4/4 and zero population commands launched for both substrate states, but its recorded revision is `735123d53238`, not the assignment's frozen `c5fe9e92201b6c36396301f12b23740565bf86a0`; `verify-final.txt` reports 12 skips while the tripwire summary reports 13 verify `host_skip_lines`/`host_skipped`, with no revision on that file. Treat that discrepancy as unresolved, not as a current frozen-revision pass. `ProbeRowsRun.md` is a BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` counterexample; it is not a run of the current source.

## Verification limits

Requested revision: `c5fe9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`. Scratch clone succeeded, but `git checkout c5fe9e92201b6c36396301f12b23740565bf86a0` failed (exit 128: `fatal: unable to read tree (c5fe9e92201b6c36396301f12b23740565bf86a0)`). No gate/selftest or fixture probe was run by this seat; consequently source findings are not authenticated against that frozen revision and control cases are test definitions, not fresh passes. No host/private paths were read, no `--allow-host-rows` invocation or code edit was made. LSP unavailable (`read xd://lsp`: “No such tool”; no semantic references/definition/diagnostics were available).
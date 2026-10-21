# FPolicyUntagged — C1 untagged-host refusal

## Identity and method
- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0` (`git rev-parse HEAD`). BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- LSP route unavailable in the exposed tools; source reads and literal `grep` were used, not semantic proof.
- Scratch clone: `/fast/scratch/kagi-r24-recovery/KagiR24-2.FPolicyUntagged-9`, cloned with `git clone --no-hardlinks ...` and checked out at the frozen revision. All executions used `env -i PATH=/usr/bin:/bin`, HOME inside the sandbox, and only an inert `corpus/drift-pins.sh` stub; no host/private gate or `--allow-host-rows` was run.
- One runtime only: `/usr/bin/bash`; this gate has no alternate runtime/identity reroute surface in scope.

## Findings (severity order)

### HIGH — Bash glob expansion bypasses the untagged-host refusal
`HOST_SCRIPT_RE` names `corpus/drift-pins.sh` (claim-ledger.sh:174), but `invoked_script()` compares the raw parsed word without shell glob expansion (196–210); `META_RE` excludes `?`, `*`, and bracket patterns (238). `host_invocation()` relies on that lexical result (217–221), and `verify_claims()` refuses only when it matches (516–519); the row is then run by `bash -c` after `cd "$ROOT"` (538–539). Round-24 selftests cover literal/slash/quote/`-x` forms but no glob form (1332–1334, 1573–1576).

Scratch fixture probe, with `corpus/drift-pins.sh` printing only `STUB_RAN` and the row expecting that exact output:
- Direct control row `bash corpus/drift-pins.sh`: exit 2; `POLICY R1-01 reason=untagged-host script=corpus/drift-pins.sh`; `CLAIM_LEDGER: POLICY (claims=1 policy=1 stamped=1)`.
- Declared host-free spelling `bash corpus/drift-pins.sh --selftest`: exit 0; `CLAIM_LEDGER: CLEAN (claims=1 deferred=0 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1 host_skipped=0)`.
- Untagged probe `bash corpus/drift-pin?.sh`: exit 0; same CLEAN summary. The exact expected `STUB_RAN` row passed, so Bash expanded `?` to `s` and ran the stub without POLICY. [INFERENCE] With the repo as `ROOT`, the same word expands to the declared real `corpus/drift-pins.sh`; no real host script was run.

This falsifies the unqualified refusal claim for a direct invocation of a declared host script. Reject/normalize glob syntax before execution or otherwise match the expanded target.

### MEDIUM — the `cells` host-free exception is a prefix, not a proven argument vector
`host_free_args()` accepts any suffix after `cells --root corpus/fixtures/` (claim-ledger.sh:183–184). `ProbeHostEvasion.md:19` records an untagged invocation with an added `--scorecard` being allowed and running a stub. The same prefix also lexically accepts appended `--allow-host-rows`; that escalation was not run here, so the proven gap is the non-exact argument vector, not a demonstrated host execution.


## Residual risk and verification gaps
- `tripwire-before.txt` reports BASE total 35; `tripwire-after.txt` reports total 0 on `rev=735123d53238` (4/4 runs, verify 12/12 skipped, cells 11/12). Those receipts support the frozen population only; they do not cover glob spellings or validate the host-free exceptions, and the after receipt is not the frozen `c5ef9e9` identity.
- `ProbeHostEvasion.md:25` bounds the name-based check further: copied scripts/wrappers under new names are not identified by path matching. The current symlink check (claim-ledger.sh:523–526) does not establish semantic identity for ordinary copies or wrappers.
- Only the assigned fixture rows were executed; the full selftest and all host modes were not run. No production files were edited and no tool was installed.

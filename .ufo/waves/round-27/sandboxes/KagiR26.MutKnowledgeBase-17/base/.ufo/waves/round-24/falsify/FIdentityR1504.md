# FIdentityR1504 — fresh scoped review

Axes: operability (isolated execution), freshness (frozen-tree run), calibration (cardinality versus membership).
Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
Sandbox: `/fast/scratch/kagi-r24-recovery/FIdentityR1504`; `HOME` and `TMPDIR` are private sandbox directories.

## Findings by severity

No actionable finding against the assigned R15-04 mutant: **VALID KILLED** on the frozen revision. This result covers R15-04 only, not the other fourteen C3 population members or global saturation.

## Fresh bounded experiment

Setup cloned the lane with `git clone --no-hardlinks` and checked out `c5ef9e92201b6c36396301f12b23740565bf86a0` in the sandbox; clone/checkout exited 0. `git rev-parse HEAD` in that clone printed the full revision above. All target commands ran with `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home TMPDIR=<sandbox>/tmp LANG=C.UTF-8`.

`claim-ledger.tsv:36` (R15-04) counts lines matching `^[EH][0-9]+[[:space:]]` and expects `16`; its note names E1-E8 and H1-H8. The frozen checklist at `corpus/checklist.tsv:26-41` has exactly those sixteen first-column IDs. `claim-ledger.tsv:71` (R24-08) expects the `checklist-ids` selector at `row-identity.sh:91-94` to return count 16 and SHA-256 `d892ba936daeb1e346e7e0aa4d2d8761523154172cc43bd93bfb74541df6652f`.

Pristine commands/results (exit 0):
- `grep -cE '^[EH][0-9]+[[:space:]]' corpus/checklist.tsv` → stdout `16`.
- `bash corpus/row-identity.sh checklist-ids` → `ROW_IDENTITY: checklist-ids count=16 sha256=d892ba936daeb1e346e7e0aa4d2d8761523154172cc43bd93bfb74541df6652f`.

I imported the frozen `identity-swap.py` definitions without calling `main`, selected only its R15-04 mutation, and called it once. The exact mutant is `E1` → `E91` in column 1; the rest of that row is unchanged. The mutation call exited 0 with no stdout. Sandbox `git diff -- corpus/checklist.tsv corpus/stamps.tsv` showed only that one ID replacement and the corresponding `corpus/checklist.tsv` stamp update; no unrelated files or stamp rows changed.

Mutant commands/results (both exit 0):
- R15-04 count command → stdout `16` (old count preserved).
- `bash corpus/row-identity.sh checklist-ids` → `ROW_IDENTITY: checklist-ids count=16 sha256=b61125f0c42f2f0009edbf6c4c7809b796ae8b460366228cee8502fa107af3b3` (membership digest changed).

The updated stamp is SHA-256 `3bb1ed902ccdbdecaf3940f22f0aa22c5fa727d8c33cae60151c937298553e5a`, 40 LF lines, 11695 bytes; independent `sha256sum`/`wc -l -c` matched it. Thus R24-08's failure is the pinned identity digest, not stale-stamp drift. In a two-row `claim-ledger.sh verify --claims <sandbox>/claims-r15.tsv --stamps corpus/stamps.tsv` check, the pristine summary had `failed=0 stale=0`; the mutant emitted `FAIL R24-08 reason=verdict-not-final exit=0` and summary `failed=1 stale=0`. This is the identity kill while R15-04 remains green.

## Residual risk and verification gaps

- The two-row `verify` command exited 1 in both phases because this deliberately incomplete claims file leaves `unresolved_ids=514 labeled_ids=56`; it is not a whole-ledger clean run. Its stamp counts were `stamped=83 stale=0 missing=0` in both phases. The row-specific direct controls and mutant output above are the evidence used; no full harness or other population row was run.
- `identity-swap.py:180-187` discards the verifier process return code and classifies from `FAIL`/`POLICY` lines. This run did not misclassify R15-04, but its archived `control_failing=-` alone is not proof that the enclosing verifier exited 0; non-row diagnostics must remain distinguished from row outcomes.
- Historical receipts are not this frozen-run evidence: `identity-before-v2.txt:6` is BASE `4f94b52a3cdf` SURVIVES; `identity-after.txt:6` records `6c23a56dea0f` KILLED by R24-08. `build/IdentR1504.md` describes a different BASE mutation (E8→E9); it does not replace this fresh E1→E91 run.
- No LSP device is mounted (`xd://lsp` returned `No such tool`); references/definition/diagnostics were unavailable. Grep was used only to locate exact rows; source reads and bounded executions provide the evidence. No tools installed or updated; production remained read-only.

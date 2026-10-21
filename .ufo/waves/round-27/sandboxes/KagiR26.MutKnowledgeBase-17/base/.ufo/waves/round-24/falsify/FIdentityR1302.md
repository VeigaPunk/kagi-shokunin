# FIdentityR1302 — C3 / R13-02

## Result
- Axes: operability, freshness, calibration. This assignment exercises calibration only; C1/C2 were not retested.
- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- No actionable R13-02 survivor: on the frozen revision, the assigned count-preserving identity swap is caught by identity rows, not by stamp drift. The scoped result is **KILLED**; control qualification below limits the strength of the green-control claim.

## Exact scope and evidence
- Read `plans/round-24.md`, `corpus/claim-ledger.tsv`, `corpus/row-identity.sh`, `.ufo/waves/round-24/tools/identity-swap.py`, the located receipts `.ufo/waves/round-24/identity-before-v2.txt` and `.ufo/waves/round-24/identity-after.txt`, and `.ufo/waves/round-24/build/IdentR1302.md`. The requested baseline receipt is at round-24 root, not under `tools/`; the named build report exists.
- `identity-before-v2.txt` is BASE `4f94b52a3cdf…`; `identity-after.txt` is `6c23a56dea0f…`. Neither is the frozen `c5ef…` run; the following scoped experiment was independently run at the frozen revision.
- Scratch only: `/fast/scratch/kagi-r24-recovery/FIdentityR1302/{repo,mutant}`, created by `git clone --no-hardlinks` and checked out at the frozen revision; HOME was the empty scratch `home` directory and commands used `env -i PATH=/usr/bin:/bin`. No production files changed.
- `bash corpus/row-identity.sh ledger-r1` on pristine: `ROW_IDENTITY: ledger-r1 count=35 sha256=7cac266074eeae54e767873e5c684bab7dbbf5699f4f0103d58bcf2ebc3064bb` (exit 0). R24-07 pins that exact projection. The R13-02 note says 35 R1x IDs; its command `grep -c '^R1' corpus/claim-ledger.tsv` returned `35` (exit 0), agreeing with the selector count on the current ledger.
- Applied only the `R13-02` entry from `identity-swap.py`: `R17-03` → `R19-03` in the ID field; helper re-stamped `corpus/claim-ledger.tsv`. Both IDs remain in the `^R1` population, so the R13-02 count stays 35 while membership changes.
- Mutant selector: `ROW_IDENTITY: ledger-r1 count=35 sha256=f4680794de7ac5b2858de3b2238fdcfb19c5402666daa5bf7139f75054964e6d` (exit 0), different from the pinned digest. Mutant `grep -c '^R1' corpus/claim-ledger.tsv` returned `35` (exit 0).

## Control and single-mutant verification
- Control subset comprised R13-02, other non-host rows naming `corpus/claim-ledger.tsv`, and R24-01..R24-16 (19 rows). Command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FIdentityR1302/home timeout -k 5 900 bash corpus/claim-ledger.sh verify --claims /fast/scratch/kagi-r24-recovery/FIdentityR1302/control.tsv --stamps corpus/stamps.tsv`. Exit **1**; summary: `CLAIM_LEDGER: FAIL (claims=19 failed=0 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=483 labeled_ids=55 host_skipped=0)`. Thus selected rows are pristine (`failed=0`), but this is not a globally clean verifier exit; the clone has unrelated unresolved/labeled document IDs.
- Mutant ran the same command with `--claims /fast/scratch/kagi-r24-recovery/FIdentityR1302/mutant-claims.tsv`. Exit **1**; the only row failures were `FAIL R24-07 reason=verdict-not-final exit=0` and `FAIL R24-14 reason=verdict-not-final exit=0`; summary had `claims=19 failed=2`, `stale=0`, `missing=0`, and the same `unresolved_ids=483 labeled_ids=55`. R13-02's expected 35 still passes. R24-07 is the exact ledger-R1 identity binding; R24-14 is the all-ledger-ID identity binding. No stamp row failed and no stamp drift was reported.
- Therefore the control is clean at the selected-row level, not at the whole-command level. The mutator's row-level kill is explicit and not attributable to stamp drift; the overall exit 1 is shared baseline document-audit noise.

## Residual risk / verification gaps
- `identity-swap.py` labels controls by parsing `FAIL|POLICY <id>` rows, not by requiring subprocess exit 0. Here that yields no control row failures despite `CLAIM_LEDGER: FAIL`; report the control as row-scoped, not globally green.
- The note's `^R1` count and `ledger-r1` projection agree on the observed valid 35-row ledger. The selector projects syntactically shaped IDs (`^R1[0-9]*-[0-9]+$`); this check does not establish correspondence for malformed future ledger rows.
- LSP device unavailable: `read xd://lsp` returned “No such tool.” No LSP references/definition/diagnostics were available; grep was used only as the exact R13-02 runtime count command, not as semantic proof.
- No tools installed or updated. No full 15-row harness, host row, `--allow-host-rows`, or real-lane gate was run.

Report: .ufo/waves/round-24/falsify/FIdentityR1302.md

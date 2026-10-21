# R17-02 scoped falsification

Revision tested: `c5ef9e92201b6c36396301f12b23740565bf86a0`; frozen BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.

## Findings (by severity)

- None for assigned row R17-02: the fresh, count-preserving identity swap is killed by R24-12, not by stamp drift.

## Evidence

- `plans/round-24.md:51-61` defines C3 as membership-bound count claims. `corpus/claim-ledger.tsv:46` (R17-02) expects four breadth pins; `:75` (R24-12) pins the four `# breadth` lines, including `children`/`declared` values. `corpus/row-identity.sh:107-110` selects full `# breadth` lines. `corpus/adjacency.tsv:75-78` contains exactly four such records, and all four also match R17-02's count command. The documented note population and current digest projection therefore agree; the digest covers the complete records, not paths alone.
- LSP status was attempted first (`read xd://lsp`); the tool returned `No such tool`, so no LSP server was available for references/definition/diagnostics. I read the named sources directly; no grep result is used as semantic proof.
- Scratch-only setup: `git clone -q --no-hardlinks --no-checkout /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/FIdentityR1702/tree`, then `git -C .../tree checkout -q --detach c5ef9e92201b6c36396301f12b23740565bf86a0`; `git rev-parse HEAD` returned that exact revision. Commands ran under `env -i PATH=/usr/bin:/bin` with `HOME` and `TMPDIR` in the unique sandbox.
- I loaded the cloned `identity-swap.py` helpers, selected only its `R17-02` mutation tuple, and ran its `subset`/`evaluate` control, then that one mutation and the same evaluation. No 15-mutant loop/full harness ran. Evaluated IDs were `R16-04,R16-05,R16-06,R17-02,R17-03,R24-01..R24-16` (21 claims).
- Pristine selector: `bash corpus/row-identity.sh adjacency-breadth` → exit 0, `ROW_IDENTITY: adjacency-breadth count=4 sha256=2953746decc0a1ab765f77d2f507a1b0111c75715aa17f65eecfc0bcf899be5d`.
- The single mutant changed `$HOME/.config/opencode` to `$HOME/zz-.config/opencode`; it retained four breadth records and restamped `corpus/adjacency.tsv`. Mutant selector → exit 0, `ROW_IDENTITY: adjacency-breadth count=4 sha256=871bf85f4efb4638db672747f23d185e51b8d2128443e86d53f6a2ecdf4b32b9`.
- Control row failures: `-`; R17-02 still passed after mutation; mutant row failures: `R24-12`; result `KILLED`. Mutant verifier output identified `FAIL R24-12 reason=verdict-not-final exit=0`; the targeted subset summary had `stale=0 missing=0`, so this was not stamp drift.

## Residual risk / verification gaps

- The `verify` subprocess exited 1 on both pristine and mutant runs: pristine summary was `CLAIM_LEDGER: FAIL (claims=21 failed=0 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=480 labeled_ids=55 host_skipped=0)`. Thus the control is clean for evaluated claim rows, not a globally successful ledger run. `identity-swap.py:evaluate` classifies parsed `FAIL`/`POLICY` rows and does not use the subprocess exit code; do not present this as a whole-gate pass.
- `build/IdentR1702.md` records an earlier path-only digest proposal and an unverified full-set restamp timeout. The committed R24-12 projection is instead the full-line digest described by its ledger note; this fresh focused run confirms its R17-02 result at the frozen lane revision.
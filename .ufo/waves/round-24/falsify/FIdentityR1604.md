# R16-04 identity-bound count probe

**Result: KILLED (row-scoped), not SURVIVES or INVALID-MUTANT. Severity: no actionable C3 defect for this assigned mutant.** The pristine selected rows have zero `FAIL`/`POLICY`; after the one count-preserving mutation, the only selected row failure is R24-09. Caveat: the subset `verify` process exits 1 in both runs because its document scan reports 480 unresolved IDs; see below. This is not a full-ledger CLEAN result.

## Frozen scope and membership

- Frozen revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; round-24 BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (`plans/round-24.md:51-62`). The only population row probed here is R16-04.
- `corpus/claim-ledger.tsv:42` expects count 5 and names the five prefixes: `$HOME/.config/the-janitor`, `$HOME/.local/bin/the-janitor`, `$HOME/.local/bin/tac-check`, `$HOME/.local/state/the-janitor`, `$HOME/.local/state/tac`.
- `row-identity.sh:95-98` hashes the full five `# own` directive lines, matching that membership. Pristine selector: `ROW_IDENTITY: adjacency-own count=5 sha256=79c248359430739ae757661c0a7cc42637fc8527e4e98f0f1503a916d8cec5c7`.
- The assigned `identity-swap.py:144` mutant changes the first key to `$HOME/zz-.config/the-janitor`. The other four remain unchanged. It preserves exactly five lines matching R16-04's command; membership differs. The selector becomes `count=5 sha256=e8f17def0681940c77edf1ea0fdb65e24c36e40cd8e8c0ab169d2eecafab840b`.

## Isolated execution and results

- Created `/fast/scratch/kagi-r24-recovery/FIdentityR1604/tree` with `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin .../tree`, then `git -C .../tree checkout --detach c5ef9e92201b6c36396301f12b23740565bf86a0`. `rev-parse HEAD` returned that full frozen revision. Commands ran with `env -i PATH=/usr/bin:/bin` and sandbox HOME.
- Ran only the R16-04 function from `identity-swap.py`, using its own `subset()`/`evaluate()` for pristine and one mutant (not `main()`, which runs all 15). Selected 21 rows: R16-04, four other non-host rows naming adjacency.tsv, and R24-01..R24-16.
- Probe stdout: `CONTROL_R16_04_COUNT=5`; `CONTROL_IDENTITY=ROW_IDENTITY: adjacency-own count=5 sha256=79c248359430739ae757661c0a7cc42637fc8527e4e98f0f1503a916d8cec5c7`; `CONTROL_FAILS=none`; `MUTANT_R16_04_COUNT=5`; `MUTANT_IDENTITY=ROW_IDENTITY: adjacency-own count=5 sha256=e8f17def0681940c77edf1ea0fdb65e24c36e40cd8e8c0ab169d2eecafab840b`; `MUTANT_FAILS=R24-09`; `VERDICT=KILLED`. Driver exit 0.
- Direct command `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv` returned `5` before and after (exit 0). `bash corpus/row-identity.sh adjacency-own` returned the digests above (exit 0).
- The mutant calls the shipped `sub_once()`/`restamp()` path (`identity-swap.py:70-77`). Pristine stamp: `corpus/adjacency.tsv 4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549 83 5660`; mutant stamp: `corpus/adjacency.tsv 9efece07b4cefe033365f150eb274a586a9020bf1398cf762998deb3c060599a 83 5663`. `sha256sum` of mutated adjacency.tsv matched its new stamp. The row failures therefore identify R24-09's changed membership digest, not stale file stamps.
- Captured exact subset `verify` summaries (the command is `timeout -k 5 900 bash corpus/claim-ledger.sh verify --claims <control-or-mutant claims.tsv> --stamps corpus/stamps.tsv`). Control: `CLAIM_LEDGER: FAIL (claims=21 failed=0 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=480 labeled_ids=55 host_skipped=0)`, exit 1. Mutant: `FAIL R24-09 reason=verdict-not-final exit=0`, then `CLAIM_LEDGER: FAIL (claims=21 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=480 labeled_ids=55 host_skipped=0)`, exit 1. Thus control is clean at selected-row level per the instrument's explicit predicate, but not an overall clean verifier run: subset claims leave documentation IDs unresolved.

## Receipt comparison, bounds, and gaps

- `identity-before-v2.txt` records R16-04 surviving at BASE (`15/15`); `identity-after.txt` records R16-04 killed by R24-09 at `6c23a56dea0f`, not this frozen revision. The fresh single-row run above independently reproduces the kill at `c5ef9e9`.
- No full harness or other C3 population mutant was run; no host rows were selected. No tools installed. This establishes only R16-04 under this mutation.
- LSP unavailable: `read xd://lsp` returned “No such tool”; therefore no LSP status/references/definition/diagnostics were available. No grep was used as semantic call-site proof.

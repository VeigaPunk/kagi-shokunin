# FIdentityR1606 — C3 R16-06 fresh falsification

## Verdict

- **No actionable defect in the assigned R16-06 repair (PASS).** The inherited R16-06 count row survives the specified identity swap, as intended; R24-11 alone kills it by the changed no-enumerate identity digest.
- **Severity:** none at frozen revision. This is a confirmation of the C3 repair, not an admission or review of the other 14 population rows.
- Falsifier: the old count changing, the pristine R24-11 digest not matching its pin, an unrelated row being the only failure, or stamp controls becoming stale. None occurred.

## Bounds and evidence

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original C3 BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Reproduced in `/fast/scratch/kagi-r24-recovery/FIdentityR1606-9/isolated/lane`, cloned with `--no-hardlinks` and checked out at the frozen revision under `env -i PATH=/usr/bin:/bin` and an empty sandbox `HOME`. No host rows, host gates, or full harness were run; no tools installed.
- `corpus/row-identity.sh` selector `adjacency-noenum` selects full `# no-enumerate` directive lines in file order and hashes their emitted bytes. Frozen `R24-11` pins count `8` and SHA-256 `c52c1027bd87e4ea71dfa63f9e222d36fdc302a17a12fcc23ec05aab91d5a6b1`.
- The R16-06 note says eight directories and names `$HOME/.local/bin`, `$HOME/.config/opencode`, `$HOME/.agents`, plus “the chrome-profile subtree”; it is not an exhaustive enumeration. Frozen `corpus/adjacency.tsv:67-74` contains exactly eight projected members: those three paths, `$HOME/.local/share/the-musketeer/chrome-profile`, `$HOME/.config`, `$HOME/.local/state`, `$HOME/.local/share`, and `$HOME/.local/share/the-musketeer`. The R24-11 projection includes all eight full lines, including the four ancestors not individually listed in the old note; no count/population mismatch observed.

## Bounded checks (all execution used sanitized `env -i`)

- **Pristine control, exit 0:** `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` → `8`; `bash corpus/row-identity.sh adjacency-noenum` → `ROW_IDENTITY: adjacency-noenum count=8 sha256=c52c1027bd87e4ea71dfa63f9e222d36fdc302a17a12fcc23ec05aab91d5a6b1`; independent `grep -E '^# no-enumerate[[:space:]]' corpus/adjacency.tsv | sha256sum` → same digest. Thus both R16-06 and its R17-03 identical count command pass pristine, and R24-11's exact expected line matches.
- **Assigned mutant:** applied only the frozen `identity-swap.py` R16-06 `sub_once` effect in scratch, changing the first member from `# no-enumerate<TAB>$HOME/.local/bin` to `# no-enumerate<TAB>$HOME/zz-.local/bin`. This changes membership but retains the old grep selector's `$HOME/` prefix and therefore count.
- After updating only the scratch `corpus/adjacency.tsv` stamp to its exact hash/line/byte values (`13cc856749d7e0cf27b1030ebec5977d496952c4e20471b11057344777fc8194`, 83 LF lines, 5663 bytes): counts for R16-06 and R17-03 were each `8`; `row-identity.sh adjacency-noenum` returned `ROW_IDENTITY: adjacency-noenum count=8 sha256=6b47062b5e8826c1784f2d59f67913736268a465f44653fe19c1b7e4084fa2c6`; independent projection hash matched that changed digest.
- **Selected ledger evaluation, exit 1:** generated `/fast/scratch/kagi-r24-recovery/FIdentityR1606-9/isolated/claims.tsv` with `awk -F '\t' '$1=="R16-06" || $1=="R17-03" || $1=="R12-03" || $1=="R24-05" || $1=="R24-11" {print}' corpus/claim-ledger.tsv`; ran `bash corpus/claim-ledger.sh verify --claims /fast/scratch/kagi-r24-recovery/FIdentityR1606-9/isolated/claims.tsv --stamps corpus/stamps.tsv`. Extracted `FAIL/POLICY` stdout was only `FAIL R24-11 reason=verdict-not-final exit=0`; summary: `CLAIM_LEDGER: FAIL (claims=5 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=499 labeled_ids=54 host_skipped=0)`. R12-03 count and R24-05 stamp-path identity remain unchanged; `stale=0`, so this kill is from R24-11's membership digest, not stamp drift. The deliberately narrow subset yields unrelated missing-ID citation diagnostics for omitted rows; they did not appear as failing rows.

## Residual risk / verification gaps

- Process deviation: the first disposable scratch-clone setup used `git` outside `env -i`; it ran no gates or claim rows and was not used for reported measurements. I repeated the clone, checkout, and all reported measurements in the sanitized isolated tree above.
- This is one assigned mutation only; no claim is made about the other C3 rows or host-dependent scope-gate behavior.
- No LSP route/server is mounted: `read xd://lsp` returned “No such tool” and the mounted-device list omitted LSP. Therefore LSP status/references/definition/diagnostics were unavailable; no grep result is presented as semantic proof.
- The prior committed wave artifacts agree in direction (`identity-before-v2.txt`: BASE 15/15 survive; `identity-after.txt`: R16-06 killed by R24-11), while this bounded reproduction independently confirms the assigned row at the frozen revision.
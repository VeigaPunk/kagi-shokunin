# R16-06 identity-swap probe (BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`)

## Finding — Medium: count rows do not bind the `no-enumerate` member identities

`corpus/claim-ledger.tsv:44` (R16-06) says there are **8 deliberately unscanned directories** and names `$HOME/.local/bin`, `$HOME/.config/opencode`, `$HOME/.agents`, and “the chrome-profile subtree.” The note does not enumerate the remaining four members. The complete BASE membership in `corpus/adjacency.tsv:67-74` is:

1. `$HOME/.local/bin`
2. `$HOME/.config/opencode`
3. `$HOME/.agents`
4. `$HOME/.local/share/the-musketeer/chrome-profile`
5. `$HOME/.config`
6. `$HOME/.local/state`
7. `$HOME/.local/share`
8. `$HOME/.local/share/the-musketeer`

## Scratch mutation and stamp handling

Used isolated clone `/fast/scratch/kagi-r24/seats/IdentR1606-2`, cloned from the lane repo and checked out at BASE (both commands completed with exit 0). The one count-preserving identity swap changed only `corpus/adjacency.tsv:67`:

```diff
-# no-enumerate	$HOME/.local/bin
+# no-enumerate	$HOME/.local/bink
```

`adjacency.tsv` is stamped (`corpus/stamps.tsv:9` in the initial BASE clone). First attempted `bash corpus/claim-ledger.sh stamp corpus/adjacency.tsv`; exit **2**, refused to drop the other 78 pinned paths (`'LOG.md' is pinned and would be dropped`). Then restamped the full existing set without pruning: `cut -f1 corpus/stamps.tsv | xargs bash corpus/claim-ledger.sh stamp`; exit **0**, `STAMPED: n=79`. The mutant's updated pin is at scratch `corpus/stamps.tsv:1` (SHA-256 `ec5f87e8cf461ac2dc4a0166f6a570932cdfe4ef119885265c435571b5fe004e`).

## Same-file ledger command results

Executed the exact commands for R16-06 and every other ledger row whose command names `corpus/adjacency.tsv` (R16-04, R16-05, R17-02, R17-03); no host row was run. “Last line” is the row command's stdout (the wrapper separately recorded `EXIT=…`). All outcomes are **SURVIVES** the identity swap:

| Row (`corpus/claim-ledger.tsv` line) | Command | Exit | Last output line | Expected | Result |
|---|---|---:|---:|---:|---|
| R16-04 (`corpus/claim-ledger.tsv:42`) | `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `5` | `^5$` | SURVIVES |
| R16-05 (`corpus/claim-ledger.tsv:43`) | `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv` | 0 | `4` | `^4$` | SURVIVES |
| R16-06 (`corpus/claim-ledger.tsv:44`) | `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `8` | `^8$` | SURVIVES |
| R17-02 (`corpus/claim-ledger.tsv:46`) | `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `4` | `^4$` | SURVIVES |
| R17-03 (`corpus/claim-ledger.tsv:47`) | `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `8` | `^8$` | SURVIVES |

R16-03 (`corpus/claim-ledger.tsv:41`) and R17-01 (`corpus/claim-ledger.tsv:45`) were not run: their commands invoke `scope-gate.sh`, not the same-file count commands; R17-01 is substrate-tagged. This probe therefore establishes survival of the requested direct rows, not behavior of the scope gate.

## Recommended identity selector

Parse LF-delimited lines and select records whose first tab field is exactly `# no-enumerate`; require exactly two tab fields, a `$HOME/` path in field 2, and no duplicate values (fail closed on malformed selected records). Digest field 2 **verbatim**—do not expand `$HOME`, trim, normalize, or case-fold. Ignore blank lines, prose/comments, other directives, and ordinary data rows because they are not selected records. Sort the selected path bytes with `LC_ALL=C`, append one LF per value, then SHA-256 the concatenation. This makes the selection independent of file ordering while preserving membership; assert exactly 8 members. For the unchanged BASE set, the canonical digest is `c2ecb55566dbb7465d720305adb0107ce8c4c5b5dbc5c5d37f53d8228a0f7279`; this mutant yields `12fd09cced3698bbdee371c9768bbdaa844777d51a8a9abd62643eade492ece0` (8 members in both), so comparison to the fixed BASE digest kills the swap.

## Residual risk and verification gaps

- The tested count rows prove cardinality, not identity; no selected direct row detected this member substitution. The proposed selector is not implemented by this probe.
- No `lsp` device/server route was exposed in this session, so LSP status/references/definition/diagnostics were unavailable. Literal grep was used only to locate the ledger rows; command behavior above was executed directly.
- No tools were installed or updated.

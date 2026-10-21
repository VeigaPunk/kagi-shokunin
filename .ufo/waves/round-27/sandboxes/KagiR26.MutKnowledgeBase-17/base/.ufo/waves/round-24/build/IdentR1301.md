# R13-01 identity-swap probe

## Result
**R13-01 SURVIVES** a count-preserving heading-identity change. The row observes cardinality, not membership.

## Claim and mutation
At BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`, `corpus/claim-ledger.tsv:29` specifies `grep -c '^## Round ' SCORECARD.md`, expected last line `27`, exit `0`. Its note claims 25 round headings through the round-22 close, plus round-23 pre/post, and explicitly includes the blocked round-20 attempt (excluded from scored sections only). The 27 heading identities are pre/post for rounds 9–18, the blocked round-20 attempt, and pre/post for rounds 21–23.

Scratch clone: `/fast/scratch/kagi-r24/seats/IdentR1301`; the clone command checked out the specified BASE and `git rev-parse HEAD` returned that full commit.

One-key mutant in the clone:
```diff
--- a/SCORECARD.md
+++ b/SCORECARD.md
-## Round 23 — pre-move (repo HEAD `d218603`, round-22 close)
+## Round 24 — pre-move (repo HEAD `d218603`, round-22 close)
```
This replaces the claimed round-23 pre member with round-24 pre; the number of `^## Round ` lines remains 27. `SCORECARD.md` was stamped (`corpus/stamps.tsv:3` at BASE), so I ran from the clone with an empty HOME: `HOME=/fast/scratch/kagi-r24/seats/IdentR1301-emptyhome bash corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)`. It completed with `STAMPED: n=79 out=/fast/scratch/kagi-r24/seats/IdentR1301/corpus/stamps.tsv`. The stamp command sorted the full row set as well as updating the target pin: `SCORECARD.md` changed from SHA-256 `a2e135d304d349fce8709851707224006d006fc300f41f4ebbe63f6affb0d999` (`corpus/stamps.tsv:3` at BASE) to `c61b1767c50d21fec7aa7bf2ecb87b78ad3b7f9ed2364496d2ac355d52bd3602` (`corpus/stamps.tsv:77` after restamp); line and byte counts stayed 862 and 100337.

## Command results
| Ledger row | Command executed | Exit | Last non-empty line | Result |
|---|---|---:|---|---|
| R13-01 (`corpus/claim-ledger.tsv:29`) | `grep -c '^## Round ' SCORECARD.md` | 0 | `27` | **SURVIVES** |

No other eligible non-host ledger row names this root file. R23-01 (`corpus/claim-ledger.tsv:59`) explicitly targets `corpus/fixtures/cells-hermetic/SCORECARD.md`, a different file. R13-03 (`corpus/claim-ledger.tsv:38`) is `[substrate]`-tagged; its bare `cells` command defaults to the root scorecard (`corpus/claim-ledger.sh:239-240`), while the scorecard says the base `cells` row is not host-free and is skipped for host rows (`SCORECARD.md:830`). I did not run this host-dependent gate under the no-host-row bound.

## Identity selector proposal
For each physical line beginning exactly `## Round ` at column 1, extract `(round number, kind)`, where kind is `pre-move`, `post-move`, or `blocked-attempt` (the explicit blocked-round heading). Preserve file order and duplicate records; do not sort. Reject any `## Round ` line that does not match one of those forms rather than silently omitting it. Ignore blank lines, Markdown comments, and all nonmatching prose/body lines. Encode each selected record as `number<TAB>kind<LF>`, prefix with `scorecard-round-membership-v1<LF>`, and SHA-256 the resulting bytes. At BASE this selector yields 27 records and fixed digest `267232d817fc3be7e1d8ffb484148152b79e3d1464f73891437c206cada313b6`; the mutant yields 27 records but digest `ee0038f9a7413639fb3aad44d927431339f15dfdd41cc20c0e8ff45a286e4e2d`.

## Residual risk / verification gaps
The current row cannot distinguish any 27-member set from another 27-member set. The proposed digest is a measurement design only; it was not integrated. `read xd://lsp` returned “No such tool” (no LSP device mounted), so no LSP status/references/definition/diagnostics were available; literal ledger-path checks above are not semantic LSP proof. No tools were installed or updated; no host row was run.
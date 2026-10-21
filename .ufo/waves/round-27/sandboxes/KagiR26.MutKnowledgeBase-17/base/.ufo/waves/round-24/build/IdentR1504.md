# Round-24 BUILD — R15-04 identity-swap probe

## Finding — Medium: the row checks cardinality, not membership

At BASE, `corpus/claim-ledger.tsv:36` (R15-04) says exactly: “checklist.tsv holds 16 declaration rows (E1-E8 evidence, H1-H8 handler).” Its command is `grep -cE '^[EH][0-9]+[[:space:]]' corpus/checklist.tsv`, with expected last line `16` and expected exit `0`. This tests only the number of matching IDs, not the claimed set.

**Mutant:** in the BASE scratch clone `/fast/scratch/kagi-r24/seats/IdentR1504-2`, changed only the first-column identity at `corpus/checklist.tsv:33`, `E8` → `E9`; the remaining seven columns are unchanged. The data-row count remains 16, but the claimed E1–E8 membership is no longer present.

```diff
-corpus/checklist.tsv:33  E8<TAB>runnable<TAB>…
+corpus/checklist.tsv:33  E9<TAB>runnable<TAB>…
```

The complete scratch `git diff -- corpus/checklist.tsv` reported one changed line (one deletion, one insertion); no other checklist row changed.

## Probe results

- Scratch setup: cloned `/home/vgpnk/Projects/shokunin/kagi-shokunin` with `git clone -q --no-hardlinks`, then `git -C /fast/scratch/kagi-r24/seats/IdentR1504-2 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- The mutated file was pinned at BASE in `corpus/stamps.tsv:11` (SHA-256 `28bd238e…39972f04`). The single-path command `bash corpus/claim-ledger.sh stamp corpus/checklist.tsv` exited 2 because the stamp guard refused dropping the other 78 pinned paths (`claim-ledger.sh:255-274`). I then restamped the existing full path set with `cut -f1 corpus/stamps.tsv | xargs -r -d '\n' bash corpus/claim-ledger.sh stamp`; it completed with `STAMPED: n=79`. The updated `corpus/stamps.tsv:3` record is SHA-256 `0698480c5c4241d941496b6c29cd35a349be7c8656fad51c250813503bba0578`, 40 lines, 11694 bytes. Thus the row was not tested against a stale file pin.
- **R15-04** (`corpus/claim-ledger.tsv:36`): ran `grep -cE '^[EH][0-9]+[[:space:]]' corpus/checklist.tsv` in the scratch clone. Exit **0**; last stdout line **`16`**; **SURVIVES**.
- No other ledger command field names `corpus/checklist.tsv`; therefore there was no other matching row to run. R15-01/02/03/05 name `corpus/checklist-run.sh`, not this data file, and were not run.

## Identity selector recommendation

Have a reader parse each nonblank, non-comment TSV record strictly (exactly eight columns; reject malformed records, empty IDs, and duplicate IDs), then select **column 1 only**. This is the claimed membership key; its `E`/`H` prefix preserves the evidence/handler partition. Ignore empty lines and full-line comments beginning with `#` in column 1; reject whitespace-only lines rather than silently treating them as records. Canonicalize the IDs as one LF-terminated ID per line, sorted bytewise with `LC_ALL=C` (do not use `sort -u`, so duplicates cannot disappear), and hash the stream prefixed by `checklist-ids-v1\n`. Compare with a fixed expected digest and require the exact expected 16 unique IDs.

For the unchanged BASE tree the sorted set is `E1,E2,E3,E4,E5,E6,E7,E8,H1,H2,H3,H4,H5,H6,H7,H8`; the domain-separated digest is `735164a5923f8876fece981939f6138084834f4e20ae52ebe706d66219148b89`. The E8→E9 mutant yields `6aa52ca21ee2c8288e049cca02c8d53b8fcf5aedb5e91e0251e81d5226d6b3b5`, so the unchanged tree reproduces one fixed digest and this identity swap changes it. Sorting makes row reordering irrelevant while preserving membership sensitivity.

## Residual risk and verification gaps

R15-04 alone is demonstrably insensitive to a same-count identity substitution. This probe does not assert whether other checklist-runner behavior diagnoses this mutant; those commands do not directly name the target file and were outside the requested row set. No LSP device is mounted (`read xd://lsp` returned “No such tool”); consequently no LSP status, references, definition, or diagnostics were available. Literal file reads/searches were used only to identify the ledger command text, not as semantic proof. No tools were installed or updated.
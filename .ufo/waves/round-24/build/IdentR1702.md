# R17-02 identity-swap probe

## Scope and claimed membership

- Scratch clone: `/fast/scratch/kagi-r24/seats/IdentR1702`, checked out at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (`git clone -q --no-hardlinks ...` then `git -C ... checkout -q ...`; clone command returned that exact HEAD).
- `corpus/claim-ledger.tsv:46` (R17-02) claims `adjacency.tsv` carries **exactly four breadth pins** and that the gate independently derives the required member set. The BASE `corpus/adjacency.tsv:75-78` membership is: `$HOME/.config/opencode`, `$HOME/.local/bin`, `$HOME/.agents`, `$HOME/.local/share/the-musketeer/chrome-profile`.
- The target file is pinned at BASE in `corpus/stamps.tsv:9`. LSP status was attempted first, but `read xd://lsp` returned “No such tool”; no LSP device/server was available. I used text search only to enumerate rows whose command names `corpus/adjacency.tsv`, then executed those commands directly.

## Count-preserving mutant

In the scratch clone, renamed one breadth member while retaining the directive and its count fields; the file’s line count and four matching breadth rows remain unchanged:

```diff
-# breadth\t$HOME/.config/opencode\tchildren=20\tdeclared=4
+# breadth\t$HOME/.config/openxcode\tchildren=20\tdeclared=4
```

The file was stamped in BASE, so a full-set restamp is required to avoid stamp drift. The initial `bash corpus/claim-ledger.sh stamp "${paths[@]}"` attempt (79 paths read from the first column of `corpus/stamps.tsv`) timed out after 300 seconds with no output. A retry of the same full-set stamp command was started asynchronously and was still running when this report was first written; its completion is not yet verified.

## Same-file ledger commands after mutation

Each command below ran in the scratch clone against the mutated file. BASE last-line counts were separately measured from `git show BASE:corpus/adjacency.tsv` with the same `grep -cE` expression. Every mutated command exited 0 and its final non-empty line matched the ledger expectation, so each row **SURVIVES** this identity swap.

| Row | Ledger command | BASE last line | Mutant exit | Mutant last line | Result |
|---|---|---:|---:|---:|---|
| R16-04 | `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv` | `5` | 0 | `5` | SURVIVES |
| R16-05 | `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv` | `4` | 0 | `4` | SURVIVES |
| R16-06 | `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` | `8` | 0 | `8` | SURVIVES |
| R17-02 | `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv` | `4` | 0 | `4` | SURVIVES |
| R17-03 | `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` | `8` | 0 | `8` | SURVIVES |

R17-01 was not run: its command is `bash corpus/scope-gate.sh --breadth` and it is `[substrate]`-tagged, hence a host row. It does not name `corpus/adjacency.tsv` as its command target. No host row or host-private gate was run.

## Reader-selector recommendation

For R17-02, parse only actual directive records whose first tab-delimited field is exactly `# breadth`; require four tab fields and fail closed on malformed `# breadth` records. Digest field 2 (the path identity) from each record, require four distinct paths, sort bytewise under `LC_ALL=C`, and hash the canonical UTF-8 path lines with one LF per path. Ignore blank lines and ordinary prose/comment lines; do not mistake explanatory `# breadth ...` comments without a tab-delimited directive record for members. Sorting makes the digest independent of record order, while the exact selected paths make a rename visible. The `children` and `declared` fields are not part of the membership digest.

The resulting sorted-path digest is `f879121cd9e55f7f5f3e3f386bce48c7df778c84f6a50853b4b42157a01c7b3e` for BASE and `eaaa97244231e139c03e29cb67a928a7362a6b3fb62bab909865ce85b2b9761b` for the mutant. Thus this selector reproduces one fixed digest for the unchanged BASE membership and distinguishes this count-preserving rename, unlike the bare cardinality row.

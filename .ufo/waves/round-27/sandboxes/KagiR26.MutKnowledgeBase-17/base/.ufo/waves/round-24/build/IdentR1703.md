# R17-03 identity-swap probe

## Row and claimed membership

- Scratch clone: `/fast/scratch/kagi-r24/seats/IdentR1703-2`, HEAD `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- `corpus/claim-ledger.tsv:47` (R17-03): `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv`, expected `^8$`, expected exit 0.
- Its note claims eight deliberate no-enumeration boundaries, with four leaf members requiring breadth pins and four aggregate ancestors exempt (`corpus/claim-ledger.tsv:47`). At BASE the eight path identities in `corpus/adjacency.tsv:67-74` are:
  - Breadth-pinned leaves (`:67-70`, `:75-78`): `$HOME/.local/bin`, `$HOME/.config/opencode`, `$HOME/.agents`, `$HOME/.local/share/the-musketeer/chrome-profile`.
  - Aggregate ancestors (`:71-74`): `$HOME/.config`, `$HOME/.local/state`, `$HOME/.local/share`, `$HOME/.local/share/the-musketeer`.

## Mutant and required row results

One count-preserving identity swap in the BASE clone, `corpus/adjacency.tsv:72`:

```diff
-# no-enumerate\t$HOME/.local/state
+# no-enumerate\t$HOME/.local/state/the-janitor
```

It removes one member and adds a different path, leaving eight matching no-enumerate directives. The replacement is already an `# own` prefix (`adjacency.tsv:51`); this is intentionally a membership mutation, not a claim that the mutant is a valid partition.

BASE `corpus/stamps.tsv:9` pinned `corpus/adjacency.tsv` (83 lines, 5660 bytes, SHA-256 `4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549`). The first exact-path restamp attempt, `HOME=/fast/scratch/kagi-r24/seats/IdentR1703-2-home bash corpus/claim-ledger.sh stamp corpus/adjacency.tsv`, exited 2: it refused to drop the other 78 pinned paths. I then ran `HOME=/fast/scratch/kagi-r24/seats/IdentR1703-2-home bash corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)` in the clone; exit 0, `STAMPED: n=79`. The updated adjacency stamp is SHA-256 `cee3df906ab6bd2af3a6c9d91cb9ae522a9251375a0b74ce33296a4f915ae574`, 83 lines, 5672 bytes. Thus the file was re-stamped before the count rows were evaluated.

The BASE ledger has exactly these five non-host command fields naming `corpus/adjacency.tsv` (lines 42-44, 46-47). I ran each command against the mutant; exit is the command's exit, and “last” is its last stdout line:

| Row | Exit | Last line | Result |
|---|---:|---:|---|
| R16-04 `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `5` | SURVIVES |
| R16-05 `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv` | 0 | `4` | SURVIVES |
| R16-06 `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `8` | SURVIVES |
| R17-02 `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `4` | SURVIVES |
| R17-03 `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` | 0 | `8` | SURVIVES |

All five pinned counts still match; none detects the changed path identity. I did not run the substrate-tagged scope-gate rows or a whole-ledger verification. `corpus/row-identity.sh` is absent at BASE, so the digest check below is a one-off selector experiment, not that script's output.

## Identity selector proposal

For R17-03, define a versioned selector such as `adjacency.no-enumerate-paths.v1`: parse tab-delimited records; select only records whose first field is exactly `# no-enumerate`; require the expected directive shape and a `$HOME/…` path in field 2; digest field 2 (the path identity), not header prose or unrelated columns. Ignore empty lines and ordinary comments; they are not records. Do not silently ignore malformed no-enumerate directives. Preserve duplicate path records (do not `uniq`), then byte-sort the selected paths with `LC_ALL=C sort` so source row order is immaterial. Emit a fixed domain/version header plus one UTF-8 path and LF per record, then SHA-256. This gives an unchanged tree a deterministic digest while retaining multiplicity and detecting a replacement. The separate breadth selector should pin its four path identities and values; the no-enumerate path digest alone does not validate the leaf/aggregate derivation.

For an example canonical stream consisting of `R17-03-no-enumerate-v1\n` followed by the sorted field-2 paths and LF terminators, the BASE digest was `d0eb85a6632198f77350796a45dd81422c814e0dbd8cb32c7eeb1864a8d2c732` on two runs. The mutant digest was `ecd2b87eb4c907678e152ee5234bc0d1e1e911351d813558a552171a38544fb3`.
# R13-02 identity-swap probe

## Scope and baseline

- C3 calibration; scratch clone `/fast/scratch/kagi-r24/seats/IdentR1302-2`, checked out at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- BASE `corpus/claim-ledger.tsv:31` says R13-02 claims 35 `R1x` rows: all IDs matching `^R1`, no comment lines; R2x rows are counted by R21-04. Exact BASE membership: `R11-01..R11-11`, `R12-01..R12-03`, `R13-01..R13-03`, `R14-01`, `R15-01..R15-05`, `R16-01..R16-06`, `R17-01..R17-03`, `R18-01..R18-03` (11+3+3+1+5+6+3+3=35).
- The only other command cells naming `corpus/claim-ledger.tsv` are R18-02 (`:49`) and R21-04 (`:54`). None is a host row; no other host row was run.

## Mutant

In the scratch clone, changed only the ID fields in two rows; all other columns stayed unchanged:

```diff
-corpus/claim-ledger.tsv:31 R13-02\tgrep -c '^R1' corpus/claim-ledger.tsv\t^35$\t0\t30\t...
+corpus/claim-ledger.tsv:31 R24-02\tgrep -c '^R1' corpus/claim-ledger.tsv\t^35$\t0\t30\t...
-corpus/claim-ledger.tsv:51 R21-01\tbash corpus/op-ref-probe.sh --dotenv-bytes\t...
+corpus/claim-ledger.tsv:51 R19-01\tbash corpus/op-ref-probe.sh --dotenv-bytes\t...
```

Thus the selected R1x membership loses `R13-02` and gains `R19-01`; R1x cardinality remains 35. Across all rows, `R13-02` becomes `R24-02` and `R21-01` becomes `R19-01`, so the complete-ledger row count also stays fixed. R18-02's tag membership is unchanged.

The mutated file was stamped in the clone because BASE `corpus/stamps.tsv:13` pins it. A first one-path attempt, `HOME=/fast/scratch/kagi-r24/seats/IdentR1302-2/home bash corpus/claim-ledger.sh stamp corpus/claim-ledger.tsv`, exited 2 and refused to shrink the 79-row stamp set (`LOG.md` would be dropped). Then all existing paths were preserved and re-stamped with `cut -f1 corpus/stamps.tsv | HOME=/fast/scratch/kagi-r24/seats/IdentR1302-2/home xargs -r bash corpus/claim-ledger.sh stamp`; exit 0, last line `STAMPED: n=79 out=/fast/scratch/kagi-r24/seats/IdentR1302-2/corpus/stamps.tsv`.

## Same-file row results on final mutant

Each command below was run directly from the scratch clone after re-stamping. `SURVIVES` means the count-only row accepted the membership mutation.

| BASE row (source line) | Command | Exit | Last line | Result |
|---|---|---:|---|---|
| R13-02 (`corpus/claim-ledger.tsv:31`) | `grep -c '^R1' corpus/claim-ledger.tsv` | 0 | `35` | SURVIVES |
| R18-02 (`corpus/claim-ledger.tsv:49`) | `grep -cE '\[substrate\]' corpus/claim-ledger.tsv` | 0 | `11` | SURVIVES |
| R21-04 (`corpus/claim-ledger.tsv:54`) | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | 0 | `45` | SURVIVES |

## Identity selector proposal

For selector `R13-02`, parse `corpus/claim-ledger.tsv` as tab-separated rows. Ignore empty lines and lines whose first byte is `#`; require every remaining row to have six fields, a valid unique ID, and select the first field matching `^R1[0-9]+-[0-9]+$` (the present valid `R1x` membership described by R13-02). Sort selected IDs bytewise under `LC_ALL=C` rather than using file order, then SHA-256 a canonical UTF-8/LF stream consisting of a versioned selector prefix (for example `ROW-IDENTITY-v1\tR13-02\n`) followed by one selected ID and `\n` per line. Reject malformed/duplicate data rows instead of silently dropping them. This excludes comments/blanks consistently, is invariant to record reordering, gives an unchanged tree one reproducible digest, and changes when this mutant substitutes `R19-01` for `R13-02`.

No tools were installed or updated.
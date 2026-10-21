# R21-04 identity-swap probe

## BASE membership and scope

- Scratch clone: `/fast/scratch/kagi-r24/seats/IdentR2104-2`, checked out at `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- `corpus/claim-ledger.tsv:54` (R21-04) runs `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv`, expects `^45$`, and its note claims exactly: “current claim-row membership: original 39 retained, R22-01..04 for feature review/revision audit, and R23-01/R23-02 for hermetic cells and closure dispositions.” The note therefore claims the original 39 plus R22-01 through R22-04 and R23-01/R23-02 (45 total); it does not enumerate the original 39 individually.
- Other BASE command fields naming this same file: `corpus/claim-ledger.tsv:31` R13-02 (`grep -c '^R1' ...`, expect 35) and `:49` R18-02 (`grep -cE '\[substrate\]' ...`, expect 11). Together with R21-04 at `:54`, these are the three same-file rows. They are grep-only rows, not host rows; no host command was run.

## Mutant and stamp

Changed one identifier only, keeping all other R23-02 columns byte-for-byte unchanged:

```diff
-R23-02
+R24-02
```

`corpus/stamps.tsv:13` stamped the mutated `corpus/claim-ledger.tsv` in BASE (60 lines, 19,566 bytes), so I re-stamped all 79 existing paths in the scratch clone. An initial equivalent `mapfile` invocation timed out at 300s without changing the old stamp; retrying `bash corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)` completed and printed `STAMPED: n=79 out=/fast/scratch/kagi-r24/seats/IdentR2104-2/corpus/stamps.tsv`. The updated ledger stamp is `f24a3d9997e0c966dde50fb5da9694e1f956c74526379501060e8c97be0a19b7` (still 60 lines / 19,566 bytes). The stamp command sorted the full stamp table; its path membership remained 79. Thus stamp drift is not the mutant signal.

## Mutant row outcomes

Ran the three exact BASE row commands in the scratch clone after the mutation; the captured exit and last output line were:

| Row | Exit | Last line | Result |
|---|---:|---|---|
| R13-02 | 0 | `35` | **SURVIVES** — still matches `^35$` |
| R18-02 | 0 | `11` | **SURVIVES** — still matches `^11$` |
| R21-04 | 0 | `45` | **SURVIVES** — still matches `^45$` |

The existing commands preserve only counts, so all three accept a changed identifier membership. A canonical sorted-ID serialization of BASE and mutant both contains 45 IDs but yields different SHA-256 values: BASE `b06e2b4e944c2ad6676249c3da1fc0a036cf75fc6bd23255498ceabcdd4ecbed`; mutant `72a30a0853b44b02237a0c009996e919806f4e628774acc6018020681c57cc32`.

## Reader selector recommendation

Read `corpus/claim-ledger.tsv` as strict LF-delimited TSV. Ignore only zero-length lines and comment lines whose first byte is `#`; treat whitespace-only or other malformed non-comment lines as errors. Require six fields per data row, an ID in column 1 matching the full pattern `R[0-9]+-[0-9]+`, and no duplicate IDs. Digest only column 1—not commands, expectations, or notes—because R21-04 claims row-ID membership. Sort IDs bytewise under `LC_ALL=C` (not file order), serialize each ID followed by exactly one LF including the final ID, and SHA-256 those bytes; report the ID count alongside the digest. This makes row order irrelevant, gives an unchanged BASE tree the fixed digest above, and changes the digest for the R23-02→R24-02 swap. Ignoring blank lines also prevents the prior `grep -cv '^#'` blank-line-counting behavior from disguising a deleted ID as an identity-preserving row.

## Verification gaps

- No `lsp` device is mounted (`read xd://lsp` returned “No such tool”); same-file row enumeration used the literal ledger command fields, not LSP semantics.
- `corpus/row-identity.sh` is absent at BASE, so no reader implementation was available to execute; the selector above is a proposal, and the digest comparison is the direct mutation evidence.
- No tools were installed or updated.
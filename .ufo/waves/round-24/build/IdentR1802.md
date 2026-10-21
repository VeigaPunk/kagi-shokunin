# R18-02 identity-swap probe

Axis: C3 calibration — binding the claimed membership, not only its count.

## Finding — High: the identity row self-tags and is skipped by default

`corpus/claim-ledger.tsv:49` says R18-02 claims eleven substrate-tagged command rows and points to “R24 ledger-substrate row” for their identity. Interpreted literally, the membership is data rows whose sixth TSV field contains `[substrate]`; the intended 11 IDs are `R11-01, R11-02, R11-03, R11-04, R11-06, R12-01, R13-03, R15-01, R16-01, R16-03, R17-01`.

The candidate’s R24-13 note at `corpus/claim-ledger.tsv:76` itself contains `[substrate]`. Consequently, R18-02’s grep counts 12 (not its expected 11), and `row-identity.sh:83-86` includes R24-13 in the membership it is supposed to identify. Direct scratch-only reader output was `ROW_IDENTITY: ledger-substrate count=12 sha256=1cb4b97db9c0378aa2b48ab43205a84015978676daf28d1fc4cf9443b6b16cfd` (exit 0), against R24-13’s pinned count 11 / digest `08554f8484b58cd095b257d0b9d9a0cae55a94d73b9fb801f4f1a4e812f4b031`.

This same marker makes R24-13 a host row: `claim-ledger.sh:166-167` classifies notes containing `[substrate]` as host, and `:528-530` skips host rows unless `--allow-host-rows` is given. Thus normal `verify`/`cells` do not execute the identity detector. Rephrase the R24-13 note without the literal marker (e.g. “substrate-tagged rows”) so it is not its own member or host-tagged; do not weaken the selector.

## Probe

Scratch was cloned and checked out at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`. Since BASE predates `row-identity.sh`, I copied the current lane candidate’s `claim-ledger.tsv`, `claim-ledger.sh`, `row-identity.sh`, `stamps.tsv`, and the four newly stamped artifacts needed to make that candidate stamp set operable into the clone. No lane code was edited. `corpus/claim-ledger.tsv` was stamped (it is pinned in `corpus/stamps.tsv`): before and after the mutant, `cut -f1 corpus/stamps.tsv | HOME=<empty scratch HOME> xargs bash corpus/claim-ledger.sh stamp` exited 0 and printed `STAMPED: n=83`. After mutation the pinned ledger row was SHA-256 `c6c767c7526dbf90db62a700739da57fe775b5cdb394837c6f73ac3e8cbb18cd`, 79 lines, 25986 bytes; the stamp matches those values.

One count-preserving move: removed `[substrate]` from R16-03’s note and appended it to R16-02’s note. The total literal-tag member count stayed 12 in the candidate (or 11 if R24-13’s self-description is kept out).

```diff
-R16-02 note ends: ... whole-HOME refusal
+R16-02 note ends: ... whole-HOME refusal [substrate]
-R16-03 note ends: ... deferred instead [substrate]
+R16-03 note ends: ... deferred instead
```

Commands below ran in nested Bash in the clone, matching the ledger runner’s `bash -c` execution context. Baseline means the copied candidate before the mutant.

| Row (ledger line) | Command | Baseline exit / last line | Mutant exit / last line | Result |
|---|---|---|---|---|
| R18-02 (`:49`) | `grep -cE '[[]substrate[]]' corpus/claim-ledger.tsv` | `0` / `12` | `0` / `12` | **SURVIVES**: count unchanged; note this row already mismatches `^11$` on the unmutated candidate. |
| R13-02 (`:31`) | `grep -c '^R1' corpus/claim-ledger.tsv` | `0` / `35` | `0` / `35` | **SURVIVES** |
| R21-04 (`:54`) | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | `0` / `61` | `0` / `61` | **SURVIVES** |

These are the only three ledger commands literally naming `corpus/claim-ledger.tsv`; the other identity commands name `corpus/row-identity.sh`. The tag swap diff is between R16-02 and R16-03; no other row or count changed.

For the selector, the current code’s unfiltered sorted-ID digest changes from baseline `count=12 sha256=1cb4b97db9c0378aa2b48ab43205a84015978676daf28d1fc4cf9443b6b16cfd` to mutant `count=12 sha256=a0ea0c3be4dcdf751a1508aa929d346d507b6ab700ff51c7fd6772c54f8777e5` (digest-sensitive, but the registered row is already red at baseline and default routing skips it). Keeping the identity row’s own descriptive note out of the membership gives the intended fixed baseline `count=11 sha256=08554f8484b58cd095b257d0b9d9a0cae55a94d73b9fb801f4f1a4e812f4b031`; the same swap produces `count=11 sha256=e68ea5f11d2554e16f83de90f466adae4cb37db5859a314bf330a91ebf109c01`. The corrected selector therefore **KILLS** this mutant; the current default-gated candidate does not get that protection because R24-13 is host-skipped.

## Proposed identity selector

For `ledger-substrate`, accept only data rows whose column 1 matches `^R[0-9]+-[0-9]+$`; inspect column 6 only for the literal `[substrate]`; emit column-1 IDs, one per line; sort under `LC_ALL=C`; report both count and SHA-256 of the newline-delimited sorted IDs. Comment lines and blank lines do not become members because neither has a valid row ID. Sorting is appropriate because this is set membership, not ledger order. Ensure the identity row’s own note does not contain the marker literal, so an unchanged tree reproduces the pinned digest and the row is not classified as host.

## Residual risk and verification gaps

- I did not run full `verify`/`cells` or any host-reading row. R24-13 was not run through the ledger dispatcher; its helper was invoked directly only in the scratch clone with empty HOME, and its selector logic was independently recomputed after the mutation.
- `xd://lsp` is not mounted (tool returned “No such tool”); literal text search was only used to enumerate command strings, not as semantic proof. No LSP references/definition/diagnostics were available.
- The tool shell’s injected `grep` builtin (`pi-uu-grep`) rejected the new ERE; nested Bash, which resolves `/usr/bin/grep`, was used for every reported ledger command.
- No tools were installed or updated.
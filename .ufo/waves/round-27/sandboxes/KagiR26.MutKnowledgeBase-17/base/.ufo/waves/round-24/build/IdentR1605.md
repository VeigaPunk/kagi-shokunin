# R16-05 identity-swap probe

## Scope and claimed membership

- Scratch clone: `/fast/scratch/kagi-r24/seats/IdentR1605-2`, checked out at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- `corpus/claim-ledger.tsv` R16-05 command: `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv`; expected output `4`, exit `0`.
- Its note claims the membership of the four data-row surfaces it names: `$HOME/.config/opencode` (`opencode`), `$HOME/.local/share/the-musketeer/chrome-profile` (`chrome-profile`), `$HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts` (`NativeMessagingHosts`), and `$HOME/.agents/AGENTS.md` (`agents-AGENTS.md`). These are four rows, not merely any four non-comment lines.

## Mutant and stamp

One count-preserving identity substitution in the clone, at `corpus/adjacency.tsv:84`:

```diff
-$HOME/.agents/AGENTS.md\tkotoba\tshared-read\tdeclared\tlane:kotoba/corpus/knowledge/alwayson-checklist-round7.md:30\tAGENTS\\.md\tbyte-pinned here; kotoba is the sole fleet claimant of the file's checklist/shape reading (read-only for both lanes)
+$HOME/.agents/AGENTS.local.md\tkotoba\tshared-read\tdeclared\tlane:kotoba/corpus/knowledge/alwayson-checklist-round7.md:30\tAGENTS\\.md\tbyte-pinned here; kotoba is the sole fleet claimant of the file's checklist/shape reading (read-only for both lanes)
```

Only the path in column 1 changed; the row remains a data row, so the data-row count remains four. The named `AGENTS.md` member is replaced with `AGENTS.local.md`.

The file was stamped in the baseline manifest. Refreshed the full 79-path manifest in the clone (preserving the other entries) with:

```sh
cut -f1 corpus/stamps.tsv | env HOME=/fast/scratch/kagi-r24/seats/IdentR1605-2/empty-home xargs -r bash corpus/claim-ledger.sh stamp
```

Exit `0`; output: `STAMPED: n=79 out=/fast/scratch/kagi-r24/seats/IdentR1605-2/corpus/stamps.tsv`. The adjacency stamp changed from SHA-256 `4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549` (83 lines, 5660 bytes) to `8cb5b943b7f9d28ef1cecb27302692b7bf89ecd349c2feba680a49554300cc91` (83 lines, 5666 bytes), so stamp drift is not the result under test.

## Commands run after mutation

Each exact ledger command ran in the scratch clone with `HOME=/fast/scratch/kagi-r24/seats/IdentR1605-2/empty-home`; none is a host row.

- R16-04 `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv` — exit `0`, last line `5` (expected `5`): **SURVIVES**.
- R16-05 `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv` — exit `0`, last line `4` (expected `4`): **SURVIVES**.
- R16-06 `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` — exit `0`, last line `8` (expected `8`): **SURVIVES**.
- R17-02 `grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv` — exit `0`, last line `4` (expected `4`): **SURVIVES**.
- R17-03 `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` — exit `0`, last line `8` (expected `8`): **SURVIVES**.

R16-05 detects cardinality only; its count remains correct while its stated membership is false under this mutant.

## Identity selector recommendation

For this claim, select exactly the data rows using the same first-character rule as R16-05 (`^[^#[:space:]]`); ignore blank/whitespace-only and `#` comment lines because neither belongs to the claimed data-row membership. Parse TSV strictly and digest columns 1–6 (`path`, `owner`, `status`, `claim`, `basis`, `token`), excluding the free-text note in column 7. Canonicalize each selected tuple as those fields separated by literal tabs and terminated by LF; reject malformed rows and duplicate path keys rather than silently dropping them. Sort full tuples bytewise under `LC_ALL=C` before hashing, preserving duplicates if validation permits them; sorting makes row reordering immaterial while path or structural-field substitution changes the digest. Store the expected SHA-256 for the frozen tree/population and compare it to the recomputed digest. The mutant changes the path tuple and therefore cannot reproduce the unchanged-tree digest; comments and blank lines do not perturb it.

## Verification caveat

One exploratory no-argument `bash corpus/claim-ledger.sh` was run in this scratch clone without overriding ambient `HOME`. Its observed output included `FAIL R11-08 reason=exit-mismatch exit=1 want=0`, `DEFER R16-01 reason=substrate-absent`, and other substrate DEFERs. This was not part of the assigned probe and is not evidence for a host-safe full-ledger run. The stamp refresh and all five assigned commands above used the empty scratch `HOME`; no further host-gate command was run. No identity reader implementation exists in this BASE clone, so the selector above is a recommendation, not an implementation test.

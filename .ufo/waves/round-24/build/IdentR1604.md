# R16-04 identity-swap probe

## Scope and claimed membership

Scratch clone: `/fast/scratch/kagi-r24/seats/IdentR1604-2`, pinned at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (`git rev-parse HEAD` returned that hash).

`corpus/claim-ledger.tsv:42` (R16-04) runs `grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv`, expects `^5$`, and exits 0 on success. Its note claims exactly five owned prefixes: `config/the-janitor`, `bin/the-janitor`, `bin/tac-check`, `state/the-janitor`, and `state/tac`, i.e. the literal `$HOME/.config/the-janitor`, `$HOME/.local/bin/the-janitor`, `$HOME/.local/bin/tac-check`, `$HOME/.local/state/the-janitor`, `$HOME/.local/state/tac` membership.

The other ledger commands naming this file are R16-05 (`claim-ledger.tsv:43`), R16-06 (`:44`), R17-02 (`:46`), and R17-03 (`:47`). R17-01 (`:45`) does not name the file in its command and is `[substrate]`-tagged; it was not run. Baseline direct command runs were all exit 0, last lines respectively `5`, `4`, `8`, `4`, `8`.

## Mutant and probe results

One count-preserving key rename in the clone, `corpus/adjacency.tsv:52`:

```diff
-# own\t$HOME/.local/state/tac
+# own\t$HOME/.local/state/tac-archive
```

This replaces `state/tac` with `state/tac-archive`; the owned membership changes while the number of `# own` rows remains 5. `corpus/adjacency.tsv` was already stamped (`corpus/stamps.tsv:9`, 83 lines, 5660 bytes). I re-stamped all 79 existing paths in the clone with `bash corpus/claim-ledger.sh stamp <all paths from corpus/stamps.tsv>`; it emitted `STAMPED: n=79`. The resulting adjacency stamp is SHA-256 `fc3afa2697e35669f2a23699a84148c7bb8d5e5a70790ab16b8f38b6f3c17bfd`, 83 lines, 5668 bytes (`corpus/stamps.tsv:1`). Thus stamp drift was not the detector.

After mutation, each exact ledger command was run directly in the clone. All returned the expected exit and count, so each row—and the mutant against this same-file row set—**SURVIVES**:

| Row | Exit | Last output line | Result |
|---|---:|---|---|
| R16-04 | 0 | `5` | SURVIVES |
| R16-05 | 0 | `4` | SURVIVES |
| R16-06 | 0 | `8` | SURVIVES |
| R17-02 | 0 | `4` | SURVIVES |
| R17-03 | 0 | `8` | SURVIVES |

The four companion counts do not select the renamed `# own` member; the target row checks cardinality only. A count-only check therefore fails to bind the membership named in its note.

## Identity selector proposal

Use selector `R16-04` over `corpus/adjacency.tsv`: split physical rows on literal TAB; select rows with exactly two fields, field 1 exactly `# own`, and field 2 a nonempty literal `$HOME/` prefix. Extract field 2 verbatim (do not expand `$HOME` or trim it); reject malformed selected rows and duplicate paths. Ignore blank lines and all prose/comments or other directives unless they are an exact tab-delimited `# own` directive. Sort the extracted paths bytewise with `LC_ALL=C`; count the five members and SHA-256 the canonical stream consisting of each sorted path followed by exactly one LF. This is file-order independent and excludes prose beginning with `# own`.

For that serialization, the unchanged BASE tree gives `count=5 sha256=cf5a016c922a8b6945104ee8c9a5bc659f459b013c250a86ede53ad40fc57ebc`. The mutant gives `count=5 sha256=18bd42255f8a44652baac8131f4f22e4181aae468784f5e35a2f0562499f89be`, so the proposed identity digest catches this swap while reproducing one fixed digest for the unchanged tree. `corpus/row-identity.sh` is absent at BASE; this report proposes the selector/serialization and does not claim the future reader script was exercised.

## Verification and safety notes

No tools were installed. The identity probe itself ran only the five named grep rows in the scratch clone; no substrate row was part of the probe.

An extra, accidental `bash corpus/claim-ledger.sh` (no mode; defaults to `verify`) was invoked in the clone while checking usage, without an isolated empty `HOME`. It completed with substrate-row `DEFER` output and R11-08 `FAIL exit-mismatch`; the latter row's note (`claim-ledger.tsv:22`) says the citations check fails in a lone clone by design. This was outside the probe, and because the default run did not provide a complete per-command execution log, I cannot certify that no host-backed command ran. No host side effects were audited. Do not treat that invocation as identity-probe evidence.

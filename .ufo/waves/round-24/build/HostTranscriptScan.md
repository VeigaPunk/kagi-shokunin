# `transcript-scan.sh` host-surface classification

## Scope and method

Static source/ledger reading only. No scanner, ledger mode, host gate, or live host surface was executed; no tool was installed. The `lsp` device is unavailable (`read xd://lsp` returned `No such tool: xd://lsp`), so text search was used only to locate sources and the findings below are grounded in the cited source lines, not semantic-LSP results.

## CLI mode/flag classes

The option loop accepts `--db PATH`, `--selftest`, and `--classify`; `-h|--help` exits immediately; anything else, including a missing `--db` operand, prints usage and exits 2 (`corpus/transcript-scan.sh:38-46`). `--db` consumes the next word unconditionally (even if it looks like a flag); if repeated, the last assigned DB path wins. `--selftest` and `--classify` are booleans. After successful parsing, the selftest branch precedes every live DB existence/copy/query operation (`:184-258`); otherwise the scan/classify branch uses the selected DB (`:260-282`). Thus all option permutations reduce to these classes:

| Invocation class | Classification | Read / evidence |
|---|---|---|
| No flags | **HOST** by default. Uses `$THE_JANITOR_STATE_DIR`, or `$HOME/.local/state/the-janitor`, to form `.../xdg-data/opencode/opencode.db` (`:34-35`); requires/copies that DB and any `-wal`/`-shm` siblings (`:261-274`). | Queries run against the copied DB (`:100`, `:135-182`), whose selected text columns and credential tripwire tables are listed at `:52-66`. This is a transcript read even though sqlite opens the copy: `cp` reads the source DB and sidecars (`:268-274`). |
| `--classify` without `--db` | **HOST**. It is not a privacy/scratch mode: it uses the same default host DB and snapshot path. | `classify_hits` queries the copied DB (`:117-133`); the dispatch occurs after the copy (`:276`). |
| `--db PATH`, optionally with `--classify`, without `--selftest` | **PATH-CONDITIONAL**: HOST when `PATH` (or its `-wal`/`-shm`) names host/private transcript data; HOST-FREE only when the DB and sidecars are verified repo fixtures or caller-owned scratch files. | The path is only assigned at `:41`; it is tested/copied and queried at `:261-274`. `--classify` changes query/output mode, not the data source (`:276`). Do not allow generic `--db` as a safe mode. |
| A successfully parsed invocation with `--selftest` (with or without `--classify` and/or `--db PATH`, in any order) | **HOST-FREE**. It constructs its own databases under `mktemp`, seeds fixture rows, recursively scans only those fixture DBs, and exits before the normal DB branch (`:184-257`; recursive fixture paths at `:186-216,221-248`). `--classify` and any assigned `--db` are ignored by the selftest branch. | The pre-parse `$HOME` expansion at `:34` forms an unused default pathname in this branch; it does not open/read that path. A parse error later in the argument list exits through usage before selftest begins. |
| `-h` or `--help` recognized as an option | **HOST-FREE**. It prints the first 24 lines of the invoked repo script with `sed` and exits immediately (`:44`); preceding valid flags do not open a DB. | Caveat: if `--help` follows `--db`, it is consumed as that option's PATH value, so it is not a help invocation (`:41,44`). |
| Invalid/unknown arguments or `--db` with no following word | **HOST-FREE early exit**, not a useful evidence-producing mode: usage exits before DB checks or reads (`:38,41,45`). | These should not be treated as approved ledger verdict modes. |

The default-path assignment reads the `HOME` environment variable even on help/selftest, but only constructs a string; in those modes no file under that path is accessed (`:34`, `:44`, `:184-258`). Source contains transcript-pattern literals such as `op://` and `OP_SESSION_` (`:84,94`) but does not invoke the `op` executable or `the-janitor`, read `~/.config`, or perform socket/network I/O. The only private data source in the normal scan/classify paths is the selected transcript DB plus its sidecars.

## Ledger rows that invoke the scanner

Direct command-field matches are R11-06 and R11-07. Two additional ledger rows invoke it through wrappers:

| Ledger row | Invocation path | Class | Current note tag |
|---|---|---|---|
| `R11-06` (`claim-ledger.tsv:20`) | `bash corpus/transcript-scan.sh` | **HOST** — default DB scan | `[substrate]` |
| `R11-07` (`claim-ledger.tsv:21`) | `bash corpus/transcript-scan.sh --selftest` | **HOST-FREE** — scratch DB selftest | none |
| `R13-03` (`claim-ledger.tsv:38`) | `claim-ledger.sh cells` selects/re-runs claim IDs cited by the real scorecard (`claim-ledger.sh:913-18,932-37`); scorecard `:62` cites both R11-06 and R11-07. | **HOST** as a real-tree `cells` invocation; with host rows enabled it reaches the scanner rows (the current host gate skips tagged rows by default). | `[substrate]` |
| `R15-01` (`claim-ledger.tsv:33`) | Default `checklist-run.sh` executes runnable checklist commands (`checklist-run.sh:256-61`); H7 is `bash corpus/transcript-scan.sh` (`checklist.tsv:40`). | **HOST** — the delegated H7 scan reads the default transcript DB. | `[substrate]` |

`R18-01` is not a scanner caller, but it is the known untagged HOST row to flag: its command is `bash corpus/drift-pins.sh`, and its note says it “must run on every host so it carries no substrate tag” (`claim-ledger.tsv:48`). It is included in the frozen 12-ID C1 host population (`plans/round-24.md:26-31`); C1 must give it the explicit `[host]` treatment rather than let it run untagged. No untagged HOST row was found among the direct/transitive scanner callers above; R11-07 is untagged because it is genuinely host-free.

## Host-free allowlist recommendation / false blocks

The current `claim-ledger.sh` classifier admits only the exact argument string `--selftest` for `corpus/transcript-scan.sh` (`claim-ledger.sh:175-178`); other calls to a declared host-reading script are treated as host (`:169-74,217-21`). That correctly permits current R11-07, but it would falsely classify these host-free modes as untagged-host if represented by an untagged row:

- `-h` and `--help` (read only the invoked repo script; `transcript-scan.sh:44`).
- Valid selftest invocations containing extra parsed `--classify` and/or `--db PATH` options: the selftest branch still wins and does not read the assigned DB (`:41-43,184-258`). A matcher that accepts only the literal whole argument string `--selftest` misses these variants. A `--db` operand consumes the next token, so a parser-aware matcher must not mistake `--db --selftest` for selftest.
- `--db PATH` scan/classify commands only when the DB and sidecars are independently verified to resolve inside an approved scratch/fixture root. Without that containment proof, retain HOST; never whitelist arbitrary `--db` or bare `--classify`.

**Exact semantic allowlist:** (1) `-h|--help` when the scanner parser recognizes it as an option before any DB access; (2) a successfully parsed argument list that sets `SELFTEST=1` (and does not exit via help), including extra recognized flags because the selftest branch ignores them; and (3) otherwise, `--db PATH` with optional `--classify` only when `PATH` and both possible sidecars are proven scratch/fixture-contained. Everything else is HOST. Usage-error exits are host-free in the narrow I/O sense but should not be allowlisted as successful claim modes. If the ledger classifier cannot safely parse option precedence and establish path containment, the minimal safe rule is to allow the canonical bare `--selftest`, `-h`, and `--help` forms, while documenting that noncanonical selftest combinations and fixture-backed `--db` calls will be policy-refused.

## Unresolved / verification boundary

`--db PATH` classification remains conditional on the runtime-resolved file and sidecars; those paths/environment values were not inspected. The report is static source evidence only: none of the ledger's expected outputs/exits was re-measured, and no host mode was run.
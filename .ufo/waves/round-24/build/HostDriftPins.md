# `drift-pins.sh` host-surface classification

## Scope and findings

Static source review only; no `drift-pins.sh` mode was run and no runtime exit code is claimed. The script defaults to `verify`; `--pin` and `--selftest` replace that mode, with the last selector winning. `--baseline F` and `--symbols F` set input/output paths independently; repeated occurrences leave the last value. `-h`/`--help` exits immediately when parsed. Unknown options and missing option values exit before mode dispatch. Evidence: `corpus/drift-pins.sh:39-43,81-91,448-452`.

`HOST` means the effective run reads a host path or host-derived target. `HOST-FREE` means it reads/writes only its own script/repository material and scratch fixtures. The default baseline/symbol files are in the repository, but their rows select `$HOME` files: `corpus/drift-pins.sh:39-42,112-115`; `corpus/drift-baseline.tsv:1-15`; `corpus/drift-symbols.tsv:11-30`.

## Effective modes and flag combinations

| Effective CLI behavior | Class | Reason / evidence |
|---|---|---|
| Bare invocation (default `verify`) | **HOST** | Reads default baseline and symbol rows, expands `$HOME`, then stats/reads the host targets: `corpus/drift-pins.sh:118-162,191-246`; targets below. |
| Default `verify` plus only `--baseline F` | **HOST** | The default symbol file still targets host files (`corpus/drift-symbols.tsv:11-30`). An alternate baseline does not constrain symbol-row paths. |
| Default `verify` plus only `--symbols G` | **HOST** | The default baseline still selects all 15 `$HOME` paths (`corpus/drift-baseline.tsv:1-15`). |
| Default `verify` plus both `--baseline F --symbols G` (either order) | **Conditional**: HOST-FREE only if both files and every path they name are repo/fixture/scratch-only; otherwise **HOST** | Alternate baseline skips `FILES` membership checks, not path validation (`corpus/drift-pins.sh:164-189,198-246`). The script follows the supplied rows; CLI flags alone do not make them safe. The built-in selftest uses scratch-only rows (`:374-400`). |
| Effective `--pin`, with or without either/both path overrides | **HOST** | `pin` always iterates the baked `$HOME` `FILES` array and reads those targets (`corpus/drift-pins.sh:45-62,298-316`); it reads symbol sources too (`:321-362`). It also rewrites the selected baseline/symbol files (`:365-366`). |
| Effective `--selftest`, with or without path overrides | **HOST-FREE** | It ignores parsed baseline/symbol values, creates its own `mktemp` tree, writes fixtures there, and invokes the script with those fixture files (`corpus/drift-pins.sh:373-400,408-439`). |
| `-h` or `--help` (including after already-parsed options) | **HOST-FREE** | Exits in argument parsing and prints only this script's usage text (`corpus/drift-pins.sh:79,87`). |
| Unknown option / missing value for `--baseline` or `--symbols` | **HOST-FREE early error** | Exits during parsing, before verify/pin/selftest dispatch (`corpus/drift-pins.sh:85-90`). This is not a successful check mode. |

Mode selectors can be mixed: the last `--pin`/`--selftest` wins (`corpus/drift-pins.sh:81-90`). Thus `--pin --selftest` is HOST-FREE, while `--selftest --pin` is HOST. Options before a parsed `--help` do not execute a mode. `--baseline`/`--symbols` values are not validated as safe paths.

### Exact host targets in the default `FILES` set

All are `$HOME`-relative host files; the source locations below define the target paths, and the baseline rows pin them. The no-hash paths still get metadata/content-pattern reads, only without a content hash (`corpus/drift-pins.sh:70-77,93-101,142-151,198-246`).

- `$HOME/.local/bin/the-janitor` — `drift-pins.sh:46`; baseline row 1; symbol rows 11-16, 30.
- `$HOME/.config/the-janitor/client.py` — `:47`; baseline row 2; symbol rows 17-18.
- `$HOME/.config/the-janitor/opencode.json` — `:48`; baseline row 3; symbol rows 19-21.
- `$HOME/.config/the-janitor/config.json` — `:49`; baseline row 4; no symbol row; no-hash list `:72`.
- `$HOME/.config/the-janitor/op.env` — `:50`; baseline row 5; symbol row 22; no-hash list `:71`.
- `$HOME/.config/opencode/opencode.json` — `:51`; baseline row 6.
- `$HOME/.config/opencode/agents/janitor.md` — `:52`; baseline row 7; symbol rows 23-24.
- `$HOME/.config/opencode/tools/janitor_auth.ts` — `:53`; baseline row 8; symbol row 25.
- `$HOME/.config/opencode/plugin/fnm-nudge.js` — `:54`; baseline row 9.
- `$HOME/.local/bin/tac-check` — `:55`; baseline row 10; symbol rows 26-27.
- `$HOME/.local/state/tac/daybreak-blue-access.json` — `:56`; baseline row 11; no-hash list `:75`.
- `$HOME/.local/state/the-janitor/tac-daybreak-blue.json` — `:57`; baseline row 12; no-hash list `:76`.
- `$HOME/.local/state/tac/handoff-status.json` — `:58`; baseline row 13; symbol rows 28-29; no-hash list `:74`.
- `$HOME/.agents/AGENTS.md` — `:61`; baseline row 14; no-hash list `:73`.
- `$HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json` — `:62`; baseline row 15.

The read sites are the baseline/symbol loading and host-file stat/hash/regex loops (`corpus/drift-pins.sh:93-101,122-162,191-246,269-362`). `--pin` writes its baseline and symbol destinations (`:365-366`). The source uses local utilities such as `stat`, `wc`, `sha256sum`, and `grep`; static review found no socket/network access, no `op` command invocation, no transcript read, and no execution of the pinned `the-janitor` file. E.g. `op run` and the loopback URL occur as matched text in `corpus/drift-symbols.tsv:12,21,30`, not as commands/network operations.

## Claim-ledger rows invoking the script

Only these three rows match `corpus/drift-pins.sh` in `corpus/claim-ledger.tsv`:

| Ledger row (line) | Invocation | Class | Current note tag |
|---|---|---|---|
| `R11-04` (18) | `bash corpus/drift-pins.sh` | **HOST** (default verify) | `[substrate]` |
| `R11-05` (19) | `bash corpus/drift-pins.sh --selftest` | **HOST-FREE** | none |
| `R18-01` (48) | `bash corpus/drift-pins.sh` | **HOST** (default verify) | none — untagged HOST row; the note explicitly says it must run on every host. |

A refusal based only on the script name would wrongly block the host-free `R11-05 --selftest` entry point (and `--help`). It would also block a fixture-only alternate `verify`, if such a caller were admitted; that case needs input-content/path validation, not just a flag-name exception. `R18-01` is the sole untagged HOST row among these invocations; `R11-04` already carries the tag and `R11-05` is correctly untagged.

## Proposed exact host-free allowlist

For a strict, argument-only ledger policy, allow these exact mode forms for this script:

- `bash corpus/drift-pins.sh --selftest`
- `bash corpus/drift-pins.sh --help`
- `bash corpus/drift-pins.sh -h`

Do not allow bare/default verify, `--pin`, or either single override. Do not allow a two-file alternate `verify` solely because both flags appear: allow it only under a separate content-aware check that both input files and every referenced path stay inside declared repo/fixture/scratch roots. `--selftest` with superfluous baseline/symbol arguments is also host-free by implementation, but keeping the ledger allowlist to the exact canonical command above avoids accepting arbitrary unused arguments. Parsing/error paths are safe early exits, not useful allowlist entries.

## Evidence limitation

No LSP device/server is exposed in the available tool inventory. I used a literal `drift-pins\.sh` search to locate ledger rows; classification comes from reading the relevant shell control flow and row sources, not from grep as semantic proof. No tools were installed or updated.
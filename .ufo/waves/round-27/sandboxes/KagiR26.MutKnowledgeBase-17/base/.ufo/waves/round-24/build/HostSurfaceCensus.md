# Round 24 — `surface-census.sh` host-surface classification

## Scope and method
Static source/data inspection only; no `surface-census.sh` mode or host command was executed, so this report makes no runtime/exit-code claim. LSP was unavailable (`xd://lsp` returned “No such tool”); literal source searches identify textual callers, not semantic references. No tools were installed.

For this classification, HOST means actual access to host paths/state or a host service/tool named in the assignment. The script always snapshots `$HOME` into a shell variable at startup (`corpus/surface-census.sh:79`); that variable expansion alone is not treated as a filesystem read. If “reads `$HOME`” is intended to include even reading the environment variable, every invocation is HOST and no host-free allowlist can exist.

## CLI mode/flag inventory
Argument parsing (`corpus/surface-census.sh:75-102`) defaults to `MODE=verify`; the last of `verify|--verify`, `--verbs`, `--selftest` selects the mode. `--deep` is an independent switch; `--census F`, `--shapes F`, `--baseline F`, `--root D`, and `--verb-root D` are accepted in any order and only affect their corresponding mode. `-h|--help` exits as soon as parsed; unknown flags die. `--deep` alone therefore remains verify, and options irrelevant to the selected mode are ignored.

| Effective invocation family | Class | Source evidence / reason |
|---|---|---|
| No mode flag, `verify`, or `--verify`; default inputs and `ROOT=$HOME` | **HOST** | Defaults are repo census/shape/baseline files and HOME root (`:75-81`). Census/shape inputs are read (`:152-176`, `:321-344`), paths resolve through `ROOT` (`:124-128`), then rows are statted and scanned (`:185-260`, `:343-355`). The committed declarations name host config, state, transcript DB/log, custody, profile and agents paths (`corpus/surface-census.tsv:17-55`; `corpus/state-shape.tsv:27-48`; `corpus/drift-baseline.tsv:1-15`). SQLite reads are from a scratch copy, but the source DB/WAL/SHM are copied from the resolved live host paths (`surface-census.sh:275-279`). |
| Verify plus `--root D` | **HOST** unless `D` is an absolute scratch root and loaded data is repo-only/scratch-only; then **HOST-FREE** | `--root` replaces the root used by `$HOME`/`$STATE` expansion (`:94-98`, `:124-128`). With the committed default data, all declared filesystem paths and scan dirs resolve under that root (`surface-census.tsv:17-55`, `state-shape.tsv:27-48`). |
| Verify plus any of `--census F`, `--shapes F`, `--baseline F` | **HOST** unless each selected input and every path/directive it contains is repo-only or confined to scratch; then **HOST-FREE** | The parser accepts arbitrary file paths (`:94-98`); census and shape files are opened directly (`:154-176`, `:321-344`), and their resolved path entries are read/stat'ed (`:185-260`, `:343-440`). Baseline rows are read by `awk` (`:179-183`). |
| `--verbs`, optionally `--verb-root D` | **HOST** | Scratch overrides cover probe data, not the dependency: `verbs` resolves `$JANITOR` from PATH and invokes the real handler (`:83`, `:466-502`, `:509-579`, `:648-690`). It checks the host tmux session/socket (`:686-689`); its default expected BrowserSupport path is `/opt/1Password/...` (`:498`). Thus `--verb-root` does not make it host-free. |
| `--verbs --deep` (with or without `--verb-root D`) | **HOST** (higher risk) | In addition to the above, deep probes invoke handler `run` with a fabricated env and may contact/prompt the 1Password service (`:580-619`; usage docs `:54-58`). It checks and hashes/stats the real `$HOME/.local/state/the-janitor/tac-daybreak-blue.json`, then calls `tac-register` (`:621-645`). |
| `--selftest` | **HOST**, despite scratch fixture tests | Main tests use a temporary tree and scratch-root verify calls (`:695-765`, `:767-815`), but the selftest checks host PATH for the handler and, if present, invokes it twice in nested `--verbs` runs (`:816-845`). Those verb runs also inspect tmux (`:686-689`). If the handler is absent, those cases skip; that conditional does not make the mode reliably host-free. |
| `-h` or `--help` | **HOST-FREE** (filesystem sense) | Parser prints the script’s own comments and exits (`:99`). Startup snapshots the HOME variable (`:79`) but help does not read the HOME tree, handler, socket, transcript or network. |
| `--deep`, `--verb-root`, or input overrides without a mode selector | Same as default **HOST** verify; override path values may add HOST reads | Default mode is verify (`:81`); flags merely set values (`:92`, `:94-98`). |

The verify path reads metadata/content according to assertion: `stat` kind/mode (`:131-142`, `:189-220`); direct-child enumeration of each `# scan` directory (`:240-260`); file size/line count/header/JSON key names (`:358-388`); and snapshots plus read-only SQLite queries for tables/row counts (`:266-309`, `:389-440`). These are host reads in the default configuration even though the output is count/verdict oriented.

## Ledger callers and tags
Direct `claim-ledger.tsv` command-field callers:

| Row | Effective census mode | Class | Current note tag |
|---|---|---|---|
| `R11-01` (`claim-ledger.tsv:15`) | default verify | **HOST** | `[substrate]` |
| `R11-02` (`:16`) | `--verbs` | **HOST** | `[substrate]` |
| `R11-03` (`:17`) | `--selftest` | **HOST** (conditional real-handler branch) | `[substrate]` |

Indirect callers: `R15-01` (`claim-ledger.tsv:33`, `[substrate]`) runs `checklist-run.sh`; its runnable E1 command is `bash corpus/surface-census.sh >/dev/null && bash corpus/drift-pins.sh` (`corpus/checklist.tsv:26`), and the runner executes runnable rows (`corpus/checklist-run.sh:248-262`). Class: **HOST**. `R13-03` (`claim-ledger.tsv:38`, `[substrate]`) is a conditional indirect caller: `cells` re-runs cited rows (`claim-ledger.sh:919-941`; SCORECARD cites census rows, e.g. `SCORECARD.md:97`, `:105`). The current ledger treats `[substrate]` as HOST and skips host rows by default (`claim-ledger.sh:108-110`, `:517-519`); therefore its current command does not execute the census rows unless run with `--allow-host-rows`.

No direct `surface-census.sh` caller row is untagged. Other untagged HOST rows found in the ledger, outside the direct caller set:

- `R18-01` (`claim-ledger.tsv:48`): **HOST, no tag**; command is `drift-pins.sh`, not `surface-census.sh`. The note itself states this is a host-state return-detection row that must run on every host.
- `R11-08` (`:22`): **HOST, no tag**; `claim-ledger.sh citations` resolves `ufo/…` and sibling-lane citations under `$ROOT/../` (`claim-ledger.sh:554-590`) and the row note requires the fleet checkout layout.
- `R21-01` (`:51`): **HOST, no tag** under the stated definition because its `--dotenv-bytes` probe invokes the `op` CLI. It uses `env -i` with scratch HOME/XDG (`op-ref-probe.sh:258-265`), which isolates its fixture environment but does not change that it runs `op`.

## Host-free allowlist proposal
Allow only these normalized profiles; reject by default otherwise:

1. `surface-census.sh -h` or `surface-census.sh --help` (no other flags).
2. `surface-census.sh [verify|--verify] --root <absolute scratch directory>`, with the three default committed repo inputs **or** explicit `--census`, `--shapes`, and `--baseline` files all inside that scratch tree. Require every census row and `# scan` path to resolve beneath the scratch root, and `TMPDIR` unset or scratch-only. Do not accept `--deep`, `--verbs`, `--selftest`, or `--verb-root` in this profile.

A blanket refusal on the script name would wrongly block the help mode and this scratch-root verify profile. Do **not** classify `--selftest` or `--verbs` as HOST-FREE: their scratch data does not remove their conditional/direct host-handler and tmux access. No invocation was run to test these profiles; this is a source-derived allowlist proposal, not a passed check.
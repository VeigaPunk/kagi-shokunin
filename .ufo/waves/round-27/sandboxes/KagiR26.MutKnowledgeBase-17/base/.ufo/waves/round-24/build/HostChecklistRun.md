# `checklist-run.sh` host-surface classification

## Scope and evidence

Static source reading only; no checklist mode or host gate was executed. LSP was unavailable (`xd://lsp` reported no such mounted tool), so these are literal source findings, not LSP semantic results. `checklist-run.sh` resolves its own repository directory and defaults to that repo's `corpus/checklist.tsv` and `SKILL.md` (`corpus/checklist-run.sh:64-68`). It loads those inputs at `:124-128`, `:168`, `:184-191`; `extract_items` reads the selected skill file at `:102-114`.

The parser accepts flags in any order: `--list`, `--ratio`, and `--selftest` select modes; the last selector determines `MODE`, while `--ratio` also leaves `RATIO_ONLY=1`. `--only`, `--tsv`, and `--skill` are modifiers (`corpus/checklist-run.sh:79-90`). `--help`/`-h` exits immediately after printing comments from the script itself (`:77`, `:87`). Thus the table below describes effective modes; path overrides can change a mode's classification.

## Modes and read surfaces

| Effective invocation | Class | Evidence and reasoning |
|---|---|---|
| No mode selector (default verify) | **HOST** | Verifies the checklist and runs every runnable row; row execution is `cd "$ROOT" && timeout ... bash -c ...` (`corpus/checklist-run.sh:256-262`). Eight of the nine current runnable rows read host-private surfaces or invoke host tooling (below). |
| `--only ID`, ID `E1`, `E5`, `E8`, `H1`, `H3`, `H4`, `H7`, or `H8` | **HOST** | `only_row` delegates runnable rows to `verify` (`corpus/checklist-run.sh:320-332`); `verify` runs only the selected row (`:256-262`). Their concrete reads are listed below. |
| `--only E4` | **HOST-FREE** | E4 scans `.` (`corpus/checklist.tsv:29`), and row checks run with cwd `$ROOT` (`corpus/checklist-run.sh:261`): repository-only input, not a host-private path. |
| `--only E2`, `E3`, `E6`, `E7`, `H2`, `H5`, or `H6` | **HOST-FREE** | These are by-hand rows (`corpus/checklist.tsv:27-28,31-32,35,38-39`). `only_row` prints the by-hand declaration and returns before `verify` (`corpus/checklist-run.sh:327-330`); it reads the declaration TSV only. |
| `--only` unknown ID | **HOST-FREE, error-only** | Loads the TSV, prints `SETUP --only ...: no such row id`, and returns without running a row (`corpus/checklist-run.sh:320-335`). Not a useful allowlisted success mode. |
| `--ratio` (including `--ratio` plus `--only`) | **HOST-FREE** for default repo inputs | `verify` reads SKILL/TSV and returns at `RATIO_ONLY` before the runnable-row loop (`corpus/checklist-run.sh:184-191,248-255`). Any `--tsv`/`--skill` overrides must be repo/fixture/scratch paths; an external host file makes the read HOST. |
| `--list` (including `--list` plus `--only`) | **HOST-FREE** for default repo input | `list_rows` only calls `load_rows` and prints its declaration rows (`corpus/checklist-run.sh:299-318`); it does not read SKILL or run checks. A `--tsv` override must be repo/fixture/scratch, not a host path. |
| `--selftest` | **HOST-FREE** | Creates a `mktemp` tree and writes its own SKILL/TSV fixtures (`corpus/checklist-run.sh:339-357`); child calls use those files (`:411-416`). Its fixture rows use local printf/exit/sleep/true cases (`:358-409`); the deliberately denied `cat op.env`, ledger, and janitor commands are rejected by `load_rows` before execution (`:379-381`, `:149-151`, `:168-171`). |
| `--help` / `-h` | **HOST-FREE** | Reads the script's own comment header only via `awk` (`corpus/checklist-run.sh:77,87`). |
| `--tsv F`, `--skill F`, or both with default verify | **HOST / conditional; not a host-free mode** | These flags only override inputs; absent a no-execution selector the mode remains verify and executes declared runnable checks (`corpus/checklist-run.sh:85-86,256-262`). A host-path input is a host read; arbitrary fixture rows may themselves read host surfaces. |
| `--list` / `--ratio` with `--tsv` and/or `--skill` | **HOST-FREE only when every file actually read is repo/fixture/scratch** | `--list` reads TSV only (`:304`); `--ratio` reads both selected inputs but no check (`:184-191,248-255`). An external absolute host path changes the classification. `--skill` is unused in list mode. |
| Invalid or missing-value arguments | **HOST-FREE, error-only** | Parser prints an error and exits 2 (`corpus/checklist-run.sh:84-89`); not a valid result mode. |

## Host-facing runnable rows

- **E1** delegates to `surface-census.sh` and `drift-pins.sh` (`corpus/checklist.tsv:26`). Census defaults `ROOT` to `$HOME` (`corpus/surface-census.sh:79-83`), expands and stats census paths (`:124-142,152-176,185-237`), and scans declared directories (`:240-260`); its default verify dispatch loads and checks those surfaces (`:853-858`). Drift pins its `$HOME` files (`corpus/drift-pins.sh:45-62`), expands them and reads baseline-pinned files (`:93-101,112-162`); bare mode defaults to verify (`:43`, `:448-451`).
- **E5** invokes `op-ref-probe.sh` (`corpus/checklist.tsv:30`). Its default verify mode uses `op` from PATH and `$HOME/.local/bin/the-janitor` (`corpus/op-ref-probe.sh:65,69-70,783-789`); `op_exec` invokes the binary (`:248-265`) and verify collects/evaluates probes (`:473-489`). Its generated plain-value fixtures and reference guard do not make this an op-free invocation.
- **E8** reads `~/.local/state/tac/handoff-status.json` (`corpus/checklist.tsv:33`). **H1** reads `$HOME/.local/bin/the-janitor` and stats `$HOME/.local/state/the-janitor/client.lock` (`:34`). **H3** reads two `~/.config/.../opencode.json` files (`:36`). **H4** reads `~/.config/opencode/agents/janitor.md` (`:37`). **H8** reads two `$HOME` files and queries listening/established sockets with `ss` (`:41`).
- **H7** invokes `transcript-scan.sh` with no override (`corpus/checklist.tsv:40`). It defaults to `$HOME/.local/state/the-janitor/xdg-data/opencode/opencode.db` (`corpus/transcript-scan.sh:34-35`) and copies that DB plus WAL/SHM before scanning (`:260-274`).
- **E4** is the sole runnable HOST-FREE check; its recursive grep is rooted at the repo working directory (`corpus/checklist.tsv:29`; `corpus/checklist-run.sh:261`).

## Ledger mapping and tags

| Ledger row (`corpus/claim-ledger.tsv`) | Effective invocation | Class | Current note tag |
|---|---|---|---|
| R15-01 (`:33`) | `bash corpus/checklist-run.sh` | HOST | `[substrate]` |
| R15-02 (`:34`) | `bash corpus/checklist-run.sh --selftest` | HOST-FREE | none |
| R15-03 (`:35`) | `bash corpus/checklist-run.sh --list` | HOST-FREE | none |
| R15-05 (`:37`) | `bash corpus/checklist-run.sh --ratio` | HOST-FREE | none |

R15-04 (`:36`) counts `checklist.tsv` directly; it does not invoke this script. There is no untagged HOST row among the checklist-run invocations: R15-01 is tagged. The known untagged host row R18-01 is separate (`claim-ledger.tsv:48`): bare `drift-pins.sh` expands/reads the `$HOME` file set at `corpus/drift-pins.sh:45-62,112-162`; its ledger note explicitly says it has no substrate tag. It is not an invocation of `checklist-run.sh`.

## Script-name refusal and proposed exact allowlist

`claim-ledger.sh` declares this as a host-reading script, and its current exception matches only exact `--selftest`, `--list`, or `--ratio` argument strings (`corpus/claim-ledger.sh:169-185,217-221`). Those exceptions correctly preserve R15-02/03/05. They would wrongly block other real HOST-FREE uses: `--help`/`-h`; default-TSV `--only E4`; and `--only E2`, `E3`, `E6`, `E7`, `H2`, `H5`, or `H6`. A literal-argument matcher also blocks safe local-input forms such as `--list --tsv <repo/fixture>` or `--ratio --tsv <repo/fixture> --skill <repo/fixture>`, and safe permutations where the no-execution selector is not the first argument. Do not broadly allow `--tsv`/`--skill` with default verify.

Recommended allowlist by **effective parsed mode**, with every file actually read constrained to repo/fixture/scratch paths:

1. `--help` or `-h` (immediate exit); `--selftest` (self-generated scratch fixtures only).
2. `--list` (selected TSV only) and `--ratio` (selected TSV + SKILL, no row execution).
3. `--only E4` and `--only E2|E3|E6|E7|H2|H5|H6`, only with trusted repo/default or scratch inputs. Do not include unknown IDs as accepted claim modes: they are free only because they fail before execution.

Treat all other effective verify invocations—including bare verify and `--only E1|E5|E8|H1|H3|H4|H7|H8`—as HOST. Parse flags to determine the effective mode rather than matching only the first raw argument; path-bearing overrides must be checked before receiving a HOST-FREE exception.
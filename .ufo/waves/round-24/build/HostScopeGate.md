# `scope-gate.sh` host-surface classification

Static source review only; no `scope-gate.sh` mode was executed. I used literal source/ledger search and targeted reads. The mounted tool set has no `lsp` device (`read xd://lsp` returned “No such tool”), so no semantic LSP result was available; findings below are grounded in the shell source and its explicit call sites.

## CLI modes and flags

Parser accepts mode selectors in any order; the last reached selector among `verify`, `--verify`, `--map`, `--breadth`, `--selftest`, and `--falsify` determines dispatch (parser: `corpus/scope-gate.sh:104-119`; dispatch: `:1125-1129`). `-h|--help` exits immediately when parsed (`:116`), so later arguments are not processed. Path flags are accepted independently of mode. Missing values/unknown arguments call `die` before `gate`/`falsify`/`selftest` (`:102-118`).

| Invocation / effective mode | Classification | Reason and source evidence |
|---|---|---|
| No mode; `verify`; `--verify` | **HOST** by default | Default is `MODE=verify`; `ROOT` defaults to `$HOME` (`:89,93,106`). `gate` reads the repo data and census (`:183-188,193-236,238-262`), expands `$HOME` in census paths (`:121-124`), then probes path existence/symlinks and resolves paths (`:403-419`). The shipped census includes `$HOME/.config/the-janitor/op.env`, the-janitor executable/state, and the durable `opencode.db` transcript path (`corpus/surface-census.tsv:21-55`; especially `:24,30,45`). These are filesystem metadata/path checks, not reads of those private file contents. It also reads cited basis lines with `sed` (`scope-gate.sh:155-162`); current `lane:` citations resolve under the fleet lane root (`:90-91,336-346`; `corpus/adjacency.tsv:82,84`). |
| `--map` | **HOST** by default | Dispatches to the same `gate` (`:1128`); map output is added after verification, not instead of it (`:621-630`). |
| `--breadth` | **HOST** by default | Also dispatches to `gate`; it stats/resolves the `$HOME` breadth roots and enumerates direct children with `find` (`:550-568`). Shipped breadth roots are `$HOME/.config/opencode`, `$HOME/.local/bin`, `$HOME/.agents`, and the Chrome profile (`corpus/adjacency.tsv:75-78`). |
| `--falsify` | **HOST** with default inputs/root | It creates its mutation copies in `mktemp` scratch (`:674-705`), but invokes the gate repeatedly with `--root "$ROOT"` and inherited basis/lane roots (`:680-684`); default `ROOT` is `$HOME` (`:89`). Gate runs therefore perform the same host path checks; the row note independently says two breadth mutations measure live host counts (`claim-ledger.tsv:41`). It writes mutations only to its temporary directory, not the shipped data/census. |
| `--selftest` | **HOST-FREE** | The test creates a temporary tree (`:816-831`) and its normal gate runner explicitly supplies temporary data, census, host-root fixture, basis root, and lane root (`:873-879`); the `--breadth` case does likewise (`:899-900`). Other selftest gate calls shown in `:1072-1085,1113-1115` also use scratch paths or fail on the missing scratch input before traversal. It does not use ambient `ROOT` for its gate calls. |
| `-h` / `--help` | **HOST-FREE** | Prints the script’s own usage comment using `sed` and exits (`:116`); it does not call `gate`. |
| Unknown arg / missing value | **HOST-FREE** (no gate run) | Parser emits usage/setup error via `die` and exits before dispatch (`:102-118`). |

Path modifiers `--data F`, `--census F`, `--root D`, `--basis-root D`, `--lane-root D` (parser `:111-115`) and environment equivalents `ADJ_DATA`, `ADJ_CENSUS`, `ADJ_HOME`, `ADJ_BASIS_ROOT`, `ADJ_LANE_ROOT` (`:87-91`) are **input-dependent**, not safe modes: the data/census files are opened at `:183-188,193-236,238-262`; the root controls `$HOME` expansion and host checks (`:89,121-124,403-419`); basis files are tested/read at `:336-367,155-162`; `lane:` citations use `LANE_ROOT` (`:342-343`). For `verify`/`map`/`breadth`/`falsify`, these combinations are host-free only when every effective input and expanded root is confined to scratch/fixture/repository material; pointing any one at an external host path remains HOST. `--selftest` uses its own fixed scratch inputs even if path options were parsed; `--help` exits before any such inputs are opened.

Mode combinations are order-sensitive: e.g. `--selftest --map` ends in HOST `map`, while `--map --selftest` ends in HOST-FREE `selftest`; checking only for presence of the `--selftest` token is unsafe. `--help` is a short-circuit wherever it is reached.

## Ledger callers and note tags

Only these four ledger commands invoke `scope-gate.sh` (`corpus/claim-ledger.tsv:39-41,45`):

| Ledger row | Command | Class for recorded invocation | Current note tag |
|---|---|---|---|
| R16-01 (`:39`) | `bash corpus/scope-gate.sh` | HOST | `[substrate]` |
| R16-02 (`:40`) | `bash corpus/scope-gate.sh --selftest` | HOST-FREE | none |
| R16-03 (`:41`) | `bash corpus/scope-gate.sh --falsify` | HOST | `[substrate]` |
| R17-01 (`:45`) | `bash corpus/scope-gate.sh --breadth` | HOST | `[substrate]` |

No scope-gate HOST caller is untagged. The known untagged HOST row R18-01 is **not** a scope-gate caller: it runs `bash corpus/drift-pins.sh` and its note explicitly says “no substrate tag” (`claim-ledger.tsv:48`). R16-02’s untagged status is appropriate because the recorded selftest is scratch-only.

## Refusal collision and allowlist

A refusal keyed only on the basename `scope-gate.sh` would wrongly block the real HOST-FREE ledger invocation `R16-02 --selftest`; it would also unnecessarily refuse `-h|--help`. Do not allowlist the script basename and do not treat any mode token’s mere presence as sufficient.

**Exact unconditional host-free mode allowlist:**

1. `--selftest` only when it is the final effective mode selector (its internally executed gates use scratch roots/inputs).
2. `-h` or `--help` when reached (it exits immediately before input reads).

Do not unconditionally allowlist `verify`/`--verify`, `--map`, `--breadth`, or `--falsify`. A caller-specific invocation of those modes can be HOST-FREE only after verifying all path flags and relevant `ADJ_*` environment values resolve strictly to scratch/fixture/repository paths; that is a path-constrained exception, not a mode-name allowlist. In particular, `--falsify` is not safe by its name because it forwards the default `$HOME` root.

## Verification boundary

No runtime command, host mode, test, or check was run; this is a static classification, not a claim that any ledger expectation currently passes. Static evidence is the source/ledger line references above. No tools were installed or updated.
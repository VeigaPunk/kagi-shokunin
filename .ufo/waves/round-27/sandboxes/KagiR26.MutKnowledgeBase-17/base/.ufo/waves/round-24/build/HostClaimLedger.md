# C1 — `claim-ledger.sh` host-surface classification

## Scope and method

Static source/ledger reading only; **no ledger mode or host mode was executed**. I read `corpus/claim-ledger.sh`, the matching `corpus/claim-ledger.tsv` rows, and the committed hermetic-cells fixture. The requested LSP device is unavailable here (`read xd://lsp` returned “No such tool”; mounted-device listing contains no LSP), so findings are based on cited source lines, not semantic-server references. No tool was installed or updated.

Classification uses the prompt’s boundary: repo/fixture/scratch inputs are HOST-FREE; paths outside this lane root (including absolute sibling/fleet paths), `$HOME` probes, and modes that can run tagged host probes are HOST. `SCRIPT_DIR` and default `ROOT` resolve to this checkout (`corpus/claim-ledger.sh:117-120`); the checkout’s own physical absolute path is not alone treated as a host-private surface.

## CLI modes and flags

The parser accepts `verify` (also the no-mode default), `citations`, `cells`, `docs`, `stamp`, `--selftest`, plus `-h|--help`; mode selectors can appear in the same argument stream, with the last selector determining `MODE` (`:281-315`). The mode and the path/permission flags therefore have to be classified together:

| Invocation shape | Class | Read/surface evidence |
|---|---|---|
| `-h` / `--help` | HOST-FREE | Exits while printing this script’s header; reads only `${BASH_SOURCE[0]}` via `sed` (`:298`). |
| `--selftest` **without path overrides** | HOST-FREE (scratch) | Creates a `mktemp` tree and fixtures (`:1143-1171`), then exercises nested modes against `$R`; the substrate test cases force `KAGI_SUBSTRATE=present|absent` or get skipped before substrate detection (`:1551-1558`). It does not use the real ledger/root. An external `--root` is not safe: `[[ -d $ROOT ]]` is checked before the selftest branch (`:316`, `:1142-1149`). |
| `docs` with default repo root and default/relative entry dir | HOST-FREE (repo) | Reads the selected entries, claims IDs and stamps under `ROOT` (`:973-997`); the entry-dir argument rejects absolute paths and `..` (`:979-981`). External `--root`, `--claims` or `--stamps` values make the invocation HOST. |
| `stamp` with default/repo-confined root, inputs and output | HOST-FREE (repo-only, **write mode**) | Reads an existing output and input files under `ROOT` (`:335-385`), then replaces the output (`:387-390`). Input paths reject absolute/`..` and symlink escape (`:366-381`), but an external `--root` or absolute `--out` can read/write a host path (`:335-341`). HOST-FREE does not mean suitable for a claim row: this mode mutates the stamp file. |
| `citations` with default docs | **HOST** | The default set is lane-root docs/knowledge/lessons (`:619-633`), but a cited sibling path is resolved with `[[ -e $ROOT/../$t ]]`, `ufo/*` checks `$ROOT/../.ufo`, and `.ufo/*` falls back there after the lane-first check (`:572-589`). The scanner reads each selected doc (`:642-703`). Lane-first `.ufo` lookup does not remove the fleet/sibling fallback. A citation run is HOST-FREE only if its explicit root and docs are confined and their candidate tokens cannot resolve outside that root; the bare `citations` spelling does not establish that. |
| `verify` / default mode | **HOST-capable; current default ledger is HOST** | Reads stamps and pinned files (`:404-427`, `:441-451`), reads claim rows and executes eligible commands (`:488-545`), and scans docs/IDs (`:713-785`). The current `R11-08` command runs the untagged `citations` exception, which reaches sibling/fleet paths. Other host rows are skipped or refused unless explicitly authorized (below). A hand-built, fully fixture-confined `verify` can be HOST-FREE as a standalone mode (the selftest demonstrates scratch verifies at `:1420-1441`), but a nested claim-row `verify` is intentionally refused (`:317-325`), so it is not a useful claim-row exception. |
| `cells` on the real/default root | **HOST-capable; classified HOST** | Scans the docs, scorecard and stamps, then re-runs scorecard-selected claim rows (`:751-785`, `:822-953`). The source explicitly states real-tree `cells` is host-free only over a committed fixture root because the real scorecard cites host rows (`:168-173`). Host-tagged rows are gated by `verify_claims` (`:504-527`). |
| `cells` on the committed hermetic fixture, with all five fixture paths explicitly supplied | HOST-FREE (fixture) | Exact current invocation is the `R23-01` row below. Its selected rows are a local fixture script and a local grep (`corpus/fixtures/cells-hermetic/claims.tsv:1-2`); the helper only prints a literal (`corpus/fixtures/cells-hermetic/corpus/fx-ok.sh:1-2`). The row’s fixture description also states no `$HOME`, substrate probe or network (`corpus/claim-ledger.tsv:59`). |

Flag effects (all are parsed at `corpus/claim-ledger.sh:286-294`):

- `--root`: any external/absolute root is HOST for every non-help mode (`:316`); default is this repo (`:117-120`). A `--root` argument cannot by itself make `cells` hermetic.
- `--claims`, `--stamps`, `--scorecard`, `--docs`: each is a direct file/path override. If it points outside the selected repo/fixture, the consuming mode is HOST. Consumers: claims/stamps in `verify`, `cells`, `docs` (`:404-427`, `:488-545`, `:973-997`); scorecard in `cells` (`:827-889`); docs in citations/idref (`:625-660`, `:751-785`). `--docs` is not a confinement check; it is split into the scan list (`:625-632`).
- `--out`: relevant to `stamp`; an absolute target can be read if it exists and then replaced (`:335-363`, `:387-390`), so it is not HOST-FREE under this boundary.
- `--allow-host-rows`: HOST escalation for `verify`/`cells`. It is the sole consent flag (`:294`); without it tagged rows print `HOST-SKIP` (`:516-519`), while an untagged declared host invocation is `POLICY` (`:511-515`). With it, a `[substrate]` row may call `substrate_present`, which checks `$HOME/.local/bin/the-janitor` unless `KAGI_SUBSTRATE` overrides it (`:146-162`, `:520-522`); then eligible rows are run (`:524-527`). The host script inventory includes census, drift, transcript, op-ref, checklist, scope and claim-ledger scripts (`:168-174`), so transcript/op/host surfaces are delegated through selected claim commands, not opened directly by this file.
- `--prune` only changes stamp replacement policy; `--orphans` only enables orphan output (`:292-293`, `:351-363`, `:779-783`). Neither makes a local invocation HOST by itself. `stamp --prune` remains a write mode.
- `stamp` positional input paths and `docs`’ optional positional entry dir are local only when relative and contained; absolute/`..` inputs are refused (`:307-312`, `:366-381`, `:979-981`).

## Ledger rows invoking `claim-ledger.sh`

“Tag” is the current literal note tag; none means neither `[host]` nor `[substrate]` is present.

| Row (path:line) | Exact mode | Class | Tag | Basis |
|---|---|---|---|---|
| `R11-08` (`corpus/claim-ledger.tsv:22`) | `citations` | **HOST** | none | Note itself says fleet checkout is required; default citation resolution probes sibling/fleet absolute paths (`claim-ledger.sh:572-589`). This is the current untagged HOST row. |
| `R11-09` (`corpus/claim-ledger.tsv:23`) | `--selftest` | HOST-FREE | none | Scratch selftest only (`claim-ledger.sh:1143-1171`). |
| `R13-03` (`corpus/claim-ledger.tsv:38`) | bare `cells` | HOST-capable real-tree mode | `[substrate]` | Correctly tagged HOST under the real-root rule (`claim-ledger.sh:168-173`, `:822-953`). It is skipped by default; authorization may run it/defer its substrate dependency. |
| `R14-01` (`corpus/claim-ledger.tsv:32`) | bare `docs` | HOST-FREE | none | Default repo knowledge-entry/claims/stamps reads (`claim-ledger.sh:973-997`). |
| `R18-03` (`corpus/claim-ledger.tsv:50`) | `--selftest` | HOST-FREE | none | Same scratch-only mode as R11-09. |
| `R23-01` (`corpus/claim-ledger.tsv:59`) | `cells` with explicit `corpus/fixtures/cells-hermetic/{claims,stamps,SCORECARD}.md` paths | HOST-FREE | none | All five root/data/doc inputs are the committed fixture; its two claim commands are local (`corpus/fixtures/cells-hermetic/claims.tsv:1-2`). |

Other untagged HOST row: `R18-01` (`corpus/claim-ledger.tsv:48`) invokes `bash corpus/drift-pins.sh` and has no tag. It is not a `claim-ledger.sh` invocation, but it is in `HOST_SCRIPT_RE` and is not the drift selftest exception (`claim-ledger.sh:173-180`); current `host_invocation` therefore makes it `POLICY untagged-host` (`:214-221`, `:511-515`). The note says it “must run on every host”; that expectation conflicts with this guard. Add `[host]` rather than `[substrate]` if the intended operation is to run only after explicit host-row authorization without substrate-absence deferral.

## Allowlist assessment and exact proposal

The present exception `citations` is unsound: `host_free_args` returns free for that bare arg (`claim-ledger.sh:182-183`), but `R11-08` reaches external sibling/fleet path checks. The existing `cells --root corpus/fixtures/*` wildcard is also broader than the proven hermetic invocation (`:182-183`): it does not require the five matching fixture inputs and also accepts trailing flags such as `--allow-host-rows` (`:286-294`). Narrow those cases; keep the fixture exception argument-exact.

For the **claim-row host-free bypass**, the exact current allowlist should be only:

1. `corpus/claim-ledger.sh --selftest` — exact args, no custom root/path overrides.
2. `corpus/claim-ledger.sh docs` — exact args/default repo root and data.
3. `corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims corpus/fixtures/cells-hermetic/claims.tsv --stamps corpus/fixtures/cells-hermetic/stamps.tsv --scorecard corpus/fixtures/cells-hermetic/SCORECARD.md --docs corpus/fixtures/cells-hermetic/SCORECARD.md` — this exact committed fixture tuple only.

Do **not** allow bare `citations`, bare/default `cells`, `verify`, or `--allow-host-rows`. Do not use a script-name-only refusal: it would falsely classify and block the three safe current rows R11-09, R14-01 and R23-01 (also R18-03), plus scratch-fixture citations/selftest cases. At the CLI classification level, `--help` and repo-confined `stamp` are also HOST-FREE; do not grant `stamp` a claim-row bypass because it mutates the pinned output, which should be refused for write-safety rather than mislabeled HOST. A custom citations run is not generally allowlistable from its mode name: only a separately pinned local-only docs/input tuple can be proved HOST-FREE.

Static evidence only; no shell mode was run, so no runtime verdict/exit code is claimed.
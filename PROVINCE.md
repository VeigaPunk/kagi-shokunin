# kagi-shokunin — Province

**Domain:** secrets & vault ops — the-janitor flows, credential hygiene evidence

**Owns:** the domain knowledge, playbooks, error patterns, and checklists above.
**Refuses:** anything outside this domain; report cross-domain evidence back to the orchestrator rather than absorbing it.

## Surfaces (each path resolves on this host 2026-09-28; this list is the declaration `corpus/surface-census.sh` enforces — round-10 census: 20 asset / 15 runtime rows, `scanned=4`, `absent=2` (both runtime, informational — `session-id` while stopped + its shape row), symlinks=0, `UNLISTED=0`)

Handler:
- `~/.local/bin/the-janitor` (755, 333 lines) — the CLI: `status`/`start`/`stop`/`request`/`run`/`refs`/`whoami`/`cdp-bridge`/`tac-check`/`tac-register`/`_serve` (hidden)
- `~/.config/the-janitor/client.py` (755, 117 lines) — HTTP client: session-id, `THE_JANITOR_REQUEST_TIMEOUT` (the `client.lock` flock lives in the CLI, not here — measured round 15: `grep -nic lock client.py` ⇒ 0; `the-janitor` holds `LOCK_FILE` at L12, `exec 9>"$LOCK_FILE"` at L130/139/175 and `flock 9` at L131/140/176)
- `~/.config/the-janitor/opencode.json` (644) — model overlay (`enabled_providers`, `share: disabled`, `baseURL`)
- `~/.config/the-janitor/op.env` (600) — env-ref file; values never read into an artifact
- `~/.config/the-janitor/config.json` (600) — **inert** decoy (not an opencode-discovered filename; round 6)

Opencode layer that reaches the handler:
- `~/.config/opencode/opencode.json` (644, 455 lines) — global config, merged *under* the overlay
- `~/.config/opencode/agents/janitor.md` — `steps: 4`, `permission: {"*": deny, janitor_auth: allow}`
- `~/.config/opencode/tools/janitor_auth.ts` — `AUTH_OK`/`AUTH_REQUIRED` only
- `~/.config/opencode/plugin/fnm-nudge.js` — global plugin, fails to load at every serve

Runtime state (mutates legitimately; pinned by **shape**, never by content — `corpus/state-shape.tsv`):
- `~/.local/state/the-janitor/{client.lock,session-id}` (600; `session-id` is a conversation marker, ABSENT while stopped); `xdg-data/opencode/opencode.db` (transcripts, 0600; magic + mode + table/row floors); `xdg-data/opencode/log/opencode.log` (0600, size floor); `xdg-data/opencode/{repos,opencode.db-shm,opencode.db-wal}` (created on boot / WAL siblings); `xdg-cache/opencode/models.json` (0600, public catalog)
- The 4 enumerable dirs (`$HOME/.config/the-janitor`, `$STATE`, `$STATE/xdg-data/opencode`, `~/.local/state/tac`) are scanned one level deep: an **undeclared** child is `UNLISTED` + exit 1 — this is the detection path for the round-6 vector (a file dropped into `$CONFIG_DIR` is loaded by the handler)

Evidence/custody:
- `~/.local/bin/tac-check` (755, 88 lines) — offline receipt check
- `~/.local/state/tac/daybreak-blue-access.json`, `~/.local/state/tac/handoff-status.json`, `~/.local/state/the-janitor/tac-daybreak-blue.json`

Network surfaces:
- control plane `127.0.0.1:40961` (unauthenticated OpenCode server, round 7)
- configured model endpoint `127.0.0.1:8080` (dead: Jitsi) vs live llama-server on `34113`
- CDP `9222` + `~/.local/share/the-musketeer/chrome-profile` — **contested with kake** (lease/profile ownership unresolved; kagi pins only the 1Password native-messaging manifest — the profile dir itself is presence-only, mode unchecked). Declared as a partition row in `corpus/adjacency.tsv` (`kake` / `contested` / `presence-only`), so drifting the profile dir to an exact mode pin is `OVERCLAIM`, exit 1 (round 16)

Gates in this repo:
- `corpus/surface-census.sh` — the declaration gate over the surface list above. `verify` (default): kind/exact mode per declared path, `UNLISTED` children of the 4 enumerable dirs, and the runtime shape pins; `--verbs` exercises the local write-side verbs on scratch overrides (no `op` exec); `--verbs --deep` adds the three probes with a real-world effect (`op run` plain / ref, `tac-register` no-replace) and is operator-present; `--selftest` proves 16 cases on a scratch tree. Exit 0/1/2; `UNVERIFIED` (a shape class that cannot be read) fails the run, `SKIP` (DB locked by a live serve) does not. Data: `corpus/surface-census.tsv` (35 rows, pinned by ledger row `R11-11`), `corpus/state-shape.tsv` (22 rows, pinned by `R11-10`; this said 21 until round 11). Round 10: `CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`.
- `corpus/drift-pins.sh` + `corpus/drift-baseline.tsv` (15 files) + `corpus/drift-symbols.tsv` (20 claims — 20 since round 12 added the `cmd_run` L248 `exec op run` row, the masking premise) — byte/line/symbol drift; modes cross-checked against the census
- `corpus/transcript-scan.sh` — transcript-leak gate over the durable DB
- `corpus/op-ref-probe.sh` — the `op.env` contract gate: `refs` (`cmd_refs` awk) vs `op run --env-file` (what `cmd_run` execs) over generated plain-value fixtures, plus the dotenv edge classes, precedence, four error signatures and the masking scope. `--selftest` proves 29 cases (comparator, POLICY-before-exec for a ref token / symlink / FIFO / premise break, SETUP, the hard-failure class); POLICY refuses any op-side fixture carrying a ref token, so the gate never resolves a reference. Exit 0/1/2. Data: the contract arrays in the script (there is no TSV — the fixtures are generated from the contract).
- `corpus/checklist-run.sh` — the credential-hygiene checklist as executable rows: `corpus/checklist.tsv` holds one row per SKILL.md checklist item (8 columns: `id class lead check expect_exit expect_last reason note`), each either `runnable` (a command + expected exit + expected last output line) or `by-hand` (a closed class + a unique ≥24-char reason). The `lead` ERE is a bijection over the 16 items, so an item with no row, a row with no item, a duplicated lead/item, a below-floor runnable ratio (`ceil(items/2)`) and a repeated by-hand reason are all defects. A `check` naming a denied surface (`op.env`, `op run|read|inject`, handler start/stop/run, `claim-ledger.sh`) is `POLICY`, exit 2 — the gate never reads `$CONFIG_DIR/op.env`, never resolves a reference and never starts the handler. `--list` prints the map, `--only ID` runs one row, `--selftest` proves 28 cases on scratch fixtures. Round-15 baseline: `CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7 failed=0)` + `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7`, exit 0. Data: `corpus/checklist.tsv` (16 rows).
- `corpus/scope-gate.sh` — the ownership partition over the census declaration: `corpus/adjacency.tsv` declares 5 `# own` prefixes (27 census rows this domain owns outright) and 4 group rows covering the other 8 (owner / status / claim / basis + token / note). It fails closed on an uncovered shared row (`FOREIGN`), a group covering nothing (`ORPHAN`), an owner/status/claim outside the closed sets, a basis that does not resolve (`NOT-A-FILE`) or whose cited line(s) omit the surface token (`STALE-BASIS` — the `corpus/README.md:76` class), a contested row drifted to an exact mode (`OVERCLAIM`, claim↔mode is biconditional), a `# scan` dir outside an owned prefix (`FOREIGN-SCAN`), an owned row resolving outside the owned set (`ESCAPE`), a shared row resolving into it (`INBOUND`), an unreadable/unresolvable path (`UNVERIFIED`, fail closed) and a meaningless `# no-enumerate` (`ENUM-CLASH`). `--map` prints the per-row partition; `--selftest` proves 29 cases on a scratch tree. Exit 0/1/2. `unresolved` (arbiter named) and `contested` are declared classes — counted, exit-neutral.
- `corpus/claim-ledger.sh` — the calibration gate: `verify` (revision stamps + claim rows + every `R…-…` id a checked doc cites), `citations` (durable evidence), `cells` (every `SCORECARD.md` round cell must carry a pointer that resolves *and still holds*: cited rows are re-run, cited pinned artifacts re-compared, a section missing an axis is a setup error), `docs` (every `corpus/knowledge/*.md` entry must declare its re-verification — `Reverify: R11-04, R11-05` or `Reverify: by-hand: <class> — <reason>` — and be a row in the stamps file; the by-hand class is bounded and at least half the entries must name a row), `stamp` (reviewed re-pin). Data: `corpus/claim-ledger.tsv` (18 rows), `corpus/stamps.tsv` (44 rows). Exit 0/1/2; `--selftest` proves 94 cases on scratch trees.

**Deliberate refusals:** vault-side structure (which vaults/items/fields exist) stays unmapped — mapping it would put ref paths in a durable artifact; `op` item-level reads stay unexercised; the CDP lease/profile ownership question is reported to the integrator, never adjudicated here.
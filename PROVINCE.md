# kagi-shokunin — Province

**Domain:** secrets & vault ops — the-janitor flows, credential hygiene evidence

**Owns:** the domain knowledge, playbooks, error patterns, and checklists above.
**Refuses:** anything outside this domain; report cross-domain evidence back to the orchestrator rather than absorbing it.

## Surfaces (each path resolves on this host 2026-09-28; this list is the declaration `corpus/surface-census.sh` enforces — round-10 census: 20 asset / 15 runtime rows, `scanned=4`, all absent=0, symlinks=0, `UNLISTED=0`)

Handler:
- `~/.local/bin/the-janitor` (755, 333 lines) — the CLI: `status`/`start`/`stop`/`request`/`run`/`refs`/`whoami`/`cdp-bridge`/`tac-check`/`tac-register`/`_serve` (hidden)
- `~/.config/the-janitor/client.py` (755, 117 lines) — HTTP client, lock, session-id, `THE_JANITOR_REQUEST_TIMEOUT`
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
- CDP `9222` + `~/.local/share/the-musketeer/chrome-profile` — **contested with kake** (lease/profile ownership unresolved; kagi pins only the 1Password native-messaging manifest — the profile dir itself is presence-only, mode unchecked)

Gates in this repo:
- `corpus/surface-census.sh` — the declaration gate over the surface list above. `verify` (default): kind/exact mode per declared path, `UNLISTED` children of the 4 enumerable dirs, and the runtime shape pins; `--verbs` exercises the local write-side verbs on scratch overrides (no `op` exec); `--verbs --deep` adds the three probes with a real-world effect (`op run` plain / ref, `tac-register` no-replace) and is operator-present; `--selftest` proves 16 cases on a scratch tree. Exit 0/1/2; `UNVERIFIED` (a shape class that cannot be read) fails the run, `SKIP` (DB locked by a live serve) does not. Data: `corpus/surface-census.tsv` (35 rows, pinned by ledger row `R11-11`), `corpus/state-shape.tsv` (22 rows, pinned by `R11-10`; this said 21 until round 11). Round 10: `CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`.
- `corpus/drift-pins.sh` + `corpus/drift-baseline.tsv` (15 files) + `corpus/drift-symbols.tsv` (19 claims) — byte/line/symbol drift; modes cross-checked against the census
- `corpus/transcript-scan.sh` — transcript-leak gate over the durable DB

**Deliberate refusals:** vault-side structure (which vaults/items/fields exist) stays unmapped — mapping it would put ref paths in a durable artifact; `op` item-level reads stay unexercised; the CDP lease/profile ownership question is reported to the integrator, never adjudicated here.
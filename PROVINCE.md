# kagi-shokunin — Province

**Domain:** secrets & vault ops — the-janitor flows, credential hygiene evidence

**Owns:** the domain knowledge, playbooks, error patterns, and checklists above.
**Refuses:** anything outside this domain; report cross-domain evidence back to the orchestrator rather than absorbing it.

## Surfaces (each path resolves on this host as of 2026-09-28; round-9 census: all absent=0, symlinks=0)

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

Runtime state (mutates legitimately; not pinned):
- `~/.local/state/the-janitor/{client.lock,session-id}`; `xdg-data/opencode/opencode.db` (transcripts, 0600); `xdg-data/opencode/log/opencode.log`

Evidence/custody:
- `~/.local/bin/tac-check` (755, 88 lines) — offline receipt check
- `~/.local/state/tac/daybreak-blue-access.json`, `~/.local/state/tac/handoff-status.json`, `~/.local/state/the-janitor/tac-daybreak-blue.json`

Network surfaces:
- control plane `127.0.0.1:40961` (unauthenticated OpenCode server, round 7)
- configured model endpoint `127.0.0.1:8080` (dead: Jitsi) vs live llama-server on `34113`
- CDP `9222` + `~/.local/share/the-musketeer/chrome-profile` — **contested with kake** (lease/profile ownership unresolved; kagi pins only the 1Password native-messaging manifest)

Gates in this repo:
- `corpus/drift-pins.sh` + `corpus/drift-baseline.tsv` (15 files) + `corpus/drift-symbols.tsv` (19 claims)
- `corpus/transcript-scan.sh` — transcript-leak gate over the durable DB

**Deliberate refusals:** vault-side structure (which vaults/items/fields exist) stays unmapped — mapping it would put ref paths in a durable artifact; `op` item-level reads stay unexercised; the CDP lease/profile ownership question is reported to the integrator, never adjudicated here.
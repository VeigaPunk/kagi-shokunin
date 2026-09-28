# kagi-shokunin corpus — index

Proprietary memory for the secrets & vault ops domain (the-janitor flows,
credential-hygiene evidence). Seeded 2026-09-28 by the round-1 **aggregator L1**
because kagi was deferred that round (`MANIFEST.json` →
`rounds[1].lanes.kagi: "not-dispatched"`); filled and reconciled in round 2
by the kagi L1.

Every entry was written from read-only inspection of real files on this host.
No vault access was performed: no `op` vault command, no `the-janitor request`,
no janitor tmux session was started (`tmux ls` showed only `ufo_sighting`).
No secret value, session token, or vault ref path is copied into this corpus —
see `lessons/round-1.md` for the rule and its rationale.

## Coverage map

| Area | Entry | Source basis (read 2026-09-28) |
|---|---|---|
| CLI command surface + failure texts | `knowledge/janitor-command-surface.md` | `~/.local/bin/the-janitor` (333 lines), `~/.config/the-janitor/client.py` (117 lines) |
| Credential isolation of the handler | `knowledge/credential-isolation.md` | `the-janitor` `cmd_serve`, `~/.config/the-janitor/opencode.json`, `~/.config/opencode/agents/janitor.md`, `~/.config/opencode/tools/janitor_auth.ts` |
| Vault-ref env file discipline | `knowledge/op-env-refs.md` | `the-janitor` `cmd_refs` / `cmd_run`, `stat` on `~/.config/the-janitor/op.env` (path + mode only) |
| TAC / local-evidence integrity | `knowledge/tac-evidence-integrity.md` | `~/.local/bin/tac-check` (88 lines), `~/.local/state/tac/handoff-status.json`, `~/.agents/AGENTS.md` |
| 1Password ↔ Chrome CDP bridge | `knowledge/cdp-bridge-1password.md` | `the-janitor` `cmd_cdp_ensure` / `cmd_cdp_status`, live `cdp-bridge status` output, `op --version` |
| Round-1 status + lessons | `lessons/round-1.md` | `MANIFEST.json rounds[1]`, `LOG.md`, `SKILL.md`, `SHONEN.md` |
| Round-1 aggregator audit | `lessons/round-1-aggregator-audit.md` | corpus conformance check per `~/projects/shokunin/CORPUS.md` |
| Round-1 deferral & seed lessons (aggregator) | `lessons/round-1-aggregator-seed.md` | `MANIFEST.json rounds[1]`, `.ufo/watchdog.log`, `.ufo/waves/round-1.json`, `LOG.md` round-2 entry, commit `9b3e49f` |
| `op` CLI auth states + endpoint drift | `knowledge/op-cli-surface.md` | live `op account list`, `the-janitor whoami`, `the-janitor request` attempt, `ss`/`curl` port probes, `cmd_stop` read |
| Round-3 attempt + drift lesson | `lessons/round-3.md` | the same probes; `the-janitor stop` idempotence observed |
| Env-var contract + auth selectors | `knowledge/janitor-env-contract.md` | `~/.local/bin/the-janitor` L7–27, L194–210; live `op account get` shape; `refs` output |
| Session-id / lock lifecycle, rotation & revocation surfaces | `knowledge/janitor-lifecycle.md` | `the-janitor` L128–249 (`cmd_request`/`stop`/`run`/`refs`), `client.py` L41–95, `janitor_auth.ts`; live `status`/`whoami`/dir/tmux/curl probes |
| Round-5 lifecycle lesson | `lessons/round-5.md` | same probes; no drift vs round-4 |
| Opencode config layering + inert `config.json` | `knowledge/config-layering.md` | `opencode debug config`/`debug agent janitor` under the `_serve` env (resolved dump: 9 providers, 23 agents, global plugin loaded; `steps: 4`); `the-janitor` `cmd_serve`; binary `customize-opencode` doc |
| Host-file drift pins | `corpus/drift-pins.sh` | sha256/mode/line-count of every cited file, pinned 2026-09-28 |
| Round-6 layering lesson | `lessons/round-6.md` | same probes |
| Handler on-disk state: transcript DB, error log, lock topology, wedge recovery | `knowledge/handler-on-disk-state.md` | `xdg-data/opencode/opencode.db` sqlite introspection (row counts, `$.type` shapes only), `opencode.log` forensics (8 runs since 2026-08-29), `the-janitor` lock pairs L130–131/139–140/175–176, measured wedge timings |
| Control-plane trust boundary: unauthenticated port 40961, `/session/{id}/shell` direct exec, agent/`tools`-map ceiling scope, daemon-env inheritance, squat-phish surface | `knowledge/handler-trust-boundary.md` | scratch `opencode serve` repros (no-auth 200 vs `OPENCODE_SERVER_PASSWORD` 401/Basic-only; `/doc` 162 routes; shell route 51 ms no-model; `tools` override under `agent:"janitor"`; fake `OP_*` env echo; clean-shell `op` negative control), `client.py` header audit, `ServerAuthConfig` + plugin-loader strings in binary, tmux 3.7b env-passthrough test |
| Control-plane hardening handoff (operator recipe) | `knowledge/control-plane-hardening.md` | the same probes; `client.py` Authorization gap; sequencing analysis |
| Round-7 boundary lesson | `lessons/round-7.md` | same probes + L2 verification wave |
| Transcript hygiene gate (script) | `transcript-scan.sh` | immutable-URI sqlite3 over `xdg-data/opencode/opencode.db`; 270 cells × 30 patterns (25 HIT + 5 WARN) + 5 credential-table tripwires; `--selftest` seeded-hit check |
| Transcript hygiene (entry) | `knowledge/transcript-hygiene.md` | schema census (text columns + credential tripwires), two-tier semantics, baseline 0 HIT / 4 WARN, read-side immutability re-verified |
| Round-8 lesson | `lessons/round-8.md` | false-positive taxonomy on first contact; WARN-as-hygiene-metric; README rot fix |

## Known gaps

- `SKILL.md` rewritten in round 2: decision table, hygiene checklist,
  evidence-receipt patterns, anti-patterns — all grounded in the corpus above.
- `SHONEN.md` boxes: the end-to-end `the-janitor request` was **attempted**
  round 3 — full pipeline ran, died at the 1Password auth gate (`handler
  exited before becoming ready`, ~60 s, exit 1). A *successful* model reply
  still needs an operator-side `op signin` (account registered but signed out)
  plus the endpoint-drift fix below.
- `~/.config/the-janitor/config.json` (0600, 406 bytes) — **resolved round 6:
  inert.** `config.json` is not an opencode-discovered filename (discovery =
  `opencode.json`/`opencode.jsonc`/`.opencode/`, plus `OPENCODE_CONFIG`
  overlay and global `~/.config/opencode/`); zero references in `the-janitor`.
  Its `agent.janitor.steps: 8` loses to `janitor.md` `steps: 4` (proven by
  `opencode debug agent janitor`). Dead config, keep out of the live model;
  see `knowledge/config-layering.md`.
- `op` CLI behaviours exercised through round 4: `account list` and
  `account get` both work signed out (values PII — shape only recorded),
  `whoami` exit 1 `account is not signed in`, `signin` dies non-interactive
  inside `_serve`. Round-4 resolved the two open items: `account get` JSON
  shape (fields incl. `domain`, consumed by `_serve` L203) and the
  service-account path (`OP_SERVICE_ACCOUNT_TOKEN` skips the interactive
  chain entirely; `OP_ACCOUNT` selects accounts). Still open: nothing named —
  `op run` internals and item-level reads stay deliberately unexercised.
- **Global-layer leak (open, operator decision):** round 6 proved
  `OPENCODE_CONFIG` is additive — the handler merges global
  `~/.config/opencode/opencode.json`, loads all 23 agents and global plugin
  `fnm-nudge.js`, and would pick up a project `opencode.json` dropped into
  `$CONFIG_DIR` (discovery not disabled). Containment holds via
  `enabled_providers` + last-match permission deny + `_serve` env scrub
  (`config-layering.md`). Hardening options (not ours to apply):
  `OPENCODE_DISABLE_PROJECT_CONFIG=1`, a dedicated XDG_CONFIG_HOME, or
  `--pure`.
- **Model endpoint drift (open, operator decision):** `opencode.json`
  `baseURL` pins `127.0.0.1:8080/v1` but 8080 is a Jitsi videobridge;
  llama-server serves the pinned model on **34113** (re-verified 2026-09-28
  `/health` ok). Round-4 sharpened the fix: `MODEL_ENDPOINT` (script L19)
  is cosmetic `status` output only; the one load-bearing field is
  `provider.qwen-local.options.baseURL`. No env override exists — requests
  keep hitting the dead endpoint (exponential `stream error` retries in
  `opencode.log`) until the overlay field is corrected.
- **Unauthenticated control plane (open, operator decision):** round 7 proved
  `opencode serve` on 40961 takes requests with no auth
  (`OPENCODE_SERVER_PASSWORD` unset — server warns `server is unsecured`).
  The message `agent` field picks the permission set, so the janitor deny
  ceiling is bypassable by any local process, and tool subprocesses inherit
  the daemon env (`OP_SESSION_*`/`OP_SERVICE_ACCOUNT_TOKEN`). Fix = password
  + `client.py` Authorization header, sequenced in
  `control-plane-hardening.md`.
- **Transcript persistence (open):** request text is durable in
  `xdg-data/opencode/opencode.db` (0600) past `stop`; no purge verb. Treat
  request stdin as at-rest data; reset = stop + `rm -rf xdg-data`.
  Round 8 added the gate: `corpus/transcript-scan.sh` + `knowledge/
  transcript-hygiene.md` — baseline 0 HIT / 4 WARN cells (credential-language
  request text, no material), credential-bearing tables all empty.
- Vault-side structure (which vaults/items exist, field naming conventions) is
  deliberately unmapped; mapping it would put ref paths in a durable artifact.
- Secret-rotation/revocation: resolved round 5 — no verb exists by design;
  `janitor-lifecycle.md` documents per-class rotate-at-source and `stop` as
  the revocation primitive. Vault-side ops stay operator surfaces.
- Cross-domain: CDP port 9222 and the musketeer chrome profile are shared with
  the webzites kimi fleet (kake province) — ownership of the shared browser
  lease is unresolved here; reported to the integrator, not absorbed.

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

## Known gaps

- `SKILL.md` rewritten in round 2: decision table, hygiene checklist,
  evidence-receipt patterns, anti-patterns — all grounded in the corpus above.
- `SHONEN.md` boxes: the end-to-end `the-janitor request` was **attempted**
  round 3 — full pipeline ran, died at the 1Password auth gate (`handler
  exited before becoming ready`, ~60 s, exit 1). A *successful* model reply
  still needs an operator-side `op signin` (account registered but signed out)
  plus the endpoint-drift fix below.
- `~/.config/the-janitor/config.json` (0600, 406 bytes) shape known (key names
  + types only: second OpenCode overlay); values unrecorded by design.
- `op` CLI behaviours exercised through round 4: `account list` and
  `account get` both work signed out (values PII — shape only recorded),
  `whoami` exit 1 `account is not signed in`, `signin` dies non-interactive
  inside `_serve`. Round-4 resolved the two open items: `account get` JSON
  shape (fields incl. `domain`, consumed by `_serve` L203) and the
  service-account path (`OP_SERVICE_ACCOUNT_TOKEN` skips the interactive
  chain entirely; `OP_ACCOUNT` selects accounts). Still open: nothing named —
  `op run` internals and item-level reads stay deliberately unexercised.
- **Model endpoint drift (open, operator decision):** `opencode.json`
  `baseURL` pins `127.0.0.1:8080/v1` but 8080 is a Jitsi videobridge;
  llama-server serves the pinned model on **34113** (re-verified 2026-09-28
  `/health` ok). Round-4 sharpened the fix: `MODEL_ENDPOINT` (script L17)
  is cosmetic `status` output only; the one load-bearing field is
  `provider.qwen-local.options.baseURL`. No env override exists — requests
  would fail at prompt time even with auth fixed.
- Vault-side structure (which vaults/items exist, field naming conventions) is
  deliberately unmapped; mapping it would put ref paths in a durable artifact.
- Secret-rotation/revocation: resolved round 5 — no verb exists by design;
  `janitor-lifecycle.md` documents per-class rotate-at-source and `stop` as
  the revocation primitive. Vault-side ops stay operator surfaces.
- Cross-domain: CDP port 9222 and the musketeer chrome profile are shared with
  the webzites kimi fleet (kake province) — ownership of the shared browser
  lease is unresolved here; reported to the integrator, not absorbed.

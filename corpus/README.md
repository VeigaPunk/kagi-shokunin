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

## Known gaps

- `SKILL.md` rewritten in round 2: decision table, hygiene checklist,
  evidence-receipt patterns, anti-patterns — all grounded in the corpus above.
- `SHONEN.md` boxes unchecked: promotion is gated on an end-to-end domain task
  executed and logged; round 2 performed read-only inspection + skill writing.
  An end-to-end `the-janitor request` run remains the missing proof.
- `~/.config/the-janitor/config.json` (0600, 406 bytes) shape known (key names
  + types only: second OpenCode overlay); values unrecorded by design.
- `op` CLI behaviours beyond `--version` (2.35.0 at `/usr/bin/op`) are
  unexercised: signin flow, `account get` JSON shape, service-account path.
- Vault-side structure (which vaults/items exist, field naming conventions) is
  deliberately unmapped; mapping it would put ref paths in a durable artifact.
- No entry yet on secret-rotation or revocation practice: no evidence of either
  was found in the inspected surfaces.
- Cross-domain: CDP port 9222 and the musketeer chrome profile are shared with
  the webzites kimi fleet (kake province) — ownership of the shared browser
  lease is unresolved here; reported to the integrator, not absorbed.

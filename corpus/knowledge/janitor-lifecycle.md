# janitor lifecycle — session-id, lock, rotation & revocation surfaces

Source basis: `~/.local/bin/the-janitor` (`cmd_request` L121–135, `cmd_start`
L138–143, `cmd_stop` L173–184, `cmd_run` L237–249), `client.py` L41–95,
`~/.config/opencode/tools/janitor_auth.ts`, live probes 2026-09-28
(`status`, `whoami`, `ls -la` on both state dirs, tmux, curl 34113/8080).
Line numbers date to this read — re-grep before citing.

This entry closes the README gap "no entry on secret-rotation or revocation
practice". Finding: **no rotation verb exists by design** — the architecture
makes revocation a side effect of process lifetime, and rotation a side effect
of editing the source-of-truth secret.

Reverify: R11-01, R11-04

## The state objects and what revoking them means

| Object | Nature | Lifetime | Kill semantics |
|---|---|---|---|
| `STATE_DIR/client.lock` (0600) | flock serialization file, 0 bytes | persistent; recreated by `prepare_state` (L66) if absent | not a secret; deleting mid-request deadlocks nothing — next caller recreates, but in-flight `flock 9` still holds the old inode. Never edit while a request may be running |
| `STATE_DIR/session-id` (0600) | OpenCode **conversation id**, written by `client.py` `get_session_id` (L57–63) after `POST /session` | persists across requests while the server runs | **context, not credential.** Deleting it just forks a new conversation — `get_session_id` falls back to `POST /session` if the file is missing or `GET /session/<id>` 404s (L41–46). `stop` removes it (L183); `ensure_started` also removes it when a foreign server squats the port is ruled out and tmux session is absent (L92–97) |
| `OP_SESSION_<domain>` env | live 1Password session token | daemon-process memory only (`authorization process_memory_only` — `status` L170) | `stop` kills the tmux session → token dies with the process. **This is the entire revocation surface for handler auth.** |
| `OP_SERVICE_ACCOUNT_TOKEN` env | caller-provided SA token, read once by `_serve` (L194) | daemon-process memory only | same — dies at `stop`. Changing it requires `stop` + re-export + next `request`/`start` |
| `STATE_DIR/xdg-data/opencode/opencode.db` + `…/log/opencode.log` (0600) | opencode transcript DB (plaintext request/reply text, tool parts) and ERROR log | **persistent** — created under `_serve`'s `XDG_DATA_HOME`, written every request | `stop` does **not** purge either; no verb does. Transcript reset = `stop` + `rm -rf $STATE_DIR/xdg-data` (round-7 finding — see `handler-on-disk-state.md`) |

## Rotation, per secret class

There is no `rotate`/`refresh` subcommand anywhere in `usage()`. What actually
happens per class:

- **`op://` refs in `op.env`:** rotate in the vault item (1Password side).
  `op run --env-file` re-resolves refs on every invocation, so `the-janitor
  run -- <cmd>` picks the new value with **no restart needed**. `op.env` is
  untouched — refs are stable pointers.
- **Raw values in `op.env`** (observed: `XAI_TEAM_ID`, `TOKEN_PLAN_INFNET_IDENT`):
  edit `op.env` directly (0600, never `cat` into artifacts). Same as above —
  effective on next `run`.
- **`OP_SERVICE_ACCOUNT_TOKEN`:** rotate at the IdP/vault, then `stop` + export
  the new token in the environment of the *next* `request`/`start` invocation
  (the caller's env is what `_serve` inherits via the tmux daemon command).
- **`OP_SESSION_<domain>` (app-auth path):** `op` handles session expiry
  internally on `op signin`; `stop` forces a fresh interactive signin on next
  start. Operator-side `op signout` / app lock is the preemptive kill.

## Revocation evidence trail (what to record)

- `the-janitor stop` output: `stopped` (had session) vs `already stopped`
  (L179–181) — both exit 0, both `rm -f session-id`.
- Post-stop `status` shows `state stopped`; `handler_session` line disappears.
- Vault-side revocation (`op signout`, item deletion, SA-token deactivation)
  is **not observable** through any janitor verb — `janitor_auth` is the only
  lazy probe, and it only runs *inside* a model request (spawned `op vault
  list`, exit 0 → `AUTH_OK`). A revoked vault surfaces as `AUTH_REQUIRED` at
  next request time, never sooner. No watch/revocation hook exists.
- `whoami` is caller-side `op whoami`, not handler auth — it answers "is *my*
  op signed in", predicting whether `_serve`'s `signin` will die; it says
  nothing about a running handler's token validity.

## Verification probes (deterministic, no vault access)

```
the-janitor status            # state stopped | handler_session pending|<id>
ls -la ~/.local/state/the-janitor/   # client.lock, session-id presence/modes
tmux has-session -t janitor   # handler process liveness (exit 1 if absent)
```

`session-id` is a plain UUID-shaped string; it authorizes nothing by itself —
it only lets a client *continue* a conversation on the localhost server. But
round 7 showed the server itself is vault-capable when running (daemon env
carries `OP_SESSION_*`/`OP_SERVICE_ACCOUNT_TOKEN`) and the port is
unauthenticated — see `handler-trust-boundary.md`; the ceiling binds the
`agent` field, not the socket.

## Anti-claims (bounds)

- There is no offline revocation check: `stop` output does not prove vault-side
  state, only process state.
- `session-id` in an artifact is metadata (it names a dead conversation once
  stopped), but the rule stays: keep it out — no benefit, habit-forming risk.
- Nothing here implies 1Password-side rotation happened or will; vault ops are
  operator surfaces, deliberately unmapped (see README known gaps).

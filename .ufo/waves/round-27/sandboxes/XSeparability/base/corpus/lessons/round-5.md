# Lessons — round 5

Round context: kagi L1 dispatched (`.ufo/prompts/kagi-round-5.md`). Goal:
highest-value corpus gap. Two candidates: the README's explicit "no entry on
secret-rotation or revocation" gap vs re-verifying endpoint drift (already an
operator decision — re-probing adds nothing). The lifecycle gap won: it was
the last *named* knowledge hole and the answer was non-obvious.

## What happened

Read `cmd_request`/`cmd_start`/`cmd_stop`/`cmd_run`/`cmd_refs` (L128–249) and
the full `client.py` (L41–95) for session-id semantics; `janitor_auth.ts` for
the auth probe. Live probes: `status` (stopped), `whoami` (signed out, exit
1), dir listings (state dir contains only `client.lock`, `tac-daybreak-blue.json`,
xdg dirs — no `session-id`, consistent with stopped), tmux (`ufo_sighting`
only), curl 34113 (`/health` ok) / 8080 (404 — drift persists, unchanged).

## What worked

- **The gap resolves to a non-obvious negative:** there is no rotate or
  revoke subcommand because the design doesn't need one. Authorization is
  `process_memory_only` — `stop` *is* the revocation primitive for every
  secret the handler holds (`OP_SESSION_*`, `OP_SERVICE_ACCOUNT_TOKEN`).
- **`session-id` is not a credential.** `client.py` `get_session_id` creates
  it via `POST /session`, reuses it if `GET /session/<id>` says it exists,
  self-heals otherwise. `stop` removes it (L183). It's conversation context —
  no vault access attaches to it. Prior anti-patterns treated its absence as
  cleanliness evidence; the sharper truth is it was never sensitive.
- **Rotation is class-dependent and split across surfaces:** `op://` refs and
  raw values rotate in place and need no restart (`op run` re-reads `op.env`
  each call); only the two env vars that `_serve` materializes at daemon
  start need `stop`+restart. Documenting "restart vs no-restart" per class is
  the operationally load-bearing distinction.
- **Revocation is lazy, not eager.** `janitor_auth` is a spawned `op vault
  list` exit-code probe that only runs *inside* a model request. A
  vault-side revocation (`op signout`, item delete, SA-token kill) is
  invisible until the next request returns `AUTH_REQUIRED`. No watch exists.

## What failed / newly discovered

- Nothing failed; no drift found (endpoint still 404 on 8080, model still ok
  on 34113, account still signed out — all match round-4 state).

## Rules extracted (carry forward)

1. When a named gap resolves to "the verb doesn't exist," the corpus entry
   must document the *mechanism that makes it unnecessary* (process-lifetime
   revocation) — the absence is the finding, not a blocker.
2. `stop` = revoke. Any evidence trail claiming "authorization discarded"
   needs `stop`'s `stopped`/`already stopped` output + post-stop `state
   stopped`, not just the exit code.
3. Restart-required is per secret class: `_serve`-env secrets yes, `op.env`
   secrets no. Table it; don't say "restart the handler" generically.
4. `session-id` is metadata not credential — but still keep it out of
   artifacts; the rule costs nothing and avoids habit drift.

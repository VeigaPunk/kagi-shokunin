# the-janitor environment-variable contract

Source: `~/.local/bin/the-janitor` read 2026-09-28 (sha256
`2408b0c9…57edd`, 333 lines). The script's env reads are concentrated at
L7–27 (path/port knobs) and `cmd_serve` L194–210 (auth selectors). No knob
list exists in `usage()` — this table is the only complete inventory.

## Knob table

| Variable | Default | Read at | Effect |
|---|---|---|---|
| `THE_JANITOR_ENV` | `~/.config/the-janitor/op.env` | L7 | env-file path for `refs`/`run` |
| `THE_JANITOR_CONFIG_DIR` | `~/.config/the-janitor` | L8 | dir holding `opencode.json` + `client.py` |
| `THE_JANITOR_STATE_DIR` | `~/.local/state/the-janitor` | L11 | lock, `session-id`, `xdg-*` quarantine |
| `THE_JANITOR_PORT` | `40961` | L15 | OpenCode listen port; also passed to `client.py` for health checks |
| `THE_JANITOR_REQUEST_TIMEOUT` | `3600` s | client.py L74 | per-request prompt timeout |
| `MUSKETEER_CHROME_PROFILE` | `~/.local/share/the-musketeer/chrome-profile` | L22 | NMH target profile for `cdp-bridge` |
| `ONEPASSWORD_BROWSER_SUPPORT` | `/opt/1Password/1Password-BrowserSupport` | L25 | support binary path written into manifest |
| `MUSKETEER_CDP_PORT` | `9222` | L26 | CDP reachability probe port |
| `OP_SERVICE_ACCOUNT_TOKEN` | unset | L194 | **auth selector**: present ⇒ skip `account get`/`signin`/`whoami` entirely; `op` uses the token env var natively |
| `OP_ACCOUNT` | unset | L196–197 | account selector: expands to `--account <value>` on `account get`, `signin`, `whoami` — matters only when >1 account is registered |

## Auth selector semantics (`cmd_serve` L194–210)

```
if OP_SERVICE_ACCOUNT_TOKEN set:   # L194 — token already in env
    use as-is; op client authorizes itself
else:
    account_args = [--account $OP_ACCOUNT] if set
    domain = op account get $args --format=json | .domain   # L200–203
    session_var = "OP_SESSION_${domain}"                    # L204
    export session_var = $(op signin $args --raw)           # L205–207
    unset session_token
    op whoami $args >/dev/null                              # L209 verify
```

- Path 2 fails closed on every stage: `account get` non-zero ⇒ `set -e` aborts;
  `signin` dies non-interactively (round-3 evidence); `whoami` verifies.
- Path 1 is the **non-interactive route**: no desktop-app integration, no
  prompt, no `op signin` at all. It is the documented way to run the handler
  headless — but the token must arrive in `_serve`'s environment (caller env
  or tmux session env); nothing in the script injects it.
- `OP_ACCOUNT` selects among registered accounts; `op account get` returns
  `{"url","email","user_uuid","account_uuid","domain","type","state",…}` —
  observed live 2026-09-28 while signed out (it reads on-disk registration,
  no auth needed). Field **values are account-identifying PII**: key names
  only, never values, in artifacts.
- `OP_SESSION_<domain>` is the 1Password session-token convention; the script
  builds the var name dynamically from `op account get .domain`.

## The endpoint is *not* a knob

`MODEL_ENDPOINT="http://127.0.0.1:8080/v1"` (L17) is a hardcoded literal used
**only** by `cmd_status` to print the `endpoint` line — it is never exported
and never reaches OpenCode. The request path's real endpoint is
`provider.qwen-local.options.baseURL` inside `opencode.json` (the overlay).
Consequence for the round-3 drift (real server on 34113, Jitsi on 8080):

- fix = edit `opencode.json` `baseURL` (one field), no env override exists;
- `status`'s `endpoint` line will then disagree with the fixed overlay until
  L17 is updated too — the status line is cosmetic, the overlay is truth.

## Leak-surface notes

- `_serve` unsets ~19 model/API credential vars (L214–219) but **not**
  `OP_SESSION_*`, `OP_ACCOUNT`, or `OP_SERVICE_ACCOUNT_TOKEN` — the first two
  are the auth mechanism, the last is expected (it *is* the auth). A stray
  caller-side `OP_SESSION_<other-domain>` would survive into the handler env.
- `prepare_state` enforces `umask 077` + `chmod 700/600` on every file it
  creates; env vars named above are never written to disk.
- Observed env-file reality (2026-09-28 `refs`, 10 keys): 8 keys hold
  `op://` refs, 2 hold **raw values** (`XAI_TEAM_ID`,
  `TOKEN_PLAN_INFNET_IDENT` — identifier-class, not secrets; still at 0600
  and redacted by `refs`). The convention "everything is an `op://` ref" is
  aspirational, not enforced.

## Falsification

- `grep -n 'OP_\|THE_JANITOR\|MUSKETEER\|ONEPASSWORD' ~/.local/bin/the-janitor`
  reproduces the knob table (L7–27, L194–210).
- `grep -n 'MODEL_ENDPOINT\|baseURL' ~/.local/bin/the-janitor
  ~/.config/the-janitor/opencode.json` shows the two endpoint strings and
  which is load-bearing.
- `op account get --format=json` prints the field list above while signed
  out (PII — record shape only).
- `THE_JANITOR_ENV=/nonexistent the-janitor run -- true` →
  `the-janitor: missing /nonexistent`, exit 2 (env-file check precedes the
  missing-command check; `run` with no args → `missing command`, exit 2).

# `op` CLI surface — caller-side auth states and the signin gap

Source: live probes 2026-09-28 (`op` 2.35.0 at `/usr/bin/op`), plus `cmd_serve`
auth path in `~/.local/bin/the-janitor` L194–210. **No secret values, account
emails, or UUIDs are recorded here — key names and exit codes only.** `op
account list` output is account-identifying PII even though it is metadata;
treat its *values* like `refs` output: internal, never pasted into artifacts.

## Observed command surface

| Command | Observed 2026-09-28 | Exit | Auth needed? |
|---|---|---|---|
| `op --version` | `2.35.0` | 0 | no |
| `op account list --format=json` | JSON array, one element, fields `url`, `email`, `user_uuid`, `account_uuid` (all strings) | 0 | no — reads on-disk account registration |
| `the-janitor whoami` (= caller-side `op whoami`) | `[ERROR] … account is not signed in` | 1 | yes — fails fast, **does not block or prompt** |
| `op signin --raw` inside `cmd_serve` | killed the handler: `handler exited before becoming ready` after ~60 s | 1 (wrapper) | yes — dies non-interactively when the account is signed out and no desktop approval is pending |

## The auth matrix this implies

`cmd_serve` offers exactly two auth paths (credential-isolation.md §1):

1. `OP_SERVICE_ACCOUNT_TOKEN` already in env → used as-is.
2. Otherwise `op signin --raw` → token into `OP_SESSION_<domain>` (domain
   parsed from `op account get --format=json`) → verified by `op whoami`.

Path 2 assumes an interactive desktop session where `op signin` can complete.
On 2026-09-28 the account was registered (`account list` non-empty) but signed
out (`whoami` exit 1), and `signin` inside the tmux `_serve` died instead of
prompting — the failure surfaces as the generic readiness text, not as an
`op`-specific error. **Caller-side `the-janitor whoami` exit 1 is the cheapest
predictor that a `request` will die in the readiness loop.**

## Endpoint drift: the second readiness blind spot

The overlay pins `qwen-local` at `http://127.0.0.1:8080/v1`
(`opencode.json`). On 2026-09-28 port 8080 was held by a **Jitsi videobridge**
(Jetty 404 on `/health`, `/v1/models`, `/metrics` served `jitsi_jvb_*`
metrics), while the real `llama-server` for the same model file listened on
port **34113** (`/health` → `{"status":"ok"}`, `/v1/models` lists
`Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS.gguf`).

Neither `status` nor `ensure_started` probes the model endpoint: readiness
checks only `GET /global/health` on the OpenCode port (40961). A request can
therefore pass the entire startup gate and still fail at prompt time against a
squatted endpoint — today it would have gotten Jetty 404s.

Cheap drift check before relying on the handler:

```
curl -fsS --max-time 2 "$(the-janitor status | awk '/^endpoint/{print $2}' \
  | sed 's|/v1$||')/health"
```

(llama.cpp `/health` → `{"status":"ok"}`; a foreign listener 404s or closes.)

## `cmd_stop` is idempotent and cleans stale session state

Observed: a `session-id` file left over from a previous crash (present since
Sep 21, tmux session long gone) was removed by `the-janitor stop` even though
it printed `the-janitor: already stopped` and exited 0 — `rm -f
"$SESSION_FILE"` runs unconditionally at L184. After the failed `request`
attempt (handler died in readiness), **no janitor tmux session and no
session-id remained**; `stop` was still safe to run as cleanup.

## Falsification

- `the-janitor whoami` → `[ERROR] … account is not signed in`, exit 1
  (while the account stays signed out).
- `op account list --format=json` → non-empty array with the four fields
  above (values withheld here by rule).
- `ss -tlnp | grep 8080` + `curl 127.0.0.1:8080/metrics` → Jetty/`jitsi_jvb_*`
  while the drift persists; `curl 127.0.0.1:34113/health` → ok.
- `the-janitor stop` twice → second run prints `already stopped`, exit 0.

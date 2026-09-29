# the-janitor command surface and failure texts

Source: `~/.local/bin/the-janitor` (333 lines, bash, `set -euo pipefail`,
`umask 077`) and `~/.config/the-janitor/client.py` (117 lines), both read
2026-09-28. Line numbers below refer to those files as read that day; re-grep
before trusting a number.

Reverify: R11-02, R11-04

## Verb table (from `usage()` + the `case "${1:-help}"` dispatcher, L293–333)

| Verb | What it does | Authority |
|---|---|---|
| `request` | reads ONE request from **stdin**, lazy-starts/reuses tmux `janitor`, posts it to the handler | `cmd_request` L121–135 |
| `start` | lazy-start the detached handler only | `cmd_start` L137–143 |
| `status` | metadata-only: session, model, endpoint, health, authorization lifetime | `cmd_status` L145–171 |
| `stop` | kills the tmux session and removes `session-id` (discards in-memory authorization) | `cmd_stop` L173–184 |
| `whoami` | `op whoami` **in the caller's env** — does not use handler authorization | L311–314 |
| `refs` | lists the `^[A-Z][A-Z0-9_]*=` lines + `op://` refs from the env file, redacting non-ref values — an **incomplete** inventory: `export K=v`/spaced/lowercase/indented/digit-leading lines are omitted, duplicate keys are listed once per line, a quoted `"op://…"` is reported as a non-ref, and a file the resolver rejects still prints clean (`knowledge/op-ref-consumption.md`) | `cmd_refs` L228–235 |
| `run [--] <cmd>` | one-shot `op run --env-file=…` | `cmd_run` L237–249 |
| `tac-register` | execs `~/.local/bin/tac-check --register` | L295–298 |
| `tac-check` | execs `~/.local/bin/tac-check` | L299–302 |
| `cdp-bridge ensure\|status\|open-popup` | 1Password NativeMessagingHosts manifest / reachability / refused | L320–331 |
| `_serve` | internal: the daemon body executed inside tmux | `cmd_serve` L186–226 |

Unrecognized verb → `usage` on stderr, exit 2 (L332).

## Request contract (the only persistent path)

- Arguments are rejected, not tolerated: `[[ $# -eq 0 ]] || exit 2` with
  `the-janitor request: request text must be supplied on stdin, not as arguments`
  (L122–125). Rationale visible in the header comment: secret values must never
  land in process arguments (argv is world-readable via `/proc`).
- Interactive stdin prints `type the request, then press Ctrl-D` (L126–128).
- Serialization is a `flock` on `$STATE_DIR/client.lock` held across
  `ensure_started` + the client call (L130–134): one janitor request at a time,
  machine-wide.
- Empty stdin → client exits 2 with `the-janitor request: read an empty request
  from stdin` (`client.py` L69–71).

## Startup gates (`ensure_started`, L77–119)

| Gate | Failure text | Exit |
|---|---|---|
| missing `tmux` / `python3` / `op` / `opencode` | `the-janitor: required command not found: <cmd>` (`need_command` L52–56) | 2 |
| `client.py` not executable | `the-janitor: missing executable client: …/client.py` | 2 |
| overlay unreadable | `the-janitor: missing model overlay: …/opencode.json` | 2 |
| port 40961 already healthy **outside** tmux `janitor` | `the-janitor: port 40961 already has an OpenCode server outside tmux session janitor` | 1 |
| handler died during readiness loop | `the-janitor: handler exited before becoming ready` + `Enable 1Password Settings -> Developer -> Integrate with 1Password CLI, unlock the app, then retry.` | 1 |
| readiness loop exhausted (120 × 0.5 s = 60 s) | `the-janitor: handler is waiting for 1Password authorization` + `Unlock 1Password and approve the CLI request; … tmux attach -t janitor` | 1 |

Readiness probe = `client.py health` → `GET http://127.0.0.1:40961/global/health`
with a 2 s timeout, true only when the JSON body has `healthy === true`
(`client.py` L98–100, `server_healthy` L72–75).

## Handler HTTP contract (`client.py`)

| Call | Shape | Notes |
|---|---|---|
| session reuse | read `$STATE_DIR/session-id`; `GET /session/<id>`; accept only when `result.id == session_id` | L41–55 |
| session create | `POST /session {"title":"janitor persistent local handler"}` | L57; then `mkdir 0700` + write id + `chmod 0600` (L61–63) |
| prompt | `POST /session/<id>/message` with `model {providerID:"qwen-local", modelID:"Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS"}`, `agent:"janitor"`, `parts:[{type:"text",text:<stdin>}]` | L75–84 |
| timeout | `THE_JANITOR_REQUEST_TIMEOUT`, default **3600 s** | L74 |
| output | concatenation of `parts[].text` only; trailing newline added | L87–92 |

Error texts (all `RuntimeError` → `the-janitor: <msg>` on stderr, exit 1, L111–113):
`Janitor server returned HTTP <code>`, `Janitor server is unavailable`
(URLError/timeout), `Janitor server did not create a session`,
`Janitor server returned an invalid response`. A well-formed response with no
text parts prints `the-janitor: request completed without a text response` and
still exits **0** (L93–95) — silence is not failure.

## `status` output fields (metadata only, L145–171)

`session`, `model`, `endpoint`, `fallback disabled`, `config_overlay`,
`state stopped|running`, `server_pid` (tmux pane pid), `health
ready|starting_or_authorizing`, `handler_session <id>|pending`,
`authorization process_memory_only`. No field carries a secret value; the
authorization statement is the point — 1Password authorization lives in the
handler process memory and dies with `stop`.

## Falsification

- `the-janitor status` prints exactly the fields above (compare against L146–170).
- `the-janitor request </dev/null` exits 2 with the empty-request text.
- `the-janitor request "x"` exits 2 with the stdin-not-arguments text.
- `THE_JANITOR_PORT=1 the-janitor status` reports `state stopped`/health
  starting_or_authorizing rather than hanging (health timeout 2 s).

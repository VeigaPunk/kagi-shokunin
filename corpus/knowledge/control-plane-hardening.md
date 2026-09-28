# Janitor control-plane hardening and transcript retention

Source basis: host inspection verified 2026-09-28: `~/.local/bin/the-janitor`
(`server_healthy` L72–75, `ensure_started` L92–118, `cmd_request` L121–135,
`cmd_stop` L173–184, `_serve` L186–226); `~/.config/the-janitor/client.py`
(`request` L22–38, `run_prompt` L67–95, `health` L98–100); metadata-only
inspection of `~/.local/state/the-janitor/xdg-data/opencode/opencode.db`;
and OpenCode 1.18.31 scratch-server auth / alternate-agent repros. Advisory
operator handoff only: no configuration or service changes are applied here.

## Finding — loopback is not a process boundary

`_serve` binds OpenCode to `127.0.0.1` and does not set
`OPENCODE_SERVER_PASSWORD` (OpenCode 1.18.31 warns on stdout, not stderr,
when it is unset). The client builds every HTTP request through one
`urllib.request.Request` helper without an `Authorization` header; both the
health check and the session/message calls use that helper. On the scratch
server, Basic auth gated every tested route, including `/global/health`:
anonymous requests returned 401 with an empty body, and Basic credentials
using the configured username (default `opencode`) succeeded. Bearer auth was
rejected. A separate scratch repro showed that a local caller could select
`agent: "open"` from the merged agent set and execute the bash tool in the
serve process environment. The janitor prompt and its `{"*": deny}` permission
ceiling therefore do not protect the HTTP control plane from a caller that can
reach it. The daemon environment can contain `OP_SESSION_<domain>` or
`OP_SERVICE_ACCOUNT_TOKEN`; never record their values. (Config merge and
loaded global agents/plugins: `corpus/knowledge/config-layering.md` L14–44,
L66–73; current prompt boundary: `corpus/knowledge/credential-isolation.md`
L37–51.)

## Operator decisions and rollout order

### 1. Operator-decision — add password auth end-to-end before enabling it

Choose how one password is provided to both `opencode serve` and every client
invocation. Prefer a dedicated state file under
`~/.local/state/the-janitor/` with mode `0600`; alternatively, store it in
`op.env` and add a narrow loader for just that key. Do not blindly shell-source
`op.env`: today the script uses it through `op run --env-file` for `run`, while
`cmd_request` does not load it (`the-janitor` L7, L228–249). Never print the
password or put it in logs, arguments, or evidence artifacts.

Because `_serve` has a tmux-local environment, callers cannot rely on
inheriting its password. With a state-file design, `_serve` and the
caller-side script must each load the protected value; the script then passes
it to the `client.py` subprocess for both `server_healthy` and `cmd_request`.
Export credentials only to the OpenCode/client subprocesses that need them.
Update `_serve` to export `OPENCODE_SERVER_PASSWORD` (and, if configured,
`OPENCODE_SERVER_USERNAME`) before starting OpenCode. Update `client.py` to
read those values from an explicit environment passthrough and attach
`Authorization: Basic <base64(username:password)>` in the shared
`urllib.request.Request` helper; default username is `opencode`. The script
must pass the same protected values to the client subprocess in both
`server_healthy` and `cmd_request`. This covers `GET /global/health` as well
as session creation, session lookup, and message submission. If the client
omits `Authorization` on health, `ensure_started` treats a 401 as unhealthy,
bypasses the explicit foreign-server detection, and can end with the misleading
authorization-wait message (`the-janitor` L92–118; `client.py` L41–64, L98–100).

**Required rollout order:** land the script and client changes first while
server auth remains unset; verify health and an ordinary request. Only then
provision the password, enable it in `_serve`, and restart the handler. Setting
the server password first makes `server_healthy` receive 401; `ensure_started`
retries for up to 120 × 0.5 seconds and then reports its misleading
authorization-wait error. `cmd_request` holds the lock through startup and,
once health succeeds, through the `client.py request` call (default timeout
3600 seconds). Long/hung requests therefore delay `start`/`stop` (`the-janitor`
L103–118, L129–134; `client.py` L74). The known emergency recovery for a
confirmed wedged request is `tmux kill-session -t janitor`, ending the client
and releasing its lock. Do not make this the rollout procedure.

After enabling auth and restarting, verify an unauthenticated health call
returns 401, `the-janitor start` passes its authenticated health check, and one
ordinary non-secret request completes. Record status/exit codes only.

### 2. Operator-decision — choose transcript retention

The handler's XDG data directory is
`~/.local/state/the-janitor/xdg-data`; the database is
`xdg-data/opencode/opencode.db`. On this host it was 9,240,576 bytes, mode
`0600`, with 7 session, 39 message, and 55 part rows. Metadata-only inspection
found text parts (`data.$.text`) and tool parts; the session schema includes
`cost`, `tokens_input`, `tokens_output`, `tokens_reasoning`,
`tokens_cache_read`, and `tokens_cache_write`. Request text is persisted as
plaintext. The current operating practice does not include secret values, but
that practice is not a storage control. `the-janitor stop` kills the handler
and removes `session-id`; it does not remove this database or the OpenCode log
(`the-janitor` L173–184, L190–225; lifecycle evidence in
`corpus/knowledge/janitor-lifecycle.md` L18–21).

Choose either a purge cadence or a separate, explicit purge verb. Recommended
cadence: at the end of each handler work window, after any needed conversation
continuity is finished, set
`state_dir="${THE_JANITOR_STATE_DIR:-$HOME/.local/state/the-janitor}"`, verify
`"$state_dir/xdg-data"` is the intended handler data directory, run
`the-janitor stop`, then remove only `"$state_dir/xdg-data"`. The next `_serve`
recreates its XDG directories. If continuity is intentionally retained across
work windows, set a specific periodic cadence instead; do not silently change
`stop` to purge history. No purge verb exists today (`the-janitor` usage
L28–43); an opt-in `the-janitor purge` could make stop-and-remove explicit,
but must refuse to remove data while the handler is live. `stop` takes the
same flock as a request, so a hung request can block this sequence; use the
known tmux recovery above only when the request is confirmed wedged.

### 3. Operator-decision — isolate OpenCode configuration layers

Revisit the round-6 defense-in-depth bundle in the context of the alternate
agent finding: set `OPENCODE_DISABLE_PROJECT_CONFIG=1`, give the handler a
dedicated `XDG_CONFIG_HOME`, and launch `opencode serve` with `--pure`. The
resolved janitor currently inherits global agents and plugins in addition to
its overlay; `enabled_providers` and janitor's deny rule do not prevent a
caller from selecting another loaded agent (`corpus/knowledge/config-layering.md`
L16–44, L66–73). Put only the handler's required configuration in the
isolated tree, including its janitor agent and `janitor_auth` tool, and
re-check the resolved provider, agent, plugin, and permission sets before
relying on it. This is separate defense in depth, not a substitute for
server authentication: unauthenticated local callers still reach the HTTP
API until the password rollout is complete.

### 4. Operator-decision — accept or reduce the host-local residual risk

**Current boundary:** binding to `127.0.0.1` is the only control-plane
boundary. Any local process running as user `vgpnk` (or root) can reach the
port. Password auth adds a credential check but does not isolate processes
with the same UID: on this host a same-UID process could read the serve
password from `/proc/<pid>/environ` in a scratch repro, as well as access a
`0600` password file. If that risk is unacceptable, the operator must
separately choose an OS-level isolation boundary; none is implemented by this
handoff.

## Reproduce / falsification (no vault access; outputs redacted)

```bash
# Source shape: health and request use the shared helper; inspect header wiring.
grep -n 'def request\|Authorization\|def health\|server_healthy\|cmd_request\|OPENCODE_SERVER_PASSWORD' \
  ~/.config/the-janitor/client.py ~/.local/bin/the-janitor

# Transcript counts and session field names only; do not select row contents.
DB="${THE_JANITOR_STATE_DIR:-$HOME/.local/state/the-janitor}/xdg-data/opencode/opencode.db"
sqlite3 -readonly "$DB" \
  "SELECT 'session',count(*) FROM session UNION ALL SELECT 'message',count(*) FROM message UNION ALL SELECT 'part',count(*) FROM part;"
sqlite3 -readonly "$DB" "PRAGMA table_info(session);"
sqlite3 -readonly "$DB" \
  "SELECT json_extract(data,'$.type'),count(*),sum(json_type(data,'$.text')='text') FROM part GROUP BY 1 ORDER BY 1;"
stat -c 'database_bytes=%s mode=%a' "$DB"

# Isolated scratch server only; output status codes, never response bodies.
# With auth unset, the observed POST /session status was 200.
# With auth set, expect both routes: anonymous=401, authorized=200.
SCRATCH_PORT="${SCRATCH_PORT:?set scratch port}" \
SCRATCH_SERVER_PASSWORD="${SCRATCH_SERVER_PASSWORD:?set disposable scratch password}" \
  python3 - <<'PY'
import base64
import json
import os
import urllib.error
import urllib.request

base_url = f"http://127.0.0.1:{os.environ['SCRATCH_PORT']}"
checks = [
    ("/global/health", "GET", None),
    ("/session", "POST", json.dumps({"title": "auth-check"}).encode()),
]
for path, method, body in checks:
    for label, password in (("anonymous", None), ("authorized", os.environ["SCRATCH_SERVER_PASSWORD"])):
        headers = {}
        if body is not None:
            headers["Content-Type"] = "application/json"
        if password is not None:
            token = base64.b64encode(f"opencode:{password}".encode()).decode()
            headers["Authorization"] = f"Basic {token}"
        request = urllib.request.Request(base_url + path, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request) as response:
                status = response.status
        except urllib.error.HTTPError as error:
            status = error.code
        print(f"{path} {label}={status}")
PY
```

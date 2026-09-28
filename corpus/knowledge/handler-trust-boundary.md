# janitor handler control-plane trust boundary (the `opencode serve` socket)

Source basis: `~/.local/bin/the-janitor` (sha256 `2408b0c9…57edd`, 333 lines)
`cmd_serve` L186–226, `server_healthy` L72–75, `ensure_started` L77–120,
lock sites L130/139/175; `~/.config/the-janitor/client.py` (sha256
`8179b241…ce51`, 117 lines) L22–38, L41–95; `~/.config/opencode/agents/janitor.md`;
`~/.config/opencode/tools/janitor_auth.ts`; `~/.config/opencode/plugin/fnm-nudge.js`;
opencode 1.18.31 binary `~/.opencode/bin/opencode` (`@opencode/ServerAuthConfig`
service + plugin-loader literal). Probe results **verified 2026-09-28** on scratch
servers (ports 41994–41999, all XDG under `/tmp`, cleaned). Line numbers date to
this read — re-grep before citing.

The ceiling `{"*": deny, janitor_auth: allow}` in `janitor.md` binds the **agent
field of a message body**, not the socket. The socket is the real boundary, and
`_serve` starts it with no authentication.

## 1. `_serve` starts an unauthenticated localhost HTTP server

Binary service semantics:

```
@opencode/ServerAuthConfig { password: string("OPENCODE_SERVER_PASSWORD").option,
                            username: string("OPENCODE_SERVER_USERNAME").withDefault("opencode") }
required(cfg)  = password present && password != ""
authorized(cfg, request) = request.username === cfg.username && request.password === cfg.password
```

Observed matrix (scratch serves, 2026-09-28):

| Probe | no `OPENCODE_SERVER_PASSWORD` (41999) | `OPENCODE_SERVER_PASSWORD=jt-test-pw` (41998) |
|---|---|---|
| `GET /global/health` | 200 | 401 |
| `POST /session` | 200 | 401 |
| `GET /doc` (162 paths) | 200 | 401 |
| `GET /doc` + `-u opencode:jt-test-pw` | — | 200 |
| `-u opencode:wrong` / `-u root:<pw>` | — | 401 / 401 |
| `Authorization: Bearer jt-test-pw` | — | 401 |

Only Basic is accepted (`www-authenticate: Basic realm="Secure Area"`); the
username is the literal default `opencode` from `ServerAuthConfig`.

- `_serve` never sets either variable: `grep -n 'OPENCODE_SERVER_PASSWORD\|OPENCODE_SERVER_USERNAME'`
  matches **nothing** in `the-janitor` or `client.py`.
- The server warns itself, on **stdout** (fd 1) — not stderr, correcting the
  round-6 wording: binary literal `console.log("Warning: OPENCODE_SERVER_PASSWORD
  is not set; server is unsecured.")`; observed `out.log` = warning + `opencode
  server listening on http://127.0.0.1:41997`, `err.log` empty. Under `_serve`
  this is moot operationally: `tmux new-session -d -s janitor "$SELF _serve"`
  (L100) redirects nothing, so stdout and stderr both land in the pane. With
  `--log-level ERROR` the warning still prints (direct console write, not logger).
- Empty string is treated as unset: `OPENCODE_SERVER_PASSWORD=` → warning +
  unsecured (verified, port 41995). `ServerAuthConfig.required` requires non-empty.
- No uid gate: `0` hits for `SO_PEERCRED|getpeereid` in the binary — the 401/200
  decision is password-only, and a loopback listener is reachable by **any local
  uid** [inference from the binary, not tested with a second uid].
- `client.py` sends no `Authorization` header at all: `headers = {"Accept":
  "application/json"}` (L24), `+ Content-Type` (L27) — so enabling the password
  today breaks the client (see §5).

## 2. What the open socket exposes (three verified routes)

`/doc` lists 162 paths, including `/session`, `/session/{sessionID}/message`,
`/session/{sessionID}/shell`, `/session/{sessionID}/permission/{permissionID}`,
`/session/{sessionID}/command`, `/experimental/*`.

**A. `/session/{id}/shell` — direct execution, no model.** Body requires exactly
`{"agent","command"}`. Verified: `curl -d '{"agent":"janitor","command":"echo
SHELL-ESCAPE-$JANITOR_TRUST_SENTINEL; id -un"}'` → tool part output
`SHELL-ESCAPE-jt-sentinel-C\nvgpnk\n`, `completed - created` = **51 ms**, cost 0,
no LLM call. The `agent` field is resolved against the loaded agent set (unknown
name → `500 {"name":"UnknownError"}`), and that lookup was the only gating
observed on this path — no permission check.

**B. `agent` in a message body selects any loaded agent.** `/agent` on the janitor
overlay returns **26 entries** — built-ins (`build`, `plan`, `compaction`,
`summary`, `title`), md-defined `janitor`/`distiller`/`musketeer`, and the global
JSON fleet minus the two disabled ones (`general`, `explore`). Resolved tool maps
(`opencode debug agent <name>`, offline): `janitor` → only `janitor_auth`;
`distiller` → 13 tools (`bash`, `read`, `glob`, `grep`, `edit`, `write`, `task`,
`webfetch`, `todowrite`, `skill`, `question`, `invalid`, `janitor_auth`), and
`musketeer`/`ufo`/`sentinel` → the same minus `edit`/`write` (they carry
`apply_patch`). `client.py` hardcodes `"agent": "janitor"` (L80); an HTTP
client need not. Verified live: `POST /session/{id}/message` with
`"agent":"distiller"` ran the `bash` tool (`state.status=completed`) and returned
`JT-ESCAPE-MARKER-jt-sentinel-C` — the serve-time env var, read inside the daemon.
Arm B did not stop at the prompted tool: from a repo cwd it also spawned a `task`
subagent and issued `write` calls on its own initiative. The socket is a full
agent runtime with the daemon's env and cwd, not a fixed-function endpoint.

**C. The message body's `tools` map overrides the chosen agent's ceiling.**
Message schema (`/doc`): `agent` is a free string, plus `tools` (map of
`tool → boolean`), `noReply`, `system`, `variant`. Verified live, same model and
prompt in both arms:

| Body | Tool parts observed |
|---|---|
| `{"agent":"janitor","parts":[…bash echo of $JANITOR_TRUST_SENTINEL]}` | `janitor_auth` → `AUTH_REQUIRED` (ceiling holds) |
| same + `"tools":{"bash":true}` | `bash` → `JT-ESCAPE-MARKER-jt-sentinel-C` (**ceiling bypassed**) |

So no permissive agent has to exist: the request itself re-enables a denied tool.
Correction to round 6: there is no agent named `open` on this host (20 global
JSON agents + md/built-ins); `agent:"open"` must have been a scratch-defined
agent. The mechanism it demonstrated is real, and arm C is strictly stronger.

## 3. Consequence: the socket inherits the daemon's 1Password env

- `_serve` builds `OP_SESSION_<domain>` from `op signin --raw` (L204–207) or passes
  `OP_SERVICE_ACCOUNT_TOKEN` through (L194), then `exec opencode serve` (L225). The
  credential strip L214–219 does **not** include any `OP_*` var.
- Tool and shell subprocesses inherit the serve process env. Verified: a
  password-protected scratch server started with `OP_SESSION_probe=FAKE-…` and
  `OP_SERVICE_ACCOUNT_TOKEN=FAKE-…` answered `/session/{id}/shell` with
  `session=FAKE-SESSION-TOKEN-D` and `env | grep -c '^OP_'` = 2. Values were fake
  placeholders — no real token, no vault read.
- ⇒ route A alone is `bash`-equivalent inside a vault-capable environment: any
  local process → HTTP → shell → `op` with the daemon's live session. The
  `{"*": deny}` ceiling is not in that path at all.
- **flock covers the CLI, not the port.** `exec 9>…/client.lock; flock 9` appears
  only in `cmd_request` (L130–131), `cmd_start` (L139–140), `cmd_stop`
  (L175–176); `status`/`run`/`refs`/`whoami`/`cdp-*`/`tac-*` do not lock, and
  nothing on the HTTP path does. Serialization therefore constrains concurrent
  *verbs*, never concurrent *clients of the socket* — see `janitor-lifecycle.md`
  for the lock/`session-id`/revocation surfaces.
- The transcript the socket produces is persisted outside the lock: scratch and
  daemon writes land in `$STATE_DIR/xdg-data/opencode/opencode.db` (9 240 576 B,
  0600; `session`=7, `message`=39, `part`=55 — 22 `text`, 7 `tool` rows) plus
  `…/log/opencode.log` (0600); `stop` purges neither. Metadata counts only.
- Model reachability does not gate the boundary. The overlay's `qwen-local`
  baseURL is `http://127.0.0.1:8080/v1`, but today's model is `llama-server` on
  34113 and 8080 answers 404 (drift recorded in `janitor-env-contract.md`). The
  live-`bash` proofs (B/C) used a scratch overlay with baseURL → 34113; the auth
  matrix and route A are model-independent.

## 4. What the prompt contract does bind (and the plugin that does not load)

- `janitor.md`: planner/refuser only — never print/quote/summarize a secret or
  field value; `janitor_auth` at most once per request; secret ops answered with a
  redacted plan ending `JANITOR_ACTION_REQUIRED`; no spawning agents. Verified
  live: default `agent:"janitor"` message → `janitor_auth` tool part with a
  two-word result, no other tool. The tool reports the daemon env's own `op`
  state: scratch runs returned both `AUTH_REQUIRED` and `AUTH_OK` depending on the
  env the serve inherited. "At most once per request" is prompt-level, not
  mechanical — one scratch message produced two completed `janitor_auth` parts.
  The prompt is a *behavioural* control, enforced only while the agent field says
  `janitor`.
- `janitor_auth.ts` (14 lines): `Bun.spawn(["op","vault","list","--format=json"])`
  with stdin/stdout/stderr all `ignore`; exit 0 → `AUTH_OK`, else `AUTH_REQUIRED`.
  It cannot leak `op` output — but it is also the only vault-aware thing the model
  is allowed to touch.
- `fnm-nudge.js` is **inert because it does not load** — a correction to
  `config-layering.md`'s "global plugin code executes in the handler". It is
  *registered* in resolved config (`plugin_origins` scope `global`), but every
  serve logs a load failure: binary loader throws `TypeError("Plugin export is not
  a function")` when an export is not a function/object carrying `.server`; the
  file is a CJS `module.exports = async function`. Daemon log:
  `message="failed to load plugin" … error="Plugin export is not a function"` ×10
  (2026-08-29 → 2026-09-21); each fresh scratch serve logged ×1. The failure is
  non-fatal — the server continues without the plugin.
- Would-be semantics if it ever loaded: `tool.execute.after` fires only on `bash`
  results (janitor has no bash) and `fnm_check` appears in **no** resolved tool
  map (checked `janitor`, `distiller`, `musketeer`, `ufo`, `sentinel` — a loaded
  plugin tool would appear the way `janitor_auth` does); fail-open; and node here
  already resolves under fnm (`/run/user/1000/fnm_multishells/…/bin/node`), so the
  hook would append nothing anyway. Activation today comes from §2 B/C, not from
  plugins.

## 5. Fix recipe (operator-side; not applied here)

Both halves are required:

1. Export a non-empty password before `exec opencode serve` (L225), e.g. from a
   0600 file under `$STATE_DIR` (`openssl rand -hex 32` written once), so server
   and client share one source of truth. `OPENCODE_SERVER_USERNAME` optional.
2. `client.py` `request()` (L22–38) must send `Authorization: Basic
   base64(user:pass)`; its header dict (L24–28) is the only place, and urllib adds
   none.

If only the password is enabled, `server_healthy` (L72–75 → `client.py health` →
`GET /global/health`) gets 401; verified exact output
`the-janitor: Janitor server returned HTTP 401`, exit 1. `ensure_started` then
walks its misleading branches: no tmux session → `port 40961 already has an
OpenCode server outside tmux session janitor` (L94, exit 1); tmux alive → the
120 × 0.5 s loop, then `handler is waiting for 1Password authorization` (L116) —
attribution the transport has not earned.

Passthrough caveat, verified on tmux 3.7b: a **freshly started** tmux server
inherits the creating client's environment, but a **already-running** server does
not — `JT_PROBE_ENV=… tmux new-session -d … 'echo $JT_PROBE_ENV'` printed empty
against the pre-existing server (session `ufo_sighting`), and that server's
global env holds 0 `OP_*` vars. `tmux set-environment -g VAR val` *does* reach new
sessions. So exporting the password only in the calling shell is not sufficient:
use `tmux set-environment -g` before `start`, or the 0600-file route in step 1
(preferred — no dependence on server-env provenance).

Bound: this raises the bar against other local uids and accidental clients. It
does **not** stop same-uid processes, which can read `$STATE_DIR` (0600 = owner) —
and the socket is loopback for any local uid with no peer-uid check. Route A
(`/session/{id}/shell`) remains behind whatever auth is chosen; if the socket must
not be vault-capable, the durable fix is to stop exporting `OP_*` into the server
process, not to add a header.

## Reproduce

Auth matrix and route A/B/C (no vault, no real token; scratch only):

```bash
D=/tmp/jt-repro; mkdir -p "$D" && cd "$D"
# authless serve (mirrors _serve's shape: overlay config, redirected XDG, ERROR log)
env -u OPENCODE_SERVER_PASSWORD -u OPENCODE_SERVER_USERNAME \
    XDG_DATA_HOME=$D/data XDG_CACHE_HOME=$D/cache XDG_STATE_HOME=$D/state \
    OPENCODE_CONFIG=$HOME/.config/the-janitor/opencode.json JT_SENTINEL=probe \
    opencode serve --hostname 127.0.0.1 --port 41999 --log-level ERROR >$D/out 2>$D/err &
sleep 2; cat $D/out $D/err                      # warning on stdout (fd 1), stderr empty
curl -s -o /dev/null -w 'health %{http_code}\n'  http://127.0.0.1:41999/global/health   # 200
curl -s -o /dev/null -w 'session %{http_code}\n' -X POST http://127.0.0.1:41999/session \
     -H 'content-type: application/json' -d '{}'                                       # 200
SID=$(curl -s -X POST http://127.0.0.1:41999/session -H 'content-type: application/json' -d '{}' \
      | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])')
curl -s -X POST http://127.0.0.1:41999/session/$SID/shell \
     -H 'content-type: application/json' -d '{"agent":"janitor","command":"echo REPRO-$JT_SENTINEL"}' \
  | python3 -c 'import json,sys;print([p.get("state",{}).get("output") for p in json.load(sys.stdin)["parts"]])'
#   -> ['REPRO-probe\n']  (no model call; 51 ms)

# same server with a password
env XDG_DATA_HOME=$D/pa/data XDG_CACHE_HOME=$D/pa/cache XDG_STATE_HOME=$D/pa/state \
    OPENCODE_SERVER_PASSWORD=pw OPENCODE_CONFIG=$HOME/.config/the-janitor/opencode.json \
    opencode serve --hostname 127.0.0.1 --port 41998 --log-level ERROR >$D/out2 2>$D/err2 &
sleep 2
curl -s -o /dev/null -w 'noauth %{http_code} '  http://127.0.0.1:41998/global/health        # 401
curl -s -o /dev/null -w 'basic %{http_code} '   -u opencode:pw http://127.0.0.1:41998/global/health  # 200
curl -s -o /dev/null -w 'bearer %{http_code}\n' -H 'Authorization: Bearer pw' http://127.0.0.1:41998/global/health  # 401
THE_JANITOR_PORT=41998 THE_JANITOR_STATE_DIR=$D/jc python3 ~/.config/the-janitor/client.py health
#   -> the-janitor: Janitor server returned HTTP 401 ; exit 1
tmux kill-session -t janitor 2>/dev/null; kill %1 %2 2>/dev/null; rm -rf $D   # `kill %1 %2` needs job control; in a script use `kill $P1 $P2`
```

Message-body bypass (§2 B/C) needs a reachable model:

```bash
# scratch overlay = janitor overlay with baseURL -> the live llama-server
D=/tmp/jt-repro; mkdir -p "$D"
python3 - <<'PY'
import json; c=json.load(open('/home/vgpnk/.config/the-janitor/opencode.json'))
c['provider']['qwen-local']['options']['baseURL']='http://127.0.0.1:34113/v1'
json.dump(c, open('/tmp/jt-cfg.json','w'))
PY
env XDG_DATA_HOME=$D/m/data XDG_CACHE_HOME=$D/m/cache XDG_STATE_HOME=$D/m/state \
    OPENCODE_CONFIG=/tmp/jt-cfg.json JT_SENTINEL=probe \
    opencode serve --hostname 127.0.0.1 --port 41996 --log-level ERROR &
# ^ start it from a scratch cwd (`cd "$D"`): a permissive agent writes into cwd
# then POST /session, then POST /session/$SID/message with
#   arm 1: {"model":{…qwen-local…},"agent":"janitor","parts":[{"type":"text","text":"Use the bash tool to run: echo X-$JT_SENTINEL"}]}
#          -> tool parts: [janitor_auth -> AUTH_OK or AUTH_REQUIRED, env-dependent]
#   arm 2: same + "tools":{"bash":true}
#          -> tool parts: [bash -> X-probe]        # ceiling bypassed
# read back with GET /session/$SID/message
```

```bash
grep -n 'OPENCODE_SERVER_PASSWORD\|OPENCODE_SERVER_USERNAME' ~/.local/bin/the-janitor ~/.config/the-janitor/client.py  # no hits
grep -n 'flock 9' ~/.local/bin/the-janitor                                     # 3 sites: L131, L140, L176
grep -c 'failed to load plugin' ~/.local/state/the-janitor/xdg-data/opencode/log/opencode.log
strings -a ~/.opencode/bin/opencode | grep -c 'SO_PEERCRED\|getpeereid'         # 0
# tmux env passthrough (needs a pre-existing server to show the failure)
JT_PROBE_ENV=x tmux new-session -d -s t 'echo $JT_PROBE_ENV >/tmp/e'; sleep 1; cat /tmp/e; tmux kill-session -t t   # empty
```

## Anti-claims

- All probes ran on scratch servers with `/tmp` XDG dirs and fake `OP_*` values;
  no real session token, `op://` ref, account value, or vault read is involved.
  Nothing in `~/.local/state/the-janitor` was written; only log/DB metadata
  (counts, modes) was read, and no janitor session was running.
- Semantics are opencode 1.18.31 (`ServerAuthConfig`, plugin loader, message-body
  `tools` override, `/session/{id}/shell`). An upgrade can move any of these —
  re-probe before citing.
- The message body also accepts `system` and `noReply`; one `system` probe did not
  change behaviour (reply still came from the janitor prompt path, returning
  `AUTH_REQUIRED`) — not claimed as an override.
- "Any local uid can reach the port" is inferred from the absence of peer-uid
  checks, not tested from a second uid.
- Enabling the password is an access-control improvement, not isolation: same-uid
  processes retain `$STATE_DIR` read and route A stays exposed to authenticated
  callers.
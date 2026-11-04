# Round-7 lesson — the ceiling was an agent, not a socket

Prompt: pick the highest-value gap. The corpus had documented every *verb*
and every *config layer* — but never the HTTP control plane the whole thing
runs on, and never what lands on disk. Both turned out to be load-bearing
misunderstandings.

## Finding 1: the socket is the boundary, and it has no lock

Every prior round (and round 6's "isolation is the permission ceiling")
treated `janitor.md`'s `{"*": deny, janitor_auth: allow}` as the handler's
wall. It isn't — it's **request metadata**. The `opencode serve` socket on
`127.0.0.1:40961` starts with `OPENCODE_SERVER_PASSWORD` unset (the server
itself prints `server is unsecured` on **stdout**; `_serve` never sets it)
and enforces nothing:

- `POST /session/{id}/shell` `{"agent","command"}` runs a shell command in
  the daemon env in ~50 ms — **no model call at all**.
- `POST /session/{id}/message` accepts any `agent` name (26 loaded,
  enumerable unauthenticated via `GET /agent`; `GET /config` discloses the
  merged permission JSON) — and the body's `tools` map can re-enable denied
  tools even while `agent:"janitor"`.
- No project-trust prompt, no Origin/Host validation, no per-UID check —
  reachable by any uid in the host netns; JSON accepted as
  `Content-Type: text/plain` (browser simple-POST reachable).
- `client.lock` flock covers exactly three CLI verbs; the HTTP path has no
  serialization and no auth. The lock guards the workflow, not the port.

Daemon-env consequence (verified with fake `OP_*` values, never real ones):
tool/shell subprocesses inherit the serve env → `OP_SESSION_<domain>` or
`OP_SERVICE_ACCOUNT_TOKEN`, **plus** whatever the tmux server carried at
spawn (`SSH_AUTH_SOCK` with a live agent, `XDG_RUNTIME_DIR` → GPG sockets,
docker-group uid). A clean shell has *no* ambient `op` session — the daemon
env is the only vault-capable context, which is exactly why the open port
matters. Blast radius is the operator's whole user session.

Reframing for the corpus: don't write "the ceiling is bypassed" — write
"the ceiling was never socket-scoped." The fix is transport auth
(`OPENCODE_SERVER_PASSWORD` + `client.py` `Authorization` header — both or
`server_healthy` 401s into the misleading wedge texts), not agent hardening.
And the durable fix, if the socket shouldn't be vault-capable at all, is to
stop exporting `OP_*` into the serve process — password only raises the bar
for other uids; same-uid still reads `$STATE_DIR`.

## Finding 2: "memory-only" described the auth, not the transcript

`status` prints `authorization process_memory_only` and `stop` drops the
session token — true for the credential. But `_serve` redirects XDG into
`$STATE_DIR/xdg-*` and opencode persists the **whole transcript**:
`xdg-data/opencode/opencode.db` (0600 — from the wrapper's `umask 077`, a
bare serve writes 0644) holds plaintext request/reply text and tool parts
across `stop`, across reboots, forever. No verb purges it. Requests are
at-rest data; treat stdin accordingly.

Bonus diagnostic surfaces found in the same pass: `opencode.log` (0600,
ERROR-level, appended across all 8 recorded daemon starts — `stream error
Cannot connect to API` ≈58 s exponential backoff is the dead-endpoint
signature; `failed to load plugin fnm-nudge.js "Plugin export is not a
function"` recurs every start and is why the plugin is inert — failure, not
permission), and `tmux capture-pane -t janitor -p` (the only stderr sink).

## Finding 3: the readiness texts are timeouts, not diagnoses

`handler is waiting for 1Password authorization` fires after 120 health
probes (each ≤2 s + 0.5 s sleep ⇒ 60–300 s) with the tmux session merely
*alive*. A wedged server reports the same text as a pending auth prompt.
And `flock 9` in `cmd_request` is held for the whole model round-trip
(default 3600 s): a hung request wedges `stop`/`start`; the only unblock is
`tmux kill-session -t janitor` (client.py dies, fd 9 releases).

Adjacent trap verified while probing: tmux env passthrough — a pre-existing
tmux server does **not** inherit the calling client's env, so
`OP_SERVICE_ACCOUNT_TOKEN=x the-janitor start` silently drops the token and
falls into the interactive path (`tmux set-environment -g` or a fresh
server works). The documented headless path is conditional on server
provenance — now written down.

## Method notes for future rounds

- Scratch-server replication is cheap and total: `opencode serve` + isolated
  XDG under `/tmp` + `setsid` (backgrounded children die with the cell
  otherwise) answers wire-protocol questions definitively — no janitor state
  touched.
- `opencode serve` is a *product*: `/doc` enumerates 162 routes — read the
  route list before assuming the client library shows the whole surface
  (client.py uses 3 of them).
- Negative controls matter for env-inheritance claims: the clean-shell
  `op vault list` hang (timeout 124) proved the daemon env is the sole
  credential source better than any source read.
- Squatting is a phishing surface too: `client.py` has no auth/pinning, so a
  mock control plane can answer `JANITOR_ACTION_REQUIRED` and harvest
  operator approvals. `ensure_started`'s foreign-server text detects exactly
  one squat shape (no tmux + healthy port).

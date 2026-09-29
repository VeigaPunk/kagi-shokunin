# handler on-disk state — XDG quarantine, durable transcript & wedge recovery

Source basis: `~/.local/bin/the-janitor` (sha256 `2408b0c9…57edd`, 333 lines:
`cmd_serve` L186–226, `ensure_started` L77–120, `cmd_status` L145–171, flock at
L130/139/175, dispatch L303–330), `~/.config/the-janitor/client.py` (117 lines:
`request` L22–38, `get_session_id` L49–65, `run_prompt` L67–96, `health` L98–100,
`main` L103–113), `opencode` 1.18.31, live probes 2026-09-28 (stat/find on the
state tree, read-only sqlite3, log forensics, isolated-tmux and scratch-XDG-root
repros under `/tmp`). Line numbers date to this read — re-grep before citing.
Companions: `janitor-lifecycle.md` (state objects/rotation),
`janitor-env-contract.md` (knobs), `janitor-command-surface.md` (verbs).

`verified 2026-09-28`. Everything below is metadata: no secret values, no
`op://` refs, no account values, no session ids.

Reverify: R11-01, R11-04

## 1. XDG layout — three roots, all under `$STATE_DIR`

`cmd_serve` builds the quarantine itself, **before** any auth attempt
(L190–191: `mkdir -p`, `chmod 700` on all three roots), then re-points the
standard XDG variables at them (L222–224) and execs the server (L225):
`opencode serve --hostname 127.0.0.1 --port $PORT --log-level ERROR`.
Because `cmd_serve` runs under `umask 077` (L5), every persisted file lands
0600. Probe: a bare `opencode serve` started with the same three env vars but
*without* the-janitor's umask wrote the identical file set at **0644** — the
mode discipline comes from the wrapper, not from OpenCode.

| Path (relative to `$STATE_DIR`) | Mode/size (observed) | Role |
|---|---|---|
| `xdg-data/opencode/opencode.db` | 0600, 9,240,576 B, SQLite (journal_mode `wal`, page 4096 × 2256) | **the durable transcript** |
| `xdg-data/opencode/opencode.db{-wal,-shm}` | 0600, transient | WAL siblings; present while a writer holds it, empty-`-wal` after clean exit |
| `xdg-data/opencode/log/opencode.log` | 0600, 33,687 B, 84 lines, **all `level=ERROR`** | the diagnostic surface |
| `xdg-data/opencode/repos/` | empty dir | created on first boot, unused here |
| `xdg-cache/opencode/models.json` | 0600, 4,709,964 B | cached **public** model catalog (222 providers / 7865 models) |
| `xdg-cache/opencode/bin/`, `xdg-cache/bun/@t@/*.pile` | empty dir / 0600 | bun's install cache |
| `xdg-state/opencode/locks/` | empty dir | the *only* thing `XDG_STATE_HOME` ever receives |

Two consequences worth internalising:

- **The transcript is not under the variable named "state".** OpenCode writes
  its DB and its log under `XDG_DATA_HOME`; `XDG_STATE_HOME` gets a `locks/`
  directory and nothing else. Anyone reasoning "state lives in `$STATE_DIR`"
  and looking at `xdg-state/` finds an empty tree.
- `xdg-data/opencode/log/opencode.log` **appends across daemon restarts**
  (8 distinct `run=` ids in one 33 KB file spanning 2026-08-29T17:22:31Z →
  2026-09-21T04:58:13Z) and is never rotated or truncated. It is a single
  monotonic error journal.

### What the DB actually holds (`?immutable=1` reads, 2026-09-28)

| Table | Rows | Shape notes |
|---|---|---|
| `session` | 7 | all `agent=janitor`, all `model` = `qwen-local/Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS`, all `directory=/home/vgpnk/.config/the-janitor` (because `cmd_serve` `cd`s to `$CONFIG_DIR`, L192) |
| `message` | 39 | `$.role` = user 16 / assistant 23 |
| `part` | 55 | `$.type` = text 22, tool 7, step-start 13, step-finish 13 |
| `event` | 238 | `type` **column** (not JSON): `message.updated.1` 104, `message.part.updated.1` 75, `session.updated.1` 52, `session.created.1` 7 |
| `event_sequence` / `project` / `migration` / `data_migration` | 7 / 1 / 38 / 38 | event-sourcing bookkeeping |
| `permission`, `todo`, `credential`, `account`, `session_input`, `session_share`, `session_message`, `session_context_epoch` | 0 | empty — no permissions were ever requested, no cloud account ever existed |

- All 7 session `title`s are the single constant literal `client.py` sends on
  `POST /session` (`janitor persistent local handler`) — 1 distinct title, so
  titles carry no request text. **Request/response text lives only in
  `part.data.$.text`** (22 rows, lengths 12–2047, 11,175 chars total) and in
  `event.data`. `JANITOR_ACTION_REQUIRED` (the janitor prompt's refusal marker)
  appears in 2 of those rows; `op://` appears in **0**.
- Every tool part is `janitor_auth` / `completed` with `$.state.input = {}`
  (7 invocations) — the DB is positive evidence that *only* the auth probe ever
  ran on this daemon, i.e. the `{"*": deny}` ceiling held here. It is not
  evidence about what a local process could do to the server (see the
  trust-boundary entry).
- Time span: `session.time_created` 1788026642930 (2026-08-29T18:04:02Z) →
  `time_updated` 1789966628471 (2026-09-21T04:57:08Z), consistent with the log.

### Read-side gotcha

Any `sqlite3` open of that path **creates the 0600 `-wal`/`-shm` siblings**,
even read-only (`?mode=ro`). Verified both ways: with `?immutable=1` or a
`cp` to `/tmp` first, the state dir stays untouched. Copy before reading.

### Corrections to the round-6 note

- `fnm-nudge.js`'s `Plugin export is not a function` is not a 2026-09-21 one-off:
  10 lines across **all 8 logged runs** (2026-08-29 → 2026-09-21) — it recurs on
  every daemon start and is logged non-fatal (the daemon keeps serving). Per the
  round-6 finding the plugin is fail-open and also inert on this daemon: its
  `tool.execute.after` hook fires only on `bash` results, and the janitor's
  `{"*": deny}` ceiling blocks both `bash` and its `fnm_check` tool.
- The endpoint-drift burst is exponential (**2.3 → 4.7 → 8.9 → 19 → 30 s**
  within one run), not a flat ~60 s retry; ~60 s was the length of the window.
- `event` types live in the `type` **column** — `json_extract(data,'$.type')`
  returns NULL for all 238 rows.
- 9.2 MB / 0600 is the **DB**; the log is 33,687 B / 0600 in the same tree.
- `ensure_started`'s window is 120 × 0.5 s, measured **64 s** to the timeout
  message, not a hard 60 s.
- The misleading `port … already has an OpenCode server outside tmux session
  janitor` branch needs **no tmux session**; with a live (even empty) pane the
  same failure surfaces as the 60 s `waiting for 1Password authorization`
  message instead.
- Reading the state dir mutates it (0600 `-wal`/`-shm` siblings), and
  `xdg-state/` holds only `locks/` — the transcript is under `xdg-data/`.

## 2. Lock topology — three flock verbs, everyone else is lock-free

`prepare_state` (L62–70) creates `client.lock` 0600 if absent; the locking verbs
then `exec 9>"$LOCK_FILE"; flock 9` and hold fd 9 **for their entire body**.

| Verb | flock? | Line | Held across |
|---|---|---|---|
| `request` | yes | L130–131 | `ensure_started` + `python3 client.py request` (`THE_JANITOR_REQUEST_TIMEOUT`, default **3600 s**, client.py L74) |
| `start` | yes | L139–140 | `ensure_started` (up to ~60 s) |
| `stop` | yes | L175–176 | `tmux kill-session` + `rm -f session-id` |
| `status`, `run`, `refs`, `whoami`, `cdp-bridge *`, `tac-*`, `_serve` | **no** | dispatch L303–330 | nothing |

Measured on a scratch lock (never the real one): with a request in flight,
`flock -n` fails immediately (exit 1) and `flock -x` blocks for the whole
window (exit 124); `the-janitor status` still answers exit 0; killing the server
releases the holder **0.01 s** later. Same shape through the real verbs with
`THE_JANITOR_STATE_DIR` pointing at a scratch dir: `stop` and `start` both
returned 124 (silent, no output) while the lock was held, and `stop` printed
`the-janitor: already stopped` (exit 0) once it was free.

So: **a hung request wedges `start` and `stop` for up to an hour** and produces
no output at all while blocked. There is no `--timeout`/`--nowait` flag; the
only in-script bound is `client.py`'s prompt timeout. If the server dies
mid-read the client exits anyway (observed: uncaught traceback from
`response.read()` (L31), which sits outside the `HTTPError`/`URLError` guards
(L32–33, L34–35); untidy message, exit 1, fd 9 released just the same).
Escapes: kill the tmux session (server death → client exits → lock frees), or
kill the client. Never delete or replace `client.lock` in place while a request
is in flight: the holder keeps the old inode.

## 3. Wedge taxonomy — state → diagnostic → recovery

Diagnostics: `the-janitor status` (metadata only, lock-free), `tmux has-session
-t janitor`, `tmux capture-pane -t janitor -p` (the daemon's **only** stderr
sink — `_serve` is exec'd with the pane as stdout/stderr), log tail, and
`python3 client.py health` (`GET /global/health`, timeout 2 s).

| State | What you see | Real cause / recovery |
|---|---|---|
| Stopped | `status` → `state stopped`, exit 0; `tmux has-session` exit 1; `client.py health` → `the-janitor: Janitor server is unavailable`, exit 1 | normal; `request`/`start` |
| Starting, pane alive | `status` → `state running` + `health starting_or_authorizing`; `handler_session pending` | wait, then re-run `status`; if it never flips: `stop` → `request` |
| **Pane alive, no server, ≥60 s** | `start` prints `handler is waiting for 1Password authorization` + `Unlock 1Password…` and exits 1 after 120 × 0.5 s (measured **64 s**) | message is a **timeout, not a diagnosis**: reproduced with a pane containing only `sleep 90`. Capture the pane *first*, then `stop` → `request` |
| Pane died on arrival | `handler exited before becoming ready` + the 1Password Settings hint (L108–110), exit 1 in <1 s | the cause was printed in the pane, which is now gone — `capture-pane` returns `can't find pane: janitor`. Re-run `_serve` in the foreground to see it |
| Foreign healthy server, no pane | `port 40961 already has an OpenCode server outside tmux session janitor` (L93–95), exit 1; `ensure_started` also `rm -f session-id` (L97) | a non-janitor OpenCode owns the port; stop it or move `THE_JANITOR_PORT` |
| **Lock held by an in-flight request** | `stop`/`start` produce **no output** and block (exit 124 at a 2 s timeout); `status` still works | `tmux kill-session -t janitor` (releases fd 9 when the client dies), or kill the client process |
| Server up, model endpoint dead | `status` → `health ready`, yet every request fails; only the log says so: 61 `message="stream error"` lines, exponential backoff **2.3 → 4.7 → 8.9 → 19 → 30 s**, then a terminal `message=process … error="Cannot connect to API: Unable to connect. Is the computer able to access the url?"` (60 stream-error + 10 process lines carry it; 2 process lines are `error=Aborted`) | this is the endpoint-drift failure mode from round 6 — health is server-level and never checks the model endpoint. Fix the overlay `baseURL`, not `status`'s cosmetic `endpoint` line (`janitor-env-contract.md`) |
| Control-plane password set | `the-janitor: Janitor server returned HTTP 401`, exit 1 (health raises on `HTTPError`, L32–33); `ensure_started` then falls into the foreign-server or the 60 s timeout message — neither mentions auth | `client.py` sends only `Accept`/`Content-Type` (L24–27), so enabling `OPENCODE_SERVER_PASSWORD` breaks `request`/`start` until the client sends Basic auth |

Undocumented verb: `_serve` (dispatch L310). Running it in the foreground gives
the same stderr live, and is the fastest way to read a failure the pane
swallowed. Amplifying the pane: `tmux attach -t janitor`.

## 4. Hygiene consequences

- **`status`'s `authorization process_memory_only` is about 1Password only.**
  It is also printed *only* inside the `state running` branch (L158–170) — a
  stopped handler prints no authorization line at all. It says nothing about
  the transcript, which is durable: request text is on disk in plaintext SQL,
  and the DB survived every `stop` in the observed window.
- **`stop` does not purge.** L183 is `rm -f "$SESSION_FILE"` and nothing else;
  `grep -n 'rm -f\|rm -rf'` finds only L97 (foreign-server path) and L183.
  `_serve` never truncates the log. There is no `purge`/`reset`/`vacuum` verb in
  `usage()` or the dispatch table. Transcript purge = `stop` + manual
  `rm -rf $STATE_DIR/xdg-data` (plus `xdg-cache`/`xdg-state` for a full reset).
- **No encryption, no rotation, no size cap.** The only protection on the
  transcript is 0700 dirs + 0600 files, i.e. the same-user boundary; the DB is
  not encrypted and grows without a vacuum verb.
- **The log is clean.** 0 matches for `op://`, `sk-`, `Bearer`, `api_key`,
  `password`. It records session/message ids, plugin paths, provider/model ids
  and error strings only.
- **`models.json` is a copied public catalog**, 4.7 MB, 222 providers / 7865
  models, provider keys `api/doc/env/id/models/name/npm`, 0 `apiKey`/`key`/
  `token`/`secret`/`password` fields. `qwen-local` is not in it (the overlay
  declares it). Not a secret — but it is 4.7 MB of third-party catalog sitting
  at 0600 inside a secret handler's quarantine, and it is regenerated on demand.

## Anti-claims (bounds)

- Nothing here proves the daemon ran after 2026-09-21. The durable bound is
  **content**: the last log line is 2026-09-21T04:58:13Z, `max(session.time_updated)`
  = 2026-09-21T04:57:08Z (ms epoch 1789966628471) and the row census is
  7/39/55/238 — all unchanged rounds 6→10. The DB *file* mtime is **not** part
  of that bound: it reads 2026-09-28T19:59:02Z (re-observed round 10), because
  any SQLite open — including a read-only one — can advance it, and round 10's
  own read side did. `corpus/state-shape.tsv` therefore pins magic/mode/**row
  floors**, never mtime. No `session-id` existed at either read (`state stopped`).
- The DB is a *projection* of the event log (`event` rows) — reading `part`
  alone under-counts; reading `event` alone gives types but not text.
- `agent=janitor` on all 7 sessions bounds what this daemon did; it is **not** a
  claim that a local process cannot ask the same server to use another agent.
- The 0600 modes are a property of the wrapper's `umask 077`; running
  `opencode serve` by hand against these XDG roots reproduces the same file set
  at 0644, so "files are 0600" must not be assumed from the paths themselves.

## Repro / falsification

```sh
SD=~/.local/state/the-janitor
stat -c '%A %s %n' $SD $SD/xdg-data $SD/xdg-cache $SD/xdg-state $SD/xdg-data/opencode/*
find $SD -type d -empty                       # repos/, xdg-cache/opencode/bin/, xdg-state/opencode/locks/

L=$SD/xdg-data/opencode/log/opencode.log
grep -o 'level=[A-Z]*' $L | sort | uniq -c    # 84 level=ERROR
grep -o 'run=[a-f0-9]*' $L | sort | uniq -c   # 8 daemon starts in one 33 KB file
grep -c 'Cannot connect to API' $L            # 70
grep -c 'failed to load plugin' $L            # 10 (fnm-nudge.js, every logged run)

DB="file:$SD/xdg-data/opencode/opencode.db?immutable=1"   # immutable => no -wal/-shm side effect
sqlite3 "$DB" "select 'session',count(*) from session union all select 'message',count(*) from message
               union all select 'part',count(*) from part union all select 'event',count(*) from event;"
sqlite3 "$DB" "select json_extract(data,'\$.type'),count(*) from part group by 1;"
sqlite3 "$DB" "select type,count(*) from event group by 1;"          # type is a column, not $.type
sqlite3 "$DB" "select json_extract(data,'\$.tool'),count(*) from part
               where json_extract(data,'\$.type')='tool' group by 1;" # janitor_auth|7
sqlite3 "$DB" "select count(*) from part where data like '%JANITOR_ACTION_REQUIRED%';"  # 2
sqlite3 "$DB" "select count(*) from part where data like '%op://%';"                    # 0
ls $SD/xdg-data/opencode/                     # reading in place adds 0600 -wal/-shm; cp to /tmp instead

grep -n 'flock\|exec 9>' ~/.local/bin/the-janitor      # locking verbs: L130/131, L139/140, L175/176 (+ need_command flock L63)
grep -n 'rm -f\|rm -rf' ~/.local/bin/the-janitor       # L97, L183 only — no purge path

# lock wedge, against a scratch state dir (never the real one):
W=$(mktemp -d); : > $W/client.lock
flock -x $W/client.lock -c 'sleep 5' &
THE_JANITOR_STATE_DIR=$W timeout 2 the-janitor stop;  echo "stop exit=$?"   # 124 while held
THE_JANITOR_STATE_DIR=$W timeout 2 the-janitor start; echo "start exit=$?"  # 124 while held
THE_JANITOR_STATE_DIR=$W the-janitor status | tail -1                       # state stopped (lock-free, exit 0)
wait; THE_JANITOR_STATE_DIR=$W the-janitor stop                             # already stopped, exit 0
# NB: `start` here is only safe because the background flock (5 s) outlives the
# 2 s timeout. A lock-free `start` will really launch the handler and prompt
# 1Password — use the isolated TMUX_TMPDIR form below for bare-start probes.

# ensure_started diagnostics without any vault access or real-tmux side effect:
#   `env -u TMUX` matters: from inside another tmux session $TMUX overrides
#   TMUX_TMPDIR and the probe would create its pane on the REAL server.
SHIM=$(mktemp -d); printf '#!/bin/sh\nexit 1\n' > $SHIM/op; chmod +x $SHIM/op
S=$(mktemp -d); T=$(mktemp -d)
env -u TMUX TMUX_TMPDIR=$S THE_JANITOR_STATE_DIR=$T PATH=$SHIM:$PATH the-janitor start
#   => "handler exited before becoming ready" + Settings hint, exit 1, <1 s
env -u TMUX TMUX_TMPDIR=$S tmux new-session -d -s janitor 'sleep 90'
env -u TMUX TMUX_TMPDIR=$S THE_JANITOR_STATE_DIR=$T the-janitor start
#   => "handler is waiting for 1Password authorization", exit 1 after ~64 s
env -u TMUX TMUX_TMPDIR=$S tmux capture-pane -t janitor -p
env -u TMUX TMUX_TMPDIR=$S tmux kill-server
rm -rf $SHIM $S $T $W
```
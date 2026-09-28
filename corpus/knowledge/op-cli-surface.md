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

| `op run --env-file=<plain-only env> -- <cmd>` (round 10) | value passed through, no `op://` ref to resolve | 0, ~0.02 s | **no** — no vault contact, no prompt |
| `op run --env-file=<env with an op:// ref>` (round 10, signed out) | either `[ERROR] … "<Vault>" isn't a vault in this account…` after ~4 s, **or** nothing at all for the whole bound (25 s, stdout+stderr empty) | 1 / 124 | yes — non-deterministic: fast-fail or silent block on the desktop approval prompt (round 3's `_serve` path blocked ~60 s) |

## `cmd_run` inherits that non-determinism (round 10)

`the-janitor run -- <cmd>` execs `op run` with the real env file, so with any
`op://` ref present and the account signed out it either dies fast or **hangs
silently** — round-10 probes observed both within one session (4 s/exit 1 and
25 s/exit 124 with empty streams). Bound it (`timeout 30 …`) before using it in
any scripted path; a plain-values-only env file is the one shape that returns
promptly with no vault contact. The argument guards fire before `op` is
reached: missing command ⇒ exit 2 `the-janitor run: missing command`; missing
env file ⇒ exit 2 `the-janitor: missing <path>`.

## `cmd_refs` redaction is a prefix match, not a validator (round 10)

The `awk` at L228–235 prints `KEY=<value>` verbatim when
`v ~ /^op:\/\//`, else `KEY=<redacted-non-op-value>`. Consequences, both
observed on fabricated env files:

- **Leak:** a value whose first five bytes are the ref scheme is echoed whole —
  anything after them rides out unredacted.
- **Silent omission:** `export K=v`, ` K=v` (leading whitespace) and
  `lower_case=v` never match `^[A-Z][A-Z0-9_]*=`, so those keys are absent from
  the output entirely. An inventory taken through `refs` can be incomplete
  without any error.
- Correctly redacted: an empty value, `a=b`, a plain value embedding a ref
  later in the string, and a plain value preceded by whitespace *after* a
  matched key.

So the defensible claim is "keys and ref-shaped values are echoed; other values
are replaced by `<redacted-non-op-value>`" — **not** "`refs` output is safe to
paste". `bash corpus/surface-census.sh --verbs` pins both behaviours
(`refs-shape-table`, `refs-redaction-prefix-only`).

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
"$SESSION_FILE"` runs unconditionally at L183. After the failed `request`
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
- Round-10 additions — the `op` claims in *this entry* reproduced by
  `bash corpus/surface-census.sh --verbs` (default set covers `refs` shapes and
  the argument guards; `--deep` covers the `op run` pair and the
  `tac-register` no-replace re-run): a fabricated plain-only env file ⇒ exit 0
  with the value passed; a fabricated ref env file signed out ⇒ exit 1 or exit
  124 within the bound, never 0; a value beginning `op://` ⇒ echoed whole; a
  `lower_case=`/`export`/leading-space line ⇒ absent from the output.

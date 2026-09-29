# Credential isolation of the janitor handler

Source: `~/.local/bin/the-janitor` `cmd_serve` (L186–226), `~/.config/the-janitor/opencode.json`,
`~/.config/opencode/agents/janitor.md`, `~/.config/opencode/tools/janitor_auth.ts`.
All read 2026-09-28.

Reverify: R11-01, R11-04

## Authorization lives in one process

- `_serve` runs inside detached tmux session `janitor`. Two auth paths (L194–210):
  - `OP_SERVICE_ACCOUNT_TOKEN` already in env → used as-is, no `op signin`.
  - Otherwise `op signin --raw` output goes into env var `OP_SESSION_<account_domain>`
    (domain parsed from `op account get --format=json`), then `op whoami` verifies.
  The session token never touches a file; `the-janitor stop` kills the tmux session
  and the authorization dies with the process (`status` prints
  `authorization process_memory_only`, L170).
- Before `exec opencode serve`, `cmd_serve` unsets 20 model/API credential
  variables (ANTHROPIC_*, OPENAI_API_KEY, GEMINI_API_KEY, GROQ/XAI/OPENROUTER/
  MISTRAL/ZAI/MINIMAX/CURSOR/AWS/GOOGLE…, L214–219). Comment at L212–213:
  "Keep every model credential out of the handler environment … OpenCode fails
  closed."
- Handler serves only `127.0.0.1:40961` (`--hostname 127.0.0.1 --port 40961`,
  L225) with `--log-level ERROR`.
- XDG dirs are redirected under `$STATE_DIR/xdg-{data,cache,state}` (chmod 700,
  L190–191, L222–224): handler state is quarantined from the user's normal
  `~/.local/share`, `~/.cache`, `~/.local/state`.

## Model boundary is fixed

`~/.config/the-janitor/opencode.json` (759 bytes, read 2026-09-28):

- `enabled_providers: ["qwen-local"]` only; `model` and `small_model` both
  `qwen-local/Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS` at
  `http://127.0.0.1:8080/v1` (existing llama.cpp endpoint).
- `autoupdate: false`, `share: "disabled"`, `default_agent: "janitor"`.
- `status` prints `fallback disabled` — there is no cloud fallback by design.

## Agent permissions are deny-all + one tool

`~/.config/opencode/agents/janitor.md` frontmatter: `mode: primary`,
`steps: 4`, `permission: {"*": deny, janitor_auth: allow}`.

`~/.config/opencode/tools/janitor_auth.ts` (14 lines): runs
`op vault list --format=json` with stdin/stdout/stderr all `ignore`; returns
exactly `AUTH_OK` (exit 0) or `AUTH_REQUIRED`. The model cannot see `op`
output at all — only the process exit code mapped to a two-word string.

Agent invariants (janitor.md L14–30): never print/quote/summarize a secret
value, session token, cookie, or field value; call `janitor_auth` at most once
per request and emit its result verbatim; never execute secret reads/writes —
return a redacted plan naming vault/item/field *labels* and end with
`JANITOR_ACTION_REQUIRED`; no spawning agents, no unrelated work.

## Caveat: the ceiling binds the *agent*, not the port (round 7)

`client.py` requests pin `"agent": "janitor"`, so the deny-all above governs
the *intended* path only. The HTTP control plane on `127.0.0.1:40961` is
unauthenticated and the message body's `agent` field selects the permission
set — a local process naming a permissive global agent executes tools in the
same daemon env (OP_SESSION_* / OP_SERVICE_ACCOUNT_TOKEN present). See
`handler-trust-boundary.md`; the fix recipe is `control-plane-hardening.md`.

## The `steps: 4` cap is load-bearing

`~/.local/state/tac/handoff-status.json` `janitor_provenance` records a real
precedent: a natural-language request "returned maximum-steps text without
creating requested artifact". A janitor request that needs >4 model steps dies
mid-flight — the deterministic checksum verbs (`tac-check`, `tac-register`)
exist because the model path could not be trusted to finish the job.

## Falsification

- `grep -n 'unset' ~/.local/bin/the-janitor` shows the credential strip list.
- `the-janitor status` prints `endpoint http://127.0.0.1:8080/v1` and
  `fallback disabled`.
- `cat ~/.config/opencode/tools/janitor_auth.ts` shows all three stdio streams
  ignored.

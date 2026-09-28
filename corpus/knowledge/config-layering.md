# opencode config layering for the janitor handler

Source basis: `~/.local/bin/the-janitor` `cmd_serve` (L186–226), resolved via
`opencode debug config` / `opencode debug agent janitor` (opencode 1.18.31)
under the exact `_serve` env on 2026-09-28; embedded `customize-opencode` doc
inside the opencode binary. No model call, no vault access — all deterministic.

`_serve` runs `cd $CONFIG_DIR` then `exec opencode serve` with
`OPENCODE_CONFIG=$CONFIG_DIR/opencode.json`. What the handler actually loads is
a **merge of layers**, not a single file:

## The layers

| Layer | Source | Discovered how | In the resolved janitor? |
|---|---|---|---|
| global config | `~/.config/opencode/opencode.json` (455 lines) | XDG convention; always loads | yes — supplies 8 extra `provider` defs, `permission` rules, agents/skills/commands/plugins |
| explicit overlay | `~/.config/the-janitor/opencode.json` | `OPENCODE_CONFIG` env — **additional** config, merged *after* global | yes — sets `enabled_providers`, `default_agent`, `model`, `share`, `autoupdate`, `baseURL`, `default_agent` |
| project config | `./opencode.json` / `.opencode/opencode.json` walking up from cwd | cwd = `$CONFIG_DIR`, which has none | absent — but **not disabled**; adding `opencode.json`+a dir under `$CONFIG_DIR` is already a discovered file (see §4). Kill switch: `OPENCODE_DISABLE_PROJECT_CONFIG=1` (not set by `_serve`) |
| markdown agent | `~/.config/opencode/agents/janitor.md` | global agents dir | yes — frontmatter overrides the whole `agent.janitor` object from JSON layers |
| dead file | `~/.config/the-janitor/config.json` (406 B) | **nothing loads it** — `config.json` is not an opencode-discovered filename | no — inert decoy (below) |

## What leaked in (proven, resolved dump)

- **`provider`**: resolved map has 9 providers (`alibaba-token-plan` ×3,
  `openai`, `opencode-go` ×3, `xai-key`, `qwen-local`) merged from global.
  `enabled_providers: ["qwen-local"]` filters them at provider-init time —
  this is post-merge gating, not namespace isolation. A global provider edit
  changes the handler's resolved config even though janitor can only select
  `qwen-local`.
- **`agent`**: resolved map has 23 agents (the entire fleet). `client.py`
  posts `agent:"janitor"`; siblings are unreachable via that fixed field but
  they are *loaded* into the process.
- **`permission`**: 56-entry ordered ruleset = global rules + overlay +
  janitor.md's `{"*": deny, janitor_auth: allow}` appended at the end, evaluated
  last-match-wins. The janitor deny is the effective ceiling — `tools` map
  shows every built-in `False`, only `janitor_auth: True`.
- **`plugin`**: global `plugin/fnm-nudge.js` (`plugin_origins` scope `global`)
  loads into the handler process. Its `fnm_check` tool does **not** appear in
  janitor's resolved `tools` and its `tool.execute.after` hook only fires on
  the `bash` tool (denied) — dead code path today, but it proves global
  plugin code executes in the handler. Any future global plugin with an
  enabled-tool hook or a lifecycle hook runs inside janitor.
- **`command`**: resolved map inherits global prompt commands — cosmetic.
- **`mcp`**: empty — global defines none for janitor.

## `steps` precedence: markdown frontmatter wins

`janitor.md` frontmatter `steps: 4` is the resolved value
(`debug agent janitor` → `"steps": 4`). The inert `config.json` claims
`agent.janitor.steps: 8`; even if a live layer carried it, the md definition
would still win (observed precedence, this version). SKILL.md's `steps: 4`
claim is verified against the running resolver, not just the file.

## `config.json` — the inert decoy

`~/.config/the-janitor/config.json` (0600, sha256 `af8873ca…`) looks like a
second overlay (`$schema` = opencode config schema; `provider.qwen-local`
model limits; `agent.janitor` block). It is **dead weight**: opencode
discovers `opencode.json`/`opencode.jsonc`/`./opencode/opencode.json`,
`OPENCODE_CONFIG` points at `opencode.json`, and nothing else references the
file (grep of `the-janitor` shows zero hits). Its `steps: 8` and absent
`baseURL` are traps for a reader, not live config. Editing it changes nothing;
its drift cannot affect the handler. Not recorded: its `agent.janitor.options`
values (unneeded — the file is inert).

## Isolation is the permission ceiling, not the config boundary

Prior corpus wording — "the isolation is the config" — needs the sharpened
form: **global layers leak into the janitor process; containment comes from
`enabled_providers` + the last-match permission deny + `tools` map, all of
which were verified post-merge**. The `_serve` env unsets 20 cloud-key vars
(L214–219) so leaked provider defs have no credentials anyway — the env
scrub is the second wall.

Round-7 qualifier: the ceiling binds the **agent named in the request**, not
the socket. `client.py` pins `"agent": "janitor"`, but port 40961 has no auth
— a local process posting `"agent": "<permissive-global>"` runs tools in the
daemon env. The two walls above hold only for requests routed to the janitor
agent; see `handler-trust-boundary.md`.

## Reproduce (deterministic, no vault)

```bash
cd ~/.config/the-janitor
env OPENCODE_CONFIG="$PWD/opencode.json" \
    XDG_DATA_HOME=/tmp/oj-dbg/data XDG_CACHE_HOME=/tmp/oj-dbg/cache \
    XDG_STATE_HOME=/tmp/oj-dbg/state \
    opencode debug agent janitor   # resolved steps/tools/permission
env OPENCODE_CONFIG="$PWD/opencode.json" \
    XDG_DATA_HOME=/tmp/oj-dbg/data XDG_CACHE_HOME=/tmp/oj-dbg/cache \
    XDG_STATE_HOME=/tmp/oj-dbg/state \
    opencode debug config          # resolved provider/agent/plugin/command
```

XDG redirects keep the probe out of the real `$STATE_DIR`. Output fields used
above: `steps`, `model`, `permission[]`, `tools{}`, `enabled_providers`,
`provider{}` keys, `agent{}` keys, `plugin`/`plugin_origins`, `command`.
`debug agent` exits 0 whether the handler is running or not — it resolves
files, not the live server.

## Anti-claims

- This probes resolution only; no model request, no `janitor_auth`, no vault.
- `debug` output is this-version semantics (1.18.31); an opencode upgrade can
  re-order precedence — re-run the probe before citing.
- `enabled_providers` narrows *selection*, it does not prevent a misconfigured
  global provider from breaking config parse for the whole merge.

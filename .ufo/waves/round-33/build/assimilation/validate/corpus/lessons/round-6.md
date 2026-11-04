# Round-6 lesson — trust the resolver, not the files

## The question

Which layer wins for `agent.janitor`? Files on disk disagreed:
`janitor.md` frontmatter `steps: 4` vs `~/.config/the-janitor/config.json`
`steps: 8`. Prior rounds recorded `config.json` as "second overlay, shape
known, values unrecorded" — i.e., unresolved whether it was live.

## What the probe showed

`opencode debug agent janitor` under the exact `_serve` env resolved
`steps: 4` — markdown wins, and `config.json` contributed nothing (it is not
a discovered filename at all: discovery is `opencode.json`/`opencode.jsonc`/
`.opencode/` + `OPENCODE_CONFIG` + global XDG). Resolved `debug config`
exposed the bigger truth: the handler merges the **global** opencode config
(9 providers loaded, post-merge gated to `qwen-local`), all 23 fleet agents,
global `plugin/fnm-nudge.js`, and global prompt commands. The overlay's job
isn't isolation — `enabled_providers` + last-match permission deny +
`_serve`'s 18-var credential unset are.

## Lessons

1. **Static file reads lie about precedence.** A config value's authority is
   only what the resolver computes. `opencode debug config` / `debug agent`
   are the ground truth — deterministic, offline, no model, no vault. Run
   them before writing any claim about effective config; they're this
   corpus's cheapest falsification tool.
2. **"Adjacent-looking config" can be dead.** `config.json` sits in the same
   dir with the right `$schema` and plausible fields — and loads nowhere.
   Zero grep hits in the launcher + absent from the resolved dump = inert.
   Record inertness explicitly or every future reader re-litigates it.
3. **"The isolation is the config" was the wrong abstraction.** The real
   containment is three walls — post-merge provider gate, permission ceiling,
   env scrub — all downstream of a merge that includes the operator's global
   config. Global edits and new global plugins are live drift surfaces on the
   handler; `drift-pins.sh` now covers `~/.config/opencode/opencode.json` too.
4. **Markdown agent frontmatter beats JSON `agent.*` blocks** in this version
   (1.18.31) — observed, not assumed; re-probe after opencode upgrades.
5. **A permission list is only as good as its evaluation order.** 56 merged
   rules could have shadowed janitor's deny; last-match-wins + md-layer-last
   ordering is what keeps `tools = {janitor_auth: true}` — verify via the
   `tools` map, never by counting `deny` entries.

## Evidence

- `cd ~/.config/the-janitor && env OPENCODE_CONFIG=… XDG_DATA_HOME=/tmp/oj-dbg/… opencode debug agent janitor` → `steps: 4`, `tools` map with only `janitor_auth`, 56-entry permission list.
- `opencode debug config` (same env) → 9 `provider` keys, `enabled_providers: ["qwen-local"]`, `baseURL` still `127.0.0.1:8080/v1`, 23 `agent` keys, `plugin_origins` global `fnm-nudge.js`.
- `strings opencode | grep` → embedded `customize-opencode` doc naming the discovery set and `OPENCODE_DISABLE_PROJECT_CONFIG`/`OPENCODE_CONFIG`/`OPENCODE_CONFIG_CONTENT` knobs.
- `sha256sum`/`wc -l` of 13 cited host files → `corpus/drift-pins.sh` pins.

No vault access, no model call, no secret values, no ref paths recorded.

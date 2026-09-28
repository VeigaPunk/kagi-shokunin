# kagi-shokunin — Iteration Log

- 2026-09-28 — round 0: minted as shonen.
- 2026-09-28 — round 1: `not-dispatched` (MANIFEST.json `rounds[1].lanes.kagi`);
  aggregator seeded corpus index + `knowledge/janitor-command-surface.md` from
  read-only host inspection; SKILL.md stayed the seed.
- 2026-09-28 — round 2: grounded SKILL.md in real surfaces. Evidence:
  `the-janitor --help` + full read of `~/.local/bin/the-janitor` (333 lines),
  `~/.config/the-janitor/client.py`, `~/.config/the-janitor/opencode.json`,
  `~/.config/opencode/agents/janitor.md`, `~/.config/opencode/tools/janitor_auth.ts`,
  `~/.local/bin/tac-check`, `~/.local/state/tac/handoff-status.json`;
  live probes `the-janitor status` (state stopped), `cdp-bridge status`
  (nmh present, cdp down), `op --version` (2.35.0). Wrote the 6 corpus
  entries the seeded index named but lacked on disk (4 knowledge + 2
  lessons), reconciled `corpus/README.md` (fixed `rounds[1].deferred` →
  actual `lanes.kagi` key, recorded config.json key-shape read). No vault
  access, no secret values, no ref paths recorded. Highest-value gap
  closed: index-vs-disk drift + seed SKILL.md → decision tables, failure
  texts, hygiene checklist, evidence-receipt patterns, anti-patterns.
- 2026-09-28 — round 3: executed the missing end-to-end proof. Evidence:
  `echo 'Reply with the single word READY.' | the-janitor request` →
  `handler exited before becoming ready` (~60 s, exit 1) — full pipeline
  exercised to the 1Password auth gate; root cause confirmed by
  `the-janitor whoami` → `account is not signed in` (exit 1). Found endpoint
  drift: overlay pins `127.0.0.1:8080/v1` but 8080 is a Jitsi videobridge;
  llama-server serves the pinned Qwen3-Coder-30B model on **34113**
  (`/health` ok). `op account list` works signed out (4-field shape, values
  PII — not recorded). `the-janitor stop` observed idempotent
  (`already stopped`, exit 0, still `rm session-id`). Landed:
  `knowledge/op-cli-surface.md`, `lessons/round-3.md`, SKILL.md additions
  (whoami predictor, endpoint-health check, overloaded failure text, stop
  idempotence), README coverage/gaps update, SHONEN box 2 checked as
  executed-with-negative-result. No secret values, no ref paths, no
  account-identifying values recorded.
- 2026-09-28 — round 4: closed the env-var/service-account gap. Evidence:
  `~/.local/bin/the-janitor` L1–27 (path/port knobs) + `cmd_serve` L186–226
  re-read (sha256 2408b0c9…57edd, unchanged since round-2 read);
  `opencode.json` `baseURL` read (endpoint truth confirmed);
  live probes: `the-janitor status`/`whoami`/`refs`/`run` (missing-env and
  missing-command exits both 2), `op account get` (works signed out; shape
  recorded, values are PII — withheld), `curl` on 8080 (Jetty 404 — drift
  persists) and 34113 (`{"status":"ok"}`), CDP 9222 down. Landed:
  `knowledge/janitor-env-contract.md` (full knob table; auth selectors
  `OP_SERVICE_ACCOUNT_TOKEN`/`OP_ACCOUNT`; `MODEL_ENDPOINT` is cosmetic —
  drift fix = one overlay field), `lessons/round-4.md`, SKILL.md decision
  table + env-contract section + 3 anti-patterns, README coverage/gaps.
  No secret values, no ref paths, no account-identifying values recorded.
- 2026-09-28 — round 5: closed the last named corpus gap — secret-rotation /
  revocation practice. Evidence: `the-janitor` L128–249 re-read
  (`cmd_request`/`cmd_start`/`cmd_stop`/`cmd_refs`/`cmd_run`), `client.py`
  L41–95 (`get_session_id`/`session_exists`/`run_prompt`), `janitor_auth.ts`;
  live probes `status` (stopped), `whoami` (`account is not signed in`,
  exit 1), `ls -la` both state dirs (no `session-id` — consistent), tmux
  (`ufo_sighting` only), curl 34113 (`/health` ok) + 8080 (404 — drift
  unchanged). Finding: no rotate/revoke verb exists by design — `stop` is
  the revocation primitive (process-memory-only authorization); rotation is
  per-class rotate-at-source (only `_serve`-env secrets need restart);
  `session-id` is conversation context, not a credential; vault-side
  revocation surfaces lazily as `AUTH_REQUIRED`. Landed:
  `knowledge/janitor-lifecycle.md`, `lessons/round-5.md`, SKILL.md
  rotation/revocation section + 2 anti-patterns + falsification row, README
  coverage/gaps. SHONEN boxes 1/3/4 checked — SKILL.md carries cited
  decision/failure tables, is self-contained for an agent without oral
  context, and PROVINCE.md scope held (no cross-domain absorption). No
  secret values, no ref paths, no account-identifying values recorded.
- 2026-09-28 — round 6: closed the config-layering gap and corrected three
  stale corpus claims. Evidence: `opencode debug agent janitor` + `opencode
  debug config` run under the exact `_serve` env (cwd `$CONFIG_DIR`,
  `OPENCODE_CONFIG`, throwaway XDG dirs — janitor state untouched);
  `customize-opencode` doc extracted from the opencode 1.18.31 binary;
  sha256/wc pins of 13 cited host files. Findings: `OPENCODE_CONFIG` is
  **additive** — global `~/.config/opencode/opencode.json` merges underneath
  (9 providers loaded, gated to `qwen-local` by `enabled_providers`; 23
  agents + global plugin `fnm-nudge.js` load into the process; 56-entry
  permission list resolves last-match-wins with janitor's deny as ceiling —
  `tools` map = only `janitor_auth`). `~/.config/the-janitor/config.json`
  is **inert** (not a discovered filename; resolved `steps: 4` beats its
  `steps: 8`) — README gap resolved to "dead config". Project-config
  discovery under `$CONFIG_DIR` is live but unused; hardening knobs named
  (`OPENCODE_DISABLE_PROJECT_CONFIG`, dedicated XDG_CONFIG_HOME, `--pure`)
  — operator decision, not applied. Landed: `knowledge/config-layering.md`,
  `corpus/drift-pins.sh` (host-file fingerprints), `lessons/round-6.md`,
  SKILL.md layering section + checklist/anti-pattern/falsification updates,
  README rows + gap resolution. No vault access, no secret values, no ref
  paths recorded.
- 2026-09-28 — round 7: audited the control plane and the disk — the two
  surfaces every prior round assumed rather than read. Evidence:
  `drift-pins.sh` clean (13/13 pinned files unchanged); scratch
  `opencode serve` replicas under /tmp (ports 41994–41999, 45981–45983,
  46231–46233 — all killed, dirs removed): no-auth `POST /session` 200,
  `POST /session/{id}/shell` executes a command in the daemon env in 51 ms
  with no model call, `agent` selects any of 26 loaded agents (enumerable
  via unauth `GET /agent` + `GET /config`), body `tools` map re-enables
  denied tools under `agent:"janitor"`; password set ⇒ 401 Basic-only
  (`opencode:<pw>` 200; Bearer/wrong-user/wrong-pw 401; all endpoints incl.
  `/global/health` gated); `OPENCODE_SERVER_USERNAME` honored. No
  project-trust, Origin/Host, or per-UID check; a clean shell has no ambient
  `op` session (25 s hang → timeout) — daemon env is the sole credential
  source. Disk: `xdg-data/opencode/opencode.db` (0600 via wrapper umask 077;
  7 sessions/39 messages/55 parts, plaintext `$.text`) + `opencode.log`
  (8 recorded starts; plugin failure every start; endpoint `stream error`
  ≈58 s exponential backoff) persist past `stop`, which rm's only
  `session-id`. Lock topology measured: `request` holds `client.lock`
  through the 3600 s round-trip and wedges `stop`/`start`; only
  `tmux kill-session` unblocks. tmux 3.7b env passthrough verified broken
  for pre-existing servers (headless `OP_SERVICE_ACCOUNT_TOKEN` export
  silently drops → falls to interactive signin). 9 L2 lanes dispatched;
  verifier corrections applied (flock lines, probe-loop timing, stdout vs
  stderr warning, plugin-failure recurrence, `open` agent nonexistent →
  `tools`-map arm). Landed: `knowledge/handler-trust-boundary.md`,
  `knowledge/handler-on-disk-state.md`,
  `knowledge/control-plane-hardening.md` (operator handoff), corrections to
  `credential-isolation.md`/`config-layering.md`/`janitor-lifecycle.md`
  (ceiling = per-agent request policy, transcripts durable),
  `lessons/round-7.md`, SKILL.md trust-boundary + disk/wedge sections,
  decision-table diagnose row, failure-table wedge causes, env-trap,
  checklist/anti-pattern/falsification rows, README coverage + two open
  operator gaps. Reported to integrator: CDP-9222 lease is serialization,
  not an ACL — same loopback-is-not-a-boundary question applies (kake).
  No vault access; `OP_*` values in probes were fake placeholders; no
  secret values, ref paths, or account values in any artifact.

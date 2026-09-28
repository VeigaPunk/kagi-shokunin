---
name: kagi-shokunin
description: Domain specialist — secrets & vault ops — the-janitor flows, credential hygiene evidence, vault lifecycle. Rank: shonen.
---

# kagi-shokunin — secrets & vault ops

Domain: the-janitor persistent handler (tmux `janitor`, OpenCode server
`127.0.0.1:40961`, fixed model `qwen-local/Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS`
at `127.0.0.1:8080`), 1Password CLI `op` 2.35.0, env-file ref discipline,
evidence receipts, CDP bridge. Corpus: `corpus/knowledge/*` holds the
sourced detail; this file is the executable layer.

**Hard rule:** never print, copy, or exfiltrate a secret value, session token,
cookie, or vault field. Ref *paths* (`op://…`) are internal metadata — usable
in a plan, never pasted into a durable artifact (report, commit, handoff,
corpus entry). Handle hygiene *evidence* and *flows*, not secret material.

## Vault-ops decision table

| Intent | Correct surface | Never | Notes / expected output |
|---|---|---|---|
| Ask the handler anything | `echo '…' \| the-janitor request` (stdin only) | args, tmux send-keys, port probing | text reply on stdout; empty-text reply still exits 0 |
| Check handler state | `the-janitor status` | reading `session-id` to infer auth | prints `state`, `health`, `authorization process_memory_only` |
| Check 1Password authorization | `request` → handler calls `janitor_auth` → `AUTH_OK`/`AUTH_REQUIRED` | `op whoami` against handler auth | caller-side check is `the-janitor whoami` — exit 1 (`account is not signed in`) predicts `request` will die in readiness |
| One-shot command with vault env | `the-janitor run -- <cmd>` | assuming handler auth; it uses caller's `op` | needs `~/.config/the-janitor/op.env` present |
| Inventory env keys | `the-janitor refs` | `cat op.env` (skips redaction); pasting output into artifacts | `KEY=op://…` verbatim / `KEY=<redacted-non-op-value>` |
| Start / stop handler | `the-janitor start` / `stop` | `kill` on the tmux pane | `stop` discards in-memory authorization; next `start` requires re-approval |
| Verify TAC receipt | `the-janitor tac-check` | treating it as live access or authorization | offline SHA-256 + field check; exit 0 = bytes intact only |
| First custody registration | `the-janitor tac-register` | running twice expecting refresh — O_EXCL, never replaces | writes `~/.local/state/the-janitor/tac-daybreak-blue.json` 0600 |
| 1Password in musketeer Chrome | `cdp-bridge ensure` then `status` | `open-popup` (hard refusal, exit 2); scraping vault DOM | manifest at `$MUSKETEER_CHROME_PROFILE/NativeMessagingHosts/` |
| Vault UI / unlock popup | operator + agent-browser, not janitor | automating the unlock flow | boundary is explicit in code |
| Verify model endpoint is real | `curl -fsS <endpoint-minus-/v1>/health` → `{"status":"ok"}` | trusting `status`'s `endpoint` line — it prints config, never probes | port 8080 was a Jitsi videobridge on 2026-09-28 while llama-server served the model on 34113 |

## Failure table (exact texts, exits)

| Symptom | Cause | Exit |
|---|---|---|
| `required command not found: <cmd>` | missing tmux/python3/op/opencode/flock | 2 |
| `missing executable client: …/client.py` | client.py not +x | 2 |
| `missing model overlay: …/opencode.json` | overlay unreadable | 2 |
| `port 40961 already has an OpenCode server outside tmux session janitor` | foreign server squatting the port | 1 |
| `handler exited before becoming ready` | app not unlocked / CLI integration off — **or** `op signin` died non-interactively (caller signed out; check `the-janitor whoami` first) | 1 |
| `handler is waiting for 1Password authorization` | 60 s readiness loop expired — unlock app, approve prompt, `tmux attach -t janitor` if terminal input requested | 1 |
| `request text must be supplied on stdin, not as arguments` | args passed to `request` | 2 |
| `read an empty request from stdin` | empty stdin (client.py) | 2 |
| `Janitor server is unavailable` / `HTTP <code>` / `invalid response` | transport-layer client errors | 1 |
| `request completed without a text response` | well-formed reply, no text parts — **not a failure**, exits 0 | 0 |
| `LOCAL_EVIDENCE_CHECK: FAILED (<reason>)` | receipt bytes/schema/fields diverge from custody record | 1 |
| `JANITOR_ACTION_REQUIRED` in reply | handler correctly refusing to execute; operator action needed | — |

Model cap: `steps: 4` on the janitor agent. Requests needing >4 steps die at
max-steps with no artifact (observed precedent in `handoff-status.json`
`janitor_provenance`) — keep requests atomic; deterministic work belongs in
`the-janitor` subcommands, not the model path.

## Credential-hygiene checklist

Evidence production:
- [ ] Record mechanism and metadata: paths, modes (`op.env` 0600, state dir 0700, `client.lock`/`session-id`/`config.json` 0600), verb names, exit codes, field names.
- [ ] Quote command output only when it is metadata-only (`status`, `cdp-bridge status`, `tac-check` block).
- [ ] `refs` output: key names OK for internal use; ref paths stay out of artifacts.
- [ ] Receipts/checksums bind *bytes*: state scope explicitly ("local receipt integrity only"), never imply provider attestation or live access.
- [ ] Handoffs carry context + receipt *path*; `handoff-status.json` `boundaries` is the vocabulary: `credentials_in_evidence: false`, `target_authority_conferred: false`.

Handler operation:
- [ ] One request at a time — `client.lock` flock serializes machine-wide; queue instead of racing.
- [ ] After `stop`, expect `AUTH_REQUIRED` on next request until the operator re-approves.
- [ ] Keep `config_overlay` (`opencode.json`) intact: `enabled_providers: ["qwen-local"]`, `share: disabled`, `autoupdate: false` — the isolation is the config.
- [ ] Never widen `janitor` agent permissions (`{"*": deny, janitor_auth: allow}`) — `janitor_auth` ignores all `op` output for a reason.
- [ ] CDP port 9222 + musketeer profile are shared with the kake fleet: report lease conflicts, don't absorb them.

## Evidence-receipt patterns

- **Checksum + custody split** (`tac-check`): receipt file holds the observation;
  a separate custody record (`custodian: the-janitor`, `receipt_sha256`) pinned
  with `O_EXCL` 0600 makes later tampering detectable, not silently updatable.
- **Negative-space assertions**: receipts record what was *not* true
  (`tool_events_observed: 0`, `safeguards_removed: false`) — integrity evidence
  must bound itself, or it reads as authorization.
- **Verification vocabulary** is fixed and quotable: `LOCAL_RECEIPT_INTEGRITY`,
  `CHALLENGE_RESPONSE: MATCH`, `LIVE_ACCESS_NOW: not rechecked`,
  `LIMIT: locally writable evidence`. Reuse it; don't invent synonyms.
- **Offline is a feature**: deterministic checks (SHA-256, file modes,
  key-shape comparison) need no model, vault, network, or approval — prefer
  them for evidence that must be re-verifiable.

## Anti-patterns

- `the-janitor request "<text>"` — args are rejected (exit 2) by design; argv is world-readable via `/proc`.
- `cat ~/.config/the-janitor/op.env` or committing it — file holds live `op://` refs at 0600; use `refs` for key names only.
- Retrying `janitor_auth` inside a request — contract is one call, emit result, stop.
- `kill`ing the OpenCode server PID instead of `the-janitor stop` — leaves tmux + stale `session-id`.
- Treating `status`/`tac-check` OK as "vault is unlocked" or "TAC is live" — both are metadata/offline checks. Same for `endpoint`/`model`/`fallback disabled`: configured values, not probed capabilities (endpoint check lives in the decision table).
- Assuming a failed `request` left junk — a readiness death leaves no tmux session and no `session-id`; `the-janitor stop` is idempotent cleanup regardless (`already stopped`, exit 0).
- Silent re-registration of a checksum after tamper — `O_EXCL` prevents it; if register "should" refresh a record, the design assumption is wrong.
- Mapping vault/item structure into durable artifacts — ref paths are exfil-shaped; record that refs *exist*, not where they point.
- Absorbing cross-domain surfaces (CDP lease, musketeer profile) into this repo — report to integrator.

## Falsification

- `the-janitor --help`, `the-janitor status`, `the-janitor cdp-bridge status`,
  `the-janitor tac-check` reproduce every claimed surface (verified 2026-09-28).
  Round-3 additions: `the-janitor whoami` (exit + text reveal caller auth),
  `the-janitor stop` on stopped state (`already stopped`, exit 0, still
  removes `session-id`), endpoint `/health` curl (drift check),
  `corpus/knowledge/op-cli-surface.md` for the auth matrix + drift evidence.
- `corpus/knowledge/janitor-command-surface.md` carries line refs + runnable
  probes; script line numbers date to the 2026-09-28 read — re-grep before
  citing.

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

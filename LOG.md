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
- 2026-09-28 — round 8: shipped the transcript-leak gate. Evidence:
  `drift-pins.sh` clean (13/13 unchanged); full schema census of
  `xdg-data/opencode/opencode.db` via immutable-URI sqlite3 — credential-bearing
  tables (`account`/`account_state`/`control_account`/`credential`/
  `session_share`, NOT NULL token/secret columns) all empty; text columns
  enumerated (`part`/`message`/`event`.data, `session.title`,
  `session_input.prompt`, `session_message.data`,
  `session_context_epoch.baseline`/`.snapshot`, `todo.content`); 30-pattern
  LIKE sweep → 0 material hits, 4 credential-language cells across 5 sessions.
  Read-side gotcha re-verified live: `-readonly` mutated `-wal`/`-shm` mtimes,
  `file:…?immutable=1` did not. Landed: `corpus/transcript-scan.sh`
  (counts-only, exit 0/1/2, HIT/WARN tiers, `--selftest` seeded-hit check),
  `knowledge/transcript-hygiene.md`, `lessons/round-8.md`, SKILL.md decision
  row + gate section + checklist + 3 anti-patterns + falsification. Fixed
  corpus rot: README `Model endpoint drift` bullet truncated mid-sentence
  since round 7 (completed); `MODEL_ENDPOINT` stale ref L17→L19 across
  SKILL.md/README/env-contract/round-4 lesson. L2 lanes: reviewer fact-check
  (17 claims, 15 verified, 2 corrections applied: 5 distinct WARN sessions,
  truncation introduced round-7 not round-4), sentinel coverage pass.
  No vault access, no secret values, no ref paths, no row contents recorded.
- 2026-09-28 — round 9 (freshness axis-move): made drift detection real.
  Before: `drift-pins.sh` was a printer with no stored expectations —
  `git show HEAD:corpus/drift-pins.sh | grep -c baseline` → 0 — so no fresh
  process could detect drift; `PROTOCOL.md` §Evidence standard cited this repo
  ("pins verifiable for only 2 of 13 files") and `SHONEN.md` violated the
  protocol's mark form. Landed: `corpus/drift-pins.sh` v2 (451 lines, sha256
  `c138d34c…0feb`) = gate with exit 0/1/2; `corpus/drift-baseline.tsv`
  (15 rows `$HOME`-relative path/mode/lines/sha256); `corpus/drift-symbols.tsv`
  (19 claim pins: value pins on both endpoint declarations, key-presence pins,
  `#10`+`shape` on `op.env`, two `#1` count pins on the published handoff field
  names); `corpus/knowledge/drift-gate.md` (schemas, verdict table, hash policy,
  `--pin` refusals, bounds, reproduction); `corpus/lessons/round-9.md`;
  `SCORECARD.md` (first ever — the AXES contract was unmet) with pre/post scores
  and evidence per cell; `SHONEN.md` regenerated verbatim from the PROTOCOL
  template with per-box evidence lines; `PROVINCE.md` surface + refusal census.
  Evidence: verify `DRIFT_PINS: CLEAN (files=15 symbols=19)` exit 0; `--selftest`
  `DRIFT_SELFTEST: PASS (13 cases)` exit 0; `--baseline` with no arg → exit 2;
  falsified-baseline copy → `DRIFT … sha deadbeef0b7e->2408b0c90b7e` + exit 1;
  `op.env` baseline row carrying a hash → `POLICY …` + exit 1 (policy enforced
  before any read, so no secret-derived digest is ever printed); patched-endpoint
  copies → `GONE` ×2 + exit 1; forced count pin → refusal, exit 2; hardlinked
  twin → `LINK … nlink 2`, exit 1; `--pin` emitted three `REPIN` lines on a
  falsified baseline (audit path proven live). Hash policy: 6 private 0600 files
  pinned by mode+lines only (`op.env`, `config.json`, `~/.agents/AGENTS.md`,
  `handoff-status.json`, both TAC receipt/custody records) — a committed sha256 of
  a low-entropy private file is an offline confirmation oracle (L2 sentinel
  demonstrated recovery with zero host contact); the cost is stated in the corpus
  and sentinel's refinement ("only `op.env` strictly requires it") is recorded
  next to the decision. Overclaim sweep: `SKILL.md:205`/`:304` and
  `corpus/README.md:33` said "every cited host file" while 4 cited files were
  unpinned — corrected; 2 moved into `FILES` (15 total), the two `xdg-data`
  artifacts named as deliberate exclusions. README index completed (4 lesson
  files that existed on disk were unindexed). L2: 10 lanes in one batch (planner,
  connector, scout, executor, scribe, reviewer, critic, sentinel, labrat,
  distiller); their defects fixed and attributed — `REPIN` never fired (old-row
  map keyed literally), a missing option argument exited 1 instead of 2, an
  empty/missing symbols file could be wiped by `--pin`, symbol scan followed
  symlinks, hardlinks undetected, the count pin had no shape assertion, temp
  files could linger in the corpus dir. Reported to the integrator (adjacency,
  not absorbed): `~/.agents/AGENTS.md` is also audited by kotoba, and the pinned
  musketeer NativeMessagingHosts manifest sits inside kake's leased chrome
  profile — both monitored here, ownership unchanged; also the round-5 aggregator
  lesson's `drift-pins.sh:19` citation is now dead (v2 stores `$HOME`-relative
  paths) and is left for the integrator per the append-only rule. No vault
  access; no secret values, ref paths, account values, private-file hashes, or
  private-file line layouts in any artifact.
- 2026-09-28 — round 9 (same round, re-verification wave): the round-8
  transcript gate was wrong on first contact. `transcript-scan.sh` reported
  `HITS=3` on a DB whose row census is unchanged since round 8 (7 sessions/39
  messages/55 parts/238 events) — root cause: SQL `LIKE` treats `_` as "any
  single character", so the `gsk_` pattern matched `gsk` + any 4 alnum chars in
  7 event rows (literal `gsk\_` with `ESCAPE '\'` = 0 rows; run-length after
  literal `gsk` = 4 chars in all 7 → not key-shaped). Fixed: `like_lit()` escapes
  `\`/`%`/`_` and every query carries `ESCAPE '\'`. The remaining 2 HITs are the
  `xai-` prefix colliding with provider *prose* (5-char lowercase word, no
  key-shaped run) — new `--classify` mode answers this mechanically, with no
  content: `CLASSIFY part.data pattern=xai- rows=1 key_shaped=0 prose=1`.
  Baseline corrected: round 8 recorded "0 HIT, 270 cells × 25+5 patterns", but
  the revision it committed carries 888 cells × 32+5 patterns — the measurement
  predates the last edits ("uncommitted on fleet pause"), so the corpus was
  claiming a clean baseline for a gate that was not on disk. Round-9 baseline
  (script sha256 `2d60981b…3a23`, 282 lines): `TRANSCRIPT_SCAN: HITS=2
  (cells=888 patterns=32+5 warns=2 schema-absent=0)`, exit 1, all 5 credential
  tripwires empty, `--selftest` OK (seeded + wal-resident detection);
  `--classify` key_shaped=0 for both. Also corrected: the entry claimed the
  read path is `?immutable=1` while the shipped gate snapshots db+wal into
  `mktemp` (which is what closes the wal blind window). No purge/rotation
  action taken — no material found; the DB's at-rest request text is an
  operator decision (appended to `.ufo/l0-questions.md`). Landed:
  `knowledge/transcript-hygiene.md` corrections, `lessons/round-9.md` §11–14,
  README rows + gap bullet, `transcript-scan.sh` header/baseline/classify.
  Process note recorded: the L2 reviewer caught an in-flight (18:02–18:10)
  revision of `drift-pins.sh` that was broken mid-edit (bash parse error, exit
  2) — the committed 445-line revision is green; gate-before-cite ordering
  stands.

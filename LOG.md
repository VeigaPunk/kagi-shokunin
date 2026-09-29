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

- 2026-09-28 — round 10 (**coverage** 6 → 8; axis-move: surfaces + runtime
  state become falsifiable). Dispatched 9 L2 lanes in one batched call
  (planner, 2 scouts, 3 executors, critic, sentinel, connector, reviewer routes
  per MISSION). Landed `corpus/surface-census.sh` v1 + `corpus/surface-census.tsv`
  (35 rows: 20 asset / 15 runtime) + `corpus/state-shape.tsv` (22 rows) +
  `corpus/knowledge/surface-census.md` + `corpus/lessons/round-10.md`.
  Evidence: `bash corpus/surface-census.sh` → `SURFACE_CENSUS: CLEAN
  (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)` exit 0; `--verbs` →
  `CLEAN (pass=7 skip=3)` (no `op` exec, scratch overrides only); `--verbs
  --deep` → `CLEAN (pass=10 skip=0)`; `--selftest` → `SELFTEST: PASS (16 cases)`;
  siblings unchanged: `DRIFT_PINS: CLEAN (files=15 symbols=19)` +
  `DRIFT_SELFTEST: PASS (13 cases)`, `TRANSCRIPT_SCAN: HITS=2 warns=2 cells=888`
  (known `xai-` prose collision, no secret material). New verdicts: `UNLISTED`
  over 4 enumerable dirs (16/16 children declared → `UNLISTED=0`; detection path
  for the round-6 config-drop), `DIVERGED`/`GONE`/`LINK`/`CROSSCHECK` over the
  declared set, `SHAPE`/`UNVERIFIED`/`SKIP` over the runtime shape pins.
  Findings landed as corpus claims: (a) `cmd_refs` redaction is a **prefix
  match** — a ref-shaped value is echoed whole with any plaintext tail, and
  `export`/leading-space/lowercase keys are silently omitted (SKILL decision
  table + anti-pattern, `op-cli-surface.md`); (b) `run` over a ref while signed
  out is non-deterministic — exit 1 in ~4 s or silent block, exit 124 at a 25 s
  bound (observed both, this round, in `--deep`); (c) a refused `cdp-bridge
  ensure` still creates the NMH *directory* (`mkdir -p` precedes the `-x`
  guard); (d) the DB is read through a `mktemp` snapshot because a `?mode=ro`
  open still advances `-shm`.
  L2 value, recorded: the selftest caught two gate defects before landing (a
  dropped required table read as `SKIP` → false clean; a fixture that did not
  scan the dir the case mutated), and the scouts/sentinel caught a third in a
  **shipped data file** (a fused row swallowed the `daybreak-blue-access.json
  mode 600` assertion while the summary still said `CLEAN`) — fixed by splitting
  the row and adding a >5-field guard + selftest case 14. Critic CE3 (SKIP
  fail-open) and CE5 (digest print) were real and are fixed (`UNVERIFIED` fails
  the run; digest-free custody comparison); four of its clauses described a
  stale snapshot and are recorded as such. Reviewer: 49 VERIFIED / 9 STALE /
  0 WRONG / 4 UNCHECKABLE; 5 stale prose items corrected in-repo — the
  `handler-on-disk-state.md` DB bound now separates *content* staleness
  (`max(session.time_updated)` 2026-09-21T04:57:08Z, rows 7/39/55/238 unchanged)
  from *file-mtime* freshness (2026-09-28T19:59Z, a reader effect), "deliberately
  unpinned" reworded in `drift-gate.md` + `corpus/README.md`, and the
  `PROVINCE.md` census caption re-attributed to the new gate. Sentinel verdict:
  ship-with-changes; its `SKIP`-neutrality dissent is recorded in
  `knowledge/surface-census.md` rather than resolved. No vault read, no handler
  start, no Chrome launch, no real profile/state write (scratch roots only; the
  custody record's sha/mtime byte-identical after the `tac-register` re-run).
- 2026-09-28 — round 11 (**calibration** 7 → 8; axis-move: a claim becomes a
  command row, a revision becomes a hash, a citation becomes a resolver
  result). Dispatched 9 L2 lanes in one batched call against a **frozen
  revision** (`corpus/claim-ledger.sh` `d63c60b0…` 436 lines + 8 more artifacts;
  three lanes hash-verified it independently). Landed `corpus/claim-ledger.sh`
  (verify/stamp/citations/--selftest), `corpus/claim-ledger.tsv` (11 rows),
  `corpus/stamps.tsv` (28 in-repo artifacts), `corpus/knowledge/claim-ledger.md`
  (contract: 3 schemas, verdict table, 15 bounds, falsifiers),
  `corpus/lessons/round-11.md`. Evidence (shipped revision):
  `bash corpus/claim-ledger.sh verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=11
  stamped=28)` exit 0; `citations` ⇒ `CITATION_GATE: CLEAN (cites≈505 docs=39
  unresolved=0 ephemeral=0 labeled=13)` exit 0; `--selftest` ⇒ `SELFTEST: PASS
  (39 cases)`. Siblings unchanged: `DRIFT_PINS: CLEAN (files=15 symbols=19)` +
  `DRIFT_SELFTEST: PASS (13 cases)`; `SURFACE_CENSUS: CLEAN (assets=20
  runtime=15 scanned=4 ok=34 absent=2 skipped=0)` + `--verbs CLEAN (pass=7
  skip=3)` + `SELFTEST: PASS (16 cases)`, now fail-closed when zero probes pass
  (`SURFACE_CENSUS_VERBS: DEGRADED` + exit 1, critic CE1); `TRANSCRIPT_SCAN:
  HITS=2` exit 1 by design. **First contact found four real defects in committed
  docs** — two dead session-scoped scratch URIs (`SCORECARD.md:54`,
  `corpus/lessons/round-10.md:50`), kotoba's file cited under this repo's anchor
  (`corpus/README.md:61`), a bare host filename (`corpus/README.md:157`) — plus
  **three stale numbers** in my own docs (`state-shape.tsv` 20/21 → 22 rows;
  "14-case" census selftest → 16), all fixed and now pinned by ledger rows
  `R11-03`/`R11-10`/`R11-11`. **The wave then broke the gate six times and it
  was fixed each time**: unanchored verdict EREs passed a degraded summary
  (expectations anchored; the census verbs path fails closed); the `bytes`
  stamp column was dead data (now compared); the citation scan checked only the
  first token of a span (now every token on the line, normalized through
  backticks/quotes/parens/`:N`/`#anchor`/`?query`/`=value`/`'s` — 62 → 0
  unresolved); `IFS=$'\t' read` collapsed empty fields (tab-preserving
  `split_tab` + exact field counts); `tmo=0` disabled `timeout`; `..` traversal
  let the committed default root hash a private host file's digest (refused, plus
  canonical containment); `stamp corpus/stamps.tsv` bypassed the self-stamp
  guard with the default `--out` (guard runs before the write, either argument
  order). Refusals narrowed: allowlist 7 → 5 commands, `bash -c`/backslash/empty
  quote pairs refused, deny words matched on a quote-stripped copy
  (`g''it`/`o"p"` no longer slip through). `die` no longer echoes file content.
  Accepted as bounded (recorded in `knowledge/claim-ledger.md` §Bounds): the
  ledger is a reviewed command file, not a sandbox; a self-test cannot prove its
  own honesty; the marker rule is line-granular; a stamp is a point check with no
  mode; claims are host-state dependent as a class; a citation of a generated
  file is order-dependent. Process lesson recorded: I quoted
  `CLEAN (claims=9 stamped=16)` in docs before `stamps.tsv` existed — the scout
  re-ran and caught it, and the rule is now "quote a number with the stamped
  revision it was measured at; make the measurement the last byte-touching
  step". Adjacency (reported, not absorbed): four sibling lanes ship overlapping
  verifiers (kumitate `scripts/cite-check.mjs`, kotoba `verifiers/*.py`, kengaku
  `grader.py`, kasegi `ops/claim-check.mjs`); the fleet-wide dead-pointer class
  (protocol D-19) and a possible shared verifier contract go to the integrator.
  No vault access, no handler start/stop, no Chrome launch, no secret values,
  ref paths or private-file hashes in any artifact; `OP_*` values in probes were
  fabricated; all L2 execution was scratch-only.
- 2026-09-28 — round 12 (**depth 7 → 8**; axis-move: the `op.env` two-parser
  contract, the hard-failure class, and the true scope of `op run` masking).
  Dispatch: 12 L2 lanes in one batched call (planner, connector, 2 executors,
  2 scouts, reviewer, critic, sentinel, labrat, mutation-tester, distiller).
  Landed `corpus/op-ref-probe.sh` (verify/`--evaluate`/`--fixture`/`--selftest`,
  fixture-generated contract, single `op_exec` chokepoint with a per-path
  guard), `corpus/knowledge/op-ref-consumption.md` (divergence table, §2b
  hard failures, masking table with evidence grading, 13 bounds),
  `corpus/claim-ledger.tsv` rows `R12-01..03`, one `drift-symbols.tsv` pin
  (`the-janitor` L248 — the masking premise, 19 → 20), `SKILL.md` decision/
  failure/anti-pattern/checklist rows + a `## op.env consumption` section,
  `corpus/lessons/round-12.md`, and 16 stale live-doc rows corrected (scout
  lane) plus every number this round moved. Evidence (shipped revision):
  `bash corpus/op-ref-probe.sh` ⇒ `OP_REF_PROBE: CLEAN (checks=44 oprun=12
  refs=7 divergent=5 edge=10 sig=6)` exit 0; `--selftest` ⇒
  `OP_REF_SELFTEST: PASS (29 cases)`; `bash corpus/claim-ledger.sh verify` ⇒
  `CLAIM_LEDGER: CLEAN (claims=14 stamped=32)` exit 0; `citations` ⇒
  `CITATION_GATE: CLEAN (cites≈629 docs=42 unresolved=0 ephemeral=0 labeled=16)`
  exit 0; `--selftest` ⇒ `SELFTEST: PASS (43 cases)`; siblings unchanged
  (`DRIFT_PINS: CLEAN (files=15 symbols=20)`; `SURFACE_CENSUS: CLEAN
  (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`; `TRANSCRIPT_SCAN:
  HITS=2` exit 1 by design). **The finding**: `refs` (`cmd_refs` awk L234) and
  `run` (`cmd_run` ⇒ `exec op run --env-file` L248) are different parsers over
  one file — `op run` injects 12 keys where `refs` lists 7; `#` truncates an
  unquoted value silently; `$K`/`${K}`/`${K:-default}` expand (single quotes
  suppress it); quotes/CRLF/whitespace/duplicates/inherited values are rewritten;
  `--env-file` files **merge** (union, per-key last-wins, files beat the shell);
  and a malformed line (BOM, bare key, lone `=`, `-` in a key) aborts the whole
  parse with zero keys injected **while `refs` exits 0 with a healthy
  inventory** — an audit that trusts `refs` says fine while the load delivers
  nothing. Masking is narrower than its help text: only reference-resolved values
  are concealed; plain values pass through verbatim in every measured shape and
  `--no-masking` is a no-op for them (four shapes + stderr + full-`env`
  multiset, two independent lanes), so "the handler masks its output" is false
  for plain-valued keys. **Five defects found in flight, each reproduced**: the
  `stamp` guard was a *length* rule (equal-count path swap, missing-final-newline
  off-by-one and a blank-line substitution all slipped; now per-path membership,
  non-blank-line counting, blank row = setup error, 4 selftest cases); two CRIT
  guard bypasses in my own probe (sentinel F1/F2/F3: `--fixture` could supply a
  ref-bearing `absent.env`, a *file* named `adir`, a symlink or a FIFO — closed
  by the per-path `op_exec` chokepoint, re-verified by hand: four poison trees ⇒
  `POLICY` exit 2 with an **empty stub log**); a header claim that "every
  invocation goes through `op_run()`" was false (reviewer, WRONG) and is now
  true; a `trap`+`local` cleanup bug under `set -u`; and two stale numbers in my
  own first draft (3 → 5 divergences; masking rows graded as 2 mechanised + 3
  one-off). **Process finding (mine)**: the declared wave freeze was stale on
  arrival — I kept editing the probe (v1 → v4) while the lanes ran; four lanes
  recorded the movement independently, the reviewer's verbatim receipt is *"the
  freeze was stale on arrival"*, and the lesson is recorded in
  `corpus/lessons/round-12.md` §L2 wave rather than smoothed over.
  **Unexpected repo change (not mine, adapted)**: three commits landed in this
  repo mid-round (`e0a04d8`, `7c3377c`, `4391b3b` — the aggregator lane's box-3
  cold-run lesson); it cites `.ufo/reports/round-8/aggregator.md`, which resolves
  nowhere in the main repo's history (`git log --all` empty, and the round-8
  report directory has no `aggregator.md`). The three dead tokens are labelled
  where they are cited (the repo's own marker rule) and the pointer is reported
  for the aggregator/integrator to fix; the file is stamped because this round's
  report cites it. No vault access; no secret value, ref path or account value
  in any artifact; the only vault-API contact was one bounded
  nonexistent-vault probe (`op run` over a fabricated ref, exit 1 in ~2 s),
  labelled as a one-off in the entry.
- 2026-09-28 — round 13 (**calibration 8 → 9**; axis-move: a citation becomes a
  resolvable object and a score becomes a re-verified pointer). Dispatch: 12 L2
  lanes in two batched calls (the first payload was malformed and yielded two
  lanes; planner, connector, 2 scouts, 3 executors, reviewer, critic, sentinel,
  mutation-tester, labrat, scribe). Landed `corpus/claim-ledger.sh` (four modes:
  `verify`/`citations`/`cells`/`stamp`; 72-case selftest),
  `corpus/knowledge/claim-ledger.md` §Class 4 (claim ids) + §Class 5 (scorecard
  cells) + 6 new bounds, `corpus/lessons/round-13.md`, `SCORECARD.md` round-13
  pre/post tables + pointers on the 20 uncited cells + a corrected historical
  number, `corpus/claim-ledger.tsv` rows `R13-01..03` (and `R11-09`/`R12-03`
  re-pinned), plus `PROVINCE.md`/`corpus/README.md`/`SKILL.md` current-shape
  updates. Evidence (shipped revision): `bash corpus/claim-ledger.sh cells` ⇒
  `CELL_AUDIT: CLEAN (cells=60 row_pointed=25 stamp_pointed=41 uncited=0
  missing_ids=0 rows_run=14 row_failures=0 stale_pointers=0 self_skipped=3
  orphans=0)` exit 0 (pre-move, same command: `BROKEN (cells=48 row_pointed=3
  stamp_pointed=28 uncited=20)` exit 1 — reproduced independently by a scribe
  replica, a scout python census and an executor re-implementation);
  `verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=17 stamped=33 ids=17 cited=17
  labeled_ids=13 orphans=0)` exit 0; `citations` ⇒ `CITATION_GATE: CLEAN
  (cites=700 docs=43 unresolved=0 ephemeral=0 labeled=13)` exit 0; `--selftest`
  ⇒ `SELFTEST: PASS (72 cases)`. Siblings unchanged: `DRIFT_PINS: CLEAN
  (files=15 symbols=20)` + 13 cases; `SURFACE_CENSUS: CLEAN (assets=20
  runtime=15 scanned=4 ok=34 absent=2 skipped=0)` + `--verbs CLEAN (pass=7
  skip=3)` + 16 cases; `TRANSCRIPT_SCAN: HITS=2` exit 1 by design. **The
  finding**: the gate round 11 shipped had a hole at each end — it iterated rows
  forward only (a doc citing an id no row defines passed: `citations --docs <doc
  citing the fabricated R13-99>` ⇒ CLEAN, exit 0) and nothing read
  `SCORECARD.md` (20 of 48 cells pointed at nothing). Both directions now fail
  closed, and a pointer counts only if it still holds: cited rows are re-run
  through the claims machinery, cited pins are re-compared (`STALE-POINTER`), a
  section missing or misspelling an axis is exit 2, and an unrecognised `##
  Round` heading is exit 2 rather than six silently-dropped cells. **Defect found
  in my own first implementation**: the pointer test was an unanchored
  `grep -F "token<TAB>"`, and every score digit (`7`, `9`) matched inside a
  sha256/line field — `CELL_AUDIT: CLEAN … stamp_pointed=48` against a scorecard
  with 20 unpointed cells, i.e. a false clean of the round-11 CE1 class; caught
  by a token probe (`HIT [7]`, `HIT [9]`) against the scribe lane's independent
  replica (28), fixed by array-loaded exact first-field membership, pinned by
  selftest `cells-numeric-anchored`. **Recursion closed**: a claim row may run
  this gate, so `verify` now refuses a nested self-audit (exit 2) and `cells`
  skips rows that re-invoke the gate (`SKIP-SELF`, counted) — which is why the
  ledger cannot pin its own `verify` summary and `R13-03` pins the `cells`
  summary instead. **Id vocabulary**: whole-word matching (the illustrative `R12-03a` /
  the illustrative `xR12-01` are `MISSING-ID`, a comment-only id creates no row, a range
  validates its head only), and the citation scan's marker rule applies to ids
  too (`labeled_ids=13` — the fabricated ids that are this round's own
  before-evidence), because the audit's first run failed on its own docs.
  **Sentinel-driven fixes**: stamp rows are now read under the same containment
  rule they are written under (`..`/absolute refused on both sides) and round
  headings must match the expected shape. **The L2 wave**: the critic's executed
  counterexample (a cell citing a row irrelevant to its score) forced the two
  teeth and is recorded as the axis ceiling, not smoothed over; the mutation lane
  proved the prefix/suffix/comment escapes; the scribe found both the `in_set`
  variable clash that killed all five `cells-*` cases and the recursion;
  the reviewer caught a `lineno: unbound variable` crash in a mid-edit revision
  (never shipped). No vault access; no secret value, ref path or account value in
  any artifact; all L2 execution was scratch-only.
- 2026-09-28 — round 14 (**freshness 8 → 9**; axis-move: the knowledge surface
  gets a re-verification link, and round 13's scorecard plan is split into the
  half that was reachable and the half that stays refused). Dispatch: 14 L2 lanes
  in one batched call (planner, connector, 2 scouts, scribe, 2 executors,
  reviewer, critic, sentinel, labrat, mutation-tester, simplifier, distiller; the
  distiller's first pass found no artifacts, said so instead of inventing a
  synthesis, and was revived after the wave). **The finding**: at `4b8c018` the
  knowledge surface had no link to any re-verification — 17 `corpus/knowledge/*.md`
  entries, **1** naming any claim row, **0** declaring one, **7 of 17** in
  `corpus/stamps.tsv` (reproduced three ways: L1 census, a scout python census on
  the frozen blobs *and* the live tree, a drafter `grep -c '^Reverify:'` ⇒ 0).
  Landed: a sixth mode `corpus/claim-ledger.sh docs` (one `Reverify:` line per
  entry — resolving row ids, or `by-hand: <class> — <reason>` with a closed
  4-class set and a unique ≥24-char reason — plus a mandatory revision pin, a
  `row_linked*2 >= entries` floor, and `UNDECLARED`/`MISSING-ID`/`UNPINNED`/
  `DUPLICATE-REASON`/`RATIO` as exit-1 defects with shape errors exit 2);
  `Reverify:` declarations in all **17** entries (**14 row-linked / 3 by-hand**:
  `config-layering` `opencode-internal`, `control-plane-hardening` and
  `handler-trust-boundary` `control-plane-scratch`); all 17 entries stamped
  (pin set 33 → 44 rows); ledger row `R14-01` plus four re-pinned count rows
  (`R11-09` 72 → 94 cases, `R12-03` 33 → 44 stamps, `R13-01` 10 → 12 sections,
  `R13-02` 17 → 18 rows); and **five score-card cells** now cite the rows that
  re-run the commands their own Evidence already quoted (`R11-01`, `R11-03`,
  `R11-09`, `R11-04`, `R11-01`). Evidence (shipped revision):
  `bash corpus/claim-ledger.sh docs` ⇒ `DOC_AUDIT: CLEAN (entries=17
  row_linked=14 by_hand=3 undeclared=0 missing_ids=0 unpinned=0
  duplicate_reasons=0)` exit 0, with `DOC_AUDIT_RATIO: row_linked=14/17 floor=9
  by_hand=3 duplicate_reasons=0` (pre-move, same corpus: `BROKEN (undeclared=17
  unpinned=10)` exit 1); `--selftest` ⇒ `SELFTEST: PASS (94 cases)`;
  `verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=18 stamped=44 ids=18 …)`;
  `cells` ⇒ `CELL_AUDIT: CLEAN (cells=72 row_pointed=38 stamp_pointed=47
  uncited=0 …)` (`row_pointed` 25 → 38; the round-13 half-floor is met, not
  argued); `citations` ⇒ `CITATION_GATE: CLEAN (cites=734 docs=45 unresolved=0
  ephemeral=0 labeled=13)`. Siblings unchanged: `DRIFT_PINS: CLEAN (files=15
  symbols=20)` + 13 cases; `SURFACE_CENSUS: CLEAN (assets=20 runtime=15
  scanned=4 ok=34 absent=2 skipped=0)` + `--verbs CLEAN (pass=7 skip=3)` + 16
  cases; `TRANSCRIPT_SCAN: HITS=2` exit 1 by design; `OP_REF_PROBE: CLEAN
  (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)` + 29 cases (the ledger's
  own `verify`/`cells` runs execute this gate: it execs `op run` over
  **generated fabricated plain values** and refuses any op-side ref token before
  exec, so the round's no-op-execution rule held for every lane and the gate is
  unchanged since round 12). **An author claim was falsified by a lane**: I wrote
  that round 13's `row_pointed ≥ half` target was unreachable; the pre-state scout
  independent census (H/N/R = 11/19/5 + 2 borderline) showed that **5 cells already
  quoted a live command in their own Evidence**, so the ratio half was reachable
  exactly at the boundary (25 → 30 of 60) — the five pointers landed; the half
  that would re-derive *historical* numbers stays refused (critic: 0 writable
  rows). **Defects found in my own implementation, each by execution**: an
  unbound `nrows` on the `UNDECLARED` path that the old case passed anyway (fixed,
  and the case upgraded to `tcase_last` on the exact summary); a directory of only
  hidden entries reporting "no entries" (ordering fixed); a fabricated id counted
  in `row_linked` (now counts only resolving ids); a 24-space by-hand reason
  passing the floor (trimmed first); a `Reverify`-prefixed non-declaration reading
  as `UNDECLARED` (planner lane; now exit 2); and 17 identical by-hand reasons
  satisfying the rule (critic lane's executed fixture; now `DUPLICATE-REASON`).
  Three of my draft entry→row links were rejected with evidence and replaced
  (both `R11-10` uses — a pin-file row count is not a host fact — and
  `handler-on-disk-state`'s `R11-06`), and four additions adopted from the same
  review (`R11-08`, `R11-01`, `R11-02`, `R11-10`+`R11-11` on `surface-census`).
  Also recorded: two of my own `edit` calls deleted a section heading in three
  entries by anchoring on a heading; caught by a heading census and repaired.
  Adjacency (reported, not absorbed): the connector lane maps sibling
  documentation-coverage verifiers — kotoba `verify_skill_checklist.py` (checklist
  box → disposition) and `verify_corpus_independent.py` (README index), kumitate
  `proxy-check.mjs` (doc-coverage score inside a composite), kasegi
  `anchorcheck.py` (mirror `path:line`), kengaku `grader.py` (replayed report
  tables) — all *adjacent* (different unit; none binds an entry to a re-runnable
  claim row); the shared-contract question stays with the integrator. No vault
  access, no handler start/stop, no Chrome launch; no secret value, ref path or
  account value in any artifact; all L2 execution was scratch-only.
- 2026-09-28 — round 15 (**operability 8 → 9**; axis-move: the last large prose
  surface in this repo becomes executable — each of the 16 credential-hygiene
  checklist items is now a row in a data file, tied back to its item text by a
  gate-enforced bijection, and every mechanisable one prints a verdict from one
  command). Dispatch: 14 L2 lanes in one batched call (planner, connector,
  2 scouts, scribe, 2 executors, reviewer, critic, sentinel, labrat,
  mutation-tester, simplifier, distiller). **The finding**: at `2486643` the
  checklist had **16** `- [ ]` items and **zero** verdicts — `ls corpus/checklist*`
  ⇒ nothing, `grep -rl 'hygiene checklist' corpus/*.sh` ⇒ nothing; 5 items named
  a command and none produced an outcome. The prose it replaces was wrong twice
  over: `SCORECARD.md:16` said "a 15-item hygiene checklist" (the revision it was
  measured at, `ea77bf0`, held 13; no revision in the count history 10→12→13→14→16
  ever held 15), and the three rounds-9–11 operability cells said "12 checklist
  items are still operator judgement" — unmeasured, and wrong at every revision
  they appear in (the list held 14 items then and ≥3 already named a live gate).
  Two committed notes also filed the lock under the wrong file (`PROVINCE.md:12`,
  `corpus/surface-census.tsv:22`: `grep -nic lock client.py` ⇒ 0; `flock 9` lives
  in `the-janitor` L131/140/176 under `exec 9>"$LOCK_FILE"` L130/139/175). All
  four figures/notes are corrected in place this round. Landed:
  `corpus/checklist.tsv` (16 rows; 8 columns `id class lead check expect_exit
  expect_last reason note`) + `corpus/checklist-run.sh` (`verify` / `--ratio` /
  `--list` / `--only ID` / `--selftest`), with three teeth beyond "run 16
  commands": (a) the `lead` ERE must match exactly one item and each item exactly
  one row — `UNMATCHED-ITEM`/`DUPLICATE-ITEM`/`UNMATCHED-LEAD`/`DUPLICATE-LEAD`/
  `UNDECLARED`/`EXTRA` all exit 1, so adding a bullet to SKILL.md without a row
  fails closed; (b) `by-hand` rows must carry a closed class plus a unique
  ≥24-char reason, the floor is `ceil(items/2)`, and the ratio line splits
  `delegated` (rows calling an existing gate) from `direct` (new assertions);
  (c) a `check` naming a denied surface (`op.env`, `op run|read|inject`, handler
  start/stop/run, `claim-ledger.sh`) is refused before execution, and the
  reference-path sweep prints counts only, because printing the matched line
  would be the leak the item forbids. Docs: `SKILL.md` (executable header +
  decision-table row), `PROVINCE.md` (gate registered, lock note corrected),
  `corpus/README.md` (coverage map), new `corpus/knowledge/checklist-execution.md`
  (`Reverify: R15-01, R15-02, R15-03, R15-04, R15-05`; 8-column schema, verdict
  table, delegation map, premise-vs-duty rule, 12 bounds, 10 falsifiers),
  `corpus/lessons/round-15.md`, five ledger rows `R15-01..05`, and four
  historical score-card corrections. Evidence (shipped revision):
  `bash corpus/checklist-run.sh` ⇒ `CHECKLIST_RATIO: runnable=9/16 floor=8
  by_hand=7 delegated=3 direct=6` + `CHECKLIST_RUN: CLEAN (items=16 runnable=9
  by_hand=7 failed=0)` exit 0, ~2.3 s (pre-move: the file did not exist);
  `--ratio` ⇒ the same ratio line in 0.2 s with no row executed; `--list` ⇒
  `CHECKLIST_LIST: rows=16 runnable=9 by_hand=7`; `--selftest` ⇒
  `CHECKLIST_SELFTEST: PASS (34 cases)`; and it runs from a foreign cwd
  (`/`, `/tmp`, relative path) after `$SELF` replaced `"$0"`. Siblings unchanged
  by this round: `DRIFT_PINS: CLEAN (files=15 symbols=20)`; `SURFACE_CENSUS:
  CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`; transcript
  baseline `HITS=2` exit 1 by design (now pinned *inside* the checklist as row
  H7). **Nine defects were found by execution before commit — eight by lanes,
  one by the gate's own selftest — and each is a class this corpus has been
  bitten by before**: (1)+(2) two silent-death sites — `dup_reasons=$(… | sort |
  uniq -d)` died under `set -euo pipefail` because the loop's last iteration and
  `uniq -d` both return 1, and the last-line extractor died on a row that printed
  nothing — a `bash -x` trace ending at `+ dup_reasons=` was the only clue (scribe
  + executor lanes, independently); (3) H4 read the front matter with
  `(?:[ \t]+.*\n)+` against a body whose last line has no trailing newline ⇒
  `JANITOR_PERMS: DEFECT (entries=1)` **on a correct host file**; (4) E4's sweep
  found three undeclared reference-shaped literals on first contact
  (`op-env-refs.md:14`, `round-5-aggregator-audit.md:19`, `transcript-scan.sh:202`
  — all the documented `vault` placeholder form), which is now a *visible*
  allowlist (`hits/excluded/raw` printed and both counts pinned, `excluded=5
  raw=5`); (5) the first rewrite of that row wrapped its own `printf`/`test`
  inside `n=$(…)` and swallowed the verdict (scribe lane, verbatim re-run); (6) H8
  accepted a **wildcard** listener on 40961 — a scout lane branch-proved it on
  scratch ports and the row now asserts `non_loopback=0`; (7) H1 was satisfiable
  by comment text (critic lane, fake-`HOME` fixture) and is now line-anchored;
  (8) H7 declared `0|1` while the DB-absent state the item above it *prescribes*
  exits 2 — a legitimate `stop + rm -rf xdg-data` false-defected; (9) the selftest
  re-invoked itself as `"$0"` ⇒ exit 127 from a foreign cwd (labrat lane). The
  selftest grew 0 → 34 cases and every fixture is now rebuilt from scratch instead
  of mutated by `sed`. **The competing readings are recorded, not smoothed**: the
  planner lane applied a strict duty-vs-premise criterion and got `runnable=3
  by_hand=13` (below the floor) and flagged E5 because the delegated probe execs
  `op run` — declared on the row, and the stricter reading there is `8/8`, exactly
  the floor; the simplifier argued E1 should be deleted and proposed a minimal
  honest set of 6 runnable rows (kept as dissent: the row is count-pinned and
  produces the item's verdict); the critic produced the round's ceiling — a
  16-row TSV of constant `printf`s passes `CLEAN (runnable=16/16)`, i.e. the gate
  measures well-formedness and execution, not the semantic strength of an
  assertion, and the `note` column that makes the 9 honest is not gate-enforceable
  (recorded as bound 11 + the round-16 target: a `--mutate` mode with declared
  negative fixtures). Adjacency (reported, not absorbed): the connector lane
  mapped sibling verifiers — kotoba `verify_skill_checklist.py` (checklist box →
  disposition; its predicates inspect the file, they do not execute the item's
  command), kumitate's doc-coverage score, kasegi `anchorcheck.py` (prints
  findings but exits 0) — none implements an item → command → verdict contract,
  so this is adjacent; the shared shape (a stable-ID outcome ledger) is reported
  to the integrator. No vault access, no handler start/stop, no Chrome launch; no
  secret value, ref path or account value in any artifact; all L2 execution was
  scratch-only.

- 2026-09-28 — round 16 (**adjacency 8 → 9**; axis-move: the ownership partition
  becomes a gate). At the round-15 close three axes stood at 8 (depth, coverage,
  adjacency) and adjacency was the only one with **no** mechanical support: it
  lived in the `corpus/README.md` overlap table, two `PROVINCE.md` refusals and
  one `mode = -` census row, and one of those three was stale on the live host
  (`README.md:76` cited `kake-shokunin/SKILL.md:104-107` for the musketeer lease;
  that slice matches `musketeer` 0 times, the claim is at `:161`). Landed:
  `corpus/adjacency.tsv` (5 `# own` prefixes owning 27 of the 35 census rows, 4
  group rows covering the other 8 with `owner / status / claim / basis / token`,
  4 owner + 4 status + 2 claim + 8 no-enumerate directives), `corpus/scope-gate.sh`
  (`verify` / `--map` / `--selftest` / `--falsify`; R1–R11; verdicts `BAD-ROW`,
  `FOREIGN`, `ORPHAN`, `UNKNOWN-OWNER`, `BAD-VALUE`, `OWNER-MISMATCH`,
  `NOT-A-FILE`, `STALE-BASIS`, `BASIS-ESCAPE`, `OVERCLAIM`, `FOREIGN-SCAN`,
  `ESCAPE`, `INBOUND`, `UNVERIFIED`, `ENUM-CLASH`, `OWN-UNLISTED`; exit 0/1/2),
  new `corpus/knowledge/adjacency-scope.md` (`Reverify: R16-01..06`; 7-column
  schema, the rule table with a failing input each, verdict/exit table, 14 bounds,
  11 falsifiers), `corpus/lessons/round-16.md`, six ledger rows `R16-01..06`, the
  README overlap table + coverage map (machine-checked now, stale citation
  corrected), `PROVINCE.md` (gate registered, CDP row points at the partition),
  a SKILL.md decision-table row, and the two round-16 scorecard sections.
  Evidence (shipped revision): `bash corpus/scope-gate.sh` ⇒
  `ADJACENCY_ABSTAIN: rows=1` + `ADJACENCY_SCOPE: CLEAN (census=35 owned=27
  shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0
  foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0)` exit 0,
  ~0.5 s (pre-move: the file did not exist); `--selftest` ⇒
  `SCOPE_SELFTEST: PASS (43 cases)`; `--falsify` ⇒ `SCOPE_FALSIFY: PASS
  (caught=9/9 failed=0)` on scratch copies of the shipped data; `--map` ⇒ 35 rows
  (27 owned / 8 shared). Siblings unchanged: `DRIFT_PINS: CLEAN (files=15
  symbols=20)`; `SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34
  absent=2 skipped=0)`; `CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7
  failed=0)`. **The wave found seven real holes in my own implementation, each by
  execution**: (1) `--falsify` was defined and never wired (scribe, exit 2);
  (2) run 1 of `--falsify` — both data files end WITHOUT a trailing newline, so
  three appended mutations merged into the last row and silently no-opped;
  (3) run 2 — `mutate_case` counted successes but not failures, so the summary
  printed `PASS (caught=7/7)` above a `FALSIFY FAIL` line (the repo's own
  swallowed-verdict class, inside the verifier); (4) `# own $HOME/.local/bin`
  produced a byte-identical CLEAN summary while claiming 105 foreign children
  (reviewer D2, sentinel S2, mutation M13 independently) ⇒ R10's own-vs-no-enumerate
  clause + R11 (`# own` must name a declared, enumerated surface); (5) `basis` had
  no containment check, so `lane:kake/../../priv/secret.env:1` (or
  `../../.config/the-janitor/op.env` from the repo root) was `sed`-read and turned
  the verdict into a boolean oracle over private bytes (sentinel S1) ⇒
  `BASIS-ESCAPE`, with the root compared through `resolve_anchor` so a symlinked
  lane checkout cannot move with the file; (6) the closed vocabularies were
  self-declared by directives (mutation M19) ⇒ literal sets in the script;
  (7) an owner/basis lane mismatch passed (M20) ⇒ `OWNER-MISMATCH`. Also fixed
  from the wave: an 8th column or a fused line was absorbed into `note` (M03),
  absent `asset` rows were silently exit-neutral (planner) ⇒
  `ADJACENCY_ASSET_ABSENT`, a missing data file died with no terminal line (M12)
  ⇒ `ADJACENCY_SCOPE: SETUP`, and two selftest-fixture defects of my own (a
  function-local `R` in the EXIT trap; three fixtures whose sed patterns could
  not fire). **Corrigendum, measured**: round-15's lesson attributes a silent
  death partly to "`uniq -d` exits 1 on an empty result" — on this host `printf ''
  | sort | uniq -d` ⇒ exit 0; the real killers are the loop's final status and
  `grep -v … | tail -1` under `pipefail`. Corrected in `lessons/round-15.md` with
  a pointer. Adjacency (reported, not absorbed): no sibling lane implements a
  host-path ownership map with a fail-closed foreign-claim gate (connector);
  kake's `~/.local/bin/musketeer-chrome` launcher symlink sits inside the shared
  bin dir and the contested profile subtree carries a `SingletonSocket` symlink
  that leaves `$HOME` — both invisible to a census-row-scoped rule, reported to
  the integrator; the `$HOME/.config/opencode` ownership ruling is still owed
  (kotoba/kama/kengaku/kumitate all have artifacts there; fleet ledger D-96). No
  vault access, no handler start/stop, no `op.env` bytes read, no Chrome launch;
  all L2 execution was scratch-only in `/tmp/kagi-r16/`.

- 2026-09-29 — round 17 (**coverage 8 → 9**; axis-move: shared-directory
  breadth becomes a verdict). At the round-16 close depth and coverage were
  tied at 8. Coverage had the concrete vault-free counterexample: the census
  named 8 direct children across four deliberately non-enumerated shared leaf
  dirs, but 174 other direct children were invisible; adding or deleting one
  left every shipped gate green. Landed four count-only `# breadth` rows in
  `corpus/adjacency.tsv` and R12/R13 in `corpus/scope-gate.sh`: required pin
  membership is derived from leaf `# no-enumerate` rows (aggregate ancestors
  are forbidden), live direct-child cardinality is compared with the pin, and
  the declared count is independently derived from census membership. Default
  verify now emits `BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4
  children=182 declared=8 undeclared=174 missing=0 invalid=0 drift=0 exceeds=0
  unverified=0)` before the unchanged partition verdict; `--breadth` emits the
  four count-only ratios (`20/4`, `105/2`, `4/1`, `53/1`) without child names.
  Added `SCOPE BREADTH-MISSING`, `BREADTH-INVALID`,
  `BREADTH-CHILDREN-DRIFT`, `BREADTH-DECLARED-DRIFT`, `BREADTH-EXCEEDS`,
  `BREADTH-UNVERIFIED`, and `BREADTH-SCOPE`; `--selftest` grew 43 → 61 cases
  and `--falsify` 9 → 18 mutations. The mutation set also proves aggregate
  pins, out-of-scope pins, extra fields, whole-HOME widening and a newly
  declared child fail. Added ledger rows `R17-01..03`,
  `corpus/knowledge/adjacency-breadth.md`, and
  `corpus/lessons/round-17.md`; updated the scope entry, corpus index,
  decision table, province gate registry and this scorecard. Evidence:
  `bash corpus/scope-gate.sh` exit 0 with the 182/8/174 summary;
  `bash corpus/scope-gate.sh --breadth` exit 0 with four detail rows;
  `bash corpus/scope-gate.sh --selftest` ⇒ `SCOPE_SELFTEST: PASS (61 cases)`;
  `bash corpus/scope-gate.sh --falsify` ⇒
  `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`. Privacy bound: only counts
  persist; same-cardinality name swaps remain invisible, contents and
  recursion are not inspected, and no claim is made that the 174 foreign
  children are defects.

  L2 wave: one planner plus an 8-task batch (scout, critic, sentinel,
  mutation-tester, connector, executor, reviewer, scribe). Adopted the
  planner's derived-leaf completeness rule, sentinel's count-only privacy
  posture, critic's explicit count-vs-identity bound, reviewer's aggregate and
  whole-HOME counterexamples, mutation-tester's count-direction/schema cases,
  connector's correction that D-96 concerns sibling skill discovery roots—not
  `$HOME/.config/opencode` ownership—executor's parser/test skeleton, and
  scribe's evidence structure. Two implementation defects found while exercising the
  path were fixed before landing: old selftest fixtures lacked newly required
  pins, and the asset-absent fixture retained stale breadth counts. The host
  enumeration probe itself timed out twice when composed with a per-child
  text search; isolated `find -maxdepth 1 -printf` completed in ~0.01 s, so the
  shipped gate performs only counting and census-array comparisons.

  Fallback audit: effective config maps `m_swe` to `devin/swe-2:max`;
  `retry.fallbackChains.m_swe` is null, so the requested Daybreak hop is not
  visible. No genuine `m_swe` capacity failure occurred; no fallback
  advancement was observed. No config, mission contract, vault, handler,
  Chrome, secret bytes or host state changed. Round-16 recovery was committed
  separately as `8a6ec16` after correcting the nonexistent lowercase
  `~/projects/shokunin` default to a script-derived lane root.

  Landing audit caught two stale exact-count declarations introduced by the
  round itself: `R12-03` still expected 52 stamps after the two new artifacts,
  and `R14-01` still expected 19 knowledge entries / 16 row-linked. Corrected
  them to 54 and 20/17; `docs` then returned `DOC_AUDIT: CLEAN (entries=20
  row_linked=17 by_hand=3 undeclared=0 missing_ids=0 unpinned=0
  duplicate_reasons=0)` and the score-cell audit returned `CELL_AUDIT: CLEAN
  (cells=108 row_pointed=64 stamp_pointed=64 uncited=0 missing_ids=0
  rows_run=28 row_failures=0 stale_pointers=0 self_skipped=4 orphans=0)`.

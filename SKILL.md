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
| Run handler headless | export `OP_SERVICE_ACCOUNT_TOKEN` before `request`/`start` | assuming signin is the only path; putting the token in artifacts | skips `account get`/`signin`/`whoami` in `_serve` entirely (L194); token must reach `_serve`'s env |
| Select among registered accounts | export `OP_ACCOUNT=<acct>` before `request`/`start` | `--account` flags are not accepted by any verb | expands to `--account` on `account get`/`signin`/`whoami` (L196) |
| Check handler state | `the-janitor status` | reading `session-id` to infer auth | prints `state`, `health`, `authorization process_memory_only` |
| Check 1Password authorization | `request` → handler calls `janitor_auth` → `AUTH_OK`/`AUTH_REQUIRED` | `op whoami` against handler auth | caller-side check is `the-janitor whoami` — exit 1 (`account is not signed in`) predicts `request` will die in readiness |
| One-shot command with vault env | `the-janitor run -- <cmd>` | assuming handler auth; it uses caller's `op` | needs `~/.config/the-janitor/op.env` present |
| Inventory env keys | `the-janitor refs` | `cat op.env` (skips redaction); pasting output into artifacts; **trusting it as a redactor** | `KEY=op://…` verbatim / `KEY=<redacted-non-op-value>` — but the guard is a *prefix match*: any value whose first 5 bytes are `op://` is echoed whole, plaintext tail included (round-10 probe `refs-redaction-prefix-only`), and `export K=v`, ` K=v`, `lower_case=v` lines are silently **omitted** from the inventory; a **quoted** `"op://…"` value is reported as non-ref although `op run` resolves it; duplicate keys are listed once per *line* (round 12, `corpus/knowledge/op-ref-consumption.md`) |
| One-shot command with vault env (auth state unknown) | `timeout 30 the-janitor run -- <cmd>` | running it bare while signed out — an `op://` ref makes it block silently (round-10: exit 1 after 4 s *or* exit 124 with both streams empty at a 25 s bound) | plain-value env files pass through with exit 0 and no vault access; any ref makes the exit depend on live auth |
| Know what an env file **actually loads** | `bash corpus/op-ref-probe.sh` (contract verdict) and, for a specific file, `op run --env-file=<file> -- printenv <KEY>` per key | trusting `refs` as the loader's view — it misses `export K=v` / `K = v` / lowercase keys, lists duplicate keys once per line, and reports a **quoted** `"op://…"` as a non-ref while `op run` resolves it | `op` 2.35.0 fixture: `op run` injects 12 keys, `refs` lists 7, `divergent=5`; expansion, `#`-truncation, quote-stripping, dedup and whole-file parse aborts (BOM, bare key, `-` in a key) are all invisible to `refs` (`corpus/knowledge/op-ref-consumption.md`) |
| Know whether `run` output is masked | assume **not masked** for any plain-valued key; only `op://`-resolved values are concealed by default (`--no-masking` turns that off, and does nothing to plain values) | passing `--no-masking` to "see clear text" of a *ref*; writing a plain secret into `op.env` and then pasting `the-janitor run` output | measured 2026-09-28: `printenv`, subshell `echo`, substring and shell-env shapes all print the plain value verbatim; `cmd_run` (L248) passes no masking flag, so this is the default path |
| Verify an env file's shape before trusting it | `bash corpus/op-ref-probe.sh --fixture <dir>` (refused if any op-side file carries a ref token — POLICY exit 2) | pointing the probe at `$CONFIG_DIR/op.env` — it holds real refs and the guard will (correctly) refuse | exit 0 `OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)`; 1 `DRIFT` + `FAIL` lines; 2 `SETUP`/`POLICY` |
| Verify the declared surfaces / catch an undeclared config drop | `bash corpus/surface-census.sh` (compares the host against `corpus/surface-census.tsv` + `corpus/state-shape.tsv`) | editing a TSV to go green; declaring another lane's paths; assuming prose in `PROVINCE.md` verifies anything | exit 0 `SURFACE_CENSUS: CLEAN (assets=… runtime=… scanned=… ok=… absent=… skipped=…)`; 1 `DRIFT (…)` preceded by `DIVERGED`/`GONE`/`LINK`/`UNLISTED`/`CROSSCHECK` and `SHAPE`/`UNVERIFIED` lines naming path + assertion; `UNLISTED` = an undeclared child of one of the 4 enumerable dirs (the round-6 config-drop vector); `ABSENT` and `SKIP`(locked DB) are informational; `UNVERIFIED` (shape class unreadable) is **not** — it fails the run; 2 usage/setup |
| Own vs read a shared surface / measure breadth without listing private names | `bash corpus/scope-gate.sh` partitions the 35 census rows; `--map` prints assignments; `--breadth` prints count-only measurements for the four derived leaf boundaries | widening `# own`; scanning a shared dir; pinning aggregate ancestors; emitting child names; treating `unresolved` as an owner; ignoring count drift because the known rows still exist | exit 0: `BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174 …)` then `ADJACENCY_SCOPE: CLEAN (…)`; exit 1: named partition defect or `SCOPE BREADTH-{MISSING,INVALID,CHILDREN-DRIFT,DECLARED-DRIFT,EXCEEDS,UNVERIFIED,SCOPE}`; exit 2: setup/usage. `--selftest` proves 61 cases; `--falsify` catches 18/18 shipped mutations. Pins are required only on leaf `# no-enumerate` dirs; aggregate ancestors are forbidden. Counts expose churn, not identities: a same-cardinality name swap remains invisible. |
| Exercise the handler's write-side verbs safely | `bash corpus/surface-census.sh --verbs` (scratch overrides; execs no `op`); add `--deep` only with the operator present | running `--deep` unattended — it can raise the 1Password desktop prompt and reads the real custody record | default: `PASS|SKIP` per probe, `SURFACE_CENSUS_VERBS: CLEAN (pass=N skip=M)`; `--deep` = 10 probes / 0 skips; `--selftest` proves 16 cases |
| Start / stop handler | `the-janitor start` / `stop` | `kill` on the tmux pane | `stop` discards in-memory authorization; next `start` requires re-approval |
| Verify TAC receipt | `the-janitor tac-check` | treating it as live access or authorization | offline SHA-256 + field check; exit 0 = bytes intact only |
| First custody registration | `the-janitor tac-register` | running twice expecting refresh — O_EXCL, never replaces | writes `~/.local/state/the-janitor/tac-daybreak-blue.json` 0600 |
| 1Password in musketeer Chrome | `cdp-bridge ensure` then `status` | `open-popup` (hard refusal, exit 2); scraping vault DOM | manifest at `$MUSKETEER_CHROME_PROFILE/NativeMessagingHosts/` |
| Run the credential-hygiene checklist | `bash corpus/checklist-run.sh` (one row per item in `corpus/checklist.tsv`; `--list` maps them, `--only ID` runs one) | reading the checklist as prose and calling the machine-checkable half "done"; trusting a by-hand row as verified — it is a declared gap | exit 0 `CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7 failed=0)` + `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7`; 1 `ITEM-FAIL`/`ITEM-LASTLINE` (named id + exit/last line) or `UNDECLARED`/`EXTRA`/`UNMATCHED-ITEM`/`DUPLICATE-ITEM`/`UNMATCHED-LEAD`/`DUPLICATE-LEAD`/`DUPLICATE-REASON`/`RATIO`; 2 `POLICY`/`SETUP`. A `lead` ERE binds each row to the item it declares, so an item with no row fails as `UNMATCHED-ITEM` |
| Diagnose a wedged handler | `grep`/`tail` `$STATE_DIR/xdg-data/opencode/log/opencode.log` + `tmux capture-pane -t janitor -p` | expecting stderr in `status` output | ERROR-level log is the durable diagnostic: `stream error Cannot connect to API` = dead model endpoint (round-3 drift shape; ≈58 s retry window, exponential backoff 2→5→9→19→30 s); `failed to load plugin` recurs every start, non-fatal. Or run `the-janitor _serve` in a foreground terminal for live stderr (hidden verb, not in `help`) |
| Verify model endpoint is real | `curl -fsS <endpoint-minus-/v1>/health` → `{"status":"ok"}` | trusting `status`'s `endpoint` line — it prints config, never probes | port 8080 was a Jitsi videobridge on 2026-09-28 while llama-server served the model on 34113 |
| Audit transcript for leaked secrets | `corpus/transcript-scan.sh` (immutable, counts-only) | printing matched text; `sqlite3` without `file:…?immutable=1` (mutates `-wal`/`-shm` in the live dir) | exit 0 `TRANSCRIPT_SCAN: CLEAN` (WARN cells = credential-language text — expected, not a finding); exit 1 = secret-shaped material or populated credential table; `--selftest` checks the gate itself |
| Trust a cited line ref / catch host-file drift | `bash corpus/drift-pins.sh` (compares the live host against the committed `corpus/drift-baseline.tsv` + `corpus/drift-symbols.tsv`) | the round-6 fingerprint printer (no stored baseline ⇒ it cannot detect drift); editing a TSV to go green; re-pinning to silence red | exit 0 `DRIFT_PINS: CLEAN (files=N symbols=M)`; 1 `DRIFT_PINS: DRIFT (…)` preceded by `DRIFT`/`MISSING`/`LINK`/`UNPINNED`/`EXTRA`/`DUP`/`POLICY`/`EMPTY` and symbol `MOVED`/`GONE`/`AMBIG`/`COUNT`/`SHAPE` lines naming file + line; 2 usage/setup, nothing written; `--pin` only after inspection |
| Re-run a claim this corpus makes / name the revision you read / cite an artifact / audit a score | `bash corpus/claim-ledger.sh verify` (91 stamps + 65 claims + claim ids; both counts bound to the ledger by `corpus/self-counts.tsv`) before citing; `… cells`; `… stamp PATH…` only after reviewed edits; `… citations` before adding a path reference | citing unstamped files; changing an expectation to force green; treating `STALE` as proof of defect; citing an undefined id; recursively auditing the audit; reading a lone clone's `INCOMPLETE` as a pass or as a defect | exit 0 `CLAIM_LEDGER: CLEAN (…)`; 1 `STALE`/`MISSING`/`MISSING-ID`/`FAIL`, or `LAYOUT-INCOMPLETE R11-08` + `CLAIM_LEDGER: INCOMPLETE (…)` when no fleet root sits beside the lane (`citations` alone: `FLEET-ABSENT` lines, `CITATION_GATE: INCOMPLETE`, exit 3); 2 `POLICY`/`SETUP`. |
| Check a number the corpus states about itself | `python3 corpus/self-counts.py` (each row of `corpus/self-counts.tsv` locates ONE current-tense number in SKILL.md / PROVINCE.md / `corpus/README.md` / a reviewed `corpus/knowledge/*.md` line and binds it to `rows:<file>`, a non-host ledger row's live output `ledger:<ID>`, or a host row's committed pin `expect:<ID>`, which is never executed); `--selftest` 48 cases | hand-editing a number "to match"; binding to a second definition of the quantity; dropping a binding to go green; treating an explicitly round-dated history line as current; binding a positional case index or a dated measurement section | exit 0 `SELF_COUNTS: CLEAN (claims=N stale=0)`; 1 `STALE id doc:line claimed=X live=Y` / `UNLOCATED` / `AMBIGUOUS`; 2 `POLICY` (host row under `ledger:`, recursion, unknown id) / `SETUP`. A knowledge correction keeps the old value in a history clause beside the new one |
| Judge whether a source's `on-release` recheck fired | `python3 corpus/release-clock.py` replays the **pinned round-26 rearmed receipt**, not live vendor truth; `corpus/release-clocks.tsv` retains fired old anchors and binds the Python successors at their named3.15.1 anchors. `--observe OUT.json` fetches clocks to a NEW receipt and compares against the selected profile, so later drift can return `RECEIPT-MISMATCH` / exit 1 without capture failure. Since round 28 a non-canonical version token (leading zero, component over 18 digits) is `NON-CANONICAL` and a `derived:` anchor not equal to the one version its feed row's anchor cell names is `DERIVATION` (both exit 1); `--selftest` 106 cases | first-entry or any-version feed parsing; a derived anchor without `derived:`; silently re-pinning fired clocks; demoting on-release successors to90d; reading a dated offline CLEAN as live truth; reading an OLDER newest-stable release as a fired clock; reading `3.15.01` as a release of `3.15.1`; trusting a `derived:` anchor its feed row does not name | exit 0 `RELEASE_CLOCK: CLEAN (…)` means selected receipt/profile agree, not that no clock fired; 1 `UNBOUND`/`ORPHAN`/`BADFEED`/`INCONSISTENT`/`RECEIPT-MISMATCH`/`REGRESSED` + `FAILED`; 2 `SETUP`. `REGRESSED` (round 27, SemVer §11.2 numeric precedence, S042) = strict X.Y.Z observation below its own numeric anchor, below any numeric anchor on the same feed, or (when observing) below the row's previous observation: a stale, cropped or withdrawn stream to re-verify, never a newer-stable clock event. Limits: an observation equal to the feed's highest anchor is indistinguishable on replay; non-numeric/two-component/prerelease anchors are not ordered. Re-verify fired teachings and re-arm named successors through an explicit logged migration; historical round25 replay remains separate |
| Learn from, cite or curate an external source | a row in `corpus/SOURCES.md` (opened this round, tier scoped to its claim, anchor + revision) then `bash corpus/sources-census.sh` (gate: exit 0 CLEAN / 1 FAILED / 2 SETUP; `--selftest` 70 cases; read-only, no network) | citing an unopened lead; a product page or tier-C row as sole support; re-pointing an id | `SOURCES_CENSUS: CLEAN (rows=… mined=… rejected=…)`; the bar is `corpus/QUALITY.md`; the census checks the citation chain, never page content (`recheck:` is that clock); entries without a `source:` line are outside it |
| Judge a "short-lived" / "rotated" / "revoked" claim about a machine credential | name the clock first: `op run` env lifetime vs Service Account token; OpenBao token TTL vs dynamic-secret lease (Vault: leases only) vs static KV (no lease); SOPS recipients vs data key vs values (`knowledge/onepassword-machine-credentials.md`, `knowledge/vault-openbao-token-lease-lifecycle.md` incl. its erratum, `knowledge/sops-age-key-rotation.md`) | accepting "uses OIDC"/"short-lived" without the object; treating `updatekeys` as rotation; assuming Vault/OpenBao parity; widening one product's or one path's page to another | a claim names its object, product, path and version (QUALITY QA2, QA8, QA9) |

## Control-plane trust boundary (`corpus/knowledge/handler-trust-boundary.md`)

`opencode serve` on `127.0.0.1:40961` is an **unauthenticated HTTP API** —
`_serve` never sets `OPENCODE_SERVER_PASSWORD` and the server prints
`server is unsecured` on **stdout** at startup (verified on scratch instances
2026-09-28: `POST /session` 200 with no creds and auth headers ignored;
password set ⇒ 401 on *every* endpoint incl. `/global/health`,
`www-authenticate: Basic realm="Secure Area"`, Basic-only — Bearer rejected;
Basic `opencode:<pw>` ⇒ 200, `OPENCODE_SERVER_USERNAME` overrides the
default user).

Consequences:
- Any local process can `POST /session/{id}/shell` `{"agent","command"}` —
  direct execution, **no model call** (verified: 51 ms, `id -un` = vgpnk) —
  or `POST /session/{id}/message`, where the body's `agent` field picks any
  of the 26 loaded agents (round-7 scratch `GET /agent`; 23 resolve offline via
  `opencode debug config` — different measurement surfaces) and a `"tools":{"bash":true}` map re-enables denied
  tools even under `agent:"janitor"` (verified). These don't bypass a
  boundary — the `{"*": deny}` ceiling was **never socket-scoped**: it is
  agent frontmatter applying per-request, while the socket accepts any agent
  name (enumerable unauthenticated via `GET /agent` + `GET /config`, which
  also disclose the merged permission JSON). No project-trust prompt, no
  Origin/Host check, no per-UID check — any uid in the host netns can POST.
  Secret reads additionally need the daemon's live `op` auth window (locked
  app ⇒ `op` fails fast; a clean shell has no ambient session — `op` relies
  solely on the serve-time env).
  Tools run in the daemon env (proven: bash-tool subprocess saw the `_serve`
  exports), which at serve time carries `OP_SESSION_<domain>` /
  `OP_SERVICE_ACCOUNT_TOKEN` — a vault-capable `op` subprocess. The daemon
  also inherits the tmux-server env: `SSH_AUTH_SOCK` (live agent, 3 keys),
  `XDG_RUNTIME_DIR` (GPG agent sockets), `DISPLAY`/DBus — and uid vgpnk is in
  the `docker` group (root-equivalent path). Blast radius = caller's whole
  user session, not just vault auth.
- `client.lock` only serializes the CLI verbs; the HTTP port is uncovered.
- Enabling the password needs a companion `client.py` `Authorization: Basic`
  header (and `server_healthy` passes it) or `ensure_started` misreports the
  foreign-server text. Rollout recipe: `corpus/knowledge/control-plane-hardening.md`.
- `127.0.0.1` binding is the *only* boundary: local = unauthenticated. A
  pre-start squatter is also a phishing surface — `client.py` sends no auth
  and no pinning, so a mock control plane answering `JANITOR_ACTION_REQUIRED`
  can harvest operator approvals (failure-table foreign-server row detects
  one squat shape only).

## On-disk state & wedge recovery (`corpus/knowledge/handler-on-disk-state.md`)

`_serve` points XDG_DATA/CACHE/STATE at `$STATE_DIR/xdg-*`. What persists:

| Path | What | Survives `stop`? |
|---|---|---|
| `xdg-data/opencode/opencode.db` (0600) | full transcripts — `part.data` plaintext `$.text` + `tool` parts (observed 7 sessions/39 msgs/55 parts) | **yes** — `stop` only rm's `session-id` |
| `xdg-data/opencode/log/opencode.log` (0600) | ERROR lines: plugin-load failures, `stream error` model retries | yes |
| `xdg-state/opencode/locks/`, `xdg-cache/opencode/models.json` | locks, model metadata | yes |

`authorization process_memory_only` in `status` describes the 1Password auth
only — **request text is durable at rest**. No purge verb exists; transcript
reset = `the-janitor stop` + `rm -rf $STATE_DIR/xdg-data`.

Lock topology: `request`/`start`/`stop` take `client.lock` flock;
`status`/`run`/`refs`/`whoami`/`cdp-bridge`/`tac-*` stay lock-free.
`request` holds it through the whole model round-trip
(`THE_JANITOR_REQUEST_TIMEOUT`, default 3600 s) — a hung request wedges
`stop`; recovery is `tmux kill-session -t janitor` (client.py dies, fd 9
releases), then `stop` cleans up. `ensure_started` wedge states: foreign
healthy server + no tmux → exit 1 foreign-server text; tmux alive + health
false through 120 probes (each up to 2 s + 0.5 s sleep → 60–300 s) →
misleading `waiting for 1Password authorization` text.

Transcript hygiene gate: `corpus/transcript-scan.sh` scans all text-bearing
columns in 11 tables (`part`/`message`/`event`.data, `session.title`/`slug`/`path`/`share_url`/`summary_diffs`/`metadata`/`permission`,
`session_input.prompt`, `session_message.data`, `session_context_epoch.baseline`/`.snapshot`,
`todo.content`, `project.name`/`worktree`/`commands`/`sandboxes`, `workspace.name`/`directory`/`extra`,
`permission.action`/`resource`) plus row-count tripwires on credential-bearing tables
(`account`, `account_state`, `control_account`, `credential`, `session_share` —
schema has NOT NULL `access_token`/`refresh_token`/`value`/`secret` columns; all
empty at baseline). Baseline 2026-09-28: 0 HIT / 4 WARN (request text *naming*
credential concepts, e.g. "retrieve the … API keys" — signal that stdin carries
credential intent, not leaked material). Detail + tiers:
`corpus/knowledge/transcript-hygiene.md`.

## Surface census — declared surfaces + runtime shape (`corpus/surface-census.tsv`, `corpus/state-shape.tsv`)

`PROVINCE.md` §Surfaces is prose; the census is its falsifiable form. Run it
before asserting that any path in this domain still exists in the shape the
corpus claims:

    bash corpus/surface-census.sh                  # surfaces + runtime shapes
    bash corpus/surface-census.sh --verbs          # write-side verbs, scratch only, no op exec
    bash corpus/surface-census.sh --verbs --deep   # + op run (plain/ref) + tac-register no-replace; operator present
    bash corpus/surface-census.sh --selftest       # scratch-tree proof that both fire (16 cases)

- **Declared vs undeclared.** 35 rows (`asset` = must exist; `runtime` = may be
  ABSENT). Four dirs are enumerated one level deep — `$HOME/.config/the-janitor`,
  `$STATE`, `$STATE/xdg-data/opencode`, `~/.local/state/tac` — and any child not
  in the file is `UNLISTED` + exit 1. That is the detection path for the round-6
  vector: a dropped `$CONFIG_DIR` file is loaded by the handler because
  discovery is not disabled.
- **Runtime state is pinned by shape, never content.** `opencode.db`: magic
  header byte-exact (16 bytes incl. NUL), mode, table floor 12/observed 20,
  required tables, row floors at one third of observed (`session:2`,
  `message:13`, `part:18`, `event:79`); `opencode.log`: mode + size floor;
  custody/handoff JSON: mode + top-level key **names**. Floors fire on a reset
  (`stop` + `rm -rf xdg-data`) or >3× truncation, not on growth — and a reset
  legitimately invalidates the row census recorded in
  `handler-on-disk-state.md`.
- **Read path.** The DB is opened through a `mktemp` copy of `db`+`-wal`+`-shm`,
  never in place: a read-only open of the live file still touches `-shm`
  (round-10 measurement: its mtime advanced during a `?mode=ro` read; the
  `transcript-scan.sh` sections use `?immutable=1` for the same reason).
- **One fact, one owner.** Where the census and `drift-baseline.tsv` both declare
  a mode, they must agree (`CROSSCHECK`); hashes stay in the baseline, and the
  6 private 0600 files keep `-` there. No `--pin` here: editing a declaration is
  a scope decision, so it is a reviewed commit.
- **Verb probes.** Default set (7 probes) runs `cdp-bridge ensure` against a
  scratch `MUSKETEER_CHROME_PROFILE`, `refs` against a fabricated env file, the
  `run`/`refs` argument guards, and `status` — exit-2/exit-0 assertion pairs
  with no `op` exec and no write outside scratch. `--deep` adds `op run`
  (plain pass-through; ref → exit 1 *or* blocked at the bound) and the
  `tac-register` no-replace re-run (sha/mtime compared; refuses to create a
  record). Findings: `refs` redaction is a prefix match (a value starting
  `op://` is echoed whole, and 3 odd key shapes are silently omitted); a refused
  `cdp-bridge ensure` still creates the NMH *directory* (`mkdir -p` precedes the
  guard), so assert the manifest file, not the tree.
- Detail, verdict table, bounds and 11 falsifiers:
  `corpus/knowledge/surface-census.md`.

## Freshness gate — drift pins (`corpus/drift-baseline.tsv`, `corpus/drift-symbols.tsv`)

Every line ref and content claim below points at a host file that drifts
outside lane control. Run the gate before trusting any of them:

    bash corpus/drift-pins.sh             # verify vs the committed baselines
    bash corpus/drift-pins.sh --selftest  # scratch-tree proof that the gate fires (13 cases)

- **Baselines are committed, not printed.** `corpus/drift-baseline.tsv` holds
  one row per cited host file — `$HOME-relative path<TAB>mode<TAB>lines<TAB>sha256`
  (15 files as of round 9) — and `corpus/drift-symbols.tsv` holds the content
  claims themselves: `path<TAB>line<TAB>ERE[<TAB>shape]`, 20 rows. The two
  endpoint rows are **value** pins (`the-janitor:19`
  `^MODEL_ENDPOINT="http://127\.0\.0\.1:8080/v1"$`, `opencode.json:16` the same
  literal) because the actionable claim is that both declarations still pin the
  dead 8080 endpoint — remediation must red-line the gate. The rest are
  key-presence (`the-janitor:194` `OP_SERVICE_ACCOUNT_TOKEN`,
  `agents/janitor.md:6` `^steps: 4`, `janitor_auth.ts:12` …) or count pins
  (`op.env` `#10` + `shape`; two `handoff-status.json` field names as `#1`).
  A fingerprint *printer* with no stored
  baseline is not a pin (`PROTOCOL.md` §Evidence standard) — the round-8
  audit found v1's pins verifiable for only 2 of 13 files, because only 2 had
  expected values in the repo.
- **Verdicts.** Files: `OK | DRIFT | MISSING | LINK`, plus `UNPINNED` /
  `EXTRA` / `DUP` (membership closed both ways, duplicates rejected) and
  `POLICY` (a baseline row asking for a hash of a no-hash path — refused before
  the file is read) and `EMPTY` (a pin file with no rows). Symbols:
  `OK | MOVED <pin>-><actual> | GONE | AMBIG <n> | COUNT | SHAPE`. `DRIFT`
  prints which field moved (`mode`/`lines`/`sha`); the symbol row is what catches
  the round-4→8 stale-ref class (`MODEL_ENDPOINT` L17→L19) — a sha diff alone
  does not tell you the citation broke.
- **Exit** 0 `DRIFT_PINS: CLEAN (files=N symbols=M)` · 1 `DRIFT_PINS: DRIFT
  (files_ok=… files_bad=… symbols_ok=… symbols_bad=…)` · 2 usage/setup with
  **nothing written** (`baseline not readable: … (run --pin once)`; a missing
  option argument also exits 2).
- **`--pin` records, it does not repair.** It rewrites the file rows (each
  change prints `REPIN <path> (<old> -> <mode>/<lines>/<sha12>)`) and moves a
  symbol's recorded line only while its ERE still matches exactly once
  (printing `MOVED <path>:<pin>-><actual>`). A **count change is refused** —
  `count pin changed (…:#10->#11), refusing to pin` — because that is a claim
  change (a key appeared/disappeared), not a location move; hand-edit the count
  after checking. `GONE`, ambiguous, missing/linked/hardlinked, unreadable or
  empty symbol sources and baseline rows outside `FILES` all abort with exit 2
  and write nothing. Re-pin only after inspecting what changed — never to
  silence a red run.
- **Hash policy (6 of 15 files).** `op.env` (values + refs), plus
  `config.json`, `~/.agents/AGENTS.md`, `handoff-status.json` and the two TAC
  receipt/custody files are pinned by **mode + line count only** — sha column
  `-` — because a committed sha256 of a low-entropy private file is an offline
  confirmation oracle. `op.env` adds a count pin (`#10` on
  `^[A-Z][A-Z0-9_]*=`) and a `shape` assertion; the handoff field names are
  pinned by count, not by line. Cost: for those files content drift is invisible.
  Detail + the L2 sentinel review: `corpus/knowledge/drift-gate.md` §Hash policy.
- **Scope.** Deliberate exclusions: `$STATE_DIR/xdg-data/…/opencode.log` and
  `opencode.db` mutate legitimately (the DB has its own gate,
  `corpus/transcript-scan.sh`); package-managed host binaries (`/usr/bin/op`,
  `~/.opencode/bin/opencode`) are not lane-owned bytes; vault-side structure
  stays unmapped.

## Claim ledger — revisions, claims, citations (`corpus/claim-ledger.tsv`, `corpus/stamps.tsv`)

Every claim this corpus makes should be re-runnable, and every artifact it
cites should be the revision a reader can name. Run the ledger before you cite:

    bash corpus/claim-ledger.sh verify     # stamps + claims + claim ids; exit 0 CLEAN, 1 FAIL/STALE/MISSING-ID, 2 POLICY/setup
    bash corpus/claim-ledger.sh citations  # committed docs must cite durable evidence
    bash corpus/claim-ledger.sh cells      # every scorecard cell must carry a pointer that still holds
    bash corpus/claim-ledger.sh docs       # every knowledge entry declares its re-verification and is revision-pinned
    bash corpus/claim-ledger.sh --selftest # 170 scratch cases (stamps, claims, policy, citations, claim ids, cell audit, entry declarations, the `stamp` row-set guard, substrate deferral, lone/fleet layout, release-clock network refusal) — 94 until round 18, 151 until round 25
    bash corpus/claim-ledger.sh stamp corpus/claim-ledger.sh …   # re-pin after landing edits (reviewed commit)

- **Claim rows** (`corpus/claim-ledger.tsv`): `id<TAB>command<TAB>expect<TAB>
  exit<TAB>timeout<TAB>note`. A row passes only when the exit code equals the
  expected one **and** the `expect` ERE matches the **last non-empty output
  line** — a verdict is a summary line, so a command that prints `CLEAN` early
  and dies later cannot pass (`reason=verdict-not-final`). Row failures print
  id + reason + exit; the gate never echoes a claim's output. 18 rows as of
  round 14 (three sibling gates across 9 modes, the round-12 `op.env` rows, the
  transcript baseline whose expected exit is **1**, this gate's own `cells` and
  `docs` verdicts, and five count rows that exist because docs carried stale
  numbers for them).
- **Knowledge entries** (`docs`): every `corpus/knowledge/*.md` entry must carry
  exactly one declaration — `Reverify: R11-04, R11-05` (ids that must resolve)
  or `Reverify: by-hand: <class> — <reason>` with a closed class set
  (`control-plane-scratch|opencode-internal|interactive-only|vault-refusal`) and
  a unique ≥24-char reason — and must be a row in `corpus/stamps.tsv`.
  `UNDECLARED`/`MISSING-ID`/`UNPINNED`/`DUPLICATE-REASON` and a corpus where
  `row_linked*2 < entries` (floor `ceil(n/2)`) are exit 1; a second declaration,
  a malformed `Reverify` line, an unknown class, a short reason, a hidden entry
  or an empty entries dir are exit 2. The declaration names the entry's
  **host-fact base**, not every sentence; a row can be irrelevant to the entry
  beside it (bounds 17–23 in `corpus/knowledge/claim-ledger.md`).
- **Claim ids** (`verify`): every `R<digits>-<digits>` **whole word** in the
  checked docs must be a row id, so a doc citing an id that no row defines fails
  (`MISSING-ID doc:line id`, exit 1) — the ledger used to be iterated forward
  only. Rows cited nowhere are `ORPHAN`s: counted, listed with `--orphans`.
  Bound: the vocabulary is upper-case `R`, and a range (`R12-01..03`) validates
  its head only.
- **Scorecard cells** (`cells`): every table row inside a
  `## Round <N> — pre-move|post-move` section whose first cell is an axis name
  must carry a **pointer** — and a pointer counts only if it holds: the cited
  rows are re-run through the ordinary claims machinery (`row_failures`), the
  cited pinned artifacts are re-compared (`STALE-POINTER`), and a section that
  has lost an axis is a setup error (`all six axes exactly once`). `UNCITED`
  cell, missing id, failing cited row or moved pinned revision ⇒ exit 1;
  zero cells, an empty id universe, or a scorecard outside `--docs` ⇒ exit 2.
  A cell with no row pointer at all is a setup error (nothing to re-run).
- **Revision stamps** (`corpus/stamps.tsv`): `path<TAB>sha256<TAB>lines<TAB>
  bytes`. `verify` recomputes; `STALE`/`MISSING`/`NOT-A-FILE` lines + exit 1.
  Regeneration is a reviewed `stamp` commit — **no auto-re-pin**: a stale row is
  a question ("was the edit intended?"), and the answer belongs in the report.
  `stamp` refuses absolute paths, whitespace/TAB paths and the output file.
- **Citation classes** (checked by token shape): `corpus/…` + root docs;
  `knowledge/…`/`lessons/…` (corpus shorthands); `<lane>-shokunin/…` (sibling
  repo); `ufo/…`/`.ufo/…` (main-repo `.ufo`); `{a,b}` brace sets (every
  alternative). Anything else — bare filenames, `~`-host paths, `xdg-*`
  fragments, API routes, `$VAR/…` — is a *reference*, not a path, and is not
  checked. `UNRESOLVED`/`EPHEMERAL` fail the run **unless the citing line
  labels the token** (`scratch|ephemeral|relocat|formerly|no longer|removed|
  renamed|historical` → counted as `labeled`). Round 11's first contact fixed
  four committed defects: two `local://` scratch URIs, one kotoba path wearing
  this repo's anchor, one bare host filename.
- **Command safety.** A claim must be one simple command: allowlisted first
  token (`bash|grep|sha256sum|wc|test|python3`, the last only for registered corpus scripts), no shell
  metacharacters, no denied verb (`op`, `the-janitor`, `git`, `rm`, `curl`,
  `sudo`, `tmux`, …). `POLICY` refuses **without running** (exit 2). This is a
  text guard, not a sandbox — review of the committed file is the control.
- Detail, bounds and falsifiers: `corpus/knowledge/claim-ledger.md`;
  round-11 narrative and the four gate defects: `corpus/lessons/round-11.md`.

## Failure table (exact texts, exits)

| Symptom | Cause | Exit |
|---|---|---|
| `required command not found: <cmd>` | missing tmux/python3/op/opencode/flock | 2 |
| `missing executable client: …/client.py` | client.py not +x | 2 |
| `missing model overlay: …/opencode.json` | overlay unreadable | 2 |
| `port 40961 already has an OpenCode server outside tmux session janitor` | foreign server squatting the port | 1 |
| `handler exited before becoming ready` | app not unlocked / CLI integration off — **or** `op signin` died non-interactively (caller signed out; check `the-janitor whoami` first) | 1 |
| `handler is waiting for 1Password authorization` | readiness loop expired (120 probes, 60–300 s) — unlock app, approve prompt, `tmux attach -t janitor` if terminal input requested — **or** tmux alive but server wedged (health false ≠ auth pending); check `opencode.log` before re-approving | 1 |
| `request text must be supplied on stdin, not as arguments` | args passed to `request` | 2 |
| `read an empty request from stdin` | empty stdin (client.py) | 2 |
| `Janitor server is unavailable` / `HTTP <code>` / `invalid response` | transport-layer client errors | 1 |
| `request completed without a text response` | well-formed reply, no text parts — **not a failure**, exits 0 | 0 |
| `[ERROR] <ts> open <path>: no such file or directory` | `op run --env-file` over a missing file (direct `op` path; `cmd_run` refuses earlier with exit 2) | 1 |
| `[ERROR] <ts> expected at least 1 arguments but got 0 instead` | `op run` with no command (direct `op`; `cmd_run` refuses earlier with `missing command`, exit 2) | 1 |
| `[ERROR] <ts> "<vault>" isn't a vault in this account. Specify the vault with its ID or name.` | an `op://` value whose vault does not resolve — the fast-fail branch of the round-10 non-determinism (the other branch blocks silently) | 1, ~2 s |
| `LOCAL_EVIDENCE_CHECK: FAILED (<reason>)` | receipt bytes/schema/fields diverge from custody record | 1 |
| `JANITOR_ACTION_REQUIRED` in reply | handler correctly refusing to execute; operator action needed | — |

Model cap: `steps: 4` on the janitor agent. Requests needing >4 steps die at
max-steps with no artifact (observed precedent in `handoff-status.json`
`janitor_provenance`) — keep requests atomic; deterministic work belongs in
`the-janitor` subcommands, not the model path.

## Env-var contract (full knob list — `corpus/knowledge/janitor-env-contract.md`)

Path/port overrides: `THE_JANITOR_ENV`, `THE_JANITOR_CONFIG_DIR`,
`THE_JANITOR_STATE_DIR`, `THE_JANITOR_PORT`, `THE_JANITOR_REQUEST_TIMEOUT`
(client.py, default 3600 s), `MUSKETEER_CHROME_PROFILE`,
`ONEPASSWORD_BROWSER_SUPPORT`, `MUSKETEER_CDP_PORT`.

Auth selectors (read by `_serve`, L194–210): `OP_SERVICE_ACCOUNT_TOKEN`
(present ⇒ skip `account get`/`signin`/`whoami` — the headless path) and
`OP_ACCOUNT` (⇒ `--account` passthrough). Neither is in `usage()`.

**tmux env-passthrough trap (verified tmux 3.7b):** `ensure_started` spawns
`_serve` via `tmux new-session` on the *server's* env — a freshly spawned
server inherits the caller's env, but an **already-running** tmux server
does not (pane sees nothing of `OP_SERVICE_ACCOUNT_TOKEN`/`OP_ACCOUNT`/
`THE_JANITOR_*` exported at call time; verified empty). The headless path
therefore only works reliably when `request`/`start` spawns the tmux server
itself, or via `tmux set-environment -g` / a 0600 env file. Symptom of the
trap: the app-auth path runs instead — signin hangs →
`handler exited before becoming ready`.

The model endpoint is **not** a knob: `MODEL_ENDPOINT` (L19) is a hardcoded
literal that only feeds `status`'s cosmetic `endpoint` line. The load-bearing
URL is `provider.qwen-local.options.baseURL` in `opencode.json` — the
round-3 drift fix is one JSON field there, after which the `status` line
still lies until L19 is updated too.

## `op.env` consumption — two parsers (`corpus/knowledge/op-ref-consumption.md`)

`the-janitor refs` (`cmd_refs` L234, an `awk -F= '/^[A-Z][A-Z0-9_]*=/'`) and
`the-janitor run` (`cmd_run` L248, `exec op run --env-file="$ENV_FILE" -- "$@"`)
are **different parsers over the same file**, and they disagree on eight of the
line shapes a real env file contains (measured, `op` 2.35.0; verdict gate
`corpus/op-ref-probe.sh`):

- `refs` **omits** keys the resolver injects — `export K=v`, `K = v` (spaces
  around `=`), `k=v` (lowercase first char). An inventory is not a load list.
- `refs` calls a **quoted** `K="op://…"` a non-ref; the dotenv parser strips the
  quotes and resolves it — an audit false negative on a live credential.
- `refs` lists every duplicate line; the resolver keeps the **last** one.
- `op run` performs dotenv expansion (`$K`, `${K}`, file-local then process env,
  unset → empty), strips surrounding quotes, and **treats `#` as a comment
  anywhere in an unquoted value** (`K=ab#cd` → `ab`, silently). `refs` sees none
  of that — it just redacts.
- Precedence is the inverse of the common dotenv default: **env files beat the
  shell environment**, and the last `--env-file` beats earlier ones.
- Masking is narrower than its help text reads: only **reference-resolved**
  values are concealed on stdout/stderr; plain values pass through, with or
  without `--no-masking`.

Wrapper guards fire before `op` (exit 2: `missing <path>`, `run: missing
command`); `op`'s own argument/file errors are exit 1. Verify a file's shape
without touching the vault: `bash corpus/op-ref-probe.sh` (POLICY refuses any
op-side file carrying a ref token, so the probe cannot resolve a reference).

## Config layering (`corpus/knowledge/config-layering.md`, verified via `debug`)

`OPENCODE_CONFIG` **adds** a layer; it does not replace the global one. The
handler resolves: global `~/.config/opencode/opencode.json` (always) →
`$CONFIG_DIR/opencode.json` overlay → project discovery from cwd (none today,
**not disabled** — `OPENCODE_DISABLE_PROJECT_CONFIG=1` is unset) →
`agents/janitor.md` frontmatter, which wins `agent.janitor` wholesale
(`steps: 4` resolved, even though dead `$CONFIG_DIR/config.json` claims 8 —
`config.json` is not a discovered filename; inert decoy, edits do nothing).

Resolved-state facts (`opencode debug agent janitor` / `debug config` under
the `_serve` env): 9 provider defs load but `enabled_providers` gates to
`qwen-local`; 23 agents resolve and `fnm-nudge.js` is offered to the loader
but **fails at every serve** (`Plugin export is not a function` — logged on
all 8 recorded daemon starts since 2026-08-29); 56 permission rules
evaluate last-match-wins with janitor's
`{"*": deny, janitor_auth: allow}` as ceiling — `tools` shows only
`janitor_auth: true`. Isolation = the permission ceiling + the L214–219
credential unset, **not** a config boundary. A hostile or sloppy edit to the
*global* opencode config or a new global plugin reaches the handler.

## Rotation & revocation (no rotate verb — `corpus/knowledge/janitor-lifecycle.md`)

There is no rotation/revocation subcommand; both are side effects:

| Secret class | Rotate where | Restart needed? |
|---|---|---|
| `op://` refs in `op.env` | vault item | no — `op run` re-resolves each call |
| raw values in `op.env` | edit the file (0600) | no — next `run` reads it |
| `OP_SERVICE_ACCOUNT_TOKEN` | IdP/vault + re-export | yes — `_serve` reads it once at daemon start (L194) |
| `OP_SESSION_<domain>` | `stop` → next start re-signins | yes — token lives in daemon memory only |

`stop` is the revocation primitive: kills the tmux session, discards
`OP_SESSION_*`/`OP_SERVICE_ACCOUNT_TOKEN`, removes `session-id`
(conversation id, not a credential — `client.py` falls back to
`POST /session` when it's gone/stale). Vault-side revocation is observable
only lazily: `janitor_auth` → `AUTH_REQUIRED` inside the next request.

## Credential-hygiene checklist

**Executable since round 15.** Every item below is one row of
`corpus/checklist.tsv`, run by `bash corpus/checklist-run.sh`: 9 items carry a
runnable check (expected exit + expected last output line), 7 declare a
`by-hand` class with a unique reason because no command shape exists. The row's
`note` says what its check covers and what stays with the operator; the `lead`
ERE binds row to item, so editing this list without adding a row fails as
`UNMATCHED-ITEM`.

Evidence production:
- [ ] Record mechanism and metadata: paths, modes (`op.env`/`config.json`/`opencode.json`/`client.py` 0600–0755 in `$CONFIG_DIR`; state dir 0700; `client.lock`/`session-id` 0600 in `$STATE_DIR`), verb names, exit codes, field names. **`bash corpus/surface-census.sh` first** (round 10): exit 0 = every declared path still has its declared kind/mode, no undeclared child sits in the 4 enumerable dirs, and every runtime shape floor holds. Then `bash corpus/drift-pins.sh`: exit 0 = every pinned host file and symbol pin still matches the committed baseline (15 files / 20 pins as of round 12; 19 before it). Non-zero on either = re-read the named path before citing it. New cited file ⇒ census row (reviewed commit; there is no `--pin`) **and** a drift-pins `--pin` once. In-repo artifacts: run `bash corpus/claim-ledger.sh verify` first and cite the stamped revision (`corpus/stamps.tsv`); after landing edits, re-`stamp` (reviewed commit) — a `STALE` row means the artifact moved under the citation.
- [ ] After any intentional host-file change (endpoint fix, config edit), run `--pin` **once** and report the `REPIN`/`MOVED` lines you accepted — that is the durability of every line ref in this corpus. Never re-pin inside the same round that discovers the drift.
- [ ] Quote command output only when it is metadata-only (`status`, `cdp-bridge status`, `tac-check` block).
- [ ] `refs` output: key names OK for internal use; ref paths stay out of artifacts.
- [ ] Before relying on a key inventory, run `bash corpus/op-ref-probe.sh` (exit 0 = the `op.env` contract still holds on this host) and remember what it pins: `refs` answers about *lines*, `op run` answers about *loaded variables*. For a specific file, list keys with `op run --env-file=<file> -- printenv <KEY>`; `export`/spaced/lowercase/quoted-ref lines are where the two diverge.
- [ ] Never paste `the-janitor run` output: plain-valued keys are **not** masked (only resolved refs are). Check a value's class before quoting it, and never write a plain secret into `op.env` expecting masking.
- [ ] Receipts/checksums bind *bytes*: state scope explicitly ("local receipt integrity only"), never imply provider attestation or live access.
- [ ] Handoffs carry context + receipt *path*; `handoff-status.json` `boundaries` is the vocabulary: `credentials_in_evidence: false`, `target_authority_conferred: false`.

Handler operation:
- [ ] One request at a time — `client.lock` flock serializes machine-wide; queue instead of racing.
- [ ] After `stop`, expect `AUTH_REQUIRED` on next request until the operator re-approves.
- [ ] Keep `config_overlay` (`opencode.json`) intact: `enabled_providers: ["qwen-local"]`, `share: disabled`, `autoupdate: false` — the gate is post-merge, so the *global* `~/.config/opencode/opencode.json` also reaches the handler (providers/agents/plugins load; janitor deny + `enabled_providers` contain them). Global-config edits are an attack/drift surface on janitor.
- [ ] Never widen `janitor` agent permissions (`{"*": deny, janitor_auth: allow}`) — `janitor_auth` ignores all `op` output for a reason.
- [ ] CDP port 9222 + musketeer profile are shared with the kake fleet: report lease conflicts, don't absorb them.
- [ ] Never put secret-adjacent text into a request expecting memory-only
  handling — transcripts persist in `xdg-data/opencode/opencode.db` past
  `stop`; purge = stop + `rm -rf xdg-data` (no verb).
- [ ] Run `corpus/transcript-scan.sh` after any request that carried
  credential-shaped stdin, before/after operator-signin experiments, and
  alongside `drift-pins.sh` — exit 0 `CLEAN` (WARN cells allowed), exit 1 =
  finding: report `HIT` lines + counts only, never the matched rows.
- [ ] Treat `127.0.0.1:40961` as unauthenticated handler access: no local
  process should POST to it, and enabling `OPENCODE_SERVER_PASSWORD` without
  a `client.py` Authorization header breaks `request` (server_healthy 401 →
  foreign-server text). Rollout recipe: `corpus/knowledge/control-plane-hardening.md`.

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
- Hunting for `THE_JANITOR_ENDPOINT`-style overrides — none exists; `MODEL_ENDPOINT` (L19; L17 is `MODEL_ID`) feeds only `status`'s display line. Fix `opencode.json` `baseURL`.
- Recording `op account get`/`account list` values — key names only; the values are account-identifying PII in the same class as `op://` ref paths.
- Assuming `op.env` is all `op://` refs — 2026-09-28 `refs` showed raw-value keys (identifiers); the convention is unenforced, so `cat` still leaks them.
- Treating `the-janitor refs` as the loader's view of `op.env` — it misses `export K=v`, `K = v` and lowercase keys that `op run` injects, and reports a quoted `"op://…"` as a non-ref that `op run` resolves. Two parsers, one file.
- Reading masking as a general guarantee — `op run` conceals only **reference-resolved** values on stdout/stderr; plain keys print verbatim (`cmd_run` passes no `--no-masking`, so this is the default path, not an opt-out).
- Writing a plain secret into an env file whose value can contain `#` or quotes — the dotenv parser truncates an unquoted value at `#` (`K=ab#cd` → `ab`) with no error, and strips surrounding quotes; the file looks right and the child gets something else.
- Treating `session-id` as a credential — it's an OpenCode conversation id: deleting it only forks context, `client.py` `session_exists` self-heals a stale id, and `stop` removes it anyway.
- Expecting a vault-revoked secret to surface eagerly — no watch exists; `janitor_auth` only runs inside a model request, so revocation shows up as `AUTH_REQUIRED` at next request time, never sooner.
- Editing `~/.config/the-janitor/config.json` to change the handler — it is inert: `config.json` is not an opencode-discovered filename and nothing references it. Its `steps: 8` disagrees with the real `steps: 4` (resolved proof in `config-layering.md`); treat it as a decoy, never a knob.
- Assuming `OPENCODE_CONFIG` isolates the handler from the user's global opencode config — verified additive merge: 9 providers, 23 agents resolve; global plugin `fnm-nudge.js` resolves but fails to load (`Plugin export is not a function`, non-fatal — a fix or loader change would activate it inside the handler). Containment is `enabled_providers` + last-match deny + the `_serve` env unset, not the layer boundary. Check `opencode debug agent janitor` after any global config change.
- Assuming `the-janitor stop` erases evidence — it drops only the in-memory
  authorization and `session-id`; the SQLite transcript and error log under
  `xdg-data/opencode/` persist (0600, no purge verb).
- Trusting the `{"*": deny}` ceiling as a request boundary — it only gates
  the janitor agent; the message body's `agent` field picks the permission
  set, and the unauthenticated port lets any local process name a permissive
  one (round-7 probe: cross-agent tool execution in the daemon env).
- Querying the transcript DB with plain `sqlite3 <db>` or `-readonly` — it
  creates/updates 0600 `-wal`/`-shm` siblings in the live state dir; use the
  `file:…?immutable=1` URI (or a `/tmp` copy). `transcript-scan.sh` does this.
- Classifying a `transcript-scan` hit by dumping matched rows — WARN/HIT
  counts + `distinct_<sid>` bound the finding; if classification is needed,
  look at `$.type`/`$.tool`/`length()` and a short prefix once, never copy
  the text into an artifact.
- Treating scan WARN cells as a leak — `api_key`/`access_token` match request
  text that *discusses* credentials (the 2 baseline WARN rows of the shipped scan revision are exactly that);
  HIT patterns are the material shapes. Don't invert the tiers.
- Trusting a host-file line ref because the file "hasn't changed in months" —
  drift is detected only against the committed baseline: `bash
  corpus/drift-pins.sh`, and on `DRIFT`/`MOVED` re-read the named line before
  citing it. v1's printer-plus-no-baseline shape is the counterexample: it
  exited 0 through four rounds of stale `L17` refs.
- Re-pinning (`--pin`) to clear a red gate, or hand-editing
  `corpus/drift-baseline.tsv` + `corpus/drift-symbols.tsv` to match a changed host
  file. `--pin` records what changed and is a deliberate, reported act; a
  baseline edited to silence `DRIFT` destroys the corpus's only drift signal.
  If a symbol's ERE no longer matches, the *claim* broke — fix the claim.
- Putting a secret-bearing file's content hash in the baseline — `op.env` is
  pinned by mode + line count + a `#10` count pin precisely because a sha256
  of a file holding raw values is an offline guessing oracle. Same rule for
  any future file that holds material rather than metadata.

- Treating `the-janitor refs` as a redactor you can paste. The guard is
  `awk`'s `v ~ /^op:\/\//` — a *prefix match*: a value beginning with the ref
  scheme is echoed whole, plaintext tail included, and `export K=v`, ` K=v`,
  `lower_case=v` lines never appear in the output at all (so the inventory can
  be *incomplete*, not just unredacted). Round-10 probe
  `refs-redaction-prefix-only` pins this; a fix should flip that probe to FAIL
  and update the decision table in the same commit.
- Reading the live transcript DB with `?mode=ro` "because read-only is safe" —
  it still touches `opencode.db-shm` in the live directory. Use `?immutable=1`
  or a `mktemp` copy of db+wal+shm (what `surface-census.sh` and
  `transcript-scan.sh` do).
- Editing `corpus/surface-census.tsv` (or `drift-baseline.tsv`) to clear a red
  gate. The declaration *is* the claim: a `DIVERGED`/`GONE`/`UNLISTED` line
  means the host moved, and the fix is to read the path, record what changed
  and then decide. Both files are reviewed commits by design — there is
  deliberately no `--pin` for the census.
- Declaring another lane's paths in the census to "cover" them, or adding a
  `# scan` directive over a shared dir (`~/.config/opencode`, `~/.local/bin`,
  `~/.agents`, the chrome profile below the NMH dir). Those surfaces are
  reported, not ruled: the census declares only paths that reach the handler,
  and a `UNLISTED` verdict over a sibling lane's file is an ownership claim
  this repo must not make.
- Assuming `PROVINCE.md` §Surfaces verifies itself. It is prose; nothing fires
  when a path disappears, changes mode, or when a file is *added* next to it.
  Run `surface-census.sh` before asserting a surface still exists as described.

## Falsification

Each bullet below is the measurement **at that round's revision** — the numbers
in a round bullet are history (that is what a round bullet is for); re-run the
command for the current figures, and take the live numbers from the gate's own
verdict line rather than from a narrative.

- `the-janitor --help`, `the-janitor status`, `the-janitor cdp-bridge status`,
  `the-janitor tac-check` reproduce every claimed surface (verified 2026-09-28).
  Round-3 additions: `the-janitor whoami` (exit + text reveal caller auth),
  `the-janitor stop` on stopped state (`already stopped`, exit 0, still
  removes `session-id`), endpoint `/health` curl (drift check),
  `corpus/knowledge/op-cli-surface.md` for the auth matrix + drift evidence.
- `corpus/knowledge/janitor-command-surface.md` carries line refs + runnable
  probes; script line numbers date to the 2026-09-28 read — re-grep before
  citing.
- Round-4: `corpus/knowledge/janitor-env-contract.md` carries the full
  env-var table (auth selectors `OP_SERVICE_ACCOUNT_TOKEN`/`OP_ACCOUNT`,
  `THE_JANITOR_*` overrides) and proof the model endpoint lives only in
  `opencode.json` `baseURL`; `grep -n 'OP_\|THE_JANITOR\|baseURL'
  ~/.local/bin/the-janitor ~/.config/the-janitor/opencode.json` reproduces it.
- Round-5: `corpus/knowledge/janitor-lifecycle.md` — rotation has no verb;
  per-class rotate-at-source table + `stop` as the revocation primitive;
  `grep -n 'OP_SESSION\|SESSION_FILE\|kill-session' ~/.local/bin/the-janitor`
  + `client.py` `get_session_id`/`session_exists` reproduce it.
- Round-6: `corpus/knowledge/config-layering.md` — resolved layering proven by
  `opencode debug agent janitor` + `opencode debug config` run under the
  `_serve` env (cwd `$CONFIG_DIR`, `OPENCODE_CONFIG`, throwaway XDG dirs);
  `config.json` inertness proven by resolved `steps: 4` ≠ its `steps: 8` and
  zero script references. `corpus/drift-pins.sh` pins mode+lines+sha256 of the
  cited host files — run it before trusting any line ref (round-9 carried the
  baseline into the repo; see the round-9 bullet).
- Round-7: `corpus/knowledge/handler-trust-boundary.md` +
  `handler-on-disk-state.md` — control plane unauthenticated (scratch repro:
  no-auth `POST /session` 200; `OPENCODE_SERVER_PASSWORD` set ⇒ 401/Basic
  `opencode:<pw>` 200), cross-agent env-inheritance probe
  (`agent:"open"` ran bash in the serve env), XDG persistence map
  (`opencode.db` transcripts 0600 survive `stop`), lock topology
  (`request`/`start`/`stop` flock; a hung request wedges `stop` up to
  3600 s → `tmux kill-session -t janitor` unblocks). Repro:
  `grep -n 'flock\|XDG_' ~/.local/bin/the-janitor`; sqlite3 row counts on the
  db; `tail` the log.
- Round-8: `corpus/transcript-scan.sh` + `knowledge/transcript-hygiene.md` —
  transcript-leak gate over the durable DB. Repro:
  `bash corpus/transcript-scan.sh` (CLEAN/HITS, exit 0|1|2),
  `--selftest` (scratch-db seeded-hit check, never touches real state),
  `sqlite3 "file:$SD/xdg-data/opencode/opencode.db?immutable=1"
  "select count(*) from credential"` ⇒ 0. The immutable URI is load-bearing:
  plain opens mutate `-wal`/`-shm` (re-verified 2026-09-28).
- Round-9: `corpus/drift-pins.sh` v2 + `corpus/drift-baseline.tsv` +
  `corpus/drift-symbols.tsv` — the drift gate has a stored baseline and exits
  non-zero. Repro: `bash corpus/drift-pins.sh` ⇒ `DRIFT_PINS: CLEAN
  (files=15 symbols=19)`, exit 0; `--selftest` ⇒ `DRIFT_SELFTEST: PASS
  (13 cases)`; falsify the baseline in a temp copy
  (`sed 's/^\(\$HOME\/.local\/bin\/the-janitor\).*/\1\t755\t333\tdeadbeef/'`)
  and pass it with `--baseline` ⇒ `DRIFT … sha deadbeef0b7e->2408b0c90b7e`
  + exit 1 — i.e. the committed file, not the printer, is load-bearing.
  `--pin` on a host file that grew a symbol ⇒ `MOVED <path>:<pin>-><actual>`.
  A baseline row carrying a hash for a no-hash path ⇒ `POLICY …` + exit 1
  (checked *before* the file is read). Missing option argument ⇒ exit 2.
- Round-10: `corpus/surface-census.sh` + `corpus/surface-census.tsv` +
  `corpus/state-shape.tsv` — the declared-surface and runtime-shape gate.
  Repro: `bash corpus/surface-census.sh` ⇒ `SURFACE_CENSUS: CLEAN (assets=20
  runtime=15 scanned=4 ok=34 absent=2 skipped=0)`, exit 0; `--verbs` ⇒
  `CLEAN (pass=7 skip=3)`; `--selftest` ⇒ `SELFTEST: PASS (16 cases)`. Falsify on
  a copy or a scratch tree: `touch ~/.config/the-janitor/notes.md` ⇒ `UNLISTED`
  + exit 1 (scratch proof: selftest case 5); `drop table part` on a DB copy ⇒
  `SHAPE (missing tables)` — deliberately *not* `SKIP` (case 11);
  `SQLite format 3X` (16 bytes, no NUL) ⇒ `SHAPE (magic mismatch)` (case 9).
  Depth of the DB read: `stat -c %y` on `opencode.db-shm` before/after a
  `?mode=ro` read moves; through the gate's snapshot copy it does not.
- Round-11: `corpus/claim-ledger.sh` + `corpus/claim-ledger.tsv` +
  `corpus/stamps.tsv` — calibration gate: claims carry commands, revisions
  carry hashes, citations must resolve. Repro: `bash corpus/claim-ledger.sh
  verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=11 stamped=28)`, exit 0; `citations` ⇒
  `CITATION_GATE: CLEAN (cites≈505 docs=39 unresolved=0 ephemeral=0 labeled=13)` (counts are revision-bound — they move with every doc edit; the verdict is the claim);
  `--selftest` ⇒ `SELFTEST: PASS (39 cases)`. Falsify: append a line to a
  stamped file ⇒ `STALE <path> sha=…->…` + exit 1; a claim row with `;` in the
  command ⇒ `POLICY <id> reason=metachar` + exit 2 and the command is **not
  run** (case 5 proves it with a marker file); a doc citing a scratch token
  (`local://x`) with no marker word ⇒ `EPHEMERAL …` + exit 1 (case 14); the same token on a line
  that says "scratch" ⇒ `labeled=` + exit 0 (case 15); a command that prints
  the expected verdict then a trailer ⇒ `reason=verdict-not-final` + exit 1
  (case 16).
- Round-12: `corpus/op-ref-probe.sh` + `knowledge/op-ref-consumption.md` — the
  `op.env` contract (two parsers) and the masking scope. Repro:
  `bash corpus/op-ref-probe.sh` ⇒ `OP_REF_PROBE: CLEAN (checks=44 oprun=12
  refs=7 divergent=5 edge=10 sig=6)`, exit 0; `--selftest` ⇒
  `OP_REF_SELFTEST: PASS (36 cases)`. Falsify: append `KAGI12_POISON=op://…` to
  a copy's `oprun.env` and run with `OP_REF_OP_BIN` pointed at a logger stub ⇒
  `POLICY` exit 2 **and an empty stub log** (selftest case `policy-ref-token`);
  a stale `--evaluate` fixture with one value changed ⇒ `FAIL oprun-value` +
  exit 1; `grep -n 'exec op run' ~/.local/bin/the-janitor` ⇒ L248 with no
  `--no-masking` (the masking premise).
- Round-14: `corpus/claim-ledger.sh docs` + the `Reverify:` declaration in each
    of the 17 `corpus/knowledge/*.md` entries — the knowledge surface's
    re-verification link. Repro: `bash corpus/claim-ledger.sh docs` ⇒
    `DOC_AUDIT: CLEAN (entries=17 row_linked=14 by_hand=3 undeclared=0
    missing_ids=0 unpinned=0 duplicate_reasons=0)`, exit 0, with
    `DOC_AUDIT_RATIO: row_linked=14/17 floor=9 by_hand=3 duplicate_reasons=0`
    above it. Falsify: delete one `Reverify:` line from a copy of an entry and
    point `--root` at the copy ⇒ `UNDECLARED <entry>` + exit 1 (case
    `docs-undeclared`); declare a fabricated id ⇒ `MISSING-ID <entry> R9-99`
    (case `docs-missing-id`); give two entries the same by-hand reason ⇒
    `DUPLICATE-REASON` (case `docs-duplicate-reason`); three entries with one row
    and two by-hand ⇒ `BROKEN … floor=2` (case `docs-ratio-floor`); write
    `Reverify:` with no space ⇒ shape error, exit 2 (case `docs-malformed-line`).
    The three by-hand entries (`config-layering`, `control-plane-hardening`,
    `handler-trust-boundary`) are the explicit unverifiable set and are
    revision-pinned; `docs` checks stamp *membership*, `verify` checks the hash —
    a fabricated stamps row passes this mode and fails `verify`.

## Round-22 active reading and execution boundary

The handler-era version, paths, command outcomes, line citations and host
counts earlier in this file are **historical** observations at their named
revisions. The round-18 substrate-absence record still bounds them:
`corpus/knowledge/substrate-deferral.md`. A row that DEFERs or a description
whose hash matches is not a live behavior check. Do not execute handler,
signin/account, private transcript, service, browser/CDP or receipt recipes
unattended merely because the historical table calls them safe.

For current documented credential-review decisions use
`corpus/knowledge/feature-bound-credential-review.md`, not the old merged
E1/E3 rows: Actions public preview and custom-OIDC public beta have distinct
feature pages and Business prerequisites; OpenBao token evidence does not
establish Vault-token or KV-retention parity. QUALITY QA10 requires the
feature page's own status anchor, not shared navigation/CSS.

Revision-pointer repair and source adjudication are separate evidence:
the former preserves and compares local bytes; the latter opens public
feature/product sources. Neither proves live credential access, and local
typed review never substitutes for non-author admission closure. The
round-22 parser excludes the explicitly blocked round-20 attempt while
retaining actual scored-section completeness/vacuity guards; old sample
case counts are history, not the current executed selftest tally.

## Gate registry — round-22 changed contracts

| name | kind | entry command | verdict map | selftest | pinned values | write scope | owner |
|---|---|---|---|---|---|---|---|
| feature-bound credential review | gate | `python3 corpus/feature-claims.py --phase after`; `--input <root-confined JSON>` adjudicates one unlabeled typed claim | 0 clean/admit; 1 failed/reject; 2 could-not-evaluate | `python3 corpus/feature-claims.py --selftest` | `corpus/feature-claims.json`; code-held source/catalog/control digests in `corpus/feature-claims.py` | read-only owned-root regular files; selftest writes only an isolated temporary fixture | kagi |
| revision-pointer audit | gate | `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` | 0 clean; 1 failed (stale/missing/dropped); 2 could-not-evaluate (unsafe/malformed/unavailable) | `python3 corpus/revision-audit.py --selftest` | `corpus/stamps.tsv`; immutable history commit; before input digests in `kagi-shokunin/.ufo/waves/round-22/frozen/before/expected.json` | read-only owned tree and Git objects, locks/lazy fetch/replacement objects disabled; selftest writes isolated temporary Git/filesystem fixtures only | kagi |
| claim ledger and cell parser | gate | `bash corpus/claim-ledger.sh docs`; other documented modes retain their scopes | 0 clean; 1 failed; 2 could-not-evaluate/setup/policy | `bash corpus/claim-ledger.sh --selftest` | `corpus/claim-ledger.tsv`, `corpus/stamps.tsv` | reads declared surfaces; reviewed `stamp` replaces only the owned TSV; selftest isolated | kagi |
| source registry/citation census | gate | `bash corpus/sources-census.sh` | 0 clean; 1 failed; 2 could-not-evaluate/setup | `bash corpus/sources-census.sh --selftest` | `corpus/SOURCES.md` and literal selftest expectations | read-only owned corpus; selftest isolated temporary files, no network | kagi |

The feature reviewer checks a fixed, reviewed source/anchor vocabulary, not
vendor truth. `--phase before` deliberately refuses known bad records;
`--phase boundary` returns 2 for unjudgeable controls rather than counting
free correct rejects. `--input` has no supplied expected label or authority:
use it for independent held-out qualifier/attribution attacks. Plan,
requirement, exclusion, runtime and evidence lists are unordered conjunctions;
duplicates and unknown/malformed values are refused.

The earlier shell-command allowlist example is historical. Its current
Python extension permits **only** the exact owned feature-review and
revision-audit script path tokens; inline/module/stdin Python and other
script names remain refused, with existing metachar/deny rules unchanged.
Do not run whole `verify` or current `cells` when their transitively cited
host-private commands are outside authorization. Use QM12's explicit
safe-row and skipped-row accounting; a scratch fixture is not a live-host
pass. Existing unrelated gate registry debt is not claimed repaired here.

### Post-falsification contract clarifications (round 22)

- `verify R12-03 R21-04` is **not** a row selector. Unknown/extra positional
  arguments now fail setup before surface reads; `docs` accepts at most one
  entry directory and `stamp` retains its documented path list. No-argument
  full verify still has host-bound scope and is not authorized by this round.
  QM12's safe-row plan names actual commands and skipped IDs explicitly.
- The cell scanner handles CommonMark H2 prefix spacing/tabs, keeps the
  Round word reserved across letter case, and requires a complete pre/post
  token. Only the exact filed blocked attempt is excluded; malformed
  attempts cannot disappear as prose while other cells keep a run positive.
- Feature `--claims` and `--input` readers open nonblocking, then reject
  non-regular descriptors. A FIFO timeout is not a successful refusal.
- Revision data paths exclude Git/JJ administrative components and
  hardlinks. History input must equal Git's canonical full commit ID,
  including in SHA-256 repositories; a long abbreviation is still an
  abbreviation. The selected root/stamp table are trusted owned-artifact
  inputs, not authorization to fingerprint secret-bearing worktree files.
- Exact catalog reference sets are a projection, not all valid evidence:
  alternates/supersets may bar-fail. Eligibility scope is policy metadata;
  product-announcement EPM wording and feature-page Business prerequisites
  do not establish commercial-tier identity or live entitlement.
- S022/S023 refine the manual Vault role/locator reading in
  `corpus/lessons/round-22-source-errata.md`. JWT login stays outside the
  typed gate's closed profile; this correction does not inflate C1 counts.

## Gate registry — round-23/24 contracts (routed D2)

| name | kind | entry command | verdict map | selftest | pinned values | write scope | owner |
|---|---|---|---|---|---|---|---|
| claim ledger and cell parser (host-safe, round 24) | gate | `bash corpus/claim-ledger.sh verify` / `cells`; `--allow-host-rows` is the only consent to run `[host]`/`[substrate]` rows | 0 clean; 1 failed; 2 could-not-evaluate/setup/policy (incl. `untagged-host`, `host-path`, `bash-option`, `script-symlink`, `script-expansion`, `script-missing`, `backslash`) | `bash corpus/claim-ledger.sh --selftest` (R11-09/R18-03) | `corpus/claim-ledger.tsv`, `corpus/stamps.tsv`; host-script list and closed host-free argument vectors in the script (`HOST_SCRIPT_RE`, `host_free_args`) | reads declared surfaces; policy/host classification precedes recursion skips; `stamp` replaces only the owned TSV; selftest isolated | kagi |
| closure disposition review | gate | `python3 corpus/closure-dispositions.py` (R23-02) | 0 clean; 1 failed (missing/duplicate/unknown obligation, unresolved fixed pointer, rejected disposition); 2 setup (source digest mismatch, malformed input) | `python3 corpus/closure-dispositions.py --selftest` (R24-02, 14 cases) | `corpus/closure-dispositions.json` incl. the source sha256 of `corpus/lessons/round-22-verifier-spotcheck.md` | read-only; pointers resolve in the working tree (not a commit tree); selftest writes an isolated temp dir | kagi |
| rendered-text-v1 normalizer | helper | `python3 corpus/rendered-text-v1.py digest <body>` / `locate <body> '<quote>'` | 0 ok/located; 1 not located or selftest failure; 2 setup (usage, unreadable, not strict UTF-8) | `python3 corpus/rendered-text-v1.py --selftest` (R24-01, 22 cases) | the step order and regexes in the file are the ONE declaration (sources S027-S029, S031; S030 rejected) | reads only the named file; no network, no writes; malformed-tag behavior is a pinned regex bound, not browser parsing | kagi |
| row identity reader | helper | `bash corpus/row-identity.sh <selector>` (R24-03..R24-16) | 0 prints `ROW_IDENTITY: <selector> count=N [blank=B ]sha256=<64hex>`; 2 setup (unknown selector, missing file, failed inner gate) | none of its own: each R24 row is pinned to an exact digest and `.ufo/waves/round-24/tools/identity-swap.py` is its mutation harness | selector→membership table in the script header | reads one repo file or runs a host-free python gate; prints counts/digests only | kagi |
| source registry/citation census (round 24) | gate | `bash corpus/sources-census.sh` (R21-02) | 0 clean; 1 failed (incl. SC_FETCH, SC_INROW); 2 setup | `bash corpus/sources-census.sh --selftest` (R21-03) | `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, `corpus/inrow-pins.tsv`; historical in-row set S001-S016 in the script | read-only owned corpus; selftest isolated temporary files, no network | kagi |

Round-24 contract notes. Whole `verify` and `cells` are now safe-by-default
entry points: a host row prints `HOST-SKIP <id>` and counts `host_skipped=N`
instead of running, so QM12's hand-listed safe-row substitute is no longer the
only safe path (QM15). Residual bounds: a NEW committed wrapper script that
calls a host script is not recognized by name (it is reviewable as a new
file); `citations` stats sibling/fleet paths for existence only; R21-01
(`op-ref-probe.sh --dotenv-bytes`) stays untagged because it runs the
installed `op` binary under `env -i` with scratch HOME/XDG and no account, ref
or handler — a wave-1 seat classed it HOST for executing `op`, and that
dissent is recorded in `corpus/lessons/round-24.md`.

Round-24 recovery precision (`corpus/lessons/round-24.md` recovery Gate):
script arguments are literal, attached pattern-file paths receive the same
root checks, and any symlink component in a script path is refused. The
host-free cells exception is exactly R23-01's committed fixture vector, not
an extensible prefix. Invalid or missing self invocations cannot become
CLEAN recursion skips; host-tagged self rows are HOST-SKIPped first.

C3 identity is the projection declared in `corpus/row-identity.sh`: path
keys, literal lines, IDs or case names, not complete row semantics or test
assertion bodies. The measurement helper
`.ufo/waves/round-24/tools/identity-swap.py --selftest` checks malformed
receipt refusal; its counting mode isolates selected-ID docs and validates
process exit plus complete terminal counts. This is author-side
measurement, not independent admission or a hostile-program sandbox.

### Round-25 gate registry additions

| Gate | Command and contract | Evidence |
|---|---|---|
| current-tense self-count bindings | `python3 corpus/self-counts.py` / `--selftest`; declared reviewed bindings, not digit-census completeness; `expect:` says pinned and never executes | R25-01/R25-02; `corpus/lessons/round-25.md` |
| source release clocks | `python3 corpus/release-clock.py` / `--selftest`; default is the byte-pinned **round-26 rearmed receipt**, not live release state. `--receipt FILE --receipt-sha SHA256` selects a receipt against the selected root's table; `--observe NEW.json` never overwrites a receipt or rewrites TSV. Later drift may return exit1. Default/table/R25-04 migration and the separate original historical replay are named in the round26 lesson | R25-03/R25-04; S033–S041; `corpus/lessons/round-26.md` |

## Round-26 release-drift response

The default `python3 corpus/release-clock.py` replays the **pinned round-26
rearmed receipt**, not live vendor truth. Its path/digest, active table and
R25-04 expectation migrated explicitly; the original round25 receipt was
not rewritten. Its matching original code/tables remain in the separate
historical frozen snapshot (`corpus/lessons/round-26.md`).

The fetched Python feed's maximum stable semantic version is3.15.1 (S039),
not its first item, the3.14.9 backport. The relied-on Unicode-whitespace
and `html.unescape` clauses still locate in the served3.15.1 documentation
(S040/S041). No semantic change or installed-interpreter upgrade is inferred.
The old3.15.0 anchors remain fired; both successors retain on-release cadence
and are re-armed at named3.15.1 anchors, so a later stable release can fire.

Run `bash .ufo/waves/round-26/tools/replay-current.sh after` for the current
profile. The paired `before` has the current registry/new receipt but the
original table: it must fail on both missing successor bindings and the
old observations. `after` applies the explicit rearm only. For the separate
historical28-record drift demonstration, pass the frozen-root argument
`.ufo/waves/round-26/frozen`; it excludes the successor rows by design.
The wrapper pins the checksum-manifest digest outside each snapshot and
verifies every input before evaluation; input-plus-manifest tampering is
`snapshot_tampered` / exit2, never CLEAN. This replays the existing gate,
not a new monitor, vault capability or source hierarchy.

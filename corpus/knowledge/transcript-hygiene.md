# transcript hygiene — the scan gate for durable request text

Source basis: `~/.local/state/the-janitor/xdg-data/opencode/opencode.db`
(0600, SQLite, WAL) schema + row census via `sqlite3 "file:…?immutable=1"`
2026-09-28 (round 8); `corpus/transcript-scan.sh` (same dir as this file) is the
executable gate. Companion: `handler-on-disk-state.md` (why the transcript is
durable at all), `handler-trust-boundary.md` (who can write to it).

`verified 2026-09-28`. Everything below is metadata: no secret values, no
`op://` ref paths, no session ids, no matched text.

Reverify: R11-06, R11-07

## Why this exists

Round 7 established: `part.data` holds full request/response text in plaintext,
the DB survives `the-janitor stop`, and no purge verb exists (§4 of
`handler-on-disk-state.md`). What was missing: a repeatable check that nothing
secret-shaped ever landed in it. A claim like "requests are safe to send"
degrades silently — one sloppy `echo 'op://…' | the-janitor request` persists
forever under the same-user boundary, with no other surface warning about it.
`transcript-scan.sh` closes the loop: run it before/after any request
carrying credential-shaped input, or on any cadence; it is offline, read-only,
and prints only counts — never matched text.

## Schema facts the scan encodes (verified 2026-09-28)

Text-bearing columns scanned (`SCAN_COLS` map, 11 tables): `part.data`,
`message.data`, `event.data`, `session.title`/`slug`/`path`/`share_url`/`summary_diffs`/`metadata`/`permission`,
`session_input.prompt`, `session_message.data`,
`session_context_epoch.baseline`/`.snapshot`, `todo.content`, and the newer
`project.name`/`worktree`/`commands`/`sandboxes`,
`workspace.name`/`directory`/`extra`, `permission.action`/`resource` (this last
group is what makes the shipped revision 888 cells rather than round-8's 270).
`event` rows are keyed by `aggregate_id` = session id (used for
triage). DB is a *projection* over the `event` log — scanning `part` alone
under-counts, which is why `event.data` is in the set.

Tripwire tables that must stay empty (populated ⇒ account/oauth material
inside the quarantine DB, exit-1 finding): `account`, `account_state`,
`control_account`, `credential`, `session_share`. Observed 2026-09-28: all
empty; `account` has NOT NULL `access_token`/`refresh_token` columns —
if an opencode OAuth sign-in ever ran through this daemon, vault-adjacent
tokens would rest here at 0600 with no purge path. `session_share.secret`
is the same class (share links have bearer secrets).

## Two-tier result semantics

- **HIT** (exit 1): material-shaped strings — `op://`, `-----BEGIN`, AWS
  `AKIA`/`ASIA`, GitHub `ghp_`/`gho_`/`ghu_`/`ghs_`/`ghr_`/`github_pat_`,
  Slack `xox{b,p,s,a,r}-`, `sk-ant-`/`sk-proj-`/`sk_live`/`sk_test`,
  `AIza`, `ya29.`, JWT `eyJhbGci`/`eyJhbG`, `OP_SESSION_`,
  `OP_SERVICE_ACCOUNT_TOKEN`. Any of these at rest = a secret or live ref
  persisted; treat as a finding, not a format problem.
- **WARN** (exit stays 0): credential-language field names —
  `access_token`, `refresh_token`, `api_key`, `secret_key`, `apikey`.
  Baseline 2026-09-28 has 4 WARN cells spanning 5 distinct sessions:
  request text *discussing* credentials (requests asking the handler to
  work with named keys/gateways). WARN rows are expected whenever a request
  mentions a credential concept; they are signal for "requests carry
  credential intent — keep stdin clean", not violations. Never copy WARN-row
  contents into artifacts; triage is `distinct_<sid>` counts, not text.

Baseline (round 8, *earlier revision of the script*): 0 HIT, 4 WARN, all 5
tripwires empty, 270 cells × 30 patterns — this measurement describes a narrower
revision than the one committed that round (the gate was still being edited when
"fleet pause" landed it), so treat it as historical, not as the current gate's
baseline.

Baseline (round 9, shipped revision, re-verified 2026-09-28):
**HITS=2, warns=2, 888 cells × 32+5 patterns, all 5 tripwires empty.** Both HITs
are the `xai-` prefix colliding with provider *prose* in a text part — the
matched run is a 5-character lowercase word, not a key — confirmed with the new
content-free triage mode: `transcript-scan.sh --classify` →
`CLASSIFY part.data pattern=xai- rows=1 key_shaped=0 prose=1` (same for the one
`event.data` row). No key-shaped material is present. A third HIT class that
appeared on first contact, `gsk_` rows=7, was a **code defect, now fixed**: SQL
`LIKE` treats `_` as "any single character", so the unescaped pattern matched
`gsk` + any 4 alnum chars. Patterns are now escaped (`like_lit` + `ESCAPE '\'`)
and the same rows report literal `gsk\_` = 0. Root cause, class taxonomy and
process lessons: `lessons/round-9.md` §11-12.

## Operational notes

- Open mode is a **snapshot**: the gate copies the db plus its `-wal`/`-shm`
  siblings into `mktemp` and scans the copy, so it never opens the live state
  dir (a plain `sqlite3 <db>`, even `-readonly`, creates/updates the 0600
  `-wal`/`-shm` siblings — verified 2026-09-28) and it *does* see
  wal-resident rows (`--selftest` includes a wal-resident case). Ad-hoc probes
  should still use `file:…?immutable=1`, which has a committed-rows blind
  window on a populated `-wal` but cannot mutate anything.
- `--classify` (round 9) is the bounded triage path: for every pattern that
  fires it prints `rows`, `key_shaped` (the 32 characters after the literal
  prefix are all key characters) and `prose`. It never prints matched text, so
  "is this material or a prefix collision?" is answered mechanically instead of
  by peeking. Case note: `LIKE` is case-insensitive while `instr()` is exact,
  so the split is triage, not a verdict.
- `NOTE … ABSENT` = a scanned table is missing (schema drift): re-check
  coverage rather than assuming the surface shrank.
- `--selftest` builds a scratch DB in `mktemp`, seeds a fake `op://` row plus
  a populated `credential` row, and asserts exit 1 — run it after editing the
  pattern or table lists; it never touches the real state dir.
- Exit codes: 0 clean-or-warn, 1 any HIT (pattern or tripwire), 2 usage/db
  error (missing db, unreadable, sqlite3 absent, query error — a query failure
  cannot masquerade as a clean pass).
- `--db PATH` scans any OpenCode-shaped db — reusable on the *scratch*
  replicas used for control-plane probes (`handler-trust-boundary.md`),
  never pointed at another user's state.
- `--db` paths containing `?`/`#` break the URI form (caught by the open
  probe → exit 2); point it at real paths only.
- Triage on a HIT: the printed `distinct_<sid>` count bounds spread; to find
  the offending session, query `session.id`/`title`/`time_created` (metadata
  only — still never print `part.data` into an artifact). Purge is manual:
  `the-janitor stop` + `rm -rf $STATE_DIR/xdg-data` (no verb), which also
  destroys the audit trail — decide before deleting.

## Bounds

- LIKE-scanning catches *shapes it is told about*, not arbitrary secrets — a
  high-entropy string with no known prefix passes. HIT patterns are the
  minimum prefix set; extend, never silently shrink.
- **A pattern set that grows re-fires on old rows.** Round 8 measured 25 HIT
  patterns; the shipped revision carries 32, so the round-9 run flagged rows
  that had been sitting in the DB since before round 8 (row census unchanged:
  7 sessions / 39 messages / 55 parts / 238 events). Any baseline number must
  name the *shipped revision* it describes — pattern count, cell count and the
  script's hash — or it is not a baseline.
- **Pattern escaping is load-bearing.** `LIKE` wildcards inside a pattern make
  the gate fire on near-misses (`gsk_` → `gsk` + any char, 7 rows). Patterns are
  escaped now; when adding a pattern, put the literal bytes in the array and let
  `like_lit` handle escaping.
- `session_input`/`session_message`/`session_context_epoch`/`todo` are
  scanned but empty at baseline — future opencode versions or other writers
  may populate them; the ABSENT/0-row states are part of the baseline.
- Row counts (session 7 / message 39 / part 55 / event 238 / project 1) are
  the 2026-09-28 census, not invariants — the DB is append-mostly.

## Repro / falsification

```sh
SD=${THE_JANITOR_STATE_DIR:-$HOME/.local/state/the-janitor}
bash corpus/transcript-scan.sh                # CLEAN / HITS=n, exit 0|1|2
bash corpus/transcript-scan.sh --classify     # key_shaped vs prose per firing pattern (no text)
bash corpus/transcript-scan.sh --selftest     # scratch-db gate check (incl. wal-resident case)
DB="file:$SD/xdg-data/opencode/opencode.db?immutable=1"
sqlite3 "$DB" "select count(*) from part where data like '%op://%';"   # 0
sqlite3 "$DB" "select count(*) from credential;"                       # 0
ls -la $SD/xdg-data/opencode/   # -wal/-shm mtimes unchanged by immutable scan
```

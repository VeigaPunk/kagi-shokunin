# round-8 lesson — transcript hygiene gate + false-positive taxonomy

## What this round closed

Round 7 left the durable-transcript finding with a *manual* check shape
("treat request stdin as at-rest data; purge is manual"). There was no
repeatable gate answering "has anything secret-shaped ever landed in the
transcript?" This round shipped `corpus/transcript-scan.sh` +
`knowledge/transcript-hygiene.md`: 270-cell LIKE scan over every text-bearing
column + row-count tripwires on the credential-bearing tables
(`account`, `account_state`, `control_account`, `credential`,
`session_share` — schema confirmed to carry `access_token`/`refresh_token`/
`value`/`secret` NOT NULL columns; all empty at baseline).

Baseline: 0 HIT, 4 WARN cells across 5 distinct sessions, 5/5 tripwires
empty, exit 0.

## Lessons

1. **A single severity tier fails on contact.** The first pattern list mixed
   material shapes (`op://`, `-----BEGIN`, `ghp_`) with field-name language
   (`api_key`, `access_token`). The real DB immediately produced hits — all
   in *request text discussing credentials* (requests asking the handler to
   work with named keys/gateways), zero actual material. A gate that fires
   on the common case trains operators to ignore it. Two tiers (HIT exit 1 /
   WARN exit 0) preserve both signals.

2. **WARN cells are a hygiene metric, not noise.** 5 distinct sessions carry
   credential intent in request text — quantified evidence that stdin to
   `request` is a channel where operators *talk about* secrets. That is
   exactly the surface where one careless paste persists at 0600 forever.

3. **Re-verified the read-side gotcha live.** A `-readonly` sqlite3 open
   mutated `opencode.db-shm`/`-wal` mtimes (17:26–17:27); the
   `file:…?immutable=1` URI scan did not. The script's open mode is
   load-bearing, not cosmetic.

4. **Counts-only output is enforceable.** The script prints row counts and
   `distinct_<sid>` triage, never matched text — classification was done by
   looking at `json_extract(data,'$.type')`, `length()`, and an 80-char
   *prefix* of `$.text` once, confirming the WARN rows are request-language.
   That classification step is itself a documented, bounded exception —
   pattern/volume first, minimal peek only to classify tier. (The earlier
   draft of this lesson quoted WARN-row fragments — reviewer flagged it
   against our own triage rule; corrected to category-level description.)

5. **README rot found.** The `Model endpoint drift` known-gap bullet was
   truncated mid-sentence at `requests` — verifier traced the truncation to
   the round-7 commit (rounds 4–6 carried the complete sentence). Corpus
   docs rot too; fixed this round. Same wave caught a stale line ref:
   `MODEL_ENDPOINT` is script **L19**, not L17 — four corpus files carried
   L17 since round 4 (line-count-only pins can't catch per-symbol drift).

## Verification evidence

- `bash -n` clean; `--selftest` seeded `op://` + populated `credential`
  detected (exit 1, 2 HITs), clean scratch db passed (exit 0).
- Real DB run: `TRANSCRIPT_SCAN: CLEAN (cells=270 patterns=25+5 warns=4
  schema-absent=0)`, exit 0; `-wal`/`-shm` mtimes unchanged by the scan.
- Missing-db path exits 2 (`transcript-scan: db not found`), verified on a
  bogus `--db` path during development.
- L2 reviewer pass: 17 claims checked (15 VERIFIED, 2 WRONG — both applied
  here), URI-escape caveat noted for `--db` paths containing `?`/`#`.

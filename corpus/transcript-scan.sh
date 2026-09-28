#!/usr/bin/env bash
# transcript-scan.sh — secret-shape tripwire over the janitor transcript DB.
#
# Round 7 proved request/response text is durable plaintext in
# $STATE_DIR/xdg-data/opencode/opencode.db and that `the-janitor stop` does NOT
# purge it. This script is the repeatable gate for that surface: it counts rows
# matching secret-shaped LIKE patterns in every text-bearing column and row
# counts in every credential-bearing table. It NEVER prints row contents or
# matched text — counts, session-id triage, and exit codes only.
#
#   exit 0  clean          exit 1  hits found          exit 2  usage/db error
#
# Usage: transcript-scan.sh [--db PATH] [--selftest] [-h|--help]
#   --db PATH    override DB (default: $THE_JANITOR_STATE_DIR or
#                ~/.local/state/the-janitor)/xdg-data/opencode/opencode.db
#   --selftest   build a scratch DB in mktemp, seed a fake op:// row, verify
#                the gate fires (exit 1) and a clean db passes (exit 0). No
#                contact with the real state dir.
#
# Open mode: sqlite3 URI `file:...?immutable=1` — the read does not create the
# 0600 -wal/-shm siblings a plain open would (documented gotcha in
# knowledge/handler-on-disk-state.md "Read-side gotcha").
set -euo pipefail

SD="${THE_JANITOR_STATE_DIR:-$HOME/.local/state/the-janitor}"
DB="$SD/xdg-data/opencode/opencode.db"
SELFTEST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --db) DB="${2:?--db needs a path}"; shift 2 ;;
    --selftest) SELFTEST=1; shift ;;
    -h|--help) sed -n '1,20p' "$0"; exit 0 ;;
    *) echo "usage: transcript-scan.sh [--db PATH] [--selftest]" >&2; exit 2 ;;
  esac
done

# --- scan surface ------------------------------------------------------------
# table -> "col1 col2 ..." text columns that can hold request/response text,
# plus the column used for session-id triage (sid_map below).
declare -A SCAN_COLS SID_COL
SCAN_COLS[part]="data";                          SID_COL[part]="session_id"
SCAN_COLS[message]="data";                       SID_COL[message]="session_id"
SCAN_COLS[event]="data";                         SID_COL[event]="aggregate_id"
SCAN_COLS[session]="title";                      SID_COL[session]="id"
SCAN_COLS[session_input]="prompt";               SID_COL[session_input]="session_id"
SCAN_COLS[session_message]="data";               SID_COL[session_message]="session_id"
SCAN_COLS[session_context_epoch]="baseline snapshot"; SID_COL[session_context_epoch]="session_id"
SCAN_COLS[todo]="content";                       SID_COL[todo]="session_id"
# tables that must stay EMPTY — populated = account/oauth material in the
# quarantine DB (finding, same severity as a pattern hit)
TRIPWIRE_TABLES="account account_state control_account credential session_share"

# Secret-shaped patterns. SQL LIKE (ASCII case-insensitive); `_` in a pattern
# acts as any-single-char, which is acceptable for these prefix families.
# Deliberately prefix-shaped; generic strings ("password", "sk-") are too noisy.
# HIT tier = material that should NEVER rest in the transcript (exit 1).
# WARN tier = credential-language field names — request text discussing keys
# ("retrieve the … API keys") matches these legitimately; reported, exit stays.
# Baseline verified 2026-09-28: 0 HIT; WARN rows exist because past requests
# name key/credential concepts (see knowledge/transcript-hygiene.md).
PATTERNS_HIT=(
  'op://'                 # vault ref paths — must never rest in the transcript
  '-----BEGIN'            # PEM blocks: PRIVATE KEY, OPENSSH, PGP, certs
  'AKIA' 'ASIA'           # AWS access key id prefixes
  'ghp_' 'gho_' 'ghu_' 'ghs_' 'ghr_' 'github_pat_'   # GitHub tokens
  'xoxb-' 'xoxp-' 'xoxs-' 'xoxa-' 'xoxr-'            # Slack tokens
  'sk-ant-' 'sk-proj-' 'sk_live' 'sk_test'           # Anthropic/OpenAI/Stripe
  'AIza' 'ya29.'          # Google API key / OAuth access token prefixes
  'eyJhbGci' 'eyJhbG'     # JWT header ({"alg":...)
  'OP_SESSION_' 'OP_SERVICE_ACCOUNT_TOKEN'           # daemon-env credential vars
)
PATTERNS_WARN=('access_token' 'refresh_token' 'api_key' 'secret_key' 'apikey')

hits=0; warns=0; cells=0; absent=0


sql() { sqlite3 "file:$DB?immutable=1" "$1"; }
# Known limit: --db paths containing '?' or '#' break the URI form and are
# rejected by the open probe below (exit 2) — point it at real paths only.

table_exists() {
  [[ $(sql "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$1'") -eq 1 ]]
}

run_scan() {
  local t c p n s
  for t in "${!SCAN_COLS[@]}"; do
    if ! table_exists "$t"; then
      printf 'NOTE  table=%s ABSENT (schema drift — re-check scan coverage)\n' "$t"
      absent=$((absent+1)); continue
    fi
    for c in ${SCAN_COLS[$t]}; do
      for p in "${PATTERNS_HIT[@]}"; do
        cells=$((cells+1))
        n=$(sql "SELECT count(*) FROM $t WHERE $c LIKE '%$p%'") \
          || { echo "transcript-scan: query error on $t.$c" >&2; exit 2; }
        if [[ $n -gt 0 ]]; then
          s=$(sql "SELECT count(DISTINCT ${SID_COL[$t]}) FROM $t WHERE $c LIKE '%$p%'") \
            || { echo "transcript-scan: query error on $t.$c" >&2; exit 2; }
          printf 'HIT   %s.%s pattern=%s rows=%s distinct_%s=%s\n' \
            "$t" "$c" "$p" "$n" "${SID_COL[$t]}" "$s"
          hits=$((hits+1))
        fi
      done
      for p in "${PATTERNS_WARN[@]}"; do
        cells=$((cells+1))
        n=$(sql "SELECT count(*) FROM $t WHERE $c LIKE '%$p%'") \
          || { echo "transcript-scan: query error on $t.$c" >&2; exit 2; }
        if [[ $n -gt 0 ]]; then
          s=$(sql "SELECT count(DISTINCT ${SID_COL[$t]}) FROM $t WHERE $c LIKE '%$p%'") \
            || { echo "transcript-scan: query error on $t.$c" >&2; exit 2; }
          printf 'WARN  %s.%s pattern=%s rows=%s distinct_%s=%s\n' \
            "$t" "$c" "$p" "$n" "${SID_COL[$t]}" "$s"
          warns=$((warns+1))
        fi
      done
    done
  done
  for t in $TRIPWIRE_TABLES; do
    if ! table_exists "$t"; then
      printf 'NOTE  tripwire=%s ABSENT\n' "$t"; absent=$((absent+1)); continue
    fi
    n=$(sql "SELECT count(*) FROM $t") \
      || { echo "transcript-scan: query error on $t" >&2; exit 2; }
    if [[ $n -gt 0 ]]; then
      printf 'HIT   tripwire=%s rows=%s (credential table populated — should be empty)\n' "$t" "$n"
      hits=$((hits+1))
    else
      printf 'ok    tripwire=%s rows=0\n' "$t"
    fi
  done
}

if [[ $SELFTEST -eq 1 ]]; then
  command -v sqlite3 >/dev/null || { echo "transcript-scan: sqlite3 not found" >&2; exit 2; }
  T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
  cat > "$T/mk.sql" <<'SQL'
CREATE TABLE part(id text, message_id text, session_id text, data text);
CREATE TABLE message(id text, session_id text, data text);
CREATE TABLE event(id text, aggregate_id text, data text);
CREATE TABLE session(id text, title text);
CREATE TABLE session_input(id text, session_id text, prompt text);
CREATE TABLE session_message(id text, session_id text, data text);
CREATE TABLE session_context_epoch(session_id text, baseline text, snapshot text);
CREATE TABLE todo(session_id text, content text);
CREATE TABLE account(id text); CREATE TABLE account_state(id integer);
CREATE TABLE control_account(email text); CREATE TABLE credential(id text);
CREATE TABLE session_share(session_id text);
INSERT INTO part VALUES('p1','m1','ses_selftest','{"text":"fake op://vault/item/field marker"}');
INSERT INTO credential VALUES('c1');
SQL
  sqlite3 "$T/hit.db" < "$T/mk.sql"
  sqlite3 "$T/clean.db" < "$T/mk.sql"
  sqlite3 "$T/clean.db" "DELETE FROM part; DELETE FROM credential;"
  echo "-- selftest: seeded db (expect exit 1, 2 hits) --"
  if DB="$T/hit.db" bash "$0" --db "$T/hit.db"; then
    echo "SELFTEST FAILED: seeded hit not detected" >&2; exit 2
  else
    [[ $? -eq 1 ]] || { echo "SELFTEST FAILED: unexpected exit" >&2; exit 2; }
  fi
  echo "-- selftest: clean db (expect exit 0) --"
  DB="$T/clean.db" bash "$0" --db "$T/clean.db" \
    || { echo "SELFTEST FAILED: clean db flagged" >&2; exit 2; }
  echo "SELFTEST OK (seeded hit detected; clean db passed)"
  exit 0
fi

command -v sqlite3 >/dev/null || { echo "transcript-scan: sqlite3 not found" >&2; exit 2; }
[[ -f $DB ]] || { echo "transcript-scan: db not found: $DB" >&2; exit 2; }
# immutable URI = no -wal/-shm side effect on the live state dir
sqlite3 "file:$DB?immutable=1" 'SELECT 1' >/dev/null \
  || { echo "transcript-scan: cannot open $DB read-only" >&2; exit 2; }

run_scan
printf 'TRANSCRIPT_SCAN: %s (cells=%d patterns=%d+%d warns=%d schema-absent=%d) db=%s\n' \
  "$([[ $hits -eq 0 ]] && echo CLEAN || echo "HITS=$hits")" \
  "$cells" "${#PATTERNS_HIT[@]}" "${#PATTERNS_WARN[@]}" "$warns" "$absent" "$DB"
[[ $hits -eq 0 ]]

# R60SentinelTrial — security review of the AppRole trial and this round's receipts

Seat: sentinel (read-only on the lane; every execution below ran on copies or
against the lane file with `--work` inside the seat scratch). Reviewed bytes:
`corpus/openbao-approle-trial.sh` sha256
`49ea928f28f42c7cce91459fe577a6d80023db3844229047718f483bfed0e54f` (27248 B,
mtime 2026-11-07 15:39:15 -03). This supersedes an earlier review of
`a228e312…` (26929 B, 15:31); the two deltas between them are the `ST_BASH`
fix in the selftest fixtures and the T3 bounded-retry fix. Receipts reviewed:
every file under `.ufo/waves/round-60/build/` as of 15:50, plus the round-60
counter receipts (refreshed 15:44:50). Scratch:
`/fast/scratch/hyaku/kagi-r60/R60SentinelTrial/` (removed before yield). Host:
Linux 7.2.11-arch1-1, OpenBao v2.7.2 (`9e0a0d3c…`), util-linux 2.42.4.

Method: static read of the trial; an independent ground-truth probe of the
AppRole endpoints on a throwaway dev server (transcript
`probe-groundtruth.txt`); a traced real run (`strace -f` on `execve` and every
file mutation, plus a `/proc/*/cmdline` sampler scoped to the trial's process
tree, plus a recording loopback listener planted at the caller's `BAO_ADDR`/
`VAULT_ADDR`); a no-bao `--selftest` run; seven mutations of a scratch copy;
eight concurrent real runs; and an isolated run of the C2 counter at the
reviewed bytes. No secret value is printed in this file or in any receipt it
cites.

## Ground truth measured independently (needed to judge T1)

On bao v2.7.2, a throwaway `bao server -dev` on 127.0.0.1:

- default role: role_id-only login -> HTTP 400 `missing secret_id`;
- `bind_secret_id=false` **alone** -> HTTP 500 `at least one constraint should
  be enabled on the role`;
- role created with `token_bound_cidrs=127.0.0.1/32` (bind default true):
  role_id-only login -> 400 `missing secret_id`; then
  `bao write auth/approle/role/<r> bind_secret_id=false` **on the same role** ->
  the same role_id-only body -> HTTP 200 with a token;
- `secret-id-accessor/lookup` returns `cidr_list, creation_time,
  expiration_time, last_updated_time, metadata, secret_id_accessor,
  secret_id_num_uses, secret_id_ttl, token_bound_cidrs` and no `secret_id`
  value; destroying the accessor makes a still-valid secret_id login read
  HTTP 400 `invalid role or secret ID`;
- T2/T3 refusals read HTTP 400 `invalid role or secret ID`; T5 reads
  `source address "127.0.0.1" unauthorized by CIDR restrictions on the role:
  %!w(<nil>)`.

The trial's T1 implements exactly the frozen two-observable form with
`token_bound_cidrs` (lines 334–350), not §A3's restatement. See D-S1.

## Checks

### 1. No `secret_id` value, token or request body on any argv — PASS

Commands and evidence:

- `grep -nE 'secret_id=|secret_id:' corpus/openbao-approle-trial.sh` -> the only
  matches are the non-secret configuration fields `bind_secret_id=true|false`
  (T1 lines 334/345); no `secret_id=<value>` form exists.
- Static path: `login_body` builds the login JSON from `RID`/`SIDV`
  **environment** variables inside a `python3 -c` child and pipes it to
  `bao write auth/approle/login -`; `gen_secret_id`/`gen_secret_id_acc` pipe
  `{}` on stdin; `acc_lookup`/`acc_destroy` pipe the accessor from `ACCV` on
  stdin. The role's `role_id` is read from JSON into a shell variable and only
  ever reaches `login_body` (function argument, not process argv).
- Traced real run (`strace -f -e trace=execve,openat,creat,unlink,rename,mkdir
  -s 4096`), audit of every `execve` in the trial's tree:
  `EXEC: total=167 argv_hits=0 uuid_on_argv=0`.
  `uuid_on_argv=0` is the strong form: no UUID at all (neither `role_id` nor
  `secret_id`) appears on any argv.
- `/proc/*/cmdline` sampler scoped to the trial's process tree (PPID walk):
  82 distinct bao cmdlines, `argv_secret_shapes=0` with the census
  `(^|[^_])secret_id[=:][0-9a-f]{8}-|hvs\.|hvb\.|X-Vault-Token|BAO_DEV_ROOT_TOKEN_ID=`.
- The trial prints only verdicts and error slugs (`TRIAL T1 HOLDS aref=1 …`,
  `aerr=missing-secret-id`, `err=source-address-127-0-0-1-unauthorized-by-cidr-re…`);
  no request body, token or secret_id value is printed.

### 2. No token-shaped string in any receipt or artifact — PASS

Commands and evidence:

- `python3 scan_secrets.py <every file under .ufo/waves/round-60/build/ and
  .ufo/waves/round-60/w1/>` (patterns `hvs.`/`hvb.`/`hvr.`, bare `s.` root
  tokens, `BAO_DEV_ROOT_TOKEN_ID=<value>`, `X-Vault-Token:`, `Authorization:
  Bearer`, `secret_id=<uuid>`, `"secret_id":"…"`):
  `SECRET-SCAN: hits=11 value_shaped=0 doc_placeholder=11`. The hits are the
  public docs' own example `"secret_id":"37b74931..."` / `X-Vault-Token: ...`
  quoted in the scout's report, its verifier, and this review; none is a lane
  value.
- Same sweep over the trial source, the trial receipts and the C2 counter
  receipts: `value_shaped=0`; the only source hit is the selftest fixture
  `"secret_id":"SID-FIXTURE-1"` (a deliberately fake value used to prove the
  custody predicate rejects a response that echoes a secret_id).
- `grep -nE 'hvs\.|hvb\.' corpus/openbao-approle-trial.sh` -> no match; the
  trial's own `F-NOSECRETSHAPE` case asserts this.
- No `r60-`-shaped nonce (the root-token shape) appears in any receipt:
  `grep -rEo 'r6[0-9]-[0-9a-f]{16,}' .ufo/waves/round-60` outside `capture/`
  -> 0.
- The fetched captures contain only documentation placeholders
  (`X-Vault-Token: ...`, `"secret_id":"37b74931..."`); the fetch receipt
  records 0 Set-Cookie/Cookie lines and redacts two server correlation ids
  (QM72).

### 3. Dev server bound to 127.0.0.1, under `setpriv --pdeathsig KILL`, isolated from caller `BAO_*`/`VAULT_*` — PASS

Commands and evidence:

- Static: `start_server` launches
  `BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL bao server -dev
  -dev-listen-address="127.0.0.1:$port" -dev-no-store-token`; it then verifies
  the listener belongs to its own server pid with
  `ss -Hltnp "sport = :$port" | grep -q "pid=$SRV,"`; `HOME` points into the
  run dir; the ambient scrub loop unsets every `BAO_*`/`VAULT_*` before
  `bao version` and before the server starts.
- Traced run, listener census scoped to the trial's tree:
  `listen_lines=2`, `listen_nonloopback=0` (the server's API and cluster
  listeners, both `127.0.0.1`).
- Traced run, server process environment (names only, values never read):
  `server_env[<pid>]=BAO_DEV_ROOT_TOKEN_ID` — the server's own dev root token
  only; no inherited `VAULT_*`, `BAO_ADDR` or `BAO_TOKEN`.
- Ambient test: the caller exported `BAO_ADDR`/`BAO_TOKEN`/`BAO_NAMESPACE`/
  `VAULT_ADDR`/`VAULT_TOKEN`/`VAULT_NAMESPACE`/`VAULT_SECRET_ID` pointing at a
  recording loopback listener; the trial read `HOLDS` 5/5 and the listener
  recorded `conn_lines=0` (no request ever reached the caller's address).
- Cleanup: `stop_server` kills and reaps the server; `trap cleanup EXIT` plus
  INT/TERM/HUP; no `bao server` process with a reparented (ppid 1) parent was
  present after the runs.

### 4. `--work` confinement and `umask` — PASS

Commands and evidence:

- Static: `umask 077` (line 61); `BASE="${WORK:-…kagi-r60/R60ExecTrial/trial-work}"`;
  `D=$(mktemp -d "$BASE/openbao-approle-trial.XXXXXX")`; every write target is
  `$D/...` (`err`, `lout`, `lerr`, `lookup.json`, `home`, `nobin`, `fakebin`,
  `afile`, `w-*`); `cleanup` does `rm -rf -- "$D"`; no `chmod` on any file that
  can carry a secret (the only `chmod` is `+x` on the selftest's fake `bao`).
- Traced run, file-mutation audit with the work dir as the only allowed prefix
  (`/dev/null` whitelisted): `WRITES: total=93 outside=0`.
- `mktemp -d` creates the run dir 0700 and `umask 077` makes every file 0600;
  the secret_id never lands in a file at all (it travels on stdin and lives in
  shell variables), so no world-readable file can carry one.

### 5. `--selftest` cannot pass while the harness it asserts is broken — PASS, with two named ceilings

Commands and evidence:

- `env -i HOME=… PATH=<no-bao> TMPDIR=… bash corpus/openbao-approle-trial.sh
  --selftest` -> `APPROLE_SELFTEST: PASS (cases=45)`, rc 0; no listener, no
  connection, no `bao` on PATH (fixture-driven).
- Assertion shape: 45 `ck` cases with stable `FINDING <id>` ids, covering the
  no-bao leg (rc 2, exact SETUP line, no `TRIAL` line), a bad `--work`, usage,
  the shim matrix (each SHn flips exactly one test/flag; `NOPE`/`SH9`/empty
  flip none), `verdict_all`, `rc_for` (0/1/2, ERROR wins), `summary_line`,
  `countmap`, `errtext`/`slug`/`named_refusal`, `jget`/`jhas`, the custody
  predicate (clean/key/leak/no-metadata), and the login body builder
  (pair/role-only).
- Mutation matrix on a scratch copy (each mutation applied once; the copy runs
  `--selftest` under `env -i` with no bao):

  | mutation | result | finding id |
  |---|---|---|
  | M1 shim resolver maps SH1 to T1 and T2 | KILLED | F-SHIM-MATRIX |
  | M2 `rc_for` maps BROKEN to 0 | KILLED | F-RCFOR-BROKEN |
  | M3 ERROR no longer wins the exit code | KILLED | F-RCFOR-ERROR, F-RCFOR-ERRWINS |
  | M4 custody predicate always true | KILLED | F-CUSTODY-KEY, F-CUSTODY-LEAK, F-CUSTODY-META |
  | M5 no-bao guard removed | KILLED | F-NOBAO-LINE |
  | M6 real mechanic broken (`secret_id_num_uses=1` -> `2`) | SURVIVED | — |
  | M7 selftest replaced by a PASS printer | SURVIVED | — |

- Ceiling 1 (M6): a fixture-driven selftest cannot observe a real mechanic;
  the real run and the five shims are the falsifiers for that class, and the
  counter requires two real runs plus the five vectors. This is the correct
  division of labour, not a defect.
- Ceiling 2 (M7): the selftest cannot verify its own integrity. The pre-freeze
  battery currently has no control that mutates the selftest's verdict mapping
  (the critic's C2.4); the L1 should route C2-F9 (a copy whose selftest mapping
  is mutated must exit non-zero with a finding id) as the smallest kill.

### 6. `bind_secret_id=false` only on the throwaway server and documented as unsafe — PARTIAL

- Scope: PASS. The role `r60-t1` is created only on the in-memory
  `bao server -dev` started by this trial (127.0.0.1, `-dev-no-store-token`,
  `HOME` in the run dir); no persistent backend, no other server, and the
  server is killed and reaped on exit.
- Documentation: FAIL (low severity). The trial's header describes the
  throwaway server but never calls `bind_secret_id=false` a deliberate unsafe
  configuration (`grep -n 'unsafe\|deliberate'` -> no match); only
  `plans/round-60.md` §C2's named ceilings says so. A reader of the trial alone
  can mistake the leg for a recommended setting. Smallest remediation: one
  clause in the T1 comment, e.g. "`bind_secret_id=false` is a deliberate unsafe
  configuration, made only on this throwaway in-memory dev server; no
  persistent role is created."

## Defects routed (do not fix in the sentinel seat)

- **D-S1 (high, calibration)** — §A3 item 4 restates the frozen T1 condition
  while asserting "nothing … changes". The restatement is also unnecessary:
  the frozen two-observable form is achievable and is what the trial implements
  (role created with `token_bound_cidrs=127.0.0.1/32`, bind default true ->
  role_id-only 400 `missing secret_id`; `bind_secret_id=false` on the same role
  -> same body 200 + token). §A3's (b) 500-observable and (c)
  `secret_id_bound_cidrs` variant are not what the trial measures. Evidence:
  `probe-groundtruth.txt` probe5/probe6; trial lines 334–350. Smallest repair:
  append a correction that names the superseded §A3 T1 restatement and records
  that the frozen form was measured reachable; do not rewrite §A3.
- **D-S2 (resolved, operability/calibration)** — T3's "freshly generated
  secret_id logs in" leg raced the role's `secret_id_ttl=1s`; the trial's own
  `receipt-ref-real.txt` (15:32, pre-fix) recorded `TRIAL T3 BROKEN imm=1
  expref=1 fresh=0 err=invalid-role-or-secret-id`, and an isolated counter run
  of mine at `a228e312…` read `real=0 real2=0` once (its five shim legs read
  `shims=5`, so the failure was transient). The 15:39 fix adds a bounded
  3-attempt loop that generates a fresh secret_id and logs it in immediately
  for both T3 legs, absorbing CLI latency inside the 1 s TTL without changing
  the mechanic. Verified on the reviewed bytes: the traced real run reads
  `T3 HOLDS imm=1 expref=1 fresh=1`; 8 concurrent real runs all read
  `HOLDS holds=5 broken=0 error=0`; my isolated counter run reads
  `value=5 … real=1 real2=1`. No further action; keep the retry.
- **D-S3 (open, medium, calibration)** — the counter's refreshed
  `candidate.txt` (15:44:50) pins the trial bytes as sha256 `a228e312…` and
  says "FINAL bytes", but the lane file has been `49ea928f…` since 15:39:15
  (the T3 retry fix). The receipt therefore describes a superseded revision
  again. My isolated run of `plans/round-60-c2.sh --tree <lane>` at
  `49ea928f…` reads `C2_APPROLE_TRIAL: value=5 tests=5 pass=5 shims=5
  vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 ambient=1 none=1 secret=1 …)`,
  rc 0, so the reading is corroborated — but the L1 must freeze the trial and
  have the counter re-run at the frozen sha before the final record cites it.
  (The trial changed three times during this wave: 15:26, 15:31, 15:39.)
  Run note: my first current-bytes counter probe was killed mid-flight at
  ~15:45 when the counter seat deleted the shared
  `/fast/scratch/hyaku/kagi-r60/R60ExecCounterC2` namespace (its own
  acknowledgement); the isolated runs under my seat scratch are the readings
  cited here.
- **D-S4 (low, documentation)** — check 6's in-file "unsafe configuration"
  clause is missing (see above).

## Hardening the L1 should route

1. **C2-F9** (from the critic's C2.4): a control that mutates the trial's
   selftest verdict mapping and requires a non-zero exit with a named finding
   id. My M7 shows the current selftest is a PASS printer if replaced wholesale;
   M1–M5 show the real assertions work when the code is intact.
2. **Extend the counter's secret scan** beyond `hvs.`/`hvb.` and
   `secret_id`+UUID: the dev root token is an `r60-`+24-hex nonce, so a printed
   root token would not be caught by the current regex. Add
   `r60-[0-9a-f]{24}` and a bare-UUID check (with the fixture allowlist).
3. **Add a static argv assertion to the selftest**: a `grep -nE
   'secret_id=[0-9a-f]{8}-|secret_id="'` over the trial's own `bao` command
   lines, failing with a finding id. It would make K3's argv clause
   self-checking (the critic's C2.5).
4. **Freeze the trial before the final reading**: three edits landed during the
   wave (15:26, 15:31, 15:39); the counter receipt must pin the frozen sha and
   be re-run after the last edit, or the record will again describe a
   superseded revision (D-S3).

## SECRET-SCAN: hits=11 value_shaped=0

(11 documentation placeholders: the public docs' `"secret_id":"37b74931..."`
and `X-Vault-Token: ...` examples quoted in the scout's report/verifier and in
this review, plus the selftest fixture `SID-FIXTURE-1`; no `hvs.`/`hvb.`/`hvr.`,
no `BAO_DEV_ROOT_TOKEN_ID` value, no UUID-shaped secret_id value, no
`X-Vault-Token` value in any receipt or artifact.)

SEAT-STATUS: complete

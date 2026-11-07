# R51SentinelSecrets — secret-handling and host-safety review (round 51, C1 trial + counters)

Seat: R51SentinelSecrets. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `214d8bf530a0c87c00686493f21af15396284793`; predeclaration `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567`.
Reviewed (read-only):
- `.ufo/waves/round-51/controls/fixtures/ref/corpus/openbao-wrap-trial.sh` — sha256 `a16551ef8d0c483a636544e041efe3c88c1de7103ad48fdfa42cdb51cb12ef6e`
- `plans/round-51-c1.sh` (155 lines), `plans/round-51-c2.sh` (69 lines)
- `plans/round-51.md` §C1, `.ufo/waves/round-51/controls/controls-prefreeze.txt`

Environment: `bao` `/home/vgpnk/.local/bin/bao`, sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` = `PIN_BAO`, `OpenBao v2.7.2 (9e0a0d3c…), committed 2026-10-26T20:32:27Z`; no `bao` in `/usr/bin` or `/bin`. No package or tool installed; nothing outside my scratch and this report dir was written. Every dev server I started was bound to a random `127.0.0.1` port and killed; each such run's `setpriv --pdeathsig KILL` behaviour was also exercised (receipts C).

Method: static read of the trial and both counters, then black-box execution of the reference trial (5 runs: normal, SIGTERM, SIGINT, SIGHUP, SIGKILL) with a logging `bao` shim that records **only argv classification** (never values), `/proc` permission inspection, a cross-user read of a synthetic (fake) token in argv, and a live dev-server test of the argv-free replacements. Raw receipts: `.ufo/waves/round-51/build/R51SentinelSecrets.receipts/`.

## Verdict

| ID | Severity | Area | One line |
|---|---|---|---|
| S-1 | **HIGH** | secret in argv | live root token, wrapping tokens and KV plaintext are passed on the world-readable `bao` command line of 19 of 103 invocations |
| S-2 | MED | secret at rest | dev root token is written to `$D/server.log` (600) and survives a SIGKILL of the trial, contradicting "never printed" |
| S-3 | MED | TOCTOU | the free-port probe closes its socket before `bao server` binds, so a local process can win the port and harvest the root token |
| S-4 | LOW | scratch | counter scratch (`.state` with unwrapped nonces, per-run `server.log` with root token) persists if the counter is SIGKILLed |
| S-5 | LOW | .state key | SH1's cache filename is a truncated sha256 of the token-bearing argv (offline verifier; inside 700) |

All other checks in the assignment **pass** — see "Checks that pass (explicit none)" below.

---

## S-1 (HIGH) — live secrets on the `bao` argv, world-readable via `/proc/<pid>/cmdline`

**Exploit path.** On this host `/proc/<pid>/cmdline` is mode `444` and `/proc` is mounted without `hidepid` (`stat`/`/proc/mounts` below), so any local user can read the full argument vector of every process for as long as it lives. Every secret-bearing `bao` call in the trial puts the credential in argv:

| Call site (trial line) | What is on argv | Count per trial run |
|---|---|---|
| `bao server -dev -dev-root-token-id="$root"` (58) | dev **root token** | 1 |
| `bao unwrap -format=json "$1"` (92) | **wrapping token** | 7 |
| `bao write … sys/wrapping/{lookup,rewrap} token="$1"` (103, 167) | **wrapping token** | 5 |
| `bao kv put "$1" v="$2"` (81) | **KV plaintext nonce** | 5 |
| `bao write … sys/wrapping/wrap v="$v"` (190) | **unwrapped plaintext** | 1 |

**Evidence.**
```
$ stat -c '%a %U:%G %n' /proc/self/cmdline /proc/self/environ
444 vgpnk:vgpnk /proc/self/cmdline
400 vgpnk:vgpnk /proc/self/environ
$ awk '$2=="/proc"{print}' /proc/mounts
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0        # no hidepid

# cross-user read: synthetic fake token built inline (all zeros, not a real value), argv held 6 s
$ FAKE="r51-$(printf '0%.0s' {1..24})"
$ python3 -c 'import time,sys; time.sleep(6)' "$FAKE" & HP=$!
$ sudo -n setpriv --reuid=65534 --regid=65534 --clear-groups \
    sh -c "tr '\0' ' ' < /proc/$HP/cmdline | grep -c 'r51-000'"    -> 1      # uid nobody can read it

# logging shim on PATH, records argv CLASSIFICATION only (no values), full reference run
sub=server/-dev            argv_n=5 secret_shaped_args=1 value_args=0 root_token_flag=1
sub=kv/put                 argv_n=4 secret_shaped_args=1 value_args=1 root_token_flag=0   (x5)
sub=unwrap/-format=json    argv_n=3 secret_shaped_args=1 value_args=0 root_token_flag=0   (x7)
sub=write/-wrap-ttl=60s    argv_n=5 secret_shaped_args=1 value_args=1 root_token_flag=0   (x1)
# second shim pass additionally showed 5 x `write … token=<wrapping token>` on argv
# totals: 103 bao invocations, 19 carried a live credential or plaintext
```
Live confirmation on the shared host (values **not** reproduced): during the review, `ps -eo args | grep -c -- '-dev-root-token-id=r51-'` returned **5** — five concurrent dev servers (other seats' trials in this wave) were exposing their root tokens to my unprivileged shell at that moment. (One `pgrep -a bao` call in this session's ephemeral tool output displayed three such values; nothing token-shaped was copied into this report or the receipts. That incident is itself the finding: the pattern leaks across seats.)

**Impact.** Any local user (or any `ps`/auditd/process-accounting capture) can lift the dev root token while the server lives and obtain full control of that loopback dev server, plus every wrapping token and every test nonce. The values are ephemeral test data on a throwaway server, which bounds the blast radius, but this is the **reference implementation for the lane's vault operations** and it violates the binding refusal boundary ("never print, copy or paste any token value"). The same shape would leak a real credential if copied to a real mount.

**Smallest remediation (all mechanisms verified on 2.7.2, receipt F).**
1. `unwrap` — drop the positional token, use the client token = wrapping token:
   `BT=$(BAO_TOKEN="$w" bao unwrap -format=json)` → `value_ok=1`.
2. `sys/wrapping/lookup` — `printf '%s' "$w" | env -u BAO_TOKEN bao write -format=json sys/wrapping/lookup token=-`
   → `creation_path=secret/data/o`. **stdin must be newline-free**; a trailing newline makes the CLI send a bad token (`rc=2 «wrapping token is not valid or does not exist»`).
3. `sys/wrapping/rewrap` — `printf '%s' "$w" | BAO_TOKEN="$root" bao write -format=json sys/wrapping/rewrap token=-`
   → new token differs, unwraps to the same value, old token refused.
4. KV plaintext — `printf '%s' "$n" | bao kv put secret/t1 v=-` (`roundtrip=1`), or `v=@file` with a 600 file.
5. `sys/wrapping/wrap` value — `printf '%s' "$v" | bao write -wrap-ttl=60s -format=json sys/wrapping/wrap v=-` (`value_ok=1`).
6. Root token — `-dev-root-token-id` has no stdin form, and OpenBao 2.7.2's *default* dev token is **not** a constant: it generates an `s.`-shaped service token and prints it (verified). The argv-free route is therefore: omit `-dev-root-token-id`, wait for startup, parse `sed -nE 's/^Root Token: (.*)$/\1/p' "$D/server.log"` into a shell variable, then redact the line (S-2). Verified end-to-end: `default_token_parsed=1`, `auth_with_parsed_token_rc=0`, `log_token_lines_after_redaction=0`, `token_still_valid_after_redaction=1`, `log_mode=600`. Do not keep the token in argv.
7. **Mandatory counter coupling** (`plans/round-51-c1.sh`): the shims capture the token from argv and SH1 keys its replay cache on it —
   - `sh1` line 88: `k=$(printf "%s\0" "$@" | sha256sum | cut -c1-16)`. Once the token moves to stdin this key is identical for every unwrap, so SH1 would replay the first answer for the second unwrap too and the **real** run would report `T1 BROKEN`. The shim must hash stdin as well and replay stdin to `$REAL`.
   - `sh3` lines 92–94 and `sh4` lines 95–97: `case "$x" in token=*) t=${x#token=};;` finds nothing when the token arrives as `token=-`; both must read stdin, then feed it to `$REAL` (here-string or a 600 temp file).
   - `sh5` (98–100) only matches the path; it still works but must forward stdin to `$REAL`.
   Without those changes the argv fix silently de-calibrates the counter (real-run T1 breaks), so the trial and the counter must change in one commit.

---

## S-2 (MED) — dev root token at rest in `$D/server.log`, left behind on SIGKILL

**Exploit path.** `bao server -dev` prints `Root Token: <r51-hex24>` (line 83 of its log) even when `-dev-root-token-id` is supplied. The trial redirects that to `$D/server.log` (line 58). `cleanup` (33–44) removes `$D` on EXIT/INT/TERM/HUP — verified — but a **SIGKILL** of the trial shell skips the trap. `pdeathsig` still kills the server (verified), while `$D` and the token-bearing log stay on disk (XFS, not tmpfs: `findmnt -no FSTYPE,TARGET -T /fast/scratch/hyaku` → `xfs /fast`; `/tmp` → `xfs /tmp`).

**Evidence.**
```
$ # trial SIGKILLed 4 s in, after the log had flushed
pre_kill_server_pid_present=1 log_token_lines=1
after_sigkill_server_alive=0 leftover_dirs=1 leftover_files=1
leftover_server_log_mode=600 leftover_log_token_lines=1
```
Also: with `-dev-root-token-id` the log contains exactly one `r51-[0-9a-f]{24}` line; the trial header ("the dev root token … is never printed") and `plans/round-51.md` §C1 ("nothing token-shaped printed") are therefore too strong — true for stdout/stderr, false for the scratch log.

**Impact.** Same user only (700 dir, 600 file), so no cross-user exposure; but a token sits at rest after an abrupt kill, and the counter's `NOSECRET` check (line 150) scans only `W/out.*`, so file-borne leaks are invisible to it.

**Smallest remediation.** After `start_server` succeeds (line 60), redact the line in place while keeping `umask 077`:
`sed -i 's/^Root Token: .*/Root Token: <redacted>/' "$D/server.log"`.
If you also want the token off argv (S-1), omit `-dev-root-token-id`, parse the just-written `Root Token:` line into the shell variable first, then redact — verified: the token still authenticates after redaction and the log then holds zero token-shaped lines (receipt G). Do **not** simply drop `-dev-root-token-id` and assume a harmless constant: OpenBao 2.7.2 generates an `s.`-shaped dev token and prints it, so the log is still secret-bearing. Optionally append a trial self-check before `rm -rf "$D"`: fail if `grep -qE 'r51-[0-9a-f]{24}|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}' "$D/server.log"` still matches. If `--work` is omitted the same residue lands in `${TMPDIR:-/tmp}` (line 29) — pass `--work` everywhere, as the counter does.

---

## S-3 (MED) — free-port TOCTOU: a local process can impersonate the dev server

**Exploit path.** `start_server` (54–58) picks a port by binding `127.0.0.1:0`, **closes** the socket, and only later does `bao server` bind it. A local process that wins the race binds the port first; `bao server` fails, but the attacker can answer `bao status` convincingly and then receives `Authorization: Bearer <root token>` on the first authenticated request (`kv put`/`wrap`). Severity is bounded (ephemeral test data, 3 retries, loopback only), but the token is still handed to a foreign process.

**Evidence.** Code path at trial lines 54–58 (`s.bind(("127.0.0.1",0)); …; s.close()` then `-dev-listen-address="127.0.0.1:$port"`). Verified that the server itself accepts port 0 and that the real API port is discoverable without a probe:
```
$ bao server -dev -dev-listen-address=127.0.0.1:0 …
Listener 1: tcp (addr: "127.0.0.1:0", cluster address: "127.0.0.1:37866", …)
$ ss -ltnp | grep "pid=$SP,"
LISTEN 0 4096 127.0.0.1:37865 0.0.0.0:* users:(("bao",pid=…,fd=3))
$ BAO_ADDR=http://127.0.0.1:37865 bao status   -> rc=0
```
**Smallest remediation.** Start with `-dev-listen-address=127.0.0.1:0` and read the API port from the live process (`ss -ltnpH "pid=$SRV"` or the `/proc/$SRV/fd` → `/proc/net/tcp` inode map) instead of pre-probing. Fallback if `ss` is unwanted: keep the probe but bind the server under the same socket via `systemd-socket-activate`-style passing (heavier), or accept and document the race.

---

## S-4 (LOW) — counter scratch survives SIGKILL

**Observation.** The counter's dispatcher writes unwrapped responses (nonce-bearing JSON) to `$here/.state/{<sha16>,first}` (DISPATCH lines 88–100), i.e. `<W>/<hex>/bin/.state`, and `W` is `mktemp -d` under `$HYAKU_SCRATCH/kagi-r51` with `trap 'rm -rf -- "$W"' EXIT` (47–48). Verified during a real `--tree` run:
```
STATE mode=600 nonce_lines=1 path=kagi-r51/c1-counter.1kkeRv/<rundir>/bin/.state/7a517c8972642512   (…4 such files…)
STATE mode=600 nonce_lines=0 path=…/bin/.state/first
after exit: only /fast/scratch/hyaku/kagi-r51 remains   (W removed)
```
So the answer to the assignment's question is: **yes, inside the counter's scratch, and removed on any trapped exit**; mode 600 (inherited from the trial's `umask 077`) inside a 700 `W`. The only gap is SIGKILL of the counter, which skips the EXIT trap: `W` then keeps the nonces **and** each run's `server.log` with the root token (same mechanism as S-2).

**Smallest remediation.** Optional: at counter start, sweep `"$SCR"/c1-counter.*` older than, say, 6 h (`find … -maxdepth 0 -mmin +360 -exec rm -rf {} +`) so a killed run cannot accumulate; combined with S-2's log redaction, leftover scratch carries no token.

## S-5 (LOW) — SH1 `.state` filename is a token-derived hash

`k=$(printf "%s\0" "$@" | sha256sum | cut -c1-16)` (line 88) hashes the argv, which contains the wrapping token, so the filename is a 64-bit truncated hash of a live token — a cheap verifier for a guessed token for anyone who can read the dir (700/600, so same user only, and it disappears with `W`). Fix falls out of S-1 item 7 (hash stdin too, or key on a random per-call id); no separate action needed.

---

## Checks that pass (explicit "none")

| Check | Result |
|---|---|
| dev server bound only to `127.0.0.1` | **none** — `ss -ltnp` shows `LISTEN 127.0.0.1:<port>` only; connects to `192.168.0.253:<port>` and `172.17.0.1:<port>` got `ConnectionRefusedError`; `127.0.0.1` opened |
| killed on EXIT / INT / TERM / HUP | **none** — `exit=0/130/143/129` respectively, `server_alive=0`, leftover entries 0 for all three signals |
| killed on SIGKILL of the shell (pdeathsig) | **none** — `after_sigkill_server_alive=0` (≤1.5 s) |
| `umask` | **none** — trial sets `umask 077` (line 18); observed `D` 700, `server.log` 600, `.state` files 600 |
| scratch removal on normal/trapped exit | **none** — after a normal run: `files_left_in_work_after_exit=0`; after TERM/INT/HUP: 0; counter `W` removed |
| no `BAO_*`/`VAULT_*` leak from the caller | **none** — caller exported `BAO_TOKEN`/`VAULT_TOKEN`/`BAO_ADDR`/`VAULT_ADDR` with a canary; at the `version` and `server` invocations `bao_env_names=0`, `canary_bao_token=0`, `canary_vault_token=0`; trial line 50 unsets them, and the counter runs the trial under `env -i` (line 116) |
| root/wrapping tokens on stdout/stderr | **none** — reference run: `token_shape_stdout=0`, `wrapping_shape_stdout=0`, `stderr_bytes=0`; counter `--tree` run printed `nosecret=1` |
| `-dev-no-store-token` / HOME hygiene | **none** — leftover `$D/home` empty; token never written to `~/.bao`/`~/.vault-token` |
| counter dispatcher `.state` location/removal | **none** — inside `W`, mode 600, removed on EXIT (S-4 covers SIGKILL only) |
| C2 counter secret surface | **none** — `plans/round-51-c2.sh` touches only git objects, `claims-declared.sh` and the frozen round-48 counter; no server, no token, no `BAO_*`/`VAULT_*`; `W` via `mktemp -d` + EXIT trap (28–29) |
| lane-domain (SOPS/age/1Password) references | **none** — `grep -rniE 'sops|age -|op://|1password'` over the plan, trial and both counters returns nothing; no `op://` path is written anywhere |

## Notes, limits, and honesty

- **Counter coupling is the main operability risk of the S-1 fix.** `sh1`'s argv-keyed replay cache and `sh3`/`sh4`'s `token=*` capture are load-bearing for `DISCRIMINATE(T)`; an argv-free trial without shim updates would flip T1 to BROKEN in the real run and lower `value`. Ship trial + counter together and re-run the control receipt.
- `nos.`-style token regex: `NOSECRET` (line 150) catches `(s|b|r|hvs).` tokens and `r51-<24hex>` in stdout/stderr only. It cannot see `server.log` or `.state` (removed on exit). A trial-level assertion before `rm -rf "$D"` would close that gap.
- One process-listing command during this review displayed other seats' live `-dev-root-token-id` values in ephemeral tool output (S-1 evidence); no value was copied into this report or into the receipts, and each receipt was scanned for both token patterns before copying (`grep -rlE …` → no hits).
- Earlier in the session one canary test was invalid (it counted a non-`BAO_` canary variable) and was rerun precisely; one fix-verification run was invalid because it consumed the wrapping token before the lookup and was rerun in the correct order (receipt F is the valid run).
- No build, test or lint of the lane was run (not in this seat's scope); the lane's full `claim-ledger.sh verify` was not run.
- Cleanup: all dev servers I started are gone (pdeathsig test plus explicit kills; none of the `bao` processes visible at the end belong to this seat — the live ones are other seats' concurrent trials and were not touched). Secret-bearing scratch dirs (server logs, `.state`, tokopt/alt/fixver trees) were removed; only sanitized receipts remain.

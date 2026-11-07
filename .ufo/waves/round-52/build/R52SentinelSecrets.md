# R52SentinelSecrets — secret-handling audit (kagi round 52, attempt 1)

Seat: `R52SentinelSecrets` (leaf; no subagent dispatch). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`; predeclaration `52ebb412561d9601ad8658c30d1cfa0087af64d4`.
Audited surfaces (read-only; the frozen files were not edited):

- `corpus/openbao-kv-versions-trial.sh` — reference fixture `.ufo/waves/round-52/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh` (203 lines).
- `plans/round-52-c1.sh` (170 lines) — dispatcher, `.argv` log.
- `plans/round-52-c2.sh` (149 lines) — probe.

Method: every run was an instrumented **copy** under
`/fast/scratch/hyaku/kagi-r52/R52SentinelSecrets/` (a `--shared` clone at `$S/lane`, a copy of the
reference corpus at `$S/tree-ref`, and one-line patches: keep-scratch hooks, and a `R52PROBE_PORT`
override in the C2 probe copy). Live sampling of `/proc/<pid>/cmdline` and `/proc/<pid>/environ`
(booleans/counts only), SIGKILL residue tests, and a loopback decoy listener for the port race.
**No token, wrapping token, or nonce value is reproduced in this report or in any file I wrote**;
where a value would appear, only its shape/presence is reported.

Threat model used: several seats and OpenBao trials run concurrently as the same uid (`vgpnk`) on this
host; any other local uid is untrusted; the host is single-user but loopback ports are shared.

## Findings

| id | severity | surface | exploit path | receipt | smallest fix |
|---|---|---|---|---|---|
| F1 | **Medium** (trust boundary; effective impact bounded — token inert) | C2 probe, `plans/round-52-c2.sh:65-72` | Port is chosen by bind-then-close (`:65`), the dev server is launched (`:68`), and `BAO_ADDR`/`BAO_TOKEN` are exported **immediately** (`:70`) with no check that the listener on that port is our server. Any local process that takes the port in the window (a hostile uid, or a *benign* sibling seat's OpenBao on a colliding ephemeral port) receives `X-Vault-Token` on the first `bao status` call. The unauthenticated `sys/health` answer also lets it pass the 100×0.1 s status loop, so the probe proceeds and the counter can be forced into SETUP. This is exactly round-51 S-3, closed in the trial, re-opened in the new C2 counter. | R10 | After launch, poll `ss -Hltnp "sport = :$port"` for `pid=$SRV,` and export the token **only** after it matches (copy trial `:75,:79`); require the status loop to have succeeded; retry the port up to 3×, else `return 1`/`setup`. |
| F2 | Low (accepted residual) | trial `:70`; same for C2 `:67` | `BAO_DEV_ROOT_TOKEN_ID` is in the server's environment, not argv. `/proc/<pid>/environ` is mode `400` owner `vgpnk`; a **same-uid non-descendant** process can read it (demonstrated). ptrace_scope=1 does not gate environ reads. Impact: the dev root token of a throwaway in-memory server holding only random `r52-` nonces/kv values; another seat (same uid) could read it and interfere with that trial's namespace. Other uids are excluded by the `400` mode. `cmdline` is `444` world-readable, so moving the token to argv (as round-51 S-1 was) would be strictly worse. | R1, R11 | Accept and keep it in the environment; no smaller channel exists for a dev server without a uid split. Do not add `-dev-root-token-id` (argv). |
| F3 | Information | C2 counter vs C1 controls | C1 asserts NOSECRET over `$W/log/*` and NOARGV over `.argv` with ERE `…|r52-[0-9a-f]{24}` (`c1:48,158,164`). C2 has **no** secret-shape assertion over its own scratch, and its dev token prefix is `r52p-<24hex>` (`c2:66`), which that ERE does **not** match (`r52-` is not a substring of `r52p-`). No leak was found; the control is simply absent on a new secret-bearing surface. | R9, R10 | If a NOSECRET is added to C2, extend the ERE to `r52p-[0-9a-f]{24}` and scan `$W` **excluding** `$W/base` (the BASE git archive legitimately contains historical token-shaped sample strings: 39 files under `base/.ufo/waves/round-26/…tokens.html`, none live). |
| F4 | Low | C2 counter, `c2:70-90` | C2 never scrubs inherited `BAO_*`/`VAULT_*`; `env -i` is used for the **server** only. `cpath()` (`:75`) runs `env -u BAO_TOKEN` but leaves an inherited `VAULT_TOKEN` live, and `bao` honours `VAULT_TOKEN` when `BAO_TOKEN` is absent (verified). An operator with a real `VAULT_TOKEN` in the environment therefore has that credential sent to the throwaway dev server on the `sys/wrapping/lookup` call (real credential to a localhost server; not to a third party, server output is `/dev/null`). The trial scrubs the same variables (`trial:61`). | R13 | At C2 script start, unsets inherited `BAO_[A-Z_]*` / `VAULT_[A-Z_]*` exactly as the trial does, and use `env -u BAO_TOKEN -u VAULT_TOKEN` in `cpath` (or run probe clients under `env -i`). |
| F5 | Information | trial `:44-57`; counters `c1:57`, `c2:45` | A SIGKILL skips the EXIT trap, so scratch survives: trial `$D` (mode `700`) with `err` (`600`, 120 B) and an empty `home`; counter `$W` (mode `700`) with logs (`644`) and `.argv` (`644`). Scanning them for `s./b./r./hvs.` tokens and `r52-[0-9a-f]{24}` found 0 hits; no token file exists (`-dev-no-store-token`), and the dev server dies with its parent (`setpriv --pdeathsig KILL`; verified for both trial and C2). The C1 header already declares this as a named ceiling. | R5, R6, R14 | None required; the dirs are `0700` owner. Do **not** add a blanket stale-scratch sweeper — it could delete a concurrent seat's live run. |
| N1 | none | argv (all surfaces) | No token/value on any argv. The dev token is an env assignment; KV values are `v=-` on stdin. | R1, R2, R8 | — |
| N2 | none | stdout/stderr/logs | No token- or nonce-shaped string in the trial's stdout/stderr, the C1 logs, or the server's output (server stdout/stderr → `/dev/null`). | R3, R8 | — |
| N3 | none | on-disk token | `-dev-no-store-token` in both scripts; `$HOME` stays empty (no `.vault-token`/`.bao-token`) after normal runs and after SIGKILL. | R4, R5, R13 | — |
| N4 | none (trial) | trial `:75,:79` — S-3 | The `ss` pid check **does** close S-3 for the trial: our server's socket shows `pid=$SRV,`; a foreign-uid socket shows no `pid=` at all (ports 5355, 631), so the grep cannot false-accept; `BAO_ADDR`/`BAO_TOKEN` are exported only **after** the check passes, so even a lost race cannot release the token (the server fails to bind → retry). | R1, R12 | Keep; mirror it in C2 (F1). |
| N5 | none | C2 wrapping tokens | `sys/wrapping/wrap|rewrap|lookup` tokens travel on stdin (`token=-`) and are captured by `$(...)`; never argv, never printed, single-use/short-TTL, server dies with the counter. | R9 | — |
| N6 | none | KV values | Values are random `r52-` nonces written with `v=-` from stdin and only compared in-shell; never echoed (all `TRIAL` lines carry booleans/state vectors). | R3, R8 | — |

## Answers to the four assigned questions

1. **Token or value on an argv?** No. Live `/proc/<pid>/cmdline` sampling of every `bao` process during
   a trial: 14 distinct server samples, `argv_token=0` and `argv_envname=0` for all; client samples
   show `bao kv put secret/t5 v=-` with `argv_token=0`. The C1 `.argv` log (217 calls, 31 per real run)
   has 77 `v=-` elements, 0 `r52-` elements, 0 token-shaped elements (R8). The dev token reaches the
   server as `BAO_DEV_ROOT_TOKEN_ID=` in the environment and the client as `BAO_TOKEN` (R1, R2).
2. **In a log or stdout?** No: 0 token/nonce-shaped matches in the trial's stdout (6 lines: 5 `TRIAL` +
   summary) and stderr, in the C1 `$W/log/*`, and in the C2 scratch (`base/` excluded, see F3). The dev
   server's own output (which contains the root token at startup) is redirected to `/dev/null`.
3. **Left in scratch after SIGKILL?** Only non-secret residue: trial `$D` (`700`) with `err` (`600`,
   the last bao CLI error line) and an empty `home`; counter `$W` (`700`) with `644` logs / `.argv`.
   0 secret-shaped hits; no token file; the dev server always dies with its parent. Details in F5/R5/R6/R14.
4. **Does the `ss` pid check close the round-51 S-3 race?** For the **trial** yes (N4); for the **C2
   probe** no — the probe has no check at all and exports the token first (F1).

## Reproductions (commands, exit codes, last lines)

Scratch root `S=/fast/scratch/hyaku/kagi-r52/R52SentinelSecrets`.
Instrumented copies: `$S/trial-ref.sh` (adds `R52_KEEP_D` copy in `cleanup`),
`$S/lane/plans/round-52-c1-instr.sh` (keep-`$W` hook), `$S/lane/plans/round-52-c2-instr.sh`
(keep-`$W` hook + `R52PROBE_PORT`). No change to any decision logic of the measured artifacts.

- **R1 — trial with sampler** (`bash $S/watch.sh 40 … & ; R52_KEEP_D=$S/afterD bash $S/trial-ref.sh --work $S/trialwork`);
  rc `0`; last stdout line `OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`;
  sampler (unique): `pid=3312183 environ_mode=400 env_token_present=1 argv_token=0 argv_envname=0 port=53441 ss_pid_ok=1`
  and 13 more server samples, every one `argv_token=0 argv_envname=0`, `ss_pid_ok=1` once listening.
- **R2 — all-`bao` sampler** during a second trial: `argvtok_hits=0`; distinct client line
  `comm=bao argvtok=0 env_baotoken=1 args_head=bao kv put secret/t5 v=-`; server
  `comm=bao argvtok=0 env_baotoken=0 args_head=bao server -dev -dev-listen-address=127.0.0.1:34941 …`.
- **R3 — output scan**: the frozen trial run unpatched (`bash
  …/controls/fixtures/ref/corpus/openbao-kv-versions-trial.sh --work $S/frozen-work`) → rc `0`, last
  line `OPENBAO_KV_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, stdout 6 lines, **stderr 0
  bytes**, no leftover dir under `--work`; token/nonce ERE hits stdout `0`, stderr `0`. (An
  instrumented run's stderr carried one `cp: cannot stat` line from my keep-scratch hook, not from
  the trial.)
- **R4 — kept trial scratch after a normal run**: `$S/afterD` is `700`, contains `err` (`600`, 37 B,
  text `No value found at secret/metadata/t5`) and an empty `home/`; 0 secret-shaped hits.
- **R5 — trial SIGKILL**: server pid recorded, trial shell `kill -9`; after 1.5 s `server_survived=0`;
  leftover `openbao-kv-trial.sluE3I` (`700`) with `err` (`600`, 120 B,
  `Get "http://127.0.0.1:33795/v1/sys/internal/ui/mounts/secret/t2": … connection refused`) and empty
  `home/`; 0 secret-shaped hits.
- **R6 — C1 counter SIGKILL** (8 s in, `kill -9`): leftover `c1-counter.rj4xzA` (`700`) with 6 `644`
  log files; 0 secret-shaped hits in logs; `leftover_D=0` (the orphaned trial finished and cleaned its
  own `$D`); the orphaned dev server did not survive (`orphan_server_survived=0`); counter pid reaped.
- **R7 — instrumented C1 counter, full run** (`HYAKU_SCRATCH=$S/scr R52_KEEP_W=1 bash $S/lane/plans/round-52-c1-instr.sh --tree $S/tree-ref`),
  rc `0`: `C1_OPENBAO_KV: value=0 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=31,real2=31) src=0 real_rc=0 none_rc=2`
  with `T1..T5:real=HOLDS/HOLDS,shimvec=BHHHH/HBHHH/HHBHH/HHHBH/HHHHB,entry=1,ok=1`.
  (`src=0` is my reduced `--tree` fixture lacking `corpus/SOURCES.md`, not a lane result; every other
  component is 1 and the trial itself is HOLDS in both real runs.)
- **R8 — kept C1 scratch**: `W` `700`; `log/` `755`, 16 files `644`; `run/*/bin/.argv` 217 lines;
  `secret_hits_logs=0`, `secret_hits_argv=0`, `v_eq_dash_in_argv=77`, `value_like_in_argv=0`;
  no files in any run `home/`; no `openbao-kv-trial.*` left under `run/`.
- **R9 — C2 counter, normal run on the lane clone** (`--tree $S/lane`), rc `0`:
  `C2_REWRAP_STATEMENTS: value=2 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292 corpus/lessons/round-51.md:22]`
  — the probe works and reproduces BASE 2; sampler saw the probe server with `argvtok=0`.
- **R10 — C2 port-race decoy** (`R52PROBE_PORT=33951`, decoy listener bound first, `ss` showed
  `users:(("python3",pid=3566559,fd=3))` on the port): decoy log
  `GET /v1/sys/seal-status token_header=1 token_shape_r52p=1`,
  `GET /v1/sys/leader token_header=1 token_shape_r52p=1`,
  `PUT /v1/sys/wrapping/wrap token_header=1 token_shape_r52p=1`; counter rc `2`, output
  `C2_REWRAP_STATEMENTS: SETUP reason=probe-failed(helper= kv=)`. The real server could not bind
  (the decoy held the port), so the token that crossed the boundary was inert — but it did cross, and
  the probe passed its unauthenticated status loop before failing. (A second variant with a decoy also
  showed `cli_rc=0` for the CLI against the decoy, i.e. the client accepts a foreign server.)
- **R11 — same-uid non-descendant environ read**: double-forked python process (pid 3885036, `ppid=1487`;
  my shell pid 1589058, so not a descendant), `stat` → `environ_mode=400 owner=vgpnk`,
  `dummy_var_readable=1`, read error 0 B. So mode 400 protects other uids, not same-uid. The same
  sampler also read a `bao server` it did not start (pid 2714164, `-dev-listen-address=…:0`):
  `environ_mode=400 env_token_present=1` — the exposure is cross-process/cross-seat in practice.
- **R12 — `ss` cannot false-accept a foreign socket**: root-owned listeners on 5355 and 631 give
  `pid_tokens=0` in `ss -Hltnp "sport = :$p"`; our own server gives `pid=<pid>,` (R1). The trial's
  `grep -q "pid=$SRV,"` therefore fails closed.
- **R13 — `VAULT_*` fallback**: against a real dev server with the token in env,
  `env -i VAULT_ADDR=… VAULT_TOKEN=$root bao token lookup` → shell rc `0` (the printed
  `vault_token_honored=0` is bao's success code), and with `BAO_TOKEN=<bogus>` + `VAULT_TOKEN=$root`
  → rc `0` (`bao_token_precedence_ok=0`: BAO_TOKEN wins); `$HOME` empty afterwards (no token file).
- **R14 — C2 counter SIGKILL**: `c2_orphan_server_survived=0`; leftover `c2-counter.Ne4ZZ8` `700`
  with `base/` and an empty `home/`.

## Notes, ceilings, non-findings

- The C1 counter's *measured* runs use `env -i HOME=… PATH=… TMPDIR=…` (`c1:120-121`) and the trial
  additionally unsets inherited `BAO_*`/`VAULT_*` (`trial:61`), so no caller credential can enter the
  measured path. C2's **clients** lack the same scrub (F4).
- The C1 `EXPECT_VEC` shim behaviour and the trial's five verdicts are outside this seat's axes
  (operability/calibration are other seats'): the run above is cited only as the vehicle that exercised
  the secret paths, and it happened to be fully discriminating.
- C2's `base/` archive legitimately contains tracked historical files with token-shaped sample text
  (`base/.ufo/waves/round-26/*tokens.html`, 39 files). Any future scratch scan must exclude `base/`;
  this is not a live secret (R9/F3).
- Wrapping tokens in the C2 probe are single-use and die with the server; they are never on argv and
  never printed (N5). The KV value written by the probe is the constant `r52probe` (not a secret).
- No tool was installed or upgraded for this seat.

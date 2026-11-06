# K49Sentinel — refusal-boundary and host-safety audit (kagi round 49, attempt 1)

- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`), BASE `89afe91878f10805921d3caa67d28d21b33226da`.
- Scope: the C1 reference trial `.ufo/waves/round-49/controls/fixtures/openbao-token-trial.ref.sh`, `plans/round-49-c1.sh`, `plans/round-49-c2.sh`, `plans/round-49-controls.sh`, the committed round-49 files and the pre-freeze controls receipt.
- Scratch: `/fast/scratch/hyaku/kagi-r49/K49Sentinel` (removed at exit). Receipts copied to `.ufo/waves/round-49/build/K49Sentinel-*`.
- No tool was installed or upgraded. No secret value appears in this report: token evidence is counts and format labels only. The dev root token shape is written as the pattern `r49-[0-9a-f]{24}`, never a value.

## Method

1. One run of the frozen reference fixture (no strace), copied byte-for-byte to scratch, `--work` in scratch, real `HOME` left in place so a stray `~/.vault-token` write would be visible. A 50 ms `/proc` poller walked the trial's descendants for argv, environ and `ss -ltnp` evidence; post-exit it re-checked every PID it had seen. Receipt: `K49Sentinel-obs.log`, `K49Sentinel-trial.out`, `K49Sentinel-trial.err`, `K49Sentinel-listen.txt`.
2. Static read of `run()`, `mkshim()`, `verdict()`, `entry_line()` and the NOSECRET block in `plans/round-49-c1.sh`; read of `plans/round-49-c2.sh` and `plans/round-49-controls.sh`.
3. Three throwaway probes (each its own `bao server -dev` on a random `127.0.0.1` port, killed by its own trap): token-shape/argv (`K49Sentinel-probe.out`), remediation forms (`K49Sentinel-rem.out`), ERE detection rate over 30 service + 30 batch tokens (`K49Sentinel-rate.out`), plus one env-isolation/signal test.
4. Counts-only scans of the committed round-49 files and the controls receipt.

## Findings

### S-01 — PASS — no token, root token or password reaches the trial's stdout/stderr

Command (observation harness, one run):

```
$ bash observe.sh
TRIAL rc=0
TRIAL last=OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2
OUT-EQ-ERE=0  ERR-EQ-ERE=0  OUT-r49=0  ERR-r49=0  OUT-hvs=0
OUTLINES=6  ERRLINES=0
OUT_PEM=0  ERR_PEM=0  OUT_CERT=0
```

ERE = `(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}|r49-[0-9a-f]{24}|password=[0-9a-f]{32}` (the counter's NOSECRET ERE); `r49-` is the literal dev-root prefix. stdout is exactly the five `TRIAL` lines plus the final `OPENBAO_TRIAL:` line; stderr is empty; no PEM block. The five tests all report `HOLDS` on the pinned binary.

### S-02 — LOW (open) — the dev root token and the userpass password sit in world-readable argv

Commands:

```
during-run /proc/<pid>/cmdline poll of the trial's descendants:
MAX argv-elements-with-r49-token=1     argv-elements-with-password32=0   (50 ms window)
targeted 2 ms poll of the `bao write … password=` client:
PASSWORD_ARGV_OBSERVED=1
```

The server is started as `bao server -dev -dev-root-token-id="$ROOT" …`, so the root token is one argv element of the server process for the whole ~19 s run. `bao write auth/userpass/users/trial password="$PW"` and `bao login … password="$PW"` put the 32-hex password in a client's argv; `bao token revoke "$t"` (T3) and `bao token revoke "$p"` (T4) put child tokens there by construction (not caught by the 50 ms poll; sub-50 ms lifetime).

Impact: `/proc/<pid>/cmdline` is world-readable and `ps` shows argv to every local user, so a different local account can read a token that grants root on the dev server and the userpass password. Both are random, loopback-only, in-memory, and die with the server; nothing is printed, written outside scratch, or reused. This is a same-host exposure of throwaway material, not a live credential.

Smallest remediation (verified in `K49Sentinel-rem.out`):

```
BAO_DEV_ROOT_TOKEN_ID=<env> : ENVVAR_MODE_SERVER_ARGV_r49=0  ENVVAR_MODE_SERVER_ENVIRON_r49=1
bao write … password=-  (password on stdin): pw_stdin_write_rc=0, user_present=True policies=['default']
bao login … (password on stdin): rc=2 "file descriptor 0 is not a terminal"  → ceiling C-1
```

`BAO_DEV_ROOT_TOKEN_ID` moves the root token from world-readable argv to owner-only environ (`/proc/<pid>/environ` is 0400); `password=-` does the same for the userpass write. The login password cannot follow without leaving the `bao` CLI (the plan's named ceiling forbids curl).

### S-03 — LOW (open) — the NOSECRET ERE misses about one in five real batch tokens

Command (`K49Sentinel-rate.out`):

```
$ bash rate.sh
SERVICE_ERE_HITS=30/30
BATCH_ERE_HITS=24/30
BATCH_NO_20ALNUM_RUN_AFTER_PREFIX=6/30
BATCH_LEN_MIN=164 BATCH_LEN_MAX=164
```

Two earlier single samples of the same command disagreed — `ERE_ON_BATCH=1` then `ERE_ON_BATCH=0` — which is the nondeterminism, not a flake in the probe. Service tokens are `s.` + 24 alphanumerics (`SERVICE_LEN=26`) and match 30/30. Batch tokens are `b.` + 164 chars of URL-safe base64; 6/30 carry a `-` or `_` inside the first 20 characters after the prefix, so the ERE's `[A-Za-z0-9]{20,}` run fails and the token is not detected.

Impact: a candidate trial that prints a batch token (T3 creates one every run) evades the frozen NOSECRET gate in 6/30 samples; the control that exercises this path (k1-f7) prints a *service* token, so the controls never see it. The reference trial prints no token (S-01), so this is a gate-completeness defect, not an observed leak. Instruments are frozen: route to the next round.

Smallest remediation (next round): widen the token alternative to the URL-safe alphabet, e.g. `(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9_-]{20,}`; or match the batch shape `(^|[^A-Za-z0-9])b\.[A-Za-z0-9_-]{20,}` explicitly.

### S-04 — PASS — the dev server binds loopback only

Command: `ss -ltnpH | grep -F "pid=<server>,"` during the run (`K49Sentinel-listen.txt`):

```
LISTEN pid=2390383 addr=127.0.0.1:49969,127.0.0.1:49970
LISTEN pid=2390383 addr=127.0.0.1:49970
```

Two sockets, both `127.0.0.1` (the API port P and the dev-mode cluster port P+1); 0 non-loopback addresses. The trial picks P from a throwaway `bind(("127.0.0.1",0))`, so no fixed port is used.

### S-05 — PASS — no process or scratch file survives the trial

Commands and counts (post-exit):

```
kill -0 over every descendant PID seen: 0 SURVIVOR lines
ls -A <--work>: 0 entries
pgrep -u 1000 -x bao, ppid==1: 0 orphans
stat ~/.vault-token before/after: ENOENT both (rc=1)
find $HOME -maxdepth 1 -newermt '-15 minutes': 0 entries
```

The host `~/.vault-token`, `~/.bao` and `~/.config/bao` do not exist before or after (stat only; contents never read). No file outside the trial's scratch/HOME changed.

### S-06 — PASS — a caller's BAO_TOKEN/VAULT_TOKEN cannot reach the trial

Commands:

```
$ BAO_TOKEN=canary-not-a-token VAULT_TOKEN=canary2 env -i HOME=… PATH=/usr/bin:/bin bash -c 'printf …'
BAO_TOKEN=UNSET VAULT_TOKEN=UNSET
$ <trial's unset loop, verbatim>
BAO_LEFT=0 VAULT_LEFT=0
```

`run()` in the counter is `env -i HOME=… PATH=… TMPDIR=… LANG=C timeout 600 bash "$TRIAL" --work …` — no `BAO_*`/`VAULT_*` is passed, so the counter clears the caller's environment before the trial's own unset loop even runs. Double protection, both observed.

### S-07 — PASS — the root token is at rest only in 0700/0600 scratch and is deleted at exit

Commands:

```
mid-run: SERVERLOG dir=700 file=600 r49lines=1     (the dev server's own log)
after exit: AFTER-WORK 0 entries
timeout 1 bash -c 'trap "echo EXITTRAP-RAN" EXIT; sleep 30'  → EXITTRAP-RAN, rc=124
background child under timeout: BG-KILLED
```

The dev server writes its root token to `$D/server.log` (mode 600 inside a 700 dir) — at rest in scratch for the run only. On TERM, bash runs the EXIT trap (observed), so `cleanup` kills the server and `rm -rf`s `$D`; under the counter, `timeout` kills the whole process group and the counter's own `rm -rf "$W"` is a second net. The only persistence path left is SIGKILL of both the trial and the counter.

### S-08 — PASS — committed round-49 files carry no token-shaped string

Command:

```
$ grep -rEc '(^|[^A-Za-z0-9])(s|b|r)\.[A-Za-z0-9]{20,}|r49-[0-9a-f]{24}' plans/round-49* .ufo/waves/round-49/controls
plans/round-49-c1.sh:0  plans/round-49-c2.sh:0  plans/round-49-controls.sh:0  plans/round-49.md:0
controls/c1-base.txt:0  c2-base.txt:0  census-start.txt:0  controls-prefreeze.txt:0
fixtures/entry-measured.ref.md:0  fixtures/openbao-token-trial.ref.sh:0
instrument-sha256.txt:0  tool-install.txt:0
rc=1 (no match)      hv[sb]\.[A-Za-z0-9]{20,} scan: 0
```

### S-09 — INFO — shim and counter leak paths

Read of `run()`/`mkshim()` plus the k1-f7 receipt line (`nosecret=0`). The counter prints only fixed setup strings and verdict details; the shims are static text written to `$W/bin/<sh>/bao` (0755) inside a 0700 `$W`; SH1/SH2/SH3/SH5 pass argv through, SH4 prints a created token only into the trial's command substitution (captured, never printed). A shim that printed `$BAO_TOKEN` or a created service token would land in `$W/sh*.out`, which NOSECRET greps — the root token matches `r49-` and service tokens match 30/30. No undetected shim/counter leak path under the pinned binary. Ceilings: NOSECRET does not scan `$W/tmp` (where `server.log` always holds the root token) and does not know PEM key material.

### S-10 — INFO — instrument integrity and C2 code-execution surface

Commands:

```
sha256sum over the 6 frozen instruments vs controls/instrument-sha256.txt  → 6/6 MATCH
git show BASE:<path> | sha256sum for self-counts.py, claim-ledger.sh, self-counts.tsv, stamps.tsv → 4/4 MATCH
```

`plans/round-49-c2.sh` executes only BASE-pinned code: G1 pins `corpus/self-counts.py` and `corpus/claim-ledger.sh` byte-identical to BASE before `python3 corpus/self-counts.py` runs, so a candidate cannot inject code into the measured scripts. No vault, token or secret is touched by C2.

### S-11 — INFO (self-inflicted, closed) — two inline probe servers outlived their command

Sequence (evidence, not inference): two throwaway servers started by *inline* probe commands
(`dbg.*`, `dbg2.*`) were not reaped. Those commands ran in the tool's temporary shell; a shell
terminated before its EXIT trap runs leaves the background child alive, and my later `rm -rf` of the
scratch root is what turned their log path into a deleted inode. Peer `K49ExecTrial` observed PIDs
3226413 and 3338286 alive at ~18:40 through `/proc/<pid>/fd/2`; both were gone by ~18:47, and my
check then read `kill -0` → gone for both and 0 `bao` processes (uid 1000) with an fd 2 under my
scratch path.

The frozen trial's own cleanup is not affected. Command (receipt `K49Sentinel-term.out`): a ready
`bao server -dev` started with `BAO_DEV_ROOT_TOKEN_ID`, random loopback port, then `kill -TERM`.

```
$ bash <term test>
ready=1 kill_rc=0 term_verdict=DIED_ZOMBIE_400ms
```

It dies within 400 ms, so `kill "$SRV"; wait` in the trial's `cleanup` reaps it; the observation run
had 0 survivors; the counter's `timeout` also kills the whole process group. Lesson for harnesses
(including mine): a script file run as `bash x.sh` exits normally and runs its trap, while an inline
`&` + `trap … EXIT` in a temporary shell may not; a post-run liveness check must read
`/proc/<pid>/stat` state, because `kill -0` succeeds on a zombie.

## Named ceilings (recorded, not defects)

- **C-1** `bao login` refuses a non-tty stdin (`rc=2`, "file descriptor 0 is not a terminal"), so the T4 login password stays in argv unless the trial leaves the CLI — which the plan's named ceiling forbids.
- **C-2** NOSECRET is format-bound: 6/30 batch tokens evade it (S-03); `hvs.`/`hvb.` shapes never match (0/0 synthetic); no PEM shape; no `$W/tmp` scan.
- **C-3** `cleanup` has no kill-after and `wait` could block if the server ignored TERM; the counter's `timeout 600` bounds it and kills the group (observed).
- **C-4** `run()` shares `$W/home` across the six runs; a mutant that omits `-no-store` could persist a token there for a later run (scratch-only, no host exposure).
- **C-5** two listeners (P and P+1), both loopback; only P is advertised by the trial.

## Cleanup

The frozen trial's run left 0 survivor PIDs and an empty `--work` (S-05). Two of my *probe* servers
outlived their inline command and were reported by a peer; both were confirmed gone and the final
check finds 0 `bao` processes with an fd 2 under my scratch path (S-11). No host sysctl, service,
user, package or kernel setting was touched; no package manager command was run; no tool was
installed or upgraded. Scratch receipts were copied to `.ufo/waves/round-49/build/K49Sentinel-*`
and the scratch tree was removed.

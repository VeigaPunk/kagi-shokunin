# R59SentinelTrial — security audit: the round-59 transit trial and the round's artifacts

Seat: R59SentinelTrial (attack share, round 59 wave 1). Date: 2026-11-07.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`,
frozen predeclaration `plans/round-59.md` @ `af7b6651`.
Audit subject bytes (sha256): trial `e11e98f6cfc924131a52713fa496481e80efb89ffcdb9b6bc47b3234d8cc3e01`;
C2 counter `454a4177dcb6ae2dedd367b9409358b45a25fbac0692b5c3c05510d1ac6c525c`;
controls battery `0d8647a0b6cce42a287e6f3faf074a0524b8b1c10273045a401790d9abb7fa96`;
bao `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (OpenBao v2.7.2).
The L1 had not committed at audit time (HEAD `af7b6651`); this audit covers the working-tree artifacts the L1
will commit. If a committed byte differs from a hash above, re-check that file against this document.

Method: read-only on the lane. Every dynamic probe ran in
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59SentinelTrial/` (deleted before yield); the receipts beside
this file reproduce the command and the raw output. The wave was in flight during the audit: other seats' `bao`
servers appear in host-wide `pgrep` and are attributed by parent pid, never by name alone.

| # | check | key command | raw result | verdict |
|---|---|---|---|---|
| 1 | secret shapes in every `.ufo/waves/round-59/` file and the trial | `grep -rlaE '<shape>' …` | `hv=0 PEM=0 token-assign=0`; `r59-hex=1` (a deliberate synthetic mutation fixture, see below) | **CLEAN** |
| 2 | fetch receipts carry no cookie value (QM72) | `grep -inE '^(set-)?cookie:' capture/*.headers` | no match (exit 1); removal note in both files | **CLEAN** |
| 3 | no secret/plaintext on any argv | `strace -f -e trace=execve` + PATH-wrapper log | 3103 execve lines, 42 bao invocations: 0 token/plaintext/ciphertext/context shapes | **CLEAN** |
| 4 | server confinement | `setpriv --pdeathsig KILL` + `-dev-listen-address=127.0.0.1`; `ss`; SIGKILL probe | server ppid = trial shell; 127.0.0.1 listeners only; after `kill -9`: `ORPHAN=no` | **CLEAN** |
| 5 | ambient `BAO_*`/`VAULT_*` cannot change a reading | counter legs under `env -i`; hostile-env runs | counter `value=5 … guard=1` (hostile) rc 0; trial output byte-identical to clean | **CLEAN** |
| 6 | scratch confinement | `strace` write-mode fileops; tree manifests | 0 write-mode opens under the lane, 37 under `--work`; tree and counter `--tree` manifests unchanged | **CLEAN** |
| 7 | no key material on disk | cleanup-disabled probe of the trial's per-run dir | one 178-B `err` file (400 text), mode 600 in a 700 dir; 0 secret/key shapes | **CLEAN** |

Findings: **none**. Ceilings/observations that do not change a verdict are listed at the end.

---

## Check 1 — Secret shapes

```
$ find .ufo/waves/round-59 -type f | wc -l
104
$ grep -rlaE 'hv[sb]\.[A-Za-z0-9_-]{16,}'            .ufo/waves/round-59 corpus/openbao-transit-trial.sh plans/round-59* | wc -l
0
$ grep -rlaE 'r59-[0-9a-f]{24}'                      .ufo/waves/round-59 corpus/openbao-transit-trial.sh plans/round-59* | wc -l
1        # .ufo/waves/round-59/build/R59ReviewerCounters/mkc2.sh — synthetic mutation fixture, see below
$ grep -rlaE '-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----' .ufo/waves/round-59 corpus/openbao-transit-trial.sh plans/round-59* | wc -l
0
$ grep -rlaE '(BAO|VAULT)_(TOKEN|DEV_ROOT_TOKEN_ID)[=:][[:space:]]*[A-Za-z0-9._/-]{12,}' .ufo/waves/round-59 corpus/openbao-transit-trial.sh plans/round-59* | wc -l
0
```

Raw evidence: `build/R59SentinelTrial/scan-secrets.txt` and `final-scan.txt`.

- The single `r59-`+24-hex hit is not a secret: `R59ReviewerCounters/mkc2.sh:31` injects a **deliberate mutation
  fixture** into a mutant stub under the reviewer's own scratch — a sequential 24-hex placeholder (the hex
  digits 0-9a-f in order), labelled "A7: an r59- + 24-hex nonce in output (secret scan must bite)". It is a
  synthetic test string, not a captured dev-server root token and not the trial's per-run marker (which is
  random); the counter's K3 scan is supposed to reject it.
- The trial's per-run marker is `r59-` + 24 random hex (`nonce()`), and its dev root token has the same shape;
  neither occurs in any captured output, receipt or note (the executor's nine receipts and `notes.md` included),
  and no random nonce shape occurs anywhere else in the tree.
- `X-Vault-Token:` occurs 94 times in the fetched documentation bodies, every one the literal placeholder
  `X-Vault-Token: ...` from the page's curl examples — no value.
- The only `r59-probe-plaintext` occurrences are the revenger's declared non-secret fixture (`probe.sh`,
  `probe.md`); they are not the trial's marker and not a credential (see C6).
- Verdict: **CLEAN**.

## Check 2 — Fetch receipts (QM72)

```
$ grep -inE '^(set-)?cookie:' .ufo/waves/round-59/capture/*.headers
(no output; exit 1)
$ grep -c 'Set-Cookie/Cookie lines removed' .ufo/waves/round-59/capture/*.headers
S121.headers:1
S122.headers:1
```

Raw evidence: `build/R59SentinelTrial/fetch-headers.txt`. Both header files carry the one-line QM72 removal note
(`Set-Cookie/Cookie lines removed: 0; none were present in this response`) and replace the server-issued
`x-github-request-id` / `x-fastly-request-id` correlation ids with placeholders. Body integrity matches the
headers' `content-length`: S121 48604 B `d8879a2a…`, S122 267984 B `ad1a47d3…`. No `__cf_bm`, `cookie=` or
`session=` string occurs in the capture directory. Verdict: **CLEAN**.

## Check 3 — argv hygiene

Static (trial):

```
$ grep -nE 'curl|(^| )-d ' corpus/openbao-transit-trial.sh
79:D=$(mktemp -d "$BASE/openbao-transit-trial.XXXXXX") ...     # mktemp -d
200:      dpt=$(printf '%s' "$d64" | base64 -d 2>/dev/null)    # base64 -d
$ grep -nE '(plaintext|ciphertext|context|token|password|secret)=' corpus/openbao-transit-trial.sh
(no output)
```

Every data-bearing call uses the stdin form: `bao write -format=json transit/encrypt/<k> -`, `decrypt/… -`,
`rewrap/… -`, with the JSON body (`plaintext`/`ciphertext`/`context`) on stdin (`mkbody`, `decj`, `rewrapj`,
lines 149–162). The only values on argv are non-secret flags/state: `derived=true
convergent_encryption=true`, `min_decryption_version=1|2`, key/endpoint names.

Dynamic (non-author, full real run under `env -i`):

```
$ strace -f -qq -e trace=execve -o execve.log bash corpus/openbao-transit-trial.sh --work <scratch>
$ wc -l execve.log
3103
argv_entries_with_r59_nonce=0
argv_entries_with_plaintext_eq=0
argv_entries_with_ciphertext_eq=0
argv_entries_with_context_eq=0
argv_entries_with_hv_token=0
$ (PATH-first delegating wrapper log) wrapper_lines=42 wrapper_secret_shape_hits=0
```

Observed argv shapes all end in `[-]` for data calls, e.g.
`[write][-format=json][transit/encrypt/r59-t1][-]`. The token reaches the server only through
`BAO_DEV_ROOT_TOKEN_ID` and the client only through `BAO_TOKEN` (shell/env assignments at lines 106, 116, 308,
310, 312, 321) — the execve trace confirms these names are not argv entries. Raw evidence:
`build/R59SentinelTrial/argv-hygiene.txt`. Verdict: **CLEAN**.

## Check 4 — Server confinement

Static:

```
$ grep -nE 'setpriv|dev-listen-address|dev-no-store-token|127\.0\.0\.1' corpus/openbao-transit-trial.sh
106:    BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL bao server -dev \
107:      -dev-listen-address="127.0.0.1:$port" -dev-no-store-token >/dev/null 2>&1 &
```

The trial also refuses a port not held by its own server pid (`ss -Hltnp "sport = :$port" | grep "pid=$SRV,"`).

Dynamic (SIGKILL of the trial shell, fresh run):

```
trial_shell_pid=3548955
server_pid=3550953 server_ppid=3548955 trial_pid=3548955
listeners held by this server pid only:
LISTEN 0 4096 127.0.0.1:43395 0.0.0.0:* users:(("bao",pid=3550953,fd=3))
SIGKILL 3548955
ORPHAN=no 3550953 gone
pgrep -af 'bao server' (host-wide; other seats run their own trials):
3530880 bao server … ppid=3528443 parent=bash /fast/scratch/…/R59ReviewerCounters/ref/corpus/openbao-transit-trial.sh
3538878 bao server … ppid=3537354 parent=bash /fast/scratch/…/R59ReviewerCounters/ref/corpus/openbao-transit-trial.sh
3551318 bao server … ppid=3550319 parent=bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/openbao-transit-trial.sh
work dir files after kill: (none)
```

A second probe killed the trial 2.5 s into a run: `ORPHANS=0`, no leftover files. Every listener observed belongs
to `127.0.0.1` (the dev server's two sockets, e.g. `127.0.0.1:57815`/`:57816`). The host-wide processes above are
live runs by sibling seats (`ppid` names their trial shells), not orphans of my probe. Raw evidence:
`build/R59SentinelTrial/confinement-runtime.txt`. Verdict: **CLEAN**.

## Check 5 — Ambient environment

```
$ grep -n 'env -i' plans/round-59-c2.sh
52:# … each leg runs under `env -i`.
117:  env -i HOME="$d/home" PATH="$d/bin:/usr/bin:/bin" TMPDIR="$d/tmp" LANG=C \
```

The counter's `run()` launcher (line 117) wraps every leg — real, real2, none, sh1..sh5 — in `env -i`; the trial
additionally unsets every ambient `BAO_*`/`VAULT_*` before its first `bao` call
(`corpus/openbao-transit-trial.sh:95`). Behavioural probe:

```
$ BAO_TOKEN=<bogus> BAO_ADDR=http://127.0.0.1:9 VAULT_TOKEN=<bogus> VAULT_ADDR=http://127.0.0.1:9 \
    HYAKU_SCRATCH=<scratch> bash plans/round-59-c2.sh --tree <tree with trial e11e98f6>
C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)
counter_rc=0
$ BAO_TOKEN=<bogus> … BAO_DEV_ROOT_TOKEN_ID=<bogus> bash corpus/openbao-transit-trial.sh --work <scratch>
trial_rc=0; cmp with the clean env -i run: IDENTICAL; work-dir leftovers: 0
```

An earlier run used a synthetic `hvs.`-shaped ambient value (not recorded, per secret discipline) and also read
`value=5`. The final pre-freeze control `C2-F8` is discriminating as landed (`plans/round-59-controls.sh:178-180`):
it copies the reference tree and requires the counter to read exactly `5` while `BAO_TOKEN`/`BAO_ADDR`/
`VAULT_ADDR` are exported — a leak that broke the reading would read `<5` and MISMATCH. Raw evidence:
`build/R59SentinelTrial/ambient-env.txt`. Verdict: **CLEAN**.

## Check 6 — Scratch confinement

```
$ strace -f -qq -e trace=openat,openat2,creat,unlink,unlinkat,rename,renameat … (cwd = lane root)
write_mode_opens_under_lane=0
write_mode_opens_under_work=37
write targets outside --work (dir summary):
     53 /dev/null
      1 /dev/tty        # readline tty probe, O_RDWR, ENXIO — not a write
$ (copied-tree run; trial cwd = tree, --work outside it)
TREE-MANIFEST-UNCHANGED=yes   files_newer_than_stamp=0
$ (counter --tree run)
COUNTER-TREE-MANIFEST-UNCHANGED=yes
```

The trial's default work base is `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecTrial/trial-work`
(line 77), never a measured tree; the counter passes `--work` under its own `${HYAKU_SCRATCH}` scratch and
removes its `SCR` on exit (trap, line 82). Post-run scratch held only empty parent directories. My lane `git
status` was not modified by any sentinel run; the lane's uncommitted entries are the wave's own artifacts (written
by their owners while the wave ran). Raw evidence: `build/R59SentinelTrial/scratch-confinement.txt`. Verdict:
**CLEAN**.

## Check 7 — Key material

Static: the trial calls no transit key export/import and no `sys/` or `operator` endpoint; its only key reads are
metadata (`latest_version`, `min_decryption_version`); the dev server runs with `-dev-no-store-token` and
in-memory storage. Dynamic: a copy with **only** `trap 'cleanup' EXIT` disabled (diff shows exactly that one
line) preserved the trial's per-run directory:

```
700 …/openbao-transit-trial.hz92kf
600 …/openbao-transit-trial.hz92kf/err       178 B
700 …/openbao-transit-trial.hz92kf/home
file inventory: one file (`err`)
content: error text only — "Code: 400. Errors: * encryption key not found"
scan of $D and HOME: r59-hex=0 hv-token=0 PEM=0; no key/token filenames
```

The executor's receipts carry booleans, pids, ports, lengths and error texts; no ciphertext value, plaintext,
context or key material (`grep 'vault:v[0-9]+:' build/R59ExecTrial/receipt-*.txt` → no match; only the prose
`vault:v2:` prefix in `notes.md`). Raw evidence: `build/R59SentinelTrial/key-material.txt`. Verdict: **CLEAN**.

---

## Findings

None. Every check reads CLEAN at the audited hashes.

## Ceilings and observations (no verdict change; hardening only)

- **C1 — the printed CLEANROOM line is refusal-only.** `cleanroom()` accepts any non-zero decrypt rc; it does not
  assert the error text, so the line alone cannot distinguish "own storage has no key" from another 400. The
  independence claim is carried by the two distinct server pids/ports (my non-author probe: server A pid 93106
  port 43369, server B pid 97798 port 37639, `independent_process=yes distinct_port=yes`, cross-server decrypt
  rc=2 with `* encryption key not found`) and by the executor's driver receipt. Smallest hardening: grep the
  refusal text in `cleanroom()`.
- **C2 — the counter's `value=5` is output consistency, not execution proof.** A trial that prints the contract
  keyed on `KAGI_TRANSIT_SHIM` and never executes `bao` reads 5 (measured by R59CriticClaims, Q1-C2). Execution is
  evidenced by my non-author real runs and the executor's receipts, not by the counter. This is the declared
  K2/K4 ceiling class.
- **C3 — the counter's K3 secret scan covers captured stdout/stderr only.** A trial that wrote a token to its
  (self-deleted) work dir could still read 5. The real trial was checked by the cleanup-disabled probe (check 7),
  not by the counter. Smallest hardening: scan each leg's `--work` tree before it is removed.
- **C4 — `bao` is PATH-resolved and not sha-pinned in the trial** (declared D4 / plan K2). A wrong or hostile
  `bao` on PATH receives the token/plaintext; the counter enforces the 2.7.2 sha256 (`PIN_BAO` from
  `plans/round-57-c2.sh`) and the pre-freeze control `C2-F7` measures a mismatch as SETUP. Run the trial only
  with a pinned PATH (the counter does).
- **C5 — `BAO_TOKEN` is exported, not scoped per command, after server start.** Helper processes spawned later
  (`python3` field parsers, `jfield`) inherit the token in their environment. No argv, printed-line or on-disk
  exposure results; same-uid `/proc/<pid>/environ` is the only channel. Smallest hardening: prefix each client
  call with `BAO_TOKEN=…` instead of exporting it.
- **C6 — the revenger's probe receipts record fixture plaintext on argv.** `R59LabratContext/transcript-run*.txt`
  contain `CMD bao write transit/encrypt/… plaintext=cjU5…` and `probe.md` quotes the base64 fixture. The values
  are fixed literals declared non-secret in `probe.md` ("No value is a secret"), are not the trial's marker, and
  no token appears. If the L1 commits the transcripts under one secret rule, add a one-line note in each that the
  fixture values are non-secret, or redact the `CMD` argument values.
- **C7 — counter scratch is predictable and not umask-hardened.** `SCR=${HYAKU_SCRATCH}/kagi-r59/R59ExecCounterC2/
  c2-counter.$$`, no `umask` line; observed live: dirs 755, log files 644. The logs contain only the trial's
  boolean transcript and error texts (K3 scans them), and the trial's own per-run dirs are 700/600. Smallest
  hardening: `umask 077` at the top of the counter and `mktemp -d` for `SCR`.
- **C8 — the trial's ambient scrub is uppercase-only** (`BAO_[A-Z_]*`, `VAULT_[A-Z_]*`). The bao CLI honors only
  uppercase variable names, so no reading can change; the counter's `env -i` closes the boundary regardless.
- **C9 — final control C2-F8 exports `BAO_TOKEN`/`BAO_ADDR`/`VAULT_ADDR` but not `VAULT_TOKEN`.** The trial
  scrubs it and my direct run covered it; the control's coverage is one variable short of its label.
- **C10 (LOW, operability, not a secret leak) — a nonce-shaped literal sits in a committed mutation builder.**
  `R59ReviewerCounters/mkc2.sh:31` keeps the A7 fixture as a literal `r59-`+24-hex string (sequential 0-9a-f),
  while the same file deliberately assembles its A6 token prefix at runtime (`"h""v""s""."`) to carry no
  token-shaped literal. Any whole-tree secret scan of the wave (the round-58 verifier's precedent over
  `.ufo/waves/round-58/`) will hit mkc2.sh and must adjudicate it as synthetic. Smallest fix: build the A7 nonce
  at runtime (`r59-$(od -An -N12 -tx1 /dev/urandom | tr -d ' \n')` — the counter's regex only needs the shape),
  which removes the literal from the committed tree without weakening the mutation.

## Non-author falsification attempts (all failed)

| attempt | result |
|---|---|
| secret-shape grep over every round-59 file + trial (hv token, r59 nonce, PEM, token assignment) | 0 matches |
| argv trace of a full real run (3103 execve lines) + PATH wrapper (42 bao calls) | 0 secret/plaintext argv entries |
| hostile ambient `BAO_TOKEN`/`BAO_ADDR`/`VAULT_TOKEN`/`VAULT_ADDR`/`BAO_DEV_ROOT_TOKEN_ID` | counter 5, trial output identical |
| `kill -9` the trial shell during server A and during the clean-room phase | server reaped; 0 orphans; no secret leftovers |
| read the lane tree for write-mode opens during a run | 0 under the lane; 37 under `--work` |
| preserve the per-run dir (cleanup disabled) and scan it | one error-text file; 0 key/secret material |
| cross-server decrypt on a second independent dev server | refused `* encryption key not found` |
| cookie/session scan of both fetch receipts | none; QM72 note present |

## Re-check recipe

```
# hashes
sha256sum corpus/openbao-transit-trial.sh plans/round-59-c2.sh plans/round-59-controls.sh
# check 1/2
grep -rlaE 'hv[sb]\.[A-Za-z0-9_-]{16,}|r59-[0-9a-f]{24}' .ufo/waves/round-59 corpus/openbao-transit-trial.sh
grep -inE '^(set-)?cookie:' .ufo/waves/round-59/capture/*.headers
# checks 3-7: receipts in .ufo/waves/round-59/build/R59SentinelTrial/ carry the exact commands
```

SEAT-STATUS: complete

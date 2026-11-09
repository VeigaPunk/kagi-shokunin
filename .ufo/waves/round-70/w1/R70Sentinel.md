Author: R70Sentinel (sentinel)

# Round 70, wave 1 — seat R70Sentinel (security & hygiene audit)

Claim under audit: **C1 — coverage (capability acquisition)**, `plans/round-70-c1.sh` at revision
`0d225553c22f686df24454040102d0502eda5c42`, frozen sha256
`8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed` (verified unchanged at
audit time; the committed receipt `controls/receipts/counter.sha256` carries the same value).

Scope of this seat: **security and hygiene of `corpus/openbao-pki-trial.sh` and of the frozen
counter** — not the truth of the five PKI behaviours themselves. Everything below was executed,
not read. The five assigned checks are answered in §1; the material finding is in §2.

**Tooling:** no package was installed and no tool was upgraded for this seat. Everything ran on
the host's pre-existing `bao` 2.7.2 (`~/.local/bin/bao`, sha256 `9c5f3628…bd41b788`), `openssl`
3.6.5, `python3` 3.14.8 and `git` 2.56.0. The channel/reason record required by the operator
directive is therefore empty (nothing changed).

**Base state confirmed first.** The frozen counter was run on the candidate as landed and
reproduced the prefreeze expectation exactly:

```
$ bash plans/round-70-c1.sh 0d225553c22f686df24454040102d0502eda5c42
C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1
  real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,spec=1,entry=1,ok=1 … T5:…ok=1
rc=0
```
(receipt `receipts/counter-candidate.txt`). The candidate's trial is byte-identical to the P1
positive control: sha256 `200efcb2850df8e729631de1772f4423ef0ac90a8bb1b9a06e4fc499bdc8023d` for
`corpus/openbao-pki-trial.sh` at the candidate revision, at `controls/p1/corpus/…`, and in the
worktree.

---

## 1. The five assigned checks — answered by execution

| # | check | result | receipt |
|---|---|---|---|
| 1 | no private key / root token / token-shaped string on stdout-stderr (success path, injected-failure path, SH1 exported-root path) | **PASS**, with one scope caveat (SE-3) | `receipts/probe-A-B-C.log` |
| 2 | SIGTERM and SIGINT mid-run leave no `bao server` alive and no scratch dir | **PASS** on all three signals | `receipts/probe-D-signals.log`, `receipts/probe-H-sigkill-orphan.log` |
| 3 | no hardcoded `/tmp`; `--work` and `TMPDIR` honoured | **PASS** | `receipts/probe-A-B-C.log` |
| 4 | `VAULT_*`/`BAO_*` caller variables scrubbed | **PASS** | `receipts/probe-A-B-C.log` (E2 below) |
| 5 | the port probe cannot attach to another process's server | **FAIL — see SE-1** | `receipts/probe-SE1-airtight.log` |

### 1.1 Secret containment (check 1)

**Success path.** `secret_ere_hits=0` against the counter's own NOSECRET expression
(`PRIVATE KEY|(^|[^A-Za-z0-9])(s|b|r|hvs)\.[A-Za-z0-9]{20,}|r70-[0-9a-f]{24}`). stdout is the
five `TRIAL Tn HOLDS` lines plus the final summary; stderr is empty.

**Injected-failure path.** A PATH shim whose `secrets enable` fails, prints the live
`$BAO_TOKEN` to stderr *and* prints a canary to stdout. The trial's `q()` helper redirects both
streams to `/dev/null`, so `secret_ere_hits=0`, `canary stdout=0 stderr=0`, exit 2 with
`SETUP pki-enable` on stderr. The caller's error text and the live token are both contained.

**SH1 exported-root path.** Under the counter's own SH1 shim (`root/generate/internal` →
`…/exported`) the response really does carry a private key: the live-capture poller observed the
trial's own `t1.json` grow to 4923 bytes with `pem_lines=1 key_field=1`. The trial printed
`TRIAL T1 BROKEN private_key-returned` and **`secret_ere_hits=0`** — the *field name* is printed,
the key material is not. The scratch directory was removed on exit (`work dir left behind: []`),
so the key file did not survive the run. This is the correct behaviour and is what makes the
counter's F6 leg meaningful.

### 1.2 Signals (check 2)

Nine rounds, three signals × three delivery points, signalled from Python with the disposition
reset to `SIG_DFL` (a shell-launched `&` child inherits `SIG_IGN` for SIGINT and bash cannot
un-ignore an inherited-ignored signal — an earlier shell-based run of mine read rc=0 for SIGINT
and was **wrong for that reason**; the corrected measurement is the one reported here).

```
{"sig":"INT","delay":0.3,"rc":130,"trial_lines":0}   {"sig":"INT","delay":0.9,…,"rc":130}
{"sig":"TERM",…,"rc":130}                             {"sig":"HUP",…,"rc":130}
```
After every round: **0 dev servers on the host, 0 scratch dirs left.** That the dev server is
attributable to the trial at all is confirmed by the marker method in §1.2's SIGKILL paragraph
(`R70_SENTINEL_MARK` inherited by every descendant, found by scanning `/proc/*/environ`). The
cleanup itself holds because the trial installs `trap cleanup EXIT` before starting the server
and `trap 'exit 130' INT TERM HUP` alongside it, and `cleanup` kills `$SP` and `rm -rf`s the
scratch.

SIGKILL is the one path the trial cannot cover (no trap can run). Killed 2.0 s in, the scratch
survives with **4 files holding a PEM private key** and 2 files holding the dev-token shape, plus
a `home/.vault-token` file (`receipts/probe-G-kill-and-token.log`); killed 250 ms in, the
dev server **survives as an orphan** — marker-attributed, still alive 2 s later — together with a
scratch holding 2 dev-token-shaped files and the `.vault-token` file
(`receipts/probe-H-sigkill-orphan.log`). This is a real but narrow residual — SIGKILL is not in
the trial's advertised exit paths, and the counter's `timeout 600` sends TERM, not KILL.
Recorded as SE-4 (low).

### 1.3 `/tmp`, `--work`, `TMPDIR` (check 3)

The only `/tmp` occurrences in the trial are the default in `WORK="${TMPDIR:-/tmp}"` (line 39)
and its usage text. With `--work` and `TMPDIR` both pointing at scratch: caller TMPDIR 0 entries
before and after, work dir 0 entries after, 0 `/tmp/kagi-pki-trial.*` dirs. The trial creates its
scratch under `$WORK` only, and redirects `HOME`/`TMPDIR` into it. Clean.

### 1.4 `VAULT_*`/`BAO_*` scrubbing (check 4)

With `VAULT_ADDR`/`BAO_ADDR` pointed at a decoy listener on 127.0.0.1:19999, plus
`VAULT_TOKEN`/`BAO_TOKEN`/`VAULT_NAMESPACE`/`VAULT_CACERT` set to caller values: the trial
reported HOLDS×5 (it talked to its own server) and **the decoy received 0 connections**; the
caller's token value appeared 0 times in stdout and 0 times in stderr. The trial's
`unset` loop (line 59) runs before the server is started, and the counter additionally runs the
trial under `env -i` (line 100), so the counter path is doubly isolated.

### 1.5 The port probe (check 5) — **FAILS**

See §2. The probe is a *connect* probe, and a socket that is **bound but not listening** refuses
the connection, so the probe reads it as "free". The trial then starts its own `bao server -dev`
on that port, which fails to bind, and the trial — which never verifies that the server answering
on `127.0.0.1:$PORT` is the one it started — talks to whatever else is there.

---

## 2. SE-1 — the frozen counter accepts a substituted server (severity: high)

### Exploit path

1. The trial picks a port from 20000–29999 by *connecting* to it
   (`corpus/openbao-pki-trial.sh:72`):
   `(exec 3<>"/dev/tcp/127.0.0.1/$p") 2>/dev/null || { PORT=$p; break; }`.
   The `||` fires on a **failed** connect, i.e. the probe selects a port where the connect was
   *refused*. A socket that is bound but not listening refuses connections, so **every**
   bound-not-listening port reads as "free".
2. The trial starts its own server on that port (`…:76`). The bind fails; the server dies; the
   error is written to the trial's own `server.log` and is never read by the trial or the counter.
3. The trial polls `bao status` (`…:79`) until something answers. A substituted server answers.
4. Every subsequent API call — `pki/root/generate/internal`, `pki/issue/*`, `pki/revoke`,
   `pki/certs`, `pki/cert/crl` — goes to the substituted server, **each carrying the trial's dev
   root token in the `X-Vault-Token` header** (28 chars, `r70-` + 24 hex).

I built that substituted server (a ~250-line OpenBao-PKI-shaped HTTP responder that mirrors the
five shims' semantics) and ran the **frozen, unmodified** counter against a tree carrying the
**byte-identical landed trial**. Result — one airtight receipt, `receipts/probe-SE1-airtight.log`:

```
(a) the trial's OWN dev server never bound — from the trial's own server.log:
    Error initializing listener of type tcp: listen tcp 127.0.0.1:21365: bind: address already in use

(b) the substituted server answered every call, each with the trial's token:
    requests served: 137        carrying a 28-char dev token: 131
    distinct dev tokens (one per counter run): 6
    6 GET /v1/sys/seal-status      6 POST /v1/sys/mounts/pki     6 PUT /v1/pki/roles/t2 …
    5 PUT /v1/pki/root/generate/internal     1 PUT /v1/pki/root/generate/exported
    (the shim runs are visible too: 5 internal + 1 exported under sh1)

(c) the FROZEN counter's verdict on that tree:
    C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1
      real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,spec=1,entry=1,ok=1 … T5:…ok=1
    counter rc=0
```

The counter reports **value=5** while **no OpenBao PKI engine answered a single call**.

### Why the counter's own legs do not catch it

- **PINS** (line 148 area) pins the sha256 of the `bao` **client** on `PATH`. It says nothing
  about the server. The client is genuine; the responder is not.
- **NOSECRET** (line 149) scans only `$W/*.out` and `$W/*.out.err`. The substituted server
  receives the token over HTTP and never prints it, so `nosecret=1` — correctly, but for the
  wrong reason: the token *did* leave the trial, just not to stdout.
- **NOLEAK** (line 105) scans `/proc/*/environ` for the run's nonce. The substituted server is
  not a descendant of the trial and never inherited the nonce, so `noleak=1`.
- **DISCRIMINATE** sees only the trial's printed `TRIAL Tn` lines, which the substituted server
  shaped — including shaping them the way each shim requires (the substituted server answers
  `pki/root/generate/exported` with a `private_key` field, and declines to put the serial on the
  CRL until a revoke arrives), so `spec=1` for all five.

The plan declares exactly one ceiling (`plans/round-70.md:70`): *"a trial that reads the shim's
own bytes and knows each shim's body could pass the specificity leg"*. This attack is a
**different** ceiling and is not declared: the trial's *own* bytes are untouched, and the
substituted server is what shapes the verdicts.

### Impact

The counter's `value=5` is meant to certify *"the lane can execute the OpenBao PKI
certificate-lifecycle mechanics"*. As written it certifies only *"some server on 127.0.0.1
answered these calls"*. A reviewer reading `value=5 discriminating=5` has no way to tell the two
apart. The threat is not hypothetical for this lane: the lane runs the counter on a shared
multi-user host, and the substituted server needs nothing but the ability to bind TCP ports on
loopback — the same privilege the trial itself uses.

The attack needs the substituted server to be listening on the port the trial picks, which the
trial does not tell the operator and does not log in a place anyone reads. Two sub-cases:
(a) **pre-bound range** — an adversary holding 20000–29999 bound-not-listening wins every
trial run (measured: the trial picked port 21365 inside the held range and its own server failed
to bind); (b) **racing** — a same-host process that binds the port after the trial's probe
passes but before `bao server -dev` binds. Case (b) also occurs **by accident**: with N
concurrent trials on one host the chance that two pick the same port from the 10 000-port range
is ≈0.72 % for N=12 and ≈11 % for N=48 (computed), and I measured a forced same-port collision
producing exactly the fail-open shape (one run's `bao status` succeeded against the *other*
run's server).

### Smallest remediation

The trial must bind and own the port rather than probe it, and the counter must bind the
measurement to the binary that served it. Either alone is insufficient:

1. **Trial:** replace the connect-probe with a bind-and-hold (open the listener itself and hand
   the fd to `bao server -dev` via `SO_REUSEPORT`/fd inheritance, or bind a socket on
   `127.0.0.1:$PORT` and keep it until the server is confirmed up), so a port the trial cannot
   own is never used. Failing that, assert that the started server is the one answering — e.g.
   have the server publish an instance marker and check it — and **fail closed** (exit 2) when
   `bao server -dev` exits with a bind error instead of polling `bao status` on a port whose
   server may have died.
2. **Counter:** add a leg that binds the verdict to the responder, e.g. require the trial to
   report the `bao` server's own identity (pid + `BAO_ADDR` + the root token it was started
   with) and check it, or have the counter start the dev server itself and hand the trial a
   ready one. At minimum the counter should read the trial's `server.log` and fail when it
   contains `address already in use` or a non-empty `Root Token:` line that does not match the
   token the trial generated.

Note the trial already writes the bind error into `$S/server.log`; the counter simply never
reads that file. Reading it would have caught this run.

---

## 3. Remaining findings

### SE-2 — the dev root token is exposed in the process argv (severity: medium)

The trial passes the token on the command line (`…:76`
`bao server -dev -dev-root-token-id="$TOK" …`). On this host `/proc` is mounted **without**
`hidepid` (`proc /proc proc rw,nosuid,nodev,noexec,relatime`) and `/proc/<pid>/cmdline` is
mode `r--r--r--`, so **any local user on the host can read the token** for the life of the run.
Measured directly: the argv of the running dev server contained
`-dev-root-token-id=<token>` (masked in the receipt).

This is not hypothetical for the lane: the lane's own controls runner prints exactly that argv
into a committed receipt — `plans/round-70-controls.sh:18`
(`echo "reaped $p $(tr '\0' ' ' < /proc/$p/cmdline …)"`) — which is why
`controls/receipts/f5.txt` had to be hand-masked after the fact, as
`controls/receipts/README.txt` discloses. The mask is honest and the committed bytes carry no
token (verified: `grep -rE 'r70-[0-9a-f]{24}'` over the whole `.ufo/waves/round-70/` tree returns
nothing). The residual is the runner itself, which will print a live token again on every future
run. The counter's own leak record is clean by comparison — it prints only the `/proc` path, never
a cmdline (line 105).

Live confirmation (`receipts/probe-RV-reverify.log`, RV1): the running dev server's argv is
`bao server -dev -dev-root-token-id=<DEV-TOKEN-MASKED> -dev-listen-address=127.0.0.1:24726`,
`/proc/<pid>/cmdline` mode `-r--r--r--`, `/proc` mounted `rw,nosuid,nodev,noexec,relatime` (no
`hidepid`). The trial's own header (line 8) says the token *"lives only in scratch and is never
printed"*.

**Remediation:** have the runner redact `-dev-root-token-id=<…>` before writing the receipt, and
prefer an env-var or stdin-passed token over an argv flag if the binary supports it.

### SE-3 — the counter's NOSECRET leg cannot see secrets written to disk (severity: medium)

The counter scans `"$W"/*.out` and `"$W"/*.out.err` (line 149), but the trial's scratch lives
under `$W/tmp/` (line 101 passes `--work "$W/tmp"`), i.e. **below** the glob. The trial writes
real leaf private keys and the dev root token there:

- `t2.json`, `t4.json`, `t5.json`, `t5c.json` each carry a `-----BEGIN RSA PRIVATE KEY-----`
  block (the `pki/issue` response includes `private_key`) — confirmed by a live capture of the
  scratch (`receipts/probe-RV2-scratch-secrets.log`, `receipts/probe-RV-reverify.log` RV2): the
  four files `t2.json`, `t4.json`, `t5.json`, `t5c.json` are the PEM-bearing ones;
- `server.log` carries `Root Token: <DEV-TOKEN-MASKED>` and `Unseal Key:` lines, and
  `home/.vault-token` holds the token as well — the same live capture lists both files as
  dev-token-shaped.

They are removed on clean exit, so the exposure window is the run itself. But the leg that is
*named* for secret containment cannot see them. Demonstrated: a fixture tree whose trial is P1
plus one line writing a PEM private key to a file in its scratch still reads
`nosecret=1 … value=5 … rc=0` (receipt `receipts/probe-F-nosecret-blindspot.log`) — the F6
control ("trial that prints the dev root token") only proves the *stdout* path is covered.

**Remediation:** scan the whole run tree (`$W/tmp` included) for the NOSECRET expression, or
have the trial write its key-bearing responses to a directory the counter scans.

### SE-4 — SIGKILL leaves an orphan dev server and a secret-bearing scratch (severity: low)

Measured (`receipts/probe-H-sigkill-orphan.log`): after SIGKILL of the trial bash, the dev server
survives (marker-attributed, still alive 2 s later) and the scratch survives with 2 files
holding the dev-token shape and a `home/.vault-token` file. SIGKILL is outside the trial's
advertised exit paths and the counter's `timeout` sends TERM, so the practical window is narrow;
the orphan also holds the port, so it can make a *later* trial run on the same host attach to it
— the SE-1 mechanism, reached without an adversary.

**Remediation:** none required for the claim; note the residual in the lesson.

### SE-5 — the controls runner writes a live token into receipts (severity: low; disclosure present)

Covered under SE-2. `controls/receipts/README.txt` discloses the post-hoc masking and the
committed bytes are clean, so this is a **process** finding, not a leak. Flagged because the
lane's QUALITY bar requires a receipt's provenance to be derivable from the runner
(QM45/QM96); a receipt that must be hand-masked after the run is, by construction, not
byte-reproducible by re-running the committed runner.

### SE-6 — concurrent trial runs collide on the port range (severity: low; observability only)

Twelve concurrent trial runs on one host: **12 completed with HOLDS×5, 0 failed**, no dev servers
left, no scratch left (`receipts/probe-RV-reverify.log`, RV3; an earlier 8-run wave gave the same
picture — `receipts/probe-E-collision.log`). The computed collision probability (§2) is ≈0.16 % for
6 concurrent runs and ≈0.72 % for 12 — low, and the failure mode is fail-closed (`SETUP`), not a
false pass. Recorded because the wave runs many seats concurrently on one host, so a rare
spurious `SETUP` should be attributable rather than mysterious.

---

## 4. Checks that passed and are worth stating positively

- The counter is genuinely reproducible: `value=5 discriminating=5 … rc=0` on the candidate, and
  the candidate's trial is byte-identical to the P1 positive control.
- The counter's shims discriminate: on the candidate every shim breaks exactly its own test and
  no other (`spec=1` for all five), and the F1/F2/F3/F4/F5/F6 controls each fail as declared
  (prefreeze receipts, re-read this wave).
- The trial never prints key material on any path I could reach (success, injected failure, SH1),
  and never inherits a caller's `VAULT_*`/`BAO_*` values.
- Signal handling is sound on EXIT/INT/TERM/HUP: no orphan, no scratch, exit 130, confirmed
  nine ways.
- The trial honours `--work` and `TMPDIR` and leaves nothing in `/tmp`.
- The counter's own leak record prints only a `/proc` path; it never writes a cmdline.

---

## 5. Method notes / corrections

- My first SIGINT measurement (rc=0, five `TRIAL Tn` lines) was **wrong** and is not reported as
  a finding: a script launched with `&` from a non-interactive shell inherits `SIG_IGN` for
  SIGINT, and bash cannot un-ignore an inherited-ignored signal. The corrected measurement
  (Python `preexec_fn` resetting the disposition to `SIG_DFL`) is the one in §1.2. I flag this
  because the same trap could produce a false "SIGINT is not handled" claim from another seat.
- Two of my early port experiments were also wrong and were discarded before use: one bound the
  decoy with `SO_REUSEADDR` (so the trial's own server still won the port) and one flipped the
  whole 10 000-port range to listening at once (so the trial's connect-probe refused every port
  and it exited `SETUP no-free-port` — fail-closed, not an attach). Only the bound-not-listening
  configuration attaches, and that is what §2 reports.
- A sibling seat's scratch cleanup removed my scratch mid-audit. All evidence was regenerated
  with outputs written directly into this seat's wave directory, and the three claims whose
  first receipts were lost (the live argv capture, the live scratch capture, and the
  concurrency run) were re-measured from scratch — `receipts/probe-RV-reverify.log` and
  `receipts/probe-RV2-scratch-secrets.log` — so every number in this report is backed by a
  receipt that exists in the tree.

---

FINDING SE-1 falsifies-number The frozen counter reads value=5 on a tree whose byte-identical landed trial measured a substituted server, not OpenBao — the trial's connect-probe accepts bound-not-listening ports and it never checks that the server answering 127.0.0.1:$PORT is the one it started, so any local process that can bind a loopback port can shape all five verdicts and receive the trial's dev root token on every call (137 requests, 131 carrying the token, 6 distinct tokens, one per counter run).
FINDING SE-2 falsifies-wording The trial passes the dev root token as `-dev-root-token-id=` on the command line, and with /proc mounted without hidepid and /proc/<pid>/cmdline mode r--r--r-- any local user can read it for the life of the run — the lane's own controls runner prints that argv into committed receipts (controls/receipts/README.txt discloses the hand-masking), so the trial's header claim that the token "lives only in scratch and is never printed" is not true.
FINDING SE-3 falsifies-wording The counter's NOSECRET leg scans only $W/*.out{,.err} while the trial's scratch sits under $W/tmp/, where the live capture shows four files carrying a PEM private key (t2/t4/t5/t5c.json) and server.log carrying the dev root token — a fixture that spills a PEM to its scratch still reads nosecret=1 value=5 rc=0, so the leg named for secret containment cannot see the secrets it exists to catch.
FINDING SE-4 neutral SIGKILL of the trial cannot be trapped and leaves the dev server running as an orphan plus a surviving scratch holding the dev token and a home/.vault-token file — outside the trial's advertised exit paths and outside the counter's timeout signal, so it is a residual rather than a claim defect.
FINDING SE-5 neutral The controls runner writes a live dev-root token into a committed receipt and it must be hand-masked afterwards, so the committed receipt is not byte-reproducible by re-running the committed runner (QM45/QM96 provenance) — the masking is disclosed and the committed bytes carry no token, so this is a process finding rather than a leak.
FINDING SE-6 neutral Twelve concurrent trial runs on one host produced 12 HOLDS×5 and 0 failures with no orphans and no scratch left, but the computed same-port collision probability is ~0.16% for 6 and ~0.72% for 12 concurrent runs, so a rare spurious SETUP on this multi-seat host is expected and should be attributed rather than treated as a trial defect.
SEAT-STATUS: complete all five assigned checks executed against the landed candidate; one high-severity falsification of the counter's value (SE-1, substituted server yields value=5) plus five further findings; evidence in .ufo/waves/round-70/w1/R70Sentinel/receipts/

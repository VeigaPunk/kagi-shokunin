# R58SentinelTrial — adversarial security review: round-58 trial and counters

Seat: sentinel (attack surface 4/14). **Read-only**: no lane edit, no commit, no subagent
dispatch, no host service or sysctl change. Lane `kagi-shokunin`, branch `master`, claim BASE
`1b13f5dad921f8901f56d30c428f89614dd74d8a`; frozen plan `plans/round-58.md`
(sha256 `a66132e65c301d0cf7024082a0568f5e1cd1513192b4e385ebecb1e056f03a3e`, carrying the
disclosed A1/A2 amendments; the security contract — K3, the trial's secret-handling sentence and
the counter's fail-closed clauses — is unchanged by them and was not amended during my review).

Environment: Linux 7.2.11-arch1-1, bash 5.3.20(1), Python 3.14.8, git 2.56.0, OpenBao
`v2.7.2 (9e0a0d3c…)` at `$HOME/.local/bin/bao`, 181,848,661 B, sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (= the round-57 pin).
Installs/updates: none. Scratch: `/fast/scratch/hyaku/kagi-r58/R58SentinelTrial/`, deleted
before yield. Every runtime probe below was run on a throwaway in-memory `bao server -dev` on
127.0.0.1 only.

Instruments reviewed (bytes pinned at review time; the C1 checker was edited twice while I
worked, so every finding was re-proven on the final bytes listed):

| file | sha256 | bytes | mtime (-03:00) |
|---|---|---|---|
| `corpus/openbao-policy-trial.sh` | `1f1eed9d872a1a1367d737d63a45f1d8eb2c9fe6fa322d5e96a95dba934d0b4a` | 13,640 | 12:07:57 |
| `plans/round-58-c2.sh` | `8baaf3486f1390d99c67e5406655ae177b68ef89024c6a1a3b0b1f13a5dd11b0` | 7,639 | 12:06:54 |
| `plans/round-58-c1-check.py` | `94e7c3260a3383ba2b56dd112d8d3ef74e4b0a4a6d0611b7af0d022af5d8f79e` | 42,792 | 12:19:49 |
| `plans/round-58-c1.sh` | `9cfa9c89e994bc987db941db92b3344e3a532d5875a8551ac2378d75cd86f377` | 8,986 | 12:14:04 |

`plans/round-58-controls.sh` did not exist at review time, so its battery was not run by me.

## Top-level answer — can a token, cookie or value reach a committed artifact?

**No, from the trial and the C2 counter as shipped.** The trial never prints a token, a nonce
or a written value (only counts, flags and capability words), sends every value on stdin
(`v=-`), sends every token through the client environment, writes its server output to
`/dev/null`, keeps all ephemeral state in a 0700 directory it deletes, and the counter scans all
nine leg receipts for `r58-`/`hvs.`/`hvb.` and forces `value=0` on a hit (proven by injecting a
fabricated nonce: `secret=0`). A sweep of the round-58 wave (108 files at close) plus the four
instruments, the entry draft and the new epoch-C receipt found **0 credential-value shapes**.

**The one residual channel is not the trial but the C1 checker** (finding C-1): it *executes*
two scripts taken from the measured tree (`corpus/current-claims.py --selftest` and
`corpus/scope-gate.sh`) with the invoking user's full environment. A hostile `--tree` therefore
runs candidate code that can read any secret the operator has exported and write it anywhere,
including into the wave tree. That is an execution primitive, not a printing bug; it is the
same class as round-57 M-2 and is still open. With the lane's own tree (the only tree the
round's counter measures via `plans/round-58-c1.sh`, which extracts to scratch) nothing secret
is available to the child, so no token can reach an artifact by this route in the round's own
workflow.

## Checks

| # | check | verdict | evidence (raw) | fix |
|---|---|---|---|---|
| S-1 | trial: no token/value on any argv (static) | **PASS** | every client call is `BAO_TOKEN="$x" bao …` (trial:134-136, 140, 208); values are `printf '%s' "$v" \| bao kv put "$path" v=-` (114, 135); `mktoken` reads `bao token create -format=json` from stdout (122); `capsof` passes only the path (140); grep finds no `input=`, `value=`, `token=` argument and no `$BAO_TOKEN` on a command line | — |
| S-2 | trial: no token/value on any argv (dynamic, 4 ms sampling of the whole process tree) | **PASS** | counter run (8 trial legs): argv classes were `secret-assignment len=3` ×121 (the literal `v=-`) and `long-opaque len=43` ×6 (the counter's own `--tree /home/vgpnk/Projects/shokunin/kagi-shokunin`); **0** rows of `service-token-shape`, `round-nonce`, `bao-token-prefix`. Direct final run: 16 × `v=-`, 36 × 61-char `--work` path, nothing else | — |
| S-3 | trial: nonces never printed | **PASS** | stdout+stderr of every run scanned for `r58-[0-9a-f]{24}`: 0 hits (ambient, wrap, port, counter, final runs). `report` details are counts/flags; `caps=` is a capability word list (`update`, `deny`, `read update`) | — |
| S-4 | dev-server output cannot be captured by a receipt | **PASS** | trial:84-85 `setpriv --pdeathsig KILL bao server -dev … >/dev/null 2>&1 &` on both the plain and the config branch; no `tee`, no server log path in `$D` | — |
| S-5 | `setpriv --pdeathsig KILL` used; no server survives a run | **PASS** | trial:84; after all runs `pgrep -a bao` shows no live server and `ss` shows nothing on 48497/48502/48511. One `bao` entry exists as a **zombie started 2026-11-06 22:33** under a previous `omp` session (PPid 1589058); not attributable to round 58 and not reaped by that session | note only |
| S-6 | port probe cannot attach to a foreign process | **PASS** | trial:88-92 picks an ephemeral port, starts the server, then requires `ss -Hltnp "sport = :$port" \| grep -q "pid=$SRV,"`. Probe: a `python3` shim answered the port query with 48502 while a foreign listener held it ⇒ `OPENBAO_POLICY_TRIAL: SETUP dev server did not start` rc 2, foreign listener log 0 connections. Control with the same shim and a free port 48509 ⇒ `OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0` rc 0 | — |
| S-7 | trial cannot be steered by inherited `BAO_ADDR`/`BAO_TOKEN`/`VAULT_*` | **PASS** | trial:74 unsets every inherited `BAO_*`/`VAULT_*`; `env -i … BAO_ADDR=http://127.0.0.1:48511 BAO_TOKEN=<fixture> VAULT_ADDR=… VAULT_TOKEN=<fixture> bash trial` ⇒ `OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` rc 0, honeypot 48511 log **0 data rows** | — |
| S-8 | trial host footprint | **PASS** | `umask 077` (45), `D=$(mktemp -d "$BASE/openbao-policy-trial.XXXXXX")` under `--work`, `HOME="$D/home"` (75), `cleanup` kills + `rm -rf "$D"`; server binds `127.0.0.1` and `-dev-no-store-token`; no sudo, no service, no sysctl, nothing outside `--work` | — |
| S-9 | trial detail fields carry no secret | **PASS** | T1-T5 details are `empty-token-denied=`, `read-allowed=`, `value-roundtrip=`, `descendant=`, `sibling-denied=`, `caps=…` — counts, flags, capability words (see the final run below) | — |
| S-10 | C2 counter: `bao` pin is enforced | **PASS** | `PIN_BAO` read once from `plans/round-57-c2.sh` (52-54), sha256 compared at 78; `R58_BAO=/bin/true` ⇒ `C2_POLICY_TRIAL: SETUP bao-pin-mismatch` rc 2 | — |
| S-11 | C2 counter: a PATH wrapper is reachable and is the resolution path | **PASS** | wrap leg builds `$d/bin/bao` as a wrapper and runs with `PATH="$d/bin:/usr/bin:/bin"` (112); my independent wrapper (delegates all but `bao token capabilities`, which it answers `deny` rc 0) made the real trial read `HHHHB`, T5 detail `caps=deny`, rc 1 — exactly one test flips | — |
| S-12 | C2 counter: an absolute-path binary must not silently pass | **PASS** (counter bites) | trial variant whose `capsof` calls `/home/vgpnk/.local/bin/bao` directly, measured with `plans/round-58-c2.sh --tree`: `C2_POLICY_TRIAL: value=0 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 wrap=0 secret=1)` rc 1. The wrap leg sees `HHHHH` because the wrapper is bypassed, so K2's ceiling is caught, not hidden | — |
| S-13 | C2 counter: receipts cannot carry a token (K3 guard) | **PASS** | counter scans `${SCR}/log/*` (stdout and `.err`) for `r58-[0-9a-f]{24}` and `(hvs|hvb)\.` (142). A copy of the trial that prints a fabricated 28-char `r58-`+24-hex nonce to stderr reads `C2_POLICY_TRIAL: value=0 … pass=5 shims=5 … (real=1 none=1 wrap=1 secret=0)` rc 1 — the guard alone forces 0 | add `s\.[A-Za-z0-9]{20,}` to the pattern (C-6) |
| S-14 | C2 counter: ambient env cannot reach the trial | **PASS** | each leg is `env -i HOME=… PATH=… TMPDIR=… LANG=C KAGI_POLICY_SHIM=…` (112); the executor's ambient-env stub receipt reads `value=5`, and my hostile-ambient direct run (S-7) shows the trial's own unset is the second line of defence | — |
| S-15 | C2 counter: host safety / write scope | **PASS** | scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/c2-counter.$$`, `trap 'rm -rf -- "$SCR"' EXIT`; run-log names randomized (`rhex`); tree is `--tree` (read in place) or `git archive` into scratch; no token in any counter argv (S-2 log) | note: leg log files are 0644 under 0755 dirs; harmless while receipts carry no secrets |
| S-16 | C2 counter executes measured-tree code | **MEDIUM** | `bash "$TRIAL"` from the measured tree (S-12 run). `env -i` limits inheritance, but the trial is still arbitrary code with the verifier's filesystem rights | Mitigate at the source: the trial is the lane's own committed file; for a `--tree` from an untrusted source, pin its sha256 or run it under `bwrap` — same class as round-57 M-2 (C-1) |
| S-17 | C1 checker: file reads bounded to the measured tree | **FAIL (weakness)** | `rd()`/`sha_of()` join without containment (133, 141). With `corpus/lessons/round-57.md → outside file` and `corpus/SOURCES.md → /etc/hostname`, the audit hook logged `open <outside>/outside-lesson.md` and `open /etc/hostname` as reads outside the root | resolve `realpath` and require it under `realpath(root)+os.sep`, or open the fixed paths with `O_NOFOLLOW`; FAIL/SKIP a symlinked authority (C-3) |
| S-18 | C1 checker: path traversal through `--root` | **PASS (limited)** | `root = os.path.abspath(args.root)` (913); `..` is normalised away; only fixed relative names are joined. A symlinked `--root` is followed (same class as S-17); no write is driven by `--root` itself | — (covered by C-3) |
| S-19 | C1 checker: no candidate-controlled execution | **FAIL (weakness)** | two `subprocess.run` calls on tree bytes with `cwd=root`: `<tree>/corpus/current-claims.py --selftest` (468) and `bash corpus/scope-gate.sh --lane-root /home/vgpnk/Projects/shokunin` (499). Forged stubs wrote markers and recorded `BAO_TOKEN_present=True`, `BAO_TOKEN_len=44`, `VAULT_TOKEN_present=True`, `cwd=<tree>` | run children with `env -i HOME=<scratch> PATH=/usr/bin:/bin TMPDIR=<scratch> LANG=C`, and execute a lane-pinned byte-identical copy (sha256-equal) instead of the tree's script, or refuse execution in `--tree` mode (C-1) |
| S-20 | C1 checker: writes confined to scratch | **FAIL (weakness)** | `tempfile.mkdtemp(prefix="c1-challenge-", dir=C1_CHALLENGE_PARENT or dirname(abspath(root)))` (605-607) + `copytree(root, copy, symlinks=True)` (612). Parent made unwritable ⇒ `CHALLENGE FAILED … Permission denied: '<parent>/c1-challenge-s5_okoe_'`. With `--root` = the lane, the default parent is the **fleet root** `/home/vgpnk/Projects/shokunin`; a lane copy is ~306 MB | default the parent to `${HYAKU_SCRATCH:-/tmp}` (or `tempfile.mkdtemp()` with no `dir`), and validate `C1_CHALLENGE_PARENT` is under a scratch root (C-2) |
| S-21 | C1 checker: replaced authority file | **named ceiling** | the plan's own ceiling: "the checker trusts the files it reads (a forged authority that satisfies the condition passes)". A *symlinked* authority is the sharpest variant and is measured in S-17 | record the symlink variant in the plan's ceiling sentence (C-3) |
| S-22 | C1 receipts cannot carry a token | **PASS (default) / LOW (verbose)** | default output is one `C1_ROUTED:` line; `plans/round-58-c1.sh` captures stdout without `--verbose`. With `--verbose`, item detail interpolates a candidate literal (`repr(str(bad[0])[:60])`, 454) and exception text, so a forged `current-claims.py` can inject a newline-prefixed `C1_ROUTED:` line into a receipt | keep `--verbose` out of receipt captures (the driver already does) and strip CR/LF from interpolated literals (C-7 note) |
| S-23 | C1 checker and C2 counter: no network | **PASS** | audit hook over the full checker: 0 `socket.connect`, 0 `socket.getaddrinfo`; the only `popen` events are the two tree scripts. Counter: no network primitives | — |
| S-24 | no credential material in the round surface | **PASS** | 108 files under `.ufo/waves/round-58` (re-swept at close) + the four instruments + `corpus/knowledge/openbao-acl-policy-semantics.md` + the new epoch-C receipt, swept for `r58-<24 hex>`, `(hvs|hvb).<8+>`, `s.<20+>`, `op://<value>`, `ghp_<20+>`, `xox[bap]-<value>`: **0 hits**. Header sweep: only the docs page's own sample curl (`--header "X-Vault-Token: ..."`, literal ellipsis) in `R58ScribeEntry/capture/S118.body`, a sibling's sweep log, and prose in a seat report; **no `Set-Cookie`/`Cookie`/`Authorization` header value** | — |
| S-25 | this seat made no host mutation | **PASS** | `git status --porcelain` before/after shows only other seats' edits; I wrote only `.ufo/waves/round-58/w1/R58SentinelTrial.md`, `.ufo/waves/round-58/build/R58SentinelTrial/` (report + receipts) and scratch; no installs, no pacman, no sysctl, no service | — |
| S-26 | readings for the record (not a security check) | **PASS** | trial direct ×3: `OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` rc 0 (clean, hostile-ambient, free-port control); counter on the lane tree: `C2_POLICY_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 wrap=1 secret=1)` rc 0 in 2m40s; checker on a pristine BASE extract: `C1_ROUTED: value=8 population=8 i1=0 … i8=0 guard=0` rc 1 (the plan's required census) | — |

## Findings

### C-1 — **Medium** — the C1 checker executes measured-tree code with the verifier's environment
- Evidence: `plans/round-58-c1-check.py:468` (`subprocess.run([sys.executable,"-I","-B",path,"--selftest"], cwd=root)`) and `:499` (`subprocess.run(["bash","corpus/scope-gate.sh","--lane-root",FLEET_ROOT], cwd=root)`), both inheriting the environment. A forged tree carrying only those two scripts was measured read-only; its stubs wrote markers outside the tree and recorded `BAO_TOKEN_present=True`, `BAO_TOKEN_len=44` (a 44-char fixture), `VAULT_TOKEN_present=True`, `cwd=<tree>`. Re-proven on the final checker bytes `94e7c326…`.
- Exploit path: a seat or operator measures a `--tree` obtained from a branch/fork/attachment; that tree's `current-claims.py` or `scope-gate.sh` runs arbitrary code as the verifier, reads every exported secret (vault tokens, API keys), and can write the secret into the lane tree or any wave path — the only path by which a real credential can reach a committed artifact in this round.
- Impact: credential capture + arbitrary filesystem write from a read-only-looking audit; same class as round-57 M-2, still open, now with two execution sites.
- Smallest remediation: run both children under `env -i HOME=<scratch> PATH=/usr/bin:/bin TMPDIR=<scratch> LANG=C`; execute a **lane-pinned** byte-identical copy of each script (sha256 equal to the lane tip's file) instead of the tree's bytes, or gate execution off for `--tree` and read syntax only.

### C-2 — **Medium** — the checker's challenge writes ~306 MB next to the measured root (fleet root, when run on the lane)
- Evidence: `:605-607` default parent is `os.path.dirname(os.path.abspath(root))`; `:612` copies the whole tree (`.git` included). Proof: with the parent unwritable, `CHALLENGE FAILED … Permission denied: '<parent>/c1-challenge-s5_okoe_'`; the default is demonstrated by the same call with `C1_CHALLENGE_PARENT` unset. On `--root /home/vgpnk/Projects/shokunin/kagi-shokunin` the parent is the fleet root; the lane is 306 MB. `C1_CHALLENGE_PARENT` is ambient and can redirect the write anywhere.
- Exploit path: a direct run of the documented command (`python3 -I -B plans/round-58-c1-check.py --root .`) writes a full lane copy into the fleet repo root; on a read-only fleet root the challenge fails and, because the guard requires it, a *correct* fix reads `FAIL`.
- Impact: host mutation by a read-only instrument, and a guard that can be made to fail by host permission state rather than by the measured tree.
- Smallest remediation: default `dir=` to `${HYAKU_SCRATCH:-/tmp}` (or no `dir` at all, so TMPDIR applies); reject a `C1_CHALLENGE_PARENT` outside a scratch root; keep `symlinks=True`.

### C-3 — **Low** — the checker follows symlinks and reads outside the measured tree
- Evidence: `rd()`/`sha_of()` (133, 141) `os.path.join` + `open` with no containment. With two symlinked authorities the audit hook logged reads of `<scratch>/outside-lesson.md` and `/etc/hostname`. `--root` itself is `abspath` only (913).
- Exploit path: a committed tree carries `LOG.md`/`SCORECARD.md`/`corpus/SOURCES.md` as symlinks to files it did not measure (or to a sensitive file the verifier can read); the item can read its verdict from bytes outside the tree.
- Impact: integrity of the audit boundary; read-only information flow (the checker prints no file content, only booleans/counts and one truncated literal under `--verbose`).
- Smallest remediation: `os.path.realpath(p)` and require `p == root or p.startswith(root + os.sep)`; FAIL/SKIP on `os.path.islink`.

### C-4 — **Low** — I8 hands the tree's `scope-gate.sh` a hardcoded live fleet root
- Evidence: `FLEET_ROOT = "/home/vgpnk/Projects/shokunin"` (:117) passed as `--lane-root` (:499); `corpus/scope-gate.sh:342` resolves `basis_root="$LANE_ROOT/${lname}-shokunin"`, so the item's verdict depends on sibling lanes outside the measured tree.
- Exploit path: measuring a copy on another host or another scratch root reads differently for the same bytes; a forged tree receives an explicit pointer to every sibling lane.
- Impact: measurement contamination / host coupling of a frozen predicate; the item is no longer a function of the measured tree.
- Smallest remediation: make the lane root an explicit counter argument recorded in the receipt (the driver can pass the lane it extracted from), or measure with `--lane-root <tree>` when the tree is the lane and SKIP I8 otherwise.

### C-5 — **Low** (residual, accepted by the frozen contract) — client tokens live in the environment, not on argv
- Evidence: `BAO_TOKEN="$root"` (94), `BAO_TOKEN="$1"` (134-136, 140), `BAO_DEV_ROOT_TOKEN_ID="$root"` (84). While each child runs, `/proc/<pid>/environ` is readable by the same user and holds the token.
- Impact: a co-resident same-user process can harvest the dev root token or a child token; the root token grants full authority over the throwaway server. No secret is printed and no receipt captures it.
- Smallest remediation (optional): write the root token to `$D/home/.vault-token` (0600) and unset `BAO_TOKEN` after client tests, using the CLI's token-file resolution; or record this as an explicit residual in the entry.

### C-6 — **Low** — the counter's secret guard omits `s.`-shape tokens
- Evidence: `plans/round-58-c2.sh:142` pattern `r58-[0-9a-f]{24}|(^|[^A-Za-z0-9])(hvs|hvb)\.`. Round 57's counter also had `s\.[A-Za-z0-9]{20,}`.
- Impact: OpenBao tokens are `hvs.`/`hvb.`, so coverage is adequate for this product; an `s.`-shaped value (or another product's token) printed by accident would not force `value=0`.
- Smallest remediation: add `s\.[A-Za-z0-9]{20,}` to the pattern (one line).

### C-7 — **Low** — trial cleanup kills by PID without an identity check
- Evidence: trial:62-70 `kill "$SRV"` / `kill -9 "$SRV"` in `cleanup` and `stop_server`, with no `/proc/$SRV/comm` check. `setpriv` execs `bao`, so the pid is the server's, but if the server dies first the pid can be reused within the retry window and `kill -9` would hit a foreign process.
- Impact: bounded to a rare race; no observed occurrence, and the round-58 runs left no live server (S-5).
- Smallest remediation: `[ "$(cat /proc/$SRV/comm 2>/dev/null)" = bao ] || return 0` before the signal, or start the server with `setsid` and signal the process group.

## Incidental observation (not a security finding)

The first trial bytes I reviewed (`5ce1216a…`, 12:05) read T1 **BROKEN** on OpenBao 2.7.2: an
empty-policy token's KV read returns HTTP 403 with the text `preflight capability check returned
403, please ensure client's policies grant access to path "secret/t1/"`, and `classify()` then
matched only the literal `permission denied`, so `empty-token-denied=2`. I reproduced it in
isolation (a 26-char server-issued token, error text carrying no credential) and reported it to
`R58ExecTrial` and `KagiR58`; the executor's revision `1f1eed9d…` classifies `Code: 403` as
denied and the final trial reads 5/5 twice (clean and hostile-ambient runs).

## What I did not do

- Did not judge the T1–T5 semantics or the guard's arithmetic (reviewer/critic/mutation seats).
- Did not run `plans/round-58-controls.sh` (absent at review time) or the L1's battery; I read
  the plan's control list only.
- Did not fuzz the instruments, did not test another OpenBao build (the pin fixes 2.7.2), and
  did not attempt privilege escalation or persistence (out of scope for a trial).
- Did not inspect the fleet root, sibling lanes or any vault; no secret value was read, written
  or printed by this seat.

Scratch deleted before yield; no file written outside the two report paths and my scratch.

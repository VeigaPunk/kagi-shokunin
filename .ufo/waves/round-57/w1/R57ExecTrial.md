# R57ExecTrial — seat report (kagi round 57, wave 1)

Seat: R57ExecTrial (executor). Date: 2026-11-07. Lane: `kagi-shokunin`, branch master, claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`. Frozen predeclaration read before work: `plans/round-57.md`, `plans/round-57-c1-check.py`, `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`. No instrument amended; no production file touched (writes confined to `/.ufo/waves/round-57/w1/R57ExecTrial.d/` and this report + my scratch, deleted at close).

## Deliverable

`.ufo/waves/round-57/w1/R57ExecTrial.d/openbao-audit-trial.sh` — working draft of the C2 trial `corpus/openbao-audit-trial.sh` (T1–T5, shims SH1–SH5), landing-target semantics per `plans/round-57-c2.sh`.

- sha256: `5f74da865f4f905ac80a6ea541f4afc61586cf3495a04af8ffe84cb83747bf15`
- Contract implemented: `--work DIR`; stdout exactly five `TEST T<n>: HOLDS|BROKEN` lines then `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` rc0 iff all hold, else `AUDIT_TRIAL: FAIL (tests=5 pass=<k>)` rc1; rc2 with no TEST/SUMMARY line when `bao` is absent (stderr-only note). Fail-closed: infrastructure failure marks unrun tests BROKEN → FAIL rc1 (exercised in iteration 1, see below).
- Shim semantics: `KAGI_AUDIT_SHIM=SH<n>` inverts test T<n>'s core assertion only; mechanics still run.
- Test mechanics (all live): T1 `bao audit enable -path=file file file_path=<work>/audit-default.log` + `bao audit list` names `file/`; T2 KV write via stdin (`bao kv put -mount=secret r57custody value=-`, value never on argv), request and response entries both present at `secret/data/r57custody`, `"value":"hmac-sha256:…"`, plaintext absent from log; T3 second device `file-raw` with `log_raw=true` records `"value":"<plaintext>"` while the default device still HMACs; T4 `cp` of the default log, `bao audit disable file/`, re-enable at the same path, rewrite the same value, `"value":"hmac-sha256:…"` before ≠ after (new salt); T5 `bao status` (sys/seal-status) adds 0 log lines while `bao kv get` adds ≥1 (non-audited-path list per S115).

## Decision-relevant finding for the L1 landing (doc/binary divergence)

OpenBao v2.7.2 **refuses API/CLI audit enablement by default**: `bao audit enable` → rc2, `400: cannot enable audit device via API; use declarative, config-based audit device management instead`. The server config must opt in with one line: `unsafe_allow_api_audit_creation = true` (documented at https://openbao.org/docs/audit/ → "Enabling/Disabling audit devices", required since v2.3.2; https://openbao.org/docs/commands/audit/ shows bare `bao audit enable` succeeding without mentioning this gate). The draft therefore writes `<work>/server-config.hcl` (scratch, no secret) with that line and starts the server with `-config=<work>/server-config.hcl`. **The landed `corpus/openbao-audit-trial.sh` must do the same or T1–T4 cannot run on OpenBao ≥ 2.3.2.** With the opt-in, every frozen POP command works verbatim, including T4's disable/re-enable round-trip.

## Environment (no installs performed)

- OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379), committed 2026-10-26T20:32:27Z, preinstalled at `/home/vgpnk/.local/bin/bao` (matches the plan's named-ceiling binary; channel: preexisting local install, nothing added).
- `setpriv` (util-linux, `--pdeathsig` verified), GNU bash, coreutils, grep — all preinstalled. pacman untouched (paused per seat orders).

## Runs and receipts (all under `R57ExecTrial.d/`)

Binary: OpenBao v2.7.2. Host: linux 7.2.11-arch1-1 x64. Exact invocations (cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`):

| receipt | invocation | rc | stdout last line |
|---|---|---|---|
| `receipt-real.txt` | `bash .ufo/waves/round-57/w1/R57ExecTrial.d/openbao-audit-trial.sh --work /fast/scratch/hyaku/kagi-r57/R57ExecTrial/work-real` | 0 | `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` |
| `receipt-sh1.txt` | `KAGI_AUDIT_SHIM=SH1 bash … --work …/work-sh1` | 1 | `AUDIT_TRIAL: FAIL (tests=5 pass=4)` — exactly T1 BROKEN |
| `receipt-sh2.txt` | `KAGI_AUDIT_SHIM=SH2 bash … --work …/work-sh2` | 1 | `AUDIT_TRIAL: FAIL (tests=5 pass=4)` — exactly T2 BROKEN |
| `receipt-sh3.txt` | `KAGI_AUDIT_SHIM=SH3 bash … --work …/work-sh3` | 1 | `AUDIT_TRIAL: FAIL (tests=5 pass=4)` — exactly T3 BROKEN |
| `receipt-sh4.txt` | `KAGI_AUDIT_SHIM=SH4 bash … --work …/work-sh4` | 1 | `AUDIT_TRIAL: FAIL (tests=5 pass=4)` — exactly T4 BROKEN |
| `receipt-sh5.txt` | `KAGI_AUDIT_SHIM=SH5 bash … --work …/work-sh5` | 1 | `AUDIT_TRIAL: FAIL (tests=5 pass=4)` — exactly T5 BROKEN |
| `receipt-noao.txt` | `env -i PATH=/usr/bin:/bin HOME=<scratch> bash … --work …/work-noao` | 2 | (0 stdout bytes; no TEST/SUMMARY line; stderr note only) |

Verdict vector, real run: `T1 HOLDS T2 HOLDS T3 HOLDS T4 HOLDS T5 HOLDS`. Each shim receipt carries its full vector (e.g. SH3: T1/T2/T4/T5 HOLDS, T3 BROKEN). All six `--- stderr ---` blocks are `(empty)`. Counter-shape cross-check: real stdout last line equals the frozen C2 counter's CLEAN case with rc 0; each shim matches its `AUDIT_TRIAL: FAIL*pass=4` + rc1 case.

Iteration 1 (pre-patch, receipts superseded): all six runs FAIL pass=0 rc1 with `fatal: audit enable failed` — the fail-closed path fired correctly and surfaced the v2.3.2 API-gate finding above.

## Custody evidence

- Server: `setpriv --pdeathsig KILL bao server -dev -dev-no-store-token -dev-listen-address=127.0.0.1:<random 21000–40999> -config=<work>/server-config.hcl`; in-memory storage; no server log file (startup/request stream drained by a pipe reader, discarded after extracting the root token).
- Root token: random, dev-generated, captured into `<work>/.root-token` (umask 077 → 0600), exported only via `BAO_TOKEN`/`VAULT_TOKEN` env; never on any argv; wiped by the EXIT trap.
- Written values: per-run 64-hex `/dev/urandom` nonces, passed on stdin (`value=-`), never on argv; never printed by the trial.
- Receipts leak check: 0 matches for `hvs\.`, `[0-9a-f]{32}`, `hmac-sha256:` across all seven receipts.
- Process check: `pgrep -c -f 'bao server'` baseline 2 → post-run 2; both survivors are sibling probes (`/fast/scratch/hyaku/kagi-r57/R57ScoutSources/probe/…`, ports 8298/8299, not started by this seat). This seat left 0 `bao` processes; each run's server is killed by the EXIT trap with the kernel pdeathsig as backstop.
- Hygiene note for peers: the two surviving sibling dev servers carry `-dev-root-token-id=<value>` on their argv (ps-visible). Flagged to R57ScoutSources; shape only, no value recorded here.
- Pre-existing host state (not mine, untouched, content never read): `~/.vault-token` exists since before my first run.

## Bounds and risks

- Dev in-memory server, one binary (OpenBao 2.7.2), one host — not a deployment; `log_raw` output judged by shape inside scratch only, never committed (work tree deleted at close; receipts kept in `.d/`).
- T4's mechanism (disable→re-enable→new salt) matches the S115/S116 sentences; measured live: HMAC of the same value differs after re-enable.
- Risks: none known for the draft. For the L1: port collisions with sibling dev servers are avoided by random-port probing; the C2 counter's `KAGI_SCRATCH` env is not required by the trial (all state under `--work`), which keeps the frozen counter's invocation shape valid.

## Blockers

None.

## Amendment A1/A2 (freeze epoch B) — draft superseded; deltas + independent evidence

Received mid-wave from L1 KagiR57. Bytes pinning the amended state: commit `03cbf656943b33bf93607f607bbbeb55d500b0f9` ("freeze epoch B"); `plans/round-57.md` sha256 `b130bb83b3dd4bdb52b84aeb4c6d3459477188b66406adab429392049698c6dc`; `plans/round-57-c2.sh` sha256 `140a8f2b204af9a0e45e1b596d1c09c4b12f84a70bd42abd18e888d82bbaea28`; landed reference `corpus/openbao-audit-trial.sh` sha256 `41fd8096d53c6584f362cdcbc62c90ff3426738b03753b1765aba6e89ce7b343` (untracked at run time). All read before this section. The draft above is the pre-A1 iteration, kept as wave history and **not** proposed for landing; per L1 instruction I did not rewrite it.

Draft → reference deltas (shape and mechanics):

- Output: `TEST T<n>: HOLDS|BROKEN` + `AUDIT_TRIAL: CLEAN/FAIL` → lane convention `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` + `OPENBAO_AUDIT_TRIAL: HOLDS|BROKEN|ERROR holds=N broken=N error=N bao=<ver>`; ERROR now maps to rc2 (three-state).
- T1: my draft measured only the accepted side (config opt-in) → reference measures both sides: refusal on a default dev server (rc≠0, `cannot enable audit device via API` grepped from stderr) and acceptance on the flagged server, plus the second `-path=file2 … log_raw=true` device listed alongside `file/`.
- T2: log-grep of `hmac-sha256:` occurrences → `bao write -format=json sys/audit-hash/file input=…` (form `hmac-sha256:<64hex>`, stable for one input, distinct for another) plus ≥2 occurrences of that same hash in the log (request+response echo) and zero plaintext.
- T3: adds client-token-cleartext counts on the raw device (and zero in the default log), counted never printed.
- T4: log-offset HMAC extraction across disable/re-enable → `sys/audit-hash` before/after on the same flagged server.
- Custody: my draft captured the root token from the startup stream (pipe reader) with `-dev-no-store-token` → reference passes it via `BAO_DEV_ROOT_TOKEN_ID` env (no argv, no stdout parsing), sandboxes `HOME` into the work dir, scrubs inherited `BAO_*/VAULT_*` env, sends server output to /dev/null, picks the port with a python `bind(("127.0.0.1",0))`, and asserts the probed port is held by our own pid via `ss -Hltnp`. Both: `setpriv --pdeathsig KILL`, stdin-only values, no server log, no printing of secrets.

Independent verification run by this seat (non-author; nine counter legs against the reference; receipts `receipt-ref-{real,real2,none,sh1..sh5,wrap}.txt`, each with exact invocation, rc, full stdout, stderr, vector):

| leg | rc | vector | summary line |
|---|---|---|---|
| real | 0 | HHHHH | `OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` |
| real2 | 0 | HHHHH | same |
| none (`env -i PATH=/usr/bin:/bin`) | 2 | none | `OPENBAO_AUDIT_TRIAL: SETUP no bao on PATH` |
| sh1 | 1 | BHHHH | `OPENBAO_AUDIT_TRIAL: BROKEN holds=4 broken=1 error=0 bao=v2.7.2` |
| sh2 | 1 | HBHHH | same shape |
| sh3 | 1 | HHBHH | same shape |
| sh4 | 1 | HHHHB | same shape |
| sh5 | 1 | HHHBH | same shape |
| wrap (client wrapper silencing `bao audit list`) | 1 | BHHHH | same shape |

Vectors match the predicate mapping SH1→T1 … SH5→T5 exactly; `none` prints no `TRIAL T<n>` lines; the wrapper leg flips T1 only. Leak check: no `r57-[0-9a-f]{24}`, `hvs\.`, `hvb\.` in any receipt. The local bao matches the counter's pin: sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`; no `bao` in `/usr/bin` or `/bin`.

Frozen counter executed by this seat against the landing tree (independent REF evidence):

`HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r57/R57ExecTrial R57_BAO=/home/vgpnk/.local/bin/bao bash plans/round-57-c2.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin` → rc0, `C2_AUDIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=5/5 guard=1 (real=1 none=1 wrap=1 secret=1)`.

Harness note for the record: the first-pass assertion lines in my job transcript (`real-ok: 0/2`, `shims-ok: 3/5`) were bugs in my own checker (a grep pattern and an expectation array with positions 4/5 transposed), not in the trial or counter; receipt-level recomputation reads real-ok 2/2 and shims-ok 5/5 per the predicate map. The `receipt-ref-*.txt` files are authoritative.

Measured gotchas handed to the L1: (1) the refusal text is reliably greppable from `bao audit enable` stderr on a default dev server (observed twice per leg); (2) `BAO_DEV_ROOT_TOKEN_ID` env passing works on 2.7.2 (every reference leg started two servers); (3) the response entry echoes the request's value hash — `hm_grep≥2` held on both real runs; (4) the `log_raw` device logs the client token in cleartext while the default device does not (counts held); (5) `unsafe_allow_api_audit_creation = true` is accepted in JSON server config (`{"unsafe_allow_api_audit_creation": true}`). Host hygiene: one sibling dev server (`R57ScoutSources` probe) was still alive at wave-end ps check — flagged to that seat earlier; this seat left zero `bao` processes.

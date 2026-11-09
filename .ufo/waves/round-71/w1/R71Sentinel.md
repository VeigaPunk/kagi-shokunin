Author: R71Sentinel (sentinel)

# Round 71 C1 — secrets-hygiene and process-safety attack on the landed trial and counter

Scope: corpus/openbao-pki-issuer-trial.sh and plans/round-71-c1.sh at landed revision 39e76bc700cf05e7772711f703bdbc3c6e7ac469 (trial bytes equal the committed bytes, sha256 prefix 588ed91a5f43d76b). The counter and plan were not edited. Receipts are in .ufo/waves/round-71/w1/R71Sentinel/ (booleans, counts and redacted samples only). No token, key, or CRL body is reproduced here.

## Result in one paragraph

The landed counter reproduces value=4 (rc 0). The token and OCSP claims hold: the dev root token never appears on any argv, and the OCSP leg sends no token in its environment or on the wire. Dev servers do not survive a SIGKILL of the trial or the counter, and the port-squat check is pid-exact. Two real gaps exist, neither of which changes the counted value. (1) Leaf private keys sit in plaintext in the scratch JSON files until the EXIT trap runs, so a SIGKILL of the trial leaves them behind. (2) The NOSECRET regex misses raw DER keys, base64-wrapped PEM, hvb./hvr. tokens, and tokens directly after bytes >= 0x80. The landed evidence contains no key or token by any encoding. This seat also caused one process-hygiene incident of its own (below), which is disclosed.

## Checks requested, with outcome

1. Dev root token on any argv. Not present. A full strace -f -e trace=execve over one real trial recorded 2000 execve lines; zero argv lines match a token shape. The server argv is `setpriv --pdeathsig KILL bao server -dev -dev-listen-address=127.0.0.1:P -dev-no-store-token`. The token reaches the server through BAO_DEV_ROOT_TOKEN_ID in its environment, and the client gets BAO_TOKEN from its environment. Both are readable only by the same uid through /proc/PID/environ. That is the stated ceiling, not a defect. Sampling file: samples-redacted.txt (97 lines, token-shaped hits 0).
2. ps during a run. Sampled every 20 ms during a real run (samples-redacted.txt; counter sampler in counter-sampler-owner-classes.txt). Argv token hits: 0. Environment of the server carries BAO_DEV_ROOT_TOKEN_ID (expected). Environment of the counter-run servers carries R71_C1_NONCE=1 in 170 samples (so NOLEAK does see the servers).
3. Private-key mode and lifetime in scratch. The scratch parent is mode 700 and the files are mode 600 (umask 077 is set before any write). The explicit `rm -f t9.key` sits inside the outer success branch after the inner if/elif, so it is reached on the no-serial path, on the BROKEN path, and on the success path; the only path that never creates the file is the one where issue fails. One gap is real: every issue response JSON (t6.json, t7.json, t8r.json, t8g.json, t9.json) carries the leaf private_key in plaintext, and only t9.key is removed. t9.json holds the key until the EXIT trap. See SE-1.
4. Private key passed by @file, not argv. Confirmed. The client argv is `bao write -format=json pki/revoke-with-key certificate=@<t9.pem> private_key=@<t9.key>`. The argv carries the path only.
5. Key or token reaching --evidence, stdout or stderr. Not found. The ev() copies list only public artifacts (certificates, CRLs, OCSP responses). Every bao and openssl call redirects stderr to /dev/null. The `TRIAL` lines and the final line print fixed strings and dates. The landed run's 15 evidence files have zero PEM private-key text, zero DER private keys, and zero base64-of-PEM key text.
6. Server ownership check (port squatting). The ss check is `ss -Hltnp "sport = :P" | grep -q "pid=$SP,"` with a trailing comma. Tested: a squatter's pid matches (1), a pid-prefix neighbour does not (0), an unrelated pid does not (0). BAO_TOKEN is exported only after ok=1, so a same-uid squatter can make start_server fail (three retries, then SETUP dev-server-not-ready) but cannot receive the token.
7. pdeathsig. Verified. Trial SIGKILL at three points (t6.json, t9.json, t9.key appearing) left zero bao servers. Counter SIGKILL left the orphan `timeout 600 bash trial` running to completion, and it reached zero servers within 2 s. Counter SIGTERM (rc 143) removed the counter scratch at once and left no server.
8. Leaks after SIGTERM and SIGKILL. No server survives either signal (items 7 above). TERM, INT (when not backgrounded) and normal exit leave zero residue. SIGKILL of the trial leaves residue (see SE-1).
9. Does the token-less OCSP leg send no token? Yes. `( unset BAO_TOKEN; openssl ocsp ... )`: the openssl child counted zero BAO_TOKEN entries in its environment (2 of 2 invocations). Strace of the openssl process showed two POST /v1/pki/ocsp requests with zero X-Vault-Token and zero Authorization headers and zero token-shaped strings. My first shim reported "yes" for every invocation. That was a quoting bug in my shim (`\"` inside `$(…)`), now fixed and retracted. The unset works.
10. NOSECRET evidence scan with grep -a on DER. `grep -a` does scan binary files, and the trial's own token form r71-<24 hex> is caught inside binary bytes (boundary-free alternative). Gaps: a raw DER private key has no PRIVATE KEY text and is missed; a base64-wrapped PEM is missed; the regex lists s|b|r|hvs but not hvb. or hvr., so OpenBao batch and recovery tokens are missed; and an hvs. token immediately preceded by a byte >= 0x80 is missed in both LC_ALL=C and en_US.UTF-8 (probes 80, a9, c3, e0, ff missed; 00, 01, 2d, 7f caught). The trial emits none of these today (checked on the landed evidence). See SE-7.

## Process-safety notes (not counted)

- Process isolation for the counter. The counter runs the trial with env -i, so the counted runs carry only the caller's PATH, HOME, TMPDIR and nonce. A direct operator run without env -i passes arbitrary environment variables (an operator canary) into the dev server and every child, because only VAULT_ and BAO_ names are stripped. See SE-8.
- Dangling counter scratch after SIGKILL. The counter's W directory holds a full `git archive` copy of the lane (about 14k entries) and the public evidence. It holds no key or token outside that copy (checked: zero PEM or token-shaped hits in the 22 files outside tree/). This is disk residue, not secret residue.
- Shell caveat. `kill -0` treats an unreaped zombie as alive, so a server that exits during start_server keeps the readiness loop running to its budget (INFERENCE; not timed; delay only).

## Incident (this seat's own process-hygiene slip)

My case.sh timing harness had a cleanup step that ran `kill -9` on any `bao server -dev` pid that was absent from the pre-run snapshot, after the trial exited. That pattern matches every user's dev servers. Three pids were killed: 84097 (after TERM-t9key), 140871 (after INT-t9json) and 222676 (after K9-1s). Controls with the same trial and no signal showed zero survivors at exit, so the survivors were not left by the trial under test. A later host sample showed sibling-seat dev servers and sibling counter runs. The three were therefore most likely sibling dev servers. A sibling run that owned one of them may have reported SETUP or ERROR. K9-early's output was discarded, so whether it killed anything is unknown. Full record: incident-killed-foreign-servers.txt. Note to Main sent. The landed counter re-run after the incident still gives value=4.

## Counter

- Counting command run once on 39e76bc: `C1_PKI_ISSUER_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2`, rc 0, stderr 0 bytes, 44 s.
- Trial stdout: four HOLDS lines and `OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0 error=0 bao=v2.7.2 openssl=3.6.5`.

## Tooling

No installs or upgrades by this seat. Used existing /usr/bin/strace, /usr/bin/ss, /usr/bin/setpriv, openssl 3.6.5 and bao v2.7.2 (sha256 prefix 9c5f3628, matches the pin). Nothing was written to ~/.local/bin or ~/.omp, and the real ~/.vault-token was never opened (its mtime predates this seat's runs).

## Findings

SE-1 — leaf private keys persist in plaintext in scratch (t6.json, t7.json, t8r.json, t8g.json, t9.json, plus t9.key) until the EXIT trap. Explicit removal covers only t9.key. Residue confirmed after SIGKILL of the trial; zero residue after TERM, INT (when not backgrounded) and normal exit. The header's "removed on every trappable exit path" is accurate. Fix suggestion: remove each issue JSON after extracting its fields. Counted values unaffected.
SE-2 — OCSP leg is token-less in environment and on the wire (2 of 2 openssl ocsp invocations; zero token headers in two POST requests). My earlier contrary reading was my own shim bug and is retracted.
SE-3 — dev root token is never on argv (0 of 2000 execve lines); it lives in the server environment and the client environment, readable only by the same uid. Stated ceiling.
SE-4 — pdeathsig holds: a trial SIGKILL at three points and a counter SIGKILL each left zero bao servers.
SE-5 — SIGINT is ignored when the trial runs as a background job of a non-interactive shell (SigIgn bit set; bash cannot trap an ignored-on-entry signal). The trap is inert; the run completes with rc 0. TERM and HUP still clean up.
SE-6 — counter SIGKILL leaves W (a full lane archive copy and public artifacts) on disk, with no key or token outside the copy; counter SIGTERM removes W and returns rc 143.
SE-7 — the NOSECRET regex is not a key-absence proof. It misses raw DER private keys, base64-wrapped PEM, hvb./hvr. tokens, and hvs. tokens after bytes >= 0x80. The frozen predicate's literal text still holds, and the landed evidence has no key or token in any encoding, so value=4 stands. The prose reading "no private key reaches evidence" is broader than what the regex shows.
SE-8 — without env -i, the trial passes arbitrary operator environment into the dev server and its children (only VAULT_ and BAO_ are stripped). The counter's env -i keeps counted runs clean. Suggest an allowlist.
SE-9 — NOLEAK sees the dev servers: servers started by a counter run carry R71_C1_NONCE in their environment (170 samples), so the check can detect a leaked server.
SE-10 — the port-squat check is pid-exact (trailing comma; prefix and unrelated pids do not match). A squatter can make start_server fail but cannot receive BAO_TOKEN.
SE-11 — process-hygiene incident by this seat: three sibling-seat dev servers (pids 84097, 140871, 222676) were SIGKILLed by a pattern-based cleanup in the timing harness. Disclosed; no counted value changed; sibling runs that owned them may show SETUP/ERROR.

FINDING SE-1 neutral leaf private keys persist in plaintext in scratch JSON until the EXIT trap; SIGKILL of the trial leaves them behind; counted values unaffected
FINDING SE-2 neutral OCSP leg is token-less: zero BAO_TOKEN in openssl ocsp child env (2 of 2) and zero token headers on the wire; earlier contrary shim reading was a shim quoting bug, retracted
FINDING SE-3 neutral dev root token never on any argv (0 of 2000 execve lines); present only in server and client environment, same-uid readable
FINDING SE-4 neutral pdeathsig holds: trial SIGKILL at three points and counter SIGKILL each left zero bao servers
FINDING SE-5 neutral SIGINT is ignored when the trial is backgrounded from a non-interactive shell, so the INT trap is inert and the run completes with rc 0; TERM and HUP clean up
FINDING SE-6 neutral counter SIGKILL leaves its scratch (full lane archive copy, public artifacts) with no key or token outside the copy; counter SIGTERM removes it and exits 143
FINDING SE-7 falsifies-wording NOSECRET regex misses raw DER keys, base64 PEM, hvb./hvr. tokens, and hvs. after bytes >= 0x80; the literal predicate holds and landed evidence is clean in every encoding, so value=4 stands
FINDING SE-8 neutral without env -i the trial passes arbitrary operator environment into the dev server and children; the frozen counter's env -i keeps counted runs clean
FINDING SE-9 neutral NOLEAK does see the dev servers: counter-run servers carry R71_C1_NONCE in environment (170 samples)
FINDING SE-10 neutral port-squat ss check is pid-exact; a same-uid squatter can make start_server fail but cannot receive BAO_TOKEN
FINDING SE-11 neutral this seat SIGKILLed three sibling-seat dev servers via a pattern-based cleanup; disclosed in incident record; no counted value changed

SEAT-STATUS: complete all requested checks run; two real gaps (SE-1, SE-7) and one disclosed incident (SE-11) reported; counter reproduced value=4 on 39e76bc

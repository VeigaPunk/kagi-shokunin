# R61Sentinel — security findings (round 61, kagi)

- **Seat**: R61Sentinel (sentinel, attack) · kagi round 61 attempt 1, wave w1 · 2026-11-07
- **Lane**: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
- **Claim BASE**: `c940f51689d702f1786989d56ad4663833c1452e`
- **Frozen predeclaration**: `plans/round-61.md` (`8595018`, read before work)
- **Full report**: `.ufo/waves/round-61/build/R61Sentinel/security.md`
- **Read-only**: no production file changed by this seat. Mutated copies lived under
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61Sentinel/` and were deleted.
- **Secret discipline**: shapes and counts only; no share, token, OTP, nonce, cookie or
  session id is printed in this file or in `security.md`. Probe material containing
  generated shares was deleted immediately after measurement.

The wave was live during this review. Bytes measured: trial `a9c80c7a…` (posture run on
`6f4b43d0…`, stable), C1 driver `e6c85323…`, C1 checker `fe4491d4…`, C2 counter
`def7b737…`, controls `70c977cf…`.

## Six checks

| # | check | observed | verdict |
|---|---|---|---|
| 1 | secret-shaped material in artifacts/receipts | 71-file round delta: 0 token/share/OTP/nonce/cookie/bearer/PEM shapes; 450 `hex64` hits all sha256 digests. Captures S125–S127: 0 cookie/authorization shapes. | pass |
| 2 | trial server posture | 2 listener blocks both `127.0.0.1`; 0 non-loopback listener strings; `setpriv --pdeathsig KILL` (`corpus/openbao-seal-trial.sh:243`); `storage "raft"` under `$D` + `storage "inmem"`; strace 20 binds all loopback, 0 non-loopback connects; listener delta empty after the run; no leftover process. | pass (posture) |
| 3 | scratch confinement / `/tmp` | 0 `/tmp/` references in round artifacts. One kagi round-61 artifact in `/tmp`: `r61-trace.txt` (F4). Instruments clean their per-run scratch; the C1 driver leaves `run-<ts>-<pid>/` (F5). | pass with F4, F5 |
| 4 | host mutation | 0 pacman transactions today; 0 sudo/pkexec/doas; 5 `systemd[1]` lines all the snapper timer at 17:00:00; `/etc/sysctl.d` mtime 2026-10-20; the only `/etc` file newer than round start is `/etc/anydesk/service.conf` (root-owned, rewritten by the running anydesk service, not attributable); fleet repo carries only pre-existing orchestrator state. | pass |
| 5 | ambient env / real token file | ambient `BAO_ADDR`/`VAULT_ADDR` pointed at a recording listener: **0 hits**; strace shows the only `.vault-token` open is `$D/home/.vault-token` (isolated scratch HOME) → ENOENT; the host's real `~/.vault-token` is never opened; source scrubs `BAO_*`/`VAULT_*` (`:1104`) and sets `HOME="$D/home"` (`:1106`). | pass |
| 6 | counters execute only named scripts; no symlink escape | C2 counter execs only `bash <tree>/corpus/openbao-seal-trial.sh --work …` (9 legs) + coreutils/git/python; refuses a symlinked trial. C1 checker execs only `git`, `python3`, and `bash <its own scratch copy>/plans/round-60-c2.sh --selftest`; refuses symlinked statement, results and I2 script (`SETUP … is a symlink (refused)` rc 2); `copytree(symlinks=False)` for the challenge copy. | pass |

## Findings (severity order)

1. **F1 HIGH** — `plans/round-61-c2.sh:133`: the K3 secret scan cannot match a real
   unseal share. `bao operator init -key-shares=5 -key-threshold=3` on the pinned
   binary emits 5 shares of 44 chars, standard base64, unpadded, and **4/5 contained
   `+` or `/`**; the scan's share class `[A-Za-z0-9_-]{43,}` excludes `+`, `/`, `=`.
   Probe: a `+`/`/`-bearing share is not caught; the selftest fixture
   (`plans/round-61-c2.sh:161`) is alphanumeric-only, so `--selftest` cannot see the
   gap. The trial itself does not print shares (verified), so this is a detection gap,
   not an observed leak. Fix: widen the class to `[A-Za-z0-9+/=_-]{43,}` (keep the
   sha256 exclusion and the `(?![-_]{43})` guard) and add a `+`/`/` fixture.
2. **F2 MEDIUM** — `plans/round-61-c2.sh:133`: the same scan misses lowercase
   `otp=…`, `{"otp":"…"}` and `{"nonce":"…"}` (case-sensitive label; no JSON key form).
   Fix: `(?i)\botp["']?\s*[:=]\s*["']?[A-Za-z0-9+/=_-]{20,}` and the nonce analogue.
3. **F3 MEDIUM (accepted exposure)** — `corpus/openbao-seal-trial.sh:304`: the
   generate-root OTP and encoded token ride `-decode=… -otp=…` on argv, readable from
   `/proc/<pid>/cmdline` for the call's life. Bounded: throwaway server, ephemeral
   token, never printed. Declare as a ceiling, or drive
   `/v1/sys/generate-root/update` with the OTP in a body file as `api_unseal` already
   does for shares.
4. **F4 LOW** — `/tmp/r61-trace.txt` (3001 B, 17:06:39) is a `bash -x` trace of
   `plans/round-61-controls.sh`; no secret shape, cited nowhere, but a round artifact
   outside lane+scratch. Delete; redirect future traces under `${HYAKU_SCRATCH}`.
5. **F5 LOW** — `plans/round-61-c1.sh:35`: no `EXIT` trap, so each run leaves
   `run-<ts>-<pid>/` (tree + checker output) under scratch. Inherited from the
   round-60 driver. Add `trap 'rm -rf -- "$WORK"' EXIT` or declare retention.
6. **F6 LOW** — `plans/round-61-c1-check.py:238`: `_isolated_env` inherits `HOME` and
   ambient `BAO_*`/`VAULT_*`; the wrapped I2 leg is fixture-driven so no credential is
   reachable, but the isolation is weaker than the C2 counter's `env -i`. Scrub as the
   C2 counter does.

## State note for the L1 (not a security finding)

On the measured bytes the trial's real run reads `BROKEN holds=4 broken=1 error=0`
(T4 `dec=0`; `token/lookup-self` returns 404 where 200 is required), and the trial's
own receipts record the same honestly. C2 cannot reach 5 until T4 is fixed. The
security posture above is independent of that defect and holds.

SEAT-STATUS: complete

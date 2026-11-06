# K49ExecTrial — C1 hardened OpenBao token/lease trial (round 49, attempt 1)

Seat: `K49ExecTrial` (leaf executor). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (read-only).
BASE `89afe91878f10805921d3caa67d28d21b33226da`; predeclaration `082bfb3f6baa2407df2a23c0489043495b4dce4d`.
Scope: C1 candidate trial script only. The frozen instruments (`plans/round-49-c1.sh`,
`plans/round-49-c2.sh`, `plans/round-49-controls.sh`, fixtures) were read, never edited.

## Deliverables

| file | what |
|---|---|
| `.ufo/waves/round-49/build/K49ExecTrial/openbao-token-trial.sh` | hardened trial, sha256 `893b60ff5b95d10fc0a0137ff94caa7838eccd21a53adf62adb18618f88cfe1e` |
| `.ufo/waves/round-49/build/K49ExecTrial/diff-vs-reference.patch` | unified diff vs `controls/fixtures/openbao-token-trial.ref.sh` (93 lines) |
| `.ufo/waves/round-49/build/K49ExecTrial/receipts.txt` | commands, rc, full outputs, secret scan |
| `.ufo/waves/round-49/build/K49ExecTrial/receipts/` | raw `standalone-{1..3}.out`, `counter-{1..3}.out` |
| `.ufo/waves/round-49/build/K49ExecTrial/shellcheck.txt` | shellcheck 0.11.0 version + rc=0 |

Lane tree and `corpus/` were not edited; the candidate lives only in this build dir and in scratch.

## Hardening applied (grammar and the five tests' logic unchanged)

`TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` lines, the final
`OPENBAO_TRIAL: <S> holds= broken= error= bao=` line, and exits 0/1/2 are byte-identical in shape;
the T1–T5 bodies and their detail strings are copied verbatim from the reference. Deltas, keyed to
the assignment:

- **(a) shellcheck-clean.** `shellcheck 0.11.0` now exits 0 with no output (was `SC2329` info on
  `cleanup`). Cause of the false positive: shellcheck 0.11.0 treats a function referenced only from
  `trap` as never invoked when the script ends in an explicit `exit`. Fixed by calling the
  (idempotent) `cleanup` explicitly before the final `exit $rc` — no disable directive, no
  behaviour change beyond an earlier, already-idempotent teardown.
- **(b) no server survives the trial.** `cleanup` now (i) kills the recorded server PID, (ii) polls
  `kill -0` up to 5 s so the process is really gone, (iii) `kill -9` fallback, (iv) `wait "$SRV"`
  wrapped so it waits for *that* PID instead of every job, (v) deletes the scratch dir. Traps on
  `EXIT`, `INT` (130), `TERM` (143) and `HUP` (129) all funnel into the same cleanup, so a killed
  or timed-out trial cannot leave `bao server` behind. Server start is retried up to 3× on a fresh
  random `127.0.0.1` port (port picked by binding `:0` in python), readiness wait raised to 30 s,
  and the loop breaks early if the server process dies (no 30 s stall on a dead binary).
- **(c) CLI only.** All operations still go through `bao` resolved on `PATH`
  (`command -v bao`); no `curl`, no HTTP API call, no absolute `bao` path anywhere. The counter's
  shim dir is first on PATH and `exec "$REAL"` passthrough works (evidenced by `shim=BROKEN` on all
  five designated falsifiers).
- **(d) environment sweep + no secret on stdout/stderr.** The `BAO_*`/`VAULT_*` sweep is kept (now a
  `while IFS= read -r` loop over the same `sed` extraction, so no word-splitting on the variable
  list). The root token is random per attempt (`r49-` + 24 hex from python `secrets`), exported
  only into the trial's own environment, never echoed; every `bao` invocation that could print a
  token is captured or redirected to `/dev/null`. `counter nosecret=1` on all three runs, and a
  direct regex scan of every recorded output found no match.
- **(e) timing margins.** T1 (ttl 2 s, check at 4 s), T2 (explicit-max-ttl 5 s, check at 7 s),
  T5 (token ttl 3 s, check at 5 s) keep the reference's 2 s slack. Measured under load average
  **38.20** with 14 concurrent `bao server` processes host-wide: `sleep 4` overshoot `+0.0015 s`,
  `sleep 7` overshoot `+0.0023 s` — ~800× smaller than the margin, and `sleep` cannot undersleep.
  21 trial executions (3 standalone + 18 counter-invoked) produced zero flakes, so per the
  assignment no widening was applied. T3/T4 tokens (60 s) are untouched and the whole script runs
  in ~19 s, far inside their lifetime.
- **(f) server log stays inside the deleted scratch dir.** `>"$D/server.log"` (and nothing else is
  written outside `$D`); `$D` is removed by `cleanup` on every exit path.

## Evidence (exact commands and results)

Fixture tree: `git -C <lane> archive 89afe… | tar -x -C $S/tree` (rc 0; no `corpus/openbao-token-trial.sh`
at BASE, as expected), candidate copied to `$S/tree/corpus/openbao-token-trial.sh`, and
`controls/fixtures/entry-measured.ref.md` appended to
`$S/tree/corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (append rc 0). Both copies sha256
`893b60ff…` (identical).

Standalone, `bash $S/openbao-token-trial.sh --work $S/w`:

- run 1 — rc=0, 19.23 s wall — `TRIAL T1..T5 HOLDS`, `OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`
- run 2 — rc=0, 18.80 s wall — same five HOLDS, same final line
- run 3 — rc=0, 18.70 s wall — same five HOLDS, same final line

Counter, `bash <lane>/plans/round-49-c1.sh --tree $S/tree` (three times, rc=0 each):

```
C1_OPENBAO_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```

identical on runs 2 and 3 (walls 112 s / 114 s / 112 s). Each run therefore exercises:
real binary HOLDS for all five, each designated falsifier shim (SH1..SH5) flips its test to BROKEN,
the entry section's `- T<n> … OpenBao 2.7.2` line is found, the no-`bao`-on-PATH control exits 2
without a HOLDS line, and no run leaks a token-shaped string.

Process hygiene: `ps -eo pid,cmd | grep -F $S` → none after every run; no `openbao-trial.*` dir or
`server.log` left in `$S`. Host-wide, three `bao server` processes were alive after the runs, but
`readlink /proc/<pid>/fd/2` attributes them to `K49Sentinel` (`dbg.*`, `dbg2.*`) and
`K49CriticClaims` (`tokenprobe.*`) scratch dirs — other live seats, not this one; they were not
touched. This seat's six trials (3 standalone + 18 counter-invoked server instances) each reaped
their own server before exit.

## Risks / observations for the main agent

1. **Other seats leak live dev servers.** `K49Sentinel` and `K49CriticClaims` left `bao server -dev`
   processes alive with `-dev-root-token-id=r49-…` visible in `/proc/<pid>/cmdline`. Those are
   throwaway dev tokens, but it is a process-hygiene (and refusal-boundary) defect in those seats,
   not in this candidate. `cmdline`-based leftover checks on this host will not distinguish seats —
   attribution needs `/proc/<pid>/fd` or a per-seat scratch prefix.
2. **SC2329 quirk.** Any script ending in an explicit `exit` while relying on a trap-only function
   will be flagged by shellcheck 0.11.0; other seats using `trap cleanup EXIT` + final `exit` should
   expect the same false positive.
3. The candidate depends on the counter's `env -i` PATH containing `python3` (`/usr/bin`), which it
   does; no additional binary is required. It never resolves `bao` by absolute path, so the shim
   contract is preserved.
4. The measured entry section was appended only in the scratch tree (the lane's
   `corpus/knowledge/…` file is out of this seat's write scope); the lane producer must append the
   same section when the script is landed.

## Tooling

No installs were performed: `shellcheck 0.11.0` was already at `/usr/bin/shellcheck`;
`~/.local/bin/bao` is the pinned OpenBao v2.7.2 binary, sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (matches the counter pin) and was
not modified. No `pacman` command was run.

SEAT-STATUS: complete

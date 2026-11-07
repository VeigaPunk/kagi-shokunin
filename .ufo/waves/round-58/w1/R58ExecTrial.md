# R58ExecTrial — seat report (kagi round 58, w1)

Seat: R58ExecTrial (executor). Assignment: build and run
`corpus/openbao-policy-trial.sh` exactly to the frozen C2 contract in
`plans/round-58.md`. Non-goals honored: no counter (`plans/round-58-c2.sh` belongs
to R58ExecCounterC2), no corpus docs.

## Files changed (lane-relative)

- `corpus/openbao-policy-trial.sh` — NEW, executable, 279 lines,
  sha256 `1f1eed9d872a1a1367d737d63a45f1d8eb2c9fe6fa322d5e96a95dba934d0b4a`.
- `.ufo/waves/round-58/build/R58ExecTrial/` — evidence (below).

No other lane file was touched. Nothing committed (L1 commits).

## Behavior

Five tests on a throwaway in-memory `bao server -dev` (127.0.0.1, probed port held
by our pid, `setpriv --pdeathsig KILL`, umask 077, `BAO_DEV_ROOT_TOKEN_ID`/
`BAO_TOKEN` only, `bao` resolved through PATH, `--work DIR`, ambient
`BAO_*`/`VAULT_*` purged, `bao v2.7.2`):

- T1 deny-by-default: comment-only zero-rule policy token denied on a KV v2 read;
  read-grant token reads its exact path (value round-trips) and is denied an update.
- T2 prefix glob: `secret/data/bar/*` reads `secret/bar/zip` and
  `secret/bar/zip/zap`, denies sibling `secret/bars/zip`; exact `secret/data/food`
  grant denied on `secret/food2`.
- T3 deny precedence: broad `secret/data/t3/*` read + narrow `deny` on
  `secret/t3/locked` → denied at locked, allowed on sibling.
- T4 `+` one-segment bound: `secret/data/+/teamb` allows `alpha/teamb`, denies
  `alpha/beta/teamb` (two) and `teamb` (zero).
- T5 union vs highest-priority: same-pattern `secret/data/t5a` read+update union
  (both work; raw `bao delete secret/data/t5a`, which maps to the `delete`
  capability, stays denied); different patterns `secret/data/t5b*` read vs exact
  `secret/data/t5b` update → read denied, update allowed, and the one client-side
  `bao token capabilities` introspection (plain form) must read exactly `update`.

Shims `KAGI_POLICY_SHIM=SH1..SH5` each corrupt exactly one test's observable
evaluation (never the mechanics).

## Measured result (candidate, both runs against the final bytes)

Summary lines, real runs (rc 0 both):

    OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2   (run 1)
    OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2   (run 2)

Vector: real=HHHHH real2=HHHHH; shims SH1→BHHHH, SH2→HBHHH, SH3→HHBHH,
SH4→HHHBH, SH5→HHHHB (each rc 1, exactly its designated test flipped);
no-bao PATH → rc 2, output is only
`OPENBAO_POLICY_TRIAL: SETUP no bao on PATH`, no TRIAL/HOLDS lines;
capabilities-lying PATH wrapper → HHHHB rc 1 (only T5 flips; the T5 detail line
shows the fabricated introspection output `["read", "update"]` reaching the
verdict, proving the observable is load-bearing).

## Retained evidence

All under `.ufo/waves/round-58/build/R58ExecTrial/`:

- `receipt-ref-real.txt`, `receipt-ref-real2.txt` — the two real HHHHH runs.
- `receipt-sh1.txt` … `receipt-sh5.txt` — the five shim vectors.
- `receipt-ref-none.txt` — no-bao PATH leg (SETUP line only).
- `receipt-ref-wrap.txt` + `wrapper-capabilities-lie.sh` — the wrapper leg; the
  wrapper delegates everything to the real `bao` found on PATH except
  `token capabilities`, which it answers with the literal union lie
  `["read", "update"]` rc 0 (the `.real` sidecar held `command -v bao` at run
  time; no absolute bao path is embedded in the trial).
- `legs-rc.txt` — none-leg rc 2, wrap-leg rc 1.

Secret discipline: root token and every KV value are random `r58-` nonces; values
only via stdin `v=-`; child tokens server-generated, parsed from JSON stdout into
shell vars, never printed; no token or value on any argv; a scan of every
stdout+stderr captured this session for
`r58-[0-9a-f]{24}|(^|[^A-Za-z0-9])(hvs|hvb)\.|s\.[A-Za-z0-9]{20,}` is clean; all
stderr files were 0 bytes.

## Probe finding (the one permitted falsifiable observable)

This seat has no subagent-spawn tool, so the probe was performed directly as an
independent pre-freeze measurement in scratch (fresh dev server, trial-independent
code), not by a spawned labrat. Finding, all reproduced against OpenBao v2.7.2:

1. The plain-form `bao token capabilities` on the highest-priority token (glob
   `secret/data/pb*` read + exact `secret/data/pb` update) reads exactly `update`
   (JSON form: `["update"]`), while the same token on the longer name
   `secret/data/pbmore` reads `read` — the exact-pattern match alone decides the
   path, i.e. T5's "read denied + caps==update" is a genuine highest-priority
   measurement, not a union reading.
2. `bao policy write` accepts a comment-only zero-rule policy file, so T1's
   "empty policy" token is a true empty policy.
3. Raw `bao delete secret/data/<path>` exists and is classified denied for a
   read+update union token — the T5 delete-denied leg measures the `delete`
   capability.

## Conformance notes (peer-integrated before the candidate measurement)

- Cross-confirmation (post-candidate): R58ExecCounterC2's provisional counter run
  against these exact bytes reads
  `value=5 vectors=ok/5 guard=1 (real=1 none=1 wrap=1 secret=1)` rc 0, their
  `deny`-lie wrapper flipping exactly T5 (HHHHB rc 1); receipt
  `.ufo/waves/round-58/build/R58ExecCounterC2/receipt-c2-candidate-worktree-PROVISIONAL.txt`
  (marked provisional; the committed-revision candidate leg is the L1's).
- R58ExecCounterC2's contract: invocation `--work DIR`; PATH-only `bao`;
  `TRIAL T<n> …` + summary line shapes; shim env `KAGI_POLICY_SHIM`; rc map
  0/1/2; T5 the only client-side introspection, in the **plain** (non-JSON) form,
  so their wrapper's literal `deny` answer parses as a wrong-but-parseable →
  BROKEN (never ERROR). Confirmed with my own wrap leg (HHHHB rc 1).
- R58SentinelTrial's finding, confirmed in my first runs (T1 read
  `empty-token-denied=2`): the CLI's unauthorized read surfaces as a
  `sys/internal/ui/mounts` preflight 403 whose text lacks "permission denied";
  `classify()` now treats any HTTP 403 (`code: 403`) as denied, other failures
  remain a distinct classification. First-run bytes (`5ce1216a…`) are superseded
  by the final bytes above; the two real-run receipts are from the final bytes.

## Tooling record

No tool installed or updated (operator authorization not exercised): `bao`
v2.7.2, python3, setpriv, ss were already present. No pacman transaction.

## Risks / blockers

None blocking. Note for the L1: the trial is the instrument only; the C2 counter
(separate seat) still must pass its own controls (two real legs, shim vectors,
no-bao, wrapper, binary pin, secret scan) before any candidate is measured.

## Scratch

`/fast/scratch/hyaku/kagi-r58/R58ExecTrial/` (probe, nine leg dirs, wrapper bin)
was used and deleted before yielding.

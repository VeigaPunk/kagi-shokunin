# R60SentinelTrial — scoped findings (wave 1, round 60)

Seat: sentinel. Target: security review of the AppRole trial and this round's
receipts (secret discipline, argv exposure, dev-server bounds, cleanup).
Read-only; every execution ran on copies or with `--work` inside the seat
scratch. Reviewed bytes: `corpus/openbao-approle-trial.sh` sha256
`49ea928f28f42c7cce91459fe577a6d80023db3844229047718f483bfed0e54f` (27248 B,
15:39 -03; supersedes the 15:31 `a228e312…` review — the deltas are the
`ST_BASH` fixture fix and the T3 bounded-retry fix). Detailed artifact:
`.ufo/waves/round-60/build/R60SentinelTrial/review.md`; evidence:
`probe-groundtruth.txt`, `dynamic-run.txt`, `selftest-mutations.txt` in the
same directory.

## Verdicts

| # | check | verdict |
|---|---|---|
| 1 | no `secret_id` value / token / body on any argv | PASS |
| 2 | no token-shaped string in any receipt or artifact | PASS |
| 3 | dev server 127.0.0.1 only, `setpriv --pdeathsig KILL`, caller env isolated | PASS |
| 4 | `--work` confinement and `umask` | PASS |
| 5 | `--selftest` cannot pass while the harness is broken | PASS (two named ceilings) |
| 6 | `bind_secret_id=false` only on the throwaway server, documented unsafe | PARTIAL (scope PASS, in-file documentation FAIL) |

Key measurements: `strace -f` over the trial's tree reads
`EXEC total=167 argv_hits=0 uuid_on_argv=0` and `WRITES total=93 outside=0`;
the `/proc` cmdline sampler reads `argv_secret_shapes=0` over 82 distinct
cmdlines; the listener census is 2 lines, both `127.0.0.1`; the server's
environment carries only its own `BAO_DEV_ROOT_TOKEN_ID`; the hostile
`BAO_ADDR`/`VAULT_ADDR` listener recorded 0 connections; `--selftest` reads
`APPROLE_SELFTEST: PASS (cases=45)` with no bao and no network; 8 concurrent
real runs all read `HOLDS holds=5 broken=0 error=0`; my isolated
`plans/round-60-c2.sh --tree <lane>` run reads `value=5 … real=1 real2=1`.
Five selftest mutations (shim double-map, BROKEN→rc0, ERROR-not-wins,
custody-always-true, no-bao guard removed) are KILLED with named finding ids;
two survive by design (a broken real mechanic; a wholesale PASS-printer
replacement).

## Defects routed (not fixed here)

- **D-S1 high (calibration)** — §A3 item 4 restates the frozen T1 condition
  while saying nothing changes, and the restatement is unnecessary: the trial
  implements the frozen two-observable form (role with
  `token_bound_cidrs=127.0.0.1/32`, bind default true → role_id-only 400
  `missing secret_id`; `bind_secret_id=false` on the same role → same body 200
  + token). My probe proves that form reachable on bao v2.7.2. Report it; do
  not rewrite §A3.
- **D-S2 resolved (operability/calibration)** — T3's fresh-secret_id leg raced
  the 1 s TTL (author's `receipt-ref-real.txt` read `T3 BROKEN … fresh=0`; my
  isolated counter run at `a228e312…` read `real=0 real2=0` once). The 15:39
  fix adds a bounded 3-attempt fresh-generation+login loop for both T3 legs;
  on the reviewed bytes the traced run, 8 concurrent runs and my isolated
  counter all read HOLDS / value=5. Keep the retry.
- **D-S3 open medium (calibration)** — the counter's refreshed `candidate.txt`
  (15:44:50) pins `a228e312…` and says "FINAL bytes", but the lane file has
  been `49ea928f…` since 15:39:15; the receipt again describes a superseded
  revision. My isolated counter run at `49ea928f…` reads `value=5 … real=1
  real2=1`, so the reading is corroborated — but the L1 must freeze the trial
  and have the counter re-run at the frozen sha before citing it. The trial
  changed three times this wave (15:26, 15:31, 15:39).
- **D-S4 low (documentation)** — the trial header does not call
  `bind_secret_id=false` a deliberate unsafe configuration; only the plan does.
  One clause in the T1 comment closes it.

## Hardening to route

1. C2-F9: a control that mutates the trial's selftest verdict mapping and
   requires a non-zero exit with a named finding id (my M7 shows a wholesale
   PASS-printer replacement is otherwise undetected).
2. Extend the counter's secret scan to the `r60-`+24-hex root-token shape and
   to bare UUIDs (the current regex catches only `hvs.`/`hvb.` and
   `secret_id`+UUID).
3. Add a static argv assertion to the selftest: grep its own `bao` command
   lines for `secret_id=<uuid>` and fail with a finding id (makes K3's argv
   clause self-checking).
4. Freeze the trial before the final reading and re-run the counter at the
   frozen sha (D-S3).

## Secret scan

`SECRET-SCAN: hits=11 value_shaped=0` over every receipt/artifact outside
`capture/` (public-docs placeholders quoted in the scout's report/verifier and
in my review, plus the selftest fixture `SID-FIXTURE-1`); no
`hvs.`/`hvb.`/`hvr.`, no `BAO_DEV_ROOT_TOKEN_ID` value, no UUID-shaped
secret_id value, no token header value. The fetched captures carry only
documentation placeholders.

SEAT-STATUS: complete

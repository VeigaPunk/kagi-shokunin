# R59ExecTrial — w1 report (C2 seat: OpenBao transit trial)

Lane kagi, round 59 attempt 1, claim BASE 5fa6e658…, frozen predeclaration
af7b6651 (plans/round-59.md §C2). Seat scope held: one lane file plus seat
receipts/notes; no commits, no sibling paths touched.

## Files

- `corpus/openbao-transit-trial.sh` — the executed trial (only lane write).
- `.ufo/waves/round-59/build/R59ExecTrial/` — receipt-ref-real.txt,
  receipt-ref-real2.txt, receipt-shim-SH1..SH5.txt, receipt-none.txt,
  receipt-cleanroom.txt, notes.md (exact commands, observed error texts,
  deviation ledger D1–D6, `SEAT-STATUS: complete`).

## Behavior

`bash corpus/openbao-transit-trial.sh [--work DIR]` starts one throwaway
`bao server -dev` (127.0.0.1, `setpriv --pdeathsig KILL`, random root token via
env), enables transit, and measures T1 round trip + `vault:v1:` prefix +
plaintext-absence + tamper refusal; T2 rotate → `vault:v2:` + latest_version=2
while v1 still decrypts; T3 rewrap → changed `vault:v2:` ciphertext that
decrypts with no client decrypt, still decrypting at min_decryption_version=2
while the original v1 is refused; T4 named-error refusal of v1 at min=2 and
re-enable at min=1; T5 convergent byte-identity (equal plaintext+context),
context sensitivity, non-convergent contrast. A CLEANROOM leg runs a second
independent dev server (own port/storage) that must refuse server 1's T1
ciphertext. `bao` is resolved through PATH only. All field values ride stdin
JSON bodies; tokens never touch argv or output; every write lands under the
work dir; default work dir is the seat scratch path.

## Measured result (bao v2.7.2, sha pinned in notes.md)

- Two independent real runs: `OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0
  error=0 bao=v2.7.2`, rc 0 (baseline HHHHH).
- SH1..SH5 flip exactly their designated test (BHHHH/HBHHH/HHBHH/HHHBH/HHHHB),
  rc 1, summary BROKEN holds=4 broken=1 error=0.
- No-bao PATH: `OPENBAO_TRANSIT_TRIAL: SETUP no bao on PATH`, rc 2, zero TRIAL
  lines.
- Clean room: second server refuses the first server's T1 ciphertext with
  `encryption key not found` (PASS receipt).

## Findings for the L1 (deviations, all ledgered in notes.md)

1. T4 rotates before raising min_decryption_version: the API refuses a raise
   above latest_version (`cannot set min decryption version of 2, latest key
   version is 1`); the frozen observable is unchanged.
2. Trial prints a sixth line `TRIAL CLEANROOM <verdict> <detail>`; summary
   holds counts T1..T5 only — interface agreed with R59ExecCounterC2 (their
   counter greps `^TRIAL CLEANROOM HOLDS `). POP clean-room conjunct unchanged.
3. Trial does not sha-pin bao (C2-F7 pin must be counter/battery-side); it
   reports `bao=<ver>` from PATH.
4. Measured for the lesson: transit auto-creates an absent key on first
   encrypt in 2.7.2; `bao write <path> -` parses a JSON stdin body (the
   key=value stdin form fails); empty writes need `-f`.
5. Named refusal texts captured: tamper `cipher: message authentication
   failed`; min-version retirement `ciphertext or signature version is
   disallowed by policy (too old)`; clean room `encryption key not found`.

## Coordination

Contract locked with R59ExecCounterC2 (conform, six points); sentinel
R59SentinelTrial pinged when the file went final and is auditing; secret-shape
scan over all receipts = 0 matches; no orphan dev servers left by this seat.

## Risks

- Controls C2-F7/F8 expectations must match the trial's actual split of duties
  (D3 above): F7 counter-side pin, F8 covered by the trial's own
  BAO_*/VAULT_* env scrub at startup (verified by two clean runs).
- One pre-existing host `bao` process (15 h old) and sibling seats' in-flight
  runs were visible during measurements; none interfered (ports are
  bind-probed and pid-verified via ss).

SEAT-STATUS: complete

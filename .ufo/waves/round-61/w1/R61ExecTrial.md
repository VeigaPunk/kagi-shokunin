# R61ExecTrial — seat report (round 61 w1, C2 seal trial)

SEAT-STATUS: complete

## Files changed (all inside my scope)

- `corpus/openbao-seal-trial.sh` — NEW, the executed OpenBao seal / unseal
  key-share custody trial `plans/round-61.md` §C2 declares. 1123 lines,
  sha256 `a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535`.
  `bash corpus/openbao-seal-trial.sh [--work DIR] [--selftest]`; `bao`
  resolved through PATH only; throwaway raft + inmem servers on 127.0.0.1
  under `setpriv --pdeathsig KILL`; per-run work dir wiped by an EXIT trap.
- `.ufo/waves/round-61/build/R61ExecTrial/receipt-{real-1,real-2,shim-SH1..SH5,nobao,selftest,selftest-mutant}.txt`
  and `receipts.md` (index) — the retained evidence, all written this seat.

No other lane file was touched. No commits, no pushes, no mutating git/jj
anywhere. Tooling: nothing installed or upgraded (ambient `bao` v2.7.2,
python3, curl, setpriv, coreutils only); the pacman pause was respected.

## Behavior (frozen POP coverage)

- T1: raft server (`storage "raft"` + node_id/api_addr/cluster_addr,
  tls_disable=1) initialized `-key-shares=5 -key-threshold=3`; asserts
  `unseal_shares=5 unseal_threshold=3` plus 5 distinct 44-char base64 keys
  in the init payload, `initialized=true sealed=true t=3 n=5` in
  `sys/seal-status`, and greps the raft storage path for each share
  (custody: zero matches — shares never persisted).
- T2: CLI unseal — one share `progress=1/3`, SAME share stays `1/3`
  (duplicate refusal), second distinct `2/3`, third `sealed=false t=3 n=5`;
  the T2 detail line carries the counter's literal markers.
- T3: `operator seal` with the root token -> sealed=true; authenticated
  request while sealed -> 503; `sys/seal-status` unauthenticated -> 200.
- T4: `generate-root -init` yields nonce + 26-char OTP + `required=3`;
  three shares via `-nonce=` stdin `-` positional -> progress 1,2,3,
  `complete=true`, encoded token; `-decode=<enc> -otp=<otp>` -> 26-char
  token that authenticates (200 on `/v1/auth/token/lookup-self` and on
  `sys/seal-status`); wrong OTP -> different bytes, refused (code recorded).
- T5: `operator rekey -init -key-shares=3 -key-threshold=2` exits non-zero
  with HTTP 405 `unsupported operation` on the unsealed raft server AND an
  unsealed inmem server (default config, no
  `disable_unauthed_rekey_endpoints` stanza — condition named in the
  header and in receipts.md for reproducibility).
- Shims `KAGI_SEAL_SHIM=SH1..SH5` flip exactly one designated flag
  client-side (SH1 shares, SH2 dup, SH3 auth503, SH4 dec, SH5 mem405);
  unknown shim -> SETUP rc 2; no `bao` on PATH -> `SETUP no bao on PATH`
  rc 2 with no TRIAL/HOLDS line.
- `--selftest`: fixture-driven stub-`bao`+stub-`curl` harness (no OpenBao
  binary, no network, no sockets; state machine simulated from a state file
  the trial exports as `KAGI_SEAL_STUB_STATE`, ignored by the real binary)
  — 63 cases: honest baseline holds=5 exit 0, each shim flipping exactly
  its own test exit 1, injected ERROR exit 2 (vector HEHHE: one broken
  unseal per simulated server), unknown-shim/no-bao/usage SETUP rc 2,
  work-dir cleanliness, shim matrix, verdict/exit mappings, JSON and
  error-text fixtures, no-secret-shape and no-long-base64-run source scans.
  `FINDING SEAL-ST-`-style ids are printed per failed case (the mutant
  receipt shows them live).

## Exact retained evidence (all under `.ufo/waves/round-61/build/R61ExecTrial/`)

- `receipt-real-1.txt`, `receipt-real-2.txt`: both end
  `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`, rc 0,
  byte-identical; T2 markers `progress=1/3 … progress=2/3 sealed=false
  t=3 n=5` present in both.
- `receipt-shim-SH1..SH5.txt`: each `BROKEN holds=4 broken=1 error=0`, rc 1,
  exactly its own test moved — vectors BHHHH / HBHHH / HHBHH / HHHBH /
  HHHHB (baseline HHHHH from the two real receipts).
- `receipt-nobao.txt`: `OPENBAO_SEAL_TRIAL: SETUP no bao on PATH`, rc 2,
  zero TRIAL/HOLDS lines.
- `receipt-selftest.txt`: `SEAL_SELFTEST: PASS (cases=63)`, rc 0 (N >= 8).
- `receipt-selftest-mutant.txt`: mutated copy exits 1 with named findings
  `FINDING F-STUB-SH1-VEC` + `FINDING F-SHIM-MATRIX`
  (`SEAL_SELFTEST: FAIL (cases=63 failed=2)`).
- `receipts.md`: the index above, with the T5 config condition and the
  no-secret attestation.

## Measured build facts this seat contributed (for the lesson/records)

- The 2.7.2 CLI refuses piped unseal material ("file descriptor 0 is not a
  terminal"); the working non-interactive channel for unseal is the share
  as first argument (rc 0, progress semantics intact, duplicate refused);
  generate-root share submission accepts the stdin `-` positional with
  `-nonce=`, keeping those shares off argv.
- Init payload carries `unseal_shares` / `unseal_threshold` (the frozen
  "5 shares and threshold 3 in the init output" is literally assertable);
  shares are 44-char unpadded standard-base64.
- `operator seal` takes no `-format` flag; sealed state must be observed
  via `sys/seal-status`.
- `/v1/token/lookup-self` is a 404 route on this build; the canonical
  self-lookup is `/v1/auth/token/lookup-self` (valid token 200, garbage
  token 403 or 400 depending on the bytes).
- Wrong-OTP `-decode` exits 0 with a different 26-char token (both prior
  peer reports were partially right; the trial asserts only the frozen
  "does not yield that token" and records the refusal code).

## Risks / notes for integration

- `bao=<ver>` tracks the ambient PATH binary (v2.7.2 now); the sha-pin is
  owned by the counter/battery per the frozen plan, as in round 60.
- T5's 405 is configuration-dependent by design of the build; if a future
  lane config ever sets `disable_unauthed_rekey_endpoints=false`, T5's
  honest verdict flips — the condition is named in the trial header and in
  receipts.md so the reading stays reproducible.
- The seat scratch (`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ExecTrial`)
  is deleted before this report yields; nothing citable lived there.

No blockers.

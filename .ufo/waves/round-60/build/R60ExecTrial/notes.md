# R60ExecTrial seat notes — corpus/openbao-approle-trial.sh

Seat: R60ExecTrial (C2 executor, kagi round 60 attempt 1). Claim BASE
`a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`, lane branch master. The frozen
predeclaration `plans/round-60.md` §C2 and
`corpus/lessons/round-59-verifier-spotcheck.md` were read before any work.
Lane write scope held to `corpus/openbao-approle-trial.sh` plus this build
receipt directory. Scratch lived under
`/fast/scratch/hyaku/kagi-r60/R60ExecTrial/` and is deleted before yield.

## What was written

- `corpus/openbao-approle-trial.sh` — the only lane file this seat writes
  (661 lines; `bash`-invocable; `--work DIR`, `--selftest`).
- Receipts (`.ufo/waves/round-60/build/R60ExecTrial/`):
  `receipt-ref-real.txt`, `receipt-ref-real2.txt`, `receipt-shim-SH1.txt`
  .. `receipt-shim-SH5.txt`, `receipt-none.txt`, `receipt-selftest.txt`,
  `receipt-selftest-mutant.txt` (10 files), each = trial stdout+stderr plus
  a final `rc=<n>` line.

## Exact commands

All run from the lane root `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
`bao` reached the trial through PATH only (PATH prefix
`/home/vgpnk/.local/bin`); the trial itself never names an absolute path.

1. Two independent real runs (both HOLDS 5/5, rc 0):
   ```
   PATH="/home/vgpnk/.local/bin:$PATH" bash corpus/openbao-approle-trial.sh \
     --work /fast/scratch/hyaku/kagi-r60/R60ExecTrial/v3-real1
   PATH="/home/vgpnk/.local/bin:$PATH" bash corpus/openbao-approle-trial.sh \
     --work /fast/scratch/hyaku/kagi-r60/R60ExecTrial/v3-real2
   ```
2. Falsifier shims, one env change each (vectors BHHHH / HBHHH / HHBHH /
   HHHBH / HHHHB, rc 1 each, each flipping exactly its designated test):
   ```
   KAGI_APPROLE_SHIM=SH<n> PATH="/home/vgpnk/.local/bin:$PATH" \
     bash corpus/openbao-approle-trial.sh \
     --work /fast/scratch/hyaku/kagi-r60/R60ExecTrial/v3-shim<n>
   ```
3. No-bao PATH (`/usr/bin` and `/bin` carry no bao on this host; the binary
   lives only under `/home/vgpnk/.local/bin`) — `SETUP no bao on PATH`,
   rc 2, zero TRIAL lines:
   ```
   env -i PATH=/usr/bin:/bin bash corpus/openbao-approle-trial.sh \
     --work /fast/scratch/hyaku/kagi-r60/R60ExecTrial/v3-none
   ```
4. Selftest, in the both-flags form the C2 counter uses — PASS (cases=45),
   rc 0. `--selftest` parses before the bao tool checks, so this also runs
   with no bao on PATH:
   ```
   bash corpus/openbao-approle-trial.sh --selftest \
     --work /fast/scratch/hyaku/kagi-r60/R60ExecTrial/v3-selftest
   ```
5. Mutated copy proves the selftest can fail — shim resolution broken on a
   scratch copy (`cp corpus/openbao-approle-trial.sh
   /fast/scratch/hyaku/kagi-r60/R60ExecTrial/mutant-trial.sh`, then in
   `shim_flip` the single line `SH1) [ "$2" = 1 ] && [ "$3" = ctok ] ...`
   changed to `"$2" = 2`, so SH1 matches no declared flag):
   ```
   bash /fast/scratch/hyaku/kagi-r60/R60ExecTrial/mutant-trial.sh --selftest \
     --work /fast/scratch/hyaku/kagi-r60/R60ExecTrial/mutw3
   ```
   → `FINDING F-SHIM-MATRIX` + `APPROLE_SELFTEST: FAIL (cases=45
   failed=1)`, rc 1.

Receipt capture pattern for every run: `> <scratch>/x.out 2>&1; echo
"rc=$?" >> <scratch>/x.out; cp <scratch>/x.out <receipt>`.

## Observed refusal error texts (verbatim)

Captured with a scratch probe copy of the trial (its `named_refusal` logs
the extracted named-error text); all match `plans/round-60.md` §C2 POP:

- T1 — role_id-only login on the default role (bind_secret_id=true):
  400 `missing secret_id`
- T2 — second login with the same secret_id (secret_id_num_uses=1):
  `invalid role or secret ID`
- T3 — same secret_id ≥3 s later (secret_id_ttl=1s):
  `invalid role or secret ID`
- T4 — login after secret-id-accessor/destroy of a still-valid unused
  secret_id: `invalid role or secret ID`
- T5 — 127.0.0.1 login with secret_id_bound_cidrs=10.0.0.0/8:
  `source address "127.0.0.1" unauthorized by CIDR restrictions on the role: %!w(<nil>)`
  (the `%!w(<nil>)` suffix is OpenBao's own Go formatting)
- T1 leg b — update to bind_secret_id=false on the same role, which already
  carries token_bound_cidrs=127.0.0.1/32: SUCCEEDS (no refusal). The
  at-least-one-constraint barrier (`at least one constraint should be
  enabled on the role`) only fires without a constraint, per the L1 A3/A4
  probe recipe; the trial asserts the update is accepted (flag `upd`).

T4 lookup response was verified key-clean: `secret_id_num_uses`,
`secret_id_ttl` present (configured 3 / 600s), no `secret_id` key, and the
raw response does not contain the secret_id value (custody_ok checks all
three in-process).

## Deviations from the frozen POP — findings for the L1

1. Observables: NONE. T1 follows the §A4 recipe (token_bound_cidrs
   constraint on the same role; the frozen text is kept verbatim);
   secret_id_bound_cidrs appears only in T5 (field-disjoint, K4 held).
   T5 leg 2 reuses the SAME role_id+secret_id body after the
   127.0.0.1/32 rebind — measured: the cidr binding is role-level, so the
   frozen "the same login succeeds" is reachable literally (verified with a
   scratch probe before shipping).
2. T3 robustness measure, not an observable change: both immediate legs
   allow up to three attempts, each with a NEWLY generated secret_id. On
   the pre-retry script one battery run read
   `T3 BROKEN imm=1 expref=1 fresh=0` when fleet CPU jitter pushed the
   bao/python round trip past the 1 s TTL — the POP's "a fresh secret_id
   logs in immediately" was otherwise hostage to a >1 s CLI exec. The
   shipped receipts are all from the retry-enabled script; the superseded
   receipt was overwritten in place and the flake is recorded here.
3. Presentation beyond the POP text (per the item spec): TRIAL details are
   k=v flags; named-error strings reach the printed lines only as lowercase
   dash slugs in BROKEN details (e.g. `err2=invalid-role-or-secret-id`);
   the verbatim strings are recorded above from the probe run.

## Secret handling (K3)

The dev root token is an `r60-`+24-hex nonce passed through
BAO_DEV_ROOT_TOKEN_ID (environment, never argv) with `-dev-no-store-token`;
clients use BAO_TOKEN (environment); secret_id values and login bodies
travel stdin pipes fed by env-var python3 builders; bao CLI stderr goes to
files under the per-run work dir, which the trial removes on exit; server
stdout goes to /dev/null. Post-run scan: zero `hvs.`/`hvb.`-shaped strings
and zero root-nonce occurrences across the shipped script and all ten
receipts; the selftest enforces the script-side half (F-NOSECRETSHAPE).

## Tooling authorization record

Operator rules (2026-10-19) read; no tool installed or upgraded — zero
pacman transactions (guard respected), zero uv/npm/cargo installs. Used
only pre-present binaries: bao v2.7.2 (`/home/vgpnk/.local/bin/bao`), bash,
python3, setpriv, ss, coreutils.

SEAT-STATUS: complete

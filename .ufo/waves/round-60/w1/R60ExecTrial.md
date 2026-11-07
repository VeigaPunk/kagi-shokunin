# R60ExecTrial — w1 findings for the L1 (kagi round 60)

Seat: R60ExecTrial (C2 executor). Deliverable: `corpus/openbao-approle-trial.sh`
(the executed OpenBao AppRole secret_id custody trial declared by
`plans/round-60.md` §C2) plus its build receipts. Lane write scope held.
Scratch deleted. Receipts: `.ufo/waves/round-60/build/R60ExecTrial/`
(receipt-ref-real.txt, receipt-ref-real2.txt, receipt-shim-SH1.txt..SH5.txt,
receipt-none.txt, receipt-selftest.txt, receipt-selftest-mutant.txt, notes.md).

## Result against the frozen C2 predicate

- Real runs: HOLDS 5/5 in two independent runs, rc 0 each (bao v2.7.2).
- Shim vectors: baseline HHHHH; SH1→BHHHH, SH2→HBHHH, SH3→HHBHH, SH4→HHHBH,
  SH5→HHHHB — each shim flips exactly its designated test, rc 1 each.
- No-bao PATH: `OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH`, rc 2, zero
  TRIAL lines (env -i PATH=/usr/bin:/bin).
- Selftest: `APPROLE_SELFTEST: PASS (cases=45)`, rc 0; parses before the bao
  tool checks, so `--selftest --work DIR` works with no bao on PATH (the C2
  counter's invocation form).
- Selftest can fail: a scratch-mutated copy with broken shim resolution
  (SH1 remapped to a flag no test declares) prints `FINDING F-SHIM-MATRIX`
  and exits 1 (receipt-selftest-mutant.txt).
- Secret hygiene: no token / secret_id value / secret-shaped string / request
  body on any argv or printed line; post-run scan of the script and all ten
  receipts is clean; root token is an env-passed `r60-` nonce with
  `-dev-no-store-token`; server stdout to /dev/null; per-run work dir removed
  on exit.

## Measured refusal texts (POP-faithful)

T1 `missing secret_id` (400, role_id-only on default bind_secret_id=true);
T2/T3/T4 `invalid role or secret ID`; T5 `source address "127.0.0.1"
unauthorized by CIDR restrictions on the role: %!w(<nil>)` (OpenBao's own
formatting). T1's leg-b update (bind_secret_id=false on a role already
carrying token_bound_cidrs=127.0.0.1/32) is accepted — the constraint
barrier only fires without a constraint, per the §A3/§A4 probe recipe.

## Deviations / findings for the L1

1. Frozen POP observables: none violated. T1 keeps the frozen text via the
   §A4 recipe (token_bound_cidrs constraint, same role, same body);
   secret_id_bound_cidrs is T5-only (K4 field-disjointness held). T5 leg 2
   reuses the SAME role_id+secret_id body after the 127.0.0.1/32 rebind —
   measured to succeed, so the frozen "the same login succeeds" is literal
   (cidr binding is role-level).
2. T3 carries bounded fresh-sid retries (≤3 attempts, each a newly generated
   secret_id) on its two immediate legs: one pre-retry battery run read
   `T3 BROKEN ... fresh=0` when fleet CPU jitter pushed the CLI round trip
   past the 1 s TTL. All shipped receipts come from the retry-enabled
   script; the superseded receipt was overwritten in place. This is a
   robustness measure inside the POP mechanic, not a reinterpretation.
3. Named-error strings appear in printed lines only as lowercase dash slugs
   in BROKEN details; verbatim texts are recorded in notes.md.

## C2-counter interface facts (already confirmed to R60ExecCounterC2)

- Summary prefix: `OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0`
  followed by ` bao=<ver>`.
- Per-test lines: `TRIAL T<n> HOLDS|BROKEN|ERROR k=v ...` exactly once each.
- Shim env: `KAGI_APPROLE_SHIM=SH<n>`; unrecognised values are SETUP rc 2
  before any server starts.
- Selftest: rc 0 + single `APPROLE_SELFTEST: PASS (cases=N)`, N=45.

SEAT-STATUS: complete

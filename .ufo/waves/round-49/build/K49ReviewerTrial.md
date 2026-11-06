# K49ReviewerTrial — semantic review of the C1 OpenBao trial against S016

Reviewer seat: K49ReviewerTrial (round 49, kagi lane). Scope: does each test T1–T5 of
`.ufo/waves/round-49/controls/fixtures/openbao-token-trial.ref.sh` measure the S016
sentence that `plans/round-49.md` §C1 cites? The trial fixture and the entry were
treated as read-only; every finding below is a review observation, nothing was edited.

## Method and receipts

- S016 re-fetched 2026-11-06: <https://openbao.org/docs/concepts/tokens/>, page label
  "Version: Version 2.7.x" — same version band the entry cites.
- Binary: `~/.local/bin/bao` OpenBao v2.7.2, sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`
  (equals the plan's pin). No tool was installed or upgraded for this seat.
- Reference trial, run once in scratch (`$HYAKU_SCRATCH/kagi-r49/K49ReviewerTrial/w`):
  `bash .ufo/waves/round-49/controls/fixtures/openbao-token-trial.ref.sh --work $S/w`
  → exit **0**, last line `OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`,
  stderr empty. Receipt: `K49ReviewerTrial/ref.out` (+ `ref.err`, 0 bytes).
- Six review probes (this dir, `probe-t1.sh`…`probe-t5.sh`, `probe-errs.sh`), each with
  its own throwaway `bao server -dev` on a random 127.0.0.1 port, random root token,
  HOME redirected into scratch, token values and passwords never printed (mask: root →
  `<ROOT>`, token-shaped strings → `<TOKEN>`, password → `<PW>`), server killed by EXIT
  trap. All exited 0; stderr 0 bytes each. Receipts: `probe-t1.out`…`probe-t5.out`,
  `probe-errs.out`. A dead lease id in `probe-t5.out` was replaced with `<LEASEID>`.
- Ownership check after all runs: 0 `bao server` processes under this seat's scratch
  (all servers my scripts started were killed by their traps); remaining host `bao`
  processes belong to sibling seats and were left untouched.
- Scratch dir and all fixture state removed before yield.

## S016 anchors (quotes as served 2026-11-06)

- §Token Time-To-Live, periodic tokens, and explicit max TTLs: "Every non-root token
  has a time-to-live (TTL) … After the current TTL is up, the token will no longer
  function -- it, and its associated leases, are revoked."
- §Explicit max TTLs: "This value becomes a hard limit on the token's lifetime -- no
  matter what the values in (1), (2), and (3) from the general case are, the token
  cannot live past this explicitly-set value."
- §Token hierarchies and orphan tokens: "When a parent token is revoked, all of its
  child tokens -- and all of their leases -- are revoked as well." Orphan tokens are
  created by 4 routes, the fourth being "By logging in with any other (non-`token`)
  auth method".
- §Token type comparison table: Batch Tokens — "Can be Renewable: No", "Manually
  Revocable: No", "Has Accessors: No".
- §Service tokens (lease handling): "Leases created by service tokens (including child
  tokens' leases) are tracked along with the service token and revoked when the token
  expires."

## Per-test verdicts

### T1 — verdict: measures-with-narrowing

Cited sentence: "Every non-root token has a time-to-live … After the current TTL is
up, the token will no longer function" (§Token Time-To-Live).

- The trial observes `token lookup` succeed pre-lapse and fail post-lapse for one
  ttl=2s token. The exit-status observable alone cannot distinguish "expired" from any
  other denial: probe-errs shows the actual failure is `Code: 403. Errors: * permission
  denied` (`GET /v1/auth/token/lookup-self`) — the error text does not name expiry.
- Cause attribution therefore rests on design isolation: between the two lookups the
  only manipulated variable is elapsed time (no other actor exists in the sealed dev
  server). Probe-t1 sharpens this with a contrast the trial itself lacks: a ttl=60s
  token created in the same server stays alive through the same ~4 s window
  (`ttl60.ttl-at-0=59s alive@~4s=1`), so the wait does not kill tokens — the lapse does.
- "Every" is not exhaustively exercised (one token class, one TTL value), but
  probe-t1 also shows a token created with no `-ttl` gets the finite dev default
  (`default-token.ttl=2764799s` ≈ 32 d − 1 s), i.e. no non-root token observed is
  open-ended.
- Tightening note (fail-safe direction): if the first lookup ever happened after the
  2 s TTL, T1 reports BROKEN, never a silent HOLDS.

### T2 — verdict: measures

Cited sentence: explicit max TTL "becomes a hard limit on the token's lifetime" (§Explicit max TTLs).

- `auth.lease_duration` of the renew response is the right granted-TTL field:
  probe-t2 shows capped token `renew(increment=3600) → granted=5`, and the same
  token's post-renew lookup reads `ttl=4 explicit_max_ttl=5` — lookup ttl tracks the
  response's lease_duration (1 s decay), so the response number is the token's new TTL.
- The ≤5 s is attributable to the cap, not to server defaults: the contrast token
  without `-explicit-max-ttl` renews `increment=3600 → granted=3600` on the same dev
  server (whose system max is 32 d, cf. T1's default-token ttl 2764799 s).
- Hard-cap enforcement is measured, not just granted-size: `alive@+7s=0` past the 5 s
  cap (ref trial line: `granted=5 alive-after-7s=0`).

### T3 — verdict: measures

Cited sentence: batch tokens — "Can be Renewable: No", "Manually Revocable: No" (§Token type comparison).

- The failures are batch-specific, not incidental. probe-errs records the server's own
  reasons, all `Code: 400`: renew-self → `* batch tokens cannot be renewed`;
  revoke by ID as **root** → `* batch tokens cannot be revoked`; revoke-self →
  `* batch tokens cannot be revoked`. Root as the revoking caller removes "permission
  was missing" as an alternative cause; prefix check `prefix-is-b.=1` confirms the
  token really is a batch token.
- `alive-after-all=1` (probe-t3) shows the token survived three failed mutations — the
  observables are refusals, not collateral destruction.
- The trial's `renew-ok=0` (self) plus `revoke-ok=0` (root, by ID) covers the two
  table cells; probe-t3 adds revoke-self. Accessor revocation is out of scope
  consistently with the same table ("Has Accessors: No").
- Control that the same operations succeed for service tokens lives inside the trial
  itself: T2 renews and T4 revokes service tokens with the same caller patterns.

### T4 — verdict: measures

Cited sentence: orphans are created "By logging in with any other (non-`token`) auth
method", and "When a parent token is revoked, all of its child tokens … are revoked as
well" (§Token hierarchies and orphan tokens).

- probe-t4 isolates the creation path as the only difference: parent token
  `orphan=false`; child created via `auth/token/create` `orphan=false`; token obtained
  by userpass login (same caller) `orphan=true`. So `orphan=true` on the login token is
  specific to the non-token auth route — exactly list item 4 — not a property of the
  caller or of lookup.
- The tree semantics are measured, not assumed: after `token revoke <parent>`,
  `child-alive=0` and `login-alive=1` — the child dies with the parent while the
  orphan does not, in the same server, same parent.
- This pair is also what the counter's SH4 shim attacks (login replaced by a child
  token → `orphan=false`/dies-with-parent → T4 BROKEN), so the observable discriminates.

### T5 — verdict: measures (contrast run; receipt probe-t5.out)

Cited sentence: "After the current TTL is up, the token will no longer function -- it,
and its associated leases, are revoked" (§Token Time-To-Live), reinforced for service
tokens by "Leases created by service tokens … are tracked along with the service token
and revoked when the token expires" (§Service tokens).

- Required contrast, executed: identical issuance (same PKI mount, root, role
  `generate_lease=true`, lease `ttl=10m`) under a long-lived token —
  `long-token(ttl=30m): lease alive@0=1 alive@+5s=1 remaining-ttl=594s` versus
  `short-token(ttl=3s): lease-own-ttl-at-issue=599s alive@0=1 alive@+5s=0`.
  The lease's own TTL (599 s at issue) makes self-expiry impossible at 5 s, and the
  long-token branch rules out unconditional/immediate PKI lease revocation; the only
  remaining differentiator is the issuing token's lapse.
- The lease-revocation observable is server-state, not a lookup artifact: the
  long-token lease lookup succeeds on the same server seconds later.
- The trial itself does not contain this contrast, but its designated falsifier SH5
  (`token create` drops `-ttl` → token outlives the lease → `lease-after=1` → BROKEN)
  is the built-in version of it; the counter therefore carries the same discriminating
  power the manual contrast demonstrates.

## Narrowings the entry's `## Measured (round 49 …)` section must carry

1. **Dev mode only**: `bao server -dev`, in-memory storage, no persistence, dev root
   token; created tokens carry the dev default policy and the dev default system max
   TTL (observed default token TTL 2764799 s ≈ 32 d); `-dev-no-store-token`.
2. **One host, one release, loopback only**: OpenBao v2.7.2 linux_amd64 (sha256
   `9c5f3628…` per the plan's pin) on 127.0.0.1; no cluster, no seal, no production
   storage backend.
3. **CLI surface only**: every observable goes through the `bao` CLI (this is also
   what keeps the counter's shims meaningful); the HTTP API was driven by the server
   but never by the tests; `bao login -method=userpass -no-store` used for T4.
4. **Wall-clock margins, not boundary measurement**: TTLs 2 s/3 s/5 s against sleeps
   4 s/7 s/5 s; the exact lapse instant and sub-second behavior are unmeasured; under
   extreme load the design fails toward BROKEN/ERROR, not silent HOLDS.
5. **T1**: refusal is measured as lookup exit status; the 403 body reads `permission
   denied` (probe-errs), so expiry is attributed by isolation (only time changes),
   one token class and one TTL value sampled; "every non-root token" is the doc's
   quantifier, not the trial's.
6. **T3**: manual-revocation coverage = renew-self, revoke-by-ID (root), revoke-self
   (probe-errs); accessor revocation excluded (batch tokens have no accessor, same
   S016 table).
7. **T4**: userpass is the single non-token auth method sampled; S016's "any other
   (non-token) auth method" is not exhaustively exercised.
8. **T5**: PKI-issued certificate is the only leased-secret class; the long-lived-token
   contrast exists in the review probes and in falsifier SH5, not in the trial body.

## Residual risk

- T1's failure text (`permission denied`) would also cover a concurrent manual
  revocation; in the trial's sealed single-actor server that alternative has no actor,
  but the entry should not claim the *error text* identifies expiry.
- All findings are one-release (v2.7.2), one-host, dev-mode facts; the entry's
  `recheck: on-release` clock is what re-opens them.
- No counter/instrument was modified; nothing in this report edits corpus/, plans/, or
  the fixture (routed findings only, per the round's freeze).

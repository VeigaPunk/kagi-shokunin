Author: R70Scout (scout)

# R70Scout — round-70 frontier reconnaissance for the OpenBao PKI engine

Seat: scout (frontier), lane `kagi`, wave `kagi-r70-w1`, round 70 attempt 1.
Claim under review: **C1 coverage (capability acquisition)** — `C1_PKI_TRIAL: value = number of
tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and
NOLEAK = 1 and SOURCED = 1, else 0; target 5 (BASE 0).` Counting command:
`bash plans/round-70-c1.sh <rev>` from `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

**This seat does not judge C1's value.** It maps the frontier the round did *not* measure, as the
seat brief asks. No registry rows were written; no plan, counter, trial or entry was edited; no
mutating git/jj command was run in the lane or the fleet repo; no `bao server` survived the seat.

## What I did

1. Read the frozen plan, the frozen counter, the landed trial, the landed entry, the lane's quality
   bar, and the eight executed pre-freeze control receipts.
2. Opened the OpenBao PKI API page (S170, lane-committed capture), the engine overview (S171,
   lane-committed), and — newly — the operator **considerations** page and the **rotation-primitives**
   page, captured into this seat's dir as `capture/S173-…body` and `capture/S174-…body`
   (no registry rows written, per the seat brief).
3. Executed a throwaway `bao server -dev` (127.0.0.1, in-memory, random root token kept in scratch
   and never printed) and **measured** which unmeasured mechanics the engine actually exposes:
   `probe-frontier-final.sh` + `probe-frontier-focused.sh`, receipts in `receipts/`.
4. Located every quote the frontier cites against a committed capture body with the **lane's own
   committed normalizer** (`corpus/rendered-text-v1.py`, imported as a module — not re-implemented):
   `quote-locate-frontier.py` → `receipts/quote-locate-frontier.txt`, exit 0, **22/22 quotes located**.

## Deliverable

**`.ufo/waves/round-70/w1/R70Scout/frontier.md`** — ten mechanics the round did not measure, each with
doc URL + section anchor, a ≤25-word located quote, why it matters for credential custody, whether a
throwaway dev-server test can measure it, and the falsifier shim that would flip it.

### The ten (short form)

| # | mechanic | anchor | measurable? | headline measurement (2.7.2, dev server) |
|---|---|---|---|---|
| F1 | `leaf_not_after_behavior` (err/truncate/permit) | S170 §Update issuer (`leaf_not_after_behavior`) | **yes**, 3-way | `permit` → leaf outlives issuer (2109546188 > 1796778188); `truncate` → clipped to issuer; `err` → refused |
| F2 | `sign-intermediate` (intermediate CA + chain) | S170 §Sign intermediate | **yes** | HTTP 200, `ca_chain` length 2 |
| F3 | **where a revoked leaf of a non-default issuer lands** | S170 §Multi-issuer notice / §Revoke issuer; S173 §Always configure a default issuer | **yes** | serial **absent** from the default CRL, **present** on its own issuer's CRL (control: default-issuer leaf present on the default CRL) |
| F4 | auto-tidy + the four safety buffers | S170 §Tidy / §Set automatic tidy configuration | **yes** (config) | read-back `safety_buffer=259200`, `revoked_safety_buffer=259200`, `issuer_safety_buffer=31536000`, `acme_account_safety_buffer=2592000` |
| F5 | OCSP (unauthenticated revocation channel) | S170 §OCSP request | **yes** | no token: `good` → after revoke `revoked` |
| F6 | delta CRLs | S170 §Rotate delta CRLs | **partially** | `enable_delta_crl` write 200, delta read 200 but **empty payload** in this sequence |
| F7 | ACME (unauthenticated front door, `eab_policy`, required headers) | S170 §ACME required headers / §Set ACME configuration; S173 §ACME role restrictions require EAB | **yes** (not issuance) | directory 200 with no token, `externalAccountRequired=false`, `default_directory_policy=sign-verbatim`, `eab_policy=not-required`; `new-account` **201**; `new-order` **201**; `Replay-Nonce` absent until the mount is tuned |
| F8 | CEL roles (operator-written issuance policy) | S170 §Create/Update CEL role | **yes** | role create 200; `POST /pki/cel/issue/celrole` 200, response carries `private_key` |
| F9 | `revoke-with-key` (proof-of-possession revocation for `no_store` leaves) | S170 §Revoke certificate with private key | **yes** | HTTP 200, `state=revoked` |
| F10 | `key_usage` / `ext_key_usage` on the leaf | S170 §Create/Update role | **yes** | leaf carries `Key Usage: critical / Digital Signature, Key Encipherment` and `Extended Key Usage: / TLS Web Server Authentication, TLS Web Client Authentication` |

### Two supporting observations (measured, not counted as frontier rows)

- **Unauthenticated read surface**: no token → `GET /v1/pki/certs` **403**, `GET /v1/pki/roles` **403**,
  `GET /v1/pki/cert/crl` **200**, `GET /v1/pki/cert/ca` **200**. The CRL and the CA cert are public; the
  certificate inventory is not.
- **Unresolved by this seat**: `POST /pki/sign-verbatim` with a `CA:TRUE` CSR returned HTTP 200 where the
  doc says the endpoint refuses intermediate CA certificates; the issued cert's `basicConstraints` read
  back empty. Whether OpenBao drops the CA flag or issues a CA certificate is **not established** here.

### Which frontier row is worth the next round's coverage

**F3** is the highest-value unmeasured custody property: the round's own T4 measures revocation only for
the **default** issuer, and a leaf issued by a **non-default** issuer (the normal shape during a CA
rotation) does **not** reach the mount's default CRL — a relying party that fetches only `pki/cert/crl`
sees that serial as live. F1 and F9 close two gaps the landed entry explicitly lists under
"Does not establish". F7 is the largest attack surface the lane has never touched, but a full
measurement needs ACME challenge-fulfilment scaffolding, so it is a two-round item.

## Notes for the integrator

- The five shims the frozen counter uses are all **client-side argument edits** on `bao write`. Every
  falsifier shim I propose for F1–F10 is the same shape (a PATH-level `bao` wrapper that rewrites one
  write's arguments or path), so none of the ten rows needs a new instrument class — a successor trial
  can be written in the existing style.
- One trap recorded so it is not re-learned: my probe's CEL program had **two identical branches**
  (`cn != "" && small ? out : out`), so the `ttl<4h` clause was never enforced and the `ttl=10h`
  request was served. That measurement proves nothing about CEL's refusal behaviour; a real test needs
  two *different* branches and must assert the refusal.
- Two rounds of probe scripts were needed because the first attempts mis-modelled the API (JSON bodies
  sent as CLI `k=v` pairs, `bao list` returning a JSON array rather than `{data:{keys:[]}}`, and the
  per-issuer CRL endpoint returning `crl` rather than `certificate`). The final scripts are the only ones
  kept in the seat dir; the earlier iterations were deleted.
- Tooling: **no tool was installed or upgraded by this seat** — `bao` 2.7.2, `openssl` 3.6.5 and
  `python3` + `cryptography` 50.0.2 were already present. The generic pacman channel is PAUSED host-wide
  and no install was needed.

## Bounds of this seat's own claims

- Everything measured is **OpenBao 2.7.2 on a throwaway `bao server -dev`** (127.0.0.1, in-memory,
  synthetic `r70.test` names, one `pki` mount). Nothing here is a claim about a deployed mount, an
  HSM/KMS-backed issuer, a multi-node cluster, or any OpenBao release other than 2.7.2.
- Every doc quote is located against a **committed capture body** with the lane's committed normalizer
  (`receipts/quote-locate-frontier.txt`), but a located quote is not a claim that the quote supports
  the custody statement beside it; the measurements stand on their own.
- No private key, root token, EAB HMAC key or certificate body appears in this report or in any file
  this seat wrote.

FINDING SC-1 neutral Round-70's T4 measures revocation only for the default issuer; a leaf of a non-default issuer revoked on 2.7.2 was absent from the mount's default CRL and present on its own issuer's CRL, an unmeasured rotation-custody gap (frontier.md F3).
FINDING SC-2 neutral leaf_not_after_behavior is per-issuer, not per-role, and the three values behave three ways on 2.7.2 (permit outlives the issuer, truncate clips, err refuses), a custody contract the landed entry does not establish (frontier.md F1).
FINDING SC-3 neutral revoke-with-key restores revocation for no_store leaves and is documented as not privileged by design yet authenticated by policy, so the ACL is the custodian's only control (frontier.md F9).
FINDING SC-4 neutral ACME's directory and new-account/new-order succeed with no OpenBao token under the default sign-verbatim/not-required policy, an unauthenticated issuance front door the lane has never touched; full issuance was not measured (frontier.md F7).
FINDING SC-5 neutral role ext_key_usage=serverAuth produced a leaf also carrying TLS Web Client Authentication on 2.7.2, an inference from one observation that a successor trial should confirm before it is written down (frontier.md F10).
FINDING SC-6 neutral the delta CRL endpoint answers 200 after enable_delta_crl but the payload was empty in the measured sequence, so delta-CRL content is measurable only with an explicit rotate-delta in the same run (frontier.md F6).
FINDING SC-7 neutral sign-verbatim returned HTTP 200 for a CA:TRUE CSR where the doc says it refuses intermediate CA certificates, so that refusal is not established on 2.7.2 by this seat (frontier.md, supporting observations).
FINDING SC-8 neutral auto-tidy exposes four independent retention windows (safety_buffer, revoked_safety_buffer, issuer_safety_buffer, acme_account_safety_buffer) whose values decide how long a revocation stays evidenced, none of which the landed entry establishes (frontier.md F4).
FINDING SC-9 neutral the mount serves pki/cert/crl and pki/cert/ca unauthenticated while pki/certs and pki/roles answer 403, a public-revocation-surface fact the landed entry does not record (frontier.md, supporting observations).
FINDING SC-10 neutral ten unmeasured mechanics are each measurable on a throwaway dev server with the round's existing client-side shim style, and every falsifier proposed for them is a PATH-level bao wrapper that rewrites one write (frontier.md F1-F10).
SEAT-STATUS: complete frontier.md written with ten located-quote mechanics, their dev-server measurements, and their falsifier shims; no registry rows, no plan/counter edits, no surviving dev server

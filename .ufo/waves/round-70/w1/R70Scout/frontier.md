# Round 70 frontier — OpenBao PKI mechanics beyond the five the round measured

Author: R70Scout (scout)
Seat dir: `.ufo/waves/round-70/w1/R70Scout/`
Lane: `kagi` (`/home/vgpnk/Projects/shokunin/kagi-shokunin`), BASE `7bd34832c94b81d4cf9bf34113c4952a7f6d9b04`, candidate `0d225553c22f686df24454040102d0502eda5c42`
Binary: OpenBao 2.7.2 official release binary `~/.local/bin/bao` (sha256 `9c5f3628…41b788`, the round's pin), `openssl 3.6.5`, `python3` 3.14 with `cryptography` 50.0.2 (already installed; **no tool was installed or upgraded by this seat**).
Tool installs this round: none.

## What round 70 measured, and what this frontier adds

Round 70's five mechanics (frozen plan `plans/round-70.md`, trial `corpus/openbao-pki-trial.sh`) are
**T1 root-internal**, **T2 ttl-clamp**, **T3 domain-refuse**, **T4 revoke-crl**, **T5 no-store**.
Every row below is a mechanic of the same OpenBao PKI engine that T1–T5 did **not** touch, and each
row carries: the doc URL and section anchor, a located quote (≤25 words), why it matters for credential
custody, and whether a throwaway dev-server test could measure it — with the falsifier shim that would
flip it.

**Every row's quote is located** against a committed capture body with the lane's committed normalizer
(`corpus/rendered-text-v1.py`), by `python3 .ufo/waves/round-70/w1/R70Scout/quote-locate-frontier.py`
(receipt `receipts/quote-locate-frontier.txt`, exit 0, 22/22 quotes located, offsets recorded there).

**Every row's "measured" column is an executed observation** on a throwaway `bao server -dev`
(127.0.0.1, in-memory, random root token kept in scratch and never printed), from
`probe-frontier-final.sh` / `probe-frontier-focused.sh` (receipts
`receipts/probe-frontier-final.txt`, `receipts/probe-frontier-focused.txt`). Every dev server was
killed by the probe's own EXIT trap; no `bao server` process survived the seat
(`pgrep -af "bao server"` → empty at write time).

## Sources

| id | URL | body in this seat dir | what it is |
|---|---|---|---|
| S170 | https://openbao.org/docs/api/secret/pki/ | `.ufo/waves/round-70/capture/S170.body` (lane-committed, round-70 capture) | the PKI secrets-engine **API** reference (2.7.x) |
| S171 | https://openbao.org/docs/secrets/pki/ | `.ufo/waves/round-70/capture/S171.body` (lane-committed) | the engine overview |
| S173 | https://openbao.org/docs/secrets/pki/considerations/ | `.ufo/waves/round-70/w1/R70Scout/capture/S173-openbao-pki-considerations.body` | operator considerations (fetched this seat, 2026-11-08, sha256 `42ef7582…5047a`, 96207 B) |
| S174 | https://openbao.org/docs/secrets/pki/rotation-primitives/ | `.ufo/waves/round-70/w1/R70Scout/capture/S174-openbao-pki-rotation-primitives.body` | rotation primitives (fetched this seat, 2026-11-08, sha256 `406c85ec…1d2e`, 64986 B) |

S173/S174 are **captures only** — this seat writes **no registry rows** (seat brief). A successor round
that admits them would mint the next free S-ids itself.

## The frontier mechanics

### F1 — `leaf_not_after_behavior`: whether a leaf may outlive its issuer

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Update issuer, named anchor `leaf_not_after_behavior`
- **Quote (SC-Q1, S170, normalized offset 92868)**: "Behavior of a leaf's NotAfter field during issuance."
- **Why it matters for custody**: it is the one knob that decides whether an issued leaf can claim a
  validity window *longer than the signing CA's own*, i.e. whether a credential's promised lifetime is
  bounded by the issuer's remaining life. Three behaviours (`err`, `truncate`, `permit`) are three
  different custody contracts, and they are set **per issuer**, not per role — a role operator cannot
  see them by reading the role.
- **Measured (OpenBao 2.7.2, dev server)**: with a 30-day issuer (`expiration=1796778188`) and a role
  whose `max_ttl=87600h`, a 365-day request behaved differently per setting —
  `permit` → issued, `leaf_expiration=2109546188` (**past** the issuer's expiry);
  `truncate` → issued, `leaf_expiration=1796778188` (silently clipped to the issuer);
  `err` → **refused** (`issue_rc=2`, no certificate).
  Receipt: `receipts/probe-frontier-focused.txt` (F1.* rows).
- **Dev-server measurable?** **Yes** — fully, and it discriminates three ways.
  **Falsifier shim**: a PATH-level `bao` wrapper that, on `write pki/issuer/*`, appends
  `leaf_not_after_behavior=err` (or drops the caller's value): the `permit`/`truncate` leaf then either
  fails to issue or comes back clipped, so the "leaf may outlive its issuer" verdict flips to BROKEN
  while every other test keeps its verdict.

### F2 — `sign-intermediate`: issuing an intermediate CA and the chain it returns

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Sign intermediate (`#sign-intermediate`)
- **Quote (SC-Q2, S170, offset 26748)**: "This endpoint can be used both when signing an OpenBao-backed intermediate or when signing an externally-owned intermediate."
- **Quote (SC-Q3, S170, offset 26888)**: "This is a privileged endpoint, as callers are granted a new intermediate certificate, with which they can issue for arbitrary names."
- **Why it matters for custody**: this is the **custody handoff** — the moment a CA signing key and the
  right to sign *arbitrary names* leave the root and become a portable artifact. Its blast radius is
  larger than any leaf issuance in the mount, and its ACL is a policy decision, not a role setting.
- **Measured (2.7.2)**: `POST pki/root/sign-intermediate` with a synthetic CSR → **HTTP 200**,
  response `ca_chain` length **2** (leaf-side chain root→intermediate), i.e. the mount builds and
  returns the chain a client needs to trust only the root. Receipt: `receipts/probe-frontier-final.txt` (F2).
- **Dev-server measurable?** **Yes.**
  **Falsifier shim**: a wrapper that rewrites the `*/root/sign-intermediate` path to `*/root/generate/internal`
  (or no-ops the call): `ca_chain` then does not carry the intermediate, and the "the mount hands back a
  usable chain" verdict flips to BROKEN while the other tests keep theirs.

### F3 — where a revoked certificate lands when its issuer is **not** the default issuer

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Notice about new Multi-Issuer functionality
  (`#notice-about-new-multi-issuer-functionality`), §Revoke issuer (`#revoke-issuer`);
  https://openbao.org/docs/secrets/pki/considerations/ — §Always configure a default issuer (`#always-configure-a-default-issuer`)
- **Quote (SC-Q20, S170, offset 2556)**: "OpenBao allows a single PKI mount to have multiple Certificate"
- **Quote (SC-Q5, S173, offset 5540)**: "When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL."
- **Why it matters for custody**: this is the **rotation** case, and it is the one T4 never reached: T4
  revokes a leaf of the *default* issuer and reads the mount's CRL. If a leaf is issued by a **non-default**
  issuer (the normal shape during a CA rotation), the revocation does **not** reach the mount's default
  CRL — so a relying party that fetches only `pki/cert/crl` (the path T4 measures) sees a *live* serial
  for a certificate the mount has revoked. Rotation and revocation are the same custody problem.
- **Measured (2.7.2)**: two roots in one mount (`r70root` default, `r70second` non-default), a leaf
  issued by `r70second`, then revoked: the serial was **absent** from the default CRL
  (`pki/cert/crl`) and **present** on its own issuer's CRL (`pki/issuer/<id>/crl`, openssl-parsed); the
  control (a leaf of the default issuer, revoked) was **present** on the default CRL.
  Receipt: `receipts/probe-frontier-final.txt` (F3).
- **Dev-server measurable?** **Yes.**
  **Falsifier shim**: a wrapper that drops `serial_number=` from `write pki/revoke` (the revoke never
  lands anywhere): the serial then appears on **no** CRL, the F3 verdict flips to BROKEN, and — because
  the control leaf is also affected — a trial must check the two serials separately to keep the verdict
  specific.

### F4 — auto-tidy and the safety buffers that decide when custody records are destroyed

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Tidy (`#tidy`),
  §Set automatic tidy configuration (`#set-automatic-tidy-configuration`)
- **Quote (SC-Q17, S170, offset 145470)**: "This endpoint allows tidying up the storage backend and/or CRL by removing certificates that have expired and are past a certain buffer period"
- **Quote (SC-Q6, S170, offset 145678)**: "Note: it is encouraged to use the automatic tidy capabilities to ensure this gets run periodically."
- **Why it matters for custody**: tidy is the only documented way the mount **destroys** its own
  custody records (certificates, revoked entries, ACME orders). The `safety_buffer`,
  `revoked_safety_buffer`, `issuer_safety_buffer` and `acme_account_safety_buffer` are the four
  retention windows, and they decide how long a revocation is still *evidenced* after the certificate
  expired — i.e. how long an auditor or a relying party can still see that something was revoked.
- **Measured (2.7.2)**: `POST pki/config/auto-tidy` with `enabled=true, tidy_cert_store=true,
  tidy_revoked_certs=true, safety_buffer=72h` → HTTP 200; the read-back configuration carries
  `safety_buffer=259200`, `revoked_safety_buffer=259200`, `issuer_safety_buffer=31536000`,
  `acme_account_safety_buffer=2592000` (seconds). Receipt: `receipts/probe-frontier-final.txt` (F5).
- **Dev-server measurable?** **Yes** for the configuration surface; the *effect* (an expired entry
  actually being removed) needs a short-lived certificate and a short buffer, so a trial can reach it but
  must pay for the wall-clock.
  **Falsifier shim**: a wrapper that drops the `pki/config/auto-tidy` write (or rewrites
  `safety_buffer=72h` → `safety_buffer=0s`): the read-back buffer then reads absent/zero and the
  "the retention window is what the operator set" verdict flips to BROKEN.

### F5 — OCSP: the unauthenticated revocation-status channel

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §OCSP request (`#ocsp-request`)
- **Quote (SC-Q7, S170, offset 61726)**: "This endpoint retrieves an OCSP response (revocation status) for a given serial number."
- **Quote (SC-Q19, S170, offset 62017)**: "Only a single serial number within the request will appear in the response"
- **Why it matters for custody**: OCSP is how a relying party learns a serial is dead **without polling
  the CRL**. Two custody facts ride on it: the channel is **unauthenticated** (so anyone can ask), and
  the implementation returns **one serial per response** (so a bulk check needs one request per
  certificate — a load property, and a completeness property for anyone relying on it).
- **Measured (2.7.2)**: `openssl ocsp` against `POST /v1/pki/ocsp` with **no token** → status `good`;
  after `pki/revoke serial_number=<serial>` → status **`revoked`** (same URL, still no token).
  Receipt: `receipts/probe-frontier-final.txt` (F7).
- **Dev-server measurable?** **Yes.**
  **Falsifier shim**: the counter's existing **SH4 revoke-swallowed** shim is exactly this row's
  falsifier — with the revoke swallowed, the OCSP response stays `good` after the "revoke" and F5's
  verdict flips to BROKEN while the other four tests keep theirs.

### F6 — delta CRLs

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Rotate delta CRLs (`#rotate-delta-crls`),
  §Read CRL configuration / §Set CRL configuration (`#set-crl-configuration`)
- **Quote (SC-Q8, S170, offset 140255)**: "This endpoint forces a rotation of all issuers' delta CRLs, when enabled."
- **Why it matters for custody**: a delta CRL is the *incremental* revocation channel: a relying party
  that has the base CRL can learn about new revocations without refetching the whole list. It is off by
  default (`enable_delta_crl` in the CRL configuration), so a mount that believes it is publishing delta
  CRLs may publish none.
- **Measured (2.7.2)**: `POST pki/config/crl {"enable_delta_crl":true}` → HTTP 200; `GET pki/crl/delta`
  → HTTP 200 **but with an empty payload in these runs** (the delta CRL had not been built in this
  sequence). **Partial** — the *endpoint and the switch* are measurable; the *content* is not yet
  measured by this seat and a trial must assert payload bytes, not just an HTTP status.
  Receipt: `receipts/probe-frontier-final.txt` (F6).
- **Dev-server measurable?** **Partially** — yes for the switch and the endpoint; content needs an
  explicit `crl/rotate-delta` plus a base-CRL regeneration in the same run.
  **Falsifier shim**: a wrapper that drops `enable_delta_crl=true` from the `pki/config/crl` write
  (or rewrites `pki/crl/rotate-delta` to `pki/crl/rotate`): the delta read then yields the base
  behaviour/empty payload and the verdict flips.

### F7 — ACME: an unauthenticated issuance channel with an operator-chosen policy

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §ACME required headers
  (`#acme-required-headers`), §Get ACME EAB binding token (`#get-acme-eab-binding-token`),
  §Set ACME configuration (`#set-acme-configuration`);
  https://openbao.org/docs/secrets/pki/considerations/ — §ACME role restrictions require EAB
  (`#acme-role-restrictions-require-eab`), §Automate rotation with ACME (`#automate-rotation-with-acme`)
- **Quote (SC-Q9, S170, offset 3755)**: "Using ACME with a role requires no_store=false to be set on the role"
- **Quote (SC-Q10, S170, offset 7147)**: "to be specified by mount tuning"
- **Quote (SC-Q15, S173, offset 13130)**: "ACME by default has no external authorization engine and is unauthenticated from an OpenBao perspective"
- **Why it matters for custody**: ACME is a *second, separate* issuance front door whose authorization is
  **proof-of-possession, not an OpenBao token**. Two operator knobs decide how wide it is:
  `default_directory_policy` (`sign-verbatim` = any provable name) and `eab_policy`
  (`not-required` = no OpenBao-token binding at all). A mount that enables ACME without touching either
  is a public issuance surface. The mount must also be tuned with `allowed_response_headers`
  (Replay-Nonce, Link, Location) or the protocol does not work — a *silent* custody-relevant failure.
- **Measured (2.7.2)**: after `pki/config/cluster path=…` and `pki/config/acme enabled=true`:
  `GET /v1/pki/acme/directory` with **no token** → HTTP 200, `meta={"externalAccountRequired": false}`;
  config read-back `default_directory_policy=sign-verbatim`, `eab_policy=not-required`, `enabled=True`;
  `POST /v1/pki/acme/new-account` with a JWS and **no token** → **HTTP 201** (account created);
  `POST /v1/pki/acme/new-order` → **HTTP 201** with an authorization `pending` for the requested name.
  The `Replay-Nonce` header is **absent** until the mount is tuned
  (`bao secrets tune -allowed-response-headers=Replay-Nonce -allowed-response-headers=Link
  -allowed-response-headers=Location pki`); untuned, the ACME client gets `badNonce`.
  Receipt: `receipts/probe-frontier-final.txt` (F8, F8b).
- **Dev-server measurable?** **Yes** for the directory, the account/order creation and the policy
  read-back. **Not** measured here: completing the http-01/dns-01 challenge and *finalising* an
  issuance — that needs a name the dev server can validate (a resolvable `r70.test` name or a challenge
  responder), so a trial can measure "the unauthenticated front door exists and what policy it runs"
  but not "a certificate came out" without extra scaffolding.
  **Falsifier shim**: a wrapper that rewrites `write pki/config/acme enabled=true` to
  `enabled=false` (or drops the write): the directory then 404s and F7's verdict flips to BROKEN with
  every other test unaffected.

### F8 — CEL roles: issuance policy written by the operator, in the operator's own code

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Create/Update CEL role
  (`#create-update-cel-role`), §Generate certificate and key against CEL role
  (`#generate-certificate-and-key-against-cel-role`)
- **Quote (SC-Q11, S170, offset 158765)**: "All validation is taken on by the CEL prgraom created by the operator; limited to no validation is performed by OpenBao"
- **Why it matters for custody**: a CEL role replaces the engine's own name/TTL checks with an operator
  program. It is the one issuance path where **OpenBao performs no validation of its own** — the
  custodian's entire name/TTL policy is a program the custodian wrote. Its custody value is therefore
  entirely a function of the program, and its blast radius (a program that permits any name) is
  unbounded. Note the doc's own typo "prgraom" is in the located quote.
- **Measured (2.7.2)**: `POST pki/cel/roles/celrole` with a CEL program → HTTP 200;
  `POST pki/cel/issue/celrole {"common_name":"cel.r70.test","ttl":"5m"}` → HTTP 200 with data keys
  `certificate, expiration, issuing_ca, not_before, private_key, private_key_type, serial_number` —
  note the response **carries the private key** and the CEL docs state it is not stored.
  Receipt: `receipts/probe-frontier-final.txt` (F9).
- **Dev-server measurable?** **Yes** — the role create, the role read (`cel_program`, `name`) and the
  issuance all respond. **Trap for a successor trial** (recorded so it is not re-learned): my probe's CEL
  program was `cn != "" && small ? out : out` — *both* branches identical — so the `ttl<4h` clause was
  never actually enforced and the `ttl=10h` request was served (HTTP 200). That observation proves
  nothing about CEL's refusal behaviour; a real test must give the program **two different branches**
  and assert the refusal. **Unresolved by this seat.**
- **Falsifier shim**: a wrapper that drops the `cel_program=` argument from `write pki/cel/roles/*`
  (so the role is never created) — the CEL issuance then 404s and F8 flips to BROKEN.

### F9 — BYOC-style revocation with proof of possession (`revoke-with-key`)

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Revoke certificate with private key
  (`#revoke-certificate-with-private-key`)
- **Quote (SC-Q12, S170, offset 45763)**: "This endpoint revokes a certificate using its private key as proof that the request is authorized by an appropriate individual"
- **Why it matters for custody**: this is the revocation path for a `no_store` leaf — the one thing T5
  established is that a `no_store` certificate **cannot be revoked by serial**. Proof-of-possession
  restores exactly that capability, and the doc states the endpoint is *not* privileged by design
  ("this operation is NOT privileged … however … we've made this endpoint authenticated"). So it widens
  the revocation capability while keeping an ACL in front of it; whether that ACL exists is a custody
  decision, and the engine will not make it.
- **Measured (2.7.2)**: `POST pki/revoke-with-key` with a throwaway leaf's own certificate and private
  key (values never printed) → HTTP 200, `state=revoked`. Receipt: `receipts/probe-frontier-final.txt` (F10).
- **Dev-server measurable?** **Yes.**
  **Falsifier shim**: a wrapper that drops `private_key=` from the `pki/revoke-with-key` call: the
  request is then refused and F9 flips to BROKEN while every other test keeps its verdict.

### F10 — `key_usage` / `ext_key_usage`: what the leaf is *allowed to do*

- **URL / anchor**: https://openbao.org/docs/api/secret/pki/ — §Create/Update role
  (`#createupdate-role`), `key_usage` / `ext_key_usage`
- **Quote (SC-Q14, S170, offset 34416)**: "Specifies the default extended key usage constraint on the issued certificate."
- **Why it matters for custody**: a certificate's key usage is the difference between "may act as a TLS
  server" and "may sign code / authenticate as a client". A role that sets the wrong usage hands out a
  credential with a *different* authority than the operator intended, and the operator's mental model
  ("I issued a server cert") may not match the extension on the wire.
- **Measured (2.7.2)**: role `key_usage=DigitalSignature,KeyEncipherment ext_key_usage=serverAuth` →
  the issued leaf carries `X509v3 Key Usage: critical / Digital Signature, Key Encipherment` and
  `X509v3 Extended Key Usage: / TLS Web Server Authentication, TLS Web Client Authentication` — i.e.
  the engine added **client** authentication on top of the requested `serverAuth`.
  Receipt: `receipts/probe-frontier-final.txt` (F11). **[INFERENCE]** the added client-auth EKU is a
  consequence of OpenBao's default template; a successor trial should compare `ext_key_usage=serverAuth`
  against `ext_key_usage=clientAuth` leaves to confirm the mapping before anything is written down.
- **Dev-server measurable?** **Yes**, with an openssl-parsed extension check.
  **Falsifier shim**: a wrapper that drops `key_usage=` and `ext_key_usage=` from `write pki/roles/*`:
  the leaf then carries no usage extensions and F10 flips to BROKEN.

## Two supporting surface observations (measured; not frontier rows)

- **Unauthenticated read surface** (`receipts/probe-frontier-final.txt`, F15): with **no token**,
  `GET /v1/pki/certs` → **403** and `GET /v1/pki/roles` → **403**, while `GET /v1/pki/cert/crl` →
  **200** and `GET /v1/pki/cert/ca` → **200**. The mount publishes its CRL and its CA certificate
  without authentication and keeps the certificate *inventory* private. That is the right shape for
  revocation checking and is exactly the property a custody entry should record.
- **`sign-verbatim` and intermediate CAs** (F16): `POST /pki/sign-verbatim` with a **CA:TRUE** CSR
  returned HTTP 200 in this run (the doc says the endpoint "will refuse to issue an intermediate CA
  certificate", SC-Q13). The issued certificate's `basicConstraints` came back empty in the probe.
  **Unresolved by this seat** — whether OpenBao silently drops the CA flag or issues a CA cert is not
  established. A successor should re-run it and parse `basicConstraints` explicitly. This row is
  *not* counted in the ten above.

## What the frontier implies for the next round's coverage

The single highest-value unmeasured custody property is **F3** (a revoked leaf of a non-default issuer
is absent from the mount's default CRL), because the round's own T4 measures only the default-issuer
case and the lane's entry explicitly does not establish multi-issuer chain behaviour. F1 (leaf
NotAfter vs issuer life) and F9 (`revoke-with-key` for `no_store` leaves) are the two that close real
custody gaps the current entry lists under "Does not establish". F7's ACME front door is the largest
*attack surface* the lane has never touched, but a full measurement needs challenge-fulfilment
scaffolding and is therefore a two-round item.

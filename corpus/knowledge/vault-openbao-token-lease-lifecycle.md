# Vault and OpenBao: JWT login, token lifetime and lease lifecycle are separate clocks

source: S012 (https://developer.hashicorp.com/vault/docs/auth/jwt, §JWT verification, §Bound claims, §Claims as metadata, unversioned "latest" page as served 2026-10-19; version switcher's newest pinned entry v1.21.x); S013 (https://developer.hashicorp.com/vault/docs/concepts/lease, §Lease, renew, and revoke, §Lease durations and renewal, same serving as S012); S014 (https://openbao.org/docs/auth/jwt/, §JWT verification, §Bound claims, §Claims as metadata, OpenBao docs Version 2.7.x); S015 (https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/, §Kubernetes note, Version 2.7.x); S016 (https://openbao.org/docs/concepts/tokens/, §Token hierarchies and orphan tokens, §Token Time-To-Live …, §Token type comparison, Version 2.7.x)
verified-at: 2026-10-19 (the five pages above, fetched and read as tag-stripped text)
recheck: on-release — on a Vault or OpenBao release, re-open S012 §JWT verification (audience rule, verification options), S013 KV note, S015 TokenReview note, S016 §Token Time-To-Live and §Token type comparison; on OpenBao, compare the docs "Version" label to 2.7.x
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the pages, run Vault or OpenBao or measure any behaviour; `recheck:` is the content clock.)

Scope: vendor documentation only; nothing was deployed or probed. Vault claims
cite S012/S013; OpenBao claims cite S014–S016. A Vault fact is never extended to
OpenBao or the reverse — the two are compared, not equated.

## Four clocks a "short-lived" claim can mean (QA8)

| clock | owner | ends by | source |
|---|---|---|---|
| external JWT validity | the issuer (IdP, Kubernetes) | its own expiry; issuer-side revocation is not seen by OpenBao JWT auth | S015 |
| Vault/OpenBao token TTL | role / mount / system max TTL | expiry, renewal limits, explicit revocation, parent revocation | S016 (OpenBao) |
| lease on a dynamic secret | the secrets engine | expiry or revocation; Vault revokes a token's leases with the token | S013 (Vault), S016 (OpenBao) |
| static value in KV | whoever writes it | only a write; no lease, nothing expires | S013 (Vault) |

## Login: verification and claim binding

- Vault (S012 §JWT verification): signatures are checked against issuer public
  keys from one configured method per mount — static keys, JWKS, JWKS pairs, or
  OIDC Discovery; more methods need another mount. With OIDC Discovery, "OIDC
  validation criteria (e.g. iss, aud, etc.) will be applied".
- Vault, version-scoped (S012 page note): "Starting in Vault 1.17", a JWT carrying
  `aud` needs a role `bound_audiences` that exactly matches one of its values.
- Vault (S012 §Bound claims): binding runs only after the JWT "has been validated
  as being properly signed and not expired"; `bound_claims` require listed claims
  and values. §Claims as metadata: a mapped claim missing from the JWT fails login.
- OpenBao 2.7.x (S014 §JWT verification): three methods — static keys, JWKS,
  OIDC Discovery — one per backend. §Claims as metadata: claims are copied
  "into the resulting auth token and alias metadata"; mappings without a leading
  `/` are optional, JSON-pointer mappings are required. This differs from S012's
  wording; do not assume either behaviour on the other product.
- In both products' role example, the role attaches the policy ("gives it the
  webapps policy") and uses user/groups claims "to set up Identity aliases"
  (S012, S014 §Configuration). Claims gate the login and become metadata.

## OpenBao + Kubernetes: issuer revocation is invisible (S015, Version 2.7.x)

S015 §Kubernetes note: "The JWT auth engine does not use Kubernetes' TokenReview
API during authentication"; tokens Kubernetes revoked "will still be considered
valid by OpenBao until their expiry time". Its mitigations: short service-account
token TTLs, or the separate Kubernetes auth method, which does use TokenReview.

## OpenBao tokens (S016, Version 2.7.x)

- Policies attached to a token "control what the token holder is allowed to do";
  token values are opaque and their structure is documented as volatile.
- "Every non-root token has a time-to-live"; when it lapses the token stops and
  "it, and its associated leases, are revoked". Renewal is bounded by system max
  TTL (default 32 days, configurable), mount tuning, and the auth method's value;
  an explicit max TTL is a hard cap; periodic tokens renew indefinitely.
- "outside of direct operator interaction, OpenBao will never revoke a token
  before the returned TTL has expired" (§The general case). [INFERENCE from
  S015 + S016] A Kubernetes-side revocation therefore shortens neither login
  acceptance nor an already-issued OpenBao token; an operator must revoke it.
- Logging in "with any other (non-token) auth method" yields an orphan token
  (§Token hierarchies), so parent-tree revocation does not reach it.
- Batch tokens: not renewable and not manually revocable (§Token type comparison).

## Vault leases (S013)

Leases attach to "every dynamic secret and service type authentication token";
revoking a lease "invalidates that secret immediately"; revoking a token revokes
"all leases that were created using that token". Renewal increments are
"completely advisory". KV is outside this: "The Key Value Backend which stores
arbitrary secrets does not issue leases although it will sometimes return a lease
duration" (S013, note under §Lease, renew, and revoke).

## How kagi uses this

kagi runs neither product: `grep -rliE 'sops|openbao|hashicorp' corpus/knowledge
--exclude=sops-age-key-rotation.md --exclude=vault-openbao-token-lease-lifecycle.md`
→ no file, exit 1 (2026-10-19). Use this as a review checklist when a workload
claims "short-lived" or "revoked": name the clock from the table, the product, and
the token type before accepting the claim.

## Does not establish

- Token TTL ≠ lease ≠ value rotation: expiring a token or lease never changes a
  KV-stored value; only a write does.
- Vault token mechanics (S016 is OpenBao-only; Vault's token page was not opened),
  Vault Kubernetes-auth behaviour, or Vault/OpenBao parity on any row above.
- Absence sweeps (tag-stripped, whitespace-collapsed, lower-cased page text,
  2026-10-19): "tokenreview" 0 in S012 and 0 in S014; "jwks pairs" 1 in S012, 0 in
  S014; "exactly match" 3 in S012, 0 in S014. Command, with `U` = page URL and
  `P` = lower-case phrase:
  `curl -sL "$U" | python3 -c "import sys,re,html;t=html.unescape(re.sub(r'<[^>]+>',' ',re.sub(r'(?s)<script.*?</script>','',sys.stdin.read())));t=re.sub(r'\s+',' ',t).lower();print(t.count('$P'))"`.
  A zero means the page does not say it, not that the product lacks it.
- Enterprise-only or plugin workload-identity features: not covered.

## Falsifier

A current Vault page issuing leases for KV reads or dropping the 1.17 audience
rule; an OpenBao 2.x page saying JWT auth consults TokenReview, that batch tokens
are manually revocable, or that tokens may be revoked before their returned TTL
without operator action.

## Erratum (round 21, post-landing critic; appended, text above unchanged)

The four-clocks table merged products and paths beyond what its sources state. Superseding readings, by row:

- **external JWT validity** — S015 covers only OpenBao's **Kubernetes** JWT-provider path: that path does not call TokenReview, so Kubernetes-revoked service-account tokens stay valid to OpenBao until expiry. Nothing here covers other IdPs.
- **token TTL** — OpenBao only (S016). Vault token TTL was not sourced this round; the "Vault/OpenBao" label is withdrawn.
- **lease on a dynamic secret** — Vault: S013 (leases on dynamic secrets and service tokens; revoking a token revokes its leases). OpenBao: S016 (an expiring token is revoked with "its associated leases"). Two sources, two products, not one fact.
- **static value in KV** — S013 establishes only that Vault's KV backend "does not issue leases". It does not establish that a KV value "never expires" or changes only by a write; KV version deletion settings and delete/destroy operations were not opened this round (lead: Vault KV v2 API, `corpus/SOURCES.md` §Leads). §Does not establish, first bullet, reads accordingly: a KV read carries no lease.
- §How kagi uses this: the sweep covers corpus mentions only, not host runtime use (as in the SOPS entry's erratum).

## Erratum (round 22 — outside admit disagreement retained)

The outside verifier rejected E3 **as landed**; the round-21 erratum did not
retroactively make that admission pass. The original four-clocks table and
§Does not establish first bullet are historical defective readings, not an
operational table. The product-separated round-21 erratum is authoritative.

Reopened S016 on 2026-10-20: OpenBao docs identify Version 2.7.x.
§Token Time-To-Live states: “After the current TTL is up, the token will no
longer function”. Its following sentence includes associated leases.
§Token type comparison distinguishes service-token renewal/manual revocation
from batch-token limits. This supports **OpenBao token** claims only; it
does not supply the missing Vault-token evidence, and Vault's S013 does not
supply OpenBao KV evidence.

The inherited S015/S016 inference that issuer revocation means “an operator
must revoke it” is not a universal lifecycle rule: tokens can also expire
and parent/service-token lifecycle rules apply. No issuer revocation path
for other providers, no cross-product TTL parity and no KV value-retention
guarantee is admitted here. A missing product-specific source means
**unverified/withdrawn**, never implicit parity.

On release, reopen each named product's own page and token type separately.
These are public-document corrections, not a deployed Vault/OpenBao probe;
no vault or account was contacted. The admission lesson and criterion are
`corpus/lessons/round-22.md` and QUALITY QA10.

### Further product/path precision (round 22)

The active corrected status/token reading is
`corpus/knowledge/feature-bound-credential-review.md`. The older text is
not an operational cross-product table. Reopened S014 §Claims as metadata
on 2026-10-20: copying requires configured `claim_mappings`; JSON-pointer
mapped claims must exist, while non-pointer mappings are optional. This
does not require every mapping to use JSON-pointer syntax. Bound-claim
validation, Identity aliases and configured metadata copying are separate.

Reopened S016 §The general case: mount max TTL can override the system
maximum longer or shorter. Periodic-token continuation requires timely
successful renewal and remains capped by any explicit max TTL. The phrase
“periodic tokens renew indefinitely” is therefore withdrawn unless those
qualifiers travel with it. S016's token/associated-lease statements do not
independently establish all dynamic-secret engine or KV behavior; service
and batch-token paths must remain distinct. No new deployed behavior was
measured. Source review: `kagi-shokunin/.ufo/waves/round-22/build/Source14.md` and
`kagi-shokunin/.ufo/waves/round-22/build/Source16.md`.

### Final round-22 role and locator correction

For the Vault audience rule, the mandatory bound-audience match applies
from Vault 1.17 to **JWT roles** when the presented JWT has an audience
claim. The same page says `bound_audiences` is optional for **OIDC roles**
and typically not required; do not generalize the mandatory setting across
role types. S022 records that correction to S012. S023 corrects S013's
categorical no-displayed-version locator while preserving its valid Vault
lease/KV mechanism; the observed v2.x Edit-source route proves no deployed
binary version. Located quotes and their source-consumption handshake are
in `corpus/lessons/round-22-source-errata.md`, not a rewritten old header.

The OpenBao reopen mentioned above is registered as S021; S016 retains its
earlier capture. Associated-lease revocation is a continuation of the same
TTL sentence after the dash, not a separate following sentence. **No lease
does not imply no deletion or guaranteed retention.** No Vault or OpenBao
runtime, account or token operation was performed for these corrections.

## Measured (round 49 — OpenBao 2.7.2 dev server, 127.0.0.1, throwaway tokens)

Measured 2026-11-06 on this host by executing the round-49 trial
`corpus/openbao-token-trial.sh --work <scratch dir>`; its five tests and its
`TRIAL T<n> HOLDS|BROKEN|ERROR …` / `OPENBAO_TRIAL: …` lines are those frozen in
the reference fixture
`.ufo/waves/round-49/controls/fixtures/openbao-token-trial.ref.sh`. One
throwaway `bao server -dev` was started on 127.0.0.1 at a random free port, with
in-memory storage and a random root token kept only in the scratch tree and
deleted with it; every caller `BAO_*`/`VAULT_*` variable was unset, `HOME`
pointed into that tree, and no real vault, account, credential or Kubernetes API
was touched. The binary is the official OpenBao 2.7.2 linux_amd64 release
(`~/.local/bin/bao`, sha256 `9c5f3628…b788`; receipt
`.ufo/waves/round-49/controls/tool-install.txt` — `checksums.txt` and the GitHub
asset digests match, the `.gpgsig` and `.sigstore.json` assets were **not**
verified). The trial printed one `TRIAL T<n> HOLDS …` line per test and ended
`OPENBAO_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` (rc 0; L1 run of the candidate script, 2026-11-06; counter receipts `.ufo/waves/round-49/final/`).

Supersession note (append-only entry): the `Scope:` sentence at `:9` ("vendor
documentation only; nothing was deployed or probed") and the first sentence of
§How kagi uses this (`:76`, "kagi runs neither product") describe the entry
before round 49. For the five OpenBao token mechanisms below they are
superseded: a throwaway dev server was started (not deployed) and these token
and lease behaviours were probed on it. Vault is still not run — no Vault token,
lease or KV mechanism is measured here, and nothing below is Vault/OpenBao
parity. The `[INFERENCE from S015 + S016]` reading under §OpenBao tokens
(`:58-60`) stays an inference: the trial runs no Kubernetes cluster and calls no
TokenReview API, so it cannot measure what a Kubernetes-side revocation does to
an already-issued token. What the trial establishes is one host, one release,
dev mode: a single `bao server -dev` with in-memory storage, HTTP on 127.0.0.1,
no storage backend, no seal or unseal operation, no HA, no TLS and no policy
model beyond the `default` policy and the two trial policies (`child-maker`,
`pki-issue`). A dev server is not a production configuration; none of this is
evidence about a deployed or production Vault/OpenBao, and `verified-at:
2026-10-19` remains the date the documentation was read, not the date of these
runs.

- T1 non-root TTL: with OpenBao 2.7.2, a non-root token was created with `bao token create -policy=default -ttl=2s` and looked up once immediately and once after a 4 s sleep; observed `TRIAL T1 HOLDS ttl=2s alive-before=1 alive-after-4s=0` — detail fields: `ttl=2s`, the answer before the TTL and the answer after it — measures S016 §Token Time-To-Live, "Every non-root token has a time-to-live" and "After the current TTL is up, the token will no longer function".
- T2 explicit max TTL cap: with OpenBao 2.7.2, a token was created with `-ttl=60s -explicit-max-ttl=5s`, `bao token renew -increment=3600` was requested with it, and it was looked up again after a 7 s sleep; observed `TRIAL T2 HOLDS renew-increment=3600 granted=5 alive-after-7s=0` — detail fields: the granted `lease_duration` against the requested 3600 s and the answer after the cap — measures S016 §Token Time-To-Live as this entry reads it ("an explicit max TTL is a hard cap").
- T3 batch token: with OpenBao 2.7.2, a batch token was created (`bao token create -type=batch -ttl=60s`), asked to renew itself, and then revoked by the root token; observed `TRIAL T3 HOLDS renew-ok=0 revoke-ok=0 alive-after=1` — detail fields: renew-ok, revoke-ok and whether the batch token still answers a lookup — measures S016 §Token type comparison, "Batch tokens: not renewable and not manually revocable".
- T4 orphan login token: with OpenBao 2.7.2, userpass was enabled, a token holding a `child-maker` policy created a child token and logged in through userpass, and the parent token was then revoked; observed `TRIAL T4 HOLDS login-orphan=true child-alive-after-parent-revoke=0 login-alive=1` — detail fields: the login token's `orphan` value, the child's answer after the parent's revocation and the login token's answer — measures S016 §Token hierarchies and orphan tokens: logging in "with any other (non-token) auth method" yields an orphan token, so parent-tree revocation does not reach it.
- T5 lease revoked with its token: with OpenBao 2.7.2, a PKI mount issued a certificate with `generate_lease=true` (lease TTL 10 m) under a token created with `-ttl=3s`, and the lease was looked up before and 5 s after issuance; observed `TRIAL T5 HOLDS lease-ttl=10m token-ttl=3s lease-before=1 lease-after-5s=0` — detail fields: the lease's answer before and after the token's TTL — measures S016 §Token Time-To-Live, "it, and its associated leases, are revoked".

Review narrowings (seat K49ReviewerTrial, `.ufo/waves/round-49/build/K49ReviewerTrial.md`;
probe scripts in `.ufo/waves/round-49/build/K49ReviewerTrial/`): T1's refusal is a lookup exit
status whose server text reads `permission denied`, not "expired" — expiry is attributed by
isolation (only elapsed time changes; a ttl=60s token in the same server stays alive through the
same window). T2's granted value is the renew response's `auth.lease_duration`; the same renewal
without `-explicit-max-ttl` is granted 3600. T3's refusals carry the server's own reasons, `batch
tokens cannot be renewed` and `batch tokens cannot be revoked` (revocation tried as root). T4's
`orphan=true` is specific to the userpass route: a child created through `auth/token/create` by the
same caller reads `orphan=false`. T5 was contrasted: the same issuance under a 30 m token keeps its
lease alive 5 s later, while the lease's own TTL (599 s at issue) rules out self-expiry — the
issuing token's lapse is the only differentiator. The `generate_lease` role parameter T5 relies on
is documented by S105 (OpenBao PKI API docs, opened 2026-11-06, cited by
`corpus/lessons/round-49.md`).

Each test has a designated falsifier shim in `plans/round-49-c1.sh` (SH1
token-lookup-always-succeeds, SH2 create-drops-explicit-max-ttl, SH3
create-drops-batch-type, SH4 userpass-login-returns-a-child-token, SH5
create-drops-ttl) that flips it to BROKEN; a HOLDS row excludes that falsifier
under these conditions, it is not a proof of the mechanism in general.

Re-run: `bash corpus/openbao-token-trial.sh --work <dir>` (starts and kills its
own throwaway dev server, throws the server state and tokens away on exit;
needs `bao` and `python3` on `PATH`).

**Does not establish:**

- One host, one release, dev mode: everything above is OpenBao 2.7.2 from the
  official linux_amd64 release on this host, against one `bao server -dev` with
  in-memory storage. A dev server is not a production configuration — no storage
  backend, no seal or unseal operation, no HA, no TLS, no policy model beyond
  the trial policies — and another release or a production cluster may behave
  differently.
- No Vault: no Vault binary or server was run, so no Vault token, lease or KV
  mechanism is measured and no Vault/OpenBao parity is established.
- No Kubernetes: no cluster and no TokenReview call; the `[INFERENCE]` at `:58`
  stays an inference.
- No real secret or account: the only credentials are the random dev root token
  and a random userpass password, both created in scratch and deleted with it;
  the trial prints neither the root token, a created token value nor the
  password.
- Mechanism scope: the five sentences listed, at token TTLs of 2–60 s and observation windows of 4–7 s; periodic
  tokens, the 32-day system default max TTL, mount tuning beyond the PKI mount's
  `max-lease-ttl=1h`, and auth-method max TTLs are not exercised, and PKI is the
  only lease-issuing engine used (no database, transit or other engine).
- A trial that detects its designated shims is a ceiling: T1..T5 passing
  excludes the five named falsifiers under these conditions; it does not
  establish that no other implementation or configuration could satisfy the
  entry's sentences for a different reason.

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

# C2 teaching re-verification notes — 11 fired Vault/OpenBao release-clock rows (round 47)

Seat K47ExecC2, BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`, measured in a scratch tree at
`$HYAKU_SCRATCH/kagi-r47/K47ExecC2/tree`. Every capture is a fresh live fetch of column-4 URL of the
row in `corpus/source-fetches.tsv` (== the URL in the row's `corpus/SOURCES.md` source cell), taken
2026-11-06T19:34:14Z–2026-11-06T19:34:15Z with `curl -fsSL --compressed`, HTTP 200 on all 11.
The timestamp was recorded by `date -u +%FT%TZ` immediately before each curl. Counts are from
`python3 corpus/rendered-text-v1.py locate <capture> "<column-13 quote>"` (rc=0 on all 11).

No verdict is `teaching-changed`: all 11 rows' `teaches` cells still hold at the observed release.
Context windows below are rendered-text-v1 text, trimmed to <= 40 words.

## S012 — Vault JWT/OIDC, observed release 2.2.1, quote_count=1
sha256 `0ccb802d…9912fa`, 386833 bytes.
Context: "…the JWT in the authentication request contains an aud claim (typical case) «the associated
bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the
JWT.» For additional details, refer to the JWT…"
Judgement: `teaching-holds` — the served v2.x page still carries the Vault 1.17 note that a JWT-role
audience must exactly match one of the presented `aud` claims.

## S013 — Vault lease concepts, observed release 2.2.1, quote_count=1
sha256 `f4c70f9f…e77972`, 261663 bytes.
Context: "…audit logs more valuable and also makes key rolling a lot easier. «All dynamic secrets in
Vault are required to have a lease.» Even if the data is meant to be valid for eternity, a lease is
required to force…"
Judgement: `teaching-holds` — the lease requirement for dynamic secrets is verbatim, and the
static-KV exception clause is still on the page (see note N1: "Key Value Backend … does not issue
leases although it will sometimes return a lease duration", carried in the page's MDX payload).

## S014 — OpenBao JWT/OIDC auth method, observed release 2.7.2, quote_count=1
sha256 `893f33e4…ae4be7`, 63046 bytes.
Context: "…Methods JWT/OIDC Overview Version: Version 2.7.x On this page JWT/OIDC auth method «The jwt
auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT» The OIDC method
allows authentication via a configured OIDC…"
Judgement: `teaching-holds` — the 2.7.x page still documents OIDC and direct-JWT authentication with
configured signature/claim handling.

## S015 — OpenBao Kubernetes JWT provider, observed release 2.7.2, quote_count=1
sha256 `7007e9e4…803b48`, 55824 bytes.
Context: "…OpenBao can validate its service account tokens using JWT/OIDC auth. info Note: «The JWT
auth engine does not use Kubernetes' TokenReview API during authentication» …and instead uses public
key cryptography to verify the contents of JWTs. This means tokens that…"
Judgement: `teaching-holds` — the note still states TokenReview is not consulted, so Kubernetes
revocation is not immediate on this path.

## S016 — OpenBao tokens, observed release 2.7.2, quote_count=1
sha256 `ea9bdafe…0548ef`, 47384 bytes.
Context: "…token; tokens they create will be children of them; and so on. «When a parent token is
revoked, all of its child tokens -- and all of their leases -- are revoked as well.» This ensures that
a user cannot…"
Judgement: `teaching-holds` — parent-token revocation still cascades to child tokens and their leases
under §Token hierarchies and orphan tokens.

## S021 — OpenBao token lifecycle (product-bound review), observed release 2.7.2, quote_count=1
sha256 `ea9bdafe…0548ef`, 47384 bytes (same served page as S016/S026).
Context: "…the TTL may also be 0, indicating a token that never expires). «After the current TTL is
up, the token will no longer function -- it, and its associated leases, are revoked.» If the token is
renewable, OpenBao can be…"
Judgement: `teaching-holds` — the page still states non-root token TTL expiry revokes the token and
its leases and still carries the service-versus-batch token-type comparison (Version 2.7.x), with no
Vault-token or KV-retention claim.

## S022 — Vault JWT-role audience qualifier, observed release 2.2.1, quote_count=1
sha256 `0ccb802d…9912fa`, 386833 bytes (same served page as S012).
Context: "…the JWT in the authentication request contains an aud claim (typical case) «the associated
bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the
JWT.» For additional details, refer to the JWT…"
Judgement: `teaching-holds` — exact bound-audience matching is still scoped to the "jwt" role, and the
same page still says "bound_audiences is optional for OIDC roles and typically not required", so the
supersession of S012 stands.

## S023 — Vault lease/KV scoped locator, observed release 2.2.1, quote_count=1
sha256 `f4c70f9f…e77972`, 261663 bytes (same served page as S013).
Context: "…audit logs more valuable and also makes key rolling a lot easier. «All dynamic secrets in
Vault are required to have a lease.» Even if the data is meant to be valid for eternity, a lease is
required to force…"
Judgement: `teaching-holds` — the lease/KV mechanism is intact and the served route is a v2.x locator
(page shows "v2.x (latest)" plus the Edit link to `content/vault/v2.x/content/docs/concepts/lease.mdx`),
with no deployment or KV-retention guarantee on the page, exactly as the cell states.

## S024 — Vault KV v2 API, observed release 2.2.1, quote_count=3
sha256 `08ad557b…b77b3d8`, 586212 bytes. Three occurrences: the `POST /:secret-mount-path/config`
parameter, the key-metadata `max_versions` override, and the sample payload.
Context (occurrence 1): "…such as secret . This is specified as part of the URL. «max_versions (int: 0)
– The number of versions to keep per key.» This value applies to all keys, but a key's metadata
setting can overwrite this value. Once…"
Judgement: `teaching-holds` — `max_versions` still caps retained versions per key at config level while
`delete_version_after` remains a separate parameter, i.e. configuration only, not a retention guarantee.

## S025 — OpenBao JWT/OIDC corrected locator, observed release 2.7.2, quote_count=1
sha256 `893f33e4…ae4be7`, 63046 bytes (same served page as S014).
Context: "…Methods JWT/OIDC Overview Version: Version 2.7.x On this page JWT/OIDC auth method «The jwt
auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT» The OIDC method
allows authentication via a configured OIDC…"
Judgement: `teaching-holds` — the method name still renders as code (`jwt`), the sentence still
continues "or by providing a JWT", and §Claims as metadata still documents `claim_mappings`.

## S026 — OpenBao tokens corrected locator, observed release 2.7.2, quote_count=1
sha256 `ea9bdafe…0548ef`, 47384 bytes (same served page as S016/S021).
Context: "…token; tokens they create will be children of them; and so on. «When a parent token is
revoked, all of its child tokens -- and all of their leases -- are revoked as well.» This ensures that
a user cannot…"
Judgement: `teaching-holds` — the rendered-text-v1 quote is under §Token hierarchies and orphan tokens
at Version 2.7.x, with no Vault-token or KV-retention claim, matching the corrected row.

## Notes
N1. S013/S023 KV exception is *not* in rendered-text-v1 output: the page serves that block as an MDX
payload (`mdx("a",…,"Key Value Backend"),` which stores arbitrary secrets does not issue leases
although it will sometimes return a lease duration`) that the normalizer's script-strip removes. Raw
body check: `grep -o "does not issue leases"` on S013.body → 2 hits. Verdict stays teaching-holds; this
is a normalizer-bound observation, not a page change.
N2. Distinct bodies: 5 URLs → 11 captures. S012/S022 share the Vault JWT body, S013/S023 the Vault
lease body, S014/S025 the OpenBao JWT body, S016/S021/S026 the OpenBao tokens body, S024 the KV v2 API
body. Identical sha256 within a group is expected; fetched_at is recorded per id.

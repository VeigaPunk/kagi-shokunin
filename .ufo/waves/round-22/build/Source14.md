# Round 22 — S014 re-open: OpenBao JWT/OIDC auth method

Axes: **calibration** (C1) and **freshness** (C2). Read-only. Read revision
`c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD` matched the
plan and the frozen tree). Base copies read from
`.ufo/waves/round-22/frozen/before/`. Access date **2026-10-20**
(21:37Z). Only source **S014** was re-opened; no registry, entry, stamp, gate
or host state was edited. No installs.

## 1. Source facts observed 2026-10-20

| field | observation |
|---|---|
| URL | `https://openbao.org/docs/auth/jwt/` — HTTP 200, final URL identical, `curl -sSL` |
| bytes | 63,046; raw sha256 `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` |
| normalized text | strip `script`/`style`/tags, unescape, collapse whitespace → 15,911 chars; sha256 `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403` |
| HTTP revision | `Last-Modified: Tue, 20 Oct 2026 07:50:18 GMT`; `ETag: "6ad71d3a-f646"`; server `GitHub.com`, Fastly cache |
| page build | `<meta name=generator content="Docusaurus v3.10.2">`; bundle `f040e9fc.css` |
| on-page version | `Version: Version 2.7.x` (selector also lists Development, 2.6.x, 2.5.x); `/docs/2.6.x/auth/jwt/` and `/docs/2.5.x/auth/jwt/` both 200 |
| releases | v2.7.1 published 2026-10-01T14:03:19Z; v2.7.0 2026-09-23; the next-newest is v2.6.4 2026-10-01. No OpenBao release after the row's 2026-10-19 open |
| docs source | `website/content/docs/auth/jwt/index.mdx` on `release/2.7.x` (the page's own "Edit this page" link); raw sha256 `8d0aeba8cc43a4d1abe9e9eb0dacbefe7350847dcc6dca4167a2bac1593b0965`; newest commit touching the file `ec6ba09f484b`, 2026-08-10T12:13:56Z |

Anchored sentences re-verified verbatim on the 2026-10-20 render:

| id | location | quote (≤25 words) | words |
|---|---|---|---|
| Q1 | H1 "JWT/OIDC auth method", intro paragraph | “The \`jwt\` auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT” | 18 |
| Q2 | §JWT verification | “This process can be done in three different ways, though only one method may be configured for a single backend” | 20 |
| Q3 | §Claims as metadata | “If a claim is configured in claim_mappings, it must exist in the JWT when using JSON pointer syntax” | 18 |
| Q4 | §Claims as metadata | “Claim mappings which do not begin with a / are optional.” | 11 |
| Q5 | §Configuration, role example | “gives it the webapps policy, and uses the given user/groups claims to set up Identity aliases” | 16 |
| Q6 | §Bound claims | “Once a JWT has been validated as being properly signed and not expired” | 15 |

## 2. Qualifiers on the source sentence

| dimension | observed bound | evidence |
|---|---|---|
| product | **OpenBao only.** The four `vault` strings are example claim URIs (`https://vault/user`, `https://vault/groups`, `https://vault.plugin.auth.jwt.test`) and the UI path `/ui/vault/auth/...`; no HashiCorp Vault statement | whole-page text |
| version | **2.7.x** docs release line; not "latest" and not Development | on-page `Version: Version 2.7.x`; 2.6.x/2.5.x archived |
| feature status | **released docs, no prerelease label.** 0 occurrences of `beta`, `preview`, `experimental`, `deprecated` | case-insensitive count over page text |
| eligibility | **none stated.** 0 occurrences of `enterprise`, `hcp`, `license`, `edition`; a plan/edition gate and an "available to everyone" grant are both unsupported | absence, not an affirmative |
| path | mount name `jwt` or `oidc` (default `/jwt`); login `auth/jwt/login`; CLI `-path=/my-path`; method chosen **per role**; **one** verification method per backend; OIDC roles need discovery URL + client ID/secret, JWT roles need local keys, JWKS or discovery URL | §Configuration, §JWT verification, §Via the CLI, §Via the API |
| plugin | "The JWT Auth Plugin has a full HTTP API" — built-in auth plugin, no separate install or edition qualifier | §API |

## 3. Calibration: E3 claims that cite S014

Entry frozen at base: `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
(sha256 `5fd53351…`, 111 lines). Line numbers below are the frozen copy.

| # | claim as landed | decision | S014 basis / correction |
|---|---|---|---|
| 1 | L33–34 "three methods — static keys, JWKS, OIDC Discovery — one per backend" | **ADMIT** | Q2 verbatim; correctly bounded to OpenBao 2.7.x §JWT verification |
| 2 | L34–36 "claims are copied 'into the resulting auth token and alias metadata'; mappings without a leading `/` are optional, JSON-pointer mappings are required" | **ADMIT, wording narrowed** | Q3+Q4. What is required is the **mapped claim's existence when JSON-pointer syntax is used**; pointer syntax itself is not required and non-`/` mappings are optional. "JSON-pointer mappings are required" is readable as requiring pointer syntax — replace with Q3+Q4 or restate "claims selected by pointer-style mappings must exist" |
| 3 | L36–37 "This differs from S012's wording; do not assume either behaviour on the other product" | **ADMIT as caution** | S014 contains no cross-product statement; the caution is the correct bound. The S012 leg is outside this review |
| 4 | L38–40 role example "gives it the webapps policy … to set up Identity aliases" | **ADMIT** | Q5 verbatim; the role example configures `policies`, `bound_subject`, `bound_audiences`, `user_claim`, `groups_claim`, `ttl` |
| 5 | L40 "Claims gate the login and become metadata." | **REJECT AS WORDED** (S014 leg) | Three mechanisms are merged. Bound parameters gate authorization only after Q6; `user_claim`/`groups_claim` in the role example set up **Identity aliases**, not metadata; and claims become metadata **only** "by configuring `claim_mappings`" — which the role example does not do. The login response's `metadata` object carries the `role`, not the claims. Replacement: "bound parameters gate authorization; the role's user/groups claims map Identity aliases; only `claim_mappings`-selected claims are copied to token/alias metadata" |
| 6 | L3 and L40 cite §JWT verification, §Bound claims, §Claims as metadata, §Configuration | **ADMIT the page supports them; row anchor under-declares** | all four sections exist and were read on 2026-10-20 |
| 7 | L88–90 absence sweep: "tokenreview" 0, "jwks pairs" 0, "exactly match" 0 in S014 | **REPRODUCED** | counts re-measured on the 2026-10-20 render: 0 / 0 / 0. Method bounds below must stay attached |

### Claims S014 cannot carry (reject as S014-derived)

| claim class | why S014 cannot carry it | cite instead |
|---|---|---|
| TokenReview use / issuer-revocation invisibility | `tokenreview` 0, `revoke` 0, `revoked` 0, `revocation` 0; the page is silent on issuer revocation | S015 (Kubernetes provider note only) |
| token TTL, renewal, revocation | `ttl` 2, both `ttl=1h` in example role configs; no TTL semantics. `time-to-live` 0 | S016 |
| leases on dynamic secrets, KV behaviour | `kv` 0; `lease` 5 = four `please` substrings + one `lease_duration` in the example login response; no lease lifecycle | S013 (Vault), S016 (OpenBao) |
| Vault parity | the four `vault` occurrences are example URIs/UI path; no HashiCorp Vault statement | S012/S013 |
| eligibility (either a plan gate or "available everywhere") | no plan/edition/license sentence exists; absence supports neither direction | — |
| "any IdP" revocation generality | the body names no IdP path; `kubernetes` 1 is the sidebar link only | S015, Kubernetes path only |

**Sweep-instrument bounds (keep):** the sweep counts whole-page tag-stripped
text, so sidebar/nav text is included (`kubernetes` 1 comes only from the
sidebar); substring matches inflate (`lease` above); and a zero means the page
does not say it. The round-21 caveat is correct and should be retained.

## 4. Freshness: revision-stamp reconciliation

### 4.1 The stored fetch hash is stale, the teaching is not

- Row stamp (2026-10-19): `e94723241fbcbdd0b2741c569f6ce51befe39e526cd736cebe4023fbca1cb0b1`.
- Current (2026-10-20): `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9`.
- The drift is **site-wide, not page-specific**: `/docs/auth/jwt/`,
  `/docs/concepts/tokens/`, `/docs/auth/jwt/oidc-providers/kubernetes/`,
  `/docs/`, and `/` all report the same `Last-Modified:
  2026-10-20T07:50:18Z`, and every ETag is `"<mtime-hex>-<size-hex>"`.
- The anchored content did not move: the docs source file on `release/2.7.x`
  has had no commit since `ec6ba09f484b` (2026-08-10), and Q1–Q6 match the
  render exactly. No OpenBao release landed after 2026-10-19 (latest v2.7.1,
  2026-10-01), so the row's `recheck: on-release` clock has not fired.
- **Limit:** the 2026-10-19 bytes are not retrievable — the Wayback CDX query
  for 2026-10-01..2026-10-21 returned `[]`, and there is no built-site branch
  (`gh-pages`/`pages`/`openbao.github.io` all 404). The redeploy explanation
  is therefore [INFERENCE] from the site-wide mtime, the Docusaurus build, and
  the unchanged source file; the *content* identity is observed, not inferred.

**Rule:** the raw HTML digest is deployment-coupled. A refreshed hash does not
by itself re-verify a source fact (QM14); the 2026-10-20 re-read of Q1–Q6 is
the actual re-verification.

### 4.2 Quote fidelity defect in S014

- Registered quote: “The JWT auth method can be used to authenticate with
  OpenBao using OIDC”. Literal matches on the live page: **0**.
- The page renders `<code>jwt</code>`: “The jwt auth method can be used …”,
  literal matches: **1**. The 2.6.x and 2.5.x pages also render lowercase.
- So the stored quote is a case-normalized variant, not a located quote; a
  literal grep for it fails. Replace it with Q1.

### 4.3 Anchor under-declaration (expectation migration)

Row `anchor` names only “§JWT/OIDC auth method and §JWT verification”, while
the entry's own citation line (`L3`) and role-example sentence (`L40`) rely on
§Bound claims, §Claims as metadata and §Configuration. Migration: widen the
anchor to those five locations. The row's `scope` ("role claim validation")
is supported by §Bound claims and needs no change.

### 4.4 Pin debt around S014

- E3's stamp row exists at base: `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb`,
  111 lines / 8,597 bytes, and the frozen copy matches exactly. It is **not**
  one of the nine deleted historical members; it was added and later updated
  in `c41af82` → `e1544c1`.
- The **live** E3 file is `00c8c4e209b5e07808805943cd8c728044f7466c1fe6f498494e7185d99ea784`,
  138 lines / 10,131 bytes, because another seat appended the round-22 erratum
  in the working tree. Expected in-flight state — do not restamp to it, and do
  not treat the mismatch as staleness of the source.

### 4.5 Proposed migration record (no edit made)

| field | old (2026-10-19) | new (2026-10-20) | reason |
|---|---|---|---|
| fetch sha256 | `e9472324…` | `449ef132…` | site-wide redeploy 2026-10-20T07:50:18Z; anchored text unchanged |
| quote | “The JWT auth method…” (capital) | Q1 (literal `<code>jwt</code>`) | quote was normalized, not located |
| anchor | §JWT/OIDC auth method, §JWT verification | + §Configuration, §Bound claims, §Claims as metadata | entry cites those sections |
| status / recheck | mined / on-release | unchanged | no release since 2026-10-01; docs label still 2.7.x |

Checks observed: Q1–Q6 present; version label 2.7.x; source file unchanged
since `ec6ba09f`; no release after 2026-10-19. This record is the anti-laundering
evidence QM14 asks for: old values retained, correction motivated, fresh hash
not treated as content re-verification.

## 5. Proposed superseding row (proposal only — registry untouched)

Next free id at read time is **S021** (live registry holds S001–S020). The lane's
convention supersedes rather than rewrites (`S019`/`S020` over `S007`/`S006`),
and S014's `opened`/hash/quote are the 2026-10-19 record, so a new row is the
clean mechanism. No immutable S014 field changes.

Exact row text for insertion after S020 (verbatim; backticks are registry-literal):

```
| S021 | JWT/OIDC auth method (re-open of S014) — https://openbao.org/docs/auth/jwt/ | docs | A | OpenBao 2.7.x JWT/OIDC login, per-role claim binding, and claim-to-metadata mapping | §JWT/OIDC auth method, §JWT verification, §Configuration, §Bound claims, §Claims as metadata; on-page "Version: Version 2.7.x", re-opened 2026-10-20 | supersedes S014's quote and anchor (anchored teaching unchanged): OpenBao 2.7.x documents OIDC and direct-JWT login; three signature-verification methods with one per backend; bound parameters gate authorization after signature/expiry validation; only `claim_mappings`-selected claims are copied to token/alias metadata. Quote: “The `jwt` auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT” (§JWT/OIDC auth method). Fetch sha256: `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` (2026-10-20; S014 retains the superseded `e9472324…` read of 2026-10-19); normalized-text sha256 `ca496ad8f8226d848d2fefa4b1c66d3820e32cdf5d995ee508b44521e752a403`; source file sha256 `8d0aeba8cc43a4d1abe9e9eb0dacbefe7350847dcc6dca4167a2bac1593b0965` at `release/2.7.x` (last changed `ec6ba09f`, 2026-08-10). | mined | 2026-10-20 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |
```

If the integrator instead rules that non-immutable fields may be revised in
place, the minimal migration set is exactly `anchor` + `teaches`, with
`e9472324…` retained in the field as the superseded read. Either way, S014's
row must not be deleted, re-pointed, or silently overwritten.

## 6. Falsifier

The S014/S021 teaching is falsified if any holds on a future re-open:

1. §JWT verification no longer offers exactly three methods, or permits more
   than one method per backend.
2. Q1 is absent, or the docs version label leaves 2.7.x on a release.
3. §Claims as metadata inverts the optionality rule (non-`/` mappings required,
   pointer-mapped claims optional) or states claims are copied without
   `claim_mappings`.
4. The page adds a plan/edition/license gate, or states JWT auth consults
   Kubernetes TokenReview.
5. The source file `website/content/docs/auth/jwt/index.mdx` on `release/2.7.x`
   changes any anchored sentence (check its commit and digest, not the site
   rebuild hash).

## 7. Limits

- Read-only; no registry/entry/stamp edit, no gate run, no Vault/OpenBao
  deployment or probe, no vault/account/credential access.
- S012, S013, S015 and S016 were not re-opened; their legs of E3 and the
  S012-vs-S014 contrast remain unadjudicated here.
- GitHub core API was rate-limited after the release and file-commit queries;
  commit listing was not extended.
- The 2026-10-19 page bytes are unrecoverable (no archive capture, no built-site
  history); §4.1's redeploy explanation is marked [INFERENCE].
- No tools installed; nothing to record.

## 8. Checks for the parent after integration

- `bash corpus/sources-census.sh` over the edited registry (id shape, tier-A
  sole support, `used-by` handshake).
- Literal substring check of Q1 against the live page (not a case-folded
  compare).
- Restamp `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` only after
  the round-22 erratum is final; record old/new per QM14.
- Confirm the migration record names old `e9472324…` and new `449ef132…`, and
  that S014's row is still present.

Report: `.ufo/waves/round-22/build/Source14.md`

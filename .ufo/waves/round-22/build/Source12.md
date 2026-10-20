# Source12 — S012 re-open: Vault JWT/OIDC authentication

- Seat: `KagiR22.Source12` (scout, leaf; no dispatch)
- Axes: **calibration (C1)**, **freshness (C2)**
- Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f`
- Read revision: base content. `git show HEAD:corpus/SOURCES.md` sha256 `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` (43 lines); `git show HEAD:corpus/knowledge/vault-openbao-token-lease-lifecycle.md` sha256 `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb`. The worktree concurrently gained peer additions (S017–S020, search-log erratum, round-22 entry erratum); the S012 row is byte-identical between base and worktree (`diff` empty). Read at 2026-10-20T21:38Z.
- No source-registry, entry, or ledger edits; this report only.

## Verdict (one paragraph)

S012's **content and quoted teaching still stand**: the page carries `dateModified: 2026-04-15T00:14:24.000Z`, the registered quote is present verbatim, and every S012-derived sentence in the E3 entry is supported. But the **row is wrong in two scoped facts**: (1) it merges JWT-role audience binding (required when `aud` is present, Vault 1.17+) with OIDC-role audience binding, which the same page says is *optional*; (2) its revision stamp "newest pinned version v1.21.x" is stale — the served latest page is **v2.x** (Vault 2.0.0 GA 2026-04-14; 2.2.0 GA 2026-10-15). A narrow superseding row is warranted; the old row must remain. The fetch sha256 mismatch is **not evidence of a document change** (site-level byte/chrome drift, or an unrecorded hash method; see §6); it must be documented, not silently re-pinned.

Decision count for this slice: **4 admit, 5 reject/limit, 1 bounded control**. No authored-row-count inference.

---

## 1. Source record (observed, access 2026-10-20)

| field | value |
|---|---|
| URL | https://developer.hashicorp.com/vault/docs/auth/jwt |
| access | 2026-10-20, HTTP 200, 386,400 bytes (raw HTML) |
| raw fetch sha256 | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` |
| registered "Fetch sha256" (2026-10-19; hashing method not recorded in the row) | `ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45` → **not reproduced** (§6) |
| page metadata | `datePublished` = `dateModified` = `2026-04-15T00:14:24.000Z` (JSON-LD in page) |
| h1 | "Use JWT/OIDC authentication" |
| docs version line | `latest` labelled **"v2.x (latest)"**, then `v1.21.x … v1.16.x`; older entries redirect to the version homepage; page states "No versions of this document exist before v1.16.x." |
| article-text sha256 | `ba24a54810062d6c48622b83782888b8bebad0cd38a04e14b538af7da9ee4b6a` (h1 → "Edit this page", tags stripped; `/vault/docs/auth/jwt` and `/vault/docs/v2.x/auth/jwt` are identical) |
| anchored-section sha256 | `684d31324f52f770ac1c1af99ea0ed7f70ada1d7161409d358a1f828bdea8390` (`id="jwt-verification"` → `id="tutorial"`, v2.x/latest) |

### Located quote (≤25 words, verbatim)

**Location:** page-introduction Note ("Note : Starting in Vault 1.17 …"), immediately after the "Supports custom GUI login" bullet and before §OIDC authentication — not inside §JWT verification.
**URL/date:** https://developer.hashicorp.com/vault/docs/auth/jwt, 2026-10-20.

> "the associated `bound_audiences` for the "jwt" role must exactly match at least one of the `aud` claims declared for the JWT" (21 words)

The identical rule is restated without the version gate in §JWT verification (h3, under h2 "JWT authentication") and in §Configuration → §Bound claims (h3). The version gate exists **only** in the introduction Note.

### Supporting quotes (all ≤25 words, same URL/date)

| heading | quote | use |
|---|---|---|
| §JWT verification | "You can only configure one JWT signature verification method per mounted backend" | signature-method limit |
| §JWT verification | "To configure additional verification methods, you must mount and configure one backend instance per method at different paths" | more methods need another mount |
| §JWT verification | "OIDC validation criteria (e.g. `iss`, `aud`, etc.) will be applied" | Discovery validation |
| §Configuration → §Bound claims | "Once a JWT has been validated as being properly signed and not expired" | order of checks |
| §Configuration → §Bound claims | "For roles of type "jwt": the `bound_audiences` parameter is required when an `aud` claim is set" | requirement + role type |
| §Configuration → §Claims as metadata | "If a claim is configured in `claim_mappings`, it must existing in the JWT or else the authentication will fail" [sic: "existing"] | missing mapped claim fails login |
| §OIDC configuration troubleshooting | "`bound_audiences` is optional for OIDC roles and typically not required" | role-type boundary |
| §Configuration | "The default path for the JWT authentication backend is `/jwt`" | mount path |

## 2. Status / eligibility / product / path qualifiers

| qualifier | observed |
|---|---|
| product | HashiCorp **Vault** only; not OpenBao. API doc path `/vault/api-docs/auth/jwt`. |
| method / path | JWT/OIDC auth method; default mount path `auth/jwt` (`/jwt`); custom paths allowed. |
| role type | Two paths on one mount: `role_type="jwt"` (default is `oidc` per API doc). The aud requirement is stated **only for `"jwt"` roles**; OIDC roles keep `bound_audiences` optional. |
| version gate | "Starting in Vault 1.17" for the aud requirement. Confirmed against the pinned v1.16.x page (dateModified 2025-07-02): it has **no** "Starting in Vault 1.17", **no** "For roles of type "jwt"", **no** "must exactly match at least one"; it **does** carry the OIDC-optional sentence. So the boundary is substantive, not just a note. |
| docs version | Latest = **v2.x**; pinned copies v1.21.x–v1.16.x. Last 1.x pin v1.21.x; newest 1.21 patch **1.21.4, 2026-03-05**. Release line: **2.0.0 2026-04-14; 2.1.0 2026-09-01; 2.2.0 2026-10-15** (official releases API + `releases.hashicorp.com/vault/index.json`). |
| status | GA/stable documentation; no preview/beta/tech-preview marker in the article. |
| tier / eligibility | No `ENT` badge on the article; the only "Enterprise" mention is the optional custom GUI default/backup login for "Vault Enterprise GUI users" — not a gate on JWT/OIDC auth itself. |
| config prerequisite | "To support JWT roles, either local keys, JWKS URL(s), or an OIDC Discovery URL must be present." For OIDC roles: Discovery URL + client ID + client secret. |
| deprecation | SHA-1-signed X.509 certificates "no longer usable without a workaround starting in Vault 1.12" (verification-method qualifier). |
| recheck clock | Row's `on-release` is correct in kind but was already due: 2.2.0 GA 2026-10-15, before the row's own `opened: 2026-10-19`. |

## 3. Claim-by-claim comparison with the associated entry

Entry: `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (E3), base revision.

| entry claim (S012-attributed) | verdict | evidence / qualifier |
|---|---|---|
| "signatures are checked against issuer public keys from one configured method per mount — static keys, JWKS, JWKS pairs, or OIDC Discovery; more methods need another mount." | **supported** | §JWT verification quotes above; exact list present. |
| "With OIDC Discovery, 'OIDC validation criteria (e.g. iss, aud, etc.) will be applied'." | **supported** | exact sentence, §JWT verification. |
| "Vault, version-scoped (S012 page note): 'Starting in Vault 1.17', a JWT carrying `aud` needs a role `bound_audiences` that exactly matches one of its values." | **supported** | intro Note; §Bound claims adds "required when an aud claim is set"; role type `jwt`. |
| "binding runs only after the JWT 'has been validated as being properly signed and not expired'; `bound_claims` require listed claims and values." | **supported** | §Bound claims. |
| "§Claims as metadata: a mapped claim missing from the JWT fails login." | **supported** | source sentence above (preserve `[sic]` if quoted). |
| "the role attaches the policy ('gives it the webapps policy') and uses user/groups claims 'to set up Identity aliases'" | **supported** | §Configuration role example, verbatim. |
| *(no S012-attributed claim in the entry says OIDC roles require an audience match)* | **entry is clean** | the overclaim is in the **row's scope/teaches**, not the entry. |

## 4. Calibration decisions (C1)

**Feature-specific link followed** (needed for the "at least one" reading and role-type default): https://developer.hashicorp.com/vault/api-docs/auth/jwt, accessed 2026-10-20, `dateModified` `2026-04-15T00:13:44.000Z`. §JWT role parameters: "`bound_audiences` (array: <optional>) - List of `aud` claims to match against"; "must match at least one of the associated JWT `aud` claims" (11 words); "Type of role, either "oidc" (default) or "jwt"" (8 words). This confirms the requirement is a matching set (any one match suffices) and that `oidc` is the default role type.

**Admit (4):** A1 signature verification + one-method-per-mount; A2 JWT-role aud binding (`bound_audiences` required when `aud` set, 1.17+, "at least one" match); A3 ordering after signature/expiry + `bound_claims` values; A4 missing `claim_mappings` claim fails login + policy/alias from claims.

**Reject / limit (5):**
1. **Reject** the row's unqualified teaches sentence *as a JWT+OIDC rule*. The page separates the paths: OIDC `bound_audiences` is "optional … typically not required"; JWT roles require it when `aud` is present. Applying "Vault requires" to OIDC roles is an overclaim.
2. **Reject** extending the aud rule to Vault < 1.17. The v1.16.x pinned page lacks the requirement; the gate is real.
3. **Reject** any OpenBao extension. Product boundary; S014–S016 are the only OpenBao rows and were not re-opened here.
4. **Reject** reading "exactly match" as whole-set equality. Operative text is "at least one"; the linked API doc says "must match at least one of the associated JWT `aud` claims".
5. **Reject** an Enterprise-only reading. No tier badge; only the optional custom GUI login is Enterprise-scoped.

**Bounded control (admit):**
> In Vault ≥ 1.17, for roles of type `jwt`, a presented JWT that carries `aud` requires `bound_audiences`, and at least one configured value must exactly equal one of the JWT's `aud` values. Signature keys come from exactly one verification method per mounted backend (static keys | JWKS | JWKS pairs | OIDC Discovery). Bound-claim/metadata checks run only after signature and expiry validation; a `claim_mappings` entry absent from the JWT fails login. OIDC roles: `bound_audiences` is optional.

E1 is outside this slice (no S012 citation). The E3 product-merging overclaim is already withdrawn by the entry's round-21 erratum; S012 supplies only the Vault login/claims clock, never OpenBao or KV.

## 5. Freshness reconciliation (C2) — stale revision stamp

**Old row text (immutable):**
> "latest page as served 2026-10-19, newest pinned version v1.21.x; audience note applies starting Vault 1.17"

**Observed 2026-10-20:** latest = **v2.x**; the article text served at `/vault/docs/auth/jwt` is identical (article-text hash `ba24…`) to `/vault/docs/v2.x/auth/jwt`; pinned copies are v1.21.x…v1.16.x. The v2.x content metadata is `dateModified 2026-04-15`, the day after Vault 2.0.0 GA (2026-04-14).

**Historic evidence (exact):**

| event | date | evidence |
|---|---|---|
| Vault 1.21.0 | 2025-10-22 | releases API |
| Vault 1.21.4 (last 1.21 patch) | 2026-03-05 | releases API |
| Vault 2.0.0 GA | 2026-04-14 | releases API |
| v2.x docs content | 2026-04-15 | `dateModified` |
| Vault 2.1.0 | 2026-09-01 | releases API |
| Vault 2.2.0 GA (current) | 2026-10-15 | releases API + release index |
| row opened | 2026-10-19 | row `opened` |

**Teaching invariance:** the aud/bound/claims text is unchanged between v1.21.x and v2.x; the only non-equal block in the anchored region (`id="jwt-verification"` → `id="tutorial"`) is an added Azure CLI parameter (`distributed_claim_access_token`) in §Via the CLI. So the stale stamp does **not** withdraw any claim; it changes the version line and the recheck expectation. No silent deletion, no laundering: keep S012, supersede the qualifier only.

**Ledger expectation migration (proposed wording):**
- `anchor`: replace "newest pinned version v1.21.x" with "latest = v2.x as served 2026-10-20 (dateModified 2026-04-15); pinned v1.21.x–v1.16.x; last 1.21 patch 1.21.4 (2026-03-05); Vault 2.2.0 GA 2026-10-15".
- `recheck`: on a Vault or OpenBao release, re-open the introduction 1.17 Note **and** §JWT verification, and re-read the docs version line — not only the aud sentence.
- Entry header: "unversioned 'latest' page as served 2026-10-19; version switcher's newest pinned entry v1.21.x" → "unversioned 'latest' page as served 2026-10-20 = v2.x (dateModified 2026-04-15; article hash `ba24…`); pinned copies v1.21.x–v1.16.x". Also state that the quoted 1.17 sentence sits in the page-introduction Note; §JWT verification/§Bound claims restate the rule without the version gate.

## 6. Fetch-sha256 reconciliation — no content-change evidence

| check | result |
|---|---|
| registered S012 "Fetch sha256" (method not recorded) | `ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45` |
| 2026-10-20 raw sha256 | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` (two sequential fetches identical; plain, `--compressed`, Mozilla UA, trailing slash, query-string variants all identical) |
| same-site control S013 | registered `ae321512d37…` vs today `de5f8836b2…` → **also mismatches**; S013 `dateModified` 2026-04-15 |
| off-site control S011 (getsops) | registered `d0ab8b201f…` vs today `d0ab8b201f…` → **exact match** |
| shared build id | S012 and S013 both `build-TfctsWXpff2fKS` |
| page chrome | time-relative HashiConf livestream banner in raw HTML |

**Diagnosis:** the mismatch is **not evidence that the JWT document changed**. Same-day bytes are stable, but cross-day identity failed for **both** reopened HashiCorp pages (S012, S013) while the non-HashiCorp control (S011) matched exactly; both HashiCorp pages carry the same old `dateModified` (2026-04-15) and a time-relative banner. This is consistent with site-level byte/chrome drift, but the row does not record how its hash was computed, so a method difference cannot be excluded. The registered hash cannot be reproduced with plain curl variants today, and no 2026-10-19 bytes were retained. Action: **do not** mark S012 "changed" and **do not** silently replace the old hash. Record the raw hash with its method/date **plus** the stable article-text hash (`ba24…`) and `dateModified`; if the ledger requires one hash, the text-region hash is the defensible pin.

## 7. Proposed superseding row (needed; not written)

Reason: the existing row's **scope + teaches** merge jwt-role "required" with OIDC-role "optional" audience binding, and its **version stamp** is factually stale. The quote and teaching are unchanged, so this is a qualifier/anchor supersession, not a retraction. ID: next free at read time is **≥ S021** (S017–S020 were added by peers in this worktree); renumber if another seat claims it.

| id | source | kind | tier | scope | anchor | teaches | status | opened | recheck | used-by |
|---|---|---|---|---|---|---|---|---|---|---|
| S021 | Use JWT/OIDC authentication — https://developer.hashicorp.com/vault/docs/auth/jwt | docs | A | Vault role-type-specific audience binding: jwt roles require `bound_audiences` when `aud` is present; OIDC roles keep it optional; JWT signature-key configuration | Page-introduction Note (before §OIDC authentication), §JWT verification, §Configuration §Bound claims/§Claims as metadata, §OIDC configuration troubleshooting; latest served 2026-10-20 = v2.x (dateModified 2026-04-15T00:14:24Z); pinned copies v1.21.x–v1.16.x | supersedes S012 for scope/version qualifiers only (quote unchanged) — from Vault 1.17, roles of type `jwt` with an `aud` claim require `bound_audiences` matching at least one `aud` value; OIDC roles keep it optional. Quote: "the associated `bound_audiences` for the "jwt" role must exactly match at least one of the `aud` claims declared for the JWT" (page-introduction Note). Raw fetch sha256 2026-10-20 (same-day stable; not across days): `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa`; article-text sha256: `ba24a54810062d6c48622b83782888b8bebad0cd38a04e14b538af7da9ee4b6a`. | mined | 2026-10-20 | on-release | corpus/knowledge/vault-openbao-token-lease-lifecycle.md |

Preferred: add the superseding row above (row immutability). If the integration owner instead permits a field-level qualifier correction, use the §5 wording; either way, do not delete or rewrite S012's captured quote or sha.

## 8. Falsifier

- **Teaching:** a served Vault docs page that drops the jwt-role `aud` requirement, makes `bound_audiences` optional for jwt roles carrying `aud`, moves the gate off Vault 1.17, or allows more than one signature-verification method per mounted backend.
- **OIDC boundary:** a current Vault page stating `bound_audiences` is required for OIDC roles (would collapse the role-type distinction).
- **Claims mapping:** a page stating a missing `claim_mappings` claim is ignored rather than failing login.
- **Freshness:** a served version line whose latest is again 1.x (would reopen the stamp).

## 9. Limits / remaining unknowns

- Vendor documentation only; no Vault/OpenBao binary was run and no vault, account, or credential was contacted.
- Wayback availability API returned HTTP 429, so the **2026-10-19 served version switcher** could not be independently verified. The row's v1.21.x stamp may have been a misread of the switcher rather than a page change; either way it is wrong as of 2026-10-20.
- `dateModified` is page metadata, not proof that no edit occurred; the pre-2026-10-19 raw bytes are unavailable.
- The raw hash includes all site chrome and a time-relative banner; the article-text hash starts at the `<h1>` and ends at "Edit this page on GitHub", so navigation before the h1 is excluded.
- The page's embedded RSC/JSON payload was not decoded separately; rendered DOM text is the evidence.
- S014–S016 (OpenBao) were not re-opened; no cross-product inference is made here.

## 10. Checks the parent should run after integration

1. `grep -n '^| S012 ' corpus/SOURCES.md` — confirm S012 untouched; `grep -n '^| S021 ' corpus/SOURCES.md` — confirm no ID collision before adding the superseding row.
2. `bash corpus/sources-census.sh` — R21-02 chain re-verification (every `source:` id resolves to a `mined` row whose `used-by` lists the entry).
3. `bash corpus/claim-ledger.sh` — if the round's ledger covers the E3 claim set.
4. Fresh-hash check: `curl -sSL https://developer.hashicorp.com/vault/docs/auth/jwt | sha256sum`; if it differs from `9a65…`, check `dateModified` (2026-04-15) before treating it as a content change.

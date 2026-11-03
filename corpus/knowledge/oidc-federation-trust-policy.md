source: S061 — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html — §"Create an OpenID Connect (OIDC) identity provider in IAM", `claims_supported` list (aud, iat, iss) — page fetch sha256 `141dd4819db34dc2`, fetched 2026-11-03; S062 — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html — §"Available keys for AWS OIDC federation" (provider:claim keys; the "Available in session" column) — page fetch sha256 `fb5b2e35ec37c18b`, fetched 2026-11-03; S063 — https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html — Response Elements, `Audience` element description (the page's only `Audience` occurrences; the request-parameter list carries none) — page fetch sha256 `a08888ce4d86adf2`, fetched 2026-11-03; S064 — https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation — §"Best practices" (bullets "Use attribute conditions when federating with GitHub or other multi-tenant identity providers"; "Use a single provider per workload identity pool to avoid subject collisions"; "Use the URL of the workload identity pool provider as audience") — page fetch sha256 `116398b3807c1016` (raw body carries per-request markup; stable rendered-text-v1 sha256 `92c7db2c25ab9766`), fetched 2026-11-03; S065 — https://docs.cloud.google.com/iam/docs/workload-identity-federation?hl=ja — §属性条件, the `google.subject=assertion.sub` attribute-mapping sample — page fetch sha256 `0179cc57506a632e` (raw body carries per-request markup; stable rendered-text-v1 sha256 `7a5a1c571fc5cef4`), fetched 2026-11-03; S066 — https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp — §创建OIDC身份提供商的RAM角色 → 操作步骤 → 服务级限制条件表 (限制条件关键字 / 说明 / 是否必选 / 示例), rows `oidc:iss`, `oidc:aud`, `oidc:sub` — page fetch sha256 `0e2d9afdfda461bd` (raw body carries per-request markup; stable rendered-text-v1 sha256 `8b21f8346902b086`), fetched 2026-11-03; S067 — https://openid.net/specs/openid-connect-core-1_0.html — §3.1.3.6 "ID Token", claim list entry `aud` (REQUIRED) — "Final: OpenID Connect Core 1.0 incorporating errata set 2", page fetch sha256 `4d016752a645e8a3`, fetched 2026-11-03; S068 — https://www.rfc-editor.org/rfc/rfc9700.txt — §4.10.2 "Audience-Restricted Access Tokens" — RFC 9700, BCP 240, January 2025, page fetch sha256 `9919d061d40a9788`, fetched 2026-11-03
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (receipts .ufo/waves/round-31/src-open/, cross-checked independently by the OidcEntry1 and AttackOidc seats); campaign dates 2026-10-23 are not evidence here
recheck: 180d — `curl -fsSL --max-time 30 'https://openid.net/specs/openid-connect-core-1_0.html' | grep -c 'It MUST contain the OAuth 2.0'` -> 1 (ran 2026-11-03)
ground: OIDC workload-federation trust policy — issuer, audience, identity-claim binding, and resulting permissions (the round-21 frontier lead; the cloud-provider and protocol layer the lane's GitHub-OIDC rows S047/S050 do not cover)
Reverify: R31-02

# OIDC workload-federation trust policy: issuer, audience, subject, and the four dialects

A workload-federation trust policy is one idea expressed in four dialects. The
underlying rule is identical in every provider; only the vocabulary changes.

## The rule

A trust policy answers one question: *is this token, minted by this issuer, meant
for this audience, and does it say it is this particular workload?* Three claims
do that work, and the permission they produce is the policy's output, not a
fourth claim.

- **`iss` (issuer)** — who minted the token. Each provider constrains the issuer
  URL it accepts, in its own words: AWS says the URL "must begin with https://"
  and "should correspond to the Provider URL provided to IAM", that path
  components are allowed but query parameters are not, and that it "should not
  contain a port number" [S061]; Alibaba's `oidc:iss` condition value can only be
  the issuer URL configured in the OIDC identity provider [S066].
- **`aud` (audience)** — who the token is *for*. This is the claim that does the
  load-bearing work, and it is the one the specifications make mandatory rather
  than optional.
- **`sub` (subject)** — who the workload *is*. IdP-specific: AWS exposes it as
  `provider:sub` [S062], Alibaba as `oidc:sub` [S066], and GCP maps
  `assertion.sub` onto the `google.subject` attribute [S065]. It identifies the
  workload inside the issuer's namespace, not globally, because several external
  identities can map onto one principal [S064].
- **the resulting permission** — the role or principal the token maps to. It is
  chosen by the request's `RoleArn` and returned as the policy's outcome; it is
  not a claim the token carries [S063].

## Why `aud` is the claim that matters

OpenID Connect Core makes `aud` a **REQUIRED** ID Token claim, and it "MUST
contain the OAuth 2.0 client_id of the Relying Party as an audience value"
[S067]. The audience is therefore not a hint about who sent the token; it is the
token's statement of which application it is for.

That is why a trust policy that checks `iss` and `sub` but omits `aud` leaves the
token's application-binding unchecked — the gap RFC 9700's audience-restriction
guidance exists to close [S068]. RFC 9700 states the same rule on the
resource-server side, written for access tokens: the resource server "is then
supposed to verify the intended audience", and "If the access token fails the
intended audience validation, the resource server refuses to serve the respective
request" [S068]. The recommendation to use that audience restriction is
SHOULD-level and its scope is access tokens; the ID-token case this entry is
about is the issuer-side twin of the same obligation, not the RFC's own wording.

## The four dialects

| provider | where the trust decision lives | audience | subject |
|---|---|---|---|
| AWS IAM | role trust policy; conditions are `provider:claim` keys, e.g. `token.actions.githubusercontent.com:aud` [S062] | `aud` must match the **Audience value configured at IdP registration** [S061] | `provider:sub` [S062] |
| AWS STS | the STS call takes no audience input: the token carries `aud`, the role trust policy's `provider:aud` condition checks it, and the response echoes it back in the `Audience` element — "The intended audience (also known as client ID) of the web identity token" [S063] | carried by the token; enforced by the trust-policy condition, not by the STS call [S062][S063] | the token's `sub`, published as the `provider:sub` condition keys [S062]; `ProviderId` belongs to the OAuth 2.0 request form, and the page says not to specify it for an OpenID Connect identity provider [S063] |
| Google Cloud | **attribute condition**, a CEL expression checking assertion and target attributes [S065] | the pool-provider URL, per GCP's best-practice bullet "Use the URL of the workload identity pool provider as audience" [S064] | `assertion.sub`, mapped onto the `google.subject` attribute [S065] |
| Alibaba Cloud RAM | trust-policy 限制条件 with `oidc:iss`, `oidc:aud`, `oidc:sub` [S066] | `oidc:aud`, **mandatory**, `StringEquals` [S066] | `oidc:sub`, **optional**, at most 10 values [S066] |

Two contrasts are worth memorising because they invert intuition:

- **AWS pins the audience at registration; GCP's guidance is to use the
  pool-provider URL as the audience** [S061][S064]. "What is the audience" is a
  configuration choice, not a constant.
- **Alibaba Cloud makes issuer and audience mandatory and subject optional**
  [S066]; **AWS's OIDC federation condition-key set is `amr`, `aud`, `email`,
  `oaud` and `sub` — the issuer is not among them** [S062]. The Chinese-market
  table is explicit: `oidc:iss` 是, `oidc:aud` 是, `oidc:sub` 否.

## GCP's extra hazard: subject collisions

GCP's guidance warns that "the same external identity might be represented as
multiple different IAM principals, or several external identities could map to the
same IAM principal" [S064], and pairs that ambiguity with two prescriptions: a
single provider per workload identity pool, and attribute conditions when
federating with GitHub or other multi-tenant identity providers [S064]. The
distinguishing information therefore has to be carried by claims and attribute
conditions, not by the subject alone.

## A claim outside the session is a trust-policy-only claim

AWS states that when a claim is not available in session, the OIDC condition
context key "can only be used in a role trust policy for the initial
AssumeRoleWithWebIdentity authentication" [S062]. Practical consequence: a claim
you want to check on every API call must be present in the session, and a claim
you can only check at token-exchange time cannot be used to scope permissions
afterwards.

## What this entry does not establish

- It does not describe the **GitHub**-side subject format or claim-condition
  semantics; the lane already holds that ground (rows S047/S050), and this entry
  adds only the cloud-provider and protocol layers.
- It does not cover the **Vault-side** audience check on a JWT/OIDC login (lane
  rows S012/S022), which is the consuming side of the same idea.
- It does not claim that any provider's attribute-condition or trust-policy
  semantics are stable: every page here is pinned by a fetch digest and
  re-checked on a 180-day cadence. The AWS pages carry no version stamp (0 stamp
  hits on the re-opened bodies); the GCP pages do ("Last updated 2026-10-29 UTC"
  on the best-practices page, "最終更新日 2026-03-04 UTC" on the ja page); the
  Alibaba page renders an empty 更新时间 value in static HTML. For the volatile
  pages the raw body carries per-request markup, so the stable pin is the
  rendered-text-v1 digest recorded in the source line above; the two
  specification documents carry their own revision stamps.
- Chinese and Japanese material is represented by the vendor's own documentation
  in that language [S066][S065]; a translated summary of the English page was not
  accepted as a substitute.

**Falsifier:** a provider page that drops the aud/registration binding (the
"Audience value" requirement leaves the create-oidc page, or Alibaba's `oidc:aud`
becomes optional), or a vendor-documented trust policy that accepts a token whose
`aud` differs from the registered audience, falsifies the audience-pinning claim
this entry rests on; the affected provider row is then re-derived from the
re-opened page and the entry corrected in a new round.

---

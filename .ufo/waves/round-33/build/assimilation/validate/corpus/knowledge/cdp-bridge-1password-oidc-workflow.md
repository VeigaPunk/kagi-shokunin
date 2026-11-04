source: S069 — https://www.1password.dev/brokered-access — §"Custom Workflow (OIDC)" setup steps 1-5 (issuer URL and JWKS, claim requirements, expected audience, integration key) — page fetch sha256 `6179e9c140851529` (raw body carries per-request markup; stable rendered-text-v1 sha256 `232239dd8ae8e792`), fetched 2026-11-03; S070 — https://www.1password.dev/brokered-access/custom-workflow — page title "(public beta)", §"Step 2. Connect your Environment to your workflow" and §"Step 3: Use your Environment in your workflow" (the SDK-client triple; additional and inherited access conditions) — page fetch sha256 `a34902cc251b9d9c` (raw body carries per-request markup; stable rendered-text-v1 sha256 `20fbc423c4faea78`), fetched 2026-11-03; S071 — https://1password.com/jp/product/credential-broker — §"1Password Credential Broker マシンとAIエージェントによる実行時の認証情報アクセス" (lead paragraph) and the FAQ entries on Workload Identity Federation verification and on general availability — page fetch sha256 `a5d4a10132d672c4` (raw bytes varied across five fetches while the rendered text stayed identical; stable rendered-text-v1 sha256 `0c2d13e54cc059d0`), fetched 2026-11-03; S066 — https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp — §创建可信实体为身份提供商的RAM角色 → 操作步骤 → 限制条件关键字 table (说明 / 是否必选 / 示例), rows `oidc:iss`, `oidc:aud`, `oidc:sub` — page fetch sha256 `0e2d9afdfda461bd` (raw body carries per-request markup; stable rendered-text-v1 sha256 `8b21f8346902b086`), fetched 2026-11-03
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (receipts .ufo/waves/round-31/src-open/, group-c for the three Broker pages and group-b for the Alibaba page; re-fetched and re-located independently by this seat); campaign dates 2026-10-23 are not evidence here
recheck: 180d — `curl -fsSL --max-time 30 'https://www.1password.dev/brokered-access/custom-workflow' | python3 corpus/rendered-text-v1.py locate /dev/stdin 'The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator'` -> count=1 (ran 2026-11-03)
ground: OIDC workload federation trust policy — the consuming side: the 1Password Broker custom-OIDC workflow's own trust decision (administrator setup steps and the runtime authentication triple), the half of the round-21 frontier lead the lane's existing Broker rows hold only as status and eligibility
Reverify: R31-02

# 1Password Credential Broker, custom OIDC workflow: the trust decision on the consuming side

This entry is an addition to the lane's existing `onepassword-machine-credentials.md`
entry — which records that a workload's configured trust policy determines which
credentials it may retrieve during the authorized job — not a replacement for it.
What was missing is the custom-OIDC mechanism itself, and the pages below are
where it lives.

## The administrator's side: a three-part trust decision

Setting up a **Custom Workflow (OIDC)** integration takes three trust inputs
[S069]:

1. **The issuer.** "Enter a name for the integration, then enter your OIDC
   provider’s issuer URL", with a JWKS endpoint that can be entered manually if
   it is not detected automatically [S069].
2. **The claims.** The page asks the administrator to "Define the identity
   requirements (claims) that must be met to verify a workload", and the
   load-bearing sentence is short: "All configured claims must match to verify
   the workload’s identity" [S069]. The page's own example is restriction to
   "GitLab CI/CD jobs running in a specific project, branch, environment, etc."
   — the configured claims are how a workload is narrowed to its intended scope.
3. **The audience.** "Make note of the expected audience value. Your team
   members will need to declare this when their workflows request an OIDC
   token." [S069]

Plus the integration key: the token value the workflow presents to decrypt
secrets. The setup page says to "configure the key as a secret that can be
retrieved at runtime", for example as a CI/CD variable [S069]; the runtime
page's SDK sample reads it from `OP_INTEGRATION_KEY` [S070].

## The workload's side: a triple

At runtime, the workflow builds a 1Password SDK client that "authenticates using
your OIDC token, workload ID, and the integration key configured by your
administrator", and then calls a function to retrieve secrets from the
Environment [S070]. The Environment may also carry its own conditions: the
workflow author can "(Optional) Define any additional access conditions you
want to enforce", and sees "any inherited conditions your administrator
configured for the integration" [S070].

## What this adds to the corridor

This is the **consuming** end of the federation corridor the
`oidc-federation-trust-policy` entry describes from the provider side. The
same three-part decision appears on both ends — issuer, claims, audience — with
one inversion worth noting:

| | Provider side (Alibaba Cloud RAM) | Consumer side (1Password Broker) |
|---|---|---|
| issuer | `oidc:iss` — required (是), `StringEquals`, value must be the issuer URL entered in the OIDC identity provider [S066] | entered by the administrator, then the JWKS endpoint resolves it [S069] |
| claims | `oidc:sub` — optional (否), any `String` operator, at most 10 subjects [S066] | "All configured claims must match" — an AND over the configured set [S069] |
| audience | `oidc:aud` — required (是), `StringEquals`, value must be one of the client IDs configured on the identity provider [S066] | the administrator notes the expected audience value, and the team members declare it when their workflows request an OIDC token [S069] |

Two operational details are worth keeping. The claim check is conjunctive — a
claim that does not match leaves the workload's identity unverified [S069]. And
the audience is a value stated in one place and declared in another, so it
belongs to two configurations at once.

The broker also adds a **workload ID** alongside the OIDC token and the
integration key [S070]. None of the provider pages cited by the two OIDC
entries names a separate per-workload identifier credential: Alibaba's table
lists three condition keys, `oidc:iss`, `oidc:aud` and `oidc:sub` [S066], and
the AWS and Google Cloud pages name no such credential of their own.

## The Japanese rendering, as a point observation of its own

The Japanese product page is a separate rendering of the same product, and this
entry treats it that way: it is what that page says, dated, not a translation
of the English pages and not a second source for their claims. Its lead
sentence reads 「実行時にAIエージェントとマシンワークロードを検証し、それぞれが
受け取る権限を持つ認証情報のみを提供します。」 and its Workload Identity
Federation FAQ entry reads 「Credential Brokerは、認証情報を配信する前に、
Workload Identity Federationを使用してワークロードのIDを検証します。」 [S071]

The same page also states a release status, in Japanese only: 「まだ一般提供されて
いません。Credential Brokerは現在、すべてのEnterprise Password Managerの
お客様向けにプレビュー版が公開されています。これにはGitHub Actionとカスタム
OIDC構成が含まれます。」 [S071] — the English status strings do not appear on
this page at all, so a status sweep over English needles reports nothing here
while the page still carries a status.

That status is a **product-level** label: it names the GitHub Actions path and
the custom OIDC configuration together. It therefore does not settle the
custom-OIDC path's status, and nothing in this entry rests on it for status.
The feature-level reading is the lane's existing ground: the runtime page's own
title carries "(public beta)" [S070], and the lane's status rows
(corpus/knowledge/feature-bound-credential-review.md) already hold the
per-feature split between the GitHub Actions path and the custom OIDC path. The
round-22 outside check rejected the uniform-preview reading, and this entry
does not revive it.

## What this entry does not establish

- It does not establish general availability, and it states no product-level
  status of its own: the runtime page's own title carries the feature-level
  status "(public beta)" (re-verified 2026-11-03), the guide-level pages carry
  a guide-level "(public preview)" label, and the lane's status rows
  (S017/S018, with S020's announcement distinguishing them) already hold that
  per-feature split. The Japanese page cited here carries a product-level
  status of its own, quoted above and explicitly not used as a per-feature
  status.
- It does not cover the GitHub Actions integration path, which the same
  administrator page documents separately, nor the service-account path.
- It does not change the existing entries: `onepassword-machine-credentials.md`
  remains the product-level record, and this entry adds the custom-OIDC
  mechanism under a distinct path.

**Falsifier:** a broker page or runtime behavior that verifies a workflow whose
configured claims do not all match (the conjunctive rule relaxed), or that drops
the declared-audience step, or pages that remove the triple sentence or the
"(public beta)" title, falsifies the mechanism claims; the affected row is
re-opened and the entry corrected in a new round.

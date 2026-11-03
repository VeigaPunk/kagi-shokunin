source: S066 — https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp — §创建OIDC身份提供商的RAM角色 → 操作步骤 → 服务级限制条件表, rows `oidc:iss`, `oidc:aud`, `oidc:sub` — page fetch sha256 `0e2d9afdfda461bd` (raw body carries per-request markup; stable rendered-text-v1 sha256 `8b21f8346902b086`), fetched 2026-11-03; S069 — https://www.1password.dev/brokered-access — §"Custom Workflow (OIDC)" setup steps 1-5 (issuer URL, claim requirements, expected audience, integration key) — page fetch sha256 `6179e9c140851529` (raw body carries per-request markup; stable rendered-text-v1 sha256 `232239dd8ae8e792`), fetched 2026-11-03; S070 — https://www.1password.dev/brokered-access/custom-workflow — page title "(public beta)", §"Step 2. Connect your Environment to your workflow" and §"Step 3: Use your Environment in your workflow" (additional and inherited access conditions; the SDK-client triple sentence) — page fetch sha256 `a34902cc251b9d9c` (raw body carries per-request markup; stable rendered-text-v1 sha256 `20fbc423c4faea78`), fetched 2026-11-03; S071 — https://1password.com/jp/product/credential-broker — §"1Password Credential Broker マシンとAIエージェントによる実行時の認証情報アクセス" (lead paragraph) and the Workload Identity Federation FAQ entry — page fetch sha256 `a5d4a10132d672c4` (raw body varied across five fetches while the rendered text stayed identical; stable rendered-text-v1 sha256 `0c2d13e54cc059d0`), fetched 2026-11-03
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (receipts .ufo/waves/round-31/src-open/, cross-checked independently by the AttackOidc seat); campaign dates 2026-10-23 are not evidence here
recheck: 180d — `curl -fsSL --max-time 30 'https://www.1password.dev/brokered-access' | grep -c 'All configured claims must match'` -> 1 (ran 2026-11-03)
ground: the lane's OIDC workload-federation frontier lead (corpus/SOURCES.md §Leads; the custom-workflow page opened as S018 in round 22) — the consuming-side trust decision, which the lane's existing entries hold only as status and eligibility
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
   provider's issuer URL", with a JWKS endpoint that can be entered manually if
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
`oidc-federation-trust-policy` entry described from the provider side. The
same three-part decision appears on both ends — issuer, claims, audience — with
one inversion worth noting:

| | Provider side (AWS / GCP / Alibaba) | Consumer side (1Password Broker) |
|---|---|---|
| issuer | registered against the provider, must match the token's `iss` | entered by the administrator, then the JWKS endpoint resolves it [S069] |
| claims | condition keys on the token (`oidc:sub`, `oidc:aud`) [S066] | "All configured claims must match" — an AND over the configured set [S069] |
| audience | the provider checks the token's `aud` against its own configuration | the administrator states the expected audience, and the **workload declares it** when it requests a token [S069] |

Two operational details are worth keeping: the claim check is conjunctive, so a
single misconfigured claim makes every workflow requesting under that
integration fail closed; and the audience value is the workload's
responsibility to declare, which makes the audience a shared value between two
configurations in two places.

The broker also adds a **workload ID** alongside the OIDC token and the
integration key [S070] — none of the six provider pages cited by the two OIDC
entries names a separate workload-ID credential, because the provider dialects
identify the workload through the subject claim instead.

## What this entry does not establish

- It does not establish general availability, and it states no product-level
  status of its own: the runtime page's own title carries the feature-level
  status "(public beta)" (re-verified 2026-11-03), the guide-level pages carry a
  guide-level "(public preview)" label, and the lane's status rows (S017/S018,
  with S020's announcement distinguishing them) already hold that per-feature
  split — the round-22 outside check rejected the uniform-preview reading, and
  this entry does not revive it. The JP product page cited here carries no
  release status at all (0 status hits on the re-opened body), so nothing in
  this entry rests on it for status.
- It does not cover the GitHub Actions integration path, which the same
  administrator page documents separately, nor the service-account path.
- It does not change the existing entries: `onepassword-machine-credentials.md`
  remains the product-level record, and this entry adds the custom-OIDC
  mechanism under a distinct path.

**Falsifier:** a broker page or runtime behavior that verifies a workflow whose
configured claims do not all match (the conjunctive rule relaxed), or that
drops the declared-audience step, or pages that remove the triple sentence or
the "(public beta)" title, falsifies the mechanism claims; the affected row is
re-opened and the entry corrected in a new round.

---

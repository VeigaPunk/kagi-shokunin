source: S017 (https://www.1password.dev/brokered-access/github-actions/, title and introduction); S018 (https://www.1password.dev/brokered-access/custom-workflow/, title, introduction, Steps 1/3); S019 (https://www.1password.dev/brokered-access, introduction and GitHub Actions requirements); S020 (https://1password.com/blog/1password-credential-broker-public-preview, introduction and New in this release, 2026-07-28); S021 (https://openbao.org/docs/concepts/tokens/, Token Time-To-Live and Token type comparison, Version 2.7.x)
verified-at: 2026-10-20 (public pages opened; documentation only, no deployment/account/vault probe)
recheck: on-release — open both Broker feature pages separately, setup eligibility and OpenBao's product/version-specific token page; a changed qualifier invalidates its row below.
Reverify: R21-02

# Active review: feature status, eligibility and product-bound evidence

This is the corrected active reading for the Broker status/eligibility and
cross-product token rows in the older machine-credentials and Vault/OpenBao
entries. Their original bodies and appended errata remain historical records;
readers must not operate from their superseded merged rows. This replaces
incorrect readings on already-held ground, not a new coverage area.

| Decision subject | Bounded admitted reading | Reject this overreach | Evidence |
|---|---|---|---|
| Broker GitHub Actions | Public preview; administrator connects a 1Password Business account to a GitHub.com organization. Enterprise Server and Enterprise Cloud with data residency are unsupported; Free organizations cannot use this integration for private-repository workflows. | available to any plan/deployment; preview status used for custom OIDC too | S017 title/introduction; S019 GitHub Actions requirements |
| Broker custom OIDC | Public beta; administrator connects an OIDC provider to the Business account; latest beta desktop app required; currently JavaScript SDK only. | public preview because the setup guide title says so; every SDK supported | S018 title, introduction, Steps 1/3 |
| Broker credential custody | EPM Business eligibility; the announcement distinguishes Actions preview from beta custom-OIDC rollout. The setup still requires the integration key; workflow-duration delivery does not prove token expiry or removal of every CI-held key. | OIDC means no stored key or makes a Service Account token expire with its child process | S020 introduction/New in this release; S019 setup steps |
| OpenBao service tokens | In OpenBao 2.7.x's service-token context, non-root tokens have TTL; after TTL the service token no longer functions and its associated leases are revoked. Batch-token renewal/manual-revocation limits and lease handling are separate; this row does not generalize service-token lease behavior to batch tokens. | extend this to Vault tokens, infer KV deletion/retention, or erase token-type distinctions | S021 Token Time-To-Live, Token types and Token type comparison |
| Missing product support | A Vault-only citation does not establish an OpenBao claim, nor the reverse. Leave the unsourced product claim unverified. | identical-sounding product names establish lifecycle parity | the independently scoped sources above; QUALITY QA9/QA10 |

## How to use the review

Name product, feature/path, status or version, eligibility and supporting
source before an admit. Follow the **feature-specific** link; a parent guide
or product announcement is not a universal status oracle. For source
qualifiers not represented by a typed review gate, perform the public-page
review directly. A structurally valid record is not automatic prose admission.

`R21-02` checks the source-registry citation chain only. It does not reopen
pages or establish vendor truth. Likewise a revision stamp proves local-byte
identity, not that historical host files or deployed behavior are current.
No source here establishes Vault token mechanics, OpenBao KV retention,
other-provider JWT revocation, live integration availability or credential
access for this host.

## Falsifier

A feature page changing status, Business/setup eligibility, supported SDK,
app channel or deployment restrictions; an OpenBao version changing the cited
token-type/TTL rules; or a cited page failing to carry its claimed qualifier
invalidates the corresponding admitted row. Reject the changed row until its
source is reopened and a new correction is recorded.

## Projection and wording limits (round-22 falsification)

The Actions hosting exclusions mean **currently unsupported as documented
on 2026-10-20**, not an everlasting product guarantee. The EPM Business
sentence is the **2026-07-28 product announcement's** eligibility statement;
the feature pages separately require a connected **1Password Business
account**. These are recorded as distinct conditions, not proof that the
two commercial labels are identical or that a particular customer has
feature entitlement.

The typed gate accepts the exact reviewed evidence projection. A valid
alternate/superset or more-conservative claim can fail that representation;
its rejection is not proof the source claim is false. Selected
`runtime_constraints` are not a complete workflow-prerequisite inventory.
Unrepresented setup permissions/app prerequisites require direct page
review, and no admitted typed record authorizes a real credential action.

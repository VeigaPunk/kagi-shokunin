# Machine credential custody boundaries
source: S001 (https://www.1password.dev/cli/secrets-scripts, §Use `op run` to pass environment variables from a 1Password Environment, current page with no displayed version/date, opened 2026-10-19); S004 (https://www.1password.dev/service-accounts/security, §Access control and §Token rotation and revocation, current page with no displayed version/date, opened 2026-10-19); S002 (https://www.1password.dev/connect, page introduction and Connect-server diagram caption, current page with no displayed version/date, opened 2026-10-19); S003 (https://www.1password.dev/connect/get-started, §Deployment Step 1 and Step 3, current page with no displayed version/date, opened 2026-10-19); S006 (https://1password.com/blog/1password-credential-broker-public-preview, §How 1Password Credential Broker works and §Try 1Password Credential Broker today, published 2026-07-28); S007 (https://www.1password.dev/brokered-access, page introduction, §GitHub Actions and §Custom Workflow (OIDC), current page with no displayed version/date, opened 2026-10-19)
verified-at: 2026-10-19 (reopened the six cited public documentation pages and recorded their fetched-byte digests in `corpus/SOURCES.md`)
recheck: 90d for S001–S004; on-release for S006–S007 — reopen the cited CLI, Service Account, Connect, and Broker sections; check Broker preview status, claim requirements, workflow duration, and integration-key custody.
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the pages or re-measure product behaviour; `recheck:` is the content clock.)

## Four custody boundaries

1. **Process-lifetime delivery.** When `op run` provisions Environment variables to an application or script, the CLI runs it in a subprocess and supplies those variables for the duration of that process [S001]. This describes the delivered process environment, not the lifetime of the Service Account token used for authentication [S001, S004].

2. **Service Account token and vault scope.** A Service Account's accessible vaults and access level bound the information it can return; the vendor also documents token rotation and revocation [S004]. Those are Service Account authorization and token-lifecycle controls, distinct from the process-scoped delivery described by `op run` [S001, S004].

3. **Connect server credentials and application API tokens.** Connect setup creates deployment credentials for the server and a separate access token for applications or services to authenticate to its REST API; the setup guide recommends a separate token for each application or service [S002, S003]. The deployment credential and caller token therefore occupy different custody boundaries [S003].

4. **Credential Broker public preview.** In its announcement published 2026-07-28, 1Password described Credential Broker as public preview and said a workload's configured trust policy determines which credentials it may retrieve during the authorized job, without standing vault access [S006]. The current setup guide also labels the workflow integration public preview, requires every configured OIDC claim to match, and limits access to the workflow duration [S007]. For GitHub Actions, the setup guide directs administrators to store the integration key as an organization CI secret; the announcement describes that key as an encryption key rather than a standing Service Account token and says a valid OIDC identity is also needed to decrypt [S006, S007].

## How kagi uses this

The-janitor's `run` path execs `op run --env-file` [existing lane entry `corpus/knowledge/op-ref-consumption.md`, §1]. That local caller detail is separate from the vendor's process-delivery contract and does not imply that a Service Account token expires with the subprocess.

## Does not establish

- The opened `op run` and Service Account pages describe process-scoped environment delivery and Service Account token controls separately; neither establishes that the Service Account token itself becomes short-lived or expires when the child process ends [S001, §Use `op run` to pass environment variables from a 1Password Environment; S004, §Token rotation and revocation].
- Credential Broker does not remove every CI-stored key: the GitHub setup still requires an integration key stored as an organization secret [S007]. The announcement identifies it as an encryption key, not a standing vault-access token [S006].
- These pages do not establish behavior for integrations, products, or deployment modes outside the cited CLI, Connect, Service Account, and Broker documentation [S001–S004, S006–S007].

## Falsifier

This entry is falsified if the current CLI documentation no longer scopes provisioned Environment variables to the subprocess duration; if the Service Account documentation changes its vault-scope or token rotation/revocation statements; if the Connect setup no longer separates deployment credentials from application API tokens; or if the Broker pages change public-preview status, claim matching, workflow-duration access, or the GitHub integration-key requirement. Reopen the cited S001–S004 and S006–S007 sections on those changes or at the stated cadence.

## Erratum (round 21, post-landing critic; appended, text above unchanged)

- §Four custody boundaries item 4 omitted eligibility. S006 (introduction and §Try 1Password Credential Broker today) says the public preview is "available for all Enterprise Password Manager Business customers", and S007's guide sets integrations up "in 1Password Business". Read item 4 as scoped to those plans (QA2).
- The critic also reported that S007 marks the custom-OIDC workflow "public beta". Not reproduced: the guide page as fetched 2026-10-19 (`curl -sL`, tags stripped) contains no "public beta" string and labels the guide and its navigation "(public preview)"; the custom-workflow sub-page was not opened separately. The per-workflow release status of the custom-OIDC path is therefore **unverified**; item 4's "public preview" is the guide's own label, not a per-workflow status.

## Erratum (round 22 — feature-specific status and eligibility)

This correction supersedes item 4's unqualified feature status and the
round-21 erratum's unresolved custom-OIDC status, not the preserved historical
bytes. Opened 2026-10-20: S017 (GitHub Actions feature page, title and
introduction), S018 (custom-workflow feature page, title and Steps 1/3), S019
(setup guide, introduction and GitHub requirements), S020 (announcement,
introduction and §New in this release). Their source-registry consumption is
recorded in `corpus/lessons/round-22.md` `source:` and `## Gate`.

- **GitHub Actions — public preview**, not the status of every Broker path
  [S017]. An administrator connects a **1Password Business** account to a
  GitHub.com organization [S019]. Enterprise Server and Enterprise Cloud
  with data residency are unsupported; GitHub Free organizations cannot
  use this integration for private-repository workflows [S019].
- **Custom OIDC workflows — public beta**, not public preview [S018].
  An administrator connects an OIDC provider to the Business account;
  Step 1 requires the latest **beta** desktop app and Step 3 currently
  supports only the **JavaScript SDK** [S018].
- The announcement's eligible population is **Enterprise Password Manager
  Business customers**; its custom-OIDC section explicitly separates beta
  rollout from Actions public preview [S020]. The previous failure to find
  that qualifier did not rebut the outside reviewer: the feature page was
  not opened, and even the announcement has a feature-specific beta section.
- The integration key is still required. Workflow-duration delivery is not
  expiry of a Service Account token, nor removal of all CI-held credentials
  [S019, S020]. No account, workflow, SDK or vault was exercised.

Recheck trigger: reopen the **two feature pages separately**, their setup
eligibility requirements and announcement context on release; a changed
feature status, account prerequisite, supported deployment or SDK support
falsifies this appended reading. A guide title alone cannot settle it.

### Additional source-attribution bounds (round 22)

The new active table is `corpus/knowledge/feature-bound-credential-review.md`;
the older combined-status sentence is preserved history, not the current
admitted reading. Item 3's “different custody boundaries” conclusion is
[INFERENCE]: S003 documents different artifact roles and recommends a new
token per application, not enforced per-application isolation or a named
custody-boundary property. The original fetched-page hashes are historical
point observations without a recorded representation; current raw-page
mismatches do not by themselves prove mechanism drift. Public-beta status
comes from the feature page's own title, not shared navigation labels.

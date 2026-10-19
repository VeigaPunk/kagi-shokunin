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

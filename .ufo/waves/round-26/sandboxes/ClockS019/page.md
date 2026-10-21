> ## Documentation Index
> Fetch the complete documentation index at: https://www.1password.dev/llms.txt
> Use this file to discover all available pages before exploring further.

# Set up 1Password Credential Broker to allow your team to access secrets in their workflows (public preview)

> Learn how to set up a supported integration in 1Password Business, so your team can use 1Password to access secrets in their machine workflows.

Public Preview

With [1Password Credential Broker](https://1password.com/blog/introducing-1password-credential-broker), administrators can set up a supported integration in their 1Password Business account to allow team members to use secrets from their [1Password Environments](/environments) in machine workflows.

[Credential Broker Product Experience Tour](https://www.youtube.com/embed/Mq4ZyUEF8eY)

First, an administrator sets up an integration, which defines a trust policy to control how and where the integration can be used. Team members can then connect Environments to their workflows using the configured integrations.

When a team member runs a workflow, 1Password validates the identity of the workload using an [OIDC token. ](https://openid.net/developers/how-connect-works/). Secrets are only accessible after a workload has been verified, and only remain accessible for the duration of the workflow. Every request for access is recorded in your [audit log](https://support.1password.com/activity-log/).

## Add an integration

Before team members can connect their Environments to machine workflows, an administrator must set up an integration in 1Password Business.

To set up an integration:

1. As an administrator, [sign in](https://start.1password.com/signin) on 1Password.com, then select [**Developer**](https://start.1password.com/developer-tools) in the sidebar.
2. Select the [**Agents & workflows** tab](https://start.1password.com/developer-tools/active/agents-workloads), then select **Set up integrations**.
   > [!TIP]
   >
   > If you've already set up an integration and want to add another, select **Manage integrations** > **Add Integration**.
3. Choose one of the available integrations, then follow the steps for your integration below.

**GitHub Actions**

Before you connect your 1Password Business account to your GitHub organization, review the following requirements:

* Your [GitHub organization ](https://docs.github.com/organizations/collaborating-with-groups-in-organizations/about-organizations) must be hosted on GitHub.com. GitHub organizations hosted on [GitHub Enterprise Server ](https://docs.github.com/enterprise-server@latest/admin/overview/about-github-enterprise-server) or [GitHub Enterprise Cloud with data residency ](https://docs.github.com/enterprise-cloud@latest/admin/data-residency/about-github-enterprise-cloud-with-data-residency) aren't currently supported.
* If you use [GitHub Free for organizations ](https://docs.github.com/get-started/learning-about-github/githubs-plans#github-free-for-organizations), your team won't be able to use this integration for workflows in private repositories.

If your GitHub organization meets the requirements, follow these steps:

1. Enter a name for the integration and the name of the GitHub organization you want to connect, then select **Create integration**.
2. The token value is your integration key, which is required to decrypt secrets in your team's workflows. Save this key in 1Password for future reference, then follow the steps to [add a new secret for your GitHub organization. ](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-development-environment-secrets-for-your-repository-or-organization#adding-secrets-for-an-organization). Set the secret name to `OP_INTEGRATION_KEY` and the value to your integration key.

**Custom Workflow (OIDC)**

1. Enter a name for the integration, then enter your OIDC provider's issuer URL.
2. Select **Verify**. If your JWKS endpoint isn't detected automatically, enter the URL manually, then select **Continue**.
3. Define the identity requirements (claims) that must be met to verify a workload. All configured claims must match to verify the workload's identity. For example, you can use them to restrict secrets to [GitLab CI/CD jobs running in a specific project, branch, environment, etc. ](https://docs.gitlab.com/ci/secrets/id_token_authentication/#token-payload)
4. Make note of the expected audience value. Your team members will need to declare this when their workflows request an OIDC token.
5. The token value is your integration key, which is required to decrypt secrets in your team's workflows. Save this key in 1Password for future reference, then configure the key as a secret that can be retrieved at runtime. For example, you can configure it as a [CI/CD variable in a GitLab group ](https://docs.gitlab.com/ci/variables/#for-a-group), so the team members in that group can retrieve it with its variable name.

After you've set up an integration, your team can start connecting their 1Password Environments to their workflows:

### GitHub Actions

Learn how to configure GitHub Actions workflows to retrieve secrets from 1Password Environments at runtime.

[Learn more](/brokered-access/github-actions/)

### Custom workflow

Learn how to configure custom workflows to retrieve secrets from 1Password Environments at runtime.

[Learn more](/brokered-access/custom-workflow/)

## Delete an integration

If you want to delete an integration so your team members can no longer use it to access secrets in their workflows, follow these steps:

1. As an administrator, [sign in](https://start.1password.com/signin) on 1Password.com, then select [**Developer**](https://start.1password.com/developer-tools) in the sidebar.
2. Select the [**Agents & workflows** tab](https://start.1password.com/developer-tools/active/agents-workloads), then select **Manage integrations**.
3. Select **View All Integrations** under the type of integration you want to delete.
4. Select the vertical ellipsis  for the integration you want to delete, then select **Delete integration**.

After you delete an integration, any of your team member's workflows associated with the integration will no longer run successfully.

## Learn more

* 1Password Blog: [1Password Credential Broker is now in public preview](https://1password.com/blog/1password-credential-broker-public-preview)
* [1Password Environments](/environments)


## Related topics

- [Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)](/brokered-access/github-actions.md)
- [Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)](/brokered-access/custom-workflow.md)
- [Set up your team to use 1Password developer tools](/get-started/secure-developers.md)

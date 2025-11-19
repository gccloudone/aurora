## Implementing Credential-less Authentication

This section details how to configure Argo CD's Repo Server to authenticate with private Git repositories. The approach varies by source control platform:

- **Azure DevOps - Workload Identity Federation (WIF):** Uses OIDC-based identity federation where the Kubernetes Service Account (SA) itself becomes the source of trust. Argo CD authenticates using ephemeral, short-lived credentials derived directly from the Service Account identity.

- **GitHub - GitHub Apps:** Uses a JWT-based mechanism (not OIDC workload identity). Argo CD is configured with a GitHub App's private key, which it uses to request short-lived installation tokens. While not true workload identity federation, it provides similar benefits: a single long-lived secret (the App private key) enables ephemeral token access to multiple repositories.

- **GitLab - Static Credentials Required:** Does not yet support workload identity or app-based authentication for repository access. Requires static credentials (e.g., Deploy Tokens). Best practices include automated rotation, short expiration windows, and optional broker patterns to minimize exposure.

The following sections provide platform-specific implementation guidance.

### A. Azure DevOps (Azure Repos) - Workload Identity Federation (WIF)

Azure DevOps integrates directly with Microsoft Entra ID. By configuring WIF, you allow the Argo CD Service Account to assume an user-assigned managed identity, which then has permissions to read the Git repositories.

1. **Expose OIDC Provider:** Ensure your Kubernetes cluster's OIDC issuer URL is available and configured in Azure AD (if using AKS, this is often automatic).

1. **Create User-Assigned Managed Identity:** Create an Azure user-assigned managed identity that will act as the platform's Git reader identity.

1. **Establish Trust (Federation):** Configure a Federated Credential in the user-assigned managed identity. This credential should trust the Kubernetes OIDC issuer, the Argo CD namespace, and the specific Service Account used by the Argo CD Repo Server (e.g., argocd-repo-server).

1. **Grant Permissions:** Assign the Azure user-assigned managed identity the necessary read permissions (e.g., "Code Read" scope) on the target Azure DevOps Project or Organization.

1. **Label the Pods:** Add the `azure.workload.identity/use: "true"` label to the repo-server pods.

1. **Add Annotation to Service Account:** Add `azure.workload.identity/client-id: "$CLIENT_ID"` annotation to the repo-server service account, using the CLIENT_ID from the workload identity.

1. **Configure Argo CD:** When registering the repository in Argo CD, specify the Git URL and use a mechanism that tells Argo CD to authenticate using the Kubernetes SA identity (e.g., through a lightweight repository secret pointing to the Azure AD metadata).

**For steps 1 and 3:** Retrieve the OIDC issuer URL and create the federated credential:

```bash
# Output the OIDC issuer URL
az aks show --resource-group <resource_group> --name <cluster_name> --query "oidcIssuerProfile.issuerUrl" -otsv

export SERVICE_ACCOUNT_NAMESPACE="..."
export SERVICE_ACCOUNT_NAME="..."
export SERVICE_ACCOUNT_ISSUER="..."

# if you are using a user-assigned managed identity
export USER_ASSIGNED_MANAGED_IDENTITY_NAME="<your user-assigned managed identity name>"
export RESOURCE_GROUP="<your user-assigned managed identity resource group>"

az identity federated-credential create \
  --name "kubernetes-federated-identity" \
  --identity-name "${USER_ASSIGNED_MANAGED_IDENTITY_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --issuer "${SERVICE_ACCOUNT_ISSUER}" \
  --subject "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}"
```

**For step 7:** Create a repository secret in Argo CD with workload identity enabled:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: git-private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://contoso@dev.azure.com/my-projectcollection/my-project/_git/my-repo
  useAzureWorkloadIdentity: "true"
```


### B. GitHub - GitHub App Installation Tokens

GitHub Apps are the most secure and scalable way for Argo CD to read private repositories across multiple user organizations. They provide token-less access, short-lived credentials, and granular permissions.

- **Create a GitHub App (Platform-Owned):** Create a single, centralized GitHub App registered under the platform's GitHub Organization.

- **Configure Permissions:** Set the GitHub App's repository permissions to the absolute minimum required, typically Read-Only access for "Contents".

- **Install App on User Organizations:** Users must install this platform GitHub App on their respective GitHub Organizations/Repositories where the deployment manifests reside. This installation creates a unique Installation ID which Argo CD must use to target the token request to the correct tenant organization.

- **Configure Argo CD:** The Argo CD controller must be configured with the GitHub App's credentials (App ID, Installation ID, and Private Key). Argo CD then acts as the App, using the private key to request a new, short-lived (e.g., 1 hour) Installation Token whenever it needs to sync a client repository.
  - Result: A single, centralized secret (the App Private Key) is managed by the platform, which grants read access to potentially hundreds of decentralized client repositories via ephemeral tokens.

### C. GitLab - Group-Scoped Deploy Token

GitLab does **not** yet offer credential-less repo access. Repository fetch operations require static credentials. Group-scoped Deploy Tokens provide the most secure option, as they are limited to Git/registry operations and cannot access the GitLab REST/GraphQL APIs.

- **Create Group Deploy Token:** In the GitLab group settings, navigate to Settings → Repository → Deploy tokens. Create a new deploy token with:
  - Name: e.g., `argocd-repo-reader`
  - Scopes: Select `read_repository` (and optionally `read_registry` if accessing container registries)
  - Expiration date: Set a reasonable expiration window
  - Save the generated username and token immediately (they cannot be retrieved later)

- **Store Credentials in Kubernetes Secret:** Create a Secret in the Argo CD namespace with the deploy token credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-group-deploy-token
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://gitlab.com/group-name/repo-name.git
  password: <deploy-token-value>
  username: <deploy-token-username>
```

- **Configure Argo CD:** Register the repository in Argo CD using the secret. Argo CD will use the deploy token credentials for all Git operations on repositories within the group scope.

> Note: Because deploy tokens are static credentials, implement automated rotation using the GitLab API before expiration. Monitor GitLab's roadmap for native workload identity support for repository access.
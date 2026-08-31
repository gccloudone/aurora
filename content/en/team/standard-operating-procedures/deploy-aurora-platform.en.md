---
title: "Deploy the Aurora Platform"
linkTitle: "Deploy the Aurora Platform"
weight: 5
aliases: ["/team/sop/deploy-aurora-platform"]
date: 2026-08-20
draft: false
showToc: true
---

{{< translation-note >}}

## Objective

Deploy the Aurora Platform onto an AKS cluster provisioned through the <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-kubernetes-cluster/" >}}">cluster creation process</gcds-link>.

![Aurora Platform](/images/architecture/diagrams/aurora-platform.png)

This SOP covers both cluster types:

- **Management cluster**: The first cluster stood up in an environment. It stands up its own Argo CD and manages both itself and any workload clusters onboarded later.
- **Workload cluster**: Onboarded into an existing management cluster's Argo CD (see Onboard a Workload Cluster).

This SOP is written to be followed end to end without prior knowledge of the Aurora platform. Where a step depends on another team (identity, networking, DNS), that dependency is called out so it can be requested before it becomes a blocker.

## Where this SOP fits

This is the second half of the two-part onboarding sequence:

1. Deploy a PBMM-compliant AKS cluster (cluster creation process).
2. **Deploy the Aurora Platform on top of that cluster (this SOP).**

**Prerequisite:** The Aurora Platform only works with Aurora's IaC and an Aurora-provisioned cluster. Do not attempt to bootstrap it onto a cluster provisioned by other means.

### Same platform, one key difference

Management and workload clusters run the same Aurora Platform, deployed as a Helm chart through Argo CD. The only difference is the chart's `mgmt` component:

- It is disabled by default.
- A management cluster's `config.yaml` enables it, adding the tooling the cluster needs to manage itself and onboard workload clusters.

### How each cluster type is deployed

- **Management cluster**: Because it is the first cluster, there is no existing Argo CD to deploy onto. The [bootstrap-terraform](https://github.com/gccloudone-aurora/bootstrap-terraform) repository installs Argo CD directly and creates the `aurora-platform` ApplicationSet, which syncs the platform chart from the cluster's configuration repository.
- **Workload cluster**: Keeps `mgmt` disabled and is onboarded into an existing management cluster's Argo CD rather than being bootstrapped (see Onboard a Workload Cluster below).

## Context

The AKS cluster deployed via the cluster creation process is a hardened, PBMM-compliant platform authorized under the hosting tenant's assessment: a private cluster with a Cilium dataplane, Azure Linux nodes, isolated node pools, private connectivity to Azure services, and multi-zone high availability. See that guide for the full configuration.

The Aurora Platform builds on that foundation with a curated set of hardened CNCF solutions managed through Argo CD, covering observability, runtime security, certificate management, and continuous delivery.

Deploying it is strongly recommended. Teams get a complete, ready-to-use DevOps platform rather than having to source, integrate, and harden this tooling themselves, work that is time-consuming, easy to get wrong, and duplicated across every team that attempts it. Because the platform inherits the underlying cluster's PBMM compliance and is maintained centrally, teams also benefit from a consistent security posture, a managed update cadence, and shared governance, letting them focus on their workloads instead of undifferentiated platform engineering.

## Prerequisites

Ensure the following are in place before you begin:

- An AKS cluster deployed through the cluster creation process.
- Access to a jumpbox or workstation with network access to the cluster's API server.
- The following CLI tools installed and available: Azure CLI, `kubelogin`, `kubectl`, Terraform, and Git.
- An identity with the following roles scoped to the AKS cluster:
  - Azure Kubernetes Service Cluster User Role
  - Azure Kubernetes Service RBAC Cluster Admin
- Access to the [bootstrap-terraform](https://github.com/gccloudone-aurora/bootstrap-terraform) repository.

For a **workload cluster**, the following also apply:

- A management cluster that already exists and is running Argo CD.
- A firewall path that allows traffic from the management cluster to the workload cluster.
- A Linux or WSL environment with bash (only `kubectl` and Git are required).
- Any previous kubeconfig context cleared or unset, to avoid conflicts.
- Access to the management cluster's Argo CD.

### RBAC and Identity Prerequisites

The general RBAC and identity prerequisites, including elevated Entra ID visibility via PIM, are covered in the <gcds-link href="{{< relref "/team/standard-operating-procedures/onboarding-background/" >}}">Onboarding Background</gcds-link>.

Several steps in this SOP require that visibility to see the relevant groups and service principals in Entra ID:

- Verifying role assignments (Step 2)
- Populating the Argo CD Key Vault secrets (Step 9)
- Requesting the OIDC service principal (Step 10)

**Until that PIM access is in place, expect significant back-and-forth with the identity team for each RBAC assignment.**

## Bootstrap the Management Cluster

These steps bootstrap the management cluster: authenticate to the cluster, deploy Argo CD via `bootstrap-terraform`, supply the secrets that cannot be automated, and set up DNS and certificate access. Argo CD then reconciles the platform from the cluster's configuration repository until it converges.

### 1. Authenticate to the AKS Cluster

Authenticate to Azure and retrieve the cluster credentials. For a private cluster, run this from a host with network access to the API server (for example a jumpbox or Azure Virtual Desktop).

```sh
az login
az account set --subscription <SUBSCRIPTION_ID>
az aks get-credentials \
  --name <CLUSTER_NAME> \
  --resource-group <CLUSTER_RG> \
  --overwrite-existing
kubelogin convert-kubeconfig -l azurecli
```

### 2. Verify Cluster Access and Role Assignments

Confirm the identity you authenticated as has the required roles on the AKS cluster, and that you can reach the cluster before deploying anything.

Get the AKS cluster resource ID:

```sh
az aks show \
  --name <CLUSTER_NAME> \
  --resource-group <CLUSTER_RG> \
  --query "id" -o tsv
```

List role assignments against the cluster scope:

```sh
az role assignment list \
  --assignee <IDENTITY_OBJECT_ID> \
  --scope <AKS_CLUSTER_RESOURCE_ID>
```

Ensure the output includes:

- `Azure Kubernetes Service Cluster User Role`
- `Azure Kubernetes Service RBAC Cluster Admin`

Then confirm connectivity and RBAC end to end:

```sh
kubectl get nodes
```

If the nodes are listed, authentication and RBAC are working correctly. If either the role check or `kubectl get nodes` fails, resolve the missing role assignments before proceeding.

### 3. Clone the Bootstrap Terraform Repository

This repository installs Argo CD into the cluster and creates the `aurora-platform` ApplicationSet, which syncs the Aurora Platform Helm chart from the cluster's configuration repository. With the `mgmt` component enabled in that configuration, the platform includes the tooling to manage this cluster and onboard workload clusters.

```sh
git clone https://github.com/gccloudone-aurora/bootstrap-terraform
cd bootstrap-terraform
```

### 4. Prepare the Project Configuration Repository

The Aurora Platform is driven by a per-cluster configuration repository that Argo CD syncs from. Prepare this repository before continuing.

Clone the Aurora project template:

```sh
git clone https://github.com/gccloudone-aurora/project-aurora-template.git
```

Each cluster has its own `config.yaml`, located under one of the following paths:

```text
platform/clusters/non-prod/<cluster-name>/config.yaml
platform/clusters/prod/<cluster-name>/config.yaml
```

Edit the `config.yaml` for your target cluster, filling in all the `<FILLIN_XYZ>` placeholder fields to match your environment. This file tells Argo CD what to deploy and how to manage the cluster, making it the central configuration for the Aurora Platform. In most environments you will need to update:

- App-of-apps configuration: which components are deployed and how they sync.
- Networking and identity: API server CIDRs, ingress domain, subscription and tenant IDs, and Key Vault references.
- Core components: toggles for services such as Cilium, cert-manager, and the CIDR allocator.

Commit and push your changes to a new repository, following a naming convention such as `project-example`, where `example` is the name of the project or department.

### 5. Configure Terraform Variables

Set the cluster-specific values in `terraform.tfvars`, starting from the example in the repository. At minimum this includes the target subscription and tenant IDs, the cluster name and resource group, the ingress domain and API server CIDR, and the Key Vault references the platform reads its secrets from. See `variables.tf` and the example `terraform.tfvars` in `bootstrap-terraform` for the complete, current list.

```sh
# Edit terraform.tfvars with the correct cluster-specific values
vi terraform.tfvars
```

### 6. Initialize Terraform

Initialize the working directory to download the required providers and modules:

```sh
terraform init
```

### 7. Deploy Argo CD Operator

Apply the Argo CD operator Helm chart first, since the Argo CD instance in the next step depends on it:

```sh
terraform apply -target=helm_release.argo_operator
```

### 8. Deploy Argo CD Instance

Apply the Argo CD instance Helm chart:

```sh
terraform apply -target=helm_release.argocd_instance
```

### 9. Populate Required Key Vault Secrets

Some secrets cannot be inferred or automated because of the specific access the department needs to control. These must be entered manually into the Argo CD Key Vault before the platform can sync successfully. Substitute your environment's Key Vault prefixes (`<ARGO_KV_PREFIX>` and `<PLATFORM_KV_PREFIX>`):

- `<ARGO_KV_PREFIX>-github-username`: GitHub username used by Argo CD to access the source repositories
- `<ARGO_KV_PREFIX>-github-password`: corresponding GitHub password or personal access token
- `<ARGO_KV_PREFIX>-cluster-admins`: the set of cluster administrators
- `<PLATFORM_KV_PREFIX>-argocd-oidc-sp-client-id`: client ID of the Argo CD OIDC service principal
- `<PLATFORM_KV_PREFIX>-argocd-oidc-sp-client-secret`: client secret of the Argo CD OIDC service principal

The two `<PLATFORM_KV_PREFIX>-argocd-oidc-sp-*` values are produced in Step 10; enter them once you have them.

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>The Key Vault prefixes (`<ARGO_KV_PREFIX>`, `<PLATFORM_KV_PREFIX>`) change per environment. The secret suffixes (for example `-github-username`) are constant across environments.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

### 10. Argo CD OIDC Service Principal

The OIDC service principal is normally created automatically by our Terraform, but that automation had to be disabled due to departmental policies on service principal creation and the permissions involved. As a result, the service principal must be requested manually via a support ticket. The request should ask to:

- Duplicate an existing Argo CD service principal into a new environment-specific one.
- Match the exact same permissions, groups claim (ID, Access, and SAML token types), and admin consent as the source service principal.
- Update the redirect URIs to the ingress hostnames for the new environment, under your DNS zone, for example `https://<host>.<env>.<dns-zone>/auth/callback`.
- Return the resulting `client-id` and `client-secret`.

Once received, store these values in the `<PLATFORM_KV_PREFIX>-kvs-argocd-oidc-sp-client-id` and `<PLATFORM_KV_PREFIX>-kvs-argocd-oidc-sp-client-secret` Key Vault secrets from the previous step.

### 11. Grant Argo CD Access to the Configuration Repository

Argo CD must be able to pull manifests from the configuration repository you prepared in Step 4. Once the Argo CD instance is running and the Key Vault secrets are in place:

- Confirm the repository specification points Argo CD at the correct Aurora configuration repository.
- Ensure authentication is provided through the `aurora-svc` service account, using the GitHub personal access token (PAT) stored in the `<ARGO_KV_PREFIX>-github-password` secret from Step 9. The token must have access to the repository.
- Approve the `gccloudone-aurora` request under pending repository access requests in your GitHub organization, so Argo CD can pull manifests.

### 12. Deploy Remaining Aurora Platform Components

Apply all remaining Terraform resources, which includes the `aurora-platform` ApplicationSet that deploys the full Aurora Platform:

```sh
terraform apply
```

Argo CD reconciles the ApplicationSet asynchronously, so the platform takes some time to converge after the apply completes. Watch progress in the Argo CD UI (next step).

### 13. Access Argo CD UI (Optional)

If no ingress has been configured yet, you can port-forward the Argo CD service to access the UI locally.

Port-forward the Argo CD server:

```sh
kubectl port-forward svc/argocd-server -n platform-management-system 8080:80
```

Retrieve the temporary admin password:

```sh
kubectl get secret argocd-cluster -n platform-management-system -o go-template='{{index .data "admin.password" | base64decode}}'; echo
```

Access Argo CD in your browser:

```sh
https://localhost:8080
```

Login with:

- **Username:** `admin`
- **Password:** the output from the secret retrieval above

### 14. Verify the Deployment

Confirm the platform has deployed successfully before considering the process complete. In the Argo CD UI (or with the Argo CD CLI), check that all applications and the `aurora-platform` ApplicationSet report a status of `Synced` and `Healthy`:

```sh
kubectl get applications -n platform-management-system
```

If any application is stuck in `OutOfSync`, `Degraded`, or `Missing`, inspect it in the Argo CD UI for the underlying error. A common cause is a missing or misnamed Key Vault secret from Step 9.

### 15. Add a DNS A Record for the Cluster

Each cluster's Istio ingress gateway provisions its own external load balancer. To route traffic to it (platform services by hostname), add a wildcard A record in the DNS zone (`<DNS_ZONE>`) pointing at that load balancer's IP.

You can find the external IP of the Istio ingress gateway load balancer, exposed by the service in the `ingress-general-system` namespace:

```sh
kubectl get svc -n ingress-general-system
```

Then, in the public DNS zone for your cluster, create a wildcard A record that points at that address:

```txt
*.<env> => <ingress-lb-ip> (Istio Ingress Gateway External LB)
```

Repeat this step whenever a new cluster is added, using that cluster's external LB IP. Once the record has propagated, platform services are reachable at their configured hostnames.

### 16. Grant cert-manager's MSI Access to the DNS Zone

For cert-manager to solve DNS-01 challenges, it must read and manage the `_acme-challenge` TXT records in the DNS zone. Without the correct role, certificate issuance fails with an authorization error similar to:

```txt
{
  "error": {
    "code": "AuthorizationFailed",
    "message": "The client '...' with object id '...' does not have authorization to perform action 'Microsoft.Network/dnsZones/TXT/read' over scope '/subscriptions/.../resourceGroups/<dns-rg>/providers/Microsoft.Network/dnsZones/<DNS_ZONE>/TXT/_acme-challenge.<host>.<env>' or the scope is invalid. If access was recently granted, please refresh your credentials."
  }
}
```

To resolve this, the cert-manager managed identity requires the **DNS Zone Contributor** role. Raise a ticket to assign the cert-manager MSI (for example, `aks-msi-cert-manager`).

- **Role:** DNS Zone Contributor
- **Scope:** the DNS zone (`<DNS_ZONE>`)

## Onboard a Workload Cluster

A workload cluster does not run its own Argo CD; an existing management cluster's Argo CD deploys and reconciles the platform onto it. This track reuses several management-track steps above and references them by number rather than repeating them.

Prerequisites specific to a workload cluster:

- A management cluster that already exists and is running Argo CD.
- A firewall path that allows traffic from the management cluster to the workload cluster.
- `kubectl` and Git, with any previous kubeconfig context cleared to avoid conflicts.

### W1. Prepare the Project Configuration Repository

Follow Step 4 (Prepare the Project Configuration Repository) above, for the workload cluster's `config.yaml`.

### W2. Register the Cluster in the Management Cluster's Argo CD

The management cluster's Argo CD must be updated so it can track the workload cluster and the repository prepared in W1. Edit the management cluster's `config.yaml` to add:

- The workload cluster's API server address, token, and `caData`.
- The workload cluster's Git repository URL and the credentials for accessing it.

See this [example configuration change](https://github.com/gccloudone-aurora/project-aurora-mgmt/pull/113/changes). (Private)

### W3. Populate Required Key Vault Secrets

Follow Step 9 (Populate Required Key Vault Secrets) above for the workload cluster's Argo CD Key Vault. The `argocd-oidc-sp` values are those already established for the management cluster's Argo CD; a workload cluster does not create its own OIDC service principal.

### W4. Grant Argo CD Access to the Configuration Repository

Follow Step 11 (Grant Argo CD Access to the Configuration Repository) above, for the workload cluster's configuration repository.

### W5. Grant the Management Cluster Access to the Workload Key Vault

The management cluster's Argo CD service principal must read secrets from the workload cluster's Key Vault. In the Azure portal, open the workload cluster's Key Vault and add an access policy granting all secret permissions to the management cluster's Argo CD service principal (`<MGMT_CLUSTER_NAME>-ARGO-msi-argocd`).

### W6. Sync the Argo CD Applications

In the management cluster's Argo CD portal, sync the following applications in order:

1. `platform-<MGMT_CLUSTER_NAME>`
2. `<MGMT_CLUSTER_NAME>-argo-foundation-platform-project`
3. `<MGMT_CLUSTER_NAME>-argo-foundation-argocd-instance`

Once these are synced, the platform application for the new workload cluster appears. Sync it, then sync the newly created applications for the cluster. You may need to run the sync more than once:

- If a sync fails accessing Key Vault secrets, perform a hard refresh and retry, and confirm the access policy from W5.
- If a sync fails because a CRD does not yet exist, skip that resource and return to it once the Kubernetes job installing the CRD completes.

Confirm all applications for the workload cluster report `Synced` and `Healthy` before considering the process complete.

### W7. Add a DNS A Record for the Cluster

Follow Step 15 (Add a DNS A Record for the Cluster) above, using the workload cluster's Istio ingress gateway external LB IP and its `*.<env>` wildcard record.

### W8. Grant cert-manager's MSI Access to the DNS Zone

As with a management cluster, the workload cluster's cert-manager managed identity requires the **DNS Zone Contributor** role to solve DNS-01 challenges. Follow Step 16 (Grant cert-manager's MSI Access to the DNS Zone) above, assigning the role to the workload cluster's cert-manager MSI, scoped to the DNS zone.

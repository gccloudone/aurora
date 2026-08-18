---
title: "Bootstrap the Management Cluster"
linkTitle: "Bootstrap the Management Cluster"
weight: 5
aliases: ["/team/sop/management-cluster", "/team/sop/bootstrap-cluster", "/team/standard-operating-procedures/bootstrap-cluster"]
date: 2026-08-11
draft: false
---

{{< translation-note >}}

This document outlines the process for bootstrapping the Aurora Platform onto a **management cluster**, the first cluster that stands up its own Argo CD and, from there, manages both itself and any workload clusters onboarded later. By the end of this procedure, the cluster will be running the full Aurora Platform and ready to onboard workload clusters.

## Context

The management cluster is a hardened, PBMM-compliant AKS cluster. The Aurora Platform builds on that foundation with a curated set of hardened CNCF solutions managed through Argo CD, covering observability, runtime security, certificate management, and continuous delivery.

Deploying it is strongly recommended: it gives teams a complete DevOps platform instead of having to assemble and harden this tooling on their own.

Both management and workload clusters run the same Aurora Platform, deployed as a Helm chart through Argo CD. The difference is the chart's `mgmt` component: it is disabled by default, but a management cluster's `config.yaml` enables it, adding the tooling the cluster needs to manage itself and onboard workload clusters.

A management cluster is the first cluster stood up, so there is no existing Argo CD to deploy onto it. The [bootstrap-terraform](https://github.com/gccloudone-aurora/bootstrap-terraform) repository fills that gap: it installs Argo CD directly onto the cluster and creates the `aurora-platform` ApplicationSet, which syncs the platform chart from the cluster's configuration repository. A [workload cluster](../workload-cluster/), by contrast, keeps `mgmt` disabled and is onboarded into an existing management cluster's Argo CD instead of being bootstrapped.

Previously, bootstrapping relied on a temporary local k3s cluster to work around the lack of networking on a freshly provisioned cluster. That workaround is no longer necessary: networking is now available on newly deployed clusters, so the platform is deployed directly onto the target cluster.

## Prerequisites

Ensure the following are in place before you begin:

- An AKS cluster deployed through the cluster creation process.
- Access to a jumpbox or workstation with network access to the cluster's API server.
- The following CLI tools installed and available: Azure CLI, `kubelogin`, `kubectl`, Terraform, and Git.
- An identity with the following roles scoped to the AKS cluster:
  - Azure Kubernetes Service Cluster User Role
  - Azure Kubernetes Service RBAC Cluster Admin
- Access to the [bootstrap-terraform](https://github.com/gccloudone-aurora/bootstrap-terraform) repository.

## Steps

### 1. Authenticate to the AKS cluster

Set the target subscription:

```sh
az account set --subscription <SUBSCRIPTION_ID>
```

Retrieve the AKS cluster credentials and merge them into your kubeconfig:

```sh
az aks get-credentials \
  --name <CLUSTER_NAME> \
  --resource-group <CLUSTER_RG> \
  --overwrite-existing
```

Convert the kubeconfig so that kubectl authenticates through Azure AD:

```sh
kubelogin convert-kubeconfig -l azurecli
```

### 2. Verify cluster access

Confirm that you can reach the cluster and that your identity is authorized before deploying anything:

```sh
kubectl get nodes
```

If the nodes are listed, authentication and RBAC are working correctly. If the command is rejected, resolve the missing role assignments before continuing.

### 3. Clone the bootstrap Terraform repository

This repository installs Argo CD directly onto the cluster and creates the `aurora-platform` ApplicationSet, which syncs the Aurora Platform Helm chart from the cluster's configuration repository. With the `mgmt` component enabled in that configuration, the platform includes the tooling to manage this cluster and onboard workload clusters.

```sh
git clone https://github.com/gccloudone-aurora/bootstrap-terraform
cd bootstrap-terraform
```

### 4. Prepare the project configuration repository

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

Edit the `config.yaml` for your target cluster, filling in all the `<FILLIN_XYZ>` placeholder fields, to match your environment. This file tells Argo CD what to deploy and how to manage the cluster, making it the central configuration for the Aurora Platform. In most environments you will need to update:

- App-of-apps configuration: which components are deployed and how they sync.
- Networking and identity: API server CIDRs, ingress domain, subscription and tenant IDs, and Key Vault references.
- Core components: toggles for services such as Cilium, Cert Manager, and the CIDR allocator.

Commit and push your changes to a new repository, following a naming convention such as `project-example`, where example is the name of the project or department.

### 5. Configure the Terraform variables

Update the `terraform.tfvars` file with the values for your target cluster and environment. These values tell Terraform and Argo CD which cluster to target and how to configure the platform.

```sh
# Edit terraform.tfvars with the correct cluster-specific values
vi terraform.tfvars
```

### 6. Initialize Terraform

Initialize the working directory to download the required providers and modules:

```sh
terraform init
```

### 7. Deploy the Argo CD operator

Apply the Argo CD operator Helm chart first, since the Argo CD instance in the next step depends on it:

```sh
terraform apply -target=helm_release.argo_operator
```

### 8. Deploy the Argo CD instance

Apply the Argo CD instance Helm chart:

```sh
terraform apply -target=helm_release.argocd_instance
```

### 9. Populate the required Key Vault secrets

Some secrets cannot be inferred or automated, so they must be entered manually into the Argo CD Key Vault before syncing the platform components, otherwise the applications will fail to sync when they look for these values:

- `<prefix>-argo-kvs-github-username`: GitHub username that Argo CD uses to access the source repositories.
- `<prefix>-argo-kvs-github-password`: corresponding GitHub password or personal access token.
- `<prefix>-argo-kvs-cluster-admins`: the set of cluster administrators.
- `<prefix>-platform-kvs-argocd-oidc-sp-client-id`: client ID of the Argo CD OIDC service principal.
- `<prefix>-platform-kvs-argocd-oidc-sp-client-secret`: client secret of the Argo CD OIDC service principal.

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>The prefix on these secret names changes per environment. Adjust the names to match your target Key Vault's naming convention. This step is required until these values are provisioned automatically as part of Enterprise Landing Zone (ESLZ) onboarding.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

### 10. Grant Argo CD access to the configuration repository

Argo CD must be able to pull manifests from the configuration repository you prepared earlier. Once the Argo CD instance is running and the Key Vault secrets are in place:

- Confirm the repository specification points Argo CD at the correct Aurora configuration repository.
- Ensure authentication is provided through the `aurora-svc` service account, using the GitHub personal access token (PAT) from the Key Vault secrets in the previous step. The token must have access to the repository.
- Approve the `gccloudone-aurora` request under pending repository access requests in your GitHub organization, so Argo CD can pull manifests.

### 11. Deploy the remaining Aurora Platform components

Apply the rest of the Terraform configuration. This creates the ApplicationSets that deploy the full Aurora Platform through Argo CD:

```sh
terraform apply
```

Argo CD reconciles the ApplicationSets asynchronously, so the platform will take some time to converge after the apply completes. You can watch the progress in the Argo CD UI (see the next step).

### 12. Access the Argo CD UI (optional)

If no ingress has been configured yet, you can port-forward the Argo CD service to reach the UI from your workstation.

Port-forward the Argo CD server:

```sh
kubectl port-forward svc/argocd-server -n platform-management-system 8080:80
```

Retrieve the temporary admin password:

```sh
kubectl get secret argocd-cluster -n platform-management-system -o go-template='{{index .data "admin.password" | base64decode}}'; echo
```

Open `https://localhost:8080` in your browser and log in with the username `admin` and the password returned by the command above.

### 13. Verify the deployment

Confirm that the platform has deployed successfully before considering the process complete. In the Argo CD UI (or with the Argo CD CLI), check that all applications and ApplicationSets report a status of `Synced` and `Healthy`:

```sh
kubectl get applications -n platform-management-system
```

If any application is stuck in `OutOfSync`, `Degraded`, or `Missing`, inspect it in the Argo CD UI for the underlying error. A common cause is a missing or misnamed Key Vault secret from step 9.

### 14. Add a DNS A record

Once the platform is deployed, its ingress controller provisions an external load balancer. To reach platform services by hostname, point a wildcard DNS record at that load balancer in the public DNS zone created during Enterprise Landing Zone onboarding.

First, find the external IP address of the ingress load balancer, which is exposed by the service in the `ingress-general-system` namespace:

```sh
kubectl get svc -n ingress-general-system
```

Then, in the public DNS zone for your cluster, create a wildcard A record that points at that address:

- `*.aurora`: points to the external IP of the ingress load balancer.

Once the record has propagated, platform services are reachable at their configured hostnames.

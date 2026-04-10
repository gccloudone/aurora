---
title: "Workload Cluster Onboarding"
linkTitle: "Workload Cluster Onboarding"
weight: 5
aliases: ["/team/sop/workload-cluster-onboarding"]
date: 2026-04-09
draft: false
---

{{< translation-note >}}

This guide covers deploying the aurora-platform-charts onto the workload cluster from a management cluster through Argo CD. 


## Scope & Assumptions

This guide is written with the following context in mind:

- A management cluster exists 
- Firewall is not blocking flow from Management → Workload cluster. 

## Prerequisites

The following must be in place before you begin the onboarding steps:

- A Linux / WSL environment with bash
- Required CLI tools installed and accessible: **kubectl**, and **git**
- Any previous kubeconfig context cleared or unset (to avoid conflicts)

> If any of these prerequisites are missing, resolve them before proceeding with the bootstrap steps.

## 1. Update Your Project-Level Configuration

Start by cloning the Aurora project template:

```bash
git clone https://github.com/gccloudone-aurora/project-aurora-template.git
```

Each cluster will have its own `config.yaml` located under:

```sh
platform/clusters/non-prod/<cluster-name>/config.yaml
platform/clusters/prod/<cluster-name>/config.yaml
```

Edit the `config.yaml`, **filling in all the <FILLIN_XYZ> fields** for your target cluster to match your environment. This file tells Argo CD what to deploy and how to manage the cluster, making it the central configuration for the Aurora platform.

In most environments, you will need to update:

- **App-of-apps configuration** – adjust which components are deployed and how they sync
- **Networking and identity** – API server CIDRs, ingress domain, subscription/tenant IDs, Key Vault references
- **Core components** – toggle services like Cilium, cert-manager, and CIDR allocator

Finally, commit and push your changes to a repository. We typically use a naming convention such as project-example-aur, and for client workloads we always suffix the repository name with the -aur shortcode.

## 2. Update Argo CD Configuration

At this stage, Argo CD in the management cluster must be updated so it can track the repository you prepared in the previous step.

- **Register the new cluster & repository within the management cluster** by editing the management cluster's `config.yaml`. It is necessary to add the cluster's API server address, token, caData, the cluster's git repository URL, and the credentials for accessing the git repository. See [example](https://github.com/gccloudone-aurora/project-aurora-mgmt/pull/113/changes).
- **Grant authentication** by switching to the `aurora-svc` service account and providing a GitHub Personal Access Token (PAT) with access to the repo. This allows Argo CD to pull manifests.
- **Approve access** by approving the `gccloudone-aurora` request under pending repository access requests in your GitHub organization.

## 3. Add Key Vault Secrets

At this stage, you must manually add the following secrets into Azure Key Vault so that Argo CD can fully authenticate with its resources and manage the Aurora platform:

- `xxxx-xxxxx-argo-kvs-github-password`
- `xxxx-xxxxx-argo-kvs-github-username`

> TODO: This step is required until these values are provisioned automatically as part of the Enterprise Landing Zone (ESLZ) onboarding.

## 4. Add DNS A Record

Navigate to the public DNS zone for your cluster created in the Azure Enterprise Landing Zone (ESLZ) onboarding.

- `*.aurora`: public DNS zone pointing to the load balancer

The load balancer is exposed by the service in the `ingress-general-system` namespace.

## 5. Create access policy within workload cluster's ArgoCD Keyvault 

Navigate to the workload cluster's key vault in the Azure portal. Create a new access policy with all secret permissions scoped to the management cluster's argocd service principal `<management-cluster-name>-ARGO-msi-argocd`.

## 6. Sync ArgoCD applications

Navigate to the management cluster's Argo CD portal. 

Sync the management cluster's `platform-<magenement-cluster-name>` application, then the `<management-cluster-name>-argo-foundation-platform-project` application and also the `<management-cluster-name>-argo-foundation-argocd-instance`. You should see the platform application created for the new cluster which you can sync. 

If there are any errors related to accessing the secrets in the keyvault, perform a hard refresh and try again. Ensure that the management cluster's ArgoCD service principal has access to the workload cluster's KV. 

Next, begin syncing the newly created applications. You may need to perform the sync operation multiple times. If there is an error due to a CRD not existing, skip that resource and come back to it later once the Kubernetes job installing that CRD is completed. 

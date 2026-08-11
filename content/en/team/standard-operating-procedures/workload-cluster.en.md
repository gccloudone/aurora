---
title: "Deploy a Workload Cluster"
linkTitle: "Deploy a Workload Cluster"
weight: 5
aliases: ["/team/sop/workload-cluster-onboarding", "/team/standard-operating-procedures/workload-cluster-onboarding"]
date: 2026-08-11
draft: false
---

{{< translation-note >}}

This document outlines the process for onboarding a **workload cluster**, deploying the Aurora Platform onto it from an existing management cluster through Argo CD.

## Context

A workload cluster runs the Aurora Platform but not its own Argo CD. Instead, it is registered into an existing [management cluster](../management-cluster/), whose Argo CD deploys and reconciles the platform onto it.

This is the key difference between the two cluster types. Both run the same Aurora Platform, but the chart's `mgmt` component (the tooling that lets a cluster manage itself and onboard others) is enabled only on a management cluster and stays disabled by default on a workload cluster.

This procedure assumes the following are already in place:

- A management cluster exists and is running Argo CD.
- The firewall is not blocking traffic from the management cluster to the workload cluster.

## Prerequisites

Ensure the following are in place before you begin:

- A workload cluster deployed through the cluster creation process.
- A Linux or WSL environment with bash.
- The following CLI tools installed and available: `kubectl` and Git.
- Any previous kubeconfig context cleared or unset, to avoid conflicts.
- Access to the [project-aurora-template](https://github.com/gccloudone-aurora/project-aurora-template) repository and the management cluster's Argo CD.

## Steps

### 1. Prepare the project configuration repository

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
- Core components: toggles for services such as Cilium, cert-manager, and the CIDR allocator.

Commit and push your changes to a new repository, following a naming convention such as `project-example`, where example is the name of the project or department.

### 2. Register the cluster in the management cluster's Argo CD

The management cluster's Argo CD must be updated so it can track the cluster and repository you prepared in the previous step. Edit the management cluster's `config.yaml` to add:

- The workload cluster's API server address, token, and caData.
- The workload cluster's Git repository URL and the credentials for accessing it.

See this [example configuration change](https://github.com/gccloudone-aurora/project-aurora-mgmt/pull/113/changes).

### 3. Populate the required Key Vault secrets

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

### 4. Grant Argo CD access to the configuration repository

Argo CD must be able to pull manifests from the configuration repository you prepared earlier. Once the cluster is registered and the Key Vault secrets are in place:

- Confirm the repository specification points Argo CD at the correct Aurora configuration repository.
- Ensure authentication is provided through the `aurora-svc` service account, using the GitHub personal access token (PAT) from the Key Vault secrets in the previous step. The token must have access to the repository.
- Approve the `gccloudone-aurora` request under pending repository access requests in your GitHub organization, so Argo CD can pull manifests.

### 5. Grant the management cluster access to the workload Key Vault

The management cluster's Argo CD service principal needs to read secrets from the workload cluster's Key Vault. In the Azure portal, navigate to the workload cluster's Key Vault and create a new access policy granting all secret permissions to the management cluster's Argo CD service principal, `<management-cluster-name>-ARGO-msi-argocd`.

### 6. Sync the Argo CD applications

In the management cluster's Argo CD portal, sync the following applications in order:

1. `platform-<management-cluster-name>`
2. `<management-cluster-name>-argo-foundation-platform-project`
3. `<management-cluster-name>-argo-foundation-argocd-instance`

Once these are synced, the platform application for the new workload cluster appears. Sync it, then sync the newly created applications for the cluster.

You may need to run the sync operation more than once:

- If a sync fails with an error accessing Key Vault secrets, perform a hard refresh and try again, and confirm the management cluster's Argo CD service principal has access to the workload cluster's Key Vault (step 5).
- If a sync fails because a CRD does not yet exist, skip that resource and return to it once the Kubernetes job installing the CRD has completed.

Before considering the process complete, confirm in the management cluster's Argo CD that all applications for the workload cluster report a status of `Synced` and `Healthy`.

### 7. Add a DNS A record

Once the platform is deployed, its ingress controller provisions an external load balancer. To reach platform services by hostname, point a wildcard DNS record at that load balancer in the public DNS zone created during Enterprise Landing Zone onboarding.

First, find the external IP address of the ingress load balancer, which is exposed by the service in the `ingress-general-system` namespace:

```sh
kubectl get svc -n ingress-general-system
```

Then, in the public DNS zone for your cluster, create a wildcard A record that points at that address:

- `*.aurora`: points to the external IP of the ingress load balancer.

Once the record has propagated, platform services are reachable at their configured hostnames.

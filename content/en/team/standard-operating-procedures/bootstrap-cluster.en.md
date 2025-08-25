---
title: "Bootstrap Cluster"
linkTitle: "Bootstrap Cluster"
weight: 5
aliases: ["/team/sop/bootstrap-cluster"]
date: 2025-08-19
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This guide covers creating a local k3s bootstrap cluster (also tested in Windows Subsystem for Linux / WSL), installing Argo CD, and transferring control to a remote Kubernetes cluster (the “target” cluster).

The bootstrap cluster solves the classic chicken-and-egg problem by allowing Argo CD to install baseline components (e.g., Cilium, namespaces, secrets, policies) on a cluster that initially lacks them.

> Once the target cluster is ready, Argo CD can deploy itself into that cluster and the bootstrap cluster can be discarded. The target cluster typically becomes the long-term management cluster, meaning bootstrapping is usually a one-time process.

## Scope & Assumptions

This guide is written with the following context in mind:

- The Aurora platform, configured via Argo CD, is first deployed into a temporary local k3s bootstrap cluster and then migrated to the target managed Kubernetes cluster
- The target cluster starts without a CNI (e.g., Cilium); the bootstrap process installs networking and other baseline components
- Sensitive values (credentials, tokens, etc.) are retrieved from Azure Key Vault through a Managed Service Identity (MSI)
- Argo CD and its supporting resources run in the namespace platform-management-system

This guide does not cover provisioning of landing zones, subscription-level configuration, or Argo CD operations

## Prerequisites

The following must be in place before you begin the onboarding steps:

- A **Linux / WSL** environment with `bash` available
- Required CLI tools installed and accessible: **kubectl**, **k3d** (for local k3s), **jq**, **helm**, **git**, **Azure CLI**
  - Verify **jq** is installed and working (`apt install jq -y` or equivalent)
- Any previous kubeconfig context cleared or unset (to avoid conflicts)
- Access to **Azure Key Vault** secrets through a **Managed Service Identity (MSI)** with reader/appropriate permissions
- The Aurora repository cloned locally with the following prepared:
  - `.env` file based on `.env.example`
  - `base/argocd-instance.yaml` configured for your environment

> If any of these prerequisites are missing, resolve them before proceeding with the bootstrap steps.

## 1. Configuration of the .env file

Create a `.env` file alongside the bootstrap scripts.

For users with appropriate RBAC the MSI can be added via the script:

```dotenv
MSI="00000000-0000-0000-0000-000000000000"   # If MSI already exists
```

However while a custom role is being developed by the Azure Cloud team the MSI will needed to be added by them:

```dotenv
MSI_RESOURCE_ID="/subscriptions/<SUB>/resourceGroups/<RG>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/XXXX-XXXXX-ARGO-msi-argocd"
```

> TODO: The Azure Cloud team is developing a custom role to avoid requiring their intervention.

## 2. Create the Bootstrap Cluster

At this point you should be able to successfully run the setup script in the bootstrap cluster repository.

```sh
./setup.sh
```

> **Note:** You may need to manually delete an existing secret (`project-aurora-mgmt`) if it conflicts.

## 3. Set your Kube Context

Ensure kubectl is pointed at the bootstrap cluster.

By default, the setup script creates a local kubeconfig file named .kubeconfig.

Export the kubeconfig for the current shell session:

```sh
export KUBECONFIG=.kubeconfig
```

Verify you are connected to the bootstrap cluster:

```sh
kubectl get nodes
```

Continue only if you see the bootstrap cluster nodes listed.

## 4. Custom Certificate Authority (CA)

If your environment requires a Custom Certificate Authority (CA) and you must apply it to the bootstrap cluster so Argo CD and related components can establish TLS connections.

```sh
kubectl apply -f certs.yaml
kubectl rollout restart deploy -n platform-management-system
```

The certs.yaml file should define a ConfigMap similar to the following:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-certs
  namespace: platform-management-system
data:
  custom.crt: |-
    -----BEGIN CERTIFICATE-----
    XXXXX
    -----END CERTIFICATE-----
```

## 5. Update Argo CD Configuration

At this stage, Argo CD must be updated to point to the correct repository and configuration.

* Update the repo specification in [argocd-instance.yaml](https://github.com/gccloudone-aurora/bootstrap-cluster/blob/main/base/argocd-instance.yaml) so that Argo CD syncs from the correct Aurora repo.
* Switch to the aurora-svc service account and grant a Personal Access Token (PAT) with access to the new repo. This ensures Argo CD can authenticate and pull manifests.
* Approve the gccloudone-aurora request under pending repository access requests in your GitHub organization, so Argo CD has full read permissions.

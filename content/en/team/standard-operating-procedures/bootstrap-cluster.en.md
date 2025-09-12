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

- A Linux / WSL environment with bash, on a VM capable of mounting a  **Managed Service Identity (MSI)**
- Required CLI tools installed and accessible: **azure-cli**, **kubectl**, **k3d** (for local k3s), **jq**, **helm**, and **git**
- Any previous kubeconfig context cleared or unset (to avoid conflicts)
- The Aurora [bootstrap-cluster](https://github.com/gccloudone-aurora/bootstrap-cluster) repository cloned locally with the following prepared:
  - `.env` file based on `.env.example`
  - `base/argocd-instance.yaml` configured for your environment

> If any of these prerequisites are missing, resolve them before proceeding with the bootstrap steps.

## 1. Configuration of the .env file

Create a `.env` file alongside the bootstrap scripts by copying the .env.example file and configuring it.

For users with appropriate RBAC the MSI can be added via the script:

```dotenv
MSI="00000000-0000-0000-0000-000000000000"   # If MSI already exists
```

For users without the appropriate RBAC the MSI can only be added in advance by the Azure Cloud Team.

```dotenv
MSI_RESOURCE_ID="/subscriptions/<SUB>/resourceGroups/<RG>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/XXXX-XXXXX-ARGO-msi-argocd"
```

> TODO: The Azure Cloud team is developing a custom role to remove this manual step. Until then, the managed identity XXXX-XXXXX-ARGO-msi-argocd created during Enterprise Landing Zone (ESLZ) onboarding must be manually added to the jumpbox.

## 2. Update Your Project-Level Configuration

Start by cloning the Aurora project template:

```bash
git clone https://github.com/gccloudone-aurora/project-aurora-template.git
```

Each cluster will have its own `config.yaml` located under:

```sh
platform/clusters/non-prod/<cluster-name>/config.yaml
platform/clusters/prod/<cluster-name>/config.yaml
```

Edit the `config.yaml` for your target cluster to match your environment. This file tells Argo CD what to deploy and how to manage the cluster, making it the central configuration for the Aurora platform.

In most environments, you will need to update:

- **App-of-apps configuration** – adjust which components are deployed and how they sync
- **Networking and identity** – API server CIDRs, ingress domain, subscription/tenant IDs, Key Vault references
- **Core components** – toggle services like Cilium, cert-manager, and CIDR allocator

Finally, commit and push your changes to a repository. We typically use a naming convention such as project-example-aur, and for client workloads we always suffix the repository name with the -aur shortcode.

## 3. Update Argo CD Configuration

At this stage, Argo CD in the bootstrap cluster must be updated so it can track the repository you prepared in the previous step.

- **Update the repository specification** in [`argocd-instance.yaml`](https://github.com/gccloudone-aurora/bootstrap-cluster/blob/main/base/argocd-instance.yaml) so Argo CD syncs from the correct Aurora repo.
- **Grant authentication** by switching to the `aurora-svc` service account and providing a GitHub Personal Access Token (PAT) with access to the repo. This allows Argo CD to pull manifests.
- **Approve access** by approving the `gccloudone-aurora` request under pending repository access requests in your GitHub organization.

## 4. Create the Bootstrap Cluster

At this point you should be able to successfully run the setup script in the bootstrap cluster repository.

```sh
./setup.sh
```

Once the script fully executes you will be given instructions on how to login to the Argo CD instance.

> TODO: You may need to manually delete an existing secret (`project-aurora-mgmt`) if it conflicts.

## 5. Set your Kube Context

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

## 6. Custom Certificate Authority (CA) for local Argo CD

If your environment requires a Custom Certificate Authority (CA) you must ensure it is applied to the bootstrap cluster so Argo CD and related components can establish TLS connections.

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

## 7. Add Key Vault Secrets

At this stage, you must manually add the following secrets into Azure Key Vault so that Argo CD can fully authenticate with its resources and manage the Aurora platform:

- `xxxx-xxxxx-argo-kvs-github-password`
- `xxxx-xxxxx-argo-kvs-github-username`
- `xxxx-xxxxx-argo-kvs-cluster-admins`

> TODO: This step is required until these values are provisioned automatically as part of the Enterprise Landing Zone (ESLZ) onboarding.

## 8. Register Target Cluster & Transfer Control

Register the target cluster with Argo CD by running:

```sh
./register.sh
```

This script creates a cluster secret in Argo CD using the values from your .env file and will begin the process of deploying the Aurora platform (with Argo CD itself) into the target cluster.

> TODO: Please watch out for the duplicate aks-aks problem as you may need to hard-set the context values in .env before running the script.

## 9. Add DNS A Record

Navigate to the public DNS zone for your cluster created in the Azure Enterprise Landing Zone (ESLZ) onboarding.

- `*.aurora`: public DNS zone pointing to the load balancer

The load balancer is exposed by the service in the `ingress-general-system` namespace.

## 10. Custom Certificate Authority (CA) for target Argo CD

If you applied a Custom Certificate Authority (CA) to the bootstrap cluster, you must also apply it to the **target cluster**. This ensures Argo CD and related components in the target environment can establish TLS connections.

```sh
kubectl apply -f certs.yaml
kubectl rollout restart deploy -n platform-management-system
```

## 11. Patch Argo CD Repo-Server for Workload Identity

Because the Argo CD operator does not yet expose workload identity settings, you must manually patch the repo-server deployment to set the identity binding:

```sh
kubectl patch deployment argocd-repo-server \
  -n platform-management-system \
  -p '{"spec":{"template":{"metadata":{"labels":{"aadpodidbinding":"argocd-vault-plugin"}}}}}'
```

> Note: This step will no longer be required once the Argo CD operator natively supports workload identity.

## 12. Cilium policies for API server and Konnectivity host access

Until the AKS VNet integration for the control plane is GA in your environment, the API server Private Link endpoint is created in the same subnet as the default node pool rather then then the API server subnet. Additionally traffic from the API server is routed to the cluster via Konnectivity instead of direct into into the Virtual Network. If your default egress policy is restrictive, platform/system workloads may be unable to reach the API server, and Konnectivity may fail when it needs to talk to node/host IPs.
 
```yaml
  apiVersion: cilium.io/v2
  kind: CiliumClusterwideNetworkPolicy
  metadata:
    name: allow-egress-to-apiserver-from-platform-temp
  spec:
    egress:
    - toCIDRSet:
      - cidr: XX.XXX.XXX.XXX/32
      toPorts:
      - ports:
        - port: "443"
    endpointSelector:
      matchExpressions:
      - key: io.cilium.k8s.namespace.labels.namespace.ssc-spc.gc.ca/purpose
        operator: In
        values:
        - platform
        - system
  ---
  apiVersion: cilium.io/v2
  kind: CiliumClusterwideNetworkPolicy
  metadata:
    name: allow-egress-to-hosts-from-konnectivity
  spec:
    description: |
      This rule allows Konnectivity to connect to hosts.
    egress:
    - toEntities:
      - remote-node
      - host
    endpointSelector:
      matchExpressions:
      - key: io.kubernetes.pod.namespace
        operator: In
        values:
        - kube-system
      - key: app
        operator: In
        values:
          - konnectivity-agent
```

## 13. Destroy the Bootstrap Cluster

Once the complete Aurora platform is deployed onto the target cluster, and you can log in to the target's Argo CD instance to confirm that all applications are synced, you may safely remove the bootstrap cluster:

```bash
./cleanup.sh
```

> Note: Do not remove the bootstrap cluster until you have verified that the Aurora platform is fully deployed and synchronized on the target cluster, and that you can log in to the target Argo CD instance using OIDC.

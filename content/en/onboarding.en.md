---
title: "Onboarding"
date: 2025-11-15
draft: false
sidebar: false
showToc: false
translationKey: "onboarding"
disableCharacterlimit: true
---

This document describes how to onboard to the Aurora Managed AKS Cluster.

It is written as a single source of truth. Any values that are sensitive or department-specific will be provided separately through a secure, encrypted channel. This document uses placeholders where those values are required.

## Before You Begin

You will need the cluster-specific values that were provided to you through a secure channel.
Insert these values wherever placeholders are shown in this document.

## Prerequisites

Install the following tools before you begin:

- `az`: Azure CLI for authentication and managing Azure resources.
- `kubectl`: Kubernetes CLI for interacting with the cluster.
- `k9s`: Optional but recommended. A terminal UI for exploring cluster resources.
- `freelens`: Optional but recommended. A graphical client for viewing and managing Kubernetes clusters.

## Log in to Azure

Run the following command to authenticate with Azure:

```bash
az login --use-device-code
```

A browser window will open where you can enter the device code and complete the login.

If your department connects through SSC managed access paths, log in from an approved environment.
SSC currently supports:

- JumpBox hosts
- Azure Virtual Desktop (AVD)
- F5 authenticated access paths

These environments provide the required network peerings and routing for Aurora.

Verify your active subscription:

```bash
# Show the currently selected subscription name
az account show --query "name"

# Set the subscription provided to you securely
az account set --subscription "<INSERT_SUBSCRIPTION_NAME>"
```

### Why these access paths are required

Aurora clusters run inside SSC’s Enterprise Secure Landing Zone.
Access to the control plane and node pools is restricted through firewall rules, private endpoints, and VNet peering.

Approved access paths ensure:

- Correct outbound routing to Azure management endpoints
- Firewall rules that allow access to Kubernetes APIs
- Consistent identity and logging controls
- A controlled and auditable surface for administrative operations

Using AVD, a JumpBox, or an F5 authenticated path ensures that your session is inside the trusted network boundary with the correct connectivity.

## Get AKS credentials

Use the following command to configure `kubectl` to connect to your assigned Aurora AKS cluster.
Insert the resource group and cluster name provided through the secure channel.

```bash
az aks get-credentials \
  --resource-group "<INSERT_CLUSTER_RESOURCE_GROUP>" \
  --name "<INSERT_CLUSTER_NAME>"
```

This command writes the cluster configuration into your local `kubeconfig` file.

For easier management when working with multiple clusters and namespaces, consider installing:

- `kubectx` for switching Kubernetes contexts
- `kubens` for switching Kubernetes namespaces

### Validate your connection

Run the following commands to confirm that your connection to the cluster is working:

```bash
kubectl get nodes
kubectl get ns
```

If both commands return results without errors, your onboarding is successfully complete.

## ArgoCD in Aurora

Aurora uses ArgoCD to manage all configuration and workloads deployed into the Enterprise Secure Landing Zone (ESLZ).

Each Aurora management cluster (non-prod and prod) contains **two ArgoCD instances**, each serving a distinct role in the platform lifecycle.

Both ArgoCD instances reference your department’s private GitOps repository, following the Aurora naming convention:

```bash
- `https://github.com/gccloudone-aurora/project-<INSERT_DEPARTMENT>`
```

### Platform Management Instance

The Platform Management Instance is responsible for installing and maintaining the Aurora Platform itself.

This includes the core Kubernetes add-ons, horizontal services, controllers, networking configuration, security posture, and other foundational components.

```bash
- https://aur.aurora.<INSERT_MGMT_DEV_PLATFORM_ARGOCD> (Development)
- https://aur.aurora.<INSERT_MGMT_PROD_PLATFORM_ARGOCD> (Production)
```

Platform configuration is sourced from the following private repository:

- https://github.com/gccloudone-aurora/project-aurora-mgmt

For an example of the structure and approach used in this repository, you may consult the public template:

- https://github.com/gccloudone-aurora/project-aurora-template

Departments do not deploy workloads through this instance.

It is fully managed by the Aurora team to ensure consistent operation, security, and governance across all Aurora clusters.

### Solution Builder Instance

The Solution Builder Instance is dedicated to department-specific workloads.

This is where Solution Builders deploy and manage the components required inside their Aurora-hosted AKS clusters.

```bash
- https://sol.aurora.<INSERT_MGMT_DEV_SOLUTION_ARGOCD> (Development)
- https://sol.aurora.<INSERT_MGMT_PROD_SOLUTION_ARGOCD> (Production)
```

Solution configuration is sourced from the following private repository:

- https://github.com/gccloudone-aurora/project-aurora-mgmt

For an example of the structure and approach used in this repository, you may consult the public template:

- https://github.com/gccloudone-aurora/project-aurora-template

## Support

If you encounter any issues during onboarding or require assistance at any stage, support is available through several channels.

### Aurora Platform Documentation

An introductory overview of the Aurora platform architecture is available here:

- https://aurora.gccloudone.alpha.canada.ca/architecture/introduction/azure/

### Contact the Aurora Team

For general questions or onboarding support, contact the GC Cloud One Aurora team by email:

- **aurora-aurore@ssc-spc.gc.ca**

You can also reach us through our Microsoft Teams support channel:

- [**Aurora Support Channel on Microsoft Teams**](https://teams.microsoft.com/l/channel/19%3AXLC7f7eMIGf8yEe8JqJ5q_j-G-0Rr-MjJTjsoCtOTWs1%40thread.tacv2/Support?groupId=856cec3e-dac1-473a-abe8-0a810d2a5e0a&tenantId=d05bc)

### Incident and Issue Reporting

For operational issues, outages, or incidents, please submit a ticket through the SSC ITSM Tool (Remedy):

- https://smartit.prod.global.gc.ca/smartit/app/#/create/incident

Set the support group to:

- **20814 GCCO Aurora/Aurore SIUGC**

We strongly encourage clients to report incidents through Remedy to ensure proper tracking and response.

Direct client support is available Monday to Friday from **9:00 AM to 5:00 PM EST**.

---
title: "Onboarding process for the Enterprise Landing Zone"
linkTitle: "Onboarding process for the Enterprise Landing Zone"
weight: 5
aliases: ["/team/sop/eslz"]
date: 2025-08-19
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

To successfully onboard onto the Azure Enterprise Landing Zone (ESLZ), a few prerequisite steps must be completed. This guide explains how to set up the repository, register required features, and configure permissions before Aurora can be deployed.

The process builds on the L0/L1 blueprints provided by the Azure Cloud Team. These blueprints establish the enterprise foundation, including networking, network security groups (NSGs), DNS zones, logging, monitoring, and policy exemptions. Outputs from L1 are then passed into L2_blueprint_aurora, which provisions a secure and conformant Azure Kubernetes Service (AKS) cluster with predefined node pools and configuration recommended for Aurora environments. Terraform also populates Azure Key Vault with generated values, which the Aurora platform automatically consumes through Argo CD.

> Once these prerequisites are complete, you can move on to bootstrapping the Aurora platform.

## Scope & Assumptions

This guide is written with the following context in mind:

- You have been provided access to the Azure DevOps repository by the Azure Cloud Team
- You have an assigned Azure subscription within the ESLZ hierarchy
- You can escalate privileges via Azure AD Privileged Identity Management (PIM)
- The service principal *XXXX_XXX_XXXXX_devops_sp has been created by the Azure Cloud Team with appropriate permissions
- All commands are run from a workstation or jumpbox with Azure CLI, Terraform, and Terragrunt installed

This guide does not cover ongoing operations, platform deployment, or day-to-day cluster management.

## Prerequisites

The following must be in place before you begin the onboarding steps:

- The Azure DevOps repository provided by the Azure Cloud Team is available
- Associated runners/agents are configured for executing pipelines
- The L0/L1 pipelines have already run successfully, establishing baseline networking, NSGs, DNS zones, and policies

> If any of these are missing, contact the Azure Cloud Team before proceeding.

## 1. Landing Zone Repository Setup

Begin with the landing zone repository structure provided by the Azure Cloud Team. This ensures your environment remains aligned with ESLZ (Enterprise-Scale Landing Zone) standards.

```txt
landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora
landing_zones_XXXXXX-P6/modules/L2_blueprint_aurora
```

Update the configuration files for your environment:

* `landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora/config/aurora.tfvars`
* `landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora/envvars.sh`

These define project-specific variables such as subscription IDs, resource group names, and environment settings.

## 2. Privileged Identity Management (PIM)

Escalate into the App Reader role at directory scope using Azure AD Privileged Identity Management (PIM).

This role is required to view applications and groups in Entra ID, which will be necessary for validation and secret binding in later steps.

## 3. Azure Feature Registration

Enable and confirm the EncryptionAtHost feature for your subscription:

```sh
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
az feature show --namespace "Microsoft.Compute" --name "EncryptionAtHost"
```

Wait until the state is Registered. If needed, refresh the provider:

```sh
az provider register --namespace Microsoft.Compute
```

> This registration only needs to be done once per subscription. Propagation can take up to 15 minutes.

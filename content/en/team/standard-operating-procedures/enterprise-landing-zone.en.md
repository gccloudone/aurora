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
- The service principal XXXX_XXX_XXXXX_devops_sp has been created by the Azure Cloud Team with appropriate permissions (to create groups, app registrations, etc)
- All commands are run from a workstation or jumpbox with Azure CLI, Terraform, and Terragrunt installed

This guide does not cover ongoing operations, platform deployment, or day-to-day cluster management.

## Prerequisites

The following must be in place before you begin the onboarding steps:

- A Linux / WSL environment with bash, on a VM with inherent connectivity to the ESLZ
- Required CLI tools installed and accessible: **azure-cli**, **kubectl**, **jq**, **git**, and **terragrunt**

> If any of these prerequisites are missing, resolve them before requesting an ESLZ.

## 1. Request an ESLZ

Request an ESLZ from the Azure Cloud team using the following e-mail template:

``` plaintext
Hello, I would like to request a new ESLZ and setup a new AKS cluster.
Listed below are the details necessary for this request:
Name: SSC-AuroraSDLC
CBR: 21ZN
IP Range:
  /22 Reserved
    /23 for the Virtual Network
    /23 for the POD CIDR
Profile: 6
Env: <Env>
Notes:
  If can base the L0 / L1 on what is here: https://dev.azure.com/SSC-Aurora/ESLZ/_git/SSC-AuroraMGMT-iac
```

Usually we ask for a reserved CIDR size of /22 which is broken up into:

- /23 for the Virtual Network
- /23 for the POD CIDR

Once the CIDRs have been given it is important to then request that the associated firewall rules are setup as well.

At this point the Azure Cloud Team will get back to you with:

- The Azure DevOps repository that was created
- Associated runners/agents which have configured for executing pipelines
- The L0 / L1 pipelines which have already been run once successfully, establishing baseline networking, NSGs, DNS zones, and policies
- Usually a screenshot of the Firewall Rules that were set up in the firewall

Finally don't forget to add the designated user as a member of the owner group for the new subscription.

- XXXX-XXX-XXXXX-Owners

> Just for some explanation of the second /23. While it's not connected to the Azure network today, it will be in the future, which is why it needs to be unique and reserved in IPAM. We plan to connect that into the Azure network through Router Servers (aka. BGP) to remove the requirement for NAT, so that's why it needs to be reserved but not attached to the Vnet.

## 2. Landing Zone Repository Setup

Begin with the landing zone repository structure provided by the Azure Cloud Team. This ensures your environment remains aligned with ESLZ (Enterprise-Scale Landing Zone) standards.

You will first want to ensure the following adjustments have been made inside the L1_blueprint_base:

- Policy Exemptions
- Private DNS Zones
- VNET and Subnets
- NSGs

> Note: Request the Azure Cloud Team to merge the M.R. at the L1 level and with these adjustments before going forward.

Next you will want to create the folders for L2_blueprint_aurora:

```txt
landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora
landing_zones_XXXXXX-P6/modules/L2_blueprint_aurora
```

Update the configuration files for your environment:

- `landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora/config/aurora.tfvars`
- `landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora/envvars.sh`

> TODO: The Azure Cloud team will need to generate a secret for the XXXX_XXX_XXXXX_devops_sp since it doesn't get stored as part of initial ESLZ L0 / L1 deployment.

These define project-specific variables such as subscription IDs, resource group names, and environment settings.

## 3. Privileged Identity Management (PIM)

Escalate into the App Reader role at directory scope using Azure AD Privileged Identity Management (PIM).

This role is required to view applications and groups in Entra ID, which will be necessary for validation and secret binding in later steps.

## 4. Azure Feature Registration

First you need to ensure that the account performing the operations below is added to:

- XXXX-XXX-XXXXX-Operations (This group has owner on the subscription)

> You might need to log out and log back in in order for this to take effect.

Now you can enable and confirm the EncryptionAtHost feature for your subscription:

```sh
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
az feature show --namespace "Microsoft.Compute" --name "EncryptionAtHost"
```

Wait until the state is Registered. If needed, refresh the provider:

```sh
az provider register --namespace Microsoft.Compute
```

> This registration only needs to be done once per subscription. Propagation can take up to 15 minutes.

## 5. Deploy Infrastructure for Aurora Platform

Once the landing zone repository has been prepared, authenticate and run Terragrunt to both plan and deploy the infrastructure for the Aurora platform.

```sh
source .envvars
az login --use-device-code
terragrunt init -upgrade
terragrunt plan
terragrunt apply
```

> Note: Reminder to source the *.envvars folder and ensure using the correct service principal XXXX_XXX_XXXXX_devops_sp is being used.

## 6. Retrieve AKS Credentials

Retrieve the kubeconfig credentials for your newly deployed AKS cluster.

```sh
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```

> Note: This command merges the AKS cluster context into your local kubeconfig.

## 7. Service Principal Permissions for Argo CD

Ensure the newly created Service Principal (SPN) for Argo CD has the necessary permissions to function correctly.

At minimum, the Microsoft Graph API permissions should include:

- User.Read
- User.Read.All

You must also **grant admin consent** for these permissions in Entra ID so Argo CD can authenticate and retrieve the resources it manages.

## 7. Assign the AKS Cluster User Role to the DevOps Service Principal

The service principal XXXX_XXX_XXXXX_devops_sp that has been created by the Azure Cloud Team must have the **Azure Kubernetes Service Cluster User Role** assigned at the AKS cluster scope. This role is required for the service principal to interact with the Kubernetes API (e.g., running kubectl, provisioning workloads during bootstrap, or managing RBAC bindings).

## 8. Bootstrap Cluster

At this point all of the Aurora infrastructure is fully deployed onto the Enterprise-Scale Landing Zone (ESLZ).

The bootstrap cluster is only required the **first time** to establish a management cluster. Once in place, that management cluster will perform the ongoing work of deploying and managing Aurora.

You may now wish to consult the <gcds-link href="{{< relref "/team/standard-operating-procedures/bootstrap-cluster/" >}}">bootstrap cluster onboarding guide</gcds-link>.

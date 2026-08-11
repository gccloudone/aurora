---
title: "Onboarding process for the Enterprise Landing Zone"
linkTitle: "Onboarding process for the Enterprise Landing Zone"
weight: 5
aliases: ["/team/sop/eslz"]
date: 2026-08-11
draft: false
---

{{< translation-note >}}

To successfully onboard onto the Azure Enterprise Landing Zone (ESLZ), a few prerequisite steps must be completed. This guide explains how to set up the repository, register required features, and configure permissions before Aurora can be deployed.

The process builds on the L0/L1 blueprints provided by the Azure Cloud Team. These blueprints establish the enterprise foundation, including networking, network security groups (NSGs), DNS zones, logging, monitoring, and policy exemptions. Outputs from L1 are then passed into `L2_blueprint_aurora`, which provisions a secure and conformant Azure Kubernetes Service (AKS) cluster with the predefined node pools and configuration recommended for Aurora environments. Terraform also populates Azure Key Vault with generated values, which the Aurora Platform automatically consumes through Argo CD.

Once these prerequisites are complete, you can move on to bootstrapping the Aurora Platform.

## Scope and assumptions

This guide is written with the following context in mind:

- You have been provided access to the Azure DevOps repository by the Azure Cloud Team.
- You have an assigned Azure subscription within the ESLZ hierarchy.
- You can escalate privileges via Azure AD Privileged Identity Management (PIM).
- The service principal `XXXX_XXX_XXXXX_devops_sp` has been created by the Azure Cloud Team with the permissions needed to create groups, app registrations, and similar resources.
- All commands are run from a workstation or jumpbox with Azure CLI, Terraform, and Terragrunt installed.

This guide does not cover ongoing operations, platform deployment, or day-to-day cluster management.

## Prerequisites

The following must be in place before you begin the onboarding steps:

- A Linux or WSL environment with bash, on a VM with inherent connectivity to the ESLZ.
- The following CLI tools installed and accessible: `az` (Azure CLI), `kubectl`, `jq`, `git`, and `terragrunt`.

If any of these prerequisites are missing, resolve them before requesting an ESLZ.

## Onboarding steps

### 1. Request an ESLZ

Request an ESLZ from the Azure Cloud Team using the following email template:

```text
Hello, I would like to request a new ESLZ and set up a new AKS cluster.
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
  If possible, base the L0 / L1 on what is here: https://dev.azure.com/SSC-Aurora/ESLZ/_git/SSC-AuroraMGMT-iac
```

Usually we ask for a reserved CIDR size of /22, which is broken up into:

- /23 for the Virtual Network
- /23 for the POD CIDR

Once the CIDRs have been assigned, request that the associated firewall rules are set up as well.

At this point the Azure Cloud Team will get back to you with:

- The Azure DevOps repository that was created.
- Associated runners and agents configured for executing pipelines.
- The L0/L1 pipelines, which have already been run once successfully, establishing baseline networking, NSGs, DNS zones, and policies.
- Usually a screenshot of the firewall rules that were set up in the firewall.

Finally, do not forget to add the designated user as a member of the owner group for the new subscription:

- `XXXX-XXX-XXXXX-Owners`

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Some explanation of the second /23: while it is not connected to the Azure network today, it will be in the future, which is why it needs to be unique and reserved in IPAM. We plan to connect it into the Azure network through Router Servers (BGP) to remove the requirement for NAT, so it needs to be reserved but not attached to the VNet.</gcds-text>
</gcds-alert>

### 2. Landing zone repository setup

Begin with the landing zone repository structure provided by the Azure Cloud Team. This ensures your environment remains aligned with Enterprise-Scale Landing Zone (ESLZ) standards.

First, ensure the following adjustments have been made inside `L1_blueprint_base`:

- Policy exemptions
- Private DNS zones
- VNet and subnets
- NSGs

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Request that the Azure Cloud Team merge the merge request at the L1 level, with these adjustments, before going forward.</gcds-text>
</gcds-alert>

Next, create the folders for `L2_blueprint_aurora`:

```text
landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora
landing_zones_XXXXXX-P6/modules/L2_blueprint_aurora
```

Update the configuration files for your environment:

- `landing_zones_XXXXXX-P6/dev/L2_blueprint_aurora/config/aurora.tfvars`

These define project-specific variables such as subscription IDs, resource group names, and environment settings.

Next, set the following environment variables:

```sh
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
```

Request that the Azure Cloud Team provide you these values, obtained from the `XXXX_XXX_XXXXX_devops_sp` service principal. Make sure to later commit these secrets in the Aurora.kdb, found in our SharePoint under Aurora/KeePass.

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>The Azure Cloud Team will need to generate a secret for the <code>XXXX_XXX_XXXXX_devops_sp</code> service principal, since it does not get stored as part of the initial ESLZ L0/L1 deployment.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

### 3. Privileged Identity Management (PIM)

Escalate into the App Reader role at directory scope using Azure AD Privileged Identity Management (PIM).

This role is required to view applications and groups in Entra ID, which is necessary for validation and secret binding in later steps.

### 4. Azure feature registration

First, ensure that the account performing the operations below is added to the following group, which has owner on the subscription:

- `XXXX-XXX-XXXXX-Operations`

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>You might need to log out and log back in for this to take effect.</gcds-text>
</gcds-alert>

Now you can enable and confirm the `EncryptionAtHost` feature for your subscription:

```sh
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
az feature show --namespace "Microsoft.Compute" --name "EncryptionAtHost"
```

Wait until the state is `Registered`. If needed, refresh the provider:

```sh
az provider register --namespace Microsoft.Compute
```

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>This registration only needs to be done once per subscription. Propagation can take up to 15 minutes.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

### 5. Deploy infrastructure for the Aurora Platform

Once the landing zone repository has been prepared, increase the Standard DSv5 Family vCPUs quota to 64 for the target subscription. Then authenticate and run Terragrunt to plan and deploy the infrastructure for the Aurora Platform:

```sh
az login --use-device-code
terragrunt init -upgrade
terragrunt plan
terragrunt apply
```

### 6. Retrieve AKS credentials

Retrieve the kubeconfig credentials for your newly deployed AKS cluster. This command merges the AKS cluster context into your local kubeconfig:

```sh
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```

### 7. Service principal permissions for Argo CD

Ensure the newly created service principal (SPN) for Argo CD has the permissions it needs to function correctly.

At minimum, the Microsoft Graph API permissions should include:

- `User.Read`
- `User.Read.All`

You must also grant admin consent for these permissions in Entra ID so Argo CD can authenticate and retrieve the resources it manages.

### 8. Assign the AKS Cluster User Role to the DevOps service principal

The `XXXX_XXX_XXXXX_devops_sp` service principal created by the Azure Cloud Team must have the Azure Kubernetes Service Cluster User Role assigned at the AKS cluster scope. This role is required for the service principal to interact with the Kubernetes API, for example running kubectl, provisioning workloads during bootstrap, or managing RBAC bindings.

### 9. Bootstrap the management cluster

At this point all of the Aurora infrastructure is fully deployed onto the Enterprise-Scale Landing Zone (ESLZ).

The next step is to bootstrap the Aurora Platform onto the cluster. This is only required the first time, to establish a management cluster; once in place, that management cluster performs the ongoing work of deploying and managing Aurora. To continue, follow the <gcds-link href="{{< relref "/team/standard-operating-procedures/management-cluster/" >}}">management cluster bootstrap guide</gcds-link>.

If this cluster will instead be a workload cluster managed by an existing management cluster, see the <gcds-link href="{{< relref "/team/standard-operating-procedures/workload-cluster/" >}}">workload cluster onboarding guide</gcds-link>.

---

## Troubleshooting

### Error: Unable to create application

```text
Error: creating application: unexpected status 403 (403 Forbidden) with error: Authorization_RequestDenied: Insufficient privileges to complete the operation.
```

This error typically occurs when the `XXXX_XXX_XXXXX_devops_sp` service principal is missing required Microsoft Graph API permissions, or when admin consent has not been granted.

Contact the Azure DevOps team to ensure that:

- The necessary Microsoft Graph API permissions are assigned.
- Admin consent has been approved for those permissions.

### Error: tainted cluster_admins group

```text
module.aurora.azuread_group.cluster_admins is tainted, so must be replaced
```

This issue usually indicates that the `XXXX_XXX_XXXXX_devops_sp` service principal is missing the `GroupMember.ReadWrite.All` Microsoft Graph API permission. To resolve it, do one of the following:

- Assign the required API permission and grant admin consent.
- Run `terraform untaint <resource_address>`, manually add the required group members, then re-run `terraform plan` and `terraform apply`.

### Error: AKS cluster is stuck in `Updating` state

During `terragrunt apply`, the deployment may time out while updating the AKS cluster or creating a node pool.

To troubleshoot:

1. Check the associated Virtual Machine Scale Sets (VMSS).
1. Identify any instance whose status is not `Running`.
1. Select the affected instance, then go to Status, then Extension statuses.
1. Look for a `ProvisioningState/failed` status on the `vmssCSE` extension.

If this failure is present, it typically indicates a firewall or networking issue preventing node provisioning.

Next steps:

- SSH into the affected VM.
- Run `curl -kv https://mcr.microsoft.com:443`. If the request fails, this confirms a connectivity issue.

In this case, contact the SecOps team and provide the curl output for further investigation.

See the [Microsoft troubleshooting guide for OutboundConnFailVMExtensionError](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-outboundconnfailvmextensionerror) for more information.

---
title: "Deploy a PBMM-Compliant Kubernetes Cluster"
linkTitle: "Deploy a PBMM-Compliant Kubernetes Cluster"
weight: 3
aliases: ["/team/sop/deploy-kubernetes-cluster"]
date: 2026-08-20
draft: false
showToc: true
---

{{< translation-note >}}

## Objective

This SOP provisions a Protected B, Medium Integrity, Medium Availability (PBMM) compliant Azure Kubernetes Service (AKS) cluster using Aurora's Infrastructure as Code (IaC), deployed against an approved Enterprise-Scale Landing Zone (ESLZ).

![Aurora Platform](/images/architecture/diagrams/aurora-platform.png)

Two deployment models are supported depending on who owns the L0/L1 foundation:

- **Departmental Tenant ESLZ**, where your department owns the L0/L1 foundation and you provision the cluster from your own per-cluster Azure DevOps repository and pipeline.
- **SSC Azure ESLZ**, where the Azure Cloud Team at SSC owns the L0/L1 foundation and Aurora's Infrastructure as Code (IaC) is dropped into their landing-zone structure.

See [Choose your deployment model](#choose-your-deployment-model).

This SOP is written to be followed end to end without prior knowledge of the Aurora platform. Where a step depends on another team (networking, ESLZ intake, identity), that dependency is called out explicitly.

## Where this SOP fits in

Onboarding a project onto Aurora is a two-part sequence:

1. **Deploy a PBMM-compliant AKS cluster (this guide).** The cluster is hardened to the PBMM baseline. Authorization to operate is handled under the hosting tenant's assessment. It is production-ready and usable on its own, and its security controls are documented in the `security-narratives` repository, which can be freely shared.
2. **Deploy the Aurora Platform.** The Platform adds a curated, hardened set of CNCF tooling managed by Argo CD (observability, runtime security, certificate automation, and continuous delivery). This second phase is also where the cluster's role is assigned: the same cluster becomes a **management (hub) cluster** or a **workload cluster** depending on the platform configuration applied there (the chart's `mgmt` component, which is disabled by default and enabled through a management cluster's `config.yaml`).

The cluster this SOP produces is **role-neutral**: the steps below are identical for every cluster and do not, on their own, make it a management or workload cluster. That distinction is decided only in phase 2, when the Aurora Platform is deployed.

You may deploy **as many PBMM-compliant AKS clusters as you need** from this SOP's IaC; each is provisioned from the same IaC and hardened to the same PBMM baseline. The Aurora Platform, by contrast, **only works with Aurora's IaC** and must not be deployed onto a cluster that was not created through this SOP.

## Context

This SOP produces a **private AKS cluster** on a **Non-Overlay** network model, with the **Cilium** data plane, **Azure Linux** nodes, and best-practice security settings.

The Non-Overlay model is the detail that shapes most of the networking decisions below: pods receive real, routable IP addresses from a dedicated Pod subnet rather than NAT'd overlay addresses. Three consequences follow, and they matter before the landing zone networking is finalized (whether you request it on Path A or the Azure Cloud Team preconfigures it on Path B):

- **Subnet sizing.** The Pod subnet is sized for the maximum number of pods (the `/23` in the network design) and is separate from the node (System) subnet.
- **Source IP.** A pod's traffic egresses from the pod's own IP, not the node's. That pod IP is what you supply as the source on firewall and egress requests; using the node or System subnet instead is a common mistake.
- **Routing and policy.** Because pod IPs are real VNet addresses, they are visible to VNet routing, peerings, and firewall/network policy, all of which must account for the Pod subnet CIDR.

## Prerequisites

- Access to AZDO and the Aurora repository under your organization (`<AZDO_ORG>`) and project (`<AZDO_PROJECT>`)
- Approval for the AZDO project setup via your organization's documentation
- Familiarity with Terraform and Azure networking concepts
- A Linux or WSL environment with bash, on a VM with inherent connectivity to the ESLZ
- The following CLI tools installed and accessible: `az` (Azure CLI), `kubectl`, `jq`, `git`, and your provisioning tool (`terraform` or `terragrunt`, see note below)
- The RBAC and identity access described below

**Note:** Most departments and projects provision with Terraform directly. The Azure Enterprise-Scale Landing Zone (ESLZ) at SSC uses Terragrunt as a wrapper around Terraform.

### RBAC and Identity Prerequisites

This SOP may be run by an Aurora platform operator or by the department's own platform team standing up a new cluster; the steps are identical either way. Whoever runs it needs the elevated permissions and Entra ID visibility described below.

Aurora provisions most role assignments and access declaratively through its Terraform IaC. Some environments, however, restrict certain permission types (for example, Entra ID group and service-principal visibility, or service-principal creation) that the IaC cannot grant on its own; those must be arranged manually. As a result, both cluster creation and platform deployment require the operator running the SOP to see and assign the relevant Entra ID groups and service principals.

- **Known blocker, Entra visibility via PIM:** Assigning Kubernetes RBAC and mapping the correct Entra ID groups and service principals requires the operator to be able to see those objects in Entra ID. This visibility is granted through Privileged Identity Management (PIM) and requires an approved request for elevated permissions in Entra ID. Until that PIM access is in place, expect significant back-and-forth with the identity team for every RBAC assignment during onboarding. Submit the elevated-permissions request early so PIM access is available before it is needed.
- Both paths deploy through an Azure DevOps service connection backed by a user-assigned managed identity (UAMI). That identity must be able to create resources in the target cluster; if it cannot, `terraform apply` fails with a forbidden error creating namespaces.

### How cluster access works

This section is reference material describing the identity model; it is not a setup step.

Two Entra ID groups are foundational to cluster access, and they are wired by two different mechanisms:

- **Cluster administrators** (the `*-cluster-admins` group): passed via Terraform into the cluster at creation and mapped to in-cluster administrator RBAC.
- **General cluster users** (the `*-general-cluster-users` group): granted the Azure Kubernetes Service Cluster User Role through Azure RBAC so members can pull the cluster kubeconfig (`az aks get-credentials`). Their in-cluster permissions are then governed by Kubernetes RBAC.

The concrete group names and object IDs for the environment are in the AKS Reference Guide.

The AKS Authorization Flow below shows the runtime path when a user accesses the cluster. The user authenticates interactively to Entra ID (with MFA), which issues a JWT containing a `groups` claim of Entra group GUIDs. `kubectl` presents that token to the Kubernetes API server, which validates it via the Entra ID OIDC webhook. The Kubernetes RBAC engine then matches the group GUIDs against the cluster's ClusterRoleBindings and grants the corresponding permissions.

![Aurora AKS Authorization Flow](/images/architecture/diagrams/aurora-aks-authorization-flow.png)

Figure 2: AKS Authorization Flow

The Entra ID to Azure / AKS IAM RBAC Architecture below shows how access is structured across three planes. In the identity plane, Entra ID security groups live in the tenant. In the infrastructure plane, Azure (ARM) role assignments at the subscription scope are applied through Terraform. In the in-cluster plane, the Argo CD bootstrap deploys the Kubernetes ClusterRoles and ClusterRoleBindings that bind specific Entra group GUIDs to in-cluster roles. This is the static mapping that the authorization flow above evaluates at runtime.

![Entra ID to Azure / AKS IAM RBAC Architecture](/images/architecture/diagrams/aurora-entra-rbac.png)

Figure 3: Entra ID to Azure / AKS IAM RBAC Architecture

## Choose your deployment model

Provisioning follows one of two paths depending on who owns the L0/L1 enterprise foundation. Pick the one that matches your environment and follow its numbered steps end to end. Both paths finish the same way, by handing off to the Aurora Platform.

- **Path A — Departmental Tenant ESLZ.** Your department owns the L0/L1 foundation and you provision the cluster from your own per-cluster Azure DevOps repository, applied through its pipeline. Use this path for standard department and project onboarding in a departmental tenant.
- **Path B — SSC Azure ESLZ.** The Azure Cloud Team at SSC owns the L0/L1 foundation and provides the CI boilerplate. You drop Aurora's IaC (`L2_blueprint_aurora`) into their landing-zone repository, which their preconfigured pipeline applies on approved merge requests (or you can run Terragrunt manually from a jumpbox). Use this path when onboarding onto the SSC Enterprise-Scale Landing Zone on Azure.

### Terraform state ownership

On both paths, the cluster's Terraform state is owned and governed by the party that owns the cluster's IaC and pipeline, and it lives in that party's PBMM-compliant backend (an Azure Storage Account), one state per cluster repository:

- **Path A — Departmental Tenant ESLZ.** The governing department owns and administers the state backend.
- **Path B — SSC Azure ESLZ.** The Azure Cloud Team at SSC owns the state backend for the SSC Enterprise-Scale Landing Zone.

This keeps state ownership aligned with cluster-lifecycle ownership, so the governing team can reliably plan, apply, detect drift, and destroy, and so the state (which can contain sensitive values) stays under the controls the assessment relies on.

A client that wants complete control of the whole cluster, including its Terraform state in a client-owned Storage Account, must request it through the governing department. This arrangement is **discouraged**: it splits lifecycle ownership from state ownership, makes the governing team's operations depend on a backend it does not administer, and adds cross-subscription access and network dependencies for negligible benefit. Where it is nonetheless approved, the client assumes ownership of the full cluster lifecycle and the state backend must meet the same PBMM baseline (private endpoint, public access disabled, encryption, AAD/RBAC data-plane auth, blob versioning, and soft delete).

## Path A: Departmental Tenant ESLZ

Use this path when your department owns the L0/L1 foundation. Follow the steps in order, then continue to [Deploy the Aurora Platform](#deploy-the-aurora-platform).

### 1. Create a new repository in AZDO

In the Aurora AZDO project (`<AZDO_PROJECT>`) under your organization (`<AZDO_ORG>`), create a new repository for the cluster (**Repos -> New repository**). This requires permission to create repositories in the project (Project Administrator, or Contributor with repository creation allowed).

Seed the new repository from the template by importing it (**New repository -> Import a repository**, or clone the template locally and push it into the new repository):

```sh
# template to import / clone from
https://dev.azure.com/<AZDO_ORG>/<AZDO_PROJECT>/_git/template

# the new cluster repository you created
https://dev.azure.com/<AZDO_ORG>/<AZDO_PROJECT>/_git/<REPO_NAME>
```

The template carries the `azure-pipelines.yml` deployment pipeline, so the new repository is ready to run as soon as its ESLZ-aligned subscription and Service Connection are provisioned.

### 2. Initiate intake for ESLZ and subscription

Onboarding is initiated by submitting an intake request to provision the Enterprise-Scale Landing Zone (ESLZ) and subscription:

- `<INTAKE_PORTAL_URL>`

The following should all be noted in the additional information section:

- Provide the repository URL created above for the Service Connection setup
- Reference the expected subnet design provided in the following step

### 3. Specify subnet design

Include the following in the additional description field of the intake request. It asks the networking team to keep the existing Private Endpoint (PE) subnet and add the subnets Aurora requires. The requested sizes are minimums and must not overlap existing peered address space.

```txt
Keep the existing PE (Private Endpoint) subnet; it is used for resources you deploy.

Add the following subnets (referenced from Terraform via data sources):
- GatewaySnt       /27
- ApiServerSnt     /27
- GeneralSnt       /27   (reduced, since PodSnt now holds pod IPs)
- SystemSnt        /27
- LoadBalancerSnt  /27
- InfraSnt         /26
- PodSnt           /23

Total additional VNet space required: one /24 (covering the subnets above) plus one /23
(PodSnt), excluding subnets already deployed by the initial ESLZ.
```

### 4. Wait for ESLZ and subscription creation

Await confirmation from the landing-zone team that the ESLZ-aligned Azure subscription has been created. As part of provisioning the ESLZ and its Managed DevOps Pool, the Azure DevOps Service Connection for the repository created above is created automatically and linked to the new subscription. Verify it under **Project settings -> Service connections** in the AZDO project: it should target the new subscription and pass its verify/authorize check. The deployment pipeline runs through this Service Connection, so confirm it exists and is authorized before proceeding.

### 5. Verify VNet peerings

Confirm the VNet peerings for the deployed network are established before running the pipeline. In the Azure portal (**Virtual network -> Peerings**) or via `az network vnet peering list`, every relevant peering should show a **Connected** state, including the peering between the workload and management VNets and any peering the pipeline runner (Managed DevOps Pool) relies on to reach the cluster's private API server. Peerings can fall out of sync after address-space changes; re-sync them if so. Proceeding with a peering that is not Connected commonly surfaces later as an API-server i/o timeout.

### 6. Register required Azure features

Now that the subscription exists, register the Azure subscription features the cluster needs before it is provisioned. At minimum, register `EncryptionAtHost`, since the cluster uses host-level encryption. Register any other features your configuration requires the same way, substituting the namespace and feature name.

```sh
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
az feature show --namespace "Microsoft.Compute" --name "EncryptionAtHost"
```

Wait until the state is `Registered`, then refresh the provider so the registration takes effect:

```sh
az provider register --namespace Microsoft.Compute
```

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Feature registration only needs to be done once per subscription. Propagation can take up to 15 minutes.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

### 7. Execute the pipeline and approve permissions

Run the cluster's deployment pipeline in AZDO (**Pipelines**, then the pipeline for this repository) against the `main` branch.

On the first run, AZDO prompts to permit the pipeline to use the resources it references, the Azure Service Connection and any environments or variable groups. Approve these so the run can proceed.

The pipeline runs two stages, **Plan** then **Apply**:

- **Plan** installs Terraform and kubelogin, initializes Terraform against remote state, validates, and runs `terraform plan`. Review the plan output to confirm the changes are expected before Apply proceeds.
- **Apply** depends on a successful Plan, runs only on the `main` branch, and deploys with `terraform apply` using the environment's Azure Service Connection.

If Apply fails with an API-server i/o timeout or a forbidden error creating namespaces, see your environment's Troubleshooting section, which records the tenant-specific resolutions.

### 8. Confirm the cluster is ready

Once Apply completes successfully, the PBMM-compliant AKS cluster exists, hardened to the PBMM baseline (authorized under the hosting tenant's assessment). Confirm the AKS cluster and its node pools are present and provisioned in the target subscription's resource group (Azure portal or `az aks show`); full in-cluster verification (for example `kubectl get nodes`) is possible once cluster access is configured. Who can access the cluster is governed by the two Entra ID groups in the RBAC and Identity Prerequisites (cluster administrators, and general cluster users for the kubeconfig).

### 9. Retrieve AKS credentials

Retrieve the kubeconfig credentials for your newly deployed AKS cluster. This command merges the AKS cluster context into your local kubeconfig:

```sh
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```

### 10. Verify service principal permissions and grant admin consent

Ensure the service principal (SPN) for Argo CD has the permissions it needs to function correctly. At minimum, the Microsoft Graph API permissions should include:

- `User.Read`
- `User.Read.All`

You must also grant admin consent for these permissions in Entra ID so Argo CD can authenticate and retrieve the resources it manages. Admin consent cannot be scripted, so grant it manually in the Entra ID portal.

The cluster is now fully provisioned. Continue to [Deploy the Aurora Platform](#deploy-the-aurora-platform).

## Path B: SSC Azure ESLZ

Use this path when onboarding onto the SSC Enterprise-Scale Landing Zone on Azure, where the Azure Cloud Team owns the L0/L1 foundation. Rather than running your own pipeline, you drop Aurora's IaC into their landing-zone repository structure. Follow the steps in order, then continue to [Deploy the Aurora Platform](#deploy-the-aurora-platform).

The process builds on the L0/L1 blueprints provided by the Azure Cloud Team. These blueprints establish the enterprise foundation, including networking, network security groups (NSGs), DNS zones, logging, monitoring, and policy exemptions. Outputs from L1 are then passed into `L2_blueprint_aurora`, which provisions a secure and conformant AKS cluster with the predefined node pools and configuration recommended for Aurora environments. It also populates Azure Key Vault with generated values, which the Aurora Platform automatically consumes through Argo CD.

### 1. Request an ESLZ

Request an ESLZ from the Azure Cloud Team using the following GC Form:

- English: https://forms-formulaires.alpha.canada.ca/en/id/cmt38qwug00l901yn5cteahzx
- French: https://forms-formulaires.alpha.canada.ca/fr/id/cmt38qwug00l901yn5cteahzx

The Azure Cloud Team will get back to you with:

- The Azure DevOps repository that was created
- Associated runners and agents configured for executing pipelines
- The L0/L1 pipelines, which have already been run once successfully, establishing baseline networking, NSGs, DNS zones, and policies
- A screenshot of the firewall rules that were set up in the firewall

### 2. Landing zone repository setup

Begin with the landing zone repository structure provided by the Azure Cloud Team. This ensures your environment remains aligned with Enterprise-Scale Landing Zone (ESLZ) standards.

Unlike Path A, you do not request or design the base networking here. The Azure Cloud Team's L0/L1 already provides the networking foundation, including the VNet, subnets, NSGs, private DNS zones, and policy exemptions. Your task is to drop Aurora's IaC on top of it.

Create the folders for `L2_blueprint_aurora`:

```text
landing_zones_<SUFFIX>-P6/dev/L2_blueprint_aurora
landing_zones_<SUFFIX>-P6/modules/L2_blueprint_aurora
```

Update the configuration files for your environment:

- `landing_zones_<SUFFIX>-P6/dev/L2_blueprint_aurora/config/aurora.tfvars`

These define project-specific variables such as subscription IDs, resource group names, and environment settings.

The following environment variables are only needed if you intend to run Terragrunt or Terraform directly from your jumpbox. If you rely on the AZDO pipeline instead, it is already preconfigured and applies automatically on approved merge requests, so you can skip them.

To run locally, set:

```sh
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
```

Request that the Azure Cloud Team provide you these values, obtained from the `<PREFIX>_devops_sp` service principal.

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>The Azure Cloud Team will need to generate a secret for the <code><PREFIX>_devops_sp</code> service principal, since it does not get stored as part of the initial ESLZ L0/L1 deployment in the Key Vault.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

### 3. Arrange the required access

Two access grants are needed before you can register features and deploy. Arrange both now:

- **Subscription owner via the Operations group.** Ensure the account performing the deployment is added to the `<PREFIX>-Operations` group, which has owner on the subscription. You might need to log out and log back in for this to take effect.
- **App Reader via PIM.** Escalate into the App Reader role at directory scope using Azure AD Privileged Identity Management (PIM). This role is required to view applications and groups in Entra ID, which is necessary for validation and secret binding in later steps.

### 4. Register required Azure features

Now that the subscription exists and you have the access from the previous step, register the Azure subscription features the cluster needs before it is provisioned. At minimum, register `EncryptionAtHost`, since the cluster uses host-level encryption. Register any other features your configuration requires the same way, substituting the namespace and feature name.

```sh
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
az feature show --namespace "Microsoft.Compute" --name "EncryptionAtHost"
```

Wait until the state is `Registered`, then refresh the provider so the registration takes effect:

```sh
az provider register --namespace Microsoft.Compute
```

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="info" container="full" heading="Note" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Feature registration only needs to be done once per subscription. Propagation can take up to 15 minutes.</gcds-text>
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

### 6. Assign the AKS Cluster User Role to the DevOps service principal

The `<PREFIX>_devops_sp` service principal created by the Azure Cloud Team must have the Azure Kubernetes Service Cluster User Role assigned at the AKS cluster scope. This role is required for the service principal to interact with the Kubernetes API, for example running kubectl, provisioning workloads during bootstrap, or managing RBAC bindings.

### 7. Retrieve AKS credentials

Retrieve the kubeconfig credentials for your newly deployed AKS cluster. This command merges the AKS cluster context into your local kubeconfig:

```sh
az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```

### 8. Verify service principal permissions and grant admin consent

Ensure the service principal (SPN) for Argo CD has the permissions it needs to function correctly. At minimum, the Microsoft Graph API permissions should include:

- `User.Read`
- `User.Read.All`

You must also grant admin consent for these permissions in Entra ID so Argo CD can authenticate and retrieve the resources it manages. Admin consent cannot be scripted, so grant it manually in the Entra ID portal.

The cluster is now fully provisioned. Continue to [Deploy the Aurora Platform](#deploy-the-aurora-platform).

## Deploy the Aurora Platform

At this point the PBMM-compliant AKS cluster exists and is production-ready on its own. The next step is to deploy the Aurora Platform onto it. Follow the <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-aurora-platform/" >}}">Deploy Aurora Platform guide</gcds-link>, which covers both paths: bootstrapping a new management cluster, and onboarding the cluster as a workload cluster into an existing management cluster's Argo CD.

## Troubleshooting

### Error: Unable to create application

```text
Error: creating application: unexpected status 403 (403 Forbidden) with error: Authorization_RequestDenied: Insufficient privileges to complete the operation.
```

This error typically occurs when the `<PREFIX>_devops_sp` service principal is missing required Microsoft Graph API permissions, or when admin consent has not been granted.

Contact the Azure DevOps team to ensure that:

- The necessary Microsoft Graph API permissions are assigned.
- Admin consent has been approved for those permissions.

### Error: tainted cluster_admins group

```text
module.aurora.azuread_group.cluster_admins is tainted, so must be replaced
```

This issue usually indicates that the `<PREFIX>_devops_sp` service principal is missing the `GroupMember.ReadWrite.All` Microsoft Graph API permission. To resolve it, do one of the following:

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

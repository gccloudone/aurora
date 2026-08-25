---
title: "Tear Down a PBMM-Compliant Kubernetes Cluster"
linkTitle: "Tear Down a PBMM-Compliant Kubernetes Cluster"
weight: 5
aliases: ["/team/sop/teardown-kubernetes-cluster"]
date: 2026-08-19
draft: false
showToc: true
---

{{< translation-note >}}

## Objective

This SOP describes the process for tearing down a PBMM Kubernetes cluster in the Azure environment. You may need to tear down a cluster when a client confirms that it is no longer required. The procedure removes the Aurora Platform from the target cluster, cleans up its configuration in Git and on the management cluster, destroys the L2 infrastructure with Terragrunt, and requests removal of the remaining L0/L1 subscription resources.

<!-- markdownlint-disable MD033 -->

<gcds-alert alert-role="danger" container="full" heading="This procedure is destructive and irreversible" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Tearing down a cluster permanently deletes its workloads, data, and Azure resources. Confirm you are targeting the correct cluster and subscription at every step, and do not begin until the written client confirmation in Step 1 is in hand.</gcds-text>
</gcds-alert>

<!-- markdownlint-enable MD033 -->

## Where this SOP fits

Tearing down a cluster reverses the two-part onboarding sequence documented in the deployment SOPs, unwinding it from the top down:

1. Remove the Aurora Platform from the target cluster (Steps 2 to 5), reversing the <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-aurora-platform/" >}}">Deploy the Aurora Platform</gcds-link> process.
2. Destroy the PBMM-compliant AKS cluster and its infrastructure (Steps 6 onward), reversing the <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-kubernetes-cluster/" >}}">Deploy a PBMM Kubernetes Cluster</gcds-link> process.

The platform is removed before the infrastructure so that Argo CD deprovisions its managed resources cleanly before the underlying cluster is destroyed.

## Prerequisites

Ensure the following are in place before you begin:

- A Linux or WSL environment with bash, running on a VM with network connectivity to the ESLZ
- The following CLI tools installed and accessible: `az` (Azure CLI), `kubectl`, `git`, and `terraform` or `terragrunt`
- Access to the `<PREFIX>_devops_sp` credentials, which can be found in KeePass

## Teardown Steps

### 1. Obtain written confirmation from the client

If the cluster is a department-level cluster, ensure that the client has provided **written confirmation** that the cluster is no longer required. Retain this confirmation; it is attached to the pull request in a later step.

### 2. Delete the target cluster's platform App of Apps from Argo CD

Navigate to the management cluster's Argo CD portal and delete the platform App of Apps (`platform-<cluster-name>`) responsible for deploying the Aurora Platform charts to the target cluster. This is the `platform-<cluster-name>` application that was synced when the cluster was onboarded in the <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-aurora-platform/" >}}">Deploy the Aurora Platform</gcds-link> SOP.

Select the **Background** deletion option. Wait until all child applications have been removed from the target cluster before proceeding.

### 3. Remove the target cluster configuration from its Git repository

Delete the `config.yaml` configuration for the Aurora Platform charts from the target cluster's Git repository.

When creating the pull request, attach a copy of the client's written authorization to delete the cluster obtained in Step 1.

If there are no plans to reuse the repository, it may also be deleted.

### 4. Remove the target cluster from the management cluster configuration

Remove all references to the target cluster from the management cluster's `config.yaml`.

### 5. Sync the management cluster

Sync the management cluster in Argo CD. Verify in the Argo CD portal that there are no remaining references to the target cluster.

### 6. Connect to the target cluster's jumpbox

Connect to a jumpbox with network connectivity to the target cluster. Open a terminal and change into the directory of the Git repository containing the IaC for the target cluster.

The location depends on how the cluster was provisioned:

- **SSC Azure ESLZ** (provisioned with Terragrunt): change into the `L2_blueprint_aurora` directory in the landing zone repository, matching the environment (P3 or P6) you are tearing down:

  ```text
  /landing_zones_<SUFFIX>-P3/**/L2_blueprint_aurora
  /landing_zones_<SUFFIX>-P6/**/L2_blueprint_aurora
  ```

- **Departmental Tenant ESLZ** (provisioned with Terraform): change into the root of the cluster's own IaC repository, the one created and applied through its Azure DevOps pipeline during deployment.

### 7. Set the Azure credentials

Authenticate to the target subscription so the destroy in the next step can run.

For the **SSC Azure ESLZ**, load the following environment variables into your terminal:

```sh
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_TENANT_ID
ARM_SUBSCRIPTION_ID
```

These credentials can be obtained from the `<PREFIX>_devops_sp` service principal.

For a **Departmental Tenant ESLZ**, authenticate with the Azure CLI (`az login`) as an identity with permission to destroy resources in the target subscription, or run the destroy through the same Azure DevOps pipeline used to deploy the cluster.

### 8. Destroy the L2 resources

Use the same tool the cluster was provisioned with.

For the **SSC Azure ESLZ** (Terragrunt):

```bash
terragrunt init
terragrunt destroy
```

For a **Departmental Tenant ESLZ** (Terraform):

```bash
terraform init
terraform destroy
```

Depending on the state of the environment, the destroy command may need to be run multiple times.

### 9. Verify that all L2 resources have been deleted

Confirm in the Azure portal that all L2 resources associated with the target cluster have been removed.

### 10. Submit a request to the Azure DevOps team

Submit a request to the Azure DevOps team to:

- Delete the remaining L0/L1 resources in the target subscription.
- Remove any associated networking and firewall configurations.
- Delete the `-iac` and `-cicd` repositories used to configure the ESLZ for the cluster.

### 11. Verify that the subscription has been removed

Confirm that the target subscription no longer appears in the Azure portal.

## Troubleshooting

### Key Vault cannot be destroyed

The destroy command may fail when attempting to delete the Key Vault due to permission or network-related issues.

This can occur because `terraform destroy` (or `terragrunt destroy`) removes the access policies delegated to the service principal and may also remove the private endpoint before the Key Vault itself is deleted.

If this occurs, it may be necessary to manually delete the Key Vault through the Azure portal.

### Terraform cannot destroy Kubernetes resources

You may encounter this issue if the node pools or target AKS cluster were manually deleted before running the destroy command.

To resolve this issue, manually remove the affected **Kubernetes resources** from the Terraform state, then run the destroy command again.

For the **SSC Azure ESLZ** (Terragrunt):

```bash
terragrunt state rm <resource>
```

For a **Departmental Tenant ESLZ** (Terraform):

```bash
terraform state rm <resource>
```

Repeat the command for each affected Kubernetes resource, then run the destroy command again.

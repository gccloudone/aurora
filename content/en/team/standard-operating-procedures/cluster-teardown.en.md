---

title: "Cluster Teardown"
linkTitle: "Cluster Teardown"
weight: 5
aliases: ["/team/sop/cluster-teardown"]
date: 2026-08-19
draft: false
------------

{{< translation-note >}}

This document outlines the process for tearing down a cluster in P6.

# Prerequisites

The following prerequisites must be met before beginning the teardown:

* A Linux or WSL environment with Bash, running on a VM with network connectivity to the ESLZ.
* The following CLI tools installed and accessible: `az` (Azure CLI), `kubectl`, `git`, and `terragrunt`.
* Access to the `XXXX_XXX_XXXXX_devops_sp` credentials, which can be found in KeePass.

# Teardown Steps

1. **Obtain written confirmation from the client.**

   If the cluster is a department-level cluster, ensure that the client has provided **written confirmation** that the cluster is no longer required.

2. **Delete the target cluster's platform App of Apps from ArgoCD.**

   Navigate to the management cluster's ArgoCD portal and delete the platform App of Apps (`platform-cluster-name`) responsible for deploying the Aurora platform charts to the target cluster.

   Select the **Background** deletion option. Wait until all child applications have been removed from the target cluster before proceeding.

3. **Remove the target cluster configuration from its Git repository.**

   Delete the `config.yaml` configuration for the Aurora platform charts from the target cluster's Git repository.

   When creating the pull request, attach a copy of the client's written authorization to delete the cluster obtained in Step 1.

   If there are no plans to reuse the repository, it may also be deleted.

4. **Remove the target cluster from the management cluster configuration.**

   Remove all references to the target cluster from the management cluster's `config.yaml`.

5. **Sync the management cluster.**

   Sync the management cluster in ArgoCD. Verify in the ArgoCD portal that there are no remaining references to the target cluster.

6. **Connect to the target cluster's jumpbox.**

   Connect to a jumpbox with network connectivity to the target cluster. Open a terminal and change to the Git repository containing the ESLZ configuration for the target cluster.

   The following commands should be run from:

   `/landing_zones_163ent-P6/**/L2_blueprint_aurora`

7. **Set the Azure credentials.**

   Load the following environment variables into your terminal:

   * `ARM_CLIENT_ID`
   * `ARM_CLIENT_SECRET`
   * `ARM_TENANT_ID`
   * `ARM_SUBSCRIPTION_ID`

   These credentials can be obtained from the `XXXX_XXX_XXXXX_devops_sp` service principal.

8. **Destroy the L2 resources.**

   Run:

   ```bash
   terragrunt init
   terragrunt destroy
   ```

   Depending on the state of the environment, `terragrunt destroy` may need to be run multiple times.

9. **Verify that all L2 resources have been deleted.**

   Confirm in the Azure portal that all L2 resources associated with the target cluster have been removed.

10. **Submit a request to the Azure DevOps team.**

    [Submit a request to the Azure DevOps team](https://www.cloudopsportal.g3.ent.cloud-nuage.canada.ca/support/AzureDevOps/New) to:

    * Delete the remaining L0/L1 resources in the target subscription.
    * Remove any associated networking and firewall configurations.
    * Delete the `-iac` and `-cicd` repositories used to configure the ESLZ for the cluster.

11. **Verify that the subscription has been removed.**

    Confirm that the target subscription no longer appears in the Azure portal.

# Troubleshooting

## Issue: Key Vault cannot be destroyed

`terragrunt destroy` may fail when attempting to delete the Key Vault due to permission or network-related issues.

This can occur because `terragrunt destroy` removes the access policies delegated to the service principal and may also remove the private endpoint before the Key Vault itself is deleted.

If this occurs, it may be necessary to manually delete the Key Vault through the Azure portal.

## Issue: Terragrunt cannot destroy Kubernetes resources

You may encounter this issue if the node pools or target AKS cluster were manually deleted before running `terragrunt destroy`.

To resolve this issue, manually remove the affected **Kubernetes resources** from the Terraform state using:

```bash
terragrunt state rm <resource>
```

Repeat the command for each affected Kubernetes resource, then run `terragrunt destroy` again.

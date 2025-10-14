---
title: "Adding components to Aurora Platform Charts"
linkTitle: "Adding components to Aurora Platform Charts"
weight: 5
aliases: ["/team/sop/aurora-platform-chart-add-component"]
date: 2025-10-09
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This document outlines the process for adding a new component to the [aurora-platform-charts repository](https://github.com/gccloudone-aurora/aurora-platform-charts).

## Context

Aurora uses ArgoCD to deploy Helm charts through the `Application` resource.  

If you are unfamiliar with how ArgoCD deploys Helm charts, review the [ArgoCD Helm documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/) and examples in the aurora-platform-charts repository before proceeding.

### Pre-requisites

Before adding any third-party helm charts to the Aurora platform do the following:

- Render the helm templates and verify that the rendered manifests are what we expect (e.g. there are no additional resources that are being created that we don't expect)

   ```helm template <name> ./path/to/chart --values=<example values.yaml> ```
- Confirm that the Helm repository URL matches the official vendor repository URL.

## Procedure

### 1. Decide which folder the component should go under

Determine if the component should go under `aurora-app` or `aurora-core`. `aurora-app` are for components that enhance the functionality of the Aurora platform and `aurora-core` are for components that are critical for Aurora's operation.

### 2. Create a subfolder for the component

Within the appropriate folder (`aurora-app` or `aurora-core`), create a new subfolder under `templates` named after the component.

### 3. Create the YAML file for the component

Create the `<component-name>.yaml` file in the folder that was just created & add templating for the following fields:

- tolerations
- image
- priorityClassName
- affinity
- nodeSelector

Add templating for any other fields you think should be configurable for the component.

The templating for the component should allow configurability for other Cloud Service Providers if applicable.

[Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/cert-manager.yaml)

If applicable, create a separate .yaml file for anything that may also need to be deployed for the component to work, such as Custom Resources.

[Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/issuers.yaml)

### 4. Create the `namespace.yaml` file

For the `namespace.yaml`, fill in the appropriate values according to the values for the aurora-solution chart [available here](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-solution/values.yaml). The `information` field should remain the same as other components.

[Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-app/templates/argo-workflow/namespace.yaml)

### 5. Create the `netpol.yaml` file

For the `netpol.yaml`, create any Network Policies exempting flows the component may need. By default, all flows are denied unless explicitly granted through the `NetworkPolicy` or through the `CiliumClusterwideNetworkPolicy`.

[Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/falco/netpol.yaml)

### 6. Create the `_helpers.tpl` file

For the `_helpers.tpl`, create a helper template for all image fields referenced in the component's YAML file that you created. The template should allow users the flexibility to pull the image from a third-party registry or from a custom registry. [Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-app/templates/argo-workflow/_helpers.tpl).

### 7. Update the `values.yaml` file

Add the default values to the `values.yaml` file for your component under the `aurora-core` or `aurora-app` folder. Ensure defaults for the fields specified in section [Create the YAML file for the component](#3-create-the-yaml-file-for-the-component) are provided.

[Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/values.yaml#L342)

Also add your component under either the `core` or `app` field as `# component: {}` in the `values.yaml` file located under `aurora-platform`.

### 8. Update the `Chart.yaml`

Bump the version number specified in the `Chart.yaml` file located under `aurora-platform`.

### 9. Create a pull request

Once you've pushed up your branch with all the changes, create a pull request and request a review from the team.

### 9. Deploy & test

Once your pull request is approved, merge in your pull request. You can patch the `version` field in the `config.yaml` to the new version of the aurora-platform chart. Once completed, the new `Applications` should be visible in the ArgoCD instance from where you can manually sync the application & have the resources deployed onto the cluster. Test the component and validate it functions as expected.

---
title: "Adding Components to Aurora Platform Charts"
linkTitle: "Adding Components to Aurora Platform Charts"
weight: 5
aliases: ["/team/sop/aurora-platform-chart-add-component"]
date: 2026-08-11
draft: false
---

{{< translation-note >}}

This document outlines the process for adding a new component to the [aurora-platform-charts repository](https://github.com/gccloudone-aurora/aurora-platform-charts).

## Context

Aurora uses ArgoCD to deploy Helm charts through the `Application` resource.

If you are unfamiliar with how ArgoCD deploys Helm charts, review the [ArgoCD Helm documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/) and examples in the aurora-platform-charts repository before proceeding.

### Pre-requisites

Before adding any third-party Helm charts to the Aurora platform, do the following:

- Render the Helm templates and verify that the rendered manifests are what we expect (e.g. no unexpected resources are being created):

  ```sh
  helm template <name> ./path/to/chart --values=<example values.yaml>
  ```

- Confirm that the Helm repository URL matches the official vendor repository URL.
- Perform a vulnerability scan on each referenced image with Trivy:

  ```sh
  trivy image <container-image>
  ```

  - Investigate any critical vulnerabilities and determine whether they are applicable.

## Procedure

### 1. Decide which folder the component should go under

Determine whether the component should go under aurora-app or aurora-core. Use aurora-app for components that enhance the functionality of the Aurora platform, and aurora-core for components that are critical to Aurora's operation.

### 2. Create a subfolder for the component

Within the appropriate folder (aurora-app or aurora-core), create a new subfolder under `templates` named after the component.

### 3. Create the YAML file for the component

In the folder you just created, add a `<component-name>.yaml` file with templating for the following fields:

- tolerations
- image
- priorityClassName
- affinity
- nodeSelector

Add templating for any other fields you think should be configurable for the component.

The templating for the component should allow configurability for other Cloud Service Providers if applicable.

- [Example using Cert Manager](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/cert-manager.yaml)

If applicable, create a separate YAML file for anything else the component needs in order to work, such as Custom Resources.

- [Example using Cert Manager Issuers](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/issuers.yaml)

### 4. Create the `namespace.yaml` file

Fill in the appropriate values according to the [aurora-solution chart values](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-solution/values.yaml). The `information` field should remain the same as other components.

- [Example using Cert Manager Namespace](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/namespace.yaml)

### 5. Create the `netpol.yaml` file

Create any Network Policies exempting flows the component may need. By default, all flows are denied unless explicitly granted through a `NetworkPolicy` or a `CiliumClusterwideNetworkPolicy`.

- [Example Cert Manager NetworkPolicy](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/netpol.yaml)

### 6. Create the `_helpers.tpl` file

Create a helper template for every image field referenced in the component's YAML file. The template should let users pull the image from either a third-party registry or a custom registry.

- [Example `_helpers.tpl`](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/cert-manager/_helpers.tpl)

### 7. Update the `values.yaml` file

Add the default values for your component to the `values.yaml` file under the aurora-core or aurora-app folder. Be sure to provide defaults for the fields listed in [Create the YAML file for the component](#3-create-the-yaml-file-for-the-component).

- [Aurora Core values.yaml](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/values.yaml#L342)

Also add your component under either the `core` or `app` field as `# component: {}` in the `values.yaml` file located under aurora-platform.

### 8. Update the `Chart.yaml`

Bump the version number specified in the `Chart.yaml` file located under aurora-platform.

### 9. Create a pull request

Once you've pushed up your branch with all the changes, create a pull request and request a review from the team.

### 10. Deploy and test

Once your pull request is approved, merge it. Patch the `version` field in the `config.yaml` to the new version of the aurora-platform chart. The new `Applications` should then appear in the ArgoCD instance, where you can manually sync the application to deploy the resources onto the cluster. Finally, test the component and validate that it functions as expected.

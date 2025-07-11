---
title: "Infrastructure and Configuration Management"
linkTitle: "Infrastructure and Configuration Management"
weight: 10
lang: "en"
date: 2025-07-08
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Infrastructure-as-Code (via Terraform) and Configuration-as-Code (via ArgoCD, Helm, and/or Kustomize) repositories are the source of truth for the intended state of the Aurora platform. Changes outside of these repositories are only permitted:
- Inside Aurora platform development environments inaccessible to end-users
- For complex after-hours maintenance, such as Kubernetes cluster upgrades with breaking changes
- During incidents where the repositories and/or relevant automation systems are either inaccessible or unacceptably slow

In all such cases, the repositories are updated as soon as possible to reflect all changes that are intended to be kept.

Helm chart and Terraform module versions are incremented using [Semantic Versioning](https://semver.org/).

Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format and are squashed into a pull request, which is labeled according to the [Issue Naming](../issue-naming) SOP. For live environments, the pull request is approved by at least one other Aurora team member before merging.



## Infrastructure

Terraform modules for Aurora infrastructure are available as [open-source repositories](https://github.com/orgs/gccloudone-aurora-iac/repositories) within the GC Cloud One Aurora IaC GitHub organization. The module instantiated to deploy an Aurora cluster and its supporting infrastructure is nested in the following fashion (Azure example):

- [terraform-aurora-azure-environment](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment)
  - Several instances of [terraform-azure-service-principal](https://github.com/gccloudone-aurora-iac/terraform-azure-service-principal)
  - [terraform-aurora-azure-environment-network](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-network)
    - [terraform-azure-route-server](https://github.com/gccloudone-aurora-iac/terraform-azure-route-server)
    - [terraform-azure-virtual-network](https://github.com/gccloudone-aurora-iac/terraform-azure-virtual-network)
  - [terraform-aurora-azure-environment-infrastructure](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-infrastructure)
    - [terraform-azure-kubernetes-cluster](https://github.com/gccloudone-aurora-iac/terraform-azure-kubernetes-cluster)
    - [terraform-azure-key-vault](https://github.com/gccloudone-aurora-iac/terraform-azure-key-vault)
    - [terraform-azure-kubernetes-cluster-nodepool](https://github.com/gccloudone-aurora-iac/terraform-azure-kubernetes-cluster-nodepool)
  - [terraform-aurora-azure-environment-platform-infrastructure](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-platform-infrastructure)

To deploy and manage an Aurora Kubernetes cluster and its supporting cloud infrastructure, a Terraform configuration instantiates the root environment module (e.g. [terraform-aurora-azure-environment](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment)) alongside a separate module (e.g. [terraform-aurora-azure-environment-argo-secrets](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-argo-secrets)) that populates ArgoCD with Secrets that are common across multiple clusters. 

Deployment is carried out within private DevOps platform repositories using pipelines that run `terraform` commands, including `lint`, `validate`, `plan`, and `apply` stages as well as optional utility jobs such as `import`. Additional supporting infrastructure modules may be instantiated depending on the Cloud Service Provider.

## Configuration

Aurora platform components are primarily configured within the open-source [aurora-platform-charts repository](https://github.com/gccloudone-aurora/aurora-platform-charts), containing nested Helm charts as well as ArgoCD Applications and ApplicationSets. Certain configuration values can be defined on a per-cluster basis inside of private DevOps platform repositories. 

The version of each root chart is updated with any change to a nested component. ArgoCD instances synchronize platform chart updates to Aurora clusters. Platform development clusters receive such updates automatically, while other clusters must have the intended platform chart version explicitly set in the configuration that supplies their custom Helm values.

The GC Cloud One Aurora GitHub organization contains [additional open-source repositories](https://github.com/orgs/gccloudone-aurora/repositories), such as custom-built Aurora components as well as configurations in formats other than Helm charts (for example, the Kustomize-based [gatekeeper-policies](https://github.com/gccloudone-aurora/gatekeeper-policies)).

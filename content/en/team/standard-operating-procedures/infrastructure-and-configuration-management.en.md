---
title: "Infrastructure and Configuration Management"
linkTitle: "Infrastructure and Configuration Management"
weight: 5
lang: "en"
date: 2026-08-11
---

{{< translation-note >}}

## Overview

The Aurora platform is managed entirely as code. Two types of repositories define its intended state and serve as the single source of truth:

- **Infrastructure as Code (IaC)** — the underlying cloud resources, managed with Terraform.
- **Configuration as Code (CaC)** — the platform software running on top, managed with ArgoCD, Helm, and / or Kustomize.

Changes are made by updating these repositories, not by editing live systems directly; automation then deploys them to the platform.

## Organization Overview

Aurora's repositories are spread across three GitHub organizations:

- **[github.com/gccloudone](https://github.com/gccloudone):** Public-facing content and documentation, including the Aurora documentation site.
- **[github.com/gccloudone-aurora](https://github.com/gccloudone-aurora):** Platform tooling, Helm charts, Kubernetes manifests, custom controllers, and the `project-*` configuration repositories that drive GitOps reconciliation.
- **[github.com/gccloudone-aurora-iac](https://github.com/gccloudone-aurora-iac):** Terraform Infrastructure-as-Code modules used to provision the Azure resources that Aurora depends on.

## Making Manual Changes

Changing the platform outside of the repositories is limited to designated [Platform Administrators and Platform Developers]({{< relref "architecture/security/access-control#platform-administrator" >}}), and only when:

- **Platform Developers** work within development environments that are inaccessible to end-users.
- **Platform Administrators** perform complex after-hours maintenance, such as cluster upgrades with breaking changes.
- **Platform Administrators** respond to incidents where the repositories or automation systems are inaccessible or unacceptably slow.

Any manual change that is meant to be kept must be written back to the repositories as soon as possible. Otherwise, later updates and automated reconciliation (such as ArgoCD Sync) will overwrite it.

## Change Management Standards

All changes follow a consistent set of standards:

- **Versioning** — Helm charts, Terraform modules, CI/CD pipelines, and custom component images are versioned with [Semantic Versioning](https://semver.org/). Merged changes tag the repository with the new version, and all cross-repository references are version pinned to support staged testing and rollback.
- **Commits and reviews** — Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) and are squashed into a single pull request, labeled per the [Issue Naming](../issue-naming) SOP. Merging requires write access and at least one other reviewer's approval.
- **Promotion path** — Each Aurora cluster has at minimum a development and a production instance, with optional stages (such as testing) in between. Changes are always validated in development first and promoted to production last.

## Infrastructure

Terraform modules for Aurora infrastructure are available as [open-source repositories](https://github.com/orgs/gccloudone-aurora-iac/repositories) within the GC Cloud One Aurora IaC GitHub organization.

To deploy a cluster and its supporting cloud infrastructure, a Terraform configuration instantiates a single root environment module (Azure example: [terraform-aurora-azure-environment](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment)), which composes the necessary networking, cluster, and platform infrastructure modules internally. A separate module (for example, [terraform-aurora-azure-environment-argo-secrets](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment-argo-secrets)) populates ArgoCD with Secrets shared across multiple clusters.

Deployment runs in private DevOps platform repositories through pipelines that execute `terraform` across `lint`, `validate`, `plan`, and `apply` stages, plus optional jobs such as `import`. Additional supporting modules may be instantiated depending on the Cloud Service Provider.

Aurora does not always own this provisioning. Where SSC's Enterprise Scale Landing Zone (ESLZ) governs the underlying cloud resources, infrastructure is deployed through SSC's own Azure DevOps (AZDO) processes rather than these modules. In those environments, the `infrastructure/` directory of the relevant `project-*` repository documents the intended state and links to the AZDO repository that performs the provisioning (see [Project Repositories](#project-repositories)).

## Configuration

Once a cluster is provisioned, declarative configuration turns it into a fully governed Aurora platform: `project-*` repositories describe each project, the platform charts package the platform stack, and ArgoCD reconciles it all onto clusters via GitOps.

### Project Repositories

Platform configuration lives in `project-*` repositories, each scaffolded from [project-aurora-template](https://github.com/gccloudone-aurora/project-aurora-template) for a consistent structure. Each repository declares the environments its project deploys into. Examples include [project-aurora-mgmt](https://github.com/gccloudone-aurora/project-aurora-mgmt), [project-aurora-sdlc](https://github.com/gccloudone-aurora/project-aurora-sdlc), and [project-cds](https://github.com/gccloudone-aurora/project-cds) (all private).

These repositories:

- Provide declarative configuration for every cluster, namespace, and solution in their environments.
- Support hierarchical composition, where higher-level repositories define platform guardrails (for example, `project-aurora-mgmt` integrates with `project-aurora-sdlc`).
- Separate platform logic from project-specific configuration, preventing drift and streamlining upgrades.

The `infrastructure/` directory is not always where provisioning runs. Under ESLZ governance it holds placeholders that document the intended infrastructure and link to the AZDO repository performing it (see [Infrastructure](#infrastructure)).

Each `project-*` repository follows this structure:

```txt
project-<name>/
│
├── infrastructure/                 # IaC, or ESLZ placeholders linking to the AZDO IaC repo
│   ├── non-prod/
│   └── prod/
│
└── platform/
    ├── clusters/                   # Cluster-specific values rendered into aurora-platform-charts
    │   └── <cluster>/
    │       └── config.yaml
    │
    ├── namespaces/                 # Namespace definitions, onboarding metadata, RBAC, quotas
    │   └── <namespace>/config.yaml
    │
    └── solutions/                  # Solution-level deployments managed by the Platform Team
        └── <solution>/
```

### Aurora Platform Charts

The open-source [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts) repository is the centralized Helm library that installs the platform stack onto a cluster, turning raw Kubernetes into a governed, PBMM-compliant application hosting platform. It contains nested Helm charts alongside ArgoCD Applications and ApplicationSets, and:

- Encodes Aurora's security, networking, and policy defaults centrally, so every cluster inherits a consistent, guardrailed baseline across the fleet.
- Is rendered by ArgoCD using values from the `project-*` repositories, with secrets pulled from Azure Key Vault via the ArgoCD Vault Plugin.
- Reconciles all platform components through GitOps, ensuring zero drift and reliable upgrades.
- Is cloud-agnostic by design, for consistent behavior across supported Kubernetes providers (Azure today; other providers are future targets).

Each root chart's version is bumped whenever a nested component changes, and ArgoCD synchronizes the update to Aurora clusters:

- **Platform development clusters** receive updates automatically.
- **All other clusters** must pin the intended chart version in the configuration that supplies their custom Helm values.

The GC Cloud One Aurora GitHub organization also contains [additional open-source repositories](https://github.com/orgs/gccloudone-aurora/repositories), including custom-built components and non-Helm configurations (for example, the Kustomize-based [gatekeeper-policies](https://github.com/gccloudone-aurora/gatekeeper-policies) and [tetragon-policies](https://github.com/gccloudone-aurora/tetragon-policies)).

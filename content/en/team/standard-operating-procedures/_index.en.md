---
title: "Standard Operating Procedures"
linkTitle: "Standard Operating Procedures"
weight: 5
aliases: ["/team/sop/"]
date: 2025-01-01
draft: false
translationKey: "standard-operating-procedures"
---

{{< translation-note >}}

The Aurora initiative spans multiple teams, environments, and responsibilities. To keep our work consistent, we maintain a set of **Standard Operating Procedures (SOPs)** that cover common workflows, technical conventions, and collaboration practices.

These are our agreed ways of working, from platform engineers to partner departments, so everyone shares the same understanding of how we operate. Have a browse through the procedures below and pick the one that fits what you're working on.

---

## Current SOPs

Here are the current procedures in place:

<!-- markdownlint-disable MD033 -->

<div class="mb-400">
<gcds-grid tag="ul" columns="1fr" columns-tablet="1fr 1fr" columns-desktop="1fr 1fr" gap="400" class="hydrated">
  <gcds-card
    card-title="Deploy a PBMM Kubernetes Cluster"
    href="/en/team/standard-operating-procedures/deploy-kubernetes-cluster/"
    badge="Onboarding"
    description="Procedure to provision a PBMM-compliant Azure Kubernetes Service (AKS) cluster ready for the Aurora Platform, covering both the Departmental Tenant ESLZ and SSC Azure ESLZ deployment models."
  >
  </gcds-card>
  <gcds-card
    card-title="Deploy the Aurora Platform"
    href="/en/team/standard-operating-procedures/deploy-aurora-platform/"
    badge="Onboarding"
    description="Procedure for deploying the Aurora Platform onto an AKS cluster. It covers two scenarios: bootstrapping a new management cluster by installing Argo CD with the Bootstrap Terraform, and onboarding a workload cluster into the Argo CD of an existing management cluster."
  >
  </gcds-card>
  <gcds-card
    card-title="Adding Components to Aurora Platform Charts"
    href="/en/team/standard-operating-procedures/adding-components-aurora-platform-chart/"
    badge="Operations"
    description="Guidelines for adding new components to the aurora-platform-charts."
  >
  </gcds-card>
  <gcds-card
    card-title="AKS Cluster Upgrade"
    href="/en/team/standard-operating-procedures/aks-cluster-upgrade/"
    badge="Operations"
    description="Procedure for upgrading an AKS cluster."
  >
  </gcds-card>
  <gcds-card
    card-title="Infrastructure and Configuration Management"
    href="/en/team/standard-operating-procedures/infrastructure-and-configuration-management/"
    badge="Operations"
    description="How Aurora manages infrastructure (Terraform) and configuration (Argo CD, Helm, Kustomize) as code, including source-of-truth repos, versioning, and promotion."
  >
  </gcds-card>
  <gcds-card
    card-title="SSL Cert Issuance"
    href="/en/team/standard-operating-procedures/ssl-cert-issuance/"
    badge="Operations"
    description="Procedure for validating the issuance of SSL certificates with Cert Manager."
  >
  </gcds-card>
  <gcds-card
    card-title="Backup and Disaster Recovery"
    href="/en/team/standard-operating-procedures/backup-disaster-recovery/"
    badge="Reliability"
    description="Procedure for validating that backups and restore processes work as expected."
  >
  </gcds-card>
  <gcds-card
    card-title="Issue and PR Naming Conventions"
    href="/en/team/standard-operating-procedures/issue-naming/"
    badge="Governance"
    description="Standards for naming and labeling issues and pull requests across Aurora."
  >
  </gcds-card>
  <gcds-card
    card-title="Issue Tracking"
    href="/en/team/standard-operating-procedures/issue-tracking/"
    badge="Governance"
    description="Standards for issue tracking across Aurora."
  >
  </gcds-card>
  <gcds-card
    card-title="GitHub Actions for Creating Releases"
    href="/en/team/standard-operating-procedures/use-gh-action-for-creating-releases/"
    badge="Operations"
    description="How to use the shared GitHub Composite Action to standardize release naming, tagging, and notes generation across repositories."
  >
  </gcds-card>
</gcds-grid>
</div>

<!-- markdownlint-enable MD033 -->

> SOPs are living documents. If you spot something that needs updating or expanding, please open an issue or <gcds-link href="mailto:aurora-aurore@ssc-spc.gc.ca">email us</gcds-link>.

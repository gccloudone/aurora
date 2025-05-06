---
title: "Architecture"
linkTitle: "Architecture"
type: "architecture"
weight: 10
draft: false
lang: "en"
showToc: true
date: 2025-01-01
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

<gcds-alert alert-role="info" container="full" heading="A brief word of caution" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>This initiative builds on the original platform developed at Statistics Canada, which was initially deployed on a single cloud service provider. While the platform was architected to be cloud-agnostic, each provider’s managed Kubernetes offering requires specific adjustments to ensure full compatibility. These adaptations are underway, as our goal is to support <strong>all major cloud environments</strong> across government. We appreciate your patience as we continue to open source Aurora’s architectural plan and share it here for community review and collaborative improvement.
</gcds-text>
</gcds-alert>

Aurora is a universal platform for modern application hosting, designed to standardize the use of managed Kubernetes services across the Government of Canada. It provides a secure, self-service environment that enables solution builders to rapidly develop and deploy cloud-native applications while staying aligned with federal security, compliance, and operational requirements.

This Architecture guide will outline the core design principles and technical foundation of Aurora—a platform intentionally engineered to support scalable, secure, and self-service application delivery across the Government of Canada. It presents the modular components that power the platform, including infrastructure orchestration, zero trust enforcement, and strict workload isolation through policy.

It also addresses key operational concerns such as multi-tenant cluster management, compliance automation, and GitOps-driven deployment workflows. Together, these capabilities form the backbone of a consistent, developer-focused platform that reduces duplication, enforces governance, and accelerates cloud-native adoption at scale.

---

## Overview

Aurora is not a Kubernetes distribution, it is a composable set of add-on components that transform any managed Kubernetes environment into a full-featured, secure, and scalable application hosting platform. Built atop existing cloud-managed services such as AKS, EKS, GKE, and OpenShift, Aurora provides the foundational services, governance controls, and developer experience enhancements required to support modern, multi-tenant workloads across the Government of Canada.

Aurora includes a curated, opinionated configuration of cloud-native components and Kubernetes resources aligned to Government of Canada requirements—balancing developer self-service with strong security, compliance, and operational guardrails.

- Base Platform: Cloud-managed Kubernetes offerings (AKS, EKS, GKE, OpenShift)
- Networking Layer: Cilium with BGP (BIRD + route reflectors) and namespace-level network policies for tenant isolation
- Security Model: Zero Trust architecture, Gatekeeper (OPA) for policy enforcement, SCED integration for on-prem connectivity
- CI/CD Pipelines: GitLab Runners integrated with Argo CD for GitOps-based delivery
- Observability Stack: Prometheus, Loki, and centralized logging/metrics forwarding
- Multi-Tenancy Approach: Namespaced resource boundaries, enforced network isolation, and RBAC + policy guardrails

> Note: Future enhancements will explore API surface isolation using tools like vcluster, allowing departments or advanced workloads to run custom controllers (e.g., CRDs) in isolated virtual control planes without impacting the stability or governance of the shared platform.

### Key Benefits

- ✔️ Unified API surface for Kubernetes adoption across the GC
- ✔️ Opinionated configuration that aligns with GC policies and standards
- ✔️ Security-first, with embedded zero trust and governance by default
- ✔️ Interoperable with existing departmental infrastructure
- ✔️ Flexible deployment models, supporting both OSS and proprietary tooling
- ✔️ Strong tenant isolation via namespace boundaries and enforced network segmentation
- ✔️ Self-service within policy boundaries, empowering teams while ensuring compliance

## Policy-Driven Model

Aurora enables developer autonomy while enforcing non-negotiable guardrails. The platform uses Gatekeeper (OPA) and curated policies to ensure all workloads adhere to GC-wide compliance, security, and operational requirements—without the need for manual reviews or central bottlenecks.

By codifying these constraints, Aurora empowers application teams to build, deploy, and manage their solutions independently, while staying within clearly defined, enforceable limits. This freedom within boundaries model reduces cognitive load on platform and security teams while increasing delivery velocity for application teams.

## Governance and Compliance Alignment

The Aurora initiative is supported by the newly established Technical Advisory Group (TAG)—a cross-departmental body that provides architectural oversight, technical guidance, and ensures continuous alignment with Government of Canada priorities. Governed by a published charter, roles, and responsibilities, the TAG enables community-driven governance and helps shape the platform’s evolution through shared stewardship.

- Aurora adheres to SSC’s cloud governance model, ensuring interoperability, security, and standardization
- Leverages CNCF best practices for operational maturity
- Supports multi-tenancy, workload separation, and automated compliance checks
- Aligns with Treasury Board Secretariat (TBS) cloud directives

### Deployment Approach

Aurora will be deployed in SSC’s Enterprise Tenant, using a clear separation between non-production and production environments to support safe rollout and operational maturity of platform capabilities.

- Two main platform environments for cluster provisioning and platform services:
  - AuroraNonProd: Used to test and validate Aurora’s cluster provisioning processes, platform upgrades, and service configurations before promotion to production. This environment acts as a staging area to ensure operational stability.
  - AuroraProd: The authoritative production environment where all active Aurora clusters will be managed from, including tenant clusters and shared services infrastructure.
- Integration with Fortigate Firewalls, using metadata-driven rulesets to restrict inter-cluster communication and ensure workload isolation, managed entirely as Infrastructure as Code (IaC)
- Centralized GitOps pipelines (Argo CD) for deploying and enforcing platform-level policies across all Aurora clusters

### Supporting Services and Management Clusters

In addition to the platform clusters above, the Aurora model includes several supporting service layers:

- [Planned] Shared Management Cluster: A centralized Argo CD environment to orchestrate deployment pipelines and policy enforcement across all Aurora clusters.
- [Planned] Shared SDLC Environments: Hosted in the Enterprise Tenant, enabling small departments and agencies to access secure CI/CD pipelines and runtime environments without managing their own clusters
- [Planned] Per-Department SDLC Clusters: Deployed either in the Enterprise Tenant (preferred) or departmental tenants, with connectivity to departmental landing zones. These clusters allow departments with more advanced needs to onboard in a governed but autonomous manner

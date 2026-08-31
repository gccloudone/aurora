---
title: "Onboarding Background"
linkTitle: "Onboarding Background"
weight: 3
aliases: ["/team/sop/onboarding-background"]
date: 2026-08-20
draft: false
showToc: true
---

{{< translation-note >}}

## Objective

This document collects the shared background for Aurora's onboarding SOPs: <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-kubernetes-cluster/" >}}">cluster creation</gcds-link>, <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-aurora-platform/" >}}">platform deployment</gcds-link>, and <gcds-link href="{{< relref "/team/standard-operating-procedures/teardown-kubernetes-cluster/" >}}">teardown</gcds-link>. It is reference material, not a procedure: read it once before you begin so the SOPs can get straight to their steps, then follow the SOP for the task at hand. Where a topic below is referenced by a specific SOP, that SOP points back to this document rather than repeating the material.

## How cluster access works

This is reference material describing the identity model; it is not a setup step.

Two Entra ID groups are foundational to cluster access, and they are wired by two different mechanisms:

- **Cluster administrators** (the `*-cluster-admins` group): passed via Terraform into the cluster at creation and mapped to in-cluster administrator RBAC.
- **General cluster users** (the `*-general-cluster-users` group): granted the Azure Kubernetes Service Cluster User Role through Azure RBAC so members can pull the cluster kubeconfig (`az aks get-credentials`). Their in-cluster permissions are then governed by Kubernetes RBAC.

The AKS Authorization Flow below shows the runtime path when a user accesses the cluster. The user authenticates interactively to Entra ID (with MFA), which issues a JWT containing a `groups` claim of Entra group GUIDs. `kubectl` presents that token to the Kubernetes API server, which validates it via the Entra ID OIDC webhook. The Kubernetes RBAC engine then matches the group GUIDs against the cluster's ClusterRoleBindings and grants the corresponding permissions.

![Aurora AKS Authorization Flow](/images/architecture/diagrams/aurora-aks-authorization-flow.png)

Figure 1: AKS Authorization Flow

The Entra ID to Azure / AKS IAM RBAC Architecture below shows how access is structured across three planes. In the identity plane, Entra ID security groups live in the tenant. In the infrastructure plane, Azure (ARM) role assignments at the subscription scope are applied through Terraform. In the in-cluster plane, the Argo CD bootstrap deploys the Kubernetes ClusterRoles and ClusterRoleBindings that bind specific Entra group GUIDs to in-cluster roles. This is the static mapping that the authorization flow in Figure 1 evaluates at runtime.

![Entra ID to Azure / AKS IAM RBAC Architecture](/images/architecture/diagrams/aurora-entra-rbac.png)

Figure 2: Entra ID to Azure / AKS IAM RBAC Architecture

## Networking: the flat network model

The flat (non-overlay) network model is the detail that shapes most of the networking decisions in the SOPs: pods receive real, routable IP addresses from a dedicated Pod subnet rather than NAT'd overlay addresses. Three consequences follow, and they matter before the landing zone networking is finalized (whether you request it on Path A or the Azure Cloud Team preconfigures it on Path B):

- **Subnet sizing.** The Pod subnet is sized for the maximum number of pods (the `/23` in the network design) and is separate from the node (System) subnet.
- **Source IP.** A pod's traffic egresses from the pod's own IP, not the node's. That pod IP is what you supply as the source on firewall and egress requests; using the node or System subnet instead is a common mistake.
- **Routing and policy.** Because pod IPs are real VNet addresses, they are visible to VNet routing, peerings, and firewall/network policy, all of which must account for the Pod subnet CIDR.

## RBAC and identity prerequisites

The onboarding SOPs may be run by an Aurora platform operator or by the department's own platform team standing up a new cluster; the steps are identical either way. Whoever runs them needs the elevated permissions and Entra ID visibility described below.

Aurora provisions most role assignments and access declaratively through its Terraform IaC. Some environments, however, restrict certain permission types (for example, Entra ID group and service-principal visibility, or service-principal creation) that the IaC cannot grant on its own; those must be arranged manually. As a result, both cluster creation and platform deployment require the operator running the SOP to see and assign the relevant Entra ID groups and service principals.

- **Known blocker, Entra visibility via PIM:** Assigning Kubernetes RBAC and mapping the correct Entra ID groups and service principals requires the operator to be able to see those objects in Entra ID. This visibility is granted through Privileged Identity Management (PIM) and requires an approved request for elevated permissions in Entra ID. Until that PIM access is in place, expect significant back-and-forth with the identity team for every RBAC assignment during onboarding. Submit the elevated-permissions request early so PIM access is available before it is needed.
- Both paths deploy through an Azure DevOps service connection backed by a user-assigned managed identity (UAMI). That identity must be able to create resources in the target cluster; if it cannot, `terraform apply` fails with a forbidden error creating namespaces.

## Terraform state ownership

Provisioning follows one of two paths depending on who owns the L0/L1 enterprise foundation: **Path A — Departmental Tenant ESLZ** (your department owns the L0/L1 foundation) and **Path B — SSC Azure ESLZ** (the Azure Cloud Team at SSC owns it). The <gcds-link href="{{< relref "/team/standard-operating-procedures/deploy-kubernetes-cluster/" >}}">cluster creation SOP</gcds-link> defines these paths in full.

On both paths, the cluster's Terraform state is owned and governed by the party that owns the cluster's IaC and pipeline, and it lives in that party's PBMM-compliant backend (an Azure Storage Account), one state per cluster repository:

- **Path A — Departmental Tenant ESLZ.** The governing department owns and administers the state backend.
- **Path B — SSC Azure ESLZ.** The Azure Cloud Team at SSC owns the state backend for the SSC Enterprise-Scale Landing Zone.

This keeps state ownership aligned with cluster-lifecycle ownership, so the governing team can reliably plan, apply, detect drift, and destroy, and so the state (which can contain sensitive values) stays under the controls the assessment relies on.

A client that wants complete control of the whole cluster, including its Terraform state in a client-owned Storage Account, must request it from the governing department. This arrangement is **discouraged**: it splits lifecycle ownership from state ownership, makes the governing team's operations depend on a backend it does not administer, and adds cross-subscription access and network dependencies for negligible benefit. Where it is nonetheless approved, the client assumes ownership of the full cluster lifecycle and the state backend must meet the same PBMM baseline (private endpoint, public access disabled, encryption, AAD/RBAC data-plane auth, blob versioning, and soft delete).

---
title: "Kubernetes"
linkTitle: "Kubernetes"
type: "architecture"
weight: 1
draft: false
lang: "en"
date: 2025-05-29
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Kubernetes offers [Roles and ClusterRoles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) which define access and [RoleBindings and ClusterRoleBindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) which bind Roles and ClusterRoles to an OAuth identity. This identity be an individual user or user group from an integrated OAuth provider (in our case Microsoft Entra ID) or a [Kubernetes ServiceAccount](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/).

Aurora platform component access control is managed using Kubernetes ServiceAccounts in each component's Namespace. Each ServiceAccount has its own Role or ClusterRole defining the exact rules necessary for the corresponding component's function.

Human user access control is implemented across all Aurora Kubernetes clusters in the following ways:

## Solution Builder

A custom [`solution-builder` ClusterRole](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/solution-builder.yaml) defines the minimum permissions necessary for application development and operation on Kubernetes. The label `rbac.ssc-spc.gc.ca/aggregate-to-solution-builder: "true"` permits component-specific Solution Builder ClusterRoles to be defined separately and [aggregated](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles) into this role. ([Example](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/prometheus/rbac.yaml))

A RoleBinding in each Solution Builder namespace binds this ClusterRole to the Microsoft Entra group designated for the Kubernetes application developers/operators of that Solution Builder team.

## Platform Operator

Two custom ClusterRoles are defined for Platform Operators: [`platform-operator-view`](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/platform-operator-view.yaml) for read access and [`platform-operator-maintenance'](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/platform-operator-maintenance.yaml) for write access. ClusterRole aggregation to these roles further defines read and write access to specific platform components.

A ClusterRoleBinding binds these ClusterRoles to the Microsoft Entra group designated for the day-to-day activities of the cluster's Platform Operators.

## Platform Administrator

Platform Administrators correspond to the [default User-facing Kubernetes role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) `cluster-admin`. This role is bound to a specific Microsoft Entra ID group whose membership is activated via [Microsoft Entra Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure). 

Activation requires submitting a justification, a time duration, and a reference to a support, maintenance, or incident ticket. Once the alloted time has expired, the Microsoft Entra ID [access token](https://learn.microsoft.com/en-us/entra/identity/users/users-revoke-access#access-tokens-and-refresh-tokens) required for this privileged role is no longer issued or refreshed. 

## Platform Developer

Platform Developers also correspond to the `cluster-admin` default role. Unlike the Platform Administrator, this role is not time-bound. However, this role is only defined and accessible on clusters designated for developing and testing Aurora platform infrastructure.
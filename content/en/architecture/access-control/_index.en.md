---
title: "Access Control Definitions"
linkTitle: "Access Control"
type: "architecture"
weight: 20
draft: false
lang: "en"
date: 2025-05-29
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Access control is implemented according to the principle of least privilege. These procedures are reviewed multiple times a year, whenever there are updates to the underlying APIs or organisational processes.

Aurora platform components that access or provide data are identified through non-human accounts: [Kubernetes ServiceAccounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/) as well as Cloud Service Provider (CSP) identities such as [Microsoft Entra workload identities](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview). These accounts are granted the minimum necessary sets of permissions for each component's intended function.

Kubernetes offers [Roles and ClusterRoles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) which define access and [RoleBindings and ClusterRoleBindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) which bind Roles and ClusterRoles to an OAuth identity. This identity can be an individual user or user group from an integrated identity provider or a Kubernetes ServiceAccount.

Microsoft Entra ID is the centralized identity provider, with one account per human user. Through membership in one or more [Microsoft Entra groups](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-manage-groups), each account has access to one or more user roles that align with the following high-level definitions:

## Solution Builder
Solution Builders design, develop, deploy, and operate solutions that run on Aurora. They require access to Kubernetes Resources and CustomResources.

A custom [`solution-builder` ClusterRole](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/solution-builder.yaml) defines the minimum permissions necessary for application development and operation on Kubernetes. The label `rbac.ssc-spc.gc.ca/aggregate-to-solution-builder: "true"` permits component-specific Solution Builder ClusterRoles to be defined separately and [aggregated](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles) into this role. [(Example)](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/prometheus/rbac.yaml)

A RoleBinding in each Solution Builder Namespace binds this ClusterRole to the Microsoft Entra group designated for the Kubernetes application developers/operators of that Solution Builder team.

Solution Builders may also require access to CSP resources such as managed databases and storage accounts. This is outside the scope of Aurora's access control and is established according to the processes of the corresponding Infrastructure-as-a-Service service lines.

## Platform Operator
Platform Operators ensure the continual operation of one or more areas of the Aurora platform. This requires read access to most platform resources, excluding confidential information such as Secrets. This also requires write access for common and low-impact remediation activities. 

Two custom ClusterRoles are defined for Platform Operators: [`platform-operator-view`](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/platform-operator-view.yaml) for read access and [`platform-operator-maintenance'](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/platform-operator-maintenance.yaml) for write access. ClusterRole aggregation to these roles further defines read and write access to specific platform components.

A ClusterRoleBinding binds these ClusterRoles to the Microsoft Entra group designated for the day-to-day activities of the cluster's Platform Operators.

Whenever possible, changes to Aurora CSP resources are effected via Infrastructure/Configuration-as-Code and corresponding automated CI/CD processes. Platform Operator write access to CSP resources is limited to cancelling such operations. Higher impact manual remediation requires escalation to the Platform Administrator role.

## Platform Administrator
Platform Administrators have full access to the Kubernetes clusters and other CSP resources comprising one or more areas of the Aurora platform.

This role is invoked in order to:
- Perform planned maintenance that requires major manual changes. These changes must first be verified using the Platform Developer role in the appropriate testing environment.
- Resolve urgent security and/or operational incidents, including on an on-call basis.

This role can only be activated by a group of designated personnel through privilege escalation procedures such as [Microsoft Entra Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure). Activation requires submitting a justification, a time duration (after which the role is automatically revoked), and a reference to a support, maintenance, or incident ticket. All members of this group are notified when such an activation occurs, and activation records are available for audit.

Platform Administrators correspond to the [default User-facing Kubernetes role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) `cluster-admin` and to similar CSP roles within environments corresponding to the Aurora platform.


## Platform Developer
Platform Developers design, develop, and validate functionality as well as configuration changes for one or more areas of the Aurora platform. To facilitate rapid iteration, Platform Developers have the same privileges as a Platform Administrator without the activation process or time limit. However, the Platform Developer role only exists in specific Aurora platform development environments designated for this purpose. No Solution Builder workloads run on those environments, and no Solution Builders access them.

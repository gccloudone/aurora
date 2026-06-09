---
title: "Access Control"
linkTitle: "Access Control"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2026-06-08
---

{{< translation-note >}}

Access control is implemented according to the principle of least privilege.

These procedures are reviewed multiple times a year, whenever there are updates to the underlying APIs or organizational processes.

## Kubernetes Access Control

Aurora platform components that access or provide data are identified through non-human accounts:

- **[Kubernetes Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)**
- These accounts are often associated with one or more workload identities on each Cloud Service Provider (CSP):
  - **[Microsoft Entra workload identities](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview)**
- These accounts are granted the minimum necessary sets of permissions for each component's intended function

Kubernetes offers:

- **[Roles and ClusterRoles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole)** to define access.
- **[RoleBindings and ClusterRoleBindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding)** to bind Roles and ClusterRoles to an identity.

The identity can be:

- An individual user or user group from an integrated identity provider (associated with the cluster at the CSP-level).
- A Kubernetes Service Account.

Membership to these groups grants a user role among the following high-level definitions:

- Platform Administrator
- Platform Developer
- Platform Operator
- Security Operations
- Solution Builder

### Platform Administrator

Platform Administrators have full access to the Kubernetes clusters (`cluster-admin`) along with other CSP resources comprising one or more areas of the Aurora platform.

This role is invoked in order to:

- Perform planned maintenance that requires major manual changes. These changes must first be verified using the Platform Developer role in the appropriate testing environment.
- Resolve urgent security and/or operational incidents, including on an on-call basis.

This role can only be activated by a group of designated personnel through privilege escalation procedures such as [Microsoft Entra Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure). Activation requires submitting a justification, a time duration (after which the role is automatically revoked), and a reference to a support, maintenance, or incident ticket. All members of this group are notified when such an activation occurs, and activation records are available for audit.

Platform Administrators correspond to the [default User-facing Kubernetes role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) `cluster-admin` and to similar CSP roles within environments corresponding to the Aurora platform.

### Platform Developer

Platform Developers design, develop, and validate functionality as well as configuration changes for one or more areas of the Aurora platform.

To facilitate rapid iteration, Platform Developers have the same privileges as a Platform Administrator without the activation process or time limit.

However, the Platform Developer role only exists in specific Aurora development environments designated for this purpose.

### Platform Operator

Platform Operators ensure the continual operation of one or more areas of the Aurora platform.

This requires read access to most platform resources and write access for common and low-impact remediation activities.

Two custom ClusterRoles are defined for Platform Operators:

- [`platform-operator-view`](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/platform-operator-view.yaml) for read access
- [`platform-operator-maintenance'](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/platform-operator-maintenance.yaml) for write access.

ClusterRole aggregation to these roles further defines read and write access to specific platform components.

A ClusterRoleBinding binds these ClusterRoles to the Microsoft Entra group designated for the day-to-day activities of the cluster's Platform Operators.

### Security Operations

Designated Security Operations personnel are granted access to the following roles:

- Platform Developer
- Platform Operator

These roles enable Security Operations teams to develop, support, and maintain platform security components, as well as to investigate and resolve potential security incidents effectively.

### Solution Builder

Solution Builders are responsible for designing, developing, deploying, and operating solutions that run on Aurora.

A custom [`solution-builder` ClusterRole](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/rbac/solution-builder.yaml) defines the minimum set of permissions necessary for application development and operations within Kubernetes.

The label `rbac.ssc-spc.gc.ca/aggregate-to-solution-builder: "true"` allows the creation of component-specific Solution Builder ClusterRoles, which can then be defined separately and [aggregated](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles) into this role.

- [(Example of Aggregated ClusterRoles)](https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/stable/aurora-platform/charts/aurora-core/templates/prometheus/rbac.yaml)

A RoleBinding in each Solution Builder namespace binds this ClusterRole to the Microsoft Entra group designated to the application developers/operators for that Solution Builder team.

# Entra Access Control

Azure Entra ID is the centralized identity provider for human users accessing Aurora AKS clusters.

Membership in this group is strictly controlled by Aurora administrators and is subject to the following policy:

- Membership is granted only after clients complete the intake process and are approved for onboarding.
- Membership is revoked when teams formally offboard from Aurora or no longer require cluster access.
- Membership is reviewed on an annual basis to verify that only active, authorized users retain access.

## Groups

Access to Aurora clusters is managed through predefined groups in Azure Entra ID.

Each of these groups has specific roles and permissions tailored to the responsibility of its members:

- **GcPc_RBAC_SSC-Aurora-Owners (Platform Administrator)**:
  Grants full administrative control over all subscriptions and Kubernetes clusters, including `cluster-admin` permissions for managing all resources, configurations, and access policies across the platform.

- **GcPc_RBAC_SSC-Aurora-Developers (Platform Developer)**:
  Grants full administrative control over development subscriptions and Kubernetes clusters, including `cluster-admin` permissions for managing all resources, configurations, and access policies across the platform.

- **GcPc_RBAC_SSC-Aurora-Operators (Platform Operator)**:
  Designed for day-to-day operations personnel, this group grants predefined permissions across both Azure Entra and Kubernetes:
  - **Entra Permissions**:
    - `Reader` permissions within subscriptions, providing comprehensive visibility into all resources and configurations without allowing modifications.
  - **Kubernetes Permissions**:
    - Predefined operational and maintenance roles, enabling tasks such as:
      - Scaling and restarting deployments or stateful sets
      - Viewing logs and accessing cluster-level data for issue diagnosis
      - Performing maintenance activities like creating one-off jobs for CronJobs
      - Viewing secrets and monitoring resource statuses

- **GcPc_RBAC_SSC-Aurora-GenClusterUsers (Solution Builder)**:
  Enables users to securely connect to Kubernetes clusters:
  - Grants the `Azure Kubernetes Service Cluster User Role` permission to generate and download the `kubeconfig` file required for connectivity.

- **GcPc_RBAC_SSC-Aurora-WebTop**:
  Reserved for users who need access to the default WebTop, a centralized user interface for interacting with private Kubernetes clusters.

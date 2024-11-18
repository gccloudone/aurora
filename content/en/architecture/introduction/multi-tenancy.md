---
title: "Multi-Tenancy"
linkTitle: "Multi-Tenancy"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2024-10-25
showToc: true
---

A multi-tenant Kubernetes cluster allows multiple applications or workloads, typically managed by different teams, to coexist within the same cluster. This approach can significantly reduce infrastructure costs and simplify cluster administration by centralizing resource management. However, multi-tenancy introduces complex challenges, particularly around security and resource fairness.

From a security perspective, strong tenant isolation is critical. Each tenant must be logically and functionally isolated to prevent unauthorized access or interference from other tenants. Techniques such as network policies, role-based access control (RBAC), and namespaces are often used to enforce this isolation. However, stronger isolation mechanisms, such as strict pod security policies and dedicated node pools, can increase operational complexity and overhead.

Fairness in resource allocation is another key concern. To ensure equitable resource distribution, tenants must be allocated appropriate resource quotas, preventing any single tenant from monopolizing cluster resources and starving others. Additionally, cost attribution mechanisms must be in place so that each tenant is billed based on their actual resource consumption, ensuring fair usage across the cluster.

There are three common multi-tenancy patterns in Kubernetes:

<div class="mb-400">
<gcds-grid tag="ul" columns="1fr" columns-tablet="1fr 1fr" columns-desktop="1fr 1fr" gap="400" class="hydrated">
<gcds-card
  card-title="Enterprise"
  href="#"
  badge="Enterprise"
  description="Cluster admins have full control over the Kubernetes cluster, with permissions to create, read, update, and delete any object across all namespaces. Their responsibilities include enforcing security policies, setting resource quotas, managing cluster-wide configurations, and provisioning namespaces for tenants. When provisioning a namespace, a cluster admin can delegate administrative rights to namespace admins. In the Aurora Platform, the Aurora Solutions team fulfills the role of cluster admins."
>
</gcds-card>
<gcds-card
  card-title="Kubernetes as a Service (KaaS) / Platform as a Service (PaaS)"
  href="#"
  badge="PaaS"
  description="In this model of cluster multi-tenancy, each tenant (typically a workload or application) is isolated within its own namespace, which is managed by a distinct team of users. In this model, users within the cluster are considered semi-trusted, as they all belong to the enterprise's organization, but tenant isolation and access controls are still necessary to ensure security and operational integrity."
>
</gcds-card>
<gcds-card
  card-title="Software as a Service (SaaS)"
  href="#"
  badge="SaaS"
  description="In this model, the end-user interacts solely with an application, abstracting away the complexities of the underlying Kubernetes infrastructure. The cluster and Kubernetes API server are entirely hidden, with only cluster administrators having access to the API server. This pattern is ideal for users who want to deploy and manage applications without needing extensive knowledge of Kubernetes, thereby lowering the barrier to entry and simplifying the user experience. SaaS platforms provide a highly streamlined environment where users focus solely on the application layer while the platform administrators handle all operational aspects of the underlying infrastructure."
>
</gcds-card>
</gcds-grid>
</div>

At the moment Aurora adheres to the Enterprise multi-tenancy pattern, where users (solution builders) must engage with the Aurora Solutions team, acting as cluster administrators, to onboard onto the platform. To initiate this process, users are required to submit a completed onboarding form, which then provisions a dedicated namespace for the solution. Resource consumption within each namespace is tracked and charged back to the namespace owner (solution owner). This cost attribution is facilitated by the Workload Identifier (WID) label, which is assigned to each namespace. The WID allows the finance team to accurately allocate and charge costs incurred by the workloads within that namespace to the appropriate team, ensuring transparent and efficient cost management across the platform.

## Enterprise Pattern

The main roles involved in the enterprise multi-tenancy pattern are as follows:

<div>
<gcds-grid tag="ul" columns="1fr" columns-tablet="1fr 1fr" columns-desktop="1fr 1fr" gap="400" class="hydrated">
<gcds-card
  card-title="Cluster Admin"
  href="#"
  badge="Cluster"
  description="Cluster admins have full control over the Kubernetes cluster, with permissions to create, read, update, and delete any object across all namespaces. Their responsibilities include enforcing security policies, setting resource quotas, managing cluster-wide configurations, and provisioning namespaces for tenants. When provisioning a namespace, a cluster admin can delegate administrative rights to namespace admins. In the Aurora Platform, the Aurora Solutions team fulfills the role of cluster admins."
>
</gcds-card>
<gcds-card
  card-title="Namespace Admin"
  href="#"
  badge="Namespace"
  description="Namespace admins are responsible for managing access control within their assigned namespaces. Access is typically governed by Identity groups or equivalent in other CSP's, and namespace admins are designated as owners of these groups. They manage the user roles and permissions for their namespace, ensuring that only authorized users can interact with the resources."
>
</gcds-card>
<gcds-card
  card-title="Users"
  href="#"
  badge="User"
  description="Users have permissions to create, read, update, and delete most Kubernetes objects within their assigned namespace. However, certain resource types, such as policies and quotas, remain restricted and can only be managed by higher-level administrators, such as cluster admins or namespace admins."
>
</gcds-card>
</gcds-grid>
</div>

## Isolation

Tenant isolation is crucial for both the security of the data within a Kubernetes cluster and the overall availability of the cluster. By enhancing isolation, the attack surface available to malicious actors is significantly reduced. Additionally, isolation helps mitigate the risk of non-malicious users accidentally exfiltrating sensitive data or impacting other tenants' workloads. Effective tenant isolation incorporates two key properties:

- **Multi-dimensional**: Security must be approached holistically, as attackers typically exploit the weakest link. Isolation should therefore be enforced across multiple dimensions—such as resource, data, and process isolation—rather than focusing solely on a single aspect, like data isolation.
- **Directional**: Isolation isn’t always bidirectional. For instance, while a node can access data from any container running on it, a container cannot access node-level data, maintaining a one-way isolation in this scenario.

In a Kubernetes cluster, there are six layers of isolation (illustrated in the image below). Implementing isolation across multiple layers provides defense in depth. The decision on where to isolate workloads involves balancing the trade-offs between security, cost, and complexity. For the highest level of security when running hostile multi-tenant workloads, isolation at the cluster level is ideal. However, lower levels of isolation can still block many exploits using security features such as Microsoft Defender for Containers, AppArmor, SecComp, Pod Security Admission, and Kubernetes RBAC for nodes.

On Aurora the workloads are isolated at the namespace level and responsibility for the security of the namespace lies with the end-user, ensuring they apply appropriate configurations and controls.

![Kubernetes Isolation Layers](/images/architecture/kubernetes/kubernetes_isolation_layers.png)

Isolation can be applied at both the control plane and data plane levels within a Kubernetes cluster. Control plane isolation ensures that tenants cannot access or interfere with one another's Kubernetes API resources, while data plane isolation guarantees that workloads (e.g., pods) are segregated from each other. Achieving proper isolation in both planes involves addressing several key components. During the design phase, it is critical to consider the following security principles:

- Least Privilege
- Segregation of Duties
- Defense in Depth
- Reduce the Attack Surface
- Limit the Blast Radius

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

Access control is implemented according to the principle of least privilege. This section describes how that is done in Aurora Kubernetes clusters as well as the underlying Cloud Service Providers (CSPs). These procedures are reviewed multiple times a year, whenever there are updates to the underlying APIs or organisational processes.

Aurora platform components that access or provide data are identified through non-human accounts such as Kubernetes Service Accounts and Microsoft Entra workload identities. These accounts are granted the minimum necessary sets of permissions for each component's intended function.

Microsoft Entra ID is the centralized identity provider, with one account per human user. Each account has access to one or more user roles that align with the following high-level definitions:

## Solution Builder
Solution Builders design, develop, deploy, and operate solutions that run on Aurora. They require access to Kubernetes Resources and CustomResources. Typically this access is restricted to a Kubernetes Namespace on one or more Clusters.

Solution Builders may also require access to CSP resources such as managed databases and storage accounts. This is outside the scope of Aurora's access control and is established according to the processes of the corresponding Infrastructure-as-a-Service service lines.

## Platform Operator
Platform Operators ensure the continual operation of one or more areas of the Aurora platform. This requires read access to most platform resources, excluding confidential information such as Secrets. This also requires write access for common and low-impact remediation activities, such as restarting specific types of CSP resources. 

> Platform Operator write access is very limited. Whenever possible, changes to Aurora are effected via Infrastructure/Configuration-as-Code and corresponding automated CI/CD processes. Higher impact manual remediation requires escalation to the Platform Administrator role.

## Platform Administrator
Platform Administrators have full access to the Kubernetes clusters and other CSP resources comprising one or more areas of the Aurora platform. This role is only accessed via tracked and justified privilege escalation processes. 

It is invoked in order to:
- Perform planned maintenance that requires major manual changes. These changes must first be verified using the Platform Developer role in the appropriate testing environment.
- Resolve urgent security and/or operational incidents, including on an on-call basis.

## Platform Developer
Platform Developers design, develop, and implement one or more areas of the Aurora platform. They have full access to the corresponding platform development environments in order to create, improve, and extend new platform features, as well as to validate platform functionality and configuration changes. 

> These platform development environments exist **only** for this purpose: no Solution Builder workloads run on these environments, and no Solution Builders access them.
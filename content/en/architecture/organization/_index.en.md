---
title: "Organization"
linkTitle: "Organization"
type: "architecture"
weight: 10
draft: true
lang: "en"
date: 2024-10-21
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Aurora is designed to operate seamlessly across both on-premises and managed cloud providers' Kubernetes offerings. It can incorporate a range of resources, such as Kubernetes clusters, storage solutions, key management services, and networking components. Efficient resource management is crucial due to the scale of the Aurora project across the Government of Canada landscape.

To achieve this goal, we can make use of the following strategies:

- **[Naming Conventions]({{< relref "/architecture/organization/naming-convention/" >}})**: Resource names should clearly convey their purpose and usage. Including relevant information in names provides better organization and quick identification across cloud platforms.
- **Resource Hierarchy**: Organizing resources hierarchically, whether through resource groups, projects, or organizational units, provides a clear, manageable structure. Logical containers help maintain resource grouping and facilitate straightforward management.
- **Tags**: Tags allow for the categorization and organization of resources with key-value pairs that can be leveraged for tracking costs, ownership, environment, and compliance across different cloud environments. This tagging strategy supports efficient resource management and filtering in tools like the Microsoft Graph API, AWS Resource Groups Tagging API, or GCP’s Label Manager.

It is important to design a naming and resource hierarchy strategy from the outset as resource names are often immutable and changing resource hierarchy can cause temporary disruptions.

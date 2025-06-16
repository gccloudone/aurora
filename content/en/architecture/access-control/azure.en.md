---
title: "Azure"
linkTitle: "Azure"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2025-05-29
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Aurora platform components that communicate over Azure may have associated [Microsoft Entra workload identities](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview). Permissions, such as for available APIs and tokens, are assigned to each individual identity according to the minimum requirement for the functionality of the component.

Azure access control for Aurora's human users is implemented in the following ways:

## Solution Builder

Solution Builders are members of one or more [Microsoft Entra groups](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-manage-groups) corresponding to their team. The Azure resources they have access to are determined by that team in collaboration with any relevant Infrastructure-as-a-Service service lines.

## Platform Operator

Platform Operators have access to a custom role within the Azure management groups corresponding to one or more Aurora platforms.

This custom role has the following permissions:

| Component                   | Action            | Purpose                                            | 
| :-------------------------- | :---------------- | :------------------------------------------------- | 
| All                         | Read              | Gather information for troubleshooting             | 
| Virtual Routers             | Learned Routes    | Get learned BGP routes from Azure route servers    | 
| Virtual Routers             | Advertised Routes | Get advertised BGP routes from Azure route servers | 
| Managed Clusters            | Abort             | Cancel the last operation on AKS clusters          | 
| Managed Cluster Agent Pools | Abort             | Cancel the last operation on AKS node pools        | 

## Platform Administrator

The Platform Administrator identity can be accessed by designated personnel by using [Microsoft Entra Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure) to activate their membership in the corresponding Microsoft Entra group. Activation requires submitting a justification, a time duration, and a reference to a support, maintenance, or incident ticket. All members of this group are notified by email when such an activation occurs, and activation records are available for audit in Azure.

This grants access to the built-in Azure roles [Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) and [Role Based Access Control Administrator](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#role-based-access-control-administrator) within the management groups corresponding to one or more Aurora platforms. 

## Platform Developer

The Platform Developer identity has the same roles as the Platform Administrator, but only within specific Aurora platform development subscriptions. To facilitate rapid development and testing, privilege escalation is not required within these environments.
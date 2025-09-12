---
title: "Common Naming Convention"
linkTitle: "Common"
type: "architecture"
weight: 15
draft: true
lang: "en"
date: 2024-10-21
showToc: true
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Adopting a consistent naming convention across resource types is essential for maintaining a structured and understandable cloud environment. Consistent naming enables logical mapping and easy association of resources within and across components, supporting smooth interoperability and integration. It also enhances collaboration and communication among developers by providing a shared reference framework. Therefore, using a unified naming convention across as many resource types as possible is recommended.

In the following sections, we will outline the fields included in the common naming convention, the recommended order, and specify the given values for some of them in the context of the Aurora Platform.

## Environment Types

The context of the Aurora Platform (AUR) influences the appropriate values for naming convention fields. While values for fields such as `Region`, `UserDefined`, `ResourceType`, and `Instance` are straightforward, the `Project` and `Environment` fields require more consideration due to the varied definitions of environment and the presence of multiple Kubernetes cluster types within the Aurora Platform.

To clarify, the Aurora Platform consists of two primary environment types:

- **Solution Builder**: Solution Builders need Software Development Life Cycle (SDLC) environments to thoroughly test applications and Kubernetes configurations before deploying to production. As outlined in the subscription section, separate Kubernetes clusters are designated for development, testing, quality assurance, user acceptance testing, and production, organized across two subscriptions: one for non-production clusters and one for production clusters.
- **Platform Operator**: For Platform Operators, the clusters used by Solution Builders are considered production environments. Platform Operators require SDLC environments specifically for the Aurora Platform itself, which include both development and production environments.

In addition, several types of Kubernetes clusters are used in Auror.pilcrow

- **SDLC**: Separate SDLC clusters exist for both Solution Builders and Platform Operators.
- **Ingress & Management**: The Ingress and Management clusters support the SDLC clusters, with one instance of each type for each Platform Operator environment.

Given this context, two approaches for assigning values to the `project` and `environment` fields have been identified with the separate project and environment fields being the chosen option.

With respect to the project field itself we use an abbreviation that reflects the cluster type purpose.

- Management cluster: `mgmt`
- Ingress cluster: `ingress`
- Solution Builder SDLC cluster: `gen`
- Aurora Solutions cluster: `aur`

### Separate Project and Environment Fields

With this setup, the environment field specifies the environment for each configured project (cluster type). For example, using these field definitions, the names of virtual networks created in the Canada Central region for each planned cluster would be as follows:

- AURDev subscription
  - `aur-dev-cc-00-vnet`
  - `aur-canary-cc-00-vnet`
  - `ingress-dev-cc-00-vnet`
  - `mgmt-dev-cc-00-vnet`
- AURNonProd subscription
  - `gen-dev-cc-00-vnet`
  - `gen-test-cc-00-vnet`
  - `gen-uat-cc-00-vnet`
-AURProd subscription
  - `ingress-prod-cc-00-vnet`
  - `mgmt-prod-cc-00-vnet`
  - `gen-qa-cc-00-vnet`
  - `gen-prod-cc-00-vnet`

The aur project type is specifically used in the AURDev subscription, while gen is applied in other subscriptions. This distinction prevents duplicate resource names across the tenant since without it the dev clusters in both AURDev and AURNonProd subscriptions would have identical names.

Using the aur project type, we clearly indicate that the cluster is reserved for the Aurora Solutions Team, which will be used to develop and test new features for the Aurora Platform before deploying them to Solution Builders' clusters in the AURNonProd and AURProd subscriptions.

### Combined Project and Environment Fields

With this setup, the environment field combines both the project (cluster type) and environment fields. With the note that for the platform operator environment we use the abbreviations `n` for non-production and `p` for production. With these definitions, the virtual network names created in the Canada Central region for each planned cluster would be as follows:

- AURDev subscription
  - `aur-ndev-cc-00-vnet`
  - `aur-ncanary-cc-00-vnet`
- AURNonProd subscription
  - `aur-pdev-cc-00-vnet`
  - `aur-ptest-cc-00-vnet`
  - `aur-puat-cc-00-vnet`
- AURProd subscription
  - `aur-ingress-cc-00-vnet`
  - `aur-mgmt-cc-00-vnet`
  - `aur-pqa-cc-00-vnet`
  - `aur-pprod-cc-00-vnet`

## Field Ordering

There are multiple valid approaches to order the fields in the naming convention. The best method depends on specific priorities and considerations:

- **Consistency**: Most resources in the tenant currently follow the convention of specifying the resource type last.
- **Sorting**: When listing resource names, it is desirable to group related resources together. This encourages placing common fields at the beginning.
- **Identifiable**: Since many languages are read from left to right, placing the unique fields first makes the names more easily identifiable. Alternatively, placing the unique field last is also a viable option.
- **Query Friendly**: The efficiency of querying resources is essential. Placing unique fields first enables faster querying.

Here are the patterns that were identified given these constraints:

| **Pattern Name**                                             | **Pattern**                                                              |
|--------------------------------------------------------------|--------------------------------------------------------------------------|
| Most Unique Fields First                                     | {userDefined}-{project}-{environment}-{region}-{instance}-{resourceType} |
| Resource Type Followed by UserDefined Field                  | {resourceType}-{userDefined}-{project}-{environment}-{region}-{instance} |
| Matryoshka Doll (order by frequency)                         | {resourceType}-{project}-{environment}-{region}-{userDefined}-{instance} |
| Boilerplate Fields First & Resource Type Last                | {project}-{environment}-{region}-{instance}-{userDefined}-{resourceType} |
| Boilerplate Fields First & Two Most Identifiable Fields Last | {project}-{environment}-{region}-{instance}-{resourceType}-{userDefined} |

<div class="mb-400"></div>

After carefully considering the advantages and disadvantages, it has been decided that the **Boilerplate Fields First & Two Most Identifiable Fields Last** method will be used.

## Character Length Limitations

The maximum character length of each field within the Common Naming Convention shall be the following:

| Project | Environment | Region | Instance | Resource Type | User Defined |
|:-------:|:-----------:|:------:|:--------:|:-------------:|:------------:|
|    7    |      6      |   2    |    2     |       4       |      14      |

<div class="mb-400"></div>

Consult the following for an illustrative example:

- **Project**: 7 (ex: ingress)
- **Environment**: 6 (ex: canary)
- **Region**: 2 (ex: cc)
- **Instance**: 2 (ex: 00)
- **Resource type**: 4 (ex: psql)
- **User Defined**: 14 (optional)

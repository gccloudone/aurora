---
title: "Alternative Naming Convention"
linkTitle: "Alternative"
type: "architecture"
weight: 20
draft: true
lang: "en"
date: 2024-10-21
showToc: true
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Creating a consistent naming convention across resource types is challenging due to each Cloud Service Provider's unique naming rules and restrictions. These inconsistencies make a universal convention complex, but a standardized approach remains achievable by setting clear character limits and field guidelines.

- **Azure**: Azure provides detailed naming rules and restrictions for each resource type, including specific character limits and allowable symbols. By aligning with Azure’s naming standards, we ensure compatibility with the most restrictive resources while promoting clarity and uniformity across environments.
- **Amazon Web Services**: AWS has varying naming restrictions across services, such as EC2 and S3, with character limits and permitted symbols differing by resource type. Although AWS generally imposes fewer constraints than Azure, we will align AWS naming with Azure’s conventions where feasible to maintain consistency.
- **Google Cloud Platform**: GCP enforces its own naming rules, with specific requirements for services like Compute Engine and Cloud Storage, typically allowing lowercase letters, numbers, and hyphens. Where practical, GCP resource names will follow Azure’s conventions to create a unified naming structure across CSPs.
- **Oracle Cloud Infrastructure (OCI)**: OCI recommends designing and adhering to a set of naming conventions for all resources to ensure consistency and clarity. While specific character limits and allowable symbols can vary by resource type, a common practice is to use intuitive, standardized abbreviations and separate name segments with hyphens.
- **IBM Cloud**: IBM Cloud employs Cloud Resource Names (CRNs) to uniquely identify resources. CRNs are structured with segments separated by colons, each representing specific information about the resource, such as service name, location, and instance ID. While CRNs are system-generated, it's important to follow IBM's guidelines for resource naming to ensure clarity and avoid conflicts.

## Resource Attributes

All resource types have a scope within which names must be unique. This section defines the naming convention for resource attributes, which must be unique within their parent resource’s scope. For example, subnets must have unique names within the virtual network they belong to.

The naming convention for resource attributes is as follows:

- {Purpose}

Resource attributes should be named according to their purpose, using descriptive terms or components. However, names should exclude common fields listed in the Fields section. The reasoning for this is explained in the Naming Inheritance by Scope Level section. Resource attributes implicitly inherit context from their parent resources, as locating an attribute first requires querying the parent resource. Omitting redundant information is acceptable since the parent resource’s name provides necessary context.

Example names for attributes of the virtual network `ingress-dev-cc-vnet` might include:

- **Subnets**: `system`, `general`, `gateway`, `loadbalancer`, `infrastructure`, `RouteServerSubnet`
- **Virtual Network Peering**: `hub-vnet` (the name of the peered virtual network)

### Character Length Limitations

Generally, the character length of resource attribute names has no limitation since they have no impact on the names of other resources. The only known exemption is subnets which has a maximum character length of 20 that must be adhered to.

## Restricted Resource

Complicating the naming convention design some resource types have specific character restrictions or require globally unique names. The restrictions include a set of valid characters and a maximum length the resource name can be. The inconsistencies in the restrictions across the resource types make creating a common convention challenging. Nevertheless, it is still possible by limiting the character variations that can be used within resource names and limiting the maximum length of fields such that even the most restrictive resource types can adhere to the devised naming convention.

For instance, Storage Accounts and Key Vaults have a maximum character limit of 24, and certain resources require names unique across all of a cloud tenant. These cases require special consideration beyond the common naming convention.

The naming convention for such resources is as follows:

- {resourceType}{randomCharacters}{userDefined}

Each element is defined as follows:

- **resourceType**: Represents the type of the resource.
- **randomCharacters**: This field should contain a series of random characters to ensure uniqueness. Storage Accounts and Key Vaults must consist of 6 characters.
- **userDefined**: This field should be used to indicate the purpose of the resource. For Storage Accounts and Key Vaults, it should be at most 16 characters in length.

Here are some examples to illustrate the convention:

- Storage Account: `sa123456velero`
- Key Vault: `kv123456encryption`
- Container Registry: `cr12345aur`

Tags indicating environment and region can be added for further identification.

### Valid Characters

To ensure compatibility across all resource types, the characters used in names must be universally valid. This section outlines these character requirements.

A summary of the character rules based on resource naming rules for each major Cloud Service Provider (CSP) is provided below:

- **Azure**: Azure enforces [specific naming rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rule), including restrictions on character case (often lowercase only) and permitted symbols. Some resource types must start with a letter and end with an alphanumeric character. Hyphens are typically allowed as delimiters but cannot appear consecutively, nor can names start or end with a hyphen.
- **Amazon Web Services**: AWS allows alphanumeric characters across most resource types, with hyphens permitted as delimiters. Restrictions vary by service: for instance, S3 buckets require lowercase characters, while other resources may permit uppercase letters. Generally, AWS follows more lenient character rules but aligns closely with Azure's guidelines for consistency.
- **Google Cloud Platform (GCP)**: GCP allows lowercase alphanumeric characters across most resource names, with hyphens frequently accepted as field delimiters. Names typically must start with a letter, and GCP restricts some resource types to specific character sets (e.g., Compute Engine VM names). This makes GCP’s rules relatively aligned with those of Azure and AWS.

Given these guidelines, resource names will use only lowercase alphanumeric characters to ensure compatibility across providers. Names must begin with a letter, and hyphens will be used as delimiters for fields within resource types that permit them. If hyphens are disallowed for a specific resource type, they will be omitted.

### Character Length Limitations

The maximum character length of each field within the Restricted Naming Convention shall be the following:

| Resource Type | Random Characters | User Defined |
|:-------------:|:-----------------:|:------------:|
|       2       |         6         |      16      |

The field character count calculation & reasoning are the following:

- **Resource Type**: 2 (ex: sa)
- **Random Characters**: 6 (ex: 123456)
- **User Defined**: 16 (ex: velero)

The Random Characters field is used to reduce the chance of name conflicts. This is important since the resource types that use this naming convention may have a global scope. Six characters for this field should be sufficient to achieve this aim. If the random characters only comprise digits, there are 1,000,000 permutations.

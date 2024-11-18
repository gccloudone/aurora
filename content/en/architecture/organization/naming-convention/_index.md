---
title: "Naming Convention"
linkTitle: "Naming"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2024-10-21
showToc: true
---

The name of a cloud resource is crucial for effective identification. Establishing a consistent naming convention across cloud providers enhances clarity and resource management.

The Aurora team follows a naming convention with these key goals:

- **Indicate resource use and purpose**: Resource names should clearly indicate their intended use to prevent accidental actions and enable quick location.
- **Enable sorting and filtering**: Resource names should support easy sorting and filtering across cloud platforms.
- **Ensure uniqueness**: Each resource name should be unique within its enterprise tenant to avoid conflicts and confusion.
- **Adhere to provider-specific naming restrictions**: Resource names must follow the specific naming constraints set by each cloud provider:
  - **[Azure Naming Restrictions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)**
  - *Google Cloud Naming Constraints* (TODO)
  - *AWS Naming Constraints* (TODO)
- **Promote consistency**: Using a unified naming convention across all resources, regardless of type, improves readability and streamlines resource management.

The following sections will outline the key elements in Aurora’s naming conventions and provide specific guidelines for each resource type.

## Field Approach

A common field approach has been leveraged to align with the goals of the naming convention, including indicating the purpose of the resource, facilitating filtering and sorting, and striving for uniqueness within the respective tenant.

The following common fields can be included in a resource name:

- **User-defined** (optional): This field can be used to help identify the purpose of the resource. For example, the value for this field may be "velero" for a [Velero](https://velero.io/) storage account.
- **Project**: The project the resource belongs to. An acronym or short-form version of the project name should be used if possible.
- **Environment**: The stage of the development lifecycle that the resource belongs to (ex: dev, test, qa, and prod).
- **Region**: The region where the resource is deployed. The value of this field shall be the region's acronym to reduce the number of characters used. For example, if the resource is deployed in Canada Central, the value for the region field shall be "cc."
- **Instance**: The instance count is for a specific resource to identify more than one resource that has the same naming convention. Examples are "01" and "02". An example of a use case where this might be useful is if a series of VMs with the same purpose is required.
- **Resource Type**: An abbreviation that represents the resource or asset type.

For consistency and readability, the fields should be separated by hyphens, and all characters should be lowercase.

It is important to mention that some resource types may not have all of the above fields (referred to as the common naming convention).

### Abbreviations for Resource Types

The following table provides abbreviations for some common resource types when specifying the **Resource Type** field.

| Abbreviation |            Resource            |
|:------------:|:------------------------------:|
|      rg      |         Resource Group         |
|     vnet     |        Virtual Network         |
|      rt      |          Route Table           |
|     nsg      |     Network Security Group     |
|     pip      |       Public IP address        |
|      fw      |            Firewall            |
|     aks      |    Azure Kubernetes Service    |
|      cr      |       Container Registry       |
|      sa      |        Storage Account         |
|      kv      |           Key Vault            |
|     des      |      Disk Encryption Set       |
|      rs      |          Route Server          |
|     msi      | User-Assigned Managed Identity |
|      pe      |        Private Endpoint        |

### Abbreviations for Environment Types

The following table lists some common environments and their corresponding abbreviation that can be set for the **Environment** field.

|      Environments       | Abbreviation |
|:-----------------------:|:------------:|
|       Development       |     dev      |
|          Test           |     test     |
|    Quality Assurance    |      qa      |
| User Acceptance testing |     uat      |
|         Canary          |    canary    |
|       Production        |     prod     |

## Naming Inheritance by Scope Level

When organizing resources within containers such as resource groups, there are two approaches to naming inheritance:

- **Explicit Inheritance**: With explicit inheritance, child resources adopt the same common fields as their parent resource, providing consistency and clear identification within the container. This approach makes it easier to understand each child resource’s purpose and context through the parent’s naming convention.
- **Implicit Inheritance**: With implicit inheritance, child resources do not necessarily inherit all fields from the parent resource. This approach reduces resource name length—especially useful for resource types with long names. Implicit inheritance maintains some organization while keeping names concise.

The decision on whether to use explicit or implicit naming inheritance at each scope level (subscription, resource group, and resource) should be based on the project’s specific requirements. Factors such as desired consistency, need for precise identification, and impact on character limits should be considered.

### Subscription

The fields within a subscription are:

- department
- environment (non-prod or prod)
- project/app
- user-defined string (UDS)

In the Aurora Platform, child resources of a subscription will implicitly inherit the project/app and department fields from the subscription's name:

- project: Aurora Platform (AUR)
- department: Shared Services Canada (SSC)

These characteristics will be implicitly inherited because the goal is to have resource names that are concise yet informative. The project and department fields are considered less critical to be explicitly specified in the names of resources within the subscription.

<gcds-alert alert-role="info" container="full" heading="Drawback of this decision" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>One drawback of this decision is that it increases the likelihood of resource name collisions within the tenant. To mitigate this, it is recommended that users filter the subscription when locating resources within the portal, ensuring that only resources from the desired subscription are returned.</gcds-text>
</gcds-alert>

### Resource Group

When naming resources within a resource group, use the fields outlined in the [fields](#fields) section, including key fields where child resources should explicitly inherit these fields from their resource group:

- userDefined/purpose
- project
- environment
- region

Two main considerations support this approach:

- **Reducing Name Conflicts**: By inheriting fields from the resource group name, potential name conflicts are minimized, especially if resource names must be unique beyond the resource group level. Although no relevant resource types currently require unique names at the subscription level, this approach provides flexibility for future needs.
- **Simplifying Resource Querying and Identification**: Without inherited fields, identical resource names could exist within a subscription, complicating queries and identification. Users would need to locate the resource group first, adding extra steps and increasing the risk of mistakenly selecting the wrong resource.

For these reasons, it’s recommended that child resources inherit fields from the resource group, ensuring easier querying, locating, and accurate identification within the subscription.

### Resource Types

For resource types with attributes, such as containers within a storage account or subnets within a virtual network, these attributes should implicitly inherit common fields from their parent resource’s name. This approach is logical, as resource attributes cannot exist independently of their parent.

Implicitly inheriting the common fields from the parent resource’s name promotes consistency and reinforces the contextual relationship between the parent and its attributes. Since resource attributes are inherently linked to their parent, this practice prevents issues with querying, filtering, or sorting.

To locate a resource attribute, the parent resource should be identified first, as attributes are accessed within the parent’s context. This sequential process minimizes the risk of confusion or misidentification when managing resource attributes.

## Types of Naming Conventions

While a consistent naming convention for all resource types is ideal, this is challenging due to the need to avoid naming conflicts and adhere to resource-specific naming restrictions.

A balance between flexibility and structure is required; leaning toward flexibility results in conventions that are simpler and more consistent:

- Common Naming Convention: Used by the majority of resource types and follows the common fields and guidelines outlined previously
- Other Naming Convention: Used where the common naming convention can't properly be applied due to constraints
  - Resource Attributes: Applied to resource attributes, such as subnets within an virtual network. Resource attribute names implicitly inherit common fields from their parent resource’s name
  - Restricted Resources: For resource types that are namespaced at the global level or have strict character restrictions, requiring special considerations for naming

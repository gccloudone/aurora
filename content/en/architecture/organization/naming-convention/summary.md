---
title: "Summary"
linkTitle: "Summary"
type: "architecture"
weight: 20
draft: true
lang: "en"
date: 2024-10-21
showToc: true
---

In summary, all of the naming conventions devised for resources are outlined in the table below:

| Naming Convention  | Pattern                                                                  | Comments                                                                                                                                                                                                                                                                                                                                                                |
|:------------------:|--------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|       Common       | {project}-{environment}-{region}-{instance}-{resourceType}-{userDefined} | - The userDefined field is optional<br>- The project field can be either ingress, mgmt, gen, or cns for AUR related resources<br>- The meaning of each field is defined in the Fields section<br>- The order of each field is defined within the Field Ordering section<br>- The max character count per field is defined within the Character Count per Field section. |
| Resource Attribute | {userDefined}                                                            | - Refer to the Resource Attribute Naming Convention section for more details                                                                                                                                                                                                                                                                                            |
|       Global       | {resourceType}{randomCharacters}{userDefined}                            | - For use when the common naming convention can't be used & the other conventions don't apply<br>- Reasoning for using this convention may include character count restrictions or naming conflict concerns                                                                                                                                                             |

<div class="mb-400"></div>

Across all naming conventions, all names must be lowercase alphanumeric characters and follow character limits given by the respective cloud service provider.

Notice that the Global naming convention doesn't have the project, environment, region, or instance fields. This is because there are cases where the resource types categorized into this convention have a maximum character length of 24. As such, it may be difficult to distinguish between the same kind of resources across different environments.

## Resource Type Mapping

The following table maps network-related resource types to the naming convention they should use.

The example column assumes the resource is associated with the Development SDLC Kubernetes cluster within a given subscription.

|        Resource         |     Scope      | Max Characters | Naming Convention | Example                     |
|:-----------------------:|:--------------:|:--------------:|:-----------------:|-----------------------------|
|     Virtual Network     | resource group |       64       |      Common       | gen-dev-cc-00-vnet          |
|       Route Table       | resource group |       80       |      Common       | gen-dev-cc-00-rt            |
| Network Security Group  | resource group |       80       |      Common       | gen-dev-cc-00-nsg-system    |
|         Subnet          |    resource    |       80       |     Attribute     | system                      |
| Virtual Network Peering |    resource    |       80       |     Attribute     | mazcc-vnet                  |
|    Private Endpoint     | resource group |       64       |      Common       | gen-dev-cc-00-pe-encryption |
| Service Endpoint Policy | resource group |       80       |      Common       | gen-dev-cc-00-sep-general   |
|      Load Balancer      | resource group |       80       |      Common       | gen-dev-cc-00-lb-external   |
|      Route Server       | resource group |       80       |      Common       | gen-dev-cc-00-rs            |
|    Public IP Address    | resource group |       80       |      Common       | gen-dev-cc-00-pip-rs        |

<div class="mb-400"></div>

The following table maps resource types not covered within the above table to the naming convention they should use.

|            Resource            |     Scope      | Max Characters | Naming Convention | Example                       |
|:------------------------------:|:--------------:|:--------------:|:-----------------:|-------------------------------|
|         Resource Group         |  subscription  |       90       |      Common       | gen-dev-cc-00-rg              |
|        Storage Account         |     global     |       24       |      Global       | velero12345678sa              |
|           Key Vault            |     global     |       24       |      Global       | encryption12345678kv          |
|      Disk Encryption Set       | resource group |       80       |      Common       | gen-dev-cc-00-des-encryption  |
|       Container Registry       |     global     |       63       |      Global       | aur12345678cr                 |
|       PostgreSQL Server        |     global     |       63       |      Global       | gen-dev-cc-00-psql-jfrog      |
|    Kubernetes Service    | resource group |       63       |      Common       | gen-dev-cc-00-ks             |
| User-Assigned Managed Identity | resource group |      128       |      Common       | gen-dev-cc-00-msi-ks-kubelet |

<div class="mb-400"></div>

## Illustrative Example

The following is a diagram of some of the AURDev subscriptions, some of the resource groups within it, and the names of the resources within the resource group. Only the resources associated with the Development SDLC AKS cluster are displayed.

![Naming Convention Example](/images/architecture/organization/naming-convention-example.svg)

The following list provides an overview of resource names associated with other clusters and displays the virtual network names created in the Canada Central region, organized by subscription.

- AURDev subscription
  - cns-dev-cc-00-vnet
  - gen-canary-cc-00-vnet
  - ingress-dev-cc-00-vnet
  - mgmt-dev-cc-00-vnet
- AURNonProd subscription
  - gen-dev-cc-00-vnet
  - gen-test-cc-00-vnet
  - gen-uat-cc-00-vnet
- AURProd subscription
  - ingress-prod-cc-00-vnet
  - mgmt-prod-cc-00-vnet
  - gen-qa-cc-00-vnet
  - gen-prod-cc-00-vnet

These names all follow the decisions made in the Common Naming Convention section.

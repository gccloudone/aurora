---
title: "Lexicon"
linkTitle: "Lexicon"
weight: 5
aliases: ["/team/lexicon/"]
date: 2025-01-01
draft: false
translationKey: "lexicon"
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

In the effort of align vocabulary and ensuring that documents and discussions are clear and concise, this Lexicon has been developed for the Aurora Team and Technical Advisory Group(s).

Where applicable, the Lexicon will be aligned at a higher organizational structure. The creation and coordination of this Lexicon will be promoted to ensure that GC Cloud One has cohesive definitions of concepts.

Certain terms may be sourced from [Termium Plus](https://www.btb.termiumplus.gc.ca/), or from it's successor [Language Navigator](https://www.noslangues-ourlanguages.gc.ca/en/navigateur-navigator). New terms should be presented to the Technical Advisory Group (TAG) to ensure a baseline understanding is established.

## Platform

#### Special Interest Groups (SIGs)

Special Interest Groups (SIGs) are groups of developers who share a common interest, goal, and/or problem set within a larger community. In the context of the Aurora team, SIGs are comprised of experts who collaborate to develop and improve the Aurora Platform.

#### Technical Advisory Groups (TAGs)

Technical Advisory Groups (TAGs) are communities of practice that focus on specific technical domains or areas of expertise within the larger Aurora team. TAGs bring together thought leaders, practitioners, and specialists who provide guidance, define best practices, and drive innovation to support and enhance the Aurora Platform. These groups play a key role in ensuring that technical decisions align with the overall goals and standards of the community.

#### Solution Builder

Represents both traditional Information Technology (IT) users, such as application developers as well as non-traditional IT users, such as data scientists and data analysts. The term "solution" is used instead "app" or "system" to better reflect the range of solutions that could be available on Aurora. For example, this can include large-scale solutions for corporate initiatives as well as smaller solutions that may be standalone and serve very specific purposes.

#### Horizontal Services

Term used to represent applications or tools that formulate the CI/CD development environment for solution builders. These services are Client facing services that facilitate CI/CD development within the Aurora environment.

Services include:

- GitLab
- Artifactory + XRay
- Sonarqube

#### Citizen Developer

This term was coined through the collaboration between Data Scientists. Citizen developers are individuals who create and customize existing software programs or applications to suit the specific needs of users, and to improve operational efficiency. Citizen developers can help IT meet the demand for building applications faster with fewer resources.

- These developers might not have formal development training.
- While these members are included as part of the IT department, their positions differ slightly from classical IT positions.

You may see this term referenced during divisional meetings, activties, and etc. From the Aurora perspective, citizen developers are considered as solution builders.

## Support

#### Operational Support

Operational support relates to the day-to-day operations of the Aurora Platform. This includes tasks such as: namespace creation, access control, node/platform troubleshooting, platform maintenance.

Operational and support requests are submitted through Helix.

#### Application Support

Support for application teams outside of core platform components. This includes CI/CD setup, Helm charts, application architecture, etc.

Operational and support requests are submitted through Helix.

## Workload Migration

#### Path Definitions

Solution Builder teams looking to migrate their solution to Aurora follow specific migration paths, as defined by the department. These paths will often be referenced throughout workload migration efforts and activities.

- **Path 1:** Cloud Native Applications
    - Solution Builder teams implement their applications as pure cloud native solutions.
        - New solution implementation, levearging cloud native technologies: K8s, Helm, etc.
        - Development and testing performed directly within Aurora.

- **Path 2:** CI/CD Pipeline (Hybrid)
    - Solution Builder teams leverage CI/CD pipeline capabilities to migrate their solution towards a Cloud Native solution.
        - Applications are treated individually, and analyzed to see how they can be migrated.
        - Hybrid approach: certain components rebuilt using CI/CD capabilities, other components migrated (lift-and-shift).

- **Path 3:** Relocation (Lift-and-Shift)
    - Solutions identified in this path will be migrated as-is to the cloud environment.
        - Existing solution will be migrated to virtual infrastructure using a lift-and-shift method.
        - Cloud optimization required to leverage cloud capatilibites.

## Acronyms

**AKS:** Azure Kubernetes Service

**ATO:** Authority to Operate

**AUR:** Aurora Platform

**BRM:** Business Requirements Management division

**CNAS:** Cloud Native Application Consultancy

**CNCF:** [Cloud Native Computing Foundation](https://www.cncf.io/)

**iATO:** interim Authority to Operate

**ITSLM:** IT Solution and Lifecycle Management division within SSC

**OCI:** [Open Container Initiative](https://opencontainers.org/)

**SA&A:** Security Assessment and Authorization

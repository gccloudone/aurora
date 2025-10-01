---
title: "Contingency Plan"
linkTitle: "Contingency Plan"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2025-09-16
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## Context

The following page discusses what Aurora does for its contingency planning in anticipation of system failures. You will also find information on this page relating to Aurora's resolution times and its priorities for resolving incidents & issues.

## Contingency Overview

The primary objective of Aurora's contingency plan is to ensure the **continuous 24/7 operation of the Aurora platform**, even during maintenance windows. Aurora is committed to maintaining uninterrupted service ensuring clients can rely on the platform for consistent availability. Aurora is **not** responsible for the 100% uptime of client workloads and it is the responsibility of clients to follow Kubernetes best practices such as using Pod Disruption Budgets to improve the availability of their workload.

Aurora achieves this objective without having to compromise or deteriorate Aurora's security & safeguards through the following ways:

- **Architectural resiliency**: Core components of the Aurora platform are deployed in high availability (HA) configurations to ensure system uptime and fault tolerance.
- **Client support**: Dedicated support is available during **business hours** to assist clients with issues related to their workloads.
- **Operational readiness**: A comprehensive set of <gcds-link href="{{< relref "/team/standard-operating-procedures" >}}">Standard Operating Procedures (SOPs)</gcds-link> and <gcds-link href="{{< relref "/team/monitoring-alerts/" >}}">alert runbooks</gcds-link> is maintained to enable quick incident troubleshooting & resolution by the Aurora team.

> Business hours are defined as 9:00 AM – 5:00 PM EST, Monday to Friday.

This plan helps Aurora meet the targets for the resolution times, as listed below.

### Target Resolution Times

> **Note:** The following resolution times apply to issues impacting the Aurora platform itself. Support for client workloads follows a separate process and is provided on a best-effort basis during business hours.

| **Severity Level** | Description                                         | **Target Resolution Time (90% of the time)** |
|--------------------|-----------------------------------------------------|----------------------------------------------|
| Critical           | Critical issue currently affecting all users, including system unavailability and major data integrity or security issues. | 4 hours |
| High               | Loss of functionality of non-critical components or a warning of imminent critical component failure. | 8 hours |
| Medium             | Significant & persistent performance issues or some bug affecting some but not all users. | 2 business days |
| Low                | Minor issues with minimal impact on system functionality or user workloads. | 6 business days |

> The **Target Resolution Time** is the average time taken to restore a service if an incident occurs. When a situation cannot be resolved within the target time, notifications will be provided to partners.

Priority is given first to platform issues and then to client issues based on severity level and whether the application affected is in the CBAS.

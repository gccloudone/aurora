---
title: "Issue Tracking"
linkTitle: "Issue Tracking"
weight: 5
aliases: ["/team/sop/issue-tracking"]
date: 2025-11-01
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Aurora uses multiple systems to manage issues, requests, and deliverables. Each system serves a distinct purpose depending on classification, audience, and type of work.

This document explains **where each issue belongs** and how the systems interact.

---

## 1. Overview

| System           | Primary Use                                                                        | Example                                                                |
|------------------|------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| **GitHub**       | Public and internal development tracking for Aurora’s open-source and roadmap work | Feature requests, platform component updates, roadmap epics            |
| **Helix (ITSM)** | Client support and service management                                              | Department service requests, incidents, or support tickets             |
| **Jira**         | Internal work involving protected or classified information                        | Security Impact Assessment (SIA), UX research, client-specific details |

---

## 2. Jira

Jira remains the **system of record** for any work that involves:

- Protected or classified information (e.g., environment-specific configurations, client identifiers)
- Security, privacy, or compliance documentation (e.g., SIA, CBR, ATO process)
- UX research and internal testing involving GC staff
- Internal sprint tracking for sensitive or pre-release items

➡️ **Rule of thumb:** If an issue cannot be published publicly or may contain departmental information, it belongs in **Jira**.

---

## 3. GitHub

GitHub is the **primary workspace for open and unclassified development** under the Aurora initiative.
It is where collaboration, transparency, and cross-department contribution happen across SSC and partner organizations.

### Public Repositories

All feature requests, enhancements, and documentation updates for Aurora’s open-source components should be tracked directly in their respective repositories.
Each repo links automatically to the Aurora organization-wide **Project Board** for visibility and milestone tracking.

Examples include:

- [`gccloudone-aurora/aurora-platform-charts`](https://github.com/gccloudone-aurora/aurora-platform-charts) — Helm charts for deploying and maintaining Aurora platform components
- [`gccloudone/artifacts-artefacts`](https://github.com/gccloudone/artifacts-artefacts) — GC Secure Artifacts documentation and guides
- [`gccloudone/aurora`](https://github.com/gccloudone/aurora) — Aurora public documentation and website

Use GitHub to:

- Propose new platform components or integrations
- Submit documentation changes and improvements
- Request new features or enhancements
- Discuss architectural design in an open, cross-departmental context

### Private Roadmap Repository

For internal coordination and planning not yet ready for public release, Aurora maintains a **private repository**:

- [`gccloudone-aurora/roadmap`](https://github.com/gccloudone-aurora/roadmap)

This repository houses:

- Internal Aurora issues and epics under development
- Work that is unclassified but pre-publication
- Planning discussions bridging SSC internal work and open-source deliverables

Using the **roadmap** repository helps consolidate visibility across all Aurora components while maintaining appropriate information boundaries.

### Not Tracked in GitHub

- Client-specific incidents, service requests, or operational bugs (these belong in Helix)
- Departmental onboarding requests or environment-specific issues
- Protected or classified content (tracked in Jira)

---

## 4. Helix

Helix is the **official IT Service Management (ITSM)** system used across SSC and partner departments.

- **SSC Helix:** Handles incidents, change requests, and service requests related to Aurora’s shared services.
- **STC Helix:** Used by Statistics Canada for internal Cloud Native Platform (CNP) support.
- Other departments may operate their own Helix instance but follow similar ITSM processes.

> **Note:**
> The alignment between SSC’s Helix and departmental Helix implementations is still being refined.
> Aurora follows SSC’s IT Service Lifecycle Management (ITSLM) standards; however, how client-facing requests and platform-level incidents flow between SSC and departmental instances is still under review.
> Additional guidance will be published once a unified model for Helix integration and escalation is finalized.

---

## 5. Summary

| Category                                       | Where to File                                                         | Visibility      |
|------------------------------------------------|-----------------------------------------------------------------------|-----------------|
| Aurora internal coordination                   | GitHub (`gccloudone-aurora/roadmap`)                                  | Private         |
| Public open-source development & documentation | GitHub (`gccloudone` / `gccloudone-aurora` / `gccloudone-aurora-iac`) | Public          |
| Client support / incidents                     | Helix                                                                 | Internal (ITSM) |
| Protected or classified content                | Jira                                                                  | Internal        |

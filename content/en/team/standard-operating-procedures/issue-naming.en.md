---
title: "Issue and PR Naming Conventions"
linkTitle: "Issue and PR Naming Conventions"
weight: 5
aliases: ["/team/sop/issue-naming"]
date: 2025-08-19
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

To support clarity, traceability, and scale across multiple teams, clouds, and departments, all issues, tasks, and pull requests in should follow a consistent naming and labeling convention.

This guide provides a unified format and highlights any tool-specific nuances between Jira and GitHub.

---

## Prefix Format

[PREFIX] Short description of the task

---

## Approved Prefixes

| Prefix               | Purpose                                                        | Example                                                  |
|----------------------|----------------------------------------------------------------|----------------------------------------------------------|
| [CLIENT:PHAC]        | Request from an external department                            | [CLIENT:PHAC] Prepare namespace provisioning guide       |
| [CLIENT:SSC:SEC]     | Internal SSC request, treated as a platform client             | [CLIENT:SSC:SEC] Review Gatekeeper policy exceptions     |
| [CLIENT:SSC:NET]     | Internal SSC networking team task                              | [CLIENT:SSC:NET] Configure peering to mgmt-prod          |
| [CSP:Azure]          | Coordination with cloud service providers                      | [CSP:Azure] Finalize VNet rules for IP range approval    |
| [COMMUNITY]          | Community building, outreach, events, documentation            | [COMMUNITY] Schedule SIG:Networking kickoff meetup       |
| [OSS]                | Open source platform work, infrastructure, release             | [OSS] Migrate core Terraform module to GitHub public     |
| [PARTNER:SecOps]     | Integration with internal horizontal partners or stakeholders  | [PARTNER:SecOps] Align audit logging with GC standards   |
| [SERVICE]            | Shared horizontal services used across the platform            | [SERVICE:Vault] Enable dynamic secrets for CI/CD Runners |

---

## Usage Differences

| Aspect            | Jira                                   | GitHub                                              |
|-------------------|----------------------------------------|-----------------------------------------------------|
| Prefix Placement  | In issue titles                        | In issue titles **and** pull request titles         |
| Labels            | Use structured labels or components    | Use colored labels (freeform text)                  |
| Epics             | Use Epics to group issues              | Use Milestones or GitHub Projects                   |
| Templates         | Issue templates in Description field   | Use .github/ISSUE_TEMPLATE/*.yml and PR templates   |
| Automation        | JQL or Automation for Jira             | GitHub Actions, PR title parsing, label triggers    |

---

## Recommended Labels

### By Audience

- audience:client
- audience:internal

### By Team

- team:ssc-net
- team:ssc-sec
- team:ssc-plat
- team:ssc-comms

### By Department

- dept:phac
- dept:esdc
- dept:statcan

### By Cloud Provider

- csp:azure
- csp:gccloud
- csp:aws

### By Workstream

- stream:oss
- stream:community
- stream:comms
- stream:onboarding
- stream:platform

---

## Summary

| Area        | Jira                           | GitHub                         |
|-------------|--------------------------------|--------------------------------|
| Prefixes    | Use in Issue Titles            | Use in Issue & PR Titles       |
| Labels      | Use for filtering & dashboards | Use for filtering, Actions, UI |
| Templates   | Manual description templates   | .github/ISSUE_TEMPLATE/*.yml   |
| Automation  | JQL, Automation for Jira       | GitHub Actions + Labels        |
| Hierarchy   | Epics, Components              | Milestones, Projects           |

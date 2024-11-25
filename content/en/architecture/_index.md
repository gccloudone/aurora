---
title: "Architectural Plan"
linkTitle: "Architecture"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2024-10-21
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

<gcds-alert alert-role="info" container="full" heading="A brief word of caution" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>This initiative builds on the work conducted at Statistics Canada, originally deployed on one CSP. Although the platform was designed to be cloud-agnostic, additional adjustments are necessary for each cloud service provider's managed Kubernetes offerings which will be done since we want to support ALL of them. We appreciate your patience as we gradually open source our architectural plan and share it here for review and improvements.</gcds-text>
<gcds-text>Currently, only 2 of the 12 sections have been released.</gcds-text>
</gcds-alert>

Welcome to the Aurora Architectural Plan. This document outlines the core design principles, technical architecture, and strategic decisions shaping the platform’s foundation and guiding its development.

Inside, you’ll find an in-depth overview of Aurora’s key components, covering infrastructure management, zero trust strategies, and workload isolation. The plan also addresses critical areas like security hardening, multi-tenant management, and infrastructure automation through CI/CD pipelines.

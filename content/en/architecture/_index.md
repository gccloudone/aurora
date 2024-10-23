---
title: "Architectural Plan"
linkTitle: "Architecture"
type: "architecture"
weight: 10
draft: false
lang: "en"
date: 2024-10-21
---

<gcds-alert alert-role="info" container="full" heading="A brief word of caution" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>This initiative builds on the work done at Statistics Canada, which was initially deployed on Azure. While the platform itself was designed to be cloud-agnostic, further adjustments are needed for each cloud service provider's managed kubernetes offering.</gcds-text>
</gcds-alert>

Welcome to the Architectural Plan for Aurora. This document details the core design principles, technical architecture, and strategic decisions that underpin the platform's structure and guide its evolution.

In addition you'll find a comprehensive breakdown of the platform's key components, including infrastructure management, zero trust strategy, and workload isolation techniques.

It also covers critical aspects such as security hardening, multi-tenant management, and the automation of infrastructure through CI / CD pipelines.

---
title: "Prometheus"
linkTitle: "Prometheus"
weight: 5
aliases: ["/team/monitoring/prometheus"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## What is Prometheus?

Prometheus is an open-source monitoring and alerting toolkit initially developed by SoundCloud in 2012. Widely adopted by companies and organizations, Prometheus is supported by an active developer and user community. Now an independent, standalone open-source project, it joined the Cloud Native Computing Foundation (CNCF) in 2016 as its second hosted project, after Kubernetes, highlighting its importance and transparent governance.

Prometheus collects and stores metrics as time series data, where each data point is recorded with a timestamp and optional key-value pairs called labels. This flexible structure enables powerful monitoring and alerting capabilities across a wide range of systems.

![Monitoring Diagram](/images/architecture/diagrams/monitoring-diagram.jpg "Monitoring Diagram")

## Main Features

- **Multi-dimensional Data Model:** Time series data is identified by a metric name and key-value pairs (labels).
- **Flexible Query Language:** PromQL, Prometheus's powerful query language, allows users to effectively leverage the multi-dimensional data model.
- **Independent Operation:** Prometheus does not rely on distributed storage; each server node operates autonomously.
- **Pull-Based Data Collection:** Time series data is collected using a pull model over HTTP, enabling efficient monitoring.
- **Push Support:** Time series can also be pushed to Prometheus via an intermediary gateway when necessary.
- **Dynamic Target Discovery:** Targets can be discovered automatically using service discovery or configured manually with static settings.
- **Graphing and Dashboarding:** Prometheus supports multiple modes of visualization, including graphs and dashboards.

## Official Documentation

For more information, visit the official [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/) pages.

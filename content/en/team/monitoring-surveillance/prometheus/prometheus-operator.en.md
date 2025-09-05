---
title: "Prometheus Operator"
linkTitle: "Prometheus Operator"
weight: 30
type: "docs"
draft: false
lang: "en"
---

The Prometheus Operator for Kubernetes provides easy monitoring definitions for Kubernetes services and deployment and management of Prometheus instances.

### Main features

- **Create/Destroy**: Use custom resources to facilitate launching and managing Prometheus and Alertmanager instances of various scopes and locations.
- **Simplify Configuration**: Configure the fundamentals of Prometheus like versions, persistence, retention policies, and replicas from a native Kubernetes resource.
- **Target Services via Labels**: Automatically generate monitoring target configurations based on familiar Kubernetes label queries; no need to learn a Prometheus specific configuration language.

### Resources

  - A [Grafana Helm chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana) is available to set up dashboards custom to individual solutions

### Official Documentation

The following resources on the Prometheus Operator are most relevant for those managing their own clusters or seeking an in-depth understanding of possible monitoring infrastructure.

- [Prometheus Operator Getting Started Guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md)
- [Prometheus Operator API reference](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md)

---
title: "Prometheus Operator"
linkTitle: "Prometheus Operator"
weight: 15
type: "docs"
draft: false
lang: "en"
---

The Prometheus Operator for Kubernetes simplifies the deployment, management, and configuration of Prometheus instances, as well as monitoring definitions for Kubernetes services.  

## Main features

- **Create and Manage Instances:** Launch and manage Prometheus and Alertmanager instances of various scopes and locations using custom resources.  
- **Simplified Configuration:** Easily configure core Prometheus settings, such as versions, persistence, retention policies, and replicas, through native Kubernetes resources.  
- **Dynamic Service Discovery:** Automatically generate monitoring target configurations using Kubernetes label queries, eliminating the need to learn Prometheus-specific configuration syntax.  

## Resources

- A [Grafana Helm Chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana) is available to deploy custom dashboards tailored to individual solutions.  

## Official Documentation

For those managing their own clusters or seeking a deeper understanding of monitoring infrastructure, the following resources provide valuable guidance:

- [Prometheus Operator: Getting Started Guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md)  
- [Prometheus Operator: API Reference](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md)

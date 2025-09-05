---
title: "Prometheus Operator"
linkTitle: "Prometheus Operator"
weight: 30
type: "docs"
draft: false
lang: "en"
---

The Prometheus Operator for Kubernetes provides easy monitoring definitions for Kubernetes services and deployment and management of Prometheus instances.

All CNP clusters have this operator installed onto them and a globally configured instance. This is done through the [Kube-Prometheus-Stack Terraform module](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack), which comprises the [Kube-Prometheus-Stack Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), optional [Istio DestinationRules](https://istio.io/latest/docs/reference/config/networking/destination-rule/), and the optional set of default alerting rules described in [Cluster Alert Runbooks]({{< ref "/en/team/monitoring-surveillance/prometheus/cluster-alert-runbooks" >}}) and [Namespace Alert Runbooks]({{< ref "/en/team/monitoring-surveillance/prometheus/namespace-alert-runbooks" >}}).

### Main features

- **Create/Destroy**: Use custom resources to facilitate launching and managing Prometheus and Alertmanager instances of various scopes and locations.
- **Simplify Configuration**: Configure the fundamentals of Prometheus like versions, persistence, retention policies, and replicas from a native Kubernetes resource.
- **Target Services via Labels**: Automatically generate monitoring target configurations based on familiar Kubernetes label queries; no need to learn a Prometheus specific configuration language.

### Resources

- The [Kube-Prometheus-Stack Terraform module](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack) can can be used for those managing their own cluster(s).
- The [Alerting chart](https://gitlab.k8s.cloud.statcan.ca/cloudnative/k8s/charts/-/tree/master/stable/alerting) can be used on a cluster running the Prometheus Operator to set up metrics and alerts for one or more namespaces. Metrics can be read from a cluster's global Prometheus instance and/or individually configured exporters.
  - Note that this chart is still in early development. Support is not guaranteed and features may change drastically.
- Dashboards for CNP clusters can be accessed at [Grafana](https://grafana.cloud.statcan.ca)
  - A [Grafana Helm chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana) is available to set up dashboards custom to individual solutions

### Official Documentation

The following resources on the Prometheus Operator are most relevant for those managing their own clusters or seeking an in-depth understanding of possible monitoring infrastructure.

- [Prometheus Operator Getting Started Guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/getting-started.md)
- [Prometheus Operator API reference](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md)

---
title: "Blackbox Exporter"
linkTitle: "Blackbox Exporter"
weight: 10
aliases: ["/team/monitoring/blackbox-exporter"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

The Prometheus [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) enables the monitoring of endpoints using protocols such as HTTP, HTTPS, DNS, TCP, ICMP, and gRPC. It supports "blackbox monitoring," which focuses on evaluating the external behavior and availability of a system without requiring access to its internal state.

The Blackbox Exporter is also available as a [Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter), making it easy to deploy in Kubernetes environments.

## Key Considerations

- A Blackbox Exporter running in a given cluster can only probe endpoints that are accessible from that cluster.
- There are various ways to set up and use the Blackbox Exporter. This guide focuses on installing it through its Helm chart and using it in the context of the Prometheus Operator, a common approach for Kubernetes observability.

## Core Concepts

- **Modules for Probes**: The Blackbox Exporter is configured with modules, which define the success criteria for probes. For example, a module might specify expected HTTP response codes, connection timeouts, or DNS query results.
- **Target Configuration**: The endpoints (or targets) to be probed are defined in a ServiceMonitor, which also specifies which module each target will use.
- **User Interface for Debugging**: You can access the Blackbox Exporter’s user interface by port-forwarding to its pod (default port: `9115`). The UI provides detailed traces of each probe to aid in debugging. Probe traces are displayed in historical order, but only a limited number is retained. By default, failed traces are stored separately (up to the last 100) and are listed at the bottom of the UI for easier troubleshooting.
- **Prometheus Rules and Alerts**: You can use Prometheus Rules to create alerts based on probe results or metrics. For instance, you can set up alerts for repeated probe failures or unusual response patterns.

## Defining Blackbox Modules

A common use case for the Blackbox Exporter is monitoring the uptime of HTTP endpoints. For such cases, the default module, [http_2xx](https://github.com/prometheus-community/helm-charts/blob/prometheus-blackbox-exporter-5.6.0/charts/prometheus-blackbox-exporter/values.yaml#L112-L120), is typically sufficient. This module is configured to verify that the HTTP response falls within the `2xx` range, indicating success.

However, the Blackbox Exporter supports a wide range of fine-grained configuration options for custom modules. For example, modules can be configured to fail if:

- An SSL/TLS connection cannot be established, or
- The number of redirects exceeds a specific threshold.

To explore the full range of customization options, refer to the [Blackbox Exporter Configuration Documentation](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md). Custom modules can be defined in your Helm chart's `values.yaml` file under the default `http_2xx` module, which can also be redefined if necessary.

## Example Configurations

### ServiceMonitor configuration

The following configuration would be specified in the `values.yaml` file of the Blackbox Exporter Helm chart:

```yaml
  serviceMonitor:
    enabled: true
    defaults:
      labels:
        app: blackbox-exporter
        release: kube-prometheus-stack
    targets:
      - name: example.com
        url: https://www.example.com
        interval: 60s
        scrapeTimeout: 60s
        module: http_2xx
      - name: example.org
        url: https://www.example.org
        interval: 60s
        scrapeTimeout: 60s
        module: http_2xx
```

Please note that the label `release: kube-prometheus-stack` assumes the default Prometheus instance from the default installation of the Kube-Prometheus-Stack Helm chart. If this chart was installed using a custom Helm release name, that custom release name will need to be specified as the value.

Alternatively, the desired Prometheus instance (whether installed via kube-prometheus-stack or otherwise) can be configured to discover ServiceMonitor resources based on different labels or namespace restrictions, depending on your setup.

### Prometheus Alert Rule

To monitor the success of probes run by the Blackbox Exporter, you can define Prometheus alerting rules. The following example demonstrates how to create an alert to detect probe failures:

```yaml
- alert: ProbeFailure
  expr: sum by (target, instance) (probe_success) != 1
  for: 15s
  labels:
    severity: high
  annotations:
    message: 'The {{ $labels.target }} probe is failing. Port-forward into 9115 on the blackbox pod in your namespace for {{ $labels.instance }} debug information. Scroll to the bottom for older failures.'
    runbook: https://aurora.gccloudone.alpha.canada.ca/team/monitoring-alerts/alert-cluster-level/probe-failure/
```

This rule uses the `probe_success` metric to detect failed probes. It checks if the probe_success value grouped by target and instance is not equal to 1 for 15 seconds, triggering an alert when that condition is met.

To monitor a specific target:

```promql
sum by (target, instance) (probe_success{target="<target name, e.g. example.com>"}) != 1
```

To monitor multiple targets using a regex pattern:

```promql
sum by (target, instance) (probe_success{target=~"example.com|example.org|mytargetprefix.*"}) != 1
```

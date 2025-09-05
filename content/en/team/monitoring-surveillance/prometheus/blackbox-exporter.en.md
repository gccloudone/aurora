---
title: "Uptime monitoring with Blackbox Exporter"
linkTitle: "Uptime monitoring with Blackbox Exporter"
weight: 90
type: "docs"
draft: false
lang: "en"
---

The Prometheus [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter) allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP, ICMP and gRPC. It is also available as a [Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter). "Blackbox" refers to blackbox monitoring, which is the monitoring of the external behavior of a system without knowledge of its internal state.

Note that a blackbox exporter running on a particular cluster can only probe endpoints that can be accessed from that cluster.

There are many ways to install and make use of the blackbox exporter. For brevity and greatest relevance to the Platform, this page focuses on installing it through its Helm chart and using it in the context of the Prometheus Operator.

In this context:
1. Blackbox exporter is configured with one or more modules that determine the success criteria of its probes.
1. The targets of the probes are specified in a ServiceMonitor along with the module that each target will use.
1. Port-forwarding to the blackbox pod's UI (default port 9115) reveals detailed traces of each probe.
    - Probe traces are listed in historical order with a limited total number saved. However, to facilitate debugging, failed traces are saved seperately (by default, the last 100) at the bottom of blackbox UI.
1. One or more Prometheus Rules can be written to alert for failed probes or any metrics within them.

### Defining blackbox modules

A common use case for the blackbox exporter is the uptime monitoring of http endpoints, for which the default module [http_2xx](https://github.com/prometheus-community/helm-charts/blob/prometheus-blackbox-exporter-5.6.0/charts/prometheus-blackbox-exporter/values.yaml#L112-L120) is typically sufficient.

However there is a wide variety of fine-grained configuration options for modules, such as failing when an SSL connection cannot be made or an unexpected amount of redirects is encountered. Refer to the [configuration documentation](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md) for a full list of possibilities. Such custom modules can be defined in the Helm values under the default `http_2xx`, which could itself be redefined if desired.

### Example ServiceMonitor configuration

The following would be specified in the values of the Blackbox Exporter Helm chart.

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

Note that `release: kube-prometheus-stack` assumes the default Prometheus instance from a default installation of the Kube-Prometheus-Stack Helm chart. If that chart was installed with a custom Helm release name, that would need to be the value.

Alternatively, the desired Prometheus instance (whether it is the one installed through kube-prometheus-stack or a different one) may be configured to pick up ServiceMonitors based on different labels and/or namespace restrictions.

### Example Prometheus Alert Rule

```yaml
- alert: ProbeFailure
  expr: sum by (target, instance) (probe_success) != 1
  for: 15s
  labels:
    severity: high
  annotations:
    message: 'The {{ $labels.target }} probe is failing. Port-forward into 9115 on the blackbox pod in your namespace for {{ $labels.instance }} debug information. Scroll to the bottom for older failures.'
    runbook: https://cloudnative.pages.cloud.statcan.ca/en/documentation/prometheus/cluster-alert-runbooks/probe-failure/

```

`probe_success` can also be specified to one or more targets, `e.g. sum by (target, instance) (probe_success{target="<target name, e.g. example.com>"}) != 1` or `sum by (target, instance) (probe_success{target=~"example.com|example.org|mytargetprefix.*"}) != 1` if you want to set up different alert criteria/labels for different targets.

The debug page for a given probe lists metrics that could be used to construct finer grained recording rules or alerts.

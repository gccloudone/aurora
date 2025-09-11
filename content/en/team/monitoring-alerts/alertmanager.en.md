---
title: "Alertmanager"
linkTitle: "Alertmanager"
weight: 5
aliases: ["/team/monitoring/alertmanager"]
draft: false
---

---
title: "Backup and Disaster Recovery"
linkTitle: "Backup and Disaster Recovery"
weight: 5
aliases: ["/team/sop/backup-disaster-recovery"]
date: 2025-08-19
draft: false
---

[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) is used by Prometheus to deduplicate, route, group, silence, and inhibit [alerts](()).

A single instance of Alertmanager can receive and manage alerts from multiple different instances of Prometheus. When doing so, it is best to configure the Prometheus instances to add a label to the alerts that they transmit, such as `cluster: foo` or `prometheus: bar`, so that the alerts could be differentiated within Alertmanager and its notifications.

A single instance of Prometheus can send alerts to one or more instances of Alertmanager, as well as modify or selectively drop alerts before they are transmitted. However, a Prometheus instance cannot send different sets of alerts to different instances of Alertmanager.

## Configuration

Alertmanager is configured through a YAML file. In the context of the Prometheus Operator, this configuration is expected within a Kubernetes secret, as a base64 value of the key `alertmanager.yaml`. If notification templates are used, each template should be a separate key-value pair in the data of the same secret, with the template as a base64 value of a key whose name matches the specification in the Alertmanager config. For example, if the Alertmanager config specifies:

```yaml
templates:
- '*.tmpl'
- '*.html'
```

Then `slack.tmpl: <base64 encoded template>` and `email.html: <base64 encoded template>` are acceptable.

This can be done manually by creating a secret with multiple `--from-file` specifications, or through values in Helm charts that include Alertmanager.

### Alert routing

Routing is done through a series of matches which can be nested: there must be one default `route`, but that `route` can have child `routes`, which can themselves have child `routes`, and so on.

The following example configuration defaults to sending all alerts to the empty default receiver `do_not_notify`. However, alerts with the labels `severity: medium` or `severity: high` instead go to the `ms_teams` receiver. Then, due to the property `continue: true`,  those with the label `severity: high` are *also* sent to the `email` receiver.
> If an alert matches to a route without the `continue: true` property, it is "consumed" by that route or that route's child routes. That alert will not be transmitted to sibling routes even if it matches their criteria.

```yaml
global:
  smtp_smarthost: '<Host>'
  smtp_from: '<Do not reply address>'
  smtp_auth_username: '<Username>'
  smtp_auth_password: '<Password>'
  smtp_require_tls: true

receivers:
  # Empty receiver
  - name: do_not_notify
  - name: ms_teams
    webhook_configs:
    - url: "http://prometheus-msteams:2000/example"
      send_resolved: true
  - name: email
    email_configs:
    - to: '<Recipient email(s), seperated by commas if multiple>'
      send_resolved: true
      html: '{{ template "email.email.html" . }}'

templates:
- '*.tmpl'
- '*.html'

route:
  group_by: ['cluster', 'alertname', 'namespace']
  group_wait: 10s
  group_interval: 5m
  receiver: do_not_notify
  repeat_interval: 168h
  routes:
  - match_re:
      severity: medium|high
    receiver: ms_teams
    continue: true
  - match_re:
      severity: high
    receiver: email
```

Note that `severity` is an example of an arbitrary label which is set on the Prometheus rule defining the alert. Such a label could just as easily be `severity: ultramax` or `colour: blue`. It is equally possible to match for combinations of labels, such as:

```yaml
- match_re:
    severity: medium|high
    project: myproject
```

### Alert inhibition

In addition to routing notifications, the Alertmanager `config` can be set up to not transmit certain alerts if certain other alerts are firing. `inhibition_rules` are set at the same indentation level as the base `route`.

For example, per following specification, when there is a PodNotReady and a ContainerWaiting alert for the same pod in the same namespace on the same cluster, only the ContainerWaiting alert will transmit. This is done because `ContainerWaiting` always causes `PodNotReady`, so when both are present, `PodNotReady` is redundant. However, `PodNotReady` can occur for reasons other than `ContainerWaiting`.

```yaml
inhibit_rules:
- target_match:
    alertname: 'PodNotReady'
    source_match_re:
    alertname: 'ContainerWaiting'
    equal: ['cluster', 'namespace', 'pod']
```

### Notification templates

The following notification templates are available on an as-is basis for reference. They may need to be modified for any relevant syntax updates, specific alert label definitions, and preferences for which labels and functionality to include or exclude.

- [Email](https://github.com/frazs/prometheus-operator-configs/blob/master/alertmanager-config/email.html)
- [Slack](https://github.com/frazs/prometheus-operator-configs/blob/master/alertmanager-config/slackcustom.tmpl)
- [MS Teams](https://github.com/frazs/prometheus-operator-configs/blob/master/alertmanager-config/msteams.tmpl) -- not natively supported by Alertmanager and therefore requiring the installation of, and configuraiton within, [prometheus-msteams](https://github.com/prometheus-msteams/prometheus-msteams/tree/master/chart/prometheus-msteams)


### Configuration references

- See the [Alertmanger configuration documentation](https://prometheus.io/docs/alerting/0.21/configuration/) for a full list of possibilities.
- Test your route logic using the [Routing tree editor](https://www.prometheus.io/webtools/alerting/routing-tree-editor/) web tool. For simplicity and privacy, all that is required to paste in is the `route` and `receivers` block. Furthermore, the `receivers` block can be truncated to contain only the `- name: foo` lines.

## Alert Silencing

In some cases, an alert for a particular issue can fire repeatedly or flap. Here are a few common examples:

- The consumption of a resource, such as disk or pod capacity, bounces above and below the alerting threshold.
- A low-priority issue persists for longer than Alertmanager’s data retention period, forcing Alertmanager to recreate the alert.
- An outage is not continuous, resolving itself for a few minutes or hours at a time only to reoccur.

Alerting rules can be designed to reduce flapping. But flapping cannot always be eliminated. Mitigations must be balanced against the accuracy and promptness of alerts, preferring a false positive over a false negative.

A repeating alert can be silenced by creating a corresponding Silence in the Alertmanager UI. To facilitate this process, alert notifications can contain a Silence link that will pre-fill the Silence creation form with regex matchers specific to the alert and its origin. These matchers can be removed or modified to make the Silence more general.

Silences are created with a duration/end-time and can also be removed ("expired") at any time. A list of all Silences can be viewed in the Alertmanager UI.

Note that silences also apply to alert resolution notifications. Do not apply a silence if you want to use these notifications to track the times at which an ongoing issue self-resolves.

## Creating Alerts

A Prometheus Alert is one of two types of Prometheus Rules. To define an Alert, it is important to first understand the core components of a Rule: metrics and PromQL (Prometheus Query Language) queries.

### Metrics and Exporters

First and foremost, the relevant metrics must be available to Prometheus. If what you are trying to monitor with Prometheus has not been [instrumented](https://prometheus.io/docs/practices/instrumentation/) to natively expose metrics in a format that Prometheus can read, this requires creating or installing a metric exporter.

- [Sample list of exporters](https://prometheus.io/docs/instrumenting/exporters/)
- [Guide to writing exporters](https://prometheus.io/docs/instrumenting/writing_exporters/)

Whether the metrics are native or generated by an exporter, configurations must be put in place for them to be picked up. When using the [Prometheus Operator]({{< ref "/team/monitoring-alerts/prometheus-operator.en.md" >}}), such configurations can include creating or enabling ServiceMonitors or PodMonitors with labels that the Prometheus custom resource selects for.

### Querying metrics

Once metrics are available, developing a Prometheus query is the core of making a Prometheus Alert. Refer to the [Prometheus Documentation](https://prometheus.io/docs/prometheus/latest/querying/basics/) for understanding and building queries, and test them out by executing them in any running instance of Prometheus. 

Some metrics are useful for their values. Others are useful for their informative labels, and will typically have a "value" of 1. For any query with unique results for what is being measured, the [aggregation opperators](https://prometheus.io/docs/prometheus/latest/querying/operators/#aggregation-operators) `sum by` and `sum without` are especially useful for trimming labels to return only relevant and secure information.

For example, the query `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes` returns the available memory on nodes and is composed of two metrics made available by the Prometheus Node Exporter. A simple alert could correspond to the query `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 15`. But the labels for these metrics only identify the node by its IP address (`instance`), which is not easy to follow. How could we get the node name instead? 

Fortunately, both the node `instance` and `nodename` are available in another metric, `node_uname_info`. Since `node_uname_info` is an informative label metric that always has a "value" of `1`, we can take advantage of the arithmetic operator `*` to join this information:  `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes` **`* on(instance) group_left(nodename) node_uname_info`**.

Now we can use `sum by` to return only the `nodename`: **`sum by (nodename)`** `(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * on(instance,job) group_left(nodename) node_uname_info)`, perhaps with a * 100 < 15  at the end for an alert that will report on nodes under 15% memory. 

### Defining Prometheus Rules

There are two kinds of Prometheus Rules: **Records** and **Alerts**.

**Records** are very simple. They consist of a name and an expression corresponding to a query. This name can then be queried as if it was a metric, which is useful for organizing and pre-computing parts of complex queries.

For example:
- `sum(kube_node_status_allocatable_pods * on (node) group_left(label_agentpool) kube_node_labels) by (label_agentpool)` is recorded as `nodepool_allocatable_pods`
- `sum(kube_pod_info * on (node) group_left(label_agentpool) kube_node_labels) by (label_agentpool)` is recorded as `nodepool_allocated_pods`
- This simplifies constructing a query for the proportion of pods allocated in a nodepool into `nodepool_allocated_pods/nodepool_allocatable_pods`

**Alerts** also start with a name and an expression. However, the expression for an Alert will almost always end with some form of [comparison binary operator](https://prometheus.io/docs/prometheus/latest/querying/operators/#comparison-binary-operators), which is typically not the case for a Record.

Alerts are further defined by a duration, which is how long an expression must be valid for the alert to go from` Pending` to `Firing` (e.g. "less than 15% CPU left for more than 2 minutes"), any additional labels (such as `severity`), and any additional `annotations` such as a descriptive `message` and/or a `runbook` link.

#### Examples

Many examples of Prometheus Alerts are available at [Awesome Prometheus Alerts](https://awesome-prometheus-alerts.grep.to/). These alerts should be used as references and starting points: they assume the presence of any required exporters, do not omit any labels, and may have arbitrary thresholds, formats, and severities. For example, annotations are split into a `summary` and a `description` instead of a single `message`.

It is also important to calibrate the sensitivity of alerts to the scope and scale of the environment being monitored. The level of detail appropriate for monitoring a single application may be too noisy for the monitoring of a namespace, which can in turn be too noisy for the monitoring of one or more clusters.

#### Picking up Prometheus Rules

Once Prometheus Rules are defined, they must be picked up by the relevant Prometheus instance.

In a standalone installation of Prometheus, rules are written in YAML files and which are specified under `rule_files` in the [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/). The [Prometheus Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus) facilitates this by allowing the entry of rules as [Helm values](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml) `alerting_rules.yml` and `recording_rules.yml`.

Alternatively, the [Prometheus Operator]({{< ref "/team/monitoring-alerts/prometheus-operator.en.md" >}}) facilitates the management of Prometheus Rules via a PrometheusRule Custom Resource Definition. There is no distinction made between Alerting and Recording rules, and they may coexist within the same PrometheusRule manifest.

A PrometheusRule custom resource defines one or more Prometheus Rules, which can further be categorized into groups. [See an example](https://github.com/frazs/prometheus-operator-configs/blob/master/general-cluster-alerts.yaml).

As with all other Kubernetes resources, PrometheusRules can be:
- Added with commands such as `kubectl -n mynamespace -f myalerts.yaml`
- Removed with `kubectl -n mynamespace delete prometheusrule my-alerts` (use `kubectl -n mynamespace get prometheusrules` to confirm the resource name)
- Updated by editing the yaml file and applying it again, whether manually or through any configuration-as-code management process.

The default configuration of the Prometheus instance installed by the [Kube-Prometheus-Stack Helm chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) (which installs the Prometheus Operator alongside supporting components) picks up all PrometheusRules with the label `release: kube-prometheus-stack`, or the name of the Helm release corresponding to kube-prometheus-stack if a different name was selected. This label must be on the PrometheusRule resource and should not be confused with labels on any Rules within.

This behaviour can be modified to look for one or more different labels, as well as to specify that PrometheusRules are only to be picked up from specific namespaces.

It is also possible to run multiple Prometheus instances with different criteria for which rules they pick up. These criteria are within the specification of the Prometheus custom resource(s) managed by the Prometheus Operator.

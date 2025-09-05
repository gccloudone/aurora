---
title: "Alertmanager"
linkTitle: "Alertmanager"
weight: 20
type: "docs"
draft: false
lang: "en"
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

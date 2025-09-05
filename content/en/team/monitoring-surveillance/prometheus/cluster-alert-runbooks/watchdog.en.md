---
title: "Watchdog"
linkTitle: "Watchdog"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Alert: Watchdog

Watchdog alerts are currently configured to occur at the cluster level. This is an alert meant to ensure that the entire alerting pipeline is functional. This alert is always firing; therefore, it should always be firing in Alertmanager and always fire against a receiver.

There are integrations with various notification mechanisms that send a notification when this alert is not firing. For example the [alertmanager-route-proxy](https://gitlab.k8s.cloud.statcan.ca/cloudnative/go/alertmanager-route-sender) process.

### alertmanager-route-proxy

In the case of the alertmanager-route-proxy, Alertmanager periodically [sends a notification](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/platform/terraform-kubernetes-aks-platform-mgmt/-/blob/master/module_helm_kube_prometheus_stack.tf#L556) to the process when the WatchDog alert is firing. Each time the alertmanager-route-proxy process receives the HTTP request from Alertmanager, it inputs a log entry into the cloudnative-management-law Log Analytics Workspace. Every 30 minutes Azure Monitor looks through the logs inputted into the log analytics workspace over the past 30 minutes (refer to the [alert definition](https://gitlab.k8s.cloud.statcan.ca/cloudnative/environment/management/cloudnative-management-rg/-/blob/master/infrastructure/main.tf#L138)). If it doesn't find any logs, it means the internal monitoring solution could be down. Therefore, to notify the Cloud Native Solutions team of this problem, it will send them an email.


The `alertmanager-route-proxy` pods are only running on the Management cluster. However, since the Management Alertmanger receives alerts from every SDLC cluster's Prometheus instance, the alert created by Azure Monitor also fires if a SDLC cluster's Prometheus is down. It will alert if one or more of the following is true:
- InfraTest Prometheus is down
- Dev Prometheus is down
- Test Prometheus is down
- Prod Prometheus is down
- Management Prometheus is down
- Management Alertmanager is down

## Resolution Process

Check if Alertmanager or Prometheus is down, if so it needs to be brought back up. There could be many reasons why Alertmanager is down, each with a different solution and they should be added below as it occurs.

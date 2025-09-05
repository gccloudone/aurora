---
title: "Cluster Alerts"
linkTitle: "Cluster Alerts"
weight: 50
type: "docs"
draft: false
lang: "en"
---

{{% alert title="Work In Progress" color="warning" %}}
This page is currently a work in progress. Check back periodically for more information around Cluster Alert Runbooks.
{{% /alert %}}

This page describes alerts presently defined at the cluster scope, meaning either that they do not concern namespaced resources or that they are relevant no matter which namespace they occur in.

### Runbooks

Prometheus alerts support any amount of arbitrary annotations. A standard practice is to define a link to a Runbook documenting how to investigate or resolve the alert.

Subpages within this section describe Runbooks for Prometheus Alerts experienced at the cluster scope within the Cloud Native Platform.

#### Blackbox Exporter
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/certificate_alerts/certificate_rules.yaml).

Based on metrics collected by the Blackbox Exporter.

- [**ProbeFailure**]({{< ref "probe-failure" >}}): A blackbox exporter probe has failed. What failure means depends on probe configuration and can include factors such as an unexpected HTTP response, failure to complete a TLS transaction, or an inappropriate number of redirects.
- [**SSLCertExpiringSoon**]({{< ref "ssl-cert-expiring-soon" >}}): The SSL Certificate of the target will expire within the next 20 days.

#### cert-manager
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-cert-manager/-/blob/master/prometheus_rules/cert_manager_rules.yaml).

Refer to the [general Runbook for investigating cert-manager alerts]({{< ref "cert-manager" >}}).

- **certManagerCertFailingToRenew**: A certificate is failing to renew.
- **certManagerCertFailure**: A certificate is not in a ready state, but is not in need of renewal.
- **certManagerCertExpired**: A certificate has expired.
- **certManagerAbsent**: cert-manager is down or not reachable by Prometheus.
- **certManagerHittingRateLimits**: cert-manager is hitting LetsEncrypt rate limits, which may prevent certificate generation for up to a week.

#### Miscellaneous
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/prometheus_alerts/prometheus_rules.yaml).

- **BackupJobFailed**: Management cluster only. A job with backup in the name has failed. Currently captures GitLab and Jenkins backups.
- [**PrometheusStorageLow**]({{< ref "prometheus-storage-low" >}}): Prometheus disk usage is over 85%.
- [**PrometheusDiskMayFillIn60Hours**]({{< ref "prometheus-storage-low#alert-prometheusdiskmayfillin60hours" >}}): Prometheus remaining disk capacity is predicted to go under 10% within 60 hours. A Prometheus instance whose disk capacity is exhausted will cease generating alerts.

#### Nodepools
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/nodepool_alerts/nodepool_rules.yaml).

- [**NodepoolReachingPodCapacity**]({{< ref "node-pool-pod-capacity#alert-nodepoolreachingpodcapacity" >}}): Nodepool non-terminated pod count is over 80% of capacity.
- [**NodepoolPodsFull**]({{< ref "node-pool-pod-capacity#alert-nodepoolpodsfull" >}}): Nodepool non-terminated pod count is over 95% of capacity.

#### Node Health
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/node_alerts/node_rules.yaml).

- [**NodeDiskPressure**]({{< ref "node-pressure-eviction#alert-nodediskpressure" >}}): Disk usage has reached eviction thresholds.
- **NodeDiskMayFillIn60Hours**: Node disk is being written to at a rate that may trigger Disk Pressure in the near future.
- [**NodeMemoryPressure**]({{< ref "node-pressure-eviction#alert-nodememorypressure" >}}): Memory usage has reached eviction thresholds.
- [**NodePIDPressure**]({{< ref "node-pressure-eviction#alert-nodepidpressure" >}}): Process count has reached eviction thresholds.
- **NodeNetworkUnavailable**: Network is unavailable.
- **NodeNotReady**: Node is not in Ready state but did not trip another pressure or network condition.
- [**NodeUnscheduleable**]({{< ref "node-unschedulable" >}}): Node is Ready yet cannot be scheduled on for over an hour. A common cause is when a node is left cordoned.
- **NodeReadinessFlapping**: The node is going in and out of a ready state.

#### Node Debug
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/node_alerts/node_rules.yaml).

The following alerts do not transmit notifications as they do not necessarily indicate an error state. They can be browsed in the Prometheus or Alertmanager UI for additional information during troubleshooting.

- **NodeLowCPU**: Node CPU usage over 85%.
- **NodeLowDisk**: Node disk usage over 85%.
- **NodeLowMemory**: Node memory usage over 85%.
- **NodeReachingPodCapacity**: Node pod count is over 90% of capacity.
- **NodePodsFull**: Node pod capacity is exhausted.

#### Velero
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-velero/-/tree/master/prometheus_rules/velero_rules.yaml).

Refer to the [general Runbook for investigating Velero alerts]({{< ref "velero" >}}).

- **VeleroBackupFailure**: A single Velero backup has failed.
- **VeleroBackupPartialFailure**: A single Valero backup has partially failed.
- **VeleroHourlyBackupFailure**: An hourly Velero backup is failing multiple hours in a row.
- **VeleroHourlyBackupPartialFailure**: An hourly Velero backup is partially failing multiple hours in a row.
- **VeleroBackupContinuousFailure**: Velero backups are failing while constantly being recreated.
- **VeleroBackupContinuousPartialFailure**: Valero backups are partially failing while constantly being recreated.
- **VeleroBackupTakingLongTime**: A scheduled Velero backup is taking long than 2 hours and 30 minutes.

#### Nginx
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-ingress/-/blob/main/prometheus_rules/nginx_rules.yaml)

Refer to the [general Runbook for investigating Nginx alerts]({{< ref "nginx-alerts" >}}):

- **HTTPRequestCountSpike**: The rate of HTTP requests is significantly higher than predicted
- **HTTPRequestCountDrop**: The rate of HTTP requests is significantly lower than predicted
- **NginxIngressDown**: Nginx Ingress controller is unavailable
- **UnsuccessfulNginxReload**: Nginx is failing to reload the new configuration
- **NginxConnectionsHigh**: Total nginx connections exceed 50% of the maximum amount of connections
- **NginxConnectionsVeryHigh**: Total nginx connections exceed 85% of the maximum amount of connections

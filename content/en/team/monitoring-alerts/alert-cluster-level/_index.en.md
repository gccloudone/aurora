---
title: "Cluster Level Alerts"
linkTitle: "Cluster Level Alerts"
weight: 60
aliases: ["/team/monitoring/clusteralerts"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This page describes alerts presently defined at the cluster scope, meaning either that they do not concern namespaced resources or that they are relevant no matter which namespace they occur in.

## Runbooks

Prometheus alerts support any amount of arbitrary annotations. A standard practice is to define a link to a Runbook documenting how to investigate or resolve the alert.

Subpages within this section describe Runbooks for Prometheus Alerts experienced at the cluster scope within the Aurora platform.

### Blackbox Exporter

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/blackbox_exporter).

Based on metrics collected by the Blackbox Exporter.

- [**ProbeFailure**]({{< ref "probe-failure" >}}): A blackbox exporter probe has failed. What failure means depends on probe configuration and can include factors such as an unexpected HTTP response, failure to complete a TLS transaction, or an inappropriate number of redirects.
- [**SSLCertExpiringSoon**]({{< ref "ssl-cert-expiring-soon" >}}): The SSL Certificate of the target will expire within the next 20 days.

### Cert Manager

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/cert_manager).

Refer to the [general Runbook for investigating cert-manager alerts]({{< ref "cert-manager" >}}).

- **certManagerCertFailingToRenew**: A certificate is failing to renew.
- **certManagerCertFailure**: A certificate is not in a ready state, but is not in need of renewal.
- **certManagerCertExpired**: A certificate has expired.
- **certManagerAbsent**: cert-manager is down or not reachable by Prometheus.
- **certManagerHittingRateLimits**: cert-manager is hitting LetsEncrypt rate limits, which may prevent certificate generation for up to a week.

### Miscellaneous

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack).

- **BackupJobFailed**: A job with backup in the name has failed.
- [**PrometheusStorageLow**]({{< ref "prometheus-storage-low" >}}): Prometheus disk usage is over 85%.
- [**PrometheusDiskMayFillIn60Hours**]({{< ref "prometheus-storage-low#alert-prometheusdiskmayfillin60hours" >}}): Prometheus remaining disk capacity is predicted to go under 10% within 60 hours. A Prometheus instance whose disk capacity is exhausted will cease generating alerts.

### Nodepools

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/nodepool_alerts).

- [**NodepoolReachingPodCapacity**]({{< ref "node-pool-pod-capacity#alert-nodepoolreachingpodcapacity" >}}): Nodepool non-terminated pod count is over 80% of capacity.
- [**NodepoolPodsFull**]({{< ref "node-pool-pod-capacity#alert-nodepoolpodsfull" >}}): Nodepool non-terminated pod count is over 95% of capacity.

### Node Health

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/node_alerts).

- [**NodeDiskPressure**]({{< ref "node#alert-nodediskpressure" >}}): Disk usage has reached eviction thresholds.
- **NodeDiskMayFillIn60Hours**: Node disk is being written to at a rate that may trigger Disk Pressure in the near future.
- [**NodeMemoryPressure**]({{< ref "node#alert-nodememorypressure" >}}): Memory usage has reached eviction thresholds.
- [**NodePIDPressure**]({{< ref "node#alert-nodepidpressure" >}}): Process count has reached eviction thresholds.
- **NodeNetworkUnavailable**: Network is unavailable.
- **NodeNotReady**: Node is not in Ready state but did not trip another pressure or network condition.
- [**NodeUnscheduleable**]({{< ref "node#alert-nodeunschedulable" >}}): Node is Ready yet cannot be scheduled on for over an hour. A common cause is when a node is left cordoned.
- **NodeReadinessFlapping**: The node is going in and out of a ready state.

### Node Usage

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/node_alerts).

The following alerts do not transmit notifications as they do not necessarily indicate an error state. They can be browsed in the Prometheus or Alertmanager UI for additional information during troubleshooting.

- **NodeLowCPU**: Node CPU usage over 85%.
- **NodeLowDisk**: Node disk usage over 85%.
- **NodeLowMemory**: Node memory usage over 85%.
- **NodeReachingPodCapacity**: Node pod count is over 90% of capacity.
- **NodePodsFull**: Node pod capacity is exhausted.

### Velero

These alerts are defined in our [aurora-platform-charts](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/velero).

Refer to the [general Runbook for investigating Velero alerts]({{< ref "velero" >}}).

- **VeleroBackupFailure**: A single Velero backup has failed.
- **VeleroBackupPartialFailure**: A single Valero backup has partially failed.
- **VeleroHourlyBackupFailure**: An hourly Velero backup is failing multiple hours in a row.
- **VeleroHourlyBackupPartialFailure**: An hourly Velero backup is partially failing multiple hours in a row.
- **VeleroBackupContinuousFailure**: Velero backups are failing while constantly being recreated.
- **VeleroBackupContinuousPartialFailure**: Valero backups are partially failing while constantly being recreated.
- **VeleroBackupTakingLongTime**: A scheduled Velero backup is taking long than 2 hours and 30 minutes.

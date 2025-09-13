---
title: "Namespace Level Alerts"
linkTitle: "Namespace Level Alerts"
weight: 70
aliases: ["/team/monitoring/namespacealerts/"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This page describes alerts presently defined at the namespace level. They are routed to the notification channels of the Aurora team only when they occur in namespaces relevant to the core functionality of the Aurora platform.

### Runbooks

Prometheus Alerts support any amount of arbitrary annotations. One standard practice is to define a link to a runbook documenting how to investigate or resolve the Alert.

Subpages within this section describe Runbooks for Prometheus Alerts experienced at the namespace scope within the Aurora platform.

### Alerts

Alerts are defined below their respective header.

#### Containers

These alerts are defined [here](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/container_alerts).

- [**ContainerLowCPU**]({{< ref "container#alert-containerlowcpu" >}}) : Container CPU usage is over 85% for more than 5 minutes.
- [**ContainerLowMemory**]({{< ref "container#alert-containerlowmemory" >}}) : Container memory usage is over 80% for more than 2 minutes.
- [**ContainerWaiting**]({{< ref "container#alert-containerwaiting" >}}) : A container is waiting for more than 15 minutes for any reason other than CrashLoopBackoff (which is captured separately by ManyContainerRestarts).
- [**ManyContainerRestarts**]({{< ref "container#alert-manycontainerrestarts" >}}) : A container has restarted more than 10 times in the last 8 hours.

#### Pods

These alerts are defined [here](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/pod_alerts).

- [**PodNotReady**]({{< ref "pod-not-ready" >}}): A pod has been in a non-ready state for more than 15 minutes.

#### Jobs

These alerts are defined [here](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/job_alerts).

- [**CompletedJobsNotCleared**]({{< ref "job#alert-completedjobsnotcleared" >}}) : More than *20* completed jobs within a particular namespace are older than 24 hours.
- [**JobFailed**]({{< ref "job#job-failed" >}}): A job has failed.
- [**JobIncomplete**]({{< ref "job#alert-jobincomplete" >}}): A job is not complete after running for more than 12 hours.
- [**GitlabBackupIncomplete**]({{< ref "job#alert-gitlabbackupincomplete" >}}): A GitLab backup running for more than 24 hours.

### Persistent Volumes & Claims

These alerts are defined [here](https://github.com/gccloudone-aurora/aurora-platform-charts/tree/main/stable/aurora-platform/charts/aurora-core/conf/prometheus_rules/kube_prometheus_stack/pvc_alerts).

- [**PVCStorageRemainingLow**]({{< ref "persistent-volume-claims#alert-pvcstorageremaininglow" >}}) : The persistent volume claim has less than 15% storage remaining
- [**PVCStorageRemainingNone**]({{< ref "persistent-volume-claims#alert-pvcstorageremainingnone" >}}) : The persistent volume claim has less than 1% storage remaining.
- [**KubePersistentVolumeStatusFailed**](https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeerrors/) : The persistent volume has status failed.
- [**KubePersistentVolumeStatusPending**](https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeerrors/) : The persistent volume has status pending.

---
title: "Namespace Alerts"
linkTitle: "Namespace Alerts"
weight: 60
type: "docs"
draft: false
lang: "en"
---

{{% alert title="Work In Progress" color="warning" %}}
This page is currently a work in progress. Check back periodically for more information around Namespace Alert Runbooks.
{{% /alert %}}

This page describes alerts presently defined at the namespace level. They are routed to the notification channels of the Cloud Native Solutions team only when they occur in namespaces relevant to the core functionality of the Cloud Native Platform.

### Runbooks

Prometheus Alerts support any amount of arbitrary annotations. One standard practice is to define a link to a runbook documenting how to investigate or resolve the Alert.

Subpages within this section describe Runbooks for Prometheus Alerts experienced at the namespace scope within the Cloud Native Platform.

### Alerts

Alerts are defined below their respective header. They are also featured in the default rule values of the experimental [Alerting chart](https://gitlab.k8s.cloud.statcan.ca/cloudnative/k8s/charts/-/tree/master/stable/alerting).

#### Containers
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/container_alerts/container_rules.yaml).

- [**ContainerLowCPU**]({{< ref "container-low-cpu" >}}) : Container CPU usage is over 85% for more than 5 minutes.
- [**ContainerLowMemory**]({{< ref "container-low-memory" >}}) : Container memory usage is over 80% for more than 2 minutes.
- [**ContainerWaiting**]({{< ref "container-waiting" >}}) : A container is waiting for more than 15 minutes for any reason other than CrashLoopBackoff (which is captured separately by ManyContainerRestarts).
- [**ManyContainerRestarts**]({{< ref "many-container-restarts" >}}) : A container has restarted more than 10 times in the last 8 hours.
- [**CompletedJobsNotCleared**]({{< ref "completed-jobs-not-cleared" >}}) : More than *20* completed jobs within a particular namespace are older than 24 hours.

#### Pods
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/pod_alerts/pod_rules.yaml).

- [**PodNotReady**]({{< ref "pod-not-ready" >}}): A pod has been in a non-ready state for more than 15 minutes.

#### Jobs
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/job_alerts/job_rules.yaml).

- **CompletedJobsNotCleared**: There are more than 20 complete jobs over 24 hours old in a single namespace.
- [**JobFailed**]({{< ref "job-failed" >}}): A job has failed.
- [**JobIncomplete**]({{< ref "job-incomplete" >}}): A job is not complete after running for more than 12 hours.
- [**GitlabBackupIncomplete**]({{< ref "job-incomplete#gitlabbackupincomplete" >}}): A GitLab backup running for more than 24 hours.

### Persistent Volumes & Claims
These alerts are defined [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-kube-prometheus-stack/-/tree/master/prometheus_rules/pvc_alerts/pvc_rules.yaml).

- [**PVCStorageRemainingLow**]({{< ref "persistent-volume-claims#PVCStorageRemainingLow" >}}) : The persistent volume claim has less than 15% storage remaining
- [**PVCStorageRemainingNone**]({{< ref "persistent-volume-claims#PVCStorageRemainingNone" >}}) : The persistent volume claim has less than 1% storage remaining.
- [**KubePersistentVolumeStatusFailed**](https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeerrors/) : The persistent volume has status failed.
- [**KubePersistentVolumeStatusPending**](https://runbooks.prometheus-operator.dev/runbooks/kubernetes/kubepersistentvolumeerrors/) : The persistent volume has status pending.

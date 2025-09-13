---
title: "Prometheus Storage Alerts"
linkTitle: "Prometheus Storage Alerts"
weight: 5
aliases: ["/team/monitoring/clusteralerts/prometheusstorage"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## Alert: PrometheusStorageLow

PrometheusStorageLow alerts are configured to occur at the cluster level. It triggers when Prometheus disk usage is over 85% in the specified environment. This alert indicates that the storage needs to be increased for that environment.

## Alert: PrometheusDiskMayFillIn60Hours

PrometheusDiskMayFillIn60Hours alerts are configured to occur at the cluster level. It triggers when Prometheus disk usage is predicted to go over 90% within 60 hours. This alert indicates that either the storage needs to be increased for that environment or that something is consuming storage capacity at an abnormal rate.

## Resolution Process

The resolution process is shared for both alerts. Please note PrometheusDiskMayFill is "rate based", please check the Grafana dashboard for the Prometheus disk. If it is a gradual increase (with a bit of see-saw for compression), which is typically the case, proceed to the rest of the resolution process – the disk simply requires more storage. In the event there is a sudden "cliff" then it is worth checking if there have been any recent changes (new recording rules, new metrics, new data sources) that may be writing an abnormal amount of data to Prometheus' disk.

### Storage analysis

The resolution will be the same on each environment: increase the Prometheus's storage capacity. Due to different volumes of workloads in each environment, the required changes will vary. For example:
- example 1: an alert for the production cluster has been received; it was previously discussed that the retention period of the prometheus logs should be increased to 30d from 10d. In this case, the storage was quadrupled to account for tripling the retention period. This accounted for the 3x longer retention period and a 1/3 extra overheard.
- example 2: an alert for the development cluster was received; as development is constantly expanding with new projects and storage is not overly expensive, it was decided to double the storage size

### Resolution steps

1. Increase the storage size to the [next available storage pricing tier](https://azure.microsoft.com/en-us/pricing/details/managed-disks), typically by doubling the storage.
1. In the environment platform repo, increase the Helm value [`prometheusSpec.storageSpec.storage` (check for current kube-prometheus-stack version)](https://github.com/prometheus-community/helm-charts/blob/056b60ce14937355da8f5bd8e8c7bd3bd042b9d1/charts/kube-prometheus-stack/values.yaml#L2476) in the appropriate kube-prometheus-stack Helm values file and create an MR. Confirm there are no issues in the plan.
    - ex: `module_helm_kube_prometheus_stack`
1. Before merging, perform the following operations manually on the Kubernetes cluster:
    1. Scale down the Prometheus Operator to 0 replicas. This prevents the Prometheus Operator from scaling Prometheus back up too quickly in the following step.
    1. Scale down Prometheus to 0 replicas. This allows existing Prometheus pod(s) to release their PVC(s), so that the PVC(s) can be expanded.
    1. Edit the Prometheus PVC to set `spec.resources.requests.storage` to the new value. This is due to a present Kubernetes limitation where PVCs associated to a StatefulSet do not automatically expand as the corresponding StatefulSet requests more storage.
1. Merge and apply the Terraform plan. This will scale everything back up, but you may need to re-plan/re-apply once: as the Operator is coming back, there may be timeout errors for other resources that depend on it (e.g. webhooks, rule changes).
1. Wait for the Prometheus UI to come up. It might have a few minutes of no healthy upstream.
    - You can confirm the new size by querying `kubelet_volume_stats_capacity_bytes{namespace="monitoring"} / 1000000000`

### Troubleshooting

If you get the error "`forbidden: only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize`", first edit the storageclass default to add `allowVolumeExpansion: true` at the leftmost indentation.

---
title: "Persistent Volume Claim Alerts"
linkTitle: "Persistent Volume Claim Alerts"
weight: 5
aliases: ["/team/monitoring/namespacealerts/pvc"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## Alert: PVCStorageRemainingLow

 This alert fires when the persistent volume claim has less than 15% storage remaining.

## Alert: PVCStorageRemainingNone

This alert fires when the persistent volume claim has less than 1% storage remaining.

### Resolution Process

It is first important to determine if it's expected for the PVC to be nearly full or if it's erroneous behaviour. If it is expected behaviour then check section [Mitigation](#Mitigation). In either case, follow the steps below to determine if the behaviour is erroneous or not.

1. Query the prometheus server of the revelant cluster to see a historic timeline of available PV storage using the query below. Click on Graph > Press on the + button to increase the range of the timeline.

    `(kubelet_volume_stats_available_bytes{persistentvolumeclaim="yourpvchere"} / kubelet_volume_stats_capacity_bytes) * 100`

2. Investigate any unusual events in the logs for each container for the pod that uses that persistent volume claim and check codebase:

    `kubectl logs <podName> -c <containerName> -n <namespace>`

3. Investigate any unusual events for the persistent volume claim:

    `kubectl describe pvc <pvcname> -n <namespace>`

4. If nothing stands out, it may be that the application requires increased storage demands. In which case, follow the steps outlined in [Mitigation](#Mitigation).

### Mitigation

1. Re-configure how often the application writes to storage and how long that data should be retained.

2. Resize the PVC:
   1. If the storage size is specified in configuration-as-code (Helm, Terraform, ArgoCD), update this value. Proceed to the following steps in the cluster:
   1. Scale down the application
   1. Edit the PVC manifest to set `spec.resources.requests.storage` to the desired value
   1. Apply any configuration-as-code update

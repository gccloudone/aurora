---
title: "Node Alerts"
linkTitle: "Node Alerts"
weight: 5
aliases: ["/team/monitoring/clusteralerts/node"]
draft: false
---

## Node Pressure Eviction Alerts

Node pressure eviction alerts are configured to occur at the cluster level. As defined in the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/), "node-pressure eviction is the process by which the kubelet proactively terminates pods to reclaim resources on nodes". When a particular node resource such as the memory or disk space reaches a certain threshold, the kubelet can terminate one or more of the pods on the node to reclaim resources and prevent starvation.

The kubelet has the following default hard eviction thresholds:
- memory.available<100Mi
- nodefs.available<10%
- imagefs.available<15%
- nodefs.inodesFree<5%

## Alert: NodeDiskPressure
This alert is triggered when the available disk space and inodes on either the node's root filesystem or image filesystem has satisfied eviction thresholds. When this happens, Kubernetes terminates pod(s) to reduce the load on the nodes. Doing this can cause issues to the applications on the node if the application doesn't know how to handle a sudden shutdown properly.

There are two primary reasons that could cause this event. Either Kubernetes has not cleaned up any unused images, or more commonly, the disk pressure is caused by logs or application data filling up the disk space. To determine the issue, a good place to start is to find out which files are taking up the greatest amount of disk space. This can be accomplished by SSHing into the node and running the `df -h` & `du -h` commands. If it is found that the issue isn't caused by any unexpected behavior and all the data is necessary, consider increasing the size of the disk. Otherwise, if there is data on the disk that is no longer necessary to keep, delete it and if there is unexpected behavior debug the application issue.

## Alert: NodeMemoryPressure
This alert is triggered when the available memory on the node has satisfied an eviction threshold. When troubleshooting these issue the following should be considered:
- Ensure memory requests and limits are set for each container within the node.
- If resource requests and limits have already been configured, consider if the memory requests needs to be increased.
- Evaluate the memory usage of pods within the node. Ensure that applications are consuming memory efficiently. Memory usage can be viewed in Grafana dashboards or graphs of Prometheus queries.
- Consider if the node SKU can handle the resources requested by the workloads efficiently. In other words evaluate if the nodes running the workloads are tuned/appropriately fit the resources required to run the workloads.

This alert can be mitigated by setting request and limit resource settings on each container within the node. Using these attributes, one can set the amount of CPU and memory needed by the container and prevent the container from using more resources than the value set by the limit attribute. Setting a resource request will help the Kubernetes scheduler choose a node for the pod to run on since it won't schedule a pod onto a node that has less available resources than what is specified in the resource request. If the container starts to consume more memory than the configured resource limit, then the pod is terminated. When the container starts to consume more CPU then the configured resource limit, the CPU is throttled. Refer to the [official documentation on requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) for more information.

## Alert: NodePIDPressure
This alert is triggered when the available processes identifiers on the (Linux) node has fallen below an eviction threshold. In other words, it occurs when a container spawns too many processes and starves the node of available process IDs. This typically means one or more of the applications running on containers within the node is not functioning as intended and thus it needs to be examined. To prevent the node from running out of availble PIDs, one can also set a PID limit for each pod.

## Alert: NodeUnschedulable

This alert occurs at the cluster level. This alert is triggered when a node belonging to the cluster has been in the Unschedulable state for over 1 hour. The alert specifies the cluster and node name for troubleshooting.

A node may be Unschedulable for a number of reasons:
- The node may be unhealthy,
- The node may have been cordoned, marking the node as unschedulable.

### Resolution Process

The resolution process will be different depending on the root cause of the unschedulable node.

1. Verify the status of the Node in the cluster:

    `kubectl get nodes`

    - If the status of the node is *Ready,SchedulingDisabled*, Uncordon the node:

        `kubectl uncordon <nodeName>`

    - If the status of the node is anything else:

        - Determine if any other Alerts are being triggered by the node. Cross reference Alerts with existing [Cluster Alert Runbooks]({{< ref "team/monitoring-alerts/alert-cluster-level" >}}) to resolve issues accordingly.

2. After resolving the underlying issue, verify that the node is now schedulable. The node should be in the *Ready* state:

    `kubectl get nodes`

### Additional Troubleshooting

- For more detailed information, you can always describe the node:

    `kubectl describe node <nodeName>`

---
title: "NodeUnschedulable"
linkTitle: "NodeUnschedulable"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Alert: NodeUnschedulable

This alert occurs at the cluster level. This alert is triggered when a node belonging to the cluster has been in the Unschedulable state for over 1 hour. The alert specifies the cluster and node name for troubleshooting.

A node may be Unschedulable for a number of reasons:
- The node may be unhealthy,
- The node may have been cordoned, marking the node as unschedulable.

### Resolution Process

The resolution process will be different depending on the root cause of the Unschedulable node.

1. Verify the status of the Node in the cluster:

    `kubectl get nodes`

    - If the status of the node is *Ready,SchedulingDisabled*, Uncordon the node:

        `kubectl uncordon <nodeName>`

    - If the status of the node is anything else:

        - Determine if any other Alerts are being triggered by the node. Cross reference Alerts with existing [Cluster Alert Runbooks]({{< ref "/en/team/monitoring-surveillance/prometheus/cluster-alert-runbooks/" >}}) to resolve issues accordingly.

2. After resolving the underlying issue, verify that the node is now schedulable. The node should be in the *Ready* state:

    `kubectl get nodes`

### Additional Troubleshooting

- For more detailed information, you can always describe the node:

    `kubectl describe node <nodeName>`

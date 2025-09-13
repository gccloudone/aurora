---
title: "Node Pool Capacity Alerts"
linkTitle: "Node Pool Capacity Alerts"
weight: 5
aliases: ["/team/monitoring/clusteralerts/nodepool"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Node pool pod capacity alerts are configured to occur at the cluster level. As defined in the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/architecture/nodes/), Kubernetes runs workloads by placing containers into pods to run on nodes. Each node is managed by the control plane and contains the services necessary to run pods. [Kubernetes is designed to accommodate](https://kubernetes.io/docs/setup/best-practices/cluster-large/) no more than 110 pods per node. However, when nodes are created `max-pods` is set to a hard limit of 90 pods per node. When a particular node reaches a certain threshold, the following alerts are triggered:

- **NodepoolReachingPodCapacity**: Nodepool pod capacity is over 80% used.
- **NodepoolPodsFull**: Nodepool pod capacity is over 95% used.

Terminated (Succeeded or Failed) pods are not counted for these alerts because they do not prevent the scheduling of other pods onto the nodes.

## Alert: NodepoolReachingPodCapacity

This alert is triggered when the available pod capacity in the node pool has met or exceeded an 80% usage threshold. This alert is considered to have a *Minor* severity because issues are not expected as long as some pod capacity remains available. However, it serves as a warning that the nodepool may be in need of scaling soon, or that one or more workloads may be bursting to an unexpected extent.

When [assigning pods to nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/), pods can be constrained so that they are restricted to run on a particular node(s), or to prefer to run on particular nodes. In general, the scheduler will automatically do a reasonable placement based on unused resources. However, there are some circumstances where pods control which node pools they constrain their deployments to via a label selector, `nodeSelector` or `NodeAffinity`.

## Alert: NodepoolPodsFull

A more severe version of the *NodepoolReachingPodCapacity* alert, this alert has a *Critical severity* and is triggered when the available pod capacity in the node pool has met or exceeded a 95% usage threshold. When no more pods may be deployed to a node pool, pods may fail to be scheduled. Running pods can also begin to misbehave when there is no remaining pod capacity.

## Resolution Process

As the pod capacity limits become low or full, the following are some checks to verify:

- Get the list of all node pools on the cluster:

    `kubectl top nodes`

- Verify the pod count that can be allocated to each node, this is important to see remaining node pool pod capacities:

    ```bash
    > ./get_pods_per_node.sh
    Node Name                             Pod Capacity  Allocatable Pods  Scheduled Pods
    1234k8s0100000l                       90            90                0
    k8s-elasticpool1-12348451-vmss00000p  90            90                13
    k8s-linuxpool1-12348451-vmss000012    90            90                40
    k8s-linuxpool1-12348451-vmss000013    90            90                32
    k8s-linuxpool1-12348451-vmss000014    90            90                33
    k8s-master-12348451-0                 90            90                14
    ```

    > get_pods_per_node.sh script can be found [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/k8s/utilities/get-pods-per-node).

- Take a look at the pods running in a specific nodepool to see if there are any pods that are not scheduling due to a bad image name or Jobs from a CronJob that are not completing:

    `kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=<node name here>`

- Autoscaling is configured for the nodepools so new nodes should come in (up to a configured maximum) to accomodate the increased number of workloads.

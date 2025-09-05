---
title: "ContainerLowCPU"
linkTitle: "ContainerLowCPU"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Alert: ContainerLowCPU

This alert occurs at the namespace-level within a cluster. This alert will be triggered by default when a container is using up more than **85%** of its allotted CPU for more than a **five** minute period.

This alert is triggered by a pod using almost all the CPU allocated for it. When introducing a new workload or migrating an existing workload to Kubernetes, you may not be aware of the resources required. Kubernetes works best when resource restrictions and requests are established for each pod (or, more correctly, each container in each pod). Pod CPU usage is the aggregate of the CPU use of all containers in a pod.

Note that high CPU usage by a pod can lead to it being throttled.

To resolve this alert, teams can investigate the container in question to address the pod CPU usage.

### Resolution Process

1. Identify which pods currently have the highest CPU utilization: _(Note that 1000m equates to 1 Azure vCore)_

    ```kubectl top pod --sort-by=cpu -n <namespace>```

2. Investigate any unusual events in the logs for each container and check codebase:

    ```kubectl logs <podName> -c <containerName> -n <namespace>```

3. Check historic CPU utilization of the pod in Grafana or Prometheus graphs and look for potential optimizations to be made (i.e. requests)

4. Furthermore, describing the pod and checking its state can yield more information:

    ```kubectl describe pod <podName> -n <namespace>```

5. As necessary, increase the **requests** CPU and **limits** CPU. Note that requests are what the container is guaranteed to get, whereas, limits, on the other hand, is the resource threshold a container can never exceed. Setting the request of CPU more than any of the cluster nodes can handle will cause the container to be in a pending state indefinitely until there is a large enough node. You can check the nodes used by the namespace:

    ```kubectl top node -n <namespace>```

6. Ideally, teams should always [set limits and resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for their pods. However, at the namespace level, [ResourceQuotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) and [LimitRanges](https://kubernetes.io/docs/concepts/policy/limit-range/) are oftentimes defined.

### Additional Troubleshooting

* Avoid over-provisioning since you could be using a lot more resources than your workload might need. If you are using a production and development namespace, avoid defining quotas on the production namespace and define strict quotas on the development namespace. This will help you to avoid your production containers being throttled because your development environment required more resources.

* Take this opportunity to reflect on your application architecture and application scalability. The platform enables users to horizontally scale the total containers used based on their application requirements, which may change over time. This can be done with the help of a [_Horizontal Pod Autoscaler_](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). The use of a HorizontalPodAutoscaler can increase capacity and reduce overall load. It is a useful tool for dealing with resource issues or bursting of workloads since it can also act upon CPU usage.

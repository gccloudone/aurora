---
title: "ContainerLowMemory Alert Runbook"
linkTitle: "ContainerLowMemory"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Alert: ContainerLowMemory

This alert occurs at the namespace-level within a cluster. This alert will be triggered by default when a container is using up more than **80%** of its allotted memory for more than a **two** minute period.

This alert is often triggered by a pod with high memory usage relative to the amount of memory allocated for it. When introducing a new workload or migrating an existing workload to Kubernetes, you may not be aware of the resources required. Kubernetes works best when resource restrictions and requests are established for each pod (or, more correctly, each container in each pod). Memory utilization refers to the total aggregate of memory used by all containers in a pod.

Note that high memory utilization requires remediation as soon as possible. Containers that reach their memory limits get OOMKilled.
To resolve this alert, teams must debug the container in question to resolve the high memory utilization.

### Resolution Process

1. Identify which pods currently have the highest memory utilization:

    ```kubectl top pod --sort-by=memory -n <namespace>```

2. Check for memory leaks by investigating events in the logs for each container:

    ```kubectl logs <podName> -c <containerName> -n <namespace>```

3. Check historic memory usage of the pod in Grafana or Prometheus graphs and look for potential optimizations to be made (i.e. requests)

4. Furthermore, describing the pod and checking its state can yield more information:

    ```kubectl describe pod <podName> -n <namespace>```

5. As necessary, increase the **requests** memory and **limits** memory. Note that requests are what the container is guaranteed to get, whereas, limits, on the other hand, is the resource threshold a container can never exceed. Setting the request of memory more than any of the cluster nodes can handle will make the container in the pending state indefinitely until there is a large enough node. You can check the nodes used by the namespace:

    ```kubectl top node -n <namespace>```

6. Ideally, teams should always [set limits and resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for their pods. However, at the namespace level, [ResourceQuotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) and [LimitRanges](https://kubernetes.io/docs/concepts/policy/limit-range/) are oftentimes defined.


7. Check to see if the pod has multiple restarts. Oftentimes, containers that reach their memory limits get OOMKilled and trigger a restart.

    ```kubectl get pods -n <namespace> --sort-by='.status.containerStatuses[0].restartCount'```

### Additional Troubleshooting

* Avoid over-provisioning since you could be using a lot more resources than your workload might need. If you are using a production and development namespace, avoid defining quotas on the production namespace and define strict quotas on the development namespace. This will help you to avoid your production containers being evicted because your development environment required more resources.

* Take this opportunity to reflect on your application architecture and application scalability. The platform enables users to horizontally scale the total containers used based on their application requirements, which may change over time. This can be done with the help of a [_Horizontal Pod Autoscaler_](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). The use of a HorizontalPodAutoscaler can increase capacity and reduce overall load. It is a useful tool for dealing with resource issues or bursting of workloads since it can also act upon memory usage.

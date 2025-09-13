---
title: "Container Alerts"
linkTitle: "Container Alerts"
weight: 5
aliases: ["/team/monitoring/namespacealerts/container"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

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


## Alert: ContainerWaiting

This alert occurs at the Namespace level. This alert is triggered when a container has been in the _Waiting_ state for a period of time exceeding **15 minutes**.

According to Kubernetes [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) specifications, a container can either be in the _Running_, _Terminated_, or _Waiting_ state. If a container is not in either the Running or Terminiated state, it is Waiting. A container in the Waiting state is still in the process of running the operations it requires in order to complete start up. (e.g pulling the container image from a container image  registry, or applying Secret data).

### Resolution Process

1. You can view the Pod status using kubectl. When listing the Pods you should see a Status field in the output:

    ```kubectl get pods -n <namespace>```

1. Describe the pod with the Waiting container. You should see a Reason field that summarizes the behaviour:

    ```kubectl describe pod <podName> -n <namespace>```

1. Investigate any unusual events in the logs for the container:

    ```kubectl logs <podName> -c <containerName> -n <namespace>```

### Additional Troubleshooting

Pods can have multiple statuses causing them to be in the non ready state. The list below covers the most common statuses:

#### ContainerCreating
ContainerCreating implies that kube-scheduler has assigned a worker node for the container and has instructed the container runtime to kick-off the workload. However, note that the network is not provisioned at this stage — i.e, the workload does not have an IP address. Common reasons why your Pod might get stuck in the ContainerCreating stage:
1. Failure in IP address allocation
1. Failure to mount ConfigMaps
1. Failure to claim Persistent Volumes

#### CreateContainerConfigError
A Pod falls in a CreateContainerConfigError status when Kubernetes tries to create a container in a pod, but fails before the container enters the Running state. Some common causes of this error are as follows:
- **ConfigMap is missing** — a ConfigMap stores configuration data such as key-value pairs. You must identify the missing ConfigMap and create it in the namespace, or mount another, existing ConfigMap.
- **Secret is missing** — a Secret is used to store sensitive information such as credentials. You must identify the missing Secret and create it in the namespace, or mount another, existing Secret.

#### CreateContainerError
This issue occurs when Kubernetes tries to create a container but fails. It implies some sort of issue with the container runtime, but can also indicate a problem starting up the container, such as the command not existing. This symptom can also lead to [CrashLoopBackOff]({{< ref "#many-container-restarts" >}}) errors.

Examine the Events in the pod:
```kubectl describe pod <podName> -n <namespace>```

1. **"no command specified"** implies the error is caused by both the image and pod specification not specifying a command to run.
1. **"starting container process caused"** indicates that the starting command might not be available on the image. Rectify the container start command or the image's contents accordingly.
1. **"container name [...] already in use by container"** means that there is a problem with the container runtime on that host not cleaning up old containers. If you have admin access, verify the kubelet logs on the node the container was assigned to.
1. **"...is waiting to start"** means the issue may have to do with Volumes/Secrets mounting. If there is an Init container, then look at the logs, as it may be responsible for provisioning the volume.

Check any secrets and/or configmaps in the pod are available to your pods in your namespace.

#### ErrImagePull
The image could not be pulled from the repository.
1. Verify that the image repository exists.
1. Verify that you have correct access to the repository.
1. Verify that the repository and image names are spelled correctly.

#### ImagePullBackOff
This error appears when Kubernetes is not able to retrieve the image for one of the containers of the Pod.
There are three common culprits:
1.	The image name is invalid — for example, the image name was misspelt, or the image does not exist.
1.	A non-existing tag was specified for the image.
1.	The Artifactory credentials (managed by the Cloud Native Solutions team) stored in the artifactory-prod secret does not have access to the specified image.

#### InvalidImageName
The container cannot pull the image due to an invalid image name. The image name cannot be found in the local or remote Artifactory repositories:
- Verify that the correct image name (registry and image) is being used:
    ```kubectl describe pod <podName> -n <namespace>```
- Verify in the source code

## Alert: ManyContainerRestarts
This alert occurs at the Namespace-level within a cluster. This alert will be triggered when a container is subject to frequent restarts within a specified time period. (10 restarts in the last 8 hours) This alert is often triggered by a Pod that is stuck in the CrashLoopBackoff state, where a container may see many restarts in a small time window (minutes).

To resolve this alert, users must properly debug the flagged container to remediate the frequent restarts.

### Resolution Process

1. Investigate Pod Logs:

    ```kubectl -n <Namespace> logs <PodName> -c <ContainerName>```

2. Additionally, you can check the previously exited Pod Logs:

    ```kubectl -n <Namespace> logs -p <PodName> -c <ContainerName>```

3. You can also **describe** the Pod and check for useful information:

    ```kubectl -n <Namespace> describe pod <PodName>```

    - Check the Pod Events
    - Check for last terminated reason

4. Research (Google) any error codes or messages. Apply remediation steps.
    - Example: for Out-Of-Memory (OOM) errors, adjust the container resource limits to increase memory and/or check the application code for any potential memory leaks.

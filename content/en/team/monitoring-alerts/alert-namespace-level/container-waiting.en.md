---
title: "ContainerWaiting"
linkTitle: "ContainerWaiting"
weight: 10
type: "docs"
draft: false
lang: "en"
---

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

#### Common Pod Statuses
Pods can have multiple statuses causing them to be in the non ready state. The list below covers the most common statuses:

##### ContainerCreating
ContainerCreating implies that kube-scheduler has assigned a worker node for the container and has instructed the container runtime to kick-off the workload. However, note that the network is not provisioned at this stage — i.e, the workload does not have an IP address. Common reasons why your Pod might get stuck in the ContainerCreating stage:
1. Failure in IP address allocation
1. Failure to mount ConfigMaps
1. Failure to claim Persistent Volumes

##### CreateContainerConfigError
A Pod falls in a CreateContainerConfigError status when Kubernetes tries to create a container in a pod, but fails before the container enters the Running state. Some common causes of this error are as follows:
- **ConfigMap is missing** — a ConfigMap stores configuration data such as key-value pairs. You must identify the missing ConfigMap and create it in the namespace, or mount another, existing ConfigMap.
- **Secret is missing** — a Secret is used to store sensitive information such as credentials. You must identify the missing Secret and create it in the namespace, or mount another, existing Secret.

##### CreateContainerError
This issue occurs when Kubernetes tries to create a container but fails. It implies some sort of issue with the container runtime, but can also indicate a problem starting up the container, such as the command not existing. This symptom can also lead to [CrashLoopBackOff]({{< ref "team/monitoring-alerts/alert-namespace-level/many-container-restarts" >}}) errors.

Examine the Events in the pod:
```kubectl describe pod <podName> -n <namespace>```

1. **"no command specified"** implies the error is caused by both the image and pod specification not specifying a command to run.
1. **"starting container process caused"** indicates that the starting command might not be available on the image. Rectify the container start command or the image's contents accordingly.
1. **"container name [...] already in use by container"** means that there is a problem with the container runtime on that host not cleaning up old containers. If you have admin access, verify the kubelet logs on the node the container was assigned to.
1. **"...is waiting to start"** means the issue may have to do with Volumes/Secrets mounting. If there is an Init container, then look at the logs, as it may be responsible for provisioning the volume.

Check any secrets and/or configmaps in the pod are available to your pods in your namespace.

##### ErrImagePull
The image could not be pulled from the repository.
1. Verify that the image repository exists.
1. Verify that you have correct access to the repository.
1. Verify that the repository and image names are spelled correctly.

##### ImagePullBackOff
This error appears when Kubernetes is not able to retrieve the image for one of the containers of the Pod.
There are three common culprits:
1.	The image name is invalid — for example, the image name was misspelt, or the image does not exist.
1.	A non-existing tag was specified for the image.
1.	The Artifactory credentials (managed by the Cloud Native Solutions team) stored in the artifactory-prod secret does not have access to the specified image.

##### InvalidImageName
The container cannot pull the image due to an invalid image name. The image name cannot be found in the local or remote Artifactory repositories:
- Verify that the correct image name (registry and image) is being used:
    ```kubectl describe pod <podName> -n <namespace>```
- Verify in the source code

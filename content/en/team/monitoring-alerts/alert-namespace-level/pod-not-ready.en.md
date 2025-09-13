---
title: "Pod Alerts"
linkTitle: "Pod Alerts"
weight: 5
aliases: ["/team/monitoring/namespacealerts/pod"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## Alert: PodNotReady

This alert occurs at the namespace-level within a cluster. This alert will be triggered by default when a Pod is in a non-ready state for longer than **fifteen** minutes.

Note that a pending Pod will block the Pod from moving onto the next stage of the [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/). The PodNotReady is an alert that catches Pods that are stuck in the "Pending" or "Unknown" [pod phase](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase), which can occur without a ContainerWaiting reason.

To resolve this alert, teams can investigate the Pod in question to address the non-ready state.

### Resolution Process

1. Identify which Pods are currently not running and not ready:

    ```kubectl get pods -n <namespace>```

1. Retrieve the logs of the containers of the Pod and investigate why it failed:

    ```kubectl logs <pod name> -n <namespace>```

1. If you are unable to see the logs because your container is restarting too quickly, you can print the error messages from the previous container:

    ```kubectl logs <pod-name> --previous -n <namespace>```

1. Retrieve a list of events associated with the Pod to inspect and analyze any errors:

    ```kubectl describe pod <pod name> -n <namespace>```

1. If a Pod is Running but not Ready it means that the Readiness probe is failing. When the Readiness probe is failing, the Pod is not attached to the Service, and no traffic is forwarded to that instance. A failing Readiness probe is an application-specific error, so you should inspect the Events section in kubectl describe to identify the error.

1. Extract the YAML definition of the Pod as stored in Kubernetes:

    ```kubectl get pod <pod name> -n <namespace>```

1. Run an interactive command within one of the containers of the Pod:

    ```kubectl exec -ti <pod name> -- bash-n <namespace>```

### Additional Troubleshooting

#### Pending State

Oftentimes, when a Pod is created, the Pod stays in the _Pending_ state. Assuming that the cluster scheduler is running fine, here are some potential causes:

- The current Namespace has a ResourceQuota object and creating the Pod will make the Namespace go over the quota.
- The Pod is bound to a Pending PersistentVolumeClaim.

#### Unknown State

If the container cannot start for some reason, and the state of the Pod cannot be obtained, the Pod falls in an _Unknown_ state. This typically occurs due to an error in communicating with the node where the Pod should be running.

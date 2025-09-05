---
title: "ManyContainerRestarts"
linkTitle: "ManyContainerRestarts"
weight: 10
type: "docs"
draft: false
lang: "en"
---

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

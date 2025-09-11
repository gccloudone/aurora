---
title: "Job Alerts"
linkTitle: "Job Alerts"
weight: 5
aliases: ["/team/monitoring/namespacealerts/job"]
draft: false
---

## Alert: JobFailed

This alert occurs at the namespace-level within a cluster. This alert will be triggered when a Kubernetes Job has failed to complete. It is based on a Job having the status `Failed`, and will therefore repeat until the failed Job is deleted from the cluster.

By default, a [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/) will run uninterrupted unless a Pod fails, or a container exits in error. At this point, a Job defers to a specified [backoff failure policy](https://kubernetes.io/docs/concepts/workloads/controllers/job/#pod-backoff-failure-policy). Once the defined *backoff limit* is reached, the Job will be marked as failed and any running Pods will be terminated.

### Resolution Process

As always, troubleshooting and resolution of these errors can be done via *kubectl*, through the *Lens IDE*, or a combination of both depending on the developers' preferences. To resolve this error, you will need to navigate to the specific cluster and namespace that is experiencing the issue.

The following steps can be used to determine the root cause as well as establishing a solution:

1. Navigate to the appropriate cluster that is experiencing the issue.
    - Set your KUBECONFIG, or navigate to the cluster in Lens.

2. Analyze the failed Job. View the Job resource's *status* section. Here, there may have information regarding the root cause given by the *reason* and *message* fields:

    `kubectl -n <namespace> describe job <jobName>`

    - For example, you may see information such as:
        - "reason: DeadlineExceeded , message: Job was active longer than specific deadline"
        - "reason: BackoffLimitExceeded , message: Job has reached the specified backoff limit"

3. Determine the underlying root cause.
    - From the analysis above, determine the underlying root cause related to the reason. You may need to research online, or collaborate with team members who may have previous experience.

4. Implement the solution. Once the root cause has been identified, prepare and implement the appropriate solution. This may include:
    - Increasing resources for the Job (cpu, memory)
    - Modifying the spec's *backoffLimit* to increase the number of retries before considering a Job as failed
        - In cases where we know for certain a Job may take a long time and timeout, this could be a solution.

5. (If applicable) Delete or remove old Jobs that are stuck in the *JobFailed* state.
    - Recall that the alert will keep firing until this Job is removed.
    - Once the issue has been resolved, you can delete old Jobs to remediate the alert.

### Additional Troubleshooting

- Depending on the situation, you may or may not have access to *Pod* logs related to the Job. You will see these Pods available while the Job is running. However, once a Job has failed its Pods will disappear.
    - You may be able to catch the pods at the right time, to analyze pod logs, or to shell into the containers for further troubleshooting. However, this should not be the priority during the above Resolution Process

- Most Kubernetes Jobs within Aurora are usually controlled by a simiarily named *CronJob* resource. Additional troubleshooting can be done using the CronJob resource:
    - Inspect the resource using Lens or kubectl:  `kubectl -n <namespace> describe CronJob <CronJobName>`
        - You can view information such as the *schedule*, *lastSuccesfulTime*, *lastScheduledTime*, the *backoffLimit* value, as well as the *successfulJobsHistoryLimit* and *failedJobsHistoryLimit* values.

    - Analyze the jobs history:
        - When did the job start failing? How many times has it failed? When was the last successful job? Is this the first occurence of a failure?

    - Depending on the CronJob, you could also temporarily modify the Job to run more often so that you could analyze pod logs while the job runs
        - Modify the *schedule* to make the CronJob run based on your specifications, and analyze the pod logs.

## Alert: JobIncomplete

This alert occurs at the namespace-level within a cluster and will be triggered when a given Job is taking more than 12 hours to complete. To troubleshoot this Alert, you will need to determine why the Job may be failing to complete successfully, as well as apply remediation steps to fix the Job.

This Alert could highlight an issue with the Job resource itself, or an underlying issue related to cluster resources, or Job scheduling etc.

### Resolution Process

As always, troubleshooting and resolution of these errors can be done via *kubectl*, through the *Lens IDE*, or a combination of both depending on the developers' preferences. Recall that in some cases however, it may be ideal to double-check on the Job resource through *kubectl* (kubectl describe), as Lens may not always display the most up-to-date information.

To resolve this error, you will need to navigate to the specific cluster and namespace that is experiencing the issue:
1. Navigate to the appropriate cluster that is experiencing the issue.
    - Set your KUBECONFIG, or navigate to the cluster in Lens.

There will be a couple of different steps required to address the JobIncomplete Alert:
1. Identify the root cause
2. Apply changes for remediation
3. Verify the Job succeeds

#### 1. Identify root cause

In order to identify the root cause of the failed Job, analyze the Job resource to determine which errors may be occuring.
`kubectl -n <namespace> describe job <jobName>`

You may see some relevant information within the Job resource. Within the Job, you can determine the number of *pods* that have *Succeeded*, *Failed*, or are still *Running*.

Most importantly, navigate to the *Events* section of the resource. Here, you will see all *Informational*, *Warning*, and *Errors* messages associated with the Job. You may be able to identify the exact name of the *pods* the Job is using.

Alternatively, you could list all Pods that belong to a Job in a machine readable form, using a command similar to the following. You should see the list of Pods as the output:
```bash
pods=$(kubectl get pods --selector=job-name=<jobNameHere> --output=jsonpath='{.items[*].metadata.name}')
echo $pods
```

To further diagnose, you will need to analyze these pods! Analyze the pod logs for each of the Pods to help determine the root cause:

`kubectl -n <namespace> logs <podName>`

Analyze the log contents for any errors, or even warnings, that may help diagnose the issue.

#### 2. Apply changes for remediation

Depending on the underlying root cause, there are a number of changes you may have to make to remediate the Alert.

Some examples of remediation may include:
- Modify the Job (or the CronJob) to edit values associated with [Job termination and cleanup:](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup)
    - restartPolicy,
    - backoffLimit: if you need to increase or decrease this threshold
    - activeDeadlineSeconds: if the Job fails for a *DeadlineExceeded* event
- Scaling up cluster resources - in cases where the Job fails due to lack of resources (Memory, CPU)

#### 3. Verify the Job succeeds

Once the remediation steps have been implemented, the Job will continue its progress and attempt to correct itself. You will need to monitor the Job to ensure that the Job runs and completes successfully after applying your fix.

If remediation was successful, the Job should run to completion and finish its task.
- Verify that the Job has completed
- Verify that the previous *JobIncomplete* Alerts now show up as 'Resolved' in our various Alert channels
- Verify that no new instances of the Alert occur for the same Job

### Additional Troubleshooting

If remediation was not successful, the Job may fail again. You may experience more instances of the *JobIncomplete* Alert if the root cause has not been fixed. Alternatively, different Alerts may fire based on the existence of any new errors or events.
- If you are still encountering the JobIncomplete error, simply re-iterate through the resolution process again to try and identify a new root cause, or to re-evaluate your previous attempt.
- If new Alerts are being fired on the Job resource, you will need to refer to the Cluster or Namespace Alert's [Prometheus Runbook documentation]({{< ref "team/monitoring-alerts/prometheus" >}} "Prometheus Documentation") to determine the appropriate resolution process.

## GitlabBackupIncomplete

This alert occurs within **gitlab** namespace of the the Management cluster, and will be triggered when a gitlab-backup job is taking more than 24 hours to complete. To troubleshoot this alert, you will need to determine why the Job may be failing to complete successfully.

This alert could indicate an issue with the Job resource itself, or an underlying issue related to cluster resources, or Job scheduling etc.

As this alert is a less sensitive version of JobIncomplete alert, the resolution process may be similar to the steps outlined [above](#resolution-process).

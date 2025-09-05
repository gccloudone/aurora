---
title: "JobFailed"
linkTitle: "JobFailed"
weight: 10
type: "docs"
draft: false
lang: "en"
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

- Most Kubernetes Jobs within the CNP are usually controlled by a simiarily named *CronJob* resource. Additional troubleshooting can be done using the CronJob resource:
    - Inspect the resource using Lens or kubectl:  `kubectl -n <namespace> describe CronJob <CronJobName>`
        - You can view information such as the *schedule*, *lastSuccesfulTime*, *lastScheduledTime*, the *backoffLimit* value, as well as the *successfulJobsHistoryLimit* and *failedJobsHistoryLimit* values.

    - Analyze the jobs history:
        - When did the job start failing? How many times has it failed? When was the last successful job? Is this the first occurence of a failure?

    - Depending on the CronJob, you could also temporarily modify the Job to run more often so that you could analyze pod logs while the job runs
        - Modify the *schedule* to make the CronJob run based on your specifications, and analyze the pod logs.

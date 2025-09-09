---
title: "CompletedJobsNotCleared"
linkTitle: "CompletedJobsNotCleared"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Alert: CompletedJobsNotCleared

This alert occurs at the namespace-level within a cluster and will be triggered when more than *20* completed jobs within a particular namespace are older than 24 hours. This alert indicates that certain completed jobs may need to be cleaned up or that there is an issue preventing jobs from completing successfully.

### Resolution Process

As always, troubleshooting and resolution of these errors can be done via kubectl, through the Lens IDE, or a combination of both depending on the developers' preferences. To resolve this error, you will need to navigate to the specific cluster and namespace that is experiencing the issue.

If the completed jobs identified are backed by a CronJob resource and they seem to be piling up quickly, you can configure [job history limits](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#jobs-history-limits) and let Kubernetes automatically clean up resources based on this history limit.

Otherwise, you will need to clean up the completed jobs within the namespace manually (i.e. deleting 1-by-1), or through an automated process. Additionally, you can also check the configuration of what is generating these jobs (i.e. the Helm chart for a particular application) to see if it has settings available for job management.

**Option 1: Manual cleanup**

You can manually clean up the completed jobs individually, with *kubectl* or through the *Lens*.

To manually cleanup the Jobs using *Lens*, simply navigate to the appropriate namespace and resources, and utlize built-in functionality to perform deletions and/or modifications of resources.

To manually cleanup the Jobs using *kubectl*, follow the steps defined below:

* List all of the completed Jobs in the namespace for the Job being identified by the alert. For the grep component, you can use part of the Job name as an identifier:
`kubectl -n <namespace> get jobs | grep "<Job-Name-Identifier>"`

* Delete each completed Job from the list above, using the Job's name:
`kubectl -n <namespace> delete jobs <Job-Name-Here>`

* Alternatively, you can combine these commands together to delete all successfully completed jobs within a namespace:
`kubectl -n <namespace> delete jobs --field-selector status.successful=1 `

**Option 2: Automated cleanup with TTL mechanism for finished Jobs**

In Kubernetes v1.21, there is an additional TTL (time-to-live) mechanism that could be leveraged to clean up jobs automatically. This TTL mechanism is provided by a [TTL controller](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/) for finished resources, by specifying the `.spec.ttlSecondsAfterFinished` field of the Job.

When the TTL controller cleans up the Job, it will delete the Job cascadingly, i.e. delete its dependent objects, such as Pods, together with the Job. Note that when the Job is deleted, its lifecycle guarantees, such as finalizers, will be honoured.

For example, within the Job resource, you specify the ttlSecondsAfterFinished value as seen in the snippet below:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: example-job
spec:
  ttlSecondsAfterFinished: 100
  template:
    spec:
      containers:
      ...
```

This could also be relevant for failed Jobs too. If the above mechanism is used, we may want to set the `ttlSecondsAfterFinished` value to a more generous number (days, or weeks) depending on established retention policies.

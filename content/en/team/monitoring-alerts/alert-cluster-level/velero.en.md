---
title: "Velero"
linkTitle: "Velero"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Velero alerts
Velero is an open source tool used to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes. A velero alerts occurs when a Velero backup isn't functioning as intended. Currently there are three kinds of Velero alerts:
- backup failure
- backup partial failure
- backup taking a long time

When a Velero alert fires, the first step is to find out what the problem is. This can be done by parsing the logs of the backup & Velero server pod. The Velero CLI is used to fetch some of these details. After discovering what the problem is, the solution is typically straightforward. The process to gather the nessessary information can found by following the instruction outlined below (refer to the velero troubleshooting [documentation](https://velero.io/docs/v1.3.2/troubleshooting/) for more information).

1. [Configure](https://velero.io/docs/v0.11.0/namespace/) the Velero client commands to use same namespace that the Velero server is located in by running the following command:
`
velero client config set namespace=<NAMESPACE_VALUE>
`
Note: the default namespace that the CLI uses is the *velero* namespace. If you do need to change the namespace of the Velero client commands, instead of configuring the namespace for all subsequent comamnds, one can just use the --namespace global flag.

2. Describe the backup to view a summary of the backup details.
`
velero backup describe <BACKUP NAME> | grep error
`

3. Output the Velero backup logs. This is useful for viewing failures and warning, including resources that could not not be backed up.
`
velero backup logs <BACKUP NAME>
`

> Note: The log file can also be downloaded directly from the source, an Azure storage account the logs are stored in. The name and resource group of the Azure storage account used can be found in the BackupStorageLocation CRD.

4. View the logs on the Velero server pod.
`
kubectl logs deployment/velero  -n <NAMESPACE>
`

> Note: one can also view the logs within Lens by navigating to the Velero server pod within the UI and clicking the logs button. To view the logs within the Azure storage account, the user must have the nessessary read permission on the container and blobs and the user must also have network access. Currently, one can view the data plane of the storage account from a VM workstation in the `workstationscc-operator` subnet.

---
title: "Velero Alerts"
linkTitle: "Velero Alerts"
weight: 5
aliases: ["/team/monitoring/clusteralerts/velero"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

Velero is an open source tool used to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes. A velero alerts occurs when a Velero backup isn't functioning as intended. Currently there are three kinds of Velero alerts:

- Backup failure
- Backup partial failure
- Backup taking a long time

## Resolution Process

The resolution process for the different Velero alerts remain generally the same. Investigate what is causing the issue by checking the backup details, the backup logs, and the logs of the Velero pod and address the source of the issue. For further documentation, refer to the Velero [troubleshooting guide](https://velero.io/docs/v1.3.2/troubleshooting/)

> **_NOTE:_**  Ensure you have the `velero` CLI tool installed.

1. [Configure](https://velero.io/docs/v0.11.0/namespace/) the Velero client commands to use the same namespace that the Velero server is located in by running the following command:
`
velero client config set namespace=velero-system
`

> **_NOTE:_**  By default, the velero CLI assumes that velero is installed in the `velero` namespace unless otherwise specified using the above command or by passing in the `--namespace` global flag.

1. Describe the backup to view a summary of the backup details.
`
velero backup describe <BACKUP NAME> --details | grep error
`

1. Output the Velero backup logs. This is useful for viewing failures and warnings, including resources that could not not be backed up.
`
velero backup logs <BACKUP NAME>
`

1. View the logs on the Velero server pod.
`
kubectl logs deployment/velero  -n <NAMESPACE>
`

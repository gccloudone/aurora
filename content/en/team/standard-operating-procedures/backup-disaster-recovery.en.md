---
title: "Backup Disaster Recovery Testing Procedure"
linkTitle: "Backup Disaster Recovery Testing Procedure"
weight: 5
aliases: ["/team/sop/backup-disaster-recovery"]
date: 2025-08-19
draft: false
---

# Disaster Recovery Testing Procedure

This document outlines the steps Aurora administrators must follow to perform disaster recovery testing, ensuring that Velero backups are being restored correctly.

## Context

Aurora clusters use [Velero](https://velero.io/docs/v1.16/) to back up and restore Kubernetes cluster resources and persistent volumes. This procedure is designed to verify the reliability of these backups.

## Setup

Ensure that you have the Velero command line tool installed. Prior to testing, the cluster shall have a test namespace. This namespace shall include a busybox deployment and a persistent volume claim that the busybox deployment will use. The Aurora admin shall shell into the busybox container and write a file to the path that is being mounted. For example:

1. `kubectl exec -it <pod-name> --container <busybox-container-name> -n <test-namespace> -- /bin/bash`

2. `echo “test”  > <mountPath>/testfile`

3. `cat <mountPath>/testfile` (Ensure the output is “test”)

## Procedure

This test shall be performed **monthly** for all Aurora clusters.  First ensure that the test namespace exists and that the `testfile` described in the setup section exists. Then execute the following actions:


1. ```velero backup create backuptest-yyyy-mm-dd --include-namespaces <test-namespace> –-volume-snapshot-location <volume-snapshot-location-name> --backup-storage-location <backup-storage-location-name> -n velero-system```

2.  `kubectl delete namespace -n <test-namespace>`

3.  Wait for backup to be completed. This can be checked by performing:

	-	`velero backup describe backuptest-yyyy-mm-dd  --details -n velero-system`

4. `velero restore create restoretest-yyyy-mm-dd --from-backup backuptest-yyyy-mm-dd`

5. Wait for the restore to be completed. This can be checked by performing

	-	`velero restore describe restoretest-yyyy-mm-dd --details -n velero-system`

6. `kubectl exec -it <pod-name> --container busybox -n <test-namespace> -- /bin/bash`

7. `cat /data/test`
	- The output should be "test". 
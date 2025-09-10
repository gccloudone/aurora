---
title: "Backup and Disaster Recovery"
linkTitle: "Backup and Disaster Recovery"
weight: 5
aliases: ["/team/sop/backup-disaster-recovery"]
date: 2025-08-19
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This document outlines the steps Aurora administrators must follow in order to test disaster recovery, ensuring that Velero backups would be restored correctly.

## Context

Aurora clusters use [Velero](https://velero.io) to back up and restore Kubernetes cluster resources and persistent volumes.

This procedure verifies the reliability of those backups.

## Setup

Before testing, ensure the following:

- The **Velero CLI** is installed.
- A **test namespace** exists, containing:
  - A **BusyBox deployment**
  - A **PersistentVolumeClaim (PVC)** mounted into the BusyBox container

### Preparing the Test File

1. Shell into the BusyBox container:
   ```bash
   kubectl exec -it <pod-name> \
     --container <busybox-container-name> \
     -n <test-namespace> -- /bin/bash
   ```

2. Write a test file to the mounted path:
   ```bash
   echo "test" > <mountPath>/testfile
   ```

3. Verify the file contents:
   ```bash
   cat <mountPath>/testfile
   ```
   - Output must be: `test`

## Procedure

1. Create a backup:
   ```sh
   velero backup create backuptest-YYYY-MM-DD \
     --include-namespaces <test-namespace> \
     --volume-snapshot-location <volume-snapshot-location-name> \
     --backup-storage-location <backup-storage-location-name>  \
     -n velero-system
   ```

2. Confirm the backup completed:
   ```sh
   velero backup describe backuptest-YYYY-MM-DD \
     --details -n velero-system
   ```

3. Delete the test namespace:
   ```sh
   kubectl delete namespace <test-namespace>
   ```

4. Restore from the backup:
   ```sh
   velero restore create restoretest-YYYY-MM-DD \
     --from-backup backuptest-YYYY-MM-DD
   ```

5. Confirm the restore completed:
   ```sh
   velero restore describe restoretest-YYYY-MM-DD \
     --details -n velero-system
   ```

6. Shell into the restored BusyBox pod:
   ```sh
   kubectl exec -it <pod-name> \
     --container busybox \
     -n <test-namespace> -- /bin/bash
   ```

7. Verify the restored file:
   ```sh
   cat <mountPath>/testfile
   ```
   - Output must be: `test`

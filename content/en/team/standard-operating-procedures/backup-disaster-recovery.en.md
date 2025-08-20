---
title: "Backup Disaster Recovery Testing Procedure"
linkTitle: "Backup Disaster Recovery Testing Procedure"
weight: 5
aliases: ["/team/sop/backup-disaster-recovery"]
date: 2025-08-19
draft: false
---

# Disaster Recovery Testing Procedure

This document outlines the steps Aurora administrators must follow to test disaster recovery, ensuring that Velero backups are restored correctly.

## Context

Aurora clusters use [Velero](https://velero.io/docs/v1.16/) to back up and restore Kubernetes cluster resources and persistent volumes.  
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
   kubectl exec -it <pod-name> --container <busybox-container-name> -n <test-namespace> -- /bin/bash
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

This test must be performed **monthly** for all Aurora clusters.

1. Create a backup:
   ```bash
   velero backup create backuptest-YYYY-MM-DD      --include-namespaces <test-namespace>      --volume-snapshot-location <volume-snapshot-location-name>      --backup-storage-location <backup-storage-location-name>      -n velero-system
   ```

2. Delete the test namespace:
   ```bash
   kubectl delete namespace <test-namespace>
   ```

3. Confirm the backup completed:
   ```bash
   velero backup describe backuptest-YYYY-MM-DD --details -n velero-system
   ```

4. Restore from the backup:
   ```bash
   velero restore create restoretest-YYYY-MM-DD --from-backup backuptest-YYYY-MM-DD
   ```

5. Confirm the restore completed:
   ```bash
   velero restore describe restoretest-YYYY-MM-DD --details -n velero-system
   ```

6. Shell into the restored BusyBox pod:
   ```bash
   kubectl exec -it <pod-name> --container busybox -n <test-namespace> -- /bin/bash
   ```

7. Verify the restored file:
   ```bash
   cat /data/testfile
   ```
   - Output must be: `test`

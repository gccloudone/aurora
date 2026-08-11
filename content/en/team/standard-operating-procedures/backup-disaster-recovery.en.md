---
title: "Backup and Disaster Recovery"
linkTitle: "Backup and Disaster Recovery"
weight: 5
aliases: ["/team/sop/backup-disaster-recovery"]
date: 2026-08-11
draft: false
---

{{< translation-note >}}

This document outlines the steps Aurora administrators must follow to test disaster recovery and confirm that Velero backups can be restored correctly.

## Context

Aurora clusters use [Velero](https://velero.io) to back up and restore Kubernetes cluster resources and persistent volumes. A backup is only useful if it can actually be restored, so backups should be tested on a regular basis rather than assumed to work.

This procedure verifies this reliability end to end: it writes known data to a persistent volume, backs it up, deletes the namespace to simulate data loss, restores it, and checks that the data comes back unchanged. Run it periodically and whenever the Velero configuration or version changes.

## Setup

The test needs an isolated workload with a persistent volume so that restoring it does not affect real applications. Before testing, ensure the following are in place:

- The Velero CLI is installed, so you can create and inspect backups and restores from your workstation. Its version must match the version of the Velero container image running in the cluster.
- A dedicated test namespace exists, containing:
  - A BusyBox deployment to act as a lightweight, disposable workload.
  - A `PersistentVolumeClaim` (PVC) mounted into the BusyBox container, which provides the persistent volume whose data the test will verify.

### Preparing the test file

First, place a known piece of data on the persistent volume. This gives you something concrete to check for after the restore, confirming that the volume's contents survived the backup and restore cycle.

1. Shell into the BusyBox container, replacing the placeholders with your pod, container, and namespace names:

   ```sh
   kubectl exec -it <pod-name> \
     --container <busybox-container-name> \
     -n <test-namespace> -- /bin/sh
   ```

2. Write a test file to the mounted volume path:

   ```sh
   echo "test" > <mountPath>/testfile
   ```

3. Verify the file was written correctly:

   ```sh
   cat <mountPath>/testfile
   ```

   The output must be `test`. If it is, the known data is in place and you can proceed to the backup procedure.

## Procedure

The test backs up the namespace, deletes it to simulate data loss, then restores it from the backup and confirms the test file survived intact.

Backup and restore names must be unique, so the examples below append a timestamp (`YYYY-MM-DD-HHMM`). Replace it with the current date and time, and use the same value consistently within a single run.

1. Create a backup of the test namespace, including its persistent volume snapshot:

   ```sh
   velero backup create backuptest-YYYY-MM-DD-HHMM \
     --include-namespaces <test-namespace> \
     --volume-snapshot-locations <volume-snapshot-location-name> \
     --storage-location <backup-storage-location-name> \
     -n velero-system
   ```

2. Confirm the backup completed. Check that the `Phase` field reads `Completed` before continuing; do not proceed if the backup failed or is still in progress:

   ```sh
   velero backup describe backuptest-YYYY-MM-DD-HHMM \
     --details -n velero-system
   ```

3. Delete the test namespace to simulate data loss. This removes the BusyBox workload and its persistent volume, so the only way to get the data back is through the restore:

   ```sh
   kubectl delete namespace <test-namespace>
   ```

4. Restore the namespace from the backup you just created:

   ```sh
   velero restore create restoretest-YYYY-MM-DD-HHMM \
     --from-backup backuptest-YYYY-MM-DD-HHMM \
     -n velero-system
   ```

5. Confirm the restore completed. As with the backup, check that the `Phase` field reads `Completed`:

   ```sh
   velero restore describe restoretest-YYYY-MM-DD-HHMM \
     --details -n velero-system
   ```

6. Once the restored pod is running, shell into it to inspect the recovered volume:

   ```sh
   kubectl exec -it <pod-name> \
     --container <busybox-container-name> \
     -n <test-namespace> -- /bin/sh
   ```

7. Verify that the restored file is intact:

   ```sh
   cat <mountPath>/testfile
   ```

   The output must be `test`, matching the data you wrote during setup.

If the restored file contains `test`, the backup and restore process is working correctly. If the file is missing or its contents differ, the persistent volume data was not restored as expected. Record the failure and investigate before relying on Velero for recovery.

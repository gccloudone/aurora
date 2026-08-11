---
title: "Performing an AKS Cluster Upgrade"
linkTitle: "AKS Cluster Upgrade"
weight: 5
aliases: ["/team/sop/aks-cluster-upgrade"]
date: 2026-08-11
draft: false
---

{{< translation-note >}}

This document outlines the process for upgrading an AKS cluster.

## Preparing your environment

Ensure the following command line tools are installed and up to date:

- **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)**: must be within 1 minor version of the new cluster version.
- **[Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)**: manages the AKS cluster.
- **[velero](https://github.com/vmware-tanzu/velero/releases)**: must match the version of Velero used in the target cluster.
- **[jq](https://jqlang.github.io/jq/download/)**: exports and processes pod information.
- **[pluto](https://pluto.docs.fairwinds.com/installation/)**: detects deprecated and removed Kubernetes API versions.
- **[asdf](https://asdf-vm.com/guide/getting-started.html)** (optional): a version manager for switching between tool versions (such as kubectl), useful when stepping through multiple Kubernetes minor versions in one upgrade.

Also ensure that your environment will not be automatically shut down during the maintenance period.

## Upgrading the cluster

Before following the procedure, ensure your environment is set up as described in [Preparing your environment](#preparing-your-environment), and read the [Troubleshooting](#troubleshooting) section before carrying out the upgrade.

### 1. Verify deprecated APIs

Use pluto to check whether there are any deprecated APIs in the new cluster version.

```bash
pluto detect-all-in-cluster k8s=new-cluster-version
```

Record any deprecated or removed APIs on the Jira ticket. For each one, locate the manifests that still use the old `apiVersion` (for example, in the relevant Helm charts or Kubernetes manifests) and update them to the supported version before continuing. Do not proceed with the upgrade until pluto reports no deprecated APIs that would be removed in the target version.

### 2. Record pods that aren't Running or Succeeded

Run the following two commands to export the information of pods and containers that may be in a bad state:

```bash
kubectl get pods -A -o json | jq '.items[] | select(.status.phase|test("Succeeded|Running")|not) | {namespace: .metadata.namespace, name: .metadata.name, phase: .status.phase}' | jq '{pods:[inputs]}'

kubectl get po -A | grep -v Running | grep -v Completed
```

Add the output of these commands to the Jira ticket for this cluster upgrade, along with any easily available supporting information (such as error messages in the events of those pods).

### 3. Back up the cluster

To allow for restoration in the event of a catastrophic failure during the upgrade, take a full snapshot of the cluster (resources and disks) using Velero.

First, find the snapshot location for the current cluster and store its name in a variable:

```bash
velero -n velero-system snapshot-location get
SNAPSHOT_LOCATION_NAME=<Name from the output above>
```

Then create the backup. Replace `YYYYMMDDHHMM` with the current timestamp so the backup name is unique; `--ttl 168h` retains it for 7 days:

```bash
velero -n velero-system backup create backup-YYYYMMDDHHMM --include-cluster-resources --volume-snapshot-locations $SNAPSHOT_LOCATION_NAME --ttl 168h
```

Finally, monitor the backup until it completes. Watch the `Phase` indicator: `Completed` is expected, and `PartiallyFailed` is usually acceptable for a cluster upgrade:

```bash
velero -n velero-system backup describe backup-YYYYMMDDHHMM
```

### 4. Upgrade the control plane

Log in with the Azure CLI and set your subscription to the one the target cluster lives in.

```bash
az login
az account list -o table
az account set --subscription <Subscription Name or ID>
```

Then, get the available upgrade versions:

```bash
az aks get-versions -l canadacentral -o table
```

Set the following local variables, which are used throughout the upgrade:

```bash
CLUSTER_RESOURCE_GROUP=<Name of cluster resource group>
CLUSTER_NAME=<Name of cluster>
KUBERNETES_VERSION=<New kubernetes upgrade version>
```

Finally, upgrade the control plane to your target version (`$KUBERNETES_VERSION`). AKS upgrades one minor version at a time, so if you are more than one minor version behind, repeat this step for each successive version:

```bash
az aks upgrade -g $CLUSTER_RESOURCE_GROUP -n $CLUSTER_NAME --control-plane-only -k $KUBERNETES_VERSION --no-wait
```

At this point, as well as later when upgrading the data plane, there is occasionally a glitch where the following message is displayed:

```text
The cluster is already on version <old kubernetes version> and is not in a failed state. No operations will occur when upgrading to the same version if the cluster is not in a failed state. (y/n)
```

If you encounter it, proceed with `y`.

Confirm that the control plane has been updated.

```bash
kubectl version
```

### 5. Upgrade the node pools

Upgrading the node pools evicts all workloads from the old nodes and reschedules them onto new ones, respecting any `PodDisruptionBudgets` that target the affected pods.

List the node pools:

```bash
az aks nodepool list -g $CLUSTER_RESOURCE_GROUP --cluster-name $CLUSTER_NAME -o table
```

For each node pool, run the following using the same Kubernetes version as the control plane.

<gcds-alert alert-role="danger" container="full" heading="Danger" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>DO NOT upgrade node pools in different Availability Zones (AZs) at the same time. You may upgrade multiple node pools within the same AZ together to speed up the process.</gcds-text>
</gcds-alert>

For example, if the cluster has two zones of node pools:

- Zone 1: gateway1, system1, general1
- Zone 2: gateway2, system2, general2

Upgrade all three Zone 1 node pools together, and only once they have finished, move on to the Zone 2 node pools.

```bash
az aks nodepool upgrade -g $CLUSTER_RESOURCE_GROUP --cluster-name $CLUSTER_NAME -k $KUBERNETES_VERSION --no-wait -n <Name of node pool>
```

Continue to check on the status of the upgrade by running:

```bash
az aks nodepool list -g $CLUSTER_RESOURCE_GROUP --cluster-name $CLUSTER_NAME -o table
```

Continuously check the status of the nodes to ensure they are being cordoned and drained. You should also see new nodes come in with the new Kubernetes version.

```bash
kubectl get nodes
```

If nodes are stuck in `SchedulingDisabled` for longer than 10 minutes, refer to [Node pool stuck in updating state and node not being deleted](#node-pool-stuck-in-updating-state-and-node-not-being-deleted).

Continue to the next section once the ProvisioningState changes from `Updating` to `Succeeded` for all node pools and they reflect the new Kubernetes version.

### 6. Ensure workloads are healthy

With all node pools upgraded, confirm that nothing regressed. Re-run the commands from [Record pods that aren't Running or Succeeded](#2-record-pods-that-arent-running-or-succeeded), then compare the output before and after the upgrade to ensure that any workloads which were not broken beforehand remain healthy.

### 7. Update the Infrastructure-as-Code

Finally, record the new version in code so the cluster's desired state stays in sync. Update the `kubernetes_version` variable in the Terraform file instantiating the [terraform-aurora-azure-environment](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment) module.

---

## Troubleshooting

As a general starting point, check the Activity Log in the Azure portal for "Create or Update Agent Pool" errors, where more details may be available in the JSON panel.

### Node pool stuck in updating state and node not being deleted

Check if there is a `PodDisruptionBudget` (PDB) preventing a node from draining:

```bash
kubectl get events -A --sort-by='.metadata.creationTimestamp' | grep pdb
```

You can also look through the pods on any node that has been in `SchedulingDisabled` for an unusually long time to check for error events or stuck `PodDisruptionBudget` resources.

The drain process will respect any PDB in place. This can take time, since enough replicas must reschedule before the node drains. The drain gets stuck when a PDB requires a minimum number of replicas that is equal to or greater than the total number on the node, leaving no room to reschedule.

There are multiple options to address this:

- Increase the replicas of the pod controller if possible
- Edit the PDB to decrease the minimum number of pods that need to be available
- If all else fails, or it is a Dev or NonProd environment, manually delete the stuck pod(s)

Make a note of any misconfigured PDBs so that these issues can be addressed prior to further Kubernetes upgrades. For a long term solution, a Gatekeeper policy should be developed to prevent such misconfigured PDBs.

### Availability zone issues

If you encounter Persistent Volume mounting errors reporting that the volume is in an incompatible Availability Zone, add a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or [nodeAffinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) configuration to the relevant pod controller. It should match the label key `topology.kubernetes.io/zone` against the zone requested in the error message, provided that nodes in that zone exist.

For an immediate hotfix to move a pod into a different node in the same node pool:

- Cordon all nodes in that node pool that have a `topology.kubernetes.io/zone` label value different than the requested one, leaving only the node(s) with the correct zone
- Delete the pod
- Once the pod has rescheduled onto a node in the appropriate availability zone, uncordon the previously cordoned nodes

In exceptional cases, nodeAffinity configurations can be applied directly onto Persistent Volumes.

<gcds-alert alert-role="warning" container="full" heading="Warning" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Persistent Volume nodeAffinities are immutable. Ensure caution when setting them and set persistentVolumeReclaimPolicy to Retain if you need to delete and recreate the PV/PVC.</gcds-text>
</gcds-alert>

### Cluster shows zero nodes even though VMSS instance is running

If `kubectl get nodes` returns:

```text
No resources found
```

while the underlying VMSS instance is confirmed to be running, the node may have failed to register with the cluster.

One possible cause is a failing admission webhook that blocks the API operations the node needs to register. To check whether a webhook is interfering, run a simple authorization check against the nodes API:

```bash
kubectl auth can-i list nodes
```

If the command fails with an error like the following, the Gatekeeper webhook is unavailable and is blocking node registration:

```text
Error from server (InternalError): Internal error occurred: failed calling webhook "validation.gatekeeper.sh":
failed to call webhook: Post "https://gatekeeper-webhook-service.gatekeeper-system.svc:443/v1/admit?timeout=3s":
no endpoints available for service "gatekeeper-webhook-service"
```

To unblock registration, delete the Gatekeeper validating webhook configuration. Gatekeeper will recreate it once its pods are healthy again:

```bash
kubectl delete validatingwebhookconfiguration gatekeeper-validating-webhook-configuration
```

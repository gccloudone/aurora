---
title: "Performing an AKS Cluster Upgrade"
linkTitle: "AKS Cluster Upgrade"
weight: 5
aliases: ["/team/sop/aks-cluster-upgrade"]
date: 2026-02-06
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This document outlines the process for upgrading an AKS cluster.

## Preparing your environment

 Ensure the following command line tools below are installed & are up-to-date.

- [ ] **[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)**  
   Ensure `kubectl` is within 1 minor version of the new cluster version.

- [ ] **[Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)**  

- [ ] **[velero](https://github.com/vmware-tanzu/velero/releases)**  
  The version of velero should match the version of velero used in the target cluster.

- [ ] **[jq](https://jqlang.github.io/jq/download/)**  
  Used for exporting and processing pod information.

- [ ] **[pluto](https://pluto.docs.fairwinds.com/installation/)**  
  Detects deprecated and removed Kubernetes API versions.

- [ ] (Optional) **[asdf](https://asdf-vm.com/guide/getting-started.html)**  
  Used to upgrade multiple Kubernetes clusters that are more than 2 minor versions apart from each other. Manages multiple concurrent versions of kubectl.

## Upgrading the cluster

**Before following the procedure, ensure your environment is setup as described in [Preparing your environment](#preparing-your-environment) & read the [Troubleshooting](#troubleshooting) section prior to carrying out the upgrade procedure.**

### 1. Verify deprecated APIs

Use pluto to check if there are any deprecated APIs in the new cluster version.

`pluto detect-all-in-cluster k8s=new-cluster-version`

Record any deprecated APIs on the JIRA ticket & make sure the manifest is using the new API version before continuing with the upgrade.

### 2. Export information of Pods that are not **Succeeded or Running**

Run the following two commands to export the information of Pods & containers that may be in a bad state:

```bash
kubectl get pods -A -o json | jq '.items[] | select(.status.phase|test("Succeeded|Running")|not) | {namespace: .metadata.namespace, name: .metadata.name, phase: .status.phase}' | jq '{pods:[inputs]}'

kubectl get po -A | grep -v Running | grep -v Completed
```

Add the output of this command to the Jira ticket for this cluster upgrade, along with any easily available supporting information (such as error messages in the events of those pods).

### 3. Back up the Cluster

To allow for restoration in the event of a catastrophic failure during the upgrade process,  take a full snapshot of the cluster (resources and disks) using Velero.

```bash
# Get the name of the snapshot location for the current cluster
velero -n velero-system snapshot-location get
# Take a backup
velero -n velero-system backup create backup-YYYYMMDDHHMM --include-cluster-resources --volume-snapshot-locations $SNAPSHOT_LOCATION_NAME --ttl 168h

# Monitor the backup (watch the Phase indicator: Completed or PartiallyFailed [normal])
velero -n velero-system backup describe backup-YYYYMMDDHHMM
```

### 4. Upgrade Control Plane

Login through the `az` cli and set your subscription to the subscription the target cluster lives in.

```bash
az login
az account list -o table
az account set --subscription <Subscription Name or ID>
```

Then, get the available upgrade versions:

```bash
az aks get-versions -l canadacentral -o table
```

Set the below local variables that will be used throughout the upgrade:

```bash
CLUSTER_RESOURCE_GROUP=<Name of cluster resource group>
CLUSTER_NAME=<Name of cluster>
KUBERNETES_VERSION=<New kubernetes upgrade version>
```

Finally, upgrade the control plane to the latest available patch version for the major version that you are upgrading to:

```bash
az aks upgrade -g $CLUSTER_RESOURCE_GROUP -n $CLUSTER_NAME --control-plane-only -k $KUBERNETES_VERSION --no-wait
```

At this point, as well as later when upgrading the data plane, there is occasionally a glitch where the following message is displayed:

```bash
The cluster is already on version <old kubernetes version> and is not in a failed state. No operations will occur when upgrading to the same version if the cluster is not in a failed state. (y/n)
```

If you encounter it, proceed with `y`.

Confirm that the control plane has been updated.

```bash
kubectl version
```

### 5. Upgrade Node Pools

> **Note**: The upgrade process will cause all workloads to be evicted from old nodes and rescheduled to newer nodes. This process will respect any `PodDisruptionBudgets` which target pods.

List the node pools:

```bash
az aks nodepool list -g $CLUSTER_RESOURCE_GROUP --cluster-name $CLUSTER_NAME -o table
```

For each node pool run the following, using the same Kubernetes version as the control plane.

<gcds-alert alert-role="danger" container="full" heading="Danger" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>DO NOT upgrade nodepools in different Availability Zones (AZs) at the same time. </gcds-text>
</gcds-alert>

> **Note**: You may optionally decide to upgrade multiple nodepools **within the same AZ** at the same time to speed up the upgrade process.
For example, if there is a gateway1, system1, general1 **AND** a gateway2, system2, and general2 nodepools, you can upgrade all the Zone 1 nodepools first at the same time (gateway1, system1, general1) before moving onto upgrading the Zone 2 nodepools that being gateway2, system2, and general2.

```bash
az aks nodepool upgrade -g $CLUSTER_RESOURCE_GROUP --cluster-name $CLUSTER_NAME -k $KUBERNETES_VERSION --no-wait -n <Name of node pool>
```

Continue to check on the status of the upgrade by running:

```bash
az aks nodepool list -g $CLUSTER_RESOURCE_GROUP --cluster-name $CLUSTER_NAME -o table
```

Continuously check the status of the nodes to ensure they are being cordoned & drained. You should also be seeing new nodes come in with the new Kubernetes version.

```bash
kubectl get nodes
```

**Refer to [Nodepool stuck in Updating State / Node not being deleted](#nodepool-stuck-in-updating-state-node-not-being-deleted) if Nodes are stuck in `SchedulingDisabled` for longer than 10 minutes.**

Continue to the next section once the ProvisioningState changes from `Updating` to `Succeeded` for all nodepools & reflect the new Kubernetes version.

### 6. Ensure Workloads are Healthy

Confirm that workloads are functioning. Re-run the commands described in [this section](#2-export-information-of-pods-that-are-not-succeeded-or-running). Compare the output of the commands before & after the upgrade & ensure that any workloads which were not broken before the update are fixed.

### 7. Update the Infrastructure-as-Code

Update the `kubernetes_version` variable in the terraform file instantiating the [terraform-aurora-azure-environment](https://github.com/gccloudone-aurora-iac/terraform-aurora-azure-environment) module.

---

## Troubleshooting

Check the `Activity Log` for `Create or Update Agent Pool` errors within the Azure portal, where details may be available in the `JSON` panel.

### Nodepool stuck in Updating State / Node not being deleted

Check if there is a PDB preventing a node from draining:

```bash
kubectl get events -A --sort-by='.metadata.creationTimestamp' | grep pdb
```

The drain process will respect any PodDisruptionBudget (PDB) in place. Respecting a PDB can take time in order to ensure that a sufficient number of replicas has been rescheduled before draining the node. This can result in the drain getting stuck if a PDB specifies a minimum number of replicas that is equal to or greater than the total number of replicas on the node, preventing any rescheduling.

There are multiple options to address this:

- Increase the replicas of the pod controller if possible
- Edit the PDB to decrease the minimum number of pods that need to be available
- If all else fails, or it is a Dev or NonProd environment, manually delete the stuck pod(s)

- Look through the pods on any node that has been in `SchedulingDisabled` for an unusually long time to check for error events or stuck PodDisruptionBudgets.

Make a note of any misconfigured PDBs so that these issues can be addressed prior to further Kubernetes upgrades. For a long term solution, a Gatekeeper policy should be developed to prevent such misconfigured PDBs.

### Availability Zone Issues

If you encounter Persistent Volume mounting errors reporting that the volume is in an incompatible Availability Zone, ensure that a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or [nodeAffinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) configuration is in place on the relevant pod controller such that it will match the label key `topology.kubernetes.io/zone` with the value of the zone requested in the error message (provided that nodes with such an availability zone exist).

For an immediate hotfix to move a pod into a different node in the same node pool:

- Cordon all nodes in that node pool that have a `topology.kubernetes.io/zone` label value different than the requested one, leaving only the node(s) with the correct zone
- Delete the pod
- Once the pod has rescheduled onto a node in the appropriate availability zone, uncordon the previously cordoned nodes

In exceptional cases, nodeAffinity configurations can be applied directly onto Persistent Volumes.

<gcds-alert alert-role="warning" container="full" heading="Warning" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Persistent Volume nodeAffinities are immutable. Ensure caution when setting them and set persistentVolumeReclaimPolicy to Retain if you need to delete and recreate the PV/PVC.</gcds-text>
</gcds-alert>

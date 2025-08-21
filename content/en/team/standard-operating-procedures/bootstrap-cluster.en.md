---
title: "Bootstrap Cluster"
linkTitle: "Bootstrap Cluster"
weight: 5
aliases: ["/team/sop/bootstrap-cluster"]
date: 2025-08-19
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This guide provides instructions for setting up a k3s bootstrap cluster (a process also tested in Windows Subsystem for Linux or WSL), deploying Argo CD, and transferring control to a remote Kubernetes cluster. This allows you to shift the management from the k3s instance to your designated target cluster.

It's critical because the target cluster initially lacks the cilium networking setup, however, k3s can facilitate the establishment of a full platform within the remote Kubernetes cluster.

Finally, Argo CD can also be configured to be deploy itself within your target cluster, making the usage of this bootstrap cluster usually a one time occurrence to solve the aforementioned chicken and egg bootstrapping issue.

## Pre-requisites

- Linux / WSL
- JQ
- Access to Key Vault secrets through MSI

Additionally you should ensure that a .env file is created based on the .env.example file.

Finally that the argocd-instance.yaml under the base folder is successfully configured.

### Managed Service Identity (MSI)

The fundamental requirement for the successful operation of Argo CD in this context is the Managed Service Identity (MSI).

The MSI lets Argo CD read our key vault secrets which has all of the secrets, service principals, and stuff necessary for argo to run whether on the k3s instance or the target cluster itself.

An MSI for ArgoCD is usually created by the Terraform script and conventionally follows the pattern: `GcDc-<PROJECT>-msi-argocd`.

To set up the MSI in the bootstrap cluster, you need to declare either the `MSI` or the `MSI_RESOURCE_ID` environment variable in the bootstrap cluster setup script:

```sh
# Set if the MSI has already been added beforehand
MSI="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
# Set if the MSI hasn't already been added beforehand
MSI_RESOURCE_ID=
```

> **Note**: The GC Cloud One Azure team is working on a custom role so we won't have to request the MSI be added beforehand due to lack of permissions on the WebTop.

## Bootstrap Cluster

### Setup

The following set of commands will setup the bootstrap cluster for you.

```sh
git clone https://github.com/gccloudone/bootstrap-cluster
cd bootstrap-cluster
./setup.sh
```

You can refer to the results of this operation in [this file](/docs/sops/bootstrap-cluster.txt).

### Retrieve Kubeconfig context

After the initial setup the kubeconfig will be updated to point to the newly created cluster.

However if ever you need to re-establish this context simply enter the following command.

```sh
export KUBECONFIG=$(k3d kubeconfig get bootstrap-local-cc-00)
```

### Custom CA

In some scenarios, you might require a Custom Certificate Authority (CA).

This is often the case when you need to secure internal communication within your organization, or when you're using self-signed certificates that aren't recognized by a public CA.

When creating such a secure environment, k3d initiates its setup based on the following reference point:

```sh
/usr/local/share/ca-certificates/custom.crt
```

For applications like Argo CD that also need to recognize your Custom CA, you must also run this command:

```sh
kubectl apply -f certs.yaml
```

Of which the file contents of `certs.yaml` should have a structure as shown:

```sh
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-certs
  namespace: platform-management-system
data:
  custom.crt: |-
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
```

Once this is done, you will need to restart all Argo CD pods to load the Custom CA:

```sh
kubectl rollout restart deploy -n platform-management-system
```

> **Recommendation**: This is a suitable opportunity to deploy these changes to your target cluster as well.

### Transfer Control

Before moving forward with this step, it is advisable to first log into Argo CD and initiate a sync operation.

As a result, you might observe several resources indicating that the target cluster does not exist.

To proceed, execute the following command:

```sh
./register.sh
```

This command uses the .env variables previously entered to gather the Kubernetes context and create a secret that Argo CD can use.

Once this secret is created, Argo CD will immediately begin deploying the full Aurora platform within the target cluster.

#### Custom CA

If you omitted the step of deploying the custom-certificates to the target cluster earlier, it is crucial to do so now.

This ensures that Argo CD will function successfully within your target cluster.

#### Workaround

Unfortunately, there is an unavoidable manual step in this process. You will need to apply the patch command listed below to a specific resource.

```sh
kubectl patch deployment argocd-repo-server \
  -n platform-management-system \
  -p '{
    "spec":{
      "template":{
        "metadata":{
          "labels":{
            "aadpodidbinding":"argocd-vault-plugin"
          }
        }
      }
    }'
```

Once you've successfully completed this action, all components should be functional and fully deployed within the target cluster.

### Cleanup

The following commands guide you through the process of cleaning up the bootstrap cluster.

```sh
./cleanup.sh
```

You can refer to the results of this operation in [this file](/docs/sops/bootstrap-cluster-cleanup.txt).

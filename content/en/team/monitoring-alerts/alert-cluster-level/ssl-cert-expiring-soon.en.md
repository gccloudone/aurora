---
title: "SSLCertExpiringSoon"
linkTitle: "SSLCertExpiringSoon"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Alert: SSLCertExpiringSoon

This alert occurs at the cluster level. It triggers when the SSL certificate at a given target expires in fewer than 20 days. This alert can indicate that the certificate has failed to automatically renew or that the target's pod has failed to pick up a renewed certificate.

On each cluster, the wildcard SSL certificate for the Ingress Gateway is checked by probing that cluster's instance of Grafana using the [Blackbox Exporter]({{< ref "team/monitoring-alerts/blackbox-exporter" >}}). The probe returns a metric for SSL certificate expiry. Grafana is chosen arbitrarily as the wildcard certificate is used for all `*.cloud.statcan.ca` subdomains.

Furthermore, on the Management cluster, Artifactory is probed separately since it is acting as a separate Ingress Gateway into the cluster.

### Resolution Process

First confirm whether the alert is firing only for Artifactory.

#### Firing on Artifactory only

This case is most likely to be a known issue where Artifactory's nginx pod fails to pick up a new certificate. To confirm this, check if the certificate is still valid:

`kubectl -n istio-system describe cert wildcard`

If the certificate is valid, restart the nginx pod:

`kubectl -n istio-system rollout restart deploy artifactory-ingress`

Otherwise, refer to the following section on troubleshooting cert-manager, noting that the certificate for Artifactory is `wildcard` in `istio-system`.

#### Firing on Grafana

1. If the issue has occurred recently, check if there are any pertinent error logs in the cert-manger pod in the cert-manager namespace.

2. Check for an authentication error. Using the following command, errors may be seen in the condition section:

    `kubectl -n ingress-general-system describe cert general-istio-ingress-gateway`

3. Restart the cert-manager with kubectl. This can be found in the **cert-manager**, or **cert-manager-system** namespace:

    `kubectl -n cert-manager rollout restart deploy cert-manager`

Cert-manager only authenticates once per hour. The wildcard certificate must be replaced to force cert-manager to re-authenticate immediately. This can be done by obtaining the YAML for the wildcard certificate, removing instance specific fields, deleting the certificate, and then re-applying the certificate.

This process is highlighted in the remaining steps below.

4. Get the wildcard cert yaml, and save as general-istio-ingress-gateway-cert.yaml:

    `kubectl -n ingress-general-system describe cert general-istio-ingress-gateway -o=yaml > general-istio-ingress-gateway-cert.yaml`

5. Remove instance specific fields (manual):
    - Open the file in an editor, and remove instance specific fields such as:
        - metadata.uid
        - metadata.resourceVersion
        - metadata.creationTimestamp
        - metadata.managedFields
        - metadata.selflink

6. Delete the certificate:

    `kubectl -n ingress-general-system delete cert general-istio-ingress-gateway`

7. Finally, re-apply the certificate:

    `kubectl -n ingress-general-system apply -f general-istio-ingress-gateway-cert.yaml`

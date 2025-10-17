---
title: "DNS Alerts"
linkTitle: "DNS Alerts"
weight: 5
aliases: ["/team/monitoring/clusteralerts/dns"]
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## Overview

DNS-related issues can occur at two levels:

- Cloud Service Provider (CSP) networking layer
- Kubernetes level (usually an issue with coreDNS).

If the application logs show DNS lookup errors for trying to resolve something like `google.com` the issue most likely stems from the DNS servers configured from the CSP. Collect all relevant information such as the environment, the SourceIP of the Pod & the host that is not resolving correctly and present them to the point-of-contact responsible for managing the CSP infrastructure for Aurora.

If application logs include logs similar to:

```Could not resolve host: someservice.namespace.svc.cluster.local```

This indicates that coreDNS is failing to resolve a Service. Refer to the information below to investigate & resolve the issue.

## Alert: CoreDNSDown

Check the `coredns` deployment in the `kube-system` namespace and ensure that there is at least one healthy replica.

## Other DNS related issues

If the DNS issue is at the Kubernetes level, refer to [this runbook](https://containersolutions.github.io/runbooks/posts/kubernetes/dns-failures/#overview) (credit to Ian Miell) for investigating & resolving DNS failures.

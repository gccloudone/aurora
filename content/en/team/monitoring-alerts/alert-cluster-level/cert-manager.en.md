---
title: "Cert Manager Alerts"
linkTitle: "Cert Manager Alerts"
weight: 5
aliases: ["/team/monitoring/clusteralerts/certmanager"]
draft: false
---

{{< translation-note >}}

## Alert: certManagerCertFailingToRenew

This alert fires when the Cert Manager certificate fails to renew when it should have at the designated renewal time.

## Alert: certManagerCertFailure

This alert fires when the Cert Manager certificate is not in a ready state, but is not in need of renewal. There is still some time left before its renewal time.

## Alert: certManagerCertExpired

This alert fires when the Cert Manager certificate has expired. The expiry date of the certificate has passed.

## Troubleshooting

For the above three alerts refer to the [official documentation](https://cert-manager.io/docs/troubleshooting/acme/) for the troubleshooting process.

## Alert: certManagerAbsent

This alert fires when there is no Cert Manager endpoint discovered by Prometheus. Causes could be a few things.

- Ensure Cert Manager is up and running.
- Ensure service discovery is configured correctly for Cert Manager.

[Reference](https://gitlab.com/uneeq-oss/cert-manager-mixin/-/blob/master/RUNBOOK.md)

## Alert: certManagerHittingRateLimits

Cert Manager is being rate-limited by the ACME provider. Let's Encrypt rate limits can last for up to a week. There could be up to a weeks delay in provisioning or renewing certificates, depending on the action that's being rate limited.

Let's Encrypt suggest the application process for extending rate limits can take a week. Other ACME providers could likely have different rate limits.

[Let's Encrypt Rate Limits](https://letsencrypt.org/docs/rate-limits/)

[Reference](https://gitlab.com/uneeq-oss/cert-manager-mixin/-/blob/master/RUNBOOK.md)

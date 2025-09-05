---
title: "Nginx Alerts"
linkTitle: "Nginx Alerts"
weight: 10
type: "docs"
draft: false
lang: "en"
---

## Nginx Alerts

The following page describes Nginx alerts that have been implemented within the CNP. These alerts are configured to occur at the cluster level. These alerts help identify potential issues relating to network traffic within the Ingress environment.

HTTP traffic typically follows a standard pattern when analyzed over a period of time. In scenarios where the actual behaviour of the HTTP traffic is deviating drastically from the set pattern, representing either a sharp increase or decrease in traffic, this could indicate issues or potential incidents that may be occuring within our platform. The Nginx alerts implemented and highlighted here help our team determine network traffic issues within our platform. It is worth noting that many of these alerts are preliminary or informative alerts to help the Cloud Native Solutions (CNS) team identify potential future issues.

Nginx alerts can be found [here](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-ingress/-/blob/main/prometheus_rules/nginx_rules.yaml)

## General Steps

The initial investigation and troubleshooting steps for the alerts defined on this page may share some common steps. For this purpose, some common commands are included here that will help you get started with your investigation. In any Nginx alert scenario, the commands should be used to investigate:

1. Analyze the pod or pods to determine if any errors are being thrown

`kubectl -n <namespace> describe pod <podName>`

1. Analyze the pod logs for the running pod, either through Lens IDE or with the following command:

`kubectl -n <namespace> logs <podName>`

## Alert: HTTPRequestCountSpike

This alert occurs when HTTP requests to the Ingress environment are determined to be several standard deviations above the predicted value. The prediction is based on the median rate of traffic seen during the +/- 2 hour period across the past four weeks. When this alert occurs, the team is notified that higher-than-normal amounts of HTTP requests are being seen by Nginx. This could represent malicious activity such as a DDOS attack, but may simply be unusually high traffic.

### Resolution Process

First, confirm if the alert has auto-resolved after a period of time. If the alert persists, it needs to be confirmed whether or not this type of request traffic spike is expected or if it's unfamiliar behaviour.
- Is it expected that there is more traffic occuring at this time? Perhaps there is a new product or news release, that's resulting in more HTTP request traffic to our environments?

Regardless, you can analyze the status of the pods and pod logs to get more details.

In cases where the request count spikes drastically or over a longer period of time, then it should be determined whether or not this situation classifies as an incident.
- If yes, it should be filed and escalated as an incident, based on the standard procedures.

## Alert: HTTPRequestCountDrop

This alert occurs when HTTP requests to the Ingress environment are determined to be significantly below the predicted value. The prediction is based on the median rate of traffic seen during the +/- 2 hour period across the past four weeks. When this alert occurs, the team is notified that lower-than-normal amounts of HTTP requests are being seen by Nginx. This could represent an issue with Nginx, where requests may be getting dropped erroneously, or to an issue on the networking side.

We may be more concerned with this type of alert rather than an alert regarding an increase in traffic. A significant drop in traffic could potentially indicate an issue with Nginx specifically, or a larger issue at the networking level.

### Resolution Process

First, confirm if the alert has auto-resolved after a period of time. If the alert persists, determine if Nginx is running and functioning successfully
- Analyze the status of the pods and the pog logs to get more information
- Verify if any errors messages are being captured within the pod logs. Are connections failing for any reason? Are there any issues related to resources consumption? Is there any other useful information in the logs?

If it is confirmed that Nginx is functioning correctly, and this alert still persists and traffic continues to be dropped unexpectedly, then it may point to a more complex issue at the networking level.
- In this case, it should be determined if this should be filed as an incident and escalated accordingly, based on standard operating procedures.

## Alert: NginxIngressDown & UnsuccessfulNginxReload

The NginxIngressDown alert occurs when the Nginx Ingress controller is identified as 'unavailable' within the Ingress environment. This alert is critical, as it means that Nginx is currently not working and thus the availability of our platform may be impacted. This could highlight a potential bug or issue with Nginx specifically, or it could point to a more complex issue.

The UnsuccessfulNginxReload alert occurs when a new configuration change has been made to Nginx in the Ingress environment, that ultimately resulted in an unsuccessful (failed) reload.

### Resolution Process

Analyze the pods to determine why the Nginx Ingress controller is in the Unavailable or Failed state.
- Analyze the status of the pods and pod logs to get more information
- Analyze the Nginx resources
- Determine the root cause of the issue
- For the UnsuccessfulNginxReload scenario, you should also double-check to verify that the new configuration changes are valid by referring to [Nginx docs](https://docs.nginx.com/nginx/admin-guide/basic-functionality/managing-configuration-files/)

When troubleshooting, look for a specific error message that may detail why there was a failure.

Once the root cause has been identified:
- Fix Nginx accordingly by implementing the required changes (i.e allocating more storage resources if NginxIngress fails due to running out of space)
- Verify that Nginx returns to normal functionality.
    - If it does not return automatically, you may need to restart the Nginx pods manually, or perform a re-deployment

## Alert: NginxConnectionsHigh & NginxConnectionsVeryHigh

The NginxConnectionsHigh alert occurs when the total number of Nginx connections within the Ingress environment exceeds 50% of the maximum number of connections.

The NginxConnectionsVeryHigh alert occurs when the total number of Nginx connections within the Ingress environment exceeds 85% of the maximum number of connections. This is a critical alert and should be investigated as soon as possible.

These alerts could indicate that the platform is beginning to receive much heavier-than-usual network traffic. This increased amount of connections is not likely to be expected because the maximum amount of connections is very high, such that typically less than 10% of it is in use. This alert could indicate a problem with nginx terminating connections, a major change in the maximum amount of connections, or malicious activity

### Resolution Process

Analyze the pods to try and determine a root cause.
- Analyze the status of the pods and pod logs to get more information
- Analyze the Nginx resources

One thing to confirm is if Nginx is having issues terminating connections by verifying the pod logs:
- There could be an error occuring during connection terminations
- Nginx may be hitting its resource limits, and we may need to increase the amount of allocated storage or compute resources.

If you are unable to determine a root cause and the alert does not auto-resolve, this could indicate malicious activity and could warrant an incident report.

The Nginx pod logs can be accessed through the Azure Portal through the [securityoperations-monitoring-management-law](https://portal.azure.com/#@cloud.statcan.ca/resource/subscriptions/b73ce7d3-fd70-4018-9bc6-5d160c574707/resourceGroups/securityops-management-rg/providers/Microsoft.OperationalInsights/workspaces/securityoperations-monitoring-management-law/logs) log analytics workspace.
- Useful queries can be found in: Queries -> Legacy Categories -> Ingress

During investigation, if at anytime you have a concern that malicious activity is ongoing and it could result in an larger incident, please raise this immediately with the team and follow standard procedures for escalation.

## Resolution: Nginx not functioning

For any of the alerts described on this page, you may come to the conclusion that Nginx is not running successfully for whatever reason.

If it is confirmed that Nginx is not functioning normally, you will need to implement a fix and move forward with ensuring Nginx returns to a functional state. In these scenarios:
- Identify the root cause
    - Nginx could be running out of resources (storage, compute)
    - Nginx could be encountering errors during some processes. This would be described in the logs
- Implement the fix
- If needed, restart Nginx to remediate the situation.
    - If restarting did not correct the issue, you may need to perform a re-deployment of Nginx through the [terraform module](https://gitlab.k8s.cloud.statcan.ca/cloudnative/terraform/modules/terraform-kubernetes-ingress/-/pipelines)

## Additional Notes

Once again, if you have a concern that malicious activity is ongoing and it could result in an incident, or if you have a concen a larger issue is involved (i.e. networking outages), please raise this immediately with the team for support and follow-up.

---
title: "ProbeFailure"
linkTitle: "ProbeFailure"
weight: 10
type: "docs"
draft: false
lang: "en"
---


## Probe Failure Alerts

These alert occur at the cluster-level and depend on the configuration of [Blackbox Exporter]({{< ref "/en/team/monitoring-surveillance/prometheus/blackbox-exporter" >}}) probes. Unlike most cluster-level alerts, these alerts do not pertain to the cluster they originate from, but rather to what the alert labels identify as the `target` cluster. That is because these probes are used for uptime and health monitoring. Since a cluster experiencing such issues may not be capable of transmitting the relevant alerts, clusters are configured to probe other clusters. For example, presently the Management cluster probes the SDLC and Ingress clusters, while the Production cluster in turn probes Management.

There are presently two types of Probe Failure alerts: **IstioIngressGatewayProbeFailure** and **ControlPlaneProbeFailure**.

## Alert: IstioIngressGatewayProbeFailure

This probe checks the HTTP endpoint of an Istio Ingress Gateway. The probe fails if it encounters any of the following conditions:
- A connection cannot be made.
- A redirect to HTTPS is not made.
- An unexpected status code is returned (`404` expected).
- An unexpected HTTP version is encountered (`HTTP/1.1` or `HTTP/2.0` expected).

To determine which of these occurred, as well as to examine any further error logs or metrics captured, check the Blackbox Exporter debug logs for the failed probe:
1. Use a context corresponding to the cluster that sent the probe, which is identified by the `cluster` label
1. Port-forward to port `9115` on the blackbox exporter pod in the `monitoring` namespace. For example, through Lens or via `kubectl -n monitoring blackbox-exporter-<some-suffix> port-forward 9115`
1. Go to `localhost:9115` (or the local port you have mapped to if you chose another). Search the table for an entry corresponding to the `instance` label with a **Failure** in the **Result** column and click through to `Logs`
   - Probes are listed sequentially up to a limit of entries after which only failed probes are retained

## Alert: ControlPlaneProbeFailure

This probe checks the `readyz` [Kubernetes API health endpoint](https://kubernetes.io/docs/reference/using-api/health-checks/). The probe fails if it encounters any of the following conditions:
- A connection cannot be made.
- A redirect to HTTPS is not made.
- An unexpected status code is returned (`200` expected).
- An unexpected HTTP version is encountered (`HTTP/1.1` or `HTTP/2.0` expected).
- The message `readyz check passed` is not present.

To determine which of these occurred, as well as to examine any further error logs or metrics captured, check the Blackbox Exporter debug logs for the failed probe as described in the [IstioIngressGatewayProbeFailure](#alert-istioingressgatewayprobefailure).

If the failure was due to the lack of the `readyz check passed` message, and the probe is still failing, further details can be obtained from the verbose output of the `readyz` endpoint. This can be done through `kubectl`:
1. Set your `kubectl` context to the cluster identified in the `target`. For example, the target `control-plane-infra-probe` corresponds to the `InfraTest` cluster.
1. Run  `kubectl get --raw='/readyz?verbose'`

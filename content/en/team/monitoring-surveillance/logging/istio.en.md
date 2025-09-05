---
title: "Configuring Istio Logging"
linkTitle: "Configuring Istio Logging"
weight: 40
type: "docs"
draft: false
lang: "en"
---

## Overview

Istio is a service mesh which provides extensive networking capabilities via its Envoy sidecar which it injects into Pods. This sidecar can provide large amounts of visibility through the logging available from the extensions which provide this functionality.

Logging configurations are inherited from the configurations set at the service mesh level, however, they may also be configured on each sidecar.

## Configuring Logging Level

The Envoy sidecar which Istio uses to implement its mesh has the following [logging levels](https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/run-envoy#debugging-envoy): `trace`, `debug`, `info`, `warning`, `error`, `critical`, `off`

### Persistent Configurations

The logging level of the sidecar can be set using the [following annotations](https://istio.io/latest/docs/reference/config/annotations/) set on a `Pod` resource:
- `sidecar.istio.io/logLevel`: sets the logging level for all components in Envoy.
- `sidecar.istio.io/componentLogLevel`: sets the logging level for specific components. Accepts a comma-separated list of colon separated component to logging level pairs. ex: `sidecar.istio.io/componentLogLevel=http:debug,http2:debug,jwt:info`

Since these configurations are set on the Kubernetes resources, they will persist across Pod restarts and rescheduling.

> Generally, Pods aren't instantiated directly but defined via [workload resources](https://kubernetes.io/docs/concepts/workloads/pods/#pods-and-controllers). As such, it's important to ensure that the annotations are set on the [pod templates](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates) `metadata` and not the top level `metadata` section.

Following is an example of setting the annotations on a Job:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: istio-logging-example
spec:
  template:
    # This is the pod template
    metadata:
      annotations:
        sidecar.istio.io/logLevel: error
        sidecar.istio.io/componentLogLevel: http:debug,http2:debug
```

Following is what would be visible by retrieving the Pod specification associated to the created job with the annotations in place:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: istio-logging-example
  annotations:
    sidecar.istio.io/logLevel: error
    sidecar.istio.io/componentLogLevel: http:debug,http2:debug
```

### Temporary Configurations

There are instances when it is useful to increase logging levels for a limited time: debugging, tracing, etc. This can be achieved by leveraging Envoy's [Admin Console](https://www.envoyproxy.io/docs/envoy/latest/operations/admin) which is served on port `15000` of the sidecar.

> These configurations will not persist past the normal lifecycle of the Envoy container. If the Pod is rescheduled or the container suffers a restart, the default configurations will be loaded.

To interact with the Admin Console, `kubectl port-forward` can be leveraged:
```bash
# Sets up port-forwarding to the specified Pod
kubectl -n $namespace port-forward $podName 15000
```

Once port-forwarding is started, the Admin Console can be interacted with via a browser or a CLI at `http://localhost:15000`. The [`/logging`](https://www.envoyproxy.io/docs/envoy/latest/operations/admin#post--logging) endpoint is available to query for information and to configure the logging levels.

A POST of the [`/logging`](https://www.envoyproxy.io/docs/envoy/latest/operations/admin#post--logging) endpoint can be used to view the currently configured logging levels for all of the components:
```bash
curl -X POST localhost:15000/logging
```

To change the logging level across all components, the following can be run:
```bash
curl -X POST "localhost:15000/logging?level=error" # trace, debug, info, warning, error, critical, off
```

To change the logging level of specific components, the following can be run:
```bash
curl -X POST "localhost:15000/logging?paths=http:debug,http2:debug"
```

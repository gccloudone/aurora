---
title: "Elasticsearch"
linkTitle: "Elasticsearch"
weight: 100
type: "docs"
draft: false
lang: "en"
---

To deploy an Elasticsearch and Kibana instance within the Cloud Native Platform,
the following template can be used as a base. Please customize the required
resources based on your needs.

If you require advanced configuration, such as multiple Elasticsearch nodes,
then the template can be customized based on the
[upstream documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html).
**Please note that the Istio settings below are important.**

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: $name
  namespace: $namespace
spec:
  http:
    tls:
      selfSignedCertificate:
        disabled: true
  version: 8.5.2
  nodeSets:
  - config:
      node.roles: [ master, data, ingest ]
    count: 1
    name: node
    podTemplate:
      metadata:
        annotations:
          traffic.sidecar.istio.io/excludeOutboundPorts: "9300"
          traffic.sidecar.istio.io/excludeInboundPorts: "9300"
      spec:
        automountServiceAccountToken: true
        containers:
        - env:
          - name: ES_JAVA_OPTS
            value: -Xms4g -Xmx4g
          name: elasticsearch
          resources:
            limits:
              cpu: "4"
              memory: 8Gi
            requests:
              cpu: "2"
              memory: 8Gi
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        storageClassName: default
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 128Gi
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $name-elasticsearch
  namespace: $namespace
spec:
  ingressClassName: ingress-istio-controller
  rules:
  - host: $name-elasticsearch.$env.cloud.statcan.ca
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: $name-es-http
            port:
              number: 9200
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $name-kibana
  namespace: $namespace
spec:
  ingressClassName: ingress-istio-controller
  rules:
  - host: $name-kibana.$env.cloud.statcan.ca
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: $name-kb-http
            port:
              number: 5601
---
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: $name
  namespace: $namespace
spec:
  version: 8.5.2
  count: 1
  elasticsearchRef:
    name: $name
  http:
    tls:
      selfSignedCertificate:
        disabled: true
  podTemplate:
    spec:
      automountServiceAccountToken: true
```

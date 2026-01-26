---
title: "SSL Cert Issuance"
linkTitle: "SSL Cert Issuance"
weight: 5
aliases: ["/team/sop/ssl-cert-issuance"]
date: 2026-01-26
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This document outlines the steps Aurora administrators must follow to deploy a sample Kubernetes application to validate the issuance of an SSL certificate using Cert Manager and Lets Encrypt on the Aurora clusters. The domain used in this example is for the Aurora management dev cluster.

## Context

Aurora clusters use [Cert Manager](https://cert-manager.io/) to automate ssl cert issuance and renewal.

## Setup

Before testing, ensure the following:

- The **kubectl CLI** is installed.
- Access to connect to the target Aurora cluster is granted.

### Step2:  

Apply the below manifest to create the following Kubernetes resources: 

1. Namespace 
2. Deployment  
3. Service 
4. Ingress 
5. Certificate 

```
Kubectl apply –f test-cert-issuance.yaml 
```

Contents of the test-cert-issuance.yaml manifest
```
---
# Create Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: test-cert-issuance
---
# Create a Sample Deployment 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-cert-app
  namespace: test-cert-issuance
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: docker.io/nginx:latest
        imagePullPolicy: Always
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
---
# Create Service
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: test-cert-app-svc
  namespace: test-cert-issuance
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  sessionAffinity: None
  type: ClusterIP
---
# Create Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-cert-app-ingress
  namespace: test-cert-issuance
spec:
  ingressClassName: ingress-istio-controller
  rules:
  - host: test1.aurora.ssc-dev-auroramgmt.c.ent.cloud-nuage.canada.ca
    http:
      paths:
      - backend:
          service:
            name: test-cert-app-svc
            port:
              name: http
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - test1.aurora.ssc-dev-auroramgmt.c.ent.cloud-nuage.canada.ca
    secretName: test-cert-app-tls
---
# Create Certificate - This will further create CertificateRequest and Order
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  labels:
    use-general-solver: "true"
  name: test-cert-app-certificate
  namespace: test-cert-issuance
spec:
  commonName: test1.aurora.ssc-dev-auroramgmt.c.ent.cloud-nuage.canada.ca
  dnsNames:
  - test1.aurora.ssc-dev-auroramgmt.c.ent.cloud-nuage.canada.ca
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt
  secretName: test-cert-app-tls
```

### Step3: Validate the creation of resources

Check whether all resources defined in the manifest have been created. The `Kind: Certificate` manifest further creates a CertificateRequest and Order to generate the SSL cert and stores in tls.crt and tls.key in a K8s secret.

```
> kubens test-cert-issuance
✔ Active namespace is "test-cert-issuance"

> k get po
NAME                             READY   STATUS    RESTARTS   AGE
test-cert-app-755fbfbc49-nf8hj   1/1     Running   0          81m

> k get deploy
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
test-cert-app   1/1     1            1           81m

> k get svc
NAME                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
test-cert-app-svc   ClusterIP   10.0.18.139   <none>        80/TCP    82m

> k get ing
NAME                    CLASS                      HOSTS                                                         ADDRESS   PORTS     AGE
test-cert-app-ingress   ingress-istio-controller   test1.aurora.ssc-dev-auroramgmt.c.ent.cloud-nuage.canada.ca             80, 443   82m

> k get certificate
NAME                        READY   SECRET              AGE
test-cert-app-certificate   True    test-cert-app-tls   81m

> k get certificaterequest
NAME                          APPROVED   DENIED   READY   ISSUER        REQUESTER                                                AGE
test-cert-app-certificate-1   True                True    letsencrypt   system:serviceaccount:cert-manager-system:cert-manager   81m


> k get order
NAME                                    STATE   AGE
test-cert-app-certificate-1-379287467   valid   86m
```


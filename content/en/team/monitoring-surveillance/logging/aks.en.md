---
title: "Audit logging the AKS Control Plane"
linkTitle: "AKS Control Plane"
weight: 30
type: "docs"
draft: false
lang: "en"
---

## Introduction

Audit logging in Azure Kubernetes Service (AKS) is now generally available. Use audit logging in AKS to keep a chronological record of calls made to the Kubernetes API server (also known as the control plane), investigate suspicious API requests, collect statistics, or create monitoring alerts for unwanted API calls.

### Autoscaling issues

The following query will help you to isolate potential problems with AKS autoscaling.

```sh
AzureDiagnostics
| where Category == "cluster-autoscaler" and tolower(ResourceGroup) == "XXXXX"
| extend log=parse_json(tostring(AdditionalFields.log))
| order by TimeGenerated desc
| project TimeGenerated, Resource, log, AdditionalFields
```

### RBAC permissions

The following query will help you find any issues related to RBAC and why certain requests might not succeed.

```sh
AzureDiagnostics
| where Category == "kube-audit" and tolower(ResourceGroup) == "XXXXX"
| extend log=parse_json(tostring(AdditionalFields.log))
| where log["level"] == "RequestResponse"
| extend Kind=strcat(log["objectRef"]["apiGroup"], "/", log["objectRef"]["apiVersion"], ".", log["objectRef"]["resource"], ".", log["objectRef"]["subresource"])
| extend Resource=strcat(log["objectRef"]["namespace"], "/", log["objectRef"]["name"])
| where log["responseStatus"]["code"] >= 400
| order by TimeGenerated desc
| project TimeGenerated, Kind, Resource, log["responseStatus"]["reason"], log["verb"], log["user"]["username"]
```

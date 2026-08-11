---
title: "About us"
date: 2026-08-11
draft: false
sidebar: false
translationKey: "about"
disableCharacterlimit: true
---

Aurora is a secure, self-service application hosting platform powered by a curated selection of Cloud Native Computing Foundation (CNCF) technologies that enables solution builders to quickly build and deploy cloud-native solutions in a consistent and well-governed environment. Built by departments, for departments, across the Government of Canada and part of the GC Cloud One initiative, it simplifies the operation of multi-tenant Kubernetes environments at enterprise scale, letting teams focus on delivering applications rather than building and operating platforms.

Aurora is cloud-agnostic, running on the managed Kubernetes services offered by Cloud Service Providers (CSPs), including Azure Kubernetes Service (AKS), Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE), and GC Private Cloud. This model offloads control plane lifecycle management to the provider, while Aurora retains architectural control over cluster composition, networking, and platform services.

## Our mission

We enable secure, scalable, and interoperable digital services: driven by community, guided by standards, and built on operational experience.

Standing up a production-grade, security-compliant Kubernetes environment is time-consuming and demands specialized expertise. Rather than have every team design, build, and operate its own cluster and platform stack, Aurora centralizes that effort into a shared foundation. This reduces duplicated work, closes security gaps, and helps the Government of Canada move forward together.

## Platform architecture

The platform is organized into three architectural layers:

- **Deployment framework.** The Infrastructure-as-Code (IaC) and Configuration-as-Code (CaC) tooling that provisions cloud infrastructure and reconciles cluster configuration, defining how clusters and their supporting resources are created and how configuration is delivered through GitOps.
- **Platform runtime layer.** The managed clusters and the platform components that turn a raw Kubernetes cluster into a governed hosting platform aligned to the Protected B, Medium integrity, Medium availability (PBMM) profile, providing networking, security, observability, and delivery capabilities.
- **Platform services layer.** The self-service capabilities exposed to workload owners: namespaces, deployment workflows, logging, monitoring, and advanced networking and security features.

## Why Aurora

Workload owners hosting on Aurora gain:

- **A Government of Canada–aligned platform**, designed to operate within the PBMM profile and to satisfy the associated security controls.
- **Security enforced from the kernel to the workload.** Aurora combines kernel-level networking and runtime enforcement (Cilium and Tetragon) with service-mesh mutual TLS (Istio) and admission-time policy controls to deliver a zero-trust posture by default.
- **Portability across environments.** Open-source foundations keep workloads portable and reduce lock-in to any single provider.
- **A unified operational model.** Lifecycle activities such as version upgrades, monitoring, backup, and policy enforcement are managed centrally and consistently across the fleet, giving workload owners a predictable operational baseline.

## What we believe

- **Open by default.** Aurora is, and always will be, completely open source. We build in the open and share our work with the community.
- **Built with our users.** We shape the platform alongside the departments who use it, guided by Technical Advisory Groups (TAGs) in areas like architecture, networking, and security.
- **Invested in in-house expertise.** We develop and certify talent within the Government of Canada, reducing reliance on external vendors and building lasting institutional knowledge.

## Who we are

Aurora is delivered through Shared Services Canada, in collaboration with solution builders and platform architects from departments across government. It draws inspiration from proven public-sector platforms, including the BC Government's DevOps Platform, Statistics Canada's Cloud Native Platform, and the United States Department of Defense's Platform One.

To learn more about the vision, rationale, and roadmap behind the platform, read our <gcds-link href="{{< relref "/proposal" >}}">Strategic Proposal</gcds-link>, or find out how to <gcds-link href="{{< relref "/get-involved" >}}">Get Involved</gcds-link>.

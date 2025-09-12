---
title: "Azure"
linkTitle: "Azure"
type: "architecture"
weight: 10
draft: false
lang: "en"
showToc: true
date: 2025-01-01
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

*Welcome!* In this guide, we’ll explore the **Aurora Platform** on Azure from four different views. Each view offers a perspective on how the system is structured. We’ll use simple language and analogies to make things clear. You should have a good understanding of Aurora’s cloud architecture. Let’s dive in!

## Repositories that Power Aurora

Before we dive into the views of Aurora’s architecture, it’s helpful to know where the platform's core code lives. Aurora is developed and delivered entirely as code — from infrastructure to platform components — and these efforts are organized across three GitHub Enterprise organizations:

- **[`gccloudone`](https://github.com/gccloudone):** This is home to Aurora’s public-facing content, including documentation, diagrams, and our [Hugo-based website](https://aurora.gccloudone.ca).
- **[`gccloudone-aurora`](https://github.com/gccloudone-aurora):** The main source of Aurora’s tooling — including Kubernetes manifests, controllers, policies, and other GitOps-configured components that define the platform.
- **[`gccloudone-aurora-iac`](https://github.com/gccloudone-aurora-iac):** This organization contains all Infrastructure as Code used to deploy Aurora environments. Currently, it includes our full Terraform implementation for Azure.

These repositories represent the foundation of Aurora — they encode how we build, secure, and scale the platform. Everything described in the views below is defined and managed through these open source assets.

## Single Cluster Instance View

![Single Cluster Instance View](/images/architecture/diagrams/single-cluster-instance-view.svg)

### Overview

This view zooms into a single Kubernetes cluster deployed on Azure. It highlights how workloads run within a isolated Virtual Network (VNet), with tightly controlled ingress and egress.

Network Security Groups (NSGs) enforce traffic policies — allowing only specific types of ingress (e.g., HTTPS) and egress (e.g., access to update services or private endpoints). Applications are accessed through a load balancer, while services like Key Vault or Blob Storage are reached via Private Endpoints within the Azure backbone — ensuring no traffic flows over the public internet.

The use of multiple pools (system, gateway, user/general) ensures stronger isolation between user workloads and system components, ensuring that a compromise of a user workload (container escape, for example) would not be able to impact a system component, which likely has elevated permissions.

Administrators connect to the cluster using via a jumpbox that is peered to the AKS cluster virtual network.

The Kubernetes API server is set to private mode — reachable only from within the network and not exposed to the internet.

To support hardened networking and secure routing, Aurora deploys internal route reflectors using BGP and Cilium, ensuring communication between pods and networks.

### Breakdown

**What this view represents:** This is a close-up look at one Aurora Kubernetes cluster running in Azure. Imagine zooming in on a single cluster – you’ll see how it’s set up in the cloud network, how it connects to users and admins, and how it reaches other services. It’s like looking at one “instance” of the platform in action.

**How it functions:** In the single-cluster view, you see all the components that let the cluster talk to the outside world (and vice versa) securely. Picture a fenced-off area (the cluster’s virtual network) containing the cluster’s nodes and related resources. There are gates and rules for what can go in or out:

- **Network Security Groups (NSGs):** They are sets of rules controlling traffic in and out of the cluster’s network. For example, an NSG rule might “allow web (HTTP/S) traffic in to the application, but block everything else” or “allow only our admin’s IP to access the cluster’s SSH port.” These NSG “flows” ensure only the right kind of traffic reaches the cluster and that the cluster can only send out what's permitted. In the diagram, arrows labeled NSG Flows show how traffic is filtered at each point.
- **Load Balancer:** In Aurora’s case, when users access an application (say a web app) running in the cluster, their HTTP/S requests go to an Azure Load Balancer (or similar gateway). The load balancer takes incoming requests and forwards them to the appropriate service inside the cluster (ingress controller or directly to a service’s pods).
- **API Server Access:** Every Kubernetes cluster has an API server (the brain of the cluster). In Azure Kubernetes Service (AKS), this API server can be made private (accessible only inside the Azure network) or public (internet accessible with IP restrictions). Aurora’s architecture uses a private approach – meaning the API server is not open to the internet. Instead, administrators reach it through the internal network. The API server is shown in the view with a label, and it communicates with the kubelet on each node (the node’s agent) to manage the cluster.
- **Jumpbox (Bastion Host):** To keep things secure, direct access to cluster VMs is blocked from the internet. Instead, Aurora uses a jumpbox, which is a secure virtual machine in the cluster’s network that admins can log into first, and then access the cluster from there. You SSH or RDP into the jumpbox (after connecting through a secure pathway), and from that box you can, for example, run `kubectl` commands or SSH into individual Kubernetes nodes if needed. This way, the cluster nodes themselves don’t have to expose SSH to the world. The diagram shows a “workstation” (your admin laptop) connecting via SSH traffic to the jumpbox. The jumpbox sits in the same VNet as the cluster, so it can reach the nodes.
- **Private Connection (VPN/ExpressRoute):** How does your workstation actually reach that jumpbox if it’s not public? That’s where the gateway comes in. Aurora’s single cluster view includes a Gateway which typically represents a VPN Gateway or ExpressRoute Gateway in Azure. This creates a private connection between your on-premises network (like your office or home network) and the Azure virtual network containing the cluster. It’s like an encrypted tunnel or private bridge. Through this gateway, you can safely RDP/SSH into the jumpbox VM without exposing it publicly. In simpler terms: you connect to Azure through a VPN, and once “inside” Azure’s network, you can reach the cluster’s resources as if you were in the same local network.
- **Outbound Internet Access:** Clusters often need to fetch updates or communicate with external services. In the diagram, Outbound Traffic arrows indicate how the cluster talks out to the internet or other external endpoints. By default, Azure allows outbound internet from a VNet, but Aurora controls it via NSGs or a special egress such as an Azure NAT or firewall. In a basic sense, imagine the cluster’s network has a controlled doorway for outgoing traffic – ensuring, for example, that nodes can reach Windows Update or container registries, but bad traffic can’t sneak out or in.
- **Private Endpoints to Azure Services:** Aurora Platform uses Azure services like storage and key vault for things like backups and secrets. The single cluster view shows Private Endpoints (marked as “pe” in the diagram) for services such as Azure Key Vault and Azure Blob Storage. A *Private Endpoint* means the cluster connects to those services via a private link within Azure, not over the public internet. Concretely, Azure gives the service a private IP inside the cluster’s VNet. Private DNS zones (shown in the diagram for vault and blob, e.g. `privatelink.vaultcore.azure.net`) provide internal DNS names for these endpoints. So when something in the cluster needs to talk to Key Vault (for retrieving secrets) or Storage (for saving backups), it uses an internal address. This is like having a direct private line to Azure services, avoiding exposure to the internet. For you, it means more security and potentially lower latency.
- **Zones and Redundancy:** You might notice the diagram references Zone 1, Zone 2, Zone 3. Azure regions are often divided into Availability Zones – separate physical locations – to improve resilience. Aurora’s cluster spans multiple zones so that even if one zone has an outage, the cluster still runs in the others. In the single cluster view, the nodes and components are distributed across Zone 1/2/3. For example, if you have three nodes, each might live in a different zone. The load balancer also can be zone-redundant. This setup means a single cluster instance is built with high availability in mind.
- **Route Reflectors (internal):** If you’re not familiar with networking, you can think of a route reflector as a “traffic coordinator” within the network – it makes sure every subnet or connected network knows how to reach others without having to directly talk to each one (kind of like a centralized map distributor). In a single cluster, route reflectors might be used if the cluster’s CNI (container network interface) uses BGP (Border Gateway Protocol) for pod networking or if the cluster VNet is peered with others. Aurora deploy route reflector components (as part of the Cilium networking) to handle routing.

**Key components in this view:** Summarizing the single cluster instance, the key building blocks you should remember are:

- **Azure Kubernetes Service (AKS) cluster:** The group of nodes running your containers. Azure manages the control plane for you (the Kubernetes API servers etc.), so you focus on the nodes and what’s deployed.
- **Virtual Network (VNet):** The private network in Azure that isolates the cluster and its supporting services.
- **Subnets and NSGs:** Sub-divisions of the VNet where different things reside (e.g., one subnet for AKS nodes, one for the jumpbox). NSGs on these subnets (or NICs) enforce the “who can talk to whom” rules.
- **Jumpbox:** A secure admin VM for access (no direct public access to nodes).
- **Load Balancer:** Entry point for app traffic (distributing traffic to cluster services).
- **VPN/ExpressRoute Gateway:** Allows secure connections from on-prem or your device to the Azure network (so you can reach internal-only endpoints like the API server or jumpbox).
- **Private Endpoints & DNS:** Used to connect the cluster internally to Azure services like storage and vault without going over internet – providing private, secure service access.
- **Route Reflector :** Network helper to share routes within the cluster network or with other networks.

**Example to tie it together:** Imagine you’ve deployed a web application on this Aurora cluster. A user from the internet visits the app:

1. Their browser’s request hits a public IP which is tied to the cluster’s load balancer.
2. The load balancer forwards the request (over HTTPS) to an ingress controller pod running in the cluster. This ingress pod knows which application service should get the traffic.
3. The request goes to your web app pod, the pod generates a response, which goes back out through the ingress and load balancer to the user. All of this was allowed by NSG rules that permit HTTPS in.
4. Now, let’s say your web app needs to fetch a secret from Azure Key Vault. The app calls the Key Vault URL (a privatelink address). Thanks to the Private Endpoint, this traffic goes through the cluster’s VNet to Key Vault internally – never exposing the call on the internet. The NSG allows this because it’s internal or using a service tag for Azure services.
5. As an admin, you want to check something on the cluster. You connect via VPN (through the Azure gateway) from your laptop, then SSH into the jumpbox. From the jumpbox, you run `kubectl` to talk to the Kubernetes API server of the cluster. The API server is in a private IP space (with a private DNS name like `mycluster.cloud-nuage.canada.ca`), so it only resolves when you’re in the network. The jumpbox *can* reach it (either because the API server’s private endpoint is in the VNet or the jumpbox has access via Azure’s internal routing to the managed control plane). You can now manage the cluster securely.
6. Any monitoring agents on the cluster that need to send data out ( to a centralized monitoring service) will send it through the allowed outbound path  through an egress load balancer or NAT). If an internet call is not allowed by NSG or if it’s something like trying to reach a disallowed IP, the NSG or other policies would block it. This keeps the cluster from making unwanted connections out.

This single cluster view basically shows an Aurora AKS cluster in its own secure bubble, with controlled doors for entry and exit. It’s the foundation – now let’s see how multiple clusters relate to each other.

---

## Multi-Cluster Instances View

![Multi Cluster Instance View](/images/architecture/diagrams/multi-cluster-instance-view.svg)

### Overview

This view zooms out from a single cluster to show how Aurora manages multiple clusters across the SDLC lifecycle (i.e., Dev, NonProd, Prod, and Management). 

Each environment is logically separated using its own Azure subscription / virtual network, providing isolation and governance boundaries. 

Clusters are named consistently and grouped by environment to support development pipelines, testing, production workloads, and shared services.

The Enterprise hub-and-spoke design allows environments to communicate securely when needed while still enforcing strict separation where appropriate. 

This design also allows environments to communicate securely when needed (i.e., ArgoCD in Management deploying to Dev), while still enforcing strict separation where appropriate (i.e., Dev cannot reach Prod). 

NSGs and route-sharing policies ensure that traffic is tightly controlled, enabling secure inter-cluster operations without increasing complexity.

The result is a scalable, secure architecture where multiple clusters operate independently but are managed as a unified platform. 

### Breakdown

**What this view represents:** Aurora isn’t just one cluster – it’s designed to manage multiple clusters (for different purposes or environments). The Multi-Cluster Instances View zooms out a bit. It shows how several cluster instances coexist and connect (or stay isolated) within the Aurora Platform on Azure. Think of it as looking at a neighborhood of clusters: dev clusters, test clusters, prod clusters, maybe a management cluster – each is like a house on a street, and this view is the map of the neighborhood.

**How it functions:** Organizations often have separate clusters for development, testing, staging, and production. This view demonstrates that structure. In Aurora’s context, you’ll see references to groups like **AuroraDev, AuroraNonProd, AuroraProd, AuroraMGMT** – these correspond to different Azure subscriptions or resource group groupings for various environments:

- For example, **AuroraNonProd**  encompass all non-production clusters (development, test, QA, UAT, etc. all considered “non-prod”). Within that, you might have cluster instances named for each environment (like `gen-dev-cc-00` for a dev cluster, `gen-test-cc-00` for test, `gen-uat-cc-00` for UAT, etc. – these look like naming conventions in the diagram).
- **AuroraProd** contains the production-related clusters (the actual prod cluster, and  others like a canary or performance-testing cluster that closely mirror prod).
- **AuroraMGMT** is a special environment for management or shared services (for instance, a cluster that runs platform-wide tooling like ArgoCD, or hosting route reflectors and such).
- **AuroraDev** is a dedicated environment for platform developers (or it could be that dev clusters are separate from other non-prod, depending on naming).

The key point is that multiple AKS clusters are deployed, and they are logically separated by environment, but also networked in a certain topology for controlled connectivity.

**Key components and concepts in this view:**

- **Isolation by Virtual Network and Subscription:** Each cluster is in its own Virtual Network (VNet). For instance, the dev cluster has its VNet, test cluster its VNet, etc. This provides isolation – services in one cluster’s VNet can’t directly talk to another cluster’s VNet unless we explicitly allow it. Also, each environment (dev, nonprod, prod) could be in separate Azure subscriptions for an extra layer of isolation and independent control (common in enterprises). So, a prod subscription holds prod cluster VNet, a nonprod subscription holds dev/test/uat VNets, etc.
- **Hub-and-Spoke or Mesh Networking:** When you have multiple VNets, you choose how they connect. Aurora’s architecture uses **Route Reflectors** to manage connectivity. A simple way to connect VNets is VNet Peering (directly connecting two networks), but with many clusters that can become hard to manage (a lot of connections). Instead, Aurora uses a central approach:
  - **Route Reflectors as a Networking Hub:** In the diagram, you see specific route reflector instances named per environment (e.g., `route-reflector-nonprod-cc-00`, `route-reflector-prod-cc-00`, and also `route-reflector-{0,1,2}` which represent multiple instances for redundancy). These route reflectors essentially act as a hub for sharing routes. Using BGP, each cluster’s network can advertise its IP ranges to the route reflector, which in turn reflects (shares) those routes to other networks that need to know them. This means if, say, the dev cluster needs to talk to the management cluster, it can, without us manually adding route tables everywhere – the route reflector tells dev how to reach mgmt and vice versa.
  - *Analogy: Imagine that each cluster is a separate gated community. The route reflectors are like a central post office that knows the address of every house in all communities. When one house wants to send a letter to another, they ask the post office for the route instead of every house having direct lines to every other. It reduces the complexity of connecting everyone directly.*
- **Controlled Inter-Cluster Traffic:** Even though routes exist, Aurora will still enforce security. NSGs or firewall rules can limit what inter-cluster traffic is allowed. For instance, dev and test clusters are able to talk to the management cluster, but not directly to the prod cluster (to keep prod safe). Prod only accept connections from specific sources (like jumpbox). Each environment’s route reflector only share certain routes to maintain partial isolation. So, *isolation* is maintained where needed, with *connectivity* provided where appropriate.
- **Shared Services and MGMT Cluster:** The **AuroraMGMT** environment contains shared resources that all environments use. This include:
  - A **Management Cluster** (the one named `mgmt-dev-cc-00` in the text) that run cross-cutting tooling such as ArgoCD (continuous deployment tool) or other control-plane components that manage other clusters.
  - **Jumpboxes or Bastions per environment:** The multi-cluster diagram shows one jumpbox per environment domain. The idea is that administrators have a secure way into each environment’s clusters via these designated hosts.
- **Environment Naming and Examples:** The diagram lists some example cluster names:
  - `gen-dev-cc-00`, `gen-test-cc-00`, `gen-qa-cc-00`, `gen-uat-cc-00`, `gen-prod-cc-00`, `gen-canary-cc-00`. Each of these is an AKS cluster instance for that stage of the pipeline.

**How clusters connect in practice:** Let’s illustrate with an example scenario:

- Suppose you have a CI/CD pipeline that builds new application releases and deploys them to the dev cluster, then test, then prod. The pipeline (or ArgoCD) running in the management cluster (AuroraMGMT). When it needs to deploy to dev cluster, it connects from mgmt cluster to the dev cluster’s API server. Because of the network setup with route reflectors, the management cluster’s network knows how to reach the dev cluster’s API (via a private endpoint or peering). NSGs on the dev cluster allow the mgmt cluster’s IP to hit the API server. This is a controlled pathway: only the mgmt cluster or authorized networks can do this.
- Aurora’s design with environment-specific route reflectors prod route reflector is separate, meaning by default prod does not exchange routes with nonprod. That keeps dev/test from ever reaching prod accidentally. Only the mgmt or core might have visibility into all for oversight.

So, the multi-cluster view essentially shows multiple clusters, divided by purpose, with a smart network in place to connect or isolate them as needed. The route reflectors act as the central nervous system for connectivity.

**Key components in this view:**

- **Multiple AKS Clusters:** each an instance of Aurora platform for a specific use case (dev, test, prod, etc.).
- **Environment Groupings:** logical grouping of clusters (Dev, NonProd, Prod, etc.) often corresponding to Azure subscriptions or management groups, providing isolation and governance boundaries.
- **Route Reflectors & Core Network:** special routers that distribute network routes, enabling clusters to communicate through a hub rather than many peer-to-peer links. They reduce complexity in multi-cluster networking.
- **Gateways and Private Links:** Just like the single cluster had a gateway for on-prem access, in multi-cluster there is a central gateway for each environment. For example, you have one VPN connection into nonprod environment and another into prod environment. The goal remains to let authorized users in securely, and keep environments separated so mistakes in dev don’t impact prod.

**To sum up:** The multi-cluster view gives you the big picture of Aurora on Azure – it’s not a lone island, it’s an archipelago of clusters. Each island (cluster) has its own perimeter (network), but there’s a controlled ferry system (route reflectors and gateways) connecting them under the surface. This allows Aurora to scale to many teams and stages, all under a consistent setup. If you’re a developer, you might interact mostly with the dev cluster, but it’s comforting to know prod is in the same style yet safely distant. If you’re a platform admin, this view shows how you can manage a fleet of clusters as one platform.

---

## Platform View

![Platform View](/images/architecture/diagrams/platform-view.svg)

### Overview

This view zooms into the internal architecture of an Aurora cluster to show the curated platform components that are automatically deployed with every instance. 

Rather than starting from a blank Kubernetes cluster, Aurora equips each environment with production-grade tooling out-of-the-box. Key components include Cilium for hardened networking, Istio for ingress and service mesh, Prometheus and Fluent Bit for monitoring and logging, cert-manager for TLS automation, and Gatekeeper (OPA) for policy enforcement. These tools run in dedicated system namespaces and are managed by Aurora with strict RBAC—keeping platform and application concerns cleanly separated.

Argo CD powers the GitOps delivery model behind the scenes, ensuring all platform components and configurations are defined as code and continuously reconciled. Namespaces follow a clear convention: system for platform tooling, gateway for ingress components, and general for solution builder teams.

Services like Velero (for backup), Workload Identity (for Managed Identity integration), and OpenCost (for cost visibility) round out a complete developer-ready foundation.

For application teams, this means less operational overhead and faster onboarding. 

Developers can focus on shipping code, while Aurora enforces security, handles connectivity, and provides the observability, governance, and automation needed to run workloads reliably.

### Breakdown

**What this view represents:** Now we zoom *inward*. The Platform View focuses on what’s inside each Aurora cluster – specifically, the common platform components that Aurora provides on top of vanilla Kubernetes. In other words, when you create an Aurora cluster, it’s not empty; it comes with a bunch of built-in capabilities (networking, monitoring, security, etc.). This view lays out those components and how they relate. It’s like an x-ray of the cluster’s software architecture.

**How it functions:** Aurora Platform leverages many open-source tools and Kubernetes add-ons to provide a full-featured environment. These are typically running in their own namespaces within the cluster and serve platform-wide roles (as opposed to your application code, which would run in separate namespaces). The platform components cover areas like networking, security, ingress, logging, monitoring, backup, and more – all of which make the cluster production-ready. Let’s break down the key components you’d find and their roles:

- **Cilium (CNI & Network Security):** Cilium is the cluster’s networking plugin. Kubernetes needs a CNI (Container Network Interface) to handle pod networking – how pods get IPs and talk to each other. Cilium provides that, and it’s quite advanced: it operates at the packet level using eBPF. Cilium means pods in Aurora clusters can communicate efficiently, and we also get extra features like network policies (like firewall rules between pods) and even the ability to do BGP for routing (Cilium can integrate with BGP to announce pod networks). In simpler terms, Cilium makes sure every pod can talk to the others it’s allowed to, and blocks those it shouldn’t (for example, we could say “frontend pods can talk to backend pods, but not directly to the database pods”, and Cilium enforces that). It’s part of the “infrastructure” layer inside the cluster (often in a namespace like `cilium-system`).
- **Ingress Controller (Istio or others):** The diagram references Istio (an open-source service mesh). Istio can function as both a service mesh and an ingress controller (via its gateway component). Aurora uses Istio (in `istio-system` namespace) to manage incoming traffic and service-to-service traffic. For incoming traffic, Istio’s ingress gateway pod will receive traffic from the Azure load balancer and then route it to the correct service in the cluster. This is how your apps get exposed. The term “gateway” in the platform view corresponds to this ingress gateway.
- **Cert-Manager:** This component (in `cert-manager-system` namespace perhaps) handles SSL/TLS certificates for the cluster’s services. For example, if your ingress needs a certificate for `myapp.example.com`, cert-manager can automatically get one (from Let’s Encrypt) and renew it. It automates certificate management – so you get HTTPS for your apps without manual steps. In Aurora, cert-manager ensures everything that needs a cert (ingress gateways, etc.) has one and stays up-to-date.
- **Open Policy Agent (OPA/Gatekeeper):** Policy enforcement is crucial in a multi-team cluster. Aurora includes OPA (likely the Gatekeeper variant which integrates with Kubernetes as an admission controller). OPA lets platform admins define rules like “pods cannot run as root user” or “only certain registries are allowed for images”. It then checks every new object against these rules. For a developer, this means if you try to deploy something that violates a policy, it will be rejected with a clear message. It keeps the clusters compliant and secure by design. OPA runs in (for example) `open-policy-agent-system` namespace.
- **Prometheus & Monitoring:** Aurora clusters come with Prometheus. Prometheus scrapes metrics from various components and your apps (if configured) and stores them. This enables you to set up alerts (like if CPU is high) and view performance data. Prometheus will collect data from things like the Kubernetes API (via metrics-server), Istio’s metrics, node metrics, etc.
- **Fluent Bit (Logging):** Logs from applications and system components need to go somewhere central. Fluent Bit is a lightweight log forwarder. It runs on each node (or as a daemonset) and reads logs (for example, container logs) and ships them to a log store. In Aurora’s context, Fluent Bit is configured to send logs to an Azure log analytics workspace. This means you don’t have to manually log into nodes to see logs – they’ll be aggregated.
- **Velero (Backup):** Velero is a tool for backing up and restoring cluster resources and persistent volumes. In Aurora, Velero (in `velero-system`) enables scheduled backups of critical data: for example, if you have a database running with persistent storage, Velero can snapshot that volume to Azure Blob Storage (hence the need for that blob private endpoint we saw). It can also backup Kubernetes objects (like all your deployments, services, etc.) so that in a disaster, you could restore the cluster state.
- **KubeCost (Cost Management):** KubeCost (in `kubecost-system`) is an open-source tool that monitors resource usage and estimates cost. On Azure, it can tell you “this deployment is costing X dollars” by looking at resource consumption and pricing. Aurora cares about transparency of usage – as a user, you might get reports or dashboards showing how much each team or app is consuming.
- **Workload Identity:** In Azure, Workload Identity integrates AKS with Azure AD such that pods can have an identity and directly fetch tokens to use Azure services. It’s an improvement over older methods like storing service principals in Kubernetes secrets. Aurora’s platform view lists Workload Identity in `identity-system`.
- **Argo CD (GitOps):** Argo CD is a GitOps tool that continuously deploys the desired state from git repositories to the cluster. In Aurora, Argo CD is used to deploy and manage all the aforementioned components and your applications. This means the entire platform (Cilium, Istio, OPA, etc.) is defined as code (YAML in git) and Argo CD makes sure the cluster always has what’s in git. If someone manually changes something in the cluster, ArgoCD will revert it back to match git (or at least flag it), which keeps configurations consistent and prevents drift.
- **Namespaces and Organization:** The platform view shows categories like gateway, general, system, solution, frontend 1..N, backend 1..N etc.
  - *System* namespaces are those used by the platform itself (all the ones we listed: cilium-system, istio-system, etc.). These are maintained by Aurora Platform – end users (app teams) typically won’t deploy there.
  - *Solution* or *Application* namespaces: where your actual workloads (your apps) run. For example, you may deploy an app with a front-end service and back-end service, possibly each can scale independently hence 1..N).
  - *Gateway* and *General*:  Special namespaces or categories for things like ingress gateways or common services. For instance, “ingress-general-system” namespace hosts general ingress controllers for apps.
  - The key idea is Aurora has a template for namespaces: e.g., a *general* namespace for certain default services, a *gateway* namespace for the Istio ingress gateway, *system* for core components, and then separate *application* namespaces for users. This separation ensures that platform components and user workloads don’t clash and can be managed independently.

**Why this matters:** The Platform View might seem like a lot of technical detail, but here’s why it’s awesome for someone using Aurora:

- **You get a lot out-of-the-box:** Networking that’s more secure (Cilium, Istio), automated SSL (cert-manager), built-in monitoring (Prometheus, FluentBit), backup (Velero), policy guardrails (OPA), etc. You don’t need to install or configure all these from scratch for your project – Aurora provides a ready platform.
- **Consistency and automation:** Because these are standardized, every Aurora cluster has the same capabilities and tools configured the same way. That consistency means less “snowflake” differences between environments. Also, with ArgoCD and IaC, updates to these components roll out uniformly.
- **Focus on your app:** With Aurora handling these platform concerns, your team can focus more on developing the application (the “solution”) rather than the plumbing. For example, need to expose a service? The ingress is already there – just define an Ingress resource and cert-manager will get the certificate and Istio will route the traffic, all following the security policies in place.

In summary, the Platform View is like looking under the hood of a high-end car: you see the engine, battery, wiring (Cilium’s engine, OPA’s safety system, Prometheus’s dashboard, etc.), which all work together to make the ride smooth. You don’t necessarily interact with each piece directly every day, but knowing they’re there and what they do helps you understand the capabilities of your Aurora cluster.

---

## Infrastructure / Config as Code View

![Infrastructure / Config as Code View](/images/architecture/diagrams/iac-cac-view.svg)

### Overview

This view illustrates how Aurora is architected around Infrastructure as Code (Terraform) and GitOps (Argo CD). Terraform provisions the foundational cloud infrastructure — including networking, Kubernetes clusters, and route reflectors — while Argo CD continuously applies platform components (such as Cilium, Cert Manager, and OPA) as code directly from Git repositories. 

Aurora’s high-level architecture embraces a cloud-agnostic design, enabling deployment on Azure AKS, Amazon EKS, and Google GKE using equivalent Terraform modules and shared platform manifests. We interface directly with each Cloud Service Provider’s team at SSC to ensure seamless integration, secure configuration, and proactive alignment with each C.S.P’s best practices. 

This approach provides a uniform developer experience across C.S.P’s, reducing complexity, and achieving some level of shared governance.

### Breakdown

**What this view represents:** The Platform High-Level View is the big picture architecture of Aurora – it ties everything together in a simplified way, often highlighting the relationships between the platform components, the infrastructure, and how it’s managed. This view steps back to show not just one cluster or multiple, but how the Aurora platform is delivered and maintained across potentially multiple clouds or regions. It’s a bit like a blueprint or flowchart of the entire system from a product standpoint.

**How it functions:** At a high level, Aurora Platform can be thought of in layers:

1. **Infrastructure as Code (IaC) layer**, which is how the cloud resources (networks, clusters, route reflectors, etc.) are created.
2. **Platform (Cluster software) layer**, which is the set of Kubernetes add-ons and configurations.
3. **Cloud provider** underneath that actually runs the Kubernetes service (Azure in this case, but possibly others).
4. **Applications (Solutions)** on top, which are what end-users deploy into the platform.

Aurora’s design likely emphasizes automation and reproducibility. The high-level view shows that:

- **Everything is code and automated:** The presence of Infrastructure as Code (Terraform) and Configuration as Code (ArgoCD manifests) in the diagram is a strong indicator. For Azure, Aurora uses Terraform scripts (`terraform-aurora-azure-environment`) to provision things like the resource groups, the Virtual Network, the AKS cluster, perhaps the route reflector VMs, etc. This ensures that if we need another cluster or want to rebuild an environment, we run the code and get the same outcome every time. It also means version control for our infrastructure – changes go through code reviews, reducing human error.
- **Multi-Cloud Flexibility:** Interestingly, the high-level view references not just Azure AKS, but also Google GKE and Amazon EKS. This tells us Aurora Platform is designed to be cloud-agnostic to a degree – the platform components and approach can be deployed on different cloud providers’ Kubernetes services. So Azure is one supported environment, but the same Aurora platform could run on AWS or GCP. For the reader, this means Aurora isn’t leveraging anything too proprietary that locks it to Azure only; it’s using common capabilities that all these clouds have (like their managed K8s). The diagrams lists Terraform for Azure, GCP, AWS – likely separate modules for each, but providing similar end results. The idea is that a developer using Aurora shouldn’t notice much difference whether their cluster is on Azure or elsewhere – it will have the same Aurora flavor.
- **ArgoCD (GitOps) manages the platform config:** The high-level view explicitly shows Platform Manifests (ArgoCD). This means all those components like Istio, OPA, etc., are defined in Git repos (manifests). ArgoCD continuously ensures the clusters have those manifests applied. This is often called “Configuration as Code” or sometimes “Cluster as Code” – the cluster’s desired state is stored in Git. The benefit is consistency and easy recovery: if a cluster’s state is lost, ArgoCD can replay what’s in Git onto a fresh cluster. It also means changes to platform components (say we want to upgrade Prometheus or tweak a config) are done via git commits, not manual kubectl – giving traceability.
- **Aurora Platform glue:** The diagram shows an “Aurora Platform” box encompassing ArgoCD and Terraform with arrows to AKS/GKE/EKS. Aurora Platform itself is the combination of these tools/processes that deliver a ready-to-use Kubernetes environment. It’s the secret sauce binding infra and software.
- **High-Level Summary Example:** Let’s say a new cluster for a new project needs to be created. How would Aurora do this at a high level?
    1. A Terraform configuration (part of the Aurora Platform repository) is prepared for that cluster (with parameters like environment, region, etc.). This is run (via a pipeline), and Terraform creates all the Azure resources: Resource Groups, Virtual Network, Subnets, NSGs, the AKS cluster itself, the needed route reflector setup, private DNS zones, etc. (Everything we saw in the single cluster view structurally). Now we have an empty AKS cluster.
    2. Once the cluster is up, ArgoCD (which is running in a management cluster) sees a new entry for this cluster in its config. It then connects to the cluster and starts applying the Aurora platform manifests: installing Cilium, Istio, OPA, etc., basically turning the empty AKS into an “Aurora cluster.” After a short while, the cluster is fully configured with all platform components healthy.
    3. Now the cluster is ready for applications. Teams can deploy their apps (possibly also via ArgoCD or their pipelines) into their namespaces on that cluster.
    4. We can do the same steps on GCP’s GKE – using Terraform for GCP and then the same ArgoCD manifests. Aurora abstracts the cloud differences and presents a consistent Kubernetes platform.

**Key components in this view:** (recapping in a simpler list form)

- **Infrastructure as Code (Terraform):** Automates creation of Azure resources for Aurora. Define once, use many times. If someone asks “how is the network configured?”, you can point to code rather than say “Alice clicked around in the portal” – which is great for transparency and consistency.
- **Continuous Deployment of Platform (Argo CD GitOps):** Automates the setup of the cluster’s internals. Ensures any drift is corrected and updates are rolled out to all clusters reliably.
- **Managed Kubernetes Services:** Aurora relies on managed k8s (AKS in Azure). This means Azure handles the Kubernetes control plane (masters etc.), and Aurora handles what’s installed *on* the cluster. This reduces ops burden (no need to manage etcd or control plane upgrades directly; Azure does that).
- **Cloud-Agnostic Design:** Ability to implement the same on AWS and GCP. For Azure-specific discussion, you might not worry about this, but it’s nice to know that Aurora’s concepts are not limited to one cloud. If Azure offers a unique service, Aurora would use it only if it can find equivalent approaches on others, or make it optional.
- **High-Level Security & Governance:** At this high level, also consider things like: role-based access, CI/CD integration, and auditing. The platform integrates with Azure AD for cluster access (so your logins are centralized), uses Azure’s monitoring (or its own centralized monitoring) to watch cluster health, and has governance policies (like those OPA rules and Azure Policy perhaps) to ensure compliance. The high-level view assures stakeholders that the platform is not a wild west – it’s controlled by code and best practices.

For tech folks: “*Look, we have a reliable system: we define everything as code, we use tried-and-true open-source components, and we can deploy this platform on any cloud. It’s automated, scalable, and consistent.”*

For a non-technical colleague : “*Aurora is built so that setting up or updating our cloud Kubernetes environment is as push-button as possible. We treat our setups like a recipe – follow the same recipe, get the same environment every time (that’s Infrastructure as Code). And we keep the running environments aligned with the recipe (that’s GitOps with ArgoCD). It’s like having an autopilot for our infrastructure and clusters, reducing manual work and mistakes.”*

As a wrap up, hopefully these four views have given you a clear mental model:

- The **Single Cluster Instance View** showed one cluster’s detailed plumbing (how a cluster is secured and connected in Azure).
- The **Multi-Cluster View** showed how multiple clusters are organized and networked in Aurora (how we manage many clusters across environments).
- The **Platform View** zoomed into the cluster to see the built-in tools and services that Aurora provides (the features and add-ons that make the platform developer-friendly and robust).
- The **Infrastructure as Code View** zoomed out to see how the whole system is delivered and managed at scale (the philosophy of automation and consistency across the platform).

Aurora’s architecture is complex under the hood, but it’s designed to make life easier for users on top. You can now envision it as a series of layers and connections, rather than a black box.

---

## Configuration as Code Extended View

![Configuration as Code Extended View](/images/architecture/diagrams/cac-extended-view.svg)

### Overview

With respect to the platform charts each of the now 35 components is toggleable, allowing departments to enable only what they need, while maintaining alignment with a consistent, composable platform. Every cluster becomes reproducible, consistent, and auditable — eliminating manual setup and configuration drift.

Each cluster is treated as an interchangeable instance of Aurora — automatically bootstrapped and continuously reconciled through GitOps.

---

## Glossary

*Below are definitions for technical terms used in this guide:*

- **AKS (Azure Kubernetes Service):** Azure’s managed Kubernetes offering. It handles the heavy lifting of running Kubernetes masters/control plane so you can just deploy your containers. In short, it’s Kubernetes-as-a-service on Azure. You get a cluster without having to set up the whole thing from scratch – Azure takes care of updates, scaling the master, etc., and you manage your node pools and apps.
- **Virtual Network (VNet):** A private network in Azure where you can place your resources (like VMs, clusters, etc.). It’s like your own isolated network in the cloud. You can divide it into subnets, set address ranges, and control traffic within it. Think of it as the foundation for any Azure network setup – akin to having your own local network, but in Azure’s data centers.
- **Network Security Group (NSG):** An NSG is basically a cloud firewall for your Azure network resources. It’s a set of rules that either allow or deny traffic based on source, destination, port, and protocol ([Azure network security groups overview | Microsoft Learn](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#:~:text=You%20can%20use%20an%20Azure,and%20destination%2C%20port%2C%20and%20protocol)). You can attach NSGs to subnets or individual VM network interfaces. For example, an NSG can ensure only port 80/443 are open to your web server, and everything else is blocked. NSGs are stateful, meaning if traffic is allowed in, the response is automatically allowed out. In our context, NSGs protect the cluster’s subnets (allowing, say, Kubernetes API traffic only from the jumpbox, or database traffic only internally, etc.).
- **Load Balancer:** A service that distributes incoming traffic across multiple targets (VMs or pods). Azure provides both Layer 4 load balancers (Azure Load Balancer) and Layer 7 load balancers (Application Gateway). In Aurora’s case, a load balancer gives the cluster a single point of contact (IP address) for services. When users hit that IP, the LB forwards the request to one of the instances of the application running in the cluster. This ensures reliability and scalability – if one pod is down, the LB directs to another. It’s like having multiple checkout lanes at a store with a person directing each customer to an open lane, rather than all piling into one line.
- **Gateway (VPN Gateway / ExpressRoute):** In networking, a gateway connects two different networks. An Azure VPN Gateway is a service that establishes a secure, encrypted tunnel between an Azure VNet and another network (like your on-premises network). It allows data to travel safely over the public internet as if it were a direct private link. ExpressRoute is a different kind of gateway that creates a private dedicated connection (not over the internet) between your on-prem network and Azure – even more secure and reliable, often used by enterprises. In our discussion, the gateway allowed our on-prem or developer machine to connect into the cluster’s VNet privately (either via site-to-site VPN or ExpressRoute). It’s the door between your office and Azure’s house, with a guard ensuring only authorized folks get in.
- **Jumpbox (Bastion Host):** A jumpbox is a secure VM used as a jumping-off point to access resources in a private network. Instead of opening up every server to the internet, you just open one (the jumpbox), lock it down tightly (e.g., only allow your IP, use multi-factor auth, etc.), and then from that box you hop (“jump”) to the others which are not exposed. It’s often also called a bastion host. In Azure, there’s a service called Azure Bastion that can serve this purpose without needing a custom VM. In Aurora, the jumpbox was our secure entry to manage the cluster.
- **Private Endpoint / Private Link:** Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. For example, an Azure Storage account or Key Vault can be configured with a private endpoint in your VNet. This gives the service a private IP address in your network, meaning when your resources talk to that IP, they are talking to the Azure service via Azure’s internal network, not going out to the public internet. Private DNS Zone is typically used alongside this, so that the standard service URL (like `myvault.vault.azure.net`) resolves to that private IP inside your VNet. This way, your resources use familiar URLs but over a private connection. Private Endpoints essentially eliminate exposure of certain services to the internet, reducing risk.
- **DNS / Private DNS:** DNS (Domain Name System) is like the phonebook of the internet – it resolves human-friendly names (like `api.mycluster.cloud`) to IP addresses. Private DNS in Azure refers to DNS resolution that is scoped to your private networks ([What is an Azure Private DNS zone? | Microsoft Learn](https://learn.microsoft.com/en-us/azure/dns/private-dns-privatednszone#:~:text=Azure%20Private%20DNS%20provides%20a,provided%20names%20available%20today)). If you have a Private DNS Zone for `cloud-nuage.canada.ca` linked to your VNet, then when a VM in that VNet looks up `mycluster.cloud-nuage.canada.ca`, it will get a private IP, not any public IP. Private DNS zones are how we made the cluster’s API server reachable by a nice name internally, and how we mapped those Azure service private endpoints. They work only within the networks you allow (they’re not reachable from the public internet).
- **Route Reflector:** A route reflector is a concept from BGP (a routing protocol). In a network where many routers need to share routes, normally they’d all connect to each other in a full mesh – which doesn’t scale well as numbers grow. A route reflector simplifies this by acting as a central hub: other routers (clients) only share their routes with the reflector, and the reflector passes them on to everyone else. It “reflects” routing information. In Azure/Aurora context, route reflectors (could be implemented via Azure Route Server or FRR on VMs) allow all the different cluster networks to learn about each other’s existence without complex peering between every pair. Think of a route reflector as a post office for routes: everyone sends their route updates to the post office, and the post office sorts and delivers those updates to the intended recipients. This way, even in a network with 10 or 20 different sub-networks (like multiple clusters, plus on-prem), each network just maintains a connection to the reflector(s) rather than 19 other connections.
- **BGP (Border Gateway Protocol):** The protocol often used in route reflectors and internet routing. We mention it just to clarify: BGP is like the language routers speak to share routes (which network can reach which IP range). In Aurora’s case, if we say the clusters use BGP, it means their networks are sharing info dynamically (via route reflectors). You don’t need to configure static routes for each new cluster; BGP does it. (No need to go deep unless you’re curious; just know it’s the mechanism enabling that dynamic route sharing.)
- **Ingress Controller:** In Kubernetes, an ingress controller is what watches Ingress resources and implements the actual routing of external HTTP/S traffic to services in the cluster. Aurora uses Istio’s gateway as an ingress controller (most likely). Others might use NGINX ingress or Traefik. In any case, the Ingress Controller is the component that sits at the edge of the cluster, behind the cloud load balancer, and routes requests to the right pods. It often also handles TLS termination (SSL) – meaning it can present the certificate to the client. With cert-manager, it even gets the cert automatically. So, it’s a critical part of exposing services.
- **Service Mesh:** A general term (with Istio as an example) for a layer that helps manage internal service-to-service communication. A service mesh can do load balancing, encryption, authentication, and observability for calls between microservices. In practice, it often uses sidecar proxies in each pod. Aurora’s mention of Istio indicates it has a service mesh, meaning services can communicate through those proxies which can enforce policies (like “service A can’t talk to service B unless it’s on port X and authenticated”). It’s a way to have more control and visibility over the East-West traffic (inside cluster) similarly to how ingress controls North-South (in/out traffic).
- **Argo CD (GitOps):** Argo CD is a tool that implements the GitOps pattern. GitOps means you store your desired configurations (usually YAML for K8s) in a Git repository, and a tool (Argo CD) automatically applies those to your cluster and keeps them in sync. If someone changes something in the cluster that’s not in Git, Argo will change it back to match Git (or at least flag it as “OutOfSync”). It’s like a robot sysadmin that continuously checks “Does reality match what’s in Git? If not, I’ll fix it.” In Aurora, Argo CD ensures all the platform components and maybe even your apps (if they onboarded them to GitOps) are as per the definitions the team has approved. For a developer using Aurora, you might just commit your Kubernetes manifests to a repository, and Argo CD will deploy them to the cluster – you don’t manually deploy via kubectl in that model.
- **Terraform (Infrastructure as Code):** Terraform is a tool that allows you to define cloud infrastructure in code (using HCL – HashiCorp Configuration Language). For example, you can write “create a resource group, create a VNet, create a subnet, create an AKS cluster of X size” in a .tf file, and when you run Terraform it will make those things in Azure. If you change the code (say increase node count) and apply again, it will adjust the existing infrastructure to match. It’s idempotent and tracks state, so it knows what’s already deployed. In Aurora, Terraform is used to automate standing up everything (network, cluster, etc.). It’s how we codify the single cluster architecture – no clicking in the Azure portal needed. It’s also multi-cloud, meaning you can have Terraform configs for Azure, AWS, GCP that are very similar, just using different providers under the hood. This fits Aurora’s goal of being deployable on different clouds with one methodology.
- **Velero:** An open-source tool for backing up and restoring Kubernetes cluster resources and persistent volumes. It can snapshot volumes (e.g., cloud disk snapshots) and save the state of Kubernetes objects. Useful for disaster recovery or migrating workloads. In the simplest terms, Velero is like a backup service for your cluster – if something goes wrong, you can bring things back. It stores backups in object storage (Azure Blob in our case).
- **Prometheus:** A monitoring system and time-series database. Prometheus scrapes metrics from endpoints (apps expose metrics like “current CPU usage” or “request rate”) and stores them with timestamps. You can query it to make graphs or alerts (e.g., alert if CPU > 80% for 5 minutes). It’s the de facto standard in Kubernetes for monitoring. If you ever see graphs of cluster performance or set up an alert like “pod restart rate high”, that’s Prometheus working behind scenes. It usually comes with Alertmanager (to send notifications) and works well with Grafana for dashboards.
- **Fluent Bit / Fluentd:** These are log processors. Fluent Bit is a lightweight daemon that can read logs (from files or elsewhere) and forward them to a central place. For example, it might read all container stdout logs on a node and send them to Azure Log Analytics or an ElasticSearch cluster. Fluentd is a bit heavier but more capable; Fluent Bit is a slimmed down version. The main idea: they handle log collection, filtering, and distribution. In Aurora, they ensure your app logs end up somewhere you can query them, rather than being stuck on the node.
- **Open Policy Agent (OPA) / Gatekeeper:** OPA is a policy engine that can evaluate rules written in a language called Rego. In Kubernetes, OPA Gatekeeper is a common way to enforce policies on cluster objects. For example, you can prevent anyone from creating a LoadBalancer service in a dev cluster (maybe to avoid cost) by writing a policy. Or enforce labels on all resources, etc. Gatekeeper runs as an admission controller – every time something is about to be created or changed in K8s, it checks the policies first. If a policy is violated, it rejects the change and gives a message. This ensures best practices and security standards are followed automatically. It’s like having a built-in code reviewer for your cluster changes.
- **Workload Identity:** In Azure, this specifically refers to a newer method of giving Azure AD identities to pods (replacing an older method called AAD Pod Identity). Workload Identity federates Kubernetes service account tokens with Azure AD. The result is that a pod can request a token for an Azure AD App and Azure will trust it, because it knows that service account is allowed to act as that AD App (set up beforehand). Translation: a pod can directly get credentials to access Azure resources (like a storage account or Key Vault) without storing any secret, just based on its identity. It’s safer and more manageable than handling secrets. Aurora’s inclusion of Workload Identity means when you deploy an app that needs, say, to read from a storage account, the platform can be configured so that simply running under a certain K8s service account gives it the rights – no connection strings needed.
- **Dev/QA/UAT/Prod (environments):** These are typical stages in software development:
  - **Dev** (Development) is where developers work, possibly with lots of code changes, maybe unstable at times.
  - **QA** (Quality Assurance) is where testers verify the features, catch bugs.
  - **UAT** (User Acceptance Testing) is often where business stakeholders test that it meets requirements in a production-like setting.
  - **Prod** (Production) is the live environment for end-users.
  - In Aurora context, there might be separate clusters for each to mirror each other but with different data or load. They are isolated but part of the platform so that a deployment that works in UAT will work the same way in Prod (just bigger or with real data).
- **Canary Deployment/Cluster:** “Canary” refers to releasing a new version to a small subset to monitor its performance before rolling out to everyone (like the canary in a coal mine analogy). A canary cluster might be a small prod-like cluster where new releases are deployed first. If things go well, then they deploy to full prod. This reduces risk of a bad release taking down everything. Canary cluster is optional but nice for cautious rollouts.
- **Management Cluster:** A special cluster that isn’t for running business applications, but rather for running the tooling that manages other clusters. If AuroraMGMT has a cluster, that could be the management cluster. It might run ArgoCD, some monitoring aggregation, etc., and potentially even manage itself. It’s the “meta” cluster that keeps an eye on the others. Not all setups have this (sometimes ArgoCD is just running in each cluster individually), but the term is good to know. It’s like a control tower overseeing a set of airports (the clusters).

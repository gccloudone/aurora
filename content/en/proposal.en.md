---
title: "Strategic Proposal"
date: 2024-10-21
draft: false
sidebar: false
showToc: true
translationKey: "proposal"
disableCharacterlimit: true
---

## Project overview

Aurora represents the possible future state of a unified application hosting platform for the Government of Canada (GC). The platform integrates open-source Kubernetes (OSS) offerings on managed cloud services and proprietary (in some aspects) Kubernetes offerings delivered as platform-as-a-service (PaaS), providing a standardized, scalable, and secure hosting solution. Aurora's goal is to eliminate the fragmentation that arises from each department managing its own platform, ensuring that the Government of Canada operates with consistency in compliance, security, and operational efficiency.

By focusing on a centralized governance model, Aurora will align with the GC Cloud One operating model, promoting a unified approach to onboarding, support, and security. Drawing inspiration from successful initiatives such as the BC Government's DevOps Platform, Statistics Canada's Cloud Native Platform, and Platform One from the United States Department of Defense, Aurora seeks to empower departments with both flexibility and standardization. The platform will provide departments with a comprehensive toolkit and pre-approved software patterns, allowing them to streamline their development pipelines while accelerating innovation.

Aurora will also focus on developing in-house expertise, building teams equipped with the skills and certifications necessary to manage the platform internally, reducing reliance on external vendors. This approach positions Aurora as the long-term solution for application hosting across the Government of Canada, enabling departments to focus on delivering high-quality public services without the overhead of managing fragmented, siloed environments.

## Rationale

As cloud-native technologies become more prevalent within the Government of Canada, the independent deployment of Kubernetes environments by individual departments, whether through managed cloud services or proprietary platforms, has perhaps become untenable if not cost prohibitive. This fragmented approach leads to inefficiencies, inconsistent compliance, and potential security gaps across departments. While some departments have implemented their own Kubernetes platforms, many relying on proprietary solutions often turn to external vendors for support, increasing long-term costs and limiting the growth of in-house expertise necessary for building and maintaining these platforms.

Some of the departments with their own Kubernetes environments (at least in some fashion) include:

- Statistics Canada
- Public Health Agency of Canada
- Canada Revenue Agency
- Employment and Social Development Canada
- Department of National Defence
- Department of Fisheries and Oceans
- And many others...

For over two decades, software organizations have faced the challenge of managing shared infrastructure, code, and tools across multiple teams. Centralized teams were often formed to handle these shared demands, but they frequently encountered issues such as being disconnected from their users' needs, developing overly complex or unstable solutions, or lacking flexibility. On the other hand, decentralizing entirely and giving application teams direct access to cloud tools and open-source software has exposed them to operational complexity, leading to inefficiencies and the need for costly site reliability engineers (SREs) or DevOps specialists.

However, Aurora takes a different approach by focusing on building a platform that leverages the best of both centralized and decentralized models. Aurora ensures that internal engineering talent is developed within the Government of Canada, reducing reliance on external consultants. Teams within Aurora will be skilled in both open-source Kubernetes and proprietary PaaS environments, equipped with certifications such as Certified Kubernetes Administrator (CKA), Certified Kubernetes Security Specialist (CKS), and Certified Kubernetes Application Developer (CKAD). This in-house expertise will ensure robust support across both the platform and application levels, while maintaining stability, scalability, and security.

By establishing commonality and shared standards across departments, Aurora will ensure that a broad set of trained professionals is available to support all departments. This approach not only benefits individual departments by giving them access to skilled architects and employees but also empowers government employees to work across departments, fostering collaboration and flexibility. With consistent training, standards, and expertise, professionals within Aurora can help multiple departments, ensuring that the Government of Canada moves forward together in its modernization efforts.

Aurora succeeds by creating a shared platform that allows application teams to build on a stable, flexible foundation. The platform prioritizes collaboration with its users, ensuring that departments across the government have the tools and support they need to innovate efficiently and securely. This approach fosters efficiency, cost savings, and innovation while reducing operational complexity. By leveraging the existing expertise within departments, Aurora provides a strong foundation for scaling the platform across the Government of Canada.

## Key stakeholders

**Andrew Sinkinson**: Director General of Cloud Operations Hosting Services at Shared Services Canada, responsible for overseeing the strategic alignment of Aurora amongst many other projects with the broader GC Cloud One initiative.

**Serge Leblanc**: Director of Cloud Operations Hosting Services at Shared Services Canada, responsible for managing day-to-day operations across multiple cloud initiatives, including but not limited to the Aurora platform.

## Project vision

The goal of Aurora is to establish itself as a foundational platform for application hosting across the Government of Canada, enabling seamless integration between various cloud-native environments. Drawing inspiration from successful platforms like those in the BC Government, Statistics Canada, and Platform One, Aurora will act as a centralized DevSecOps platform, offering government departments both the tooling and pre-approved software patterns needed to accelerate innovation and streamline development pipelines.

At the core of this initiative is platform engineering, a discipline designed to address the increasing complexity of modern software environments. Platform engineering goes beyond simply assigning a team to solve technical challenges—it requires a comprehensive strategy that integrates product management, software development, and operational excellence, while ensuring a deep understanding of the broader infrastructure. Teams must not only tackle technical issues but also embrace the full product lifecycle, ensuring that solutions are scalable, reliable, and built for long-term operational maturity.

By standardizing tools, infrastructure, and workflows, Aurora simplifies development, reduces cognitive load for developers, and fosters collaboration between departments. This clarity in approach ensures the platform delivers on its promise of agility, reliability, and security across all departments, while also remaining flexible enough to meet each department’s unique needs.

With its secure and compliant foundation—including integrated zero trust security, security as code, and compliance automation—Aurora empowers departments to confidently adopt modern cloud-native tools and deliver scalable, mission-critical applications. Aurora is not only the technical backbone for innovation but is designed to evolve alongside the Government of Canada's ever-changing needs, supporting growth and ensuring long-term operational maturity.

## Primary objectives

1. **Unify both open-source and proprietary environments** across GC departments to eliminate fragmentation while providing flexible, scalable hosting options that adapt to each department's specific needs.
2. **Standardize onboarding processes** in alignment with the GC Cloud One operating model, ensuring seamless integration and accelerated adoption across departments, while enhancing user satisfaction and operational efficiency.
3. **Develop a future-oriented cloud-native architecture** that incorporates on-premise connectivity (SCED), zero trust security, and defense-in-depth models, ensuring long-term sustainability, security compliance, and adaptability.
4. **Build a centralized support structure** with a unified team dedicated to both proprietary and OSS Kubernetes platforms, reinforced by Special Interest Groups (SIGs) in key domains like architecture, networking, and security to drive cross-department collaboration and innovation.

## Strategic constraints

1. **Vendor neutrality** in relation to decisions on cloud providers will remain on hold until Government of Canada-wide procurement is finalized.
2. **Integration of both open-source and proprietary environments** where open-source Kubernetes offerings on managed cloud services and proprietary Kubernetes offerings will be aligned to common standards, ensuring interoperability across platforms. This approach accommodates the diverse requirements of various departments while maintaining seamless integration, compatibility, and operational consistency.
3. **Governance structure** with a robust governance model must be established from the outset, incorporating proven strategies from the BC Government, Canadian Digital Services, and Platform One to shape team organization and foster collaboration.
4. **SCED (Secure Cloud Enablement and Defence) Compliance** where all on-premise and private cloud connections must adhere to SCED requirements to ensure secure access to cloud services.

## Risks and mitigations

One of the key challenges in building and operating a platform like Aurora is balancing flexibility with governance. Below are some of the identified risks along with some proposed mitigations:

### Platform teams without the power to say No

Risk: When platform teams lack the authority to make critical decisions including the ability to say "no" it can lead to increased complexity, scope creep, and inefficiencies. Without this authority, the platform risks becoming overly customized, bloated, or misaligned with its core objectives, slowing down development and increasing the burden on both the platform team and its users.

Mitigation: Platform teams must have the political power to define their ideal users and make decisions on how best to solve their problems. This includes the ability to minimize choice where necessary to streamline the platform, reduce cognitive load, and accelerate development. Empowering these teams to focus on core functionalities will ensure long-term sustainability and efficiency.

### Partner clients needs for centralized control

Risk: Partner clients, such as cyber security or even FinOps teams, require centralized reporting and control to ensure compliance, security, and financial efficiency. A failure to meet these needs could lead to fragmentation, inefficiencies, and a lack of trust in the platform’s governance.

Mitigation: Aurora must provide standardized tools and processes across departments to satisfy the needs for centralized control. By ensuring all teams use the same core platform services, Aurora can streamline reporting, compliance, and security management.

### Lack of operational maturity in platform engineering

Risk: Platform engineering is inherently difficult, and without proper organizational maturity, teams risk building solutions that lack long-term value, sustainability, and operational readiness.

Mitigation: Successful platform engineering requires a shift toward organizational maturity, where teams build with clear intent and align their efforts with real user needs and operational goals. Aurora’s governance structure must enforce these principles ensuring that every technical decision is backed by a clear operational strategy.

## Addressing concerns

As Aurora grows and evolves, questions about its scope, speed, and alignment with other cloud initiatives are natural.

**Why is the platform organization so big when we also have [insert cloud]?**

Aurora’s size reflects its role in providing a standardized, scalable, and secure platform that spans across multiple departments. Aurora integrates multiple cloud-native environments, balancing diverse needs with centralized governance and support for hybrid cloud strategies.

**Why does our platform have all this headcount but still move so slowly?**

Platform engineering is complex and ever evolving field. While initial development may seem slow due to necessary foundational work, the long-term benefits include increased agility, better resource allocation, and reduced cognitive load for developers. By building a stable and standardized platform, Aurora aims to accelerate development in the long run, but this requires investing in operational maturity.

**Why didn’t our recent adoption of [public cloud/SRE/developer experience] solve this?**

Adopting tools and methodologies like public cloud, SRE, or enhancing developer experience can address specific pain points but aren’t silver bullets. Platform engineering goes beyond tools; it’s about organizational alignment, standardization, and creating a secure, flexible, and interoperable environment for all partner clients / departments. Aurora’s focus is on integrating these elements into a cohesive platform that supports innovation while meeting the unique needs of the Government of Canada.

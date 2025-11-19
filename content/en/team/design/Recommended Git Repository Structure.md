# Recommended Git Repository Structure for Application Deployment

Separating an application, its infrastructure, and deployment processes into distinct Git repositories is a common practice in modern DevOps and SRE (Site Reliability Engineering) environments.

## Single Team Ownership vs. Repo Separation

Even without specialized teams, maintaining the three-repository structure remains highlybeneficial. The purpose of the separation is less about team structure and more about process structure and integrity.

1. **Process Clarity and Git History (Visibility):** The separation provides immediate visibility into the type of change made. If a file changes in the Deployment Repo, you know a version promotion occurred. If a file changes in the Infrastructure Repo, you know the underlying cloud environment was modified. This prevents essential configuration changes from being buried inside hundreds of application source code commits.

2. **Enforcing Strict Security and Least Privilege:**
Separation is the cornerstone of security. The Infra Repo holds the "keys to the kingdom"—code that can provision, modify, or destroy
critical cloud assets like production databases and networking. By isolating this code, you enforce the Principle of Least Privilege: application developers only get write access to the App Repo. Onlytrusted, highly-audited CI/CD systems, using temporary and scoped credentials, are allowed totouch the Infra Repo. This physically prevents unauthorized access and drastically reduces the risk of human error or malicious activity affecting the core production environment.

3. **Independent Versioning and Composite Applications:** The
Deployment Repo is essentialbecause most modern applications are composite systems—meaning they comprise severalpieces. Your application may involve multiple microservices, each built from its own App Repo with independent versioning (e.g. service-a:v3.0, service-b:v1.2). Furthermore, thedeployed unit often includes third-party tools (like Kafka, ELK Stack, or ZooKeeper) which haveentirely different release cycles. The
Deployment Repo acts as the only place to centrally storethe manifests that define this entire deployed state, making it illogical to store them within thesource code repository of just one of the many components. This structure allows eachcomponent's lifecycle to move independently while ensuring the final, running system is cohesiveand auditable.

## Repository Types

### 1. Application Repository (app-repo)
This is the heart of the application.

- **Content:** All the source code, libraries, configuration files (e.g. environment variables, settings), and unit tests for the application itself.

- **Purpose:** To build the deliverable artifact (e.g., a Docker image, JAR file, or executable).

- **Typical Users:** Application Developers.

- **Key Action:** Merging a pull request (PR) to the main branch usually triggers a Continuous Integration (CI) pipeline to build, test, and tag the application artifact.

### Helm Chart Placement

While the Deployment Repository (Repo 3) holds the final configuration, the
base Helm Chart (the reusable template of Kubernetes manifests) should reside in the App Repository. This ensures cohesion: any time a developer changes an application dependency (like adding a port or anenvironment variable), they are required to update the necessary deployment template in the same pull request. This hybrid approach keeps the chart's structure tightly coupled and versioned with the source code.

For Composite Applications: The Deployment Repository (Repo 3) is the only logical place for the master or "umbrella" Helm chart. This umbrella chart doesn't contain application code, but ratheracts as a manifest orchestrator, listing and consuming the specific versioned charts from multiplecomponent App Repositories and applying the final, environment-specific values (like resource limits orproduction secrets) that define the entire composite system's state.

### 2. Infrastructure Repository (infra-repo)

This repository defines the environment the application will run in. This concept is often called Infrastructure as Code (IaC).

- **Content:** Configuration files for provisioning long-lived, supporting cloud resources that the application depends on. This primarily includes managed services (databases, message queues, storage buckets, firewalls, and networking components) and, optionally, core compute environments (Virtual Machines or Kubernetes clusters). IaC tools like Terraform or Pulumi are often used.

- **Purpose:** To define, provision, and manage the long-lived, supporting infrastructure dependencies in a repeatable and documented way, ensuring the application has the necessary resources (like provisioned databases or queues) before deployment.

- **Key Action:** Changes here are applied via Continuous Delivery (CD) to update the cloud environment before the application is deployed into it. This keeps the environment configuration version-controlled.

### 3. Deployment Repository (deploy-repo)

This repository serves as the source of truth for what version of the application should be running where. This is the core principle of GitOps.

- **Content:** Declarative manifests that describe the desired state of the application on the cluster/environment.
  - **Kubernetes Example:** Contains the desired Kubernetes manifests (ex: Deployment, Service, and Ingress manifests).
  - **Crucial Part:** This config references the specific version/tag of the artifact built by the Application Repo (e.g., image: my-app:v2.1.0).

 - **Purpose:** To decouple the application code from the deployment instructions and enable continuous, automated reconciliation of the environment state.

 - **Key Action:** The ultimate function of this repository is to serve as the desired state reference for a GitOps controller (like Argo CD), which continuously performs reconciliation. The workflow is generally the following:
    - The CI pipeline from the Application Repo successfully builds a new image (e.g., v2.1.0).
    - A PR in the Deployment Repo is created to update the application manifest, changing the image tag.
    - Once this change is merged, the GitOps controller running in the cluster detects the change and automatically updates the running application to align the actual state with the desired state defined in Git.

## Summary Table

| Repository     | Focus                                                   | Primary Tools                                          | Recommended Deployment Trigger |
|----------------|---------------------------------------------------------|--------------------------------------------------------|---------------------------------------------|
| Application    | What is built                                           | Build Tools (e.g., Maven, npm, Go Build), Docker, Helm | New artifact build (CI)                     |
| Infrastructure | Application dependencies (supporting services)          | Terraform, Cloudformation                              | Resource provisioning/update (CD)           |
| Deployment     | Final Runtime State (Image & Environment Configuration) | K8s YAML, Helm, GitOps                                 | Desired State Reconciliation (GitOps)       |


## Example Workflow

In the following example a dedicated caching layer is added to improve performance. This requires changes to all three repositories.

| Step                    | Repository Updated  | Action                                                                                                                                                                                                                                                  |
|-------------------------|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1. Infra Change         | Infrastructure Repo | The developer updates the Terraform files to provision a new managed AWS ElastiCache Redis cluster within the VPC. This is a new piece of infrastructure. Rationale: The application needs a dedicated, highly available cache resource.                |
| 2. Infra CI/CD Pipeline | N/A                 | The IaC pipeline runs, provisions the new Redis cluster, and stores its connection endpoint and port in Hashicorp Vault                                                                                                                                 |
| 3. App Change           | Application Repo    | The developer updates the code to check the Redis cache first before hitting the main database. It is configured to read the Redis endpoint from an environment variable.                                                                               |
| 4. Helm Chart Change    | Application Repo    | The developer updates the Helm chart to pull the Redis connection endpoint from Hashicorp Vault and inject it as an environment variable (REDIS_ENDPOINT) into the application container. The default image version is also updated                     |
| 4. App CI Pipeline      | N/A                 | The CI pipeline runs tests, builds the new Docker image (ex: shopping-cart:v1.4.0), and pushes it to the registry. Additionally, the CI pipeline notices there is a Helm chart change, and it publishes it to a Helm chart registry.                    |
| 5. Deployment Change    | Deployment Repo     | Update the Argo CD application to use the latest Helm chart version                                                                                                                                                                                     |
| 6. Deployment           | N/A                 | The controller detects the changes in the Deployment Repo, applies the new manifests. The Kubernetes manifest changes get reflected in their workload namespace (pods use the new v1.4.0 image to connect to the newly provisioned Redis cluster, etc). |
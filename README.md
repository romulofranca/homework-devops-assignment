# Senior DevOps Engineer Homework

This repository demonstrates an end-to-end DevOps solution for deploying a minimal Rails API application. The application always responds with **"Hello World v2.1"** and is containerized using Docker, orchestrated on Kubernetes via Helm, and provisioned using Terraform. A Makefile streamlines the entire lifecycle—from building and deploying to testing and tearing down the infrastructure.

---

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Prerequisites](#prerequisites)
- [How to Run](#how-to-run)
  - [Build and Deploy](#build-and-deploy)
  - [Testing](#testing)
  - [Cleanup](#cleanup)
- [Best Practices & Advanced Considerations](#best-practices--advanced-considerations)
- [Q&A](#qa)

---

## Overview

This solution leverages industry-standard tools to demonstrate robust, reproducible deployments:

- **Containerization:**  
  The application is containerized with Docker using a multi-stage Dockerfile, ensuring a production-ready image.

- **Orchestration:**  
  Kubernetes manifests are packaged as a Helm chart to define a scalable deployment with a Service (exposed as NodePort) and a 2-replica Deployment.

- **Infrastructure as Code:**  
  Terraform is used to deploy the Helm chart, emphasizing reproducibility and versioned infrastructure.

- **Automation:**  
  A Makefile abstracts common tasks (build, deploy, test, and destroy), enabling streamlined CI/CD pipelines.

---

## Directory Structure

```plaintext
.
├── hello-app/              # Rails API application source code
├── Dockerfile              # Multi-stage Docker build configuration
├── helm/                   # Helm chart for Kubernetes deployment
├── terraform/              # Terraform configuration to deploy the Helm chart
└── Makefile                # Automation for build, deploy, test, and destroy tasks
```

This structure separates concerns and encourages modularity, allowing each component to be updated independently.

---

## Prerequisites

Ensure the following tools are installed and properly configured:

- **Docker Desktop** (with Kubernetes enabled)

Here's a friendlier version of the disclaimer:

---

> **Heads Up!**  
> For this project, I've set it up to run on Docker Desktop's Kubernetes, which makes things run smoothly. If you decide to give Minikube a try, please note that:
>
> - You'll need to copy your Docker image into Minikube using:
>   ```bash
>   minikube image load <your-image-name>
>   ```
>
> - And to properly expose your service, use:
>   ```bash
>   minikube service <service-name>
>   ```
>
> These extra steps help ensure everything works as expected :)

---

- **Terraform** (v1.0 or later) – [Download Terraform](https://www.terraform.io/downloads.html)
- **Helm** – [Install Helm](https://helm.sh/docs/intro/install/)
- **kubectl** – [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **make** – (Typically pre-installed on Linux/macOS; Windows users may use WSL or Git Bash)

---

## How to Run

The project utilizes a Makefile to encapsulate commands for common workflows. Below are the available commands:

### Build and Deploy

#### Separately

- **Build the Docker Image:**  
  Run:
  ```bash
  make build
  ```
  *Expected Output:*  
  🚀 Building Docker image...

- **Deploy the Application:**  
  Use Terraform to provision the infrastructure:
  ```bash
  make deploy
  ```
  *Expected Output:*  
  📦 Deploying application with Terraform...  
  ⏳ Waiting for the service to become ready...  
  🚀 Your application is available at: [http://localhost:31234](http://localhost:31234)

#### Together

- **Build and Deploy in One Step:**  
  Execute:
  ```bash
  make build-deploy
  ```
  *Expected Output:*  
  🔧 Build and deploy steps completed.

### Testing

- **Run Docker & Rails App Tests:**  
  Execute:
  ```bash
  make test-docker
  ```
  *Expected Output:*  
  🐳 Running Docker & Rails app tests...

- **Run Terraform Tests:**  
  Validate your Terraform configurations:
  ```bash
  make test-terraform
  ```
  *Expected Output:*  
  🛠️ Running Terraform tests...

- **Run Helm Lint:**  
  Lint the Helm chart:
  ```bash
  make test-helm
  ```
  *Expected Output:*  
  🧰 Running Helm lint...

- **Run All Tests:**  
  Execute all tests sequentially and display a summary:
  ```bash
  make test-all
  ```
  *Expected Output Example:*
  ```plaintext
  🏁 Running all tests...
  -----------------------------------
  Test            Status
  ---------------- ---------------
  Docker          ✅ Passed
  Terraform       ❌ Failed
  Helm            ✅ Passed
  -----------------------------------
  🛠️ Terraform logs:
  ... (detailed logs) ...
  ```

### Cleanup

- **Destroy the Deployment:**  
  Tear down the deployed infrastructure with:
  ```bash
  make destroy
  ```
  *Expected Output:*  
  🗑️ Destroying application with Terraform...

---

**Best Practices & Advanced Considerations**

- **Environment Segregation:**  
  One possible and best improvement is to maintain separate configurations for development, staging, and production. This approach helps isolate environments and prevents cross-environment interference.

- **State Management:**  
  We can enhance our collaboration and consistency by using remote state storage (e.g., S3 with DynamoDB for locking) for Terraform. This is a recommended practice to manage state reliably across teams.

- **Security:**  
  A strong improvement is to integrate secret management tools (such as HashiCorp Vault or AWS Secrets Manager) to securely manage credentials and sensitive data. Additionally, using temporary AWS credentials with assume-role configurations further boosts security by minimizing risks associated with static credentials.

- **Observability:**  
  We can improve our monitoring by integrating logging and monitoring tools (e.g., Datadog or Prometheus and Grafana). This enhancement provides continuous insight into both the application and the infrastructure, allowing for proactive issue detection.

- **Automation & CI/CD:**  
  Incorporating these Makefile commands into our CI/CD pipelines is another best improvement. Automating testing, deployment, and rollbacks can significantly streamline our workflow and ensure consistent delivery.

---

## Q&A

### Managing Terraform State Across Environments

**Question:** *How would you manage your Terraform state file for multiple environments?*

**Answer:**  
I manage Terraform state files by using an S3 backend with environment-specific key prefixes (e.g., `terraform/state/stage/`, `terraform/state/prod/`, `terraform/state/demo/`). A DynamoDB table is employed for state locking to prevent concurrent modifications. This approach supports versioning and ensures state consistency across environments.

### Managing Terraform Variables and Secrets

**Question:** *How would you approach managing Terraform variables and secrets?*

**Answer:**  
I follow these practices:
- **Environment-Specific Variables:** Use separate variable files (e.g., `stage.tfvars`, `prod.tfvars`, `demo.tfvars`) to clearly separate configurations.
- **Modular Code:** Structure Terraform code into reusable modules with environment-specific variable injection.
- **Sensitive Data Management:** Integrate secret management tools (e.g., HashiCorp Vault or AWS Secrets Manager) to retrieve secrets dynamically at runtime.
- **AWS Credentials via Assume Role:** Configure Terraform to assume an IAM role for temporary credentials rather than using static keys, enhancing overall security.


### Monitoring Strategy

**Question:** *How would you approach managing Terraform variables and secrets?*

Monitoring is key to ensuring high availability and performance. Below are the recommended components and metrics:

1. **Application-Level Monitoring:**
   - **Response Time & Latency:** Track how quickly the application responds to requests.
   - **Error Rates:** Monitor HTTP status codes (4xx, 5xx) to identify potential issues.
   - **Throughput:** Record the number of requests per second.
   - **Uptime:** Use health checks (liveness/readiness probes) to ensure continuous availability.

2. **Container and Pod Monitoring:**
   - **Resource Utilization:** Monitor CPU and memory usage for each container and pod.
   - **Restart Counts:** Track pod restarts as an indicator of instability.
   - **Network I/O:** Measure ingress and egress traffic.

3. **Kubernetes Cluster Monitoring:**
   - **Node Health:** Monitor CPU, memory, and disk usage at the node level.
   - **Pod Scheduling & Status:** Keep tabs on the number of running, pending, or failed pods.
   - **Cluster Events:** Aggregate events (rollouts, scaling, errors) for a comprehensive view of cluster health.

4. **Infrastructure & Deployment Monitoring:**
   - **Deployment Logs:** Continuously monitor logs generated during Terraform and Helm deployments.
   - **Alerting:** Configure alerting systems to notify teams when key metrics (e.g., error rates, resource saturation) breach thresholds.

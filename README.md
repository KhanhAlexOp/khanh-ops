# khanh-ops

This project demonstrates how to provision a minimal, secure, and scalable Amazon EKS (Elastic Kubernetes Service) cluster using Terraform and manage in-cluster resources declaratively with Kubernetes YAML manifests.

---

## Problem Statement

- **Create the EKS cluster with minimal resource capacity**
- **Create in-cluster resources by the Declarative method**
- **Create YAML files for all resources**
- **Create a Horizontal Pod Autoscaler to apply scale**
- **Ensure security both at rest and in transit**
- **Ensure healthcheck settings**

---

## Why This Approach?

- **Cost Efficiency:** Using free-tier eligible resources (e.g., `t3.micro` nodes) keeps costs low and is ideal for learning or small workloads.
- **Declarative Infrastructure:** All infrastructure and Kubernetes resources are defined as code, enabling reproducibility, version control, and automation.
- **Scalability:** Horizontal Pod Autoscaler (HPA) ensures your application can scale based on demand.
- **Security:** Secrets are encrypted at rest with AWS KMS, and network policies restrict pod communication. All traffic is encrypted in transit by default in EKS.
- **Reliability:** Health checks (liveness/readiness probes) ensure only healthy pods serve traffic and are automatically restarted if needed.

---

## Project Structure

```
.
├── aws_config/                # AWS credentials and config (not committed)
│   ├── access_key_id
│   ├── secret_access_key
│   ├── region
│   └── config
├── k8s-manifests/             # Kubernetes YAML manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── hpa.yaml
│   ├── network-policy.yaml
│   └── encryption-config.yaml
├── terraform/                 # Terraform IaC for AWS EKS
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── versions.tf
│   └── terraform.tfvars
├── run.sh                     # Automation script
└── README.md                  # This file
```

---

## Step-by-Step Explanation

### 1. AWS Credentials Setup

- Place your AWS credentials in the `aws_config/` directory:
  - `access_key_id`, `secret_access_key`, and `region` files should contain your AWS access key, secret key, and region (e.g., `ap-southeast-1`).
- These are loaded by `run.sh` to authenticate Terraform and AWS CLI commands.

### 2. Infrastructure Provisioning with Terraform

- The `terraform/` directory contains all code to provision:
  - A minimal VPC, public subnets, internet gateway, and route table.
  - IAM roles and policies for EKS control plane and worker nodes.
  - An EKS cluster with secrets encryption enabled (using AWS KMS).
  - A managed node group with `t3.micro` instances (free-tier eligible).
- **Security:** Node IAM roles include all required policies (`AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryReadOnly`, `AmazonEKS_CNI_Policy`).
- **Encryption:** KMS key is created and used for Kubernetes secrets encryption.

### 3. Kubernetes Provider Configuration

- The `provider.tf` configures the Kubernetes provider to connect to the EKS cluster after it is created, enabling Terraform to manage Kubernetes resources if desired.

### 4. Declarative Kubernetes Resources

- All Kubernetes resources are defined as YAML files in `k8s-manifests/`:
  - **deployment.yaml:** NGINX deployment with liveness and readiness probes for health checks.
  - **service.yaml:** Exposes NGINX via a LoadBalancer service.
  - **hpa.yaml:** Horizontal Pod Autoscaler to scale NGINX pods based on CPU usage.
  - **network-policy.yaml:** Restricts pod communication for security.
  - **encryption-config.yaml:** Example for enabling secret encryption (handled by EKS in this setup).

### 5. Automation Script

- `run.sh` automates the entire process:
  1. Exports AWS credentials from `aws_config/`.
  2. Runs `terraform init`, `plan`, and `apply` to provision infrastructure.
  3. Updates your kubeconfig to connect `kubectl` to the new EKS cluster.
  4. Applies all Kubernetes manifests to deploy and configure your application.

---

## How to Use

1. **Configure AWS credentials:**
   - Place your AWS access key, secret key, and region in the `aws_config/` directory as described above.

2. **Run the automation script:**
   ```sh
   ./run.sh
   ```

3. **Verify the deployment:**
   ```sh
   kubectl get nodes
   kubectl get pods
   kubectl get svc
   kubectl get hpa
   kubectl get networkpolicy
   ```

---

## Security and Reliability Features

- **At Rest:** Kubernetes secrets are encrypted using AWS KMS.
- **In Transit:** All EKS API and node communication is encrypted via TLS.
- **Network Policy:** Restricts pod-to-pod communication.
- **Health Checks:** Liveness and readiness probes ensure only healthy pods serve traffic.
- **Autoscaling:** HPA automatically scales pods based on CPU usage.

---

## Cleanup

To destroy all resources and avoid ongoing charges:

```sh
cd terraform
terraform destroy
```

---

## Summary

This project provides a secure, scalable, and cost-effective foundation for running containerized workloads on AWS EKS, following best practices for automation, security, and reliability. All infrastructure and application resources are managed as code for maximum reproducibility and transparency.
# khanh-ops: AWS RDS PostgreSQL (Free Tier) with Secrets Manager

This project demonstrates how to provision a minimal, secure PostgreSQL database using **Amazon RDS** (free-tier eligible, `t3.micro`, no HA, no read-replica) with **credentials stored in AWS Secrets Manager**. All infrastructure is managed as code using Terraform.

---

## Problem Statement

- **Provision a PostgreSQL database on AWS RDS using free-tier resources**
- **Store sensitive credentials securely in AWS Secrets Manager**
- **No high availability or read-replica setup**
- **Ensure security and health best practices**

---

## Project Structure

```
.
├── aws_config/                # AWS credentials and config (not committed)
│   ├── access_key_id
│   ├── secret_access_key
│   ├── region
│   └── config
├── terraform/                 # Terraform IaC for AWS RDS
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

## Step-by-Step Procedure

### 1. Prepare AWS Credentials

- Place your AWS credentials in the `aws_config/` directory:
  - `access_key_id`, `secret_access_key`, and `region` files should contain your AWS access key, secret key, and region (e.g., `ap-southeast-1`).
- These are loaded by `run.sh` to authenticate Terraform and AWS CLI commands.

---

### 2. Review and Configure Terraform Code

**Key resources in [`terraform/main.tf`](terraform/main.tf):**
- **VPC, Subnets, and Internet Gateway:** Minimal networking for RDS.
- **Security Group:** Allows PostgreSQL traffic (port 5432).  
  _**Note:** For demo, ingress is open to all. Restrict in production!_
- **Random Password:** Generates a secure password, avoiding forbidden RDS characters.
- **Secrets Manager:** Stores the DB username and password securely.
- **RDS Instance:**  
  - Engine: `postgres`
  - Version: Use a supported version (e.g., `15.11`)
  - Instance class: `db.t3.micro` (free-tier eligible)
  - No multi-AZ, no read-replica, no backup retention

**Example snippet for password generation:**
```hcl
resource "random_password" "db" {
  length  = 16
  special = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~" # Excludes / @ " and space
}
```

---

### 3. Run the Automation Script

From the project root, execute:

```sh
./run.sh
```

This script will:
- Export AWS credentials from `aws_config/`
- Initialize and apply Terraform to provision all resources

---

### 4. Retrieve Database Connection Details

After successful deployment, Terraform will output:
- The **RDS endpoint** (host:port)
- The **Secrets Manager ARN** for credentials

To view the credentials:
```sh
aws secretsmanager get-secret-value --secret-id <rds_secret_arn>
```
Replace `<rds_secret_arn>` with the output value.

---

### 5. Health and Security

- **RDS provides built-in instance health monitoring.**
- **Credentials are never hardcoded**—they are generated and stored securely in Secrets Manager.
- **Security group** restricts access to PostgreSQL port (adjust as needed for your environment).

---

### 6. Cleanup

To destroy all resources and avoid ongoing charges:

```sh
cd terraform
terraform destroy
```

---

## Summary

This project provides a secure, cost-effective, and automated way to deploy a PostgreSQL database on AWS RDS using free-tier resources, with all sensitive data managed in AWS Secrets Manager. All infrastructure is managed as code for maximum reproducibility and transparency.
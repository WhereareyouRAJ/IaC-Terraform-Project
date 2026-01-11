# Secure Infrastructure as Code with Terraform & DevSecOps CI/CD

## Project Introduction

This project showcases a **production-grade AWS infrastructure** built using **Terraform**, following **industry-standard Infrastructure as Code (IaC) and DevSecOps practices**.

The goal was to design infrastructure that is **secure, cost-aware, automated, and audit-ready**, rather than just provisioning cloud resources.

---

## Project Description

The infrastructure is managed entirely through **modular Terraform code**, deployed via a **secure CI/CD pipeline** that validates security, compliance, and cost **before** any change reaches AWS.

### Core Principles Followed

- **Security by Default** – Encryption, IMDSv2, least-privilege IAM, secure networking  
- **Shift-Left DevSecOps** – Automated security scans using Checkov, tfsec, Semgrep, and Gitleaks  
- **Cost Governance** – Cost estimation and comparison using Infracost on every pull request  
- **Modular & Reusable Design** – Separate Terraform modules for VPC, EC2, EKS, IAM, and KMS  
- **Audit Readiness** – Centralized logging, tagging standards, and traceability  

---

## Project Highlights

- 🔐 Secure, policy-driven infrastructure
- 💰 Pre-deployment cost visibility
- 🚀 Automated Terraform CI/CD pipeline
- 🏗 Reusable and scalable Terraform modules
- 📊 Real-world DevOps workflow implementation


## 🧩 VPC & Networking Module

The VPC module forms the **networking backbone** of the entire infrastructure and is designed to securely host Kubernetes (EKS) workloads.

---

### 📝 Service Description
The VPC module provisions a **secure, observable, and scalable networking layer** on AWS.  
Special care has been taken to ensure the module aligns with **enterprise security, governance, and compliance standards**.

Key highlights:
- Fully modular Terraform design
- Mandatory tagging enforced for governance
- Encrypted observability using AWS KMS
- Multi-AZ and private subnet architecture
- Compatible with Checkov and Infracost

---

### 🏗️ Architecture Overview

The following AWS services are created as part of this module:

- **AWS VPC**
- **Private Subnets** (Multi-AZ)
- **Internet Gateway**
- **Route Table & Associations**
- **VPC Flow Logs**
- **CloudWatch Log Group**
- **AWS KMS (Customer Managed Key)**
- **IAM Role & Policy for Flow Logs**
- **Hardened Default Security Group**

---

### 🌐 Network Design Decisions

- **CIDR Planning**
  - VPC CIDR: `10.0.0.0/16`
  - Subnets:
    - `10.0.1.0/24` (ap-south-1a)
    - `10.0.2.0/24` (ap-south-1b)

- **High Availability**
  - Subnets distributed across multiple Availability Zones
  - Improves resilience and fault tolerance

- **Private Subnet Strategy**
  - `map_public_ip_on_launch = false`
  - Prevents direct internet exposure of workloads

---

### 🔐 Security Best Practices

- **Default Security Group Hardening**
  - Ingress allowed only from self
  - Eliminates unintended external access

- **Encrypted Logging**
  - VPC Flow Logs stored in CloudWatch
  - Logs encrypted using a customer-managed KMS key
  - Automatic key rotation enabled

- **Least Privilege IAM**
  - Dedicated IAM role for VPC Flow Logs
  - Restricted permissions for CloudWatch logging only

---

### 👁️ Observability & Monitoring

- **VPC Flow Logs**
  - Captures ALL network traffic (ACCEPT and REJECT)
  - Enables traffic analysis, troubleshooting, and audits

- **Log Retention**
  - CloudWatch log retention set to 365 days
  - Supports compliance and forensic analysis

---

### 🏷️ Tagging & Governance

All resources follow a **mandatory tagging policy**:

- `Environment = Dev`
- `Service = <resource-name>`
- `Name = <logical-resource-name>`

This ensures:
- Successful Checkov compliance
- Accurate Infracost cost estimation
- Easy resource tracking and ownership

---

### 💡 Why This Design Matters

- Provides a secure base for Kubernetes (EKS)
- Improves visibility with encrypted network logs
- Designed to pass security and policy scans
- Scales easily for future NAT, EKS, and private services

---

### ✅ Compliance & Validation

- ✔ Checkov: Passed
- ✔ Security best practices enforced
- ✔ Infracost compatible
- ✔ Enterprise tagging standards followed



## 🖥️ EC2 Compute & Application Server Module

### 📌 Service Overview
This module provisions **secure, optimized, and cost-aware EC2 instances** to host application workloads such as **SonarQube and supporting backend services**.

The design follows **industry-grade security hardening, cost optimization, and observability standards**, validated using **Checkov and Infracost**.

---

### 📝 Service Description
The EC2 module is built using a **reusable Terraform module**, allowing multiple instances to be launched with consistent security, storage, and monitoring configurations.

Key workloads deployed using this module:
- **SonarQube Server**
- **Application / Utility Server**

Each instance adheres to AWS best practices for:
- Instance metadata security
- Encrypted storage
- Monitoring & governance
- Cost-efficient ARM-based compute

---

### 🏗️ Architecture & Components

The following AWS components are created:

- **AWS EC2 Instances**
- **Custom Security Group**
- **Encrypted GP3 EBS Root Volumes**
- **IAM Instance Profile**
- **Ubuntu ARM64 Minimal AMI**
- **VPC-based private networking**

---

### ⚙️ Compute Configuration

- **Instance Types**
  - `t3g.large` → SonarQube workload
  - `t2g.medium` → Application server
- **ARM-based Graviton instances**
  - Better price-to-performance ratio
  - Lower operational cost (validated via Infracost)

- **EBS Optimization**
  - `ebs_optimized = true`
  - Improves disk throughput and latency

---

### 💾 Storage Design (EBS)

- **Root Volume**
  - Type: `gp3`
  - Encrypted: ✅
  - Size:
    - Sonar server: 30 GB
    - App server: 20 GB

- **Why GP3**
  - Predictable performance
  - Lower cost than gp2
  - Explicit Checkov compliance

---

### 🔐 Security Best Practices

#### 🔒 Instance Hardening
- **IMDSv2 enforced**
  - `http_tokens = required`
  - Prevents SSRF-based credential theft

- **No Public IP**
  - `associate_public_ip_address = false`
  - Instances accessible only via controlled network paths

#### 🔑 IAM & Access Control
- Instance attached to an **IAM Instance Profile**
- Prevents hardcoding AWS credentials

---

### 🛡️ Network Security (Security Group)

- **Restricted Ingress**
  - SSH (22)
  - HTTP (80), HTTPS (443)
  - SMTP (25, 465, 587)
  - MongoDB (27017)
  - Kubernetes / custom ports (6443, 3000–10000)
- **CIDR-based access**
  - Locked to a specific trusted IP

- **Controlled Egress**
  - Explicit outbound rules defined
  - Improves auditability and policy compliance

---

### 👁️ Monitoring & Visibility

- **Detailed EC2 Monitoring Enabled**
  - `monitoring = true`
  - Enables CloudWatch enhanced metrics

- **Supports future integrations**
  - Centralized logging
  - Infra health dashboards
  - Alerting pipelines

---

### 🏷️ Tagging & Governance

Every resource is tagged with mandatory fields:

- `Environment = Dev`
- `Service = EC2 / ebs / application-server`
- `Name = logical-instance-name`

This ensures:
- Checkov mandatory tag checks pass
- Accurate Infracost allocation
- Easy cost and ownership tracking

---

### 💰 Cost Optimization Insights (Infracost)

- Migration to **Graviton (t2g / t3g)** instances
- Switch from gp2 → gp3 volumes
- Resulted in **significant cost reduction**
- Demonstrates data-driven infrastructure decisions

---

### ✅ Compliance & Validation

- ✔ Checkov: Passed (IMDSv2, encryption, tagging)
- ✔ Infracost: Optimized & verified
- ✔ AWS Well-Architected aligned
- ✔ Modular & reusable Terraform design

---

### 💡 Why This Matters

This EC2 module demonstrates:
- Production-grade security hardening
- Real-world cost optimization decisions
- Enterprise-level governance readiness
- A strong foundation for CI/CD, monitoring, and Kubernetes tooling



## ☸️ Amazon EKS (Kubernetes) Module

### 📌 Service Overview
This module provisions a **production-grade Amazon EKS cluster** designed for **secure, private, encrypted, and cost-optimized Kubernetes workloads**, with **ArgoCD-ready architecture**.

The EKS setup strictly follows **AWS Well-Architected Framework**, **security-first design**, and **compliance-driven infrastructure practices**, validated using **Checkov and Infracost**.

---

### 📝 Service Description
The EKS infrastructure is implemented using a **fully modular Terraform design**, enabling scalable and repeatable Kubernetes cluster creation across environments.

Key design goals:
- Private-by-default cluster access
- Strong encryption for Kubernetes secrets
- Secure node group provisioning
- Cost-efficient ARM-based worker nodes
- Full audit and control plane logging

---

### 🏗️ Architecture & Core Components

The following AWS services are provisioned:

- **Amazon EKS Cluster (v1.32)**
- **Private Kubernetes Control Plane**
- **Managed Node Group**
- **Custom Launch Template**
- **IAM Roles & Policies**
- **KMS for Secrets Encryption**
- **Dedicated Security Groups**
- **VPC-integrated networking**

---

### 🔐 Cluster Security Design

#### 🛡️ Control Plane Access
- **Authentication Mode:** API-based
- **Public Endpoint:** ❌ Disabled
- **Private VPC Access:** ✅ Enabled
- Prevents unauthorized public access to Kubernetes API

#### 🔒 Secrets Encryption
- Kubernetes secrets encrypted using **AWS KMS**
- Dedicated CMK with:
  - Key rotation enabled
  - Scoped IAM access
  - Least-privilege permissions
- Meets enterprise compliance standards (SOC, ISO-style controls)

---

### 🔑 IAM & Identity Management

#### Cluster IAM Role
- Attached **AmazonEKSClusterPolicy**
- Trusted only by `eks.amazonaws.com`
- Used exclusively for control plane operations

#### Node Group IAM Role
- Attached policies:
  - AmazonEKSWorkerNodePolicy
  - AmazonEKS_CNI_Policy
  - AmazonEC2ContainerRegistryReadOnly
- Enables:
  - Pod networking
  - Image pulls from ECR
  - Worker node lifecycle operations

---

### ⚙️ Node Group & Compute Strategy

- **Instance Type:** `t2g.medium` (AWS Graviton ARM)
- **Autoscaling Configuration**
  - Min: 1
  - Desired: 1
  - Max: 2
- **Rolling Updates**
  - `max_unavailable = 1`
  - Ensures zero-downtime updates

#### 💰 Cost Optimization
- ARM-based Graviton instances reduce compute cost
- Verified using **Infracost** estimates
- Demonstrates cost-aware Kubernetes design

---

### 💾 Launch Template & Storage Design

- **Custom Launch Template**
  - Ensures consistent node configuration
- **Root Volume**
  - Type: `gp3`
  - Size: 30 GB
  - Encrypted: ✅
  - Optimized IOPS & throughput

#### 🔐 Metadata Security
- **IMDSv2 enforced**
  - `http_tokens = required`
  - Prevents credential exposure via SSRF attacks

---

### 🛡️ Network Security (Security Groups)

#### Cluster Security Group
- Restricted outbound access
- No open inbound rules
- Tight control over control-plane traffic

#### Node Security Group
- Controlled SSH access
- Restricted CIDR-based ingress & egress
- Prevents lateral movement and exposure

---

### 📊 Observability & Logging

- **Control Plane Logs Enabled**
  - API
  - Audit
  - Authenticator
  - Scheduler
  - Controller Manager
- Enables:
  - Security auditing
  - Operational troubleshooting
  - Governance and compliance visibility

---

### 🏷️ Tagging & Governance

All EKS-related resources include mandatory tags:

- `Environment = Dev`
- `Service = EKS / EKS-nodes`
- `Name = logical-resource-name`

This ensures:
- Checkov mandatory tagging compliance
- Accurate cost allocation in Infracost
- Clean ownership and environment separation

---

### ✅ Compliance & Validation

- ✔ Private EKS API endpoint
- ✔ Secrets encryption using KMS
- ✔ IMDSv2 enforced on worker nodes
- ✔ Encrypted GP3 storage
- ✔ Mandatory tagging implemented
- ✔ Checkov security checks passed
- ✔ Infracost cost optimizations validated

---

### 💡 Why This EKS Design Matters

This EKS module demonstrates:
- Real-world Kubernetes security hardening
- Enterprise-ready encryption practices
- Cost-efficient cluster design
- CI/CD and GitOps (ArgoCD) readiness
- Strong foundation for production workloads

This is not a demo EKS setup — it is **production-aligned infrastructure**.



## CI/CD Pipeline – Infrastructure Automation & Governance

This project follows a **production-grade CI/CD pipeline** designed specifically for **Infrastructure as Code (IaC)**.  
The pipeline enforces **security, quality, compliance, and cost controls** before any infrastructure change is merged or deployed.

The CI/CD workflow is triggered on:
- **Pull Requests** (dev, staging, main)
- **Push events** to protected branches

This ensures **shift-left security**, early feedback, and predictable infrastructure changes.

---

## Pipeline Overview

The CI/CD pipeline is divided into the following logical stages:

1. **Secrets Detection**
2. **Static Code Analysis**
3. **Terraform Validation**
4. **Infrastructure Security Scanning**
5. **Terraform Plan (Dry Run)**
6. **Cost Estimation & Cost Diff (Infracost)**

Each stage acts as a **gate**, preventing insecure or costly changes from reaching production.

---

## Stage 1: Gitleaks – Secrets Detection

**Tool Used:** Gitleaks  
**Trigger:** Every push & pull request

### Purpose
To detect **hardcoded secrets** such as:
- AWS keys
- Tokens
- Passwords
- API keys

before they enter the repository.

### What Happens
- Entire repository is scanned as a filesystem
- Secrets are redacted in logs
- Pipeline does not fail hard (visibility-first approach)

### Why This Matters
Secrets leaked into Git history are **one of the most common cloud security incidents**.

---

## Stage 2: Semgrep – Static Code Analysis

**Tool Used:** Semgrep  
**Dependency:** Runs after Gitleaks

### Purpose
To detect:
- Bad coding patterns
- Insecure Terraform constructs
- Misconfigurations at code level

### What Happens
- Source code is analyzed using predefined security rules
- Helps catch issues **before Terraform even runs**

### Why This Matters
This stage adds an **application-security mindset** to infrastructure code.

---

## Stage 3: Terraform Init, Format & Validate

**Tool Used:** Terraform CLI  
**Terraform Version:** 1.6.6

### Purpose
To ensure Terraform code is:
- Properly initialized
- Formatted according to standards
- Structurally valid

### Steps Performed
- `terraform init`
- `terraform fmt`
- `terraform validate`

### Why This Matters
Prevents:
- Broken state
- Invalid resource definitions
- Formatting drift across teams

---

## Stage 4: Checkov – Infrastructure Security & Compliance

**Tool Used:** Checkov  
**Output:** CLI + SARIF  
**Integration:** GitHub Security Tab

### Purpose
To enforce **cloud security best practices** such as:
- Encryption at rest
- IMDSv2 enforcement
- Secure security groups
- Mandatory tagging
- Least privilege IAM

### Findings & Fixes
Several **high and medium severity issues** were detected, including:
- Missing mandatory tags (`Environment`, `Service`)
- Unencrypted EBS volumes
- Missing metadata options
- Open security group rules

All issues were **systematically fixed** by updating Terraform modules.

> 📸 Evidence 

![alt text](<Screenshot 2026-01-04 105415.png>)


---

## Stage 5: tfsec – Additional Terraform Security Layer

**Tool Used:** tfsec  
**Dependency:** Runs after Checkov

### Purpose
To provide an **additional security lens**, focusing on:
- Cloud misconfigurations
- Known insecure Terraform patterns

### Behavior
- Soft-fail enabled (visibility over blocking)
- Helps validate Checkov findings independently

### Why This Matters
Multiple scanners reduce **false negatives** and increase confidence.

> 📸 Evidence  
> ![alt text](<Screenshot 2026-01-05 091541.png>)

---

## Stage 6: Terraform Plan – Safe Dry Run

**Tool Used:** Terraform  
**Cloud Provider:** AWS

### Purpose
To generate a **safe execution plan** without applying changes.

### What Happens
- AWS credentials configured securely via GitHub Secrets
- `terraform plan` executed for the target environment
- No infrastructure is modified

### Why This Matters
Teams can review **exactly what will change** before applying.

---

## Cost Governance with Infracost

Cost control is treated as a **first-class citizen** in this project.

### Infracost Integration
- Runs automatically on Pull Requests
- Generates **cost breakdown and cost diff**
- Posts cost impact directly as PR comments

### What Was Learned
- Instance type selection dramatically affects monthly cost
- Graviton instances significantly reduce spend
- gp3 volumes provide better performance at lower cost
- Small configuration changes can cause large cost differences

### Real Outcomes
- Initial monthly estimate: ~$336
- Optimized estimate: ~$183
- Final optimized design: ~$85

This made cost **visible, reviewable, and intentional**.

> 📸 Evidence  
> ![alt text](<Screenshot 2026-01-03 090246.png>)
> ![alt text](<Screenshot 2026-01-05 163659.png>)
> ![alt text](<Screenshot 2026-01-05 230409.png>)
---

## Key CI/CD Benefits Achieved

- ✅ Shift-left security for infrastructure
- ✅ Automated policy enforcement
- ✅ Cost transparency before merge
- ✅ Safer Terraform changes
- ✅ Audit-ready infrastructure
- ✅ Industry-aligned DevSecOps workflow

---

## Final Outcome

This CI/CD pipeline transforms infrastructure changes into a **secure, predictable, and cost-aware process**, closely mirroring **real-world enterprise DevOps practices**.


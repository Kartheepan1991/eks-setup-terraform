# EKS Terraform Project with Flux CD and GitOps## CI/CD Automation

A production-ready AWS EKS infrastructure provisioned with Terraform, featuring automated CI/CD, GitOps with Flux CD, and Helm-based application deployment. Perfect for demonstrating DevOps expertise ### Terraform CI Workflow

## 📋 Table of ContentsThis repository includes a GitHub Actions workflow to automatically validate Terraform code on pull requests:

- [Architecture Overview](#-architecture-overview)- Workflow file: `.github/workflows/terraform-ci.yaml`

- [Project Structure](#-project-structure)- Runs `terraform init` and `terraform plan` on every PR

- [Prerequisites](#-prerequisites)- Uses AWS credentials from GitHub secrets (never stored in code)

- [Quick Start Guide](#-quick-start-guide)- Includes timeout protection (15 minutes) to prevent hanging builds

- [Detailed Setup Steps](#-detailed-setup-steps)- Uses `-input=false` flag to prevent interactive prompts

- [CI/CD Automation](#-cicd-automation)

- [Flux CD GitOps](#-flux-cd-gitops)#### Required GitHub Secrets

- [Configuration Options](#-configuration-options)1. Go to your GitHub repository Settings → Secrets and variables → Actions

- [Cost Management](#-cost-management)2. Add the following secrets:

- [Troubleshooting](#-troubleshooting)   - `AWS_ACCESS_KEY_ID`: Your AWS access key

- [Cleanup](#-cleanup)   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

---#### How It Works

1. Open a pull request with Terraform changes

## 🏗️ Architecture Overview2. The workflow automatically runs and validates your infrastructure code

3. Review the plan output in the Actions tab

```4. Merge when all checks pass

┌───────────────────────────────────────────────────────────┐

│              VPC (10.0.0.0/16) - ap-southeast-1           │**Note**: The workflow only runs on pull requests (not on every push) to save GitHub Actions minutes and reduce noise.

│  ┌────────────────────────┐  ┌────────────────────────┐   │# EKS Demo Project: Terraform, Flux CD, Helm, Sample App

│  │   Public Subnet AZ-A   │  │   Public Subnet AZ-B   │   │This repository demonstrates a real-world DevOps workflow for AWS EKS using Terraform, Flux CD (GitOps), Helm, and a sample application. Ideal for freelance/Upwork showcase and CKA exam practice.

│  │    10.0.101.0/24       │  │    10.0.102.0/24       │   │## Structure

│  │  ┌──────────────────┐  │  │  ┌──────────────────┐  │   │```

│  │  │  NAT Gateway     │  │  │  │  NAT Gateway     │  │   │/ 

│  │  │  (Internet GW)   │  │  │  │  (Internet GW)   │  │   │├── terraform/         # Terraform code for EKS, VPC, IAM, etc.

│  │  └──────────────────┘  │  │  └──────────────────┘  │   ││   ├── modules/       # Reusable Terraform modules

│  └────────────────────────┘  └────────────────────────┘   ││   │   ├── eks/       # EKS cluster module

│                                                            ││   │   └── vpc/       # VPC networking module

│  ┌────────────────────────┐  ┌────────────────────────┐   ││   └── environments/  # Environment-specific configurations

│  │  Private Subnet AZ-A   │  │  Private Subnet AZ-B   │   ││       └── dev/       # Development environment

│  │    10.0.1.0/24         │  │    10.0.2.0/24         │   │├── flux/              # Flux CD manifests, sources, kustomizations

│  │  ┌──────────────────┐  │  │  ┌──────────────────┐  │   │├── helm-charts/       # Helm charts (custom/third-party)

│  │  │  EKS Worker      │  │  │  │  EKS Worker      │  │   │├── app/               # Sample application code

│  │  │  Nodes           │  │  │  │  Nodes           │  │   │├── scripts/           # Automation scripts

│  │  └──────────────────┘  │  │  └──────────────────┘  │   │├── docs/              # Documentation, diagrams, guides

│  └────────────────────────┘  └────────────────────────┘   │└── .github/workflows/ # CI/CD pipelines

└───────────────────────────────────────────────────────────┘```

                           │## Workflow

                           ▼## End-to-End Workflow

                  ┌─────────────────┐

                  │  EKS Control    │### 1. Provision EKS Cluster with Terraform

                  │  Plane (v1.31)  │

                  │  - Multi-AZ HA  │#### Prerequisites

                  │  - OIDC Enabled │- AWS CLI configured with credentials

                  └─────────────────┘- Terraform installed (v1.0+)

```- kubectl installed



### Key Components#### Steps

1. Navigate to the dev environment:

**Infrastructure (Terraform)**   ```bash

- **EKS Cluster**: Kubernetes v1.31 with managed control plane   cd terraform/environments/dev

- **VPC**: Multi-AZ setup with public and private subnets   ```

- **NAT Gateways**: One per AZ for high availability (configurable)

- **Security Groups**: Minimal access with least privilege2. Review and customize `terraform.tfvars` with your settings (region, cluster name, etc.)

- **IAM Roles**: OIDC-enabled for service account integration

- **CloudWatch**: Cluster logging and monitoring3. Initialize Terraform:

   ```bash

**GitOps (Flux CD)**   terraform init

- Automated deployment from Git repository   ```

- Continuous reconciliation of cluster state

- Support for Helm releases and Kustomize4. Review the execution plan:

- Multi-tenancy ready   ```bash

   terraform plan

**CI/CD (GitHub Actions)**   ```

- Terraform validation on pull requests

- Automated Flux bootstrap workflow5. Apply the infrastructure:

- AWS credential integration via secrets   ```bash

   terraform apply

### Architecture Highlights   ```

   (This takes ~10-15 minutes to create the EKS cluster)

- **Region**: ap-southeast-1 (Singapore)

- **Availability Zones**: 2 (ap-southeast-1a, ap-southeast-1b)6. Configure kubectl to connect to your cluster:

- **VPC CIDR**: 10.0.0.0/16   ```bash

- **NAT Gateways**: 2 (one per AZ, configurable)   aws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev

- **Kubernetes Version**: 1.31 (upgradeable incrementally)   kubectl get nodes

- **Node Groups**: Configurable (on-demand and spot instances)   ```



---**Note**: The `terraform.tfvars` file is tracked in git because it contains only non-sensitive configuration (no secrets or credentials).



## 📁 Project Structure

### 2. Bootstrap Flux CD (GitOps)

```

eks-terraform-project/#### Option 1: Using Flux CLI (Local)

├── terraform/1. Install Flux CLI:

│   ├── modules/                 # Reusable Terraform modules   ```bash

│   │   ├── vpc/                 # VPC, subnets, NAT, routing   curl -s https://fluxcd.io/install.sh | sudo bash

│   │   │   ├── main.tf   ```

│   │   │   ├── variables.tf2. Create a GitHub Personal Access Token:

│   │   │   └── outputs.tf   - Go to: https://github.com/settings/tokens

│   │   └── eks/                 # EKS cluster, IAM, OIDC   - Generate new token (classic) with `repo` scope

│   │       ├── main.tf   

│   │       ├── variables.tf3. Bootstrap Flux:

│   │       └── outputs.tf   ```bash

│   └── environments/            # Environment-specific configs   export GITHUB_TOKEN=<your-token>

│       └── dev/                 # Development environment   flux bootstrap github \

│           ├── main.tf          # Calls modules with dev values     --owner=Kartheepan1991 \

│           ├── variables.tf     # Environment variables     --repository=eks-setup-terraform \

│           ├── terraform.tfvars # Variable values (non-sensitive)     --branch=main \

│           └── outputs.tf       # Environment outputs     --path=./flux \

├── flux/                        # Flux CD GitOps manifests     --personal

│   └── flux-bootstrap.yaml      # GitRepository and Kustomization   ```

├── app/                         # Application manifests (synced by Flux)4. Flux will install controllers and sync manifests from your repo automatically.

│   ├── deployment.yaml          # Sample app deployment

│   ├── service.yaml             # Service definition#### Option 2: Using GitHub Actions (Automated - Recommended)

│   ├── ingress.yaml             # Ingress rules1. **Create a GitHub Personal Access Token:**

│   └── index-configmap.yaml    # Configuration   - Go to: https://github.com/settings/tokens

├── helm-charts/                 # Helm charts   - Generate new token (classic) with `repo` scope

│   └── nginx-ingress/           # NGINX Ingress Controller   - Copy the token

│       ├── Chart.yaml

│       ├── values.yaml2. **Add required GitHub Secrets:**

│       └── templates/   - Go to Settings → Secrets and variables → Actions

├── .github/workflows/           # CI/CD automation   - Add these secrets:

│   ├── terraform-ci.yaml        # Terraform validation on PRs     - `AWS_ACCESS_KEY_ID`: Your AWS access key (already added)

│   └── flux-bootstrap.yaml      # Automated Flux setup     - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key (already added)

├── scripts/     - `FLUX_GITHUB_TOKEN`: Your GitHub Personal Access Token (new)

│   ├── setup-backend.sh         # S3/DynamoDB backend setup

│   ├── deploy.sh                # Deployment automation3. **Trigger the Flux Bootstrap workflow:**

│   └── cleanup.sh               # Resource cleanup   - Go to Actions tab → "Flux Bootstrap to EKS"

└── README.md                    # This file   - Click "Run workflow"

```   - Select branch: `main`

   - Click "Run workflow"

### Module Details

4. **What the workflow does:**

**VPC Module (`terraform/modules/vpc/`)**   - Configures AWS credentials

- Creates production-ready VPC with public and private subnets   - Updates kubeconfig for your EKS cluster

- Configurable NAT gateways for private subnet internet access   - Installs Flux CLI

- EKS-specific tags for load balancer subnet discovery   - Bootstraps Flux to connect your cluster to this repo

- VPC endpoints for S3 to reduce data transfer costs   - Flux creates `flux-system/` directory with GitOps manifests

- Internet gateway for public subnet routing

5. **After bootstrap completes:**

**EKS Module (`terraform/modules/eks/`)**   - Flux will automatically sync your `./app` directory

- Managed EKS cluster with configurable Kubernetes version   - Any changes pushed to `./app` will be deployed automatically

- IAM roles for cluster and worker nodes   - Check status: `kubectl get gitrepositories -n flux-system`

- OIDC provider for IAM Roles for Service Accounts (IRSA)

- Security groups with minimal required access### 3. Deploy NGINX Ingress Controller (Helm)

- CloudWatch logging for audit and API logs1. Helm chart is in `helm-charts/nginx-ingress/`

- Support for managed node groups (on-demand and spot)2. Deploy via Helm or Flux HelmRelease.



---### 4. Deploy Sample App (Kustomize/Manifests)

1. App manifests are in `app/`:

## 🔧 Prerequisites   - `deployment.yaml`, `service.yaml`, `ingress.yaml`, `index-configmap.yaml`

2. Flux Kustomization applies these automatically.

### Required Tools3. Access the app via the NGINX Ingress external IP.



1. **AWS CLI** (v2.x)### 5. Automation & Cleanup

   ```bash1. Use scripts in `scripts/` for deployment and cleanup.

   aws --version2. Destroy resources when done:

   aws configure  # Set up your AWS credentials   ```bash

   ```   terraform destroy

   ```

2. **Terraform** (v1.0+)

   ```bash## Getting Started

   terraform version- See `docs/` for architecture, setup, and cost management.

   ```- Follow step-by-step instructions in the README and scripts.



3. **kubectl** (v1.28+)---

   ```bashFor questions or improvements, open an issue or contact the repo owner.

   kubectl version --client# EKS Terraform Project

   ```

This project creates a production-ready Amazon EKS (Elastic Kubernetes Service) cluster using Terraform modules with proper state management. It's designed for learning Kubernetes for CKA exam preparation while following best practices for cloud engineering.

4. **Flux CLI** (optional, for manual operations)

   ```bash## 🏗️ Architecture Overview

   curl -s https://fluxcd.io/install.sh | sudo bash

   flux version```

   ```┌───────────────────────────────────────────────────────────┐

│              VPC (10.0.0.0/16) - ap-southeast-1           │

### AWS Permissions│  ┌────────────────────────┐  ┌────────────────────────┐   │

│  │   Public Subnet AZ-A   │  │   Public Subnet AZ-B   │   │

Your AWS user/role needs permissions for:│  │    10.0.101.0/24       │  │    10.0.102.0/24       │   │

- EC2 (VPC, subnets, security groups, NAT gateways)│  │  ┌──────────────────┐  │  │  ┌──────────────────┐  │   │

- EKS (cluster creation, node groups)│  │  │  NAT Gateway     │  │  │  │  NAT Gateway     │  │   │

- IAM (roles, policies, OIDC provider)│  │  │  (Internet GW)   │  │  │  │  (Internet GW)   │  │   │

- CloudWatch Logs│  │  └──────────────────┘  │  │  └──────────────────┘  │   │

- S3 and DynamoDB (for Terraform state backend)│  └────────────────────────┘  └────────────────────────┘   │

│                                                            │

---│  ┌────────────────────────┐  ┌────────────────────────┐   │

│  │  Private Subnet AZ-A   │  │  Private Subnet AZ-B   │   │

## 🚀 Quick Start Guide│  │    10.0.1.0/24         │  │    10.0.2.0/24         │   │

│  │                        │  │                        │   │

### 1. Clone the Repository│  │  ┌──────────────────┐  │  │  ┌──────────────────┐  │   │

│  │  │  EKS Worker      │  │  │  │  EKS Worker      │  │   │

```bash│  │  │  Nodes (t3.small)│  │  │  │  Nodes (Ready)   │  │   │

git clone https://github.com/Kartheepan1991/eks-setup-terraform.git│  │  │  - aws-node CNI  │  │  │  │                  │  │   │

cd eks-setup-terraform│  │  │  - kube-proxy    │  │  │  │                  │  │   │

```│  │  └──────────────────┘  │  │  └──────────────────┘  │   │

│  └────────────────────────┘  └────────────────────────┘   │

### 2. Configure AWS Credentials│                          ▲                                 │

│                          │                                 │

```bash│                   VPC Endpoint (S3)                        │

aws configure└───────────────────────────────────────────────────────────┘

# Enter your AWS Access Key ID                           │

# Enter your AWS Secret Access Key                           ▼

# Default region: ap-southeast-1                  ┌─────────────────┐

# Default output format: json                  │  EKS Control    │

```                  │  Plane (v1.28)  │

                  │  - Multi-AZ HA  │

### 3. Customize Configuration                  │  - OIDC Enabled │

                  └─────────────────┘

Edit `terraform/environments/dev/terraform.tfvars`:```



```hcl**Key Architecture Points:**

aws_region          = "ap-southeast-1"- **Region:** ap-southeast-1 (Singapore)

environment         = "dev"- **Availability Zones:** 2 (ap-southeast-1a, ap-southeast-1b)

project_name        = "eks-demo-kartheepan-apse1"- **VPC CIDR:** 10.0.0.0/16

cluster_version     = "1.31"- **NAT Gateways:** 2 (one per AZ for high availability) - configurable via `enable_nat_gateway`

enable_nat_gateway  = true- **EKS Cluster:** Version 1.31 (upgradeable)

vpc_cidr            = "10.0.0.0/16"- **Node Groups:** Configurable (on-demand and spot instances)

availability_zones  = ["ap-southeast-1a", "ap-southeast-1b"]

## 📁 Project Structure

node_groups = {

  general = {```

    desired_capacity = 2eks-terraform-project/

    max_capacity     = 4├── terraform/

    min_capacity     = 1│   ├── modules/                 # Reusable Terraform modules

    instance_types   = ["t3.medium"]│   │   ├── vpc/                 # VPC module for networking

    capacity_type    = "ON_DEMAND"│   │   │   ├── main.tf

    # ... more configuration│   │   │   ├── variables.tf

  }│   │   │   └── outputs.tf

}│   │   └── eks/                 # EKS module for cluster creation

```│   │       ├── main.tf

│   │       ├── variables.tf

### 4. Deploy Infrastructure│   │       └── outputs.tf

│   └── environments/            # Environment-specific configurations

```bash│       └── dev/                 # Development environment

cd terraform/environments/dev│           ├── main.tf

│           ├── variables.tf

# Initialize Terraform│           ├── terraform.tfvars # Variable values (tracked in git)

terraform init│           └── outputs.tf

├── flux/                        # Flux CD GitOps manifests

# Preview changes│   └── flux-bootstrap.yaml      # GitRepository and Kustomization

terraform plan├── app/                         # Application manifests (synced by Flux)

│   ├── deployment.yaml

# Apply changes│   ├── service.yaml

terraform apply│   ├── ingress.yaml

# Type 'yes' when prompted│   └── index-configmap.yaml

```├── helm-charts/                 # Helm charts

│   └── nginx-ingress/

**Note**: EKS cluster creation takes ~10-15 minutes.├── .github/workflows/           # CI/CD automation

│   ├── terraform-ci.yaml        # Terraform validation on PRs

### 5. Configure kubectl│   └── flux-bootstrap.yaml      # Automated Flux setup

├── scripts/

```bash│   ├── setup-backend.sh         # Backend infrastructure setup

aws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev│   ├── deploy.sh                # Deployment script

kubectl get nodes│   └── cleanup.sh               # Cleanup script

kubectl cluster-info└── docs/                        # Documentation

```    ├── ARCHITECTURE.md

    ├── STRUCTURE.md

### 6. Bootstrap Flux CD (Optional)    └── WORKFLOW.md

```

See [Flux CD GitOps](#-flux-cd-gitops) section for detailed instructions.

## 🚀 Quick Start

---

### Prerequisites

## 📖 Detailed Setup Steps

1. **AWS CLI** configured with appropriate permissions

### Step 1: Terraform Backend Setup (Optional)2. **Terraform** >= 1.0 installed

3. **kubectl** installed for cluster management

If using remote state (recommended for teams):

### Step 1: Setup Backend Infrastructure

```bash

./scripts/setup-backend.sh```bash

# Note the S3 bucket and DynamoDB table names# Run the backend setup script

./scripts/setup-backend.sh

# Update backend.tf with the output values

```# Update backend.tf with the output values

```

### Step 2: Initialize and Plan

### Step 2: Configure Backend

```bash

cd terraform/environments/devUpdate `backend.tf` with the S3 bucket name and DynamoDB table from the setup script output.



# Initialize Terraform (downloads providers, sets up backend)### Step 2: Deploy the Infrastructure

terraform init

```bash

# Validate configuration# Navigate to the dev environment

terraform validatecd terraform/environments/dev



# Plan deployment (review what will be created)# Initialize Terraform

terraform plan -out=tfplanterraform init



# Review the plan output carefully# Plan the deployment

```terraform plan



### Step 3: Apply Infrastructure# Apply the configuration

terraform apply

```bash```

# Apply the planned changes

terraform apply tfplan**Note:** 

- EKS cluster creation takes ~10-15 minutes

# Or apply directly- NAT gateways are enabled by default (`enable_nat_gateway = true`)

terraform apply- Current cluster version is 1.31 (can be upgraded incrementally)

```- Node groups are defined in `terraform.tfvars` but need to be implemented in the EKS module



**What gets created:**### Step 3: Configure kubectl

- VPC with public and private subnets in 2 AZs

- Internet Gateway and NAT Gateways (if enabled)```bash

- Route tables and subnet associations# Update kubeconfig

- EKS cluster control planeaws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev

- IAM roles and policies

- Security groups# Verify cluster access

- OIDC provider for service accountskubectl get nodes

- CloudWatch log groups

# Check cluster information

### Step 4: Verify Clusterkubectl cluster-info



```bash# View all system pods

# Update kubeconfigkubectl get pods --all-namespaces

aws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev```



# Verify nodes (may be empty if node groups not deployed)## 🧩 Modules Explained

kubectl get nodes

### VPC Module (`modules/vpc/`)

# Check cluster components

kubectl get pods -n kube-systemCreates a production-ready VPC with:

- **Public subnets** for load balancers and NAT gateways

# Verify cluster info- **Private subnets** for EKS worker nodes

kubectl cluster-info- **NAT gateways** for outbound internet access from private subnets

```- **VPC endpoints** for S3 to reduce data transfer costs

- **Proper tagging** for EKS resource discovery

### Step 5: Deploy Applications

**Key Features:**

After Flux is bootstrapped (see next section), applications in the `app/` directory will be automatically deployed and synchronized.- **2 Availability Zones** (ap-southeast-1a, ap-southeast-1b) for high availability

- Automatic subnet CIDR calculation (10.0.1.0/24, 10.0.2.0/24 for private)

---- EKS-specific tags for load balancer subnet discovery

- VPC endpoints for S3 to reduce data transfer costs

## 🔄 CI/CD Automation- NAT Gateways in public subnets for private subnet internet access



### Terraform CI Workflow### EKS Module (`modules/eks/`)



**Location**: `.github/workflows/terraform-ci.yaml`Creates a secure EKS cluster with:

- **Managed node groups** with auto-scaling

**Purpose**: Automatically validates Terraform code on every pull request.- **OIDC identity provider** for IRSA (IAM Roles for Service Accounts)

- **CloudWatch logging** for cluster audit and API logs

**Features**:- **Security groups** with minimal required access

- Runs `terraform init` and `terraform plan`- **Multiple node groups** (on-demand and spot instances)

- Uses `-input=false` to prevent interactive prompts

- 15-minute timeout to prevent hanging builds**Key Features:**

- Only runs on PRs (not on every push)- Production-ready IAM roles and policies

- Cluster autoscaler support

**Setup**:- Both on-demand and spot instance node groups

- Comprehensive logging and monitoring

1. **Add GitHub Secrets**:

   - Go to: Settings → Secrets and variables → Actions## 🔧 Configuration Options

   - Add secrets:

     - `AWS_ACCESS_KEY_ID`### Node Groups

     - `AWS_SECRET_ACCESS_KEY`

The project creates a managed node group:

2. **Workflow triggers automatically** when you:

   - Open a pull request1. **General Node Group**

   - Push commits to an existing PR   - On-demand instances (t3.small)

   - Modify Terraform files   - 1 desired, 1-2 min-max capacity

   - Deployed across 2 availability zones

3. **Review results**:   - 20GB EBS storage per node

   - Go to Actions tab in GitHub   - Suitable for learning and CKA practice

   - View the workflow run

   - Review the plan output**Current Configuration:**

- **Instance Type:** t3.small (2 vCPU, 2GB RAM)

**Workflow YAML**:- **AMI Type:** Amazon Linux 2 (AL2_x86_64)

```yaml- **Disk Size:** 20GB

name: Terraform CI- **Scaling:** Min 1, Max 2, Desired 1

on:

  pull_request:### Customization

jobs:

  terraform:Modify `terraform/environments/dev/terraform.tfvars` to customize:

    runs-on: ubuntu-latest- **Region and AZs:** Change `aws_region` and `availability_zones`

    timeout-minutes: 15- **NAT Gateway:** Enable/disable with `enable_nat_gateway` (currently: true)

    steps:- **Kubernetes version:** Change `cluster_version` (current: 1.31, upgradeable incrementally)

      - uses: actions/checkout@v4- **Network CIDR:** Modify `vpc_cidr` (default: 10.0.0.0/16)

      - uses: aws-actions/configure-aws-credentials@v4- **Node groups:** Configure instance types, scaling, and instance types

        with:  - On-demand nodes: General workloads

          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}  - Spot instances: Cost-effective for fault-tolerant workloads

          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}- **Resource tags:** Update `common_tags` for cost tracking

          aws-region: ap-southeast-1

      - uses: hashicorp/setup-terraform@v2## 🛡️ Security Best Practices

      - run: terraform -chdir=terraform/environments/dev init -input=false

      - run: terraform -chdir=terraform/environments/dev plan -input=false -var-file=terraform.tfvars1. **Network Security**

```   - Private subnets for worker nodes

   - Security groups with minimal access

---   - VPC endpoints to reduce internet traffic



## 🔁 Flux CD GitOps2. **IAM Security**

   - Least privilege IAM roles

### What is Flux CD?   - OIDC provider for service account integration

   - No hardcoded credentials

Flux is a GitOps tool that keeps your Kubernetes cluster in sync with your Git repository. Any changes pushed to your `app/` directory will be automatically deployed to the cluster.

3. **Cluster Security**

### Flux Bootstrap Options   - Private API endpoint option

   - Audit logging enabled

#### Option 1: Manual CLI Bootstrap (Recommended for Learning)   - Encryption at rest and in transit



1. **Install Flux CLI**:## 📊 State Management

   ```bash

   curl -s https://fluxcd.io/install.sh | sudo bashThis project uses Terraform remote state with:

   flux version- **S3 bucket** for state storage with versioning and encryption

   ```- **DynamoDB table** for state locking to prevent concurrent modifications

- **Backend encryption** for security

2. **Create GitHub Personal Access Token**:

   - Go to: https://github.com/settings/tokens## 🎯 Learning Objectives for CKA

   - Generate new token (classic)

   - Select scope: `repo` (full control of private repositories)This setup helps you practice:

   - Copy the token

1. **Cluster Management**

3. **Bootstrap Flux**:   - Understanding EKS architecture

   ```bash   - Node management and scaling

   export GITHUB_TOKEN=<your-token>   - Cluster networking

   flux bootstrap github \

     --owner=Kartheepan1991 \2. **Networking**

     --repository=eks-setup-terraform \   - Pod-to-pod communication

     --branch=main \   - Service networking

     --path=./flux \   - Ingress controllers

     --personal

   ```3. **Security**

   - RBAC configuration

4. **Verify installation**:   - Service accounts and IRSA

   ```bash   - Network policies

   flux check

   kubectl get pods -n flux-system4. **Troubleshooting**

   kubectl get gitrepositories -n flux-system   - Cluster debugging

   kubectl get kustomizations -n flux-system   - Log analysis

   ```   - Performance monitoring



#### Option 2: Automated GitHub Actions (Recommended for Production)## 📝 Common kubectl Commands



**Location**: `.github/workflows/flux-bootstrap.yaml````bash

# Cluster information

**Setup**:kubectl cluster-info

kubectl get nodes

1. **Create GitHub Personal Access Token** (same as above)kubectl describe nodes



2. **Add GitHub Secrets**:# Workload management

   - Go to: Settings → Secrets and variables → Actionskubectl get pods --all-namespaces

   - Add secrets:kubectl get services --all-namespaces

     - `AWS_ACCESS_KEY_ID` (already added)kubectl get deployments --all-namespaces

     - `AWS_SECRET_ACCESS_KEY` (already added)

     - `FLUX_GITHUB_TOKEN` (your GitHub PAT)# Troubleshooting

kubectl logs <pod-name>

3. **Trigger the workflow**:kubectl describe pod <pod-name>

   - Go to: Actions → "Flux Bootstrap to EKS"kubectl top nodes

   - Click "Run workflow"kubectl top pods

   - Select branch: `main````

   - Click "Run workflow"

## 🧹 Cleanup

4. **What the workflow does**:

   - Configures AWS credentialsTo destroy the infrastructure and avoid ongoing AWS costs:

   - Updates kubeconfig for your EKS cluster

   - Installs Flux CLI```bash

   - Runs `flux bootstrap github` commandcd terraform/environments/dev

   - Flux creates `flux-system/` directory in your repoterraform destroy

   - Starts syncing your `./app` directory

# Confirm with 'yes' when prompted

5. **Verify deployment**:```

   ```bash

   kubectl get pods -n flux-system**Note:** Destroying takes ~5-10 minutes. Make sure to destroy when not using the cluster to avoid unnecessary costs (~$0.10/hour for EKS control plane + NAT gateways + EC2 instances).

   flux get sources git

   flux get kustomizations## 📚 Additional Resources

   ```

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)

### How Flux Works- [Kubernetes Documentation](https://kubernetes.io/docs/)

- [CKA Exam Curriculum](https://github.com/cncf/curriculum)

1. **GitRepository**: Flux watches your GitHub repo for changes- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

2. **Kustomization**: Flux applies manifests from `./app` directory

3. **Automatic Sync**: Every change to `app/` is deployed within 1-10 minutes## 🤝 Contributing

4. **Reconciliation**: Flux ensures cluster state matches Git (desired state)

This project is designed for learning. Feel free to:

### Flux Configuration- Experiment with different configurations

- Add additional node groups

**File**: `flux/flux-bootstrap.yaml`- Implement monitoring solutions

- Practice with different Kubernetes workloads

```yaml

apiVersion: source.toolkit.fluxcd.io/v1beta2---

kind: GitRepository

metadata:**Happy Learning! 🚀**
  name: eks-demo-repo
  namespace: flux-system
spec:
  interval: 1m0s
  url: https://github.com/Kartheepan1991/eks-setup-terraform
  branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: eks-demo-kustomization
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./app
  prune: true
  sourceRef:
    kind: GitRepository
    name: eks-demo-repo
```

---

## ⚙️ Configuration Options

### Customizing Your Deployment

Edit `terraform/environments/dev/terraform.tfvars`:

#### Region and Network Settings

```hcl
aws_region          = "ap-southeast-1"
vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["ap-southeast-1a", "ap-southeast-1b"]
```

#### EKS Cluster Settings

```hcl
cluster_version     = "1.31"  # Kubernetes version
project_name        = "eks-demo-kartheepan-apse1"
environment         = "dev"
```

**Version Upgrade Notes**:
- AWS EKS requires incremental version upgrades (1.28 → 1.29 → 1.30 → 1.31)
- Use `terraform apply` with updated `cluster_version`
- Each upgrade takes ~20-30 minutes

#### NAT Gateway Configuration

```hcl
enable_nat_gateway = true   # Set to false to save ~$64/month
```

**Important**: NAT gateways are required for worker nodes to pull container images and access AWS services from private subnets.

#### Node Group Configuration

```hcl
node_groups = {
  general = {
    desired_capacity = 2
    max_capacity     = 4
    min_capacity     = 1
    instance_types   = ["t3.medium"]
    capacity_type    = "ON_DEMAND"
    disk_size        = 20
    ami_type         = "AL2_x86_64"
    labels = {
      role        = "general"
      environment = "dev"
    }
    taints = []
    additional_tags = {
      Name = "eks-general-node"
    }
  },
  spot = {
    desired_capacity = 1
    max_capacity     = 3
    min_capacity     = 0
    instance_types   = ["t3.medium", "t3.large"]
    capacity_type    = "SPOT"
    # Spot instances are ~70% cheaper but can be terminated
  }
}
```

#### Common Tags

```hcl
common_tags = {
  Project     = "eks-demo-kartheepan-apse1"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "YourName"
}
```

---

## 💰 Cost Management

### Estimated Monthly Costs (ap-southeast-1)

| Resource | Cost | Notes |
|----------|------|-------|
| EKS Control Plane | ~$72 | $0.10/hour |
| NAT Gateway (2) | ~$64 | $0.045/hour each |
| t3.medium nodes (2) | ~$60 | $0.042/hour each |
| EBS volumes | ~$8 | 20GB per node |
| **Total** | **~$204/month** | Without data transfer |

### Cost Optimization Tips

1. **Destroy when not in use**:
   ```bash
   terraform destroy
   ```
   You can recreate the cluster anytime with `terraform apply`.

2. **Disable NAT gateways** (for cost-sensitive learning):
   - Set `enable_nat_gateway = false` in terraform.tfvars
   - Use VPC endpoints for AWS services instead
   - Or deploy nodes in public subnets (less secure)

3. **Use Spot instances** for non-critical workloads:
   - Configure spot node groups (already in tfvars)
   - ~70% cheaper than on-demand
   - Suitable for batch jobs, testing

4. **Right-size your nodes**:
   - Start with t3.small ($30/month) instead of t3.medium
   - Scale based on actual usage

5. **Set up AWS Budgets**:
   ```bash
   aws budgets create-budget \
     --account-id $(aws sts get-caller-identity --query Account --output text) \
     --budget file://budget.json
   ```

6. **Monitor with Cost Explorer**:
   - Go to AWS Console → Cost Management → Cost Explorer
   - Filter by tags (Project=eks-demo-kartheepan-apse1)

### Cleanup Checklist

Before destroying:
- [ ] Export any important data
- [ ] Take snapshots if needed
- [ ] Verify no production workloads running
- [ ] Run `terraform destroy`
- [ ] Check AWS console for any orphaned resources

---

## 🔍 Troubleshooting

### Common Issues and Solutions

#### 1. Terraform Init Fails

**Error**: `Error: Failed to download provider`

**Solution**:
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

#### 2. AWS Credentials Not Found

**Error**: `Error: No valid credential sources found`

**Solution**:
```bash
# Configure AWS CLI
aws configure

# Or export environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=ap-southeast-1
```

#### 3. EKS Cluster Creation Timeout

**Error**: `Timeout while waiting for EKS cluster to become ACTIVE`

**Solution**:
- This is usually fine, just wait 15-20 minutes
- Check AWS Console → EKS → Clusters
- If stuck for >30 minutes, check IAM permissions

#### 4. kubectl Can't Connect to Cluster

**Error**: `Unable to connect to the server`

**Solution**:
```bash
# Update kubeconfig
aws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev

# Verify AWS credentials
aws sts get-caller-identity

# Check cluster status
aws eks describe-cluster --name eks-demo-kartheepan-apse1-dev --region ap-southeast-1
```

#### 5. Flux Bootstrap Fails

**Error**: `authentication required` or `permission denied`

**Solution**:
```bash
# Verify GitHub token has 'repo' scope
echo $GITHUB_TOKEN

# Re-create token if needed
# Ensure FLUX_GITHUB_TOKEN secret is added to GitHub Actions
```

#### 6. Nodes Not Joining Cluster

**Error**: No nodes shown with `kubectl get nodes`

**Solution**:
- Node groups may not be fully implemented in the EKS module
- Check AWS Console → EKS → Cluster → Compute
- Verify subnet tags include `kubernetes.io/cluster/<cluster-name> = shared`

#### 7. GitHub Actions Workflow Fails

**Error**: `Error: No value for required variable`

**Solution**:
- Ensure `terraform.tfvars` is committed to the repository
- Check that `.gitignore` doesn't exclude `terraform.tfvars`
- Verify GitHub Secrets are configured correctly

### Debugging Commands

```bash
# Terraform debugging
export TF_LOG=DEBUG
terraform plan

# Check Terraform state
terraform show
terraform state list

# AWS EKS debugging
aws eks describe-cluster --name eks-demo-kartheepan-apse1-dev --region ap-southeast-1

# Kubernetes debugging
kubectl get events --all-namespaces
kubectl logs -n kube-system <pod-name>
kubectl describe node <node-name>

# Flux debugging
flux check
flux logs
kubectl logs -n flux-system deploy/source-controller
```

---

## 🧹 Cleanup

### Complete Infrastructure Teardown

1. **Navigate to environment directory**:
   ```bash
   cd terraform/environments/dev
   ```

2. **Destroy all resources**:
   ```bash
   terraform destroy
   ```

3. **Confirm destruction**:
   - Review the list of resources to be destroyed
   - Type `yes` when prompted

4. **Verify cleanup**:
   ```bash
   # Check AWS Console for any remaining resources
   aws eks list-clusters --region ap-southeast-1
   aws ec2 describe-vpcs --region ap-southeast-1
   ```

**Time estimate**: 5-10 minutes

**Cost after cleanup**: $0 (assuming all resources destroyed)

### Partial Cleanup Options

**Delete only worker nodes** (keep cluster):
```bash
# Remove node groups from terraform.tfvars
# Run terraform apply
```

**Delete NAT gateways** (reduce cost by ~$64/month):
```bash
# Set enable_nat_gateway = false in terraform.tfvars
# Run terraform apply
```

---

## 📚 Additional Resources

### Official Documentation

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Flux CD Documentation](https://fluxcd.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Learning Resources

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [CKA Exam Curriculum](https://github.com/cncf/curriculum)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Useful kubectl Commands

```bash
# Cluster information
kubectl cluster-info
kubectl get nodes -o wide
kubectl describe node <node-name>

# Workload management
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
kubectl get deployments --all-namespaces

# Troubleshooting
kubectl logs <pod-name> -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl top nodes
kubectl top pods --all-namespaces

# Flux operations
flux get sources git
flux get kustomizations
flux reconcile source git eks-demo-repo
flux logs --follow
```

---

## 🚀 Complete CI/CD Pipeline

This project includes a **production-ready CI/CD pipeline** that combines **GitHub Actions** (CI) with **Flux CD** (GitOps deployment).

### Pipeline Architecture

```
Developer Push → GitHub Actions (Test + Build + Push to ECR) 
    → Update Manifest → Flux Detects Change → Deploy to EKS
```

**Total Time: ~5-6 minutes from commit to production**

### Components

#### 1. **GitHub Actions CI** (`.github/workflows/ci-cd.yml`)
- ✅ **Automated Testing**: Runs Jest tests on every push
- ✅ **Docker Build**: Multi-stage builds for optimized images
- ✅ **ECR Push**: Pushes images to Amazon ECR with SHA tags
- ✅ **Manifest Update**: Automatically updates deployment.yaml
- ✅ **Security Scanning**: ECR vulnerability scanning enabled

#### 2. **Flux CD GitOps** (`flux/`)
- ✅ **Automated Deployment**: Watches Git repo every 1 minute
- ✅ **Rolling Updates**: Zero-downtime deployments
- ✅ **Health Checks**: Validates pod readiness before completion
- ✅ **Auto-Rollback**: Reverts failed deployments automatically

#### 3. **Sample Application** (`sample-app/`)
- 🟢 **Node.js/Express** REST API
- 🟢 **Health Endpoints**: `/health`, `/api/info`
- 🟢 **Dockerized**: Multi-stage Dockerfile with non-root user
- 🟢 **Production Ready**: Resource limits, security contexts, probes

### Quick Start CI/CD

```bash
# 1. Configure AWS credentials in GitHub Secrets
AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

# 2. Update ECR registry URL (replace with your account ID)
sed -i 's/311719319684/<YOUR_ACCOUNT_ID>/g' app/deployment.yaml

# 3. Push code to trigger pipeline
git add sample-app/
git commit -m "Update application"
git push origin main

# 4. Watch deployment
flux get kustomizations --watch
kubectl get pods -l app=eks-demo-app -w
```

### Key Features
- **Zero-Downtime Deployments**: Rolling updates with `maxUnavailable: 0`
- **Automated Testing**: CI pipeline gates deployment on test success
- **GitOps**: Git as single source of truth
- **Security**: Non-root containers, vulnerability scanning, resource limits
- **Observability**: Health probes, structured logging

### Documentation
- 📘 **[Complete CI/CD Guide](CICD_PIPELINE.md)** - Architecture, concepts, interview tips
- 📗 **[Setup Instructions](CICD_SETUP.md)** - Step-by-step configuration guide

---

## 🤝 Contributing

This project is designed for learning and demonstration. Feel to:
- Fork and experiment
- Add new features (monitoring, service mesh, etc.)
- Improve documentation
- Share feedback via issues

---

## 📄 License

This project is open source and available under the MIT License.

---

## 👤 Author

**Kartheepan**
- GitHub: [@Kartheepan1991](https://github.com/Kartheepan1991)
- Repository: [eks-setup-terraform](https://github.com/Kartheepan1991/eks-setup-terraform)

---

**Happy Learning! 🚀**

*Last Updated: November 2025*

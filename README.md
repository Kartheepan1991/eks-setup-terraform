# EKS Terraform Project with Complete CI/CD Pipeline

> **Production-ready AWS EKS infrastructure** with Terraform, Flux CD GitOps, GitHub Actions CI/CD, and a sample Node.js application. Perfect for DevOps interviews, freelance portfolios, and learning Kubernetes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-blue)](https://kubernetes.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS-orange)](https://aws.amazon.com/eks/)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
  - [1. Infrastructure (Terraform)](#1-infrastructure-terraform)
  - [2. CI/CD (GitHub Actions)](#2-cicd-github-actions)
  - [3. GitOps (Flux CD)](#3-gitops-flux-cd)
  - [4. Application Deployment](#4-application-deployment)
- [Configuration](#-configuration)
- [Monitoring & Troubleshooting](#-monitoring--troubleshooting)
- [Cost Management](#-cost-management)
- [Interview Demo Guide](#-interview-demo-guide)
- [Cleanup](#-cleanup)
- [License](#-license)

---

## 🎯 Overview

This project demonstrates a **complete DevOps workflow** for deploying and managing applications on AWS EKS:

### What You'll Learn

✅ **Infrastructure as Code**: Terraform modules for VPC, EKS, and IAM  
✅ **GitOps**: Flux CD for continuous deployment from Git  
✅ **CI/CD**: GitHub Actions for automated testing, building, and deployment  
✅ **Kubernetes**: Deployments, Services, Ingress, Health Probes, Resource Management  
✅ **Container Security**: Multi-stage builds, non-root containers, vulnerability scanning  
✅ **AWS Best Practices**: Cost optimization, security groups, IAM roles  

### Key Features

- **Zero-downtime deployments** with rolling updates
- **Automated CI/CD pipeline** (5-6 minutes commit-to-production)
- **GitOps** - Git as single source of truth
- **Multi-AZ high availability** with autoscaling
- **Production-ready security** (RBAC, security contexts, resource limits)
- **Comprehensive documentation** for interviews and demos

---

## 🏗️ Architecture

### Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     AWS Region: ap-southeast-1                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              VPC (10.0.0.0/16)                              │   │
│  │                                                             │   │
│  │  ┌──────────────────────┐  ┌──────────────────────┐        │   │
│  │  │  Public Subnet AZ-A  │  │  Public Subnet AZ-B  │        │   │
│  │  │   10.0.101.0/24      │  │   10.0.102.0/24      │        │   │
│  │  │                      │  │                      │        │   │
│  │  │  ┌──────────────┐    │  │  ┌──────────────┐    │        │   │
│  │  │  │ NAT Gateway  │    │  │  │ NAT Gateway  │    │        │   │
│  │  │  │ + Elastic IP │    │  │  │ + Elastic IP │    │        │   │
│  │  │  └──────────────┘    │  │  └──────────────┘    │        │   │
│  │  │         │            │  │         │            │        │   │
│  │  └─────────┼────────────┘  └─────────┼────────────┘        │   │
│  │            │                         │                     │   │
│  │  ┌─────────▼─────────────┐  ┌───────▼────────────┐        │   │
│  │  │ Private Subnet AZ-A   │  │ Private Subnet AZ-B│        │   │
│  │  │   10.0.1.0/24         │  │   10.0.2.0/24      │        │   │
│  │  │                       │  │                    │        │   │
│  │  │  ┌───────────────┐    │  │  ┌───────────────┐│        │   │
│  │  │  │ EKS Worker    │    │  │  │ EKS Worker    ││        │   │
│  │  │  │ Nodes (t3.    │    │  │  │ Nodes (t3.    ││        │   │
│  │  │  │ small x 2)    │    │  │  │ small x 2)    ││        │   │
│  │  │  └───────────────┘    │  │  └───────────────┘│        │   │
│  │  └───────────────────────┘  └────────────────────┘        │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │          EKS Control Plane (v1.31) - Managed by AWS         │   │
│  │          - Multi-AZ High Availability                       │   │
│  │          - OIDC Provider for IRSA                           │   │
│  │          - CloudWatch Logging Enabled                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### CI/CD Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                       COMPLETE CI/CD FLOW                            │
└──────────────────────────────────────────────────────────────────────┘

  Developer                GitHub Repository           GitHub Actions
  ┌─────────┐              ┌───────────────┐          ┌──────────────┐
  │         │              │               │          │              │
  │ git push│─────────────▶│  sample-app/  │─────────▶│ 1. Run Tests │
  │ (code   │              │  ├─ server.js │          │    (Jest)    │
  │ changes)│              │  └─ Dockerfile│          │              │
  │         │              │               │          └──────┬───────┘
  └─────────┘              └───────────────┘                 │
                                                              │
                                                              ▼
                                                     ┌──────────────┐
                                                     │ 2. Build     │
                                                     │    Docker    │
                                                     │    Image     │
                                                     └──────┬───────┘
                                                            │
                                                            ▼
   ┌──────────────────────────────────────────────────────────┐
   │           Amazon ECR (Container Registry)                │
   │   Image: 311719319684.dkr.ecr.../eks-demo-app:sha       │
   └──────────────────────┬───────────────────────────────────┘
                          │
                          │ 3. Update manifest with new image tag
                          ▼
                   ┌─────────────┐
                   │ app/        │
                   │ deployment. │─────┐
                   │ yaml        │     │ Git commit pushed
                   └─────────────┘     │
                          │            │
                          ▼            ▼
                   ┌────────────────────────┐
                   │    Flux CD (GitOps)    │
                   │  - Watches repo (1min) │
                   │  - Detects changes     │
                   │  - Applies to cluster  │
                   └──────────┬─────────────┘
                              │
                              ▼
                   ┌────────────────────────┐
                   │   EKS Cluster (Prod)   │
                   │                        │
                   │  ┌──────┐   ┌──────┐  │
                   │  │ Pod 1│   │ Pod 2│  │
                   │  └───┬──┘   └───┬──┘  │
                   │      └──────────┘     │
                   │           │           │
                   │      ┌────▼─────┐     │
                   │      │ Service  │     │
                   │      └────┬─────┘     │
                   │           │           │
                   │      ┌────▼─────┐     │
                   │      │ Ingress  │     │
                   │      └──────────┘     │
                   └────────────────────────┘

⏱️  Total Time: 5-6 minutes from commit to production
🔄  Zero Downtime: Rolling updates with health checks
```

---

## 📁 Project Structure

```
eks-terraform-project/
│
├── terraform/                      # Infrastructure as Code
│   ├── modules/
│   │   ├── vpc/                   # VPC with public/private subnets, NAT
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── eks/                   # EKS cluster, node groups, IAM
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       └── dev/                   # Development environment
│           ├── main.tf           # Calls VPC + EKS modules
│           ├── terraform.tfvars  # Environment-specific values
│           ├── variables.tf
│           └── outputs.tf
│
├── sample-app/                     # Node.js Application (Source Code)
│   ├── server.js                  # Express REST API
│   ├── server.test.js             # Jest unit tests
│   ├── package.json               # Dependencies
│   ├── Dockerfile                 # Multi-stage container build
│   └── .dockerignore
│
├── app/                            # Kubernetes Manifests (Deployed by Flux)
│   ├── deployment.yaml            # Deployment with health probes
│   ├── service.yaml               # ClusterIP service
│   └── ingress.yaml               # Nginx ingress routing
│
├── flux/                           # Flux CD GitOps Configuration
│   ├── flux-bootstrap.yaml        # GitRepository + Kustomization
│   ├── README.md                  # Flux setup instructions
│   └── nginx-ingress-helmrelease.yaml.example  # Optional Helm chart
│
├── helm-charts/                    # Optional Helm Charts
│   └── nginx-ingress/             # Custom ingress controller chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│
├── .github/workflows/              # CI/CD Automation
│   └── ci-cd.yml                  # Complete pipeline (test, build, deploy)
│
├── scripts/                        # Utility Scripts
│   ├── setup-backend.sh           # S3 + DynamoDB for Terraform state
│   ├── deploy.sh                  # Deployment automation
│   └── cleanup.sh                 # Resource cleanup
│
└── Documentation
    ├── README.md                   # This file
    ├── CICD_PIPELINE.md           # Detailed CI/CD docs
    ├── CICD_SETUP.md              # Setup instructions
    ├── CICD_QUICK_REFERENCE.md    # Command reference
    ├── COST_MANAGEMENT.md         # AWS cost optimization
    └── LICENSE                    # MIT License
```

---

## 🔄 CI/CD Pipeline

### Pipeline Overview

The project implements a **complete automated CI/CD pipeline** using GitHub Actions and Flux CD:

#### 1. Continuous Integration (GitHub Actions)

**Workflow File**: `.github/workflows/ci-cd.yml`

**Jobs**:

1. **Test** (`~30 seconds`)
   - Checkout code
   - Install Node.js dependencies
   - Run Jest unit tests
   - Upload coverage reports to Codecov

2. **Build & Push** (`~3-4 minutes`)
   - Configure AWS credentials
   - Login to Amazon ECR
   - Build Docker image (multi-stage)
   - Tag with: `SHA`, `branch`, `latest`
   - Push to ECR registry
   - Enable vulnerability scanning

3. **Update Manifest** (`~10 seconds`)
   - Update `app/deployment.yaml` with new image tag
   - Commit changes back to repository
   - Include `[skip ci]` to prevent loops

4. **Notify** (`~5 seconds`)
   - Report pipeline status
   - Can integrate with Slack/Teams

**Total CI Time**: ~4-5 minutes

#### 2. Continuous Deployment (Flux CD)

**How It Works**:

1. **Flux watches** the Git repository every 1 minute
2. **Detects changes** in `app/` directory manifests
3. **Pulls new image** from Amazon ECR
4. **Applies changes** to EKS cluster
5. **Rolling update** with zero-downtime (maxUnavailable: 0)
6. **Health checks** validate pods before routing traffic

**Total CD Time**: ~1-2 minutes

### Application Endpoints

The sample Node.js application exposes:

- `GET /` - Welcome message with version info
- `GET /health` - Health check endpoint (liveness/readiness)
- `GET /api/info` - Application metadata and tech stack

### Key Features

✅ **Automated Testing**: Unit tests gate production deployments  
✅ **Zero-Downtime**: Rolling updates with health validation  
✅ **GitOps**: Git as single source of truth  
✅ **Security**: Vulnerability scanning, non-root containers  
✅ **Fast**: 5-6 minute commit-to-production cycle  

---

## 📦 Prerequisites

### Required Tools

- **AWS Account** with permissions for EC2, VPC, EKS, ECR, IAM
- **AWS CLI** (v2.x) - [Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Terraform** (v1.0+) - [Install](https://developer.hashicorp.com/terraform/downloads)
- **kubectl** (v1.28+) - [Install](https://kubernetes.io/docs/tasks/tools/)
- **Flux CLI** (v2.x) - [Install](https://fluxcd.io/flux/installation/)
- **Docker** (for local testing) - [Install](https://docs.docker.com/get-docker/)
- **Git** - [Install](https://git-scm.com/downloads)

### AWS Permissions Required

Your AWS user/role needs:
- EC2 (VPC, Subnets, Security Groups, NAT Gateway)
- EKS (Cluster management)
- ECR (Container registry)
- IAM (Roles and policies)
- CloudWatch (Logging)

### Cost Estimate

- **EKS Control Plane**: ~$73/month ($0.10/hour)
- **Worker Nodes**: 2 x t3.small ~$30/month
- **NAT Gateways**: 2 x ~$32/month = ~$64/month
- **Data Transfer**: Variable
- **ECR Storage**: ~$0.10/GB/month

**Total**: ~$170-200/month for dev environment

💡 **Tip**: Destroy resources when not in use to save costs!

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/Kartheepan1991/eks-setup-terraform.git
cd eks-terraform-project
```

### 2. Configure AWS

```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region (ap-southeast-1)

# Verify
aws sts get-caller-identity
```

### 3. Update Configuration

```bash
# Update with your AWS account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Update ECR URL in deployment manifest
sed -i "s/311719319684/${AWS_ACCOUNT_ID}/g" app/deployment.yaml
```

### 4. Deploy Infrastructure

```bash
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Review plan
terraform plan -var-file=terraform.tfvars

# Apply (takes ~10-15 minutes)
terraform apply -var-file=terraform.tfvars
```

### 5. Configure kubectl

```bash
# Get kubeconfig
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name eks-demo-kartheepan-apse1-dev

# Verify
kubectl get nodes
```

### 6. Bootstrap Flux CD

```bash
# Set GitHub token
export GITHUB_TOKEN=<your-github-personal-access-token>

# Bootstrap Flux
flux bootstrap github \
  --owner=Kartheepan1991 \
  --repository=eks-setup-terraform \
  --branch=main \
  --path=flux \
  --personal

# Verify Flux
flux check
kubectl get pods -n flux-system
```

### 7. Deploy Application

```bash
# Flux automatically deploys from app/ directory
# Watch deployment
kubectl get deployments -w
kubectl get pods -l app=eks-demo-app -w

# Check status
kubectl get all
```

### 8. Test Application

```bash
# Port forward to test locally
kubectl port-forward svc/eks-demo-app 8080:80

# In another terminal
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/api/info
```

---

## 📚 Detailed Setup

### 1. Infrastructure (Terraform)

#### Initialize Backend (Optional - Remote State)

```bash
# Run setup script for S3 + DynamoDB backend
./scripts/setup-backend.sh

# Update backend.tf with your bucket name
```

#### Review Terraform Variables

**File**: `terraform/environments/dev/terraform.tfvars`

```hcl
project_name = "eks-demo-kartheepan-apse1"
environment  = "dev"
region       = "ap-southeast-1"

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-southeast-1a", "ap-southeast-1b"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

eks_version = "1.31"

node_groups = {
  general = {
    desired_size   = 2
    min_size       = 1
    max_size       = 4
    instance_types = ["t3.small"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 20
  }
}

enable_nat_gateway = true
```

#### Deploy Infrastructure

```bash
cd terraform/environments/dev

# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars -auto-approve
```

**Expected Output**:
- VPC with public/private subnets
- 2 NAT Gateways
- EKS cluster (control plane)
- Node group with 2 worker nodes
- IAM roles and security groups

#### Verify Deployment

```bash
# List EKS clusters
aws eks list-clusters --region ap-southeast-1

# Get cluster details
aws eks describe-cluster \
  --name eks-demo-kartheepan-apse1-dev \
  --region ap-southeast-1

# Configure kubectl
aws eks update-kubeconfig \
  --region ap-southeast-1 \
  --name eks-demo-kartheepan-apse1-dev

# Check nodes
kubectl get nodes -o wide
```

---

### 2. CI/CD (GitHub Actions)

#### Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add the following secrets:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AWS_ACCESS_KEY_ID` | IAM user access key | AWS Console → IAM → Users → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | IAM secret key | Generated when creating access key |

#### Create IAM User for CI/CD

```bash
# Create IAM policy
cat > ecr-cicd-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:CreateRepository",
        "ecr:DescribeRepositories",
        "ecr:ListImages"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create policy
aws iam create-policy \
  --policy-name EKS-CICD-ECR-Policy \
  --policy-document file://ecr-cicd-policy.json

# Create IAM user
aws iam create-user --user-name github-actions-cicd

# Attach policy
aws iam attach-user-policy \
  --user-name github-actions-cicd \
  --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/EKS-CICD-ECR-Policy

# Create access keys
aws iam create-access-key --user-name github-actions-cicd
```

#### Test Locally

```bash
cd sample-app

# Install dependencies
npm install

# Run tests
npm test

# Build Docker image
docker build -t eks-demo-app:local .

# Run locally
docker run -p 3000:3000 eks-demo-app:local

# Test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
```

#### Trigger Pipeline

```bash
# Make a change
echo "// CI/CD test" >> sample-app/server.js

# Commit and push to main branch
git add sample-app/
git commit -m "Trigger CI/CD pipeline"
git push origin main

# Watch GitHub Actions
# Go to: https://github.com/Kartheepan1991/eks-setup-terraform/actions
```

---

### 3. GitOps (Flux CD)

#### Install Flux CLI

```bash
# Linux/macOS
curl -s https://fluxcd.io/install.sh | sudo bash

# Verify installation
flux --version
```

#### Create GitHub Personal Access Token

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token (classic)"**
3. Select scopes:
   - `repo` (all)
   - `admin:repo_hook` (read/write)
4. Generate and copy token

#### Bootstrap Flux

```bash
# Export token
export GITHUB_TOKEN=<your-token>

# Bootstrap Flux
flux bootstrap github \
  --owner=Kartheepan1991 \
  --repository=eks-setup-terraform \
  --branch=main \
  --path=flux \
  --personal \
  --token-auth

# This will:
# 1. Install Flux components in flux-system namespace
# 2. Create deploy key in GitHub
# 3. Commit Flux manifests to your repo
# 4. Start watching for changes
```

#### Verify Flux Installation

```bash
# Check Flux components
flux check

# View all Flux resources
flux get all

# Check GitRepository
flux get sources git

# Check Kustomization
flux get kustomizations

# View Flux logs
kubectl logs -n flux-system deploy/source-controller -f
kubectl logs -n flux-system deploy/kustomization-controller -f
```

#### Flux Configuration

**File**: `flux/flux-bootstrap.yaml`

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
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

#### How Flux Works

1. **Watches**: Git repository every 1 minute for changes
2. **Syncs**: Pulls latest manifests from `app/` directory
3. **Applies**: Updates Kubernetes resources in cluster
4. **Reconciles**: Ensures cluster state matches Git state
5. **Prunes**: Removes resources deleted from Git

---

### 4. Application Deployment

#### Deploy Nginx Ingress Controller (Option 1 - Simplest)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

# Wait for LoadBalancer
kubectl get svc -n ingress-nginx ingress-nginx-controller -w
```

#### Deploy via Helm (Option 2 - Recommended)

```bash
# Add Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install nginx-ingress
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb"
```

#### Verify Application Deployment

```bash
# Check deployments
kubectl get deployments
kubectl describe deployment eks-demo-app

# Check pods
kubectl get pods -l app=eks-demo-app
kubectl logs -f deployment/eks-demo-app

# Check service
kubectl get svc eks-demo-app

# Check ingress
kubectl get ingress
```

#### Access Application

**Method 1: Port Forward (Local Testing)**

```bash
kubectl port-forward svc/eks-demo-app 8080:80

# Test
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/api/info
```

**Method 2: LoadBalancer (Production)**

```bash
# Get LoadBalancer URL
kubectl get svc -n ingress-nginx ingress-nginx-controller

# Access via LoadBalancer DNS
curl http://<load-balancer-dns>/
```

**Method 3: Update /etc/hosts (Local Development)**

```bash
# Get LoadBalancer IP
LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Add to /etc/hosts
echo "${LB_IP} eks-demo.local" | sudo tee -a /etc/hosts

# Access
curl http://eks-demo.local/
```

---

## ⚙️ Configuration

### Node Groups

Modify node group settings in `terraform/environments/dev/terraform.tfvars`:

```hcl
node_groups = {
  general = {
    desired_size   = 2          # Number of nodes to maintain
    min_size       = 1          # Minimum autoscaling size
    max_size       = 4          # Maximum autoscaling size
    instance_types = ["t3.small"]  # EC2 instance type
    capacity_type  = "ON_DEMAND"   # or "SPOT" for cost savings
    disk_size      = 20         # GB per node
  }
}
```

**Available Instance Types** (Free Tier / Low Cost):
- `t3.micro` (2 vCPU, 1GB RAM) - Free Tier eligible
- `t3.small` (2 vCPU, 2GB RAM) - ~$15/month
- `t3.medium` (2 vCPU, 4GB RAM) - ~$30/month

### Application Configuration

**Resource Limits**: `app/deployment.yaml`

```yaml
resources:
  requests:
    cpu: 100m      # Minimum CPU
    memory: 128Mi  # Minimum memory
  limits:
    cpu: 500m      # Maximum CPU
    memory: 512Mi  # Maximum memory
```

**Scaling**: Adjust replicas

```yaml
spec:
  replicas: 2  # Number of pod replicas
```

**Health Checks**:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 5
```

---

## 📊 Monitoring & Troubleshooting

### Check Pipeline Status

**GitHub Actions**:
```bash
# Visit in browser
https://github.com/Kartheepan1991/eks-setup-terraform/actions
```

**Flux CD**:
```bash
# Check Flux status
flux get all

# Check GitRepository sync
flux get sources git

# Watch Kustomization
flux get kustomizations --watch

# Force reconciliation
flux reconcile kustomization eks-demo-kustomization --with-source
```

### View Logs

```bash
# Application logs
kubectl logs -f deployment/eks-demo-app

# All pods with label
kubectl logs -l app=eks-demo-app --all-containers=true -f

# Flux logs
kubectl logs -n flux-system deploy/source-controller -f
kubectl logs -n flux-system deploy/kustomization-controller -f

# Nginx ingress logs
kubectl logs -n ingress-nginx deploy/ingress-nginx-controller -f
```

### Common Issues

#### Issue 1: Nodes Not Joining Cluster

**Symptoms**: Node group stuck in CREATE_FAILED

**Solution**:
```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name eks-demo-kartheepan-apse1-dev \
  --nodegroup-name eks-demo-kartheepan-apse1-dev-general

# Check EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:eks:cluster-name,Values=eks-demo-kartheepan-apse1-dev"

# Verify security groups allow egress
aws ec2 describe-security-groups --group-ids <sg-id>
```

#### Issue 2: Pods ImagePullBackOff

**Symptoms**: Pods fail to pull image from ECR

**Solution**:
```bash
# Check ECR repository exists
aws ecr describe-repositories --repository-names eks-demo-app

# Check image exists
aws ecr describe-images --repository-name eks-demo-app

# Verify pod events
kubectl describe pod <pod-name>

# Check deployment image URL
kubectl get deployment eks-demo-app -o yaml | grep image:
```

#### Issue 3: Flux Not Deploying

**Symptoms**: Changes pushed to Git but not applied to cluster

**Solution**:
```bash
# Check Flux can access GitHub
flux get sources git

# Check for errors in logs
kubectl logs -n flux-system deploy/kustomization-controller | tail -50

# Force reconciliation
flux reconcile source git eks-demo-repo
flux reconcile kustomization eks-demo-kustomization --with-source

# Check manifest syntax
kubectl apply --dry-run=client -f app/deployment.yaml
```

#### Issue 4: Application Not Accessible

**Symptoms**: Cannot access application via LoadBalancer or port-forward

**Solution**:
```bash
# Check pods are running
kubectl get pods -l app=eks-demo-app

# Check service endpoints
kubectl get endpoints eks-demo-app

# Check ingress
kubectl describe ingress eks-demo-app-ingress

# Test directly to pod
kubectl port-forward <pod-name> 8080:3000
curl http://localhost:8080/health

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>
```

### Rollback Deployment

```bash
# View rollout history
kubectl rollout history deployment/eks-demo-app

# Rollback to previous version
kubectl rollout undo deployment/eks-demo-app

# Rollback to specific revision
kubectl rollout undo deployment/eks-demo-app --to-revision=2

# Check rollout status
kubectl rollout status deployment/eks-demo-app
```

---

## 💰 Cost Management

### Cost Breakdown

| Resource | Cost | Notes |
|----------|------|-------|
| EKS Control Plane | ~$73/month | $0.10/hour, cannot be reduced |
| Worker Nodes (2 x t3.small) | ~$30/month | Can use spot instances for 70% savings |
| NAT Gateways (2) | ~$64/month | One per AZ for HA |
| Data Transfer | Variable | Minimal for dev/test |
| ECR Storage | ~$0.10/GB | Delete old images regularly |
| **Total** | **~$170-200/month** | Dev environment estimate |

### Cost Optimization Strategies

#### 1. Use Spot Instances

**Savings**: Up to 70% on worker nodes

```hcl
# In terraform.tfvars
node_groups = {
  general = {
    capacity_type  = "SPOT"  # Change from ON_DEMAND
    instance_types = ["t3.small", "t3a.small"]  # Multiple types
  }
}
```

#### 2. Single NAT Gateway (Non-Production)

**Savings**: ~$32/month

```hcl
# In terraform.tfvars
enable_nat_gateway     = true
single_nat_gateway     = true  # Add this line
```

⚠️ **Warning**: Reduces high availability

#### 3. Destroy When Not in Use

**Savings**: 100% when stopped

```bash
# Destroy all resources
cd terraform/environments/dev
terraform destroy -var-file=terraform.tfvars -auto-approve

# Recreate when needed (takes ~15 minutes)
terraform apply -var-file=terraform.tfvars -auto-approve
```

#### 4. Use Smaller Instances

```hcl
node_groups = {
  general = {
    instance_types = ["t3.micro"]  # Free tier eligible
    # Note: May not have enough resources for multiple apps
  }
}
```

#### 5. ECR Lifecycle Policy

```bash
# Create lifecycle policy to delete old images
cat > lifecycle-policy.json << 'EOF'
{
  "rules": [{
    "rulePriority": 1,
    "description": "Keep last 10 images",
    "selection": {
      "tagStatus": "any",
      "countType": "imageCountMoreThan",
      "countNumber": 10
    },
    "action": { "type": "expire" }
  }]
}
EOF

aws ecr put-lifecycle-policy \
  --repository-name eks-demo-app \
  --lifecycle-policy-text file://lifecycle-policy.json
```

#### 6. Set Budget Alerts

```bash
# Create budget alert for $200/month
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget.json

# budget.json
{
  "BudgetName": "EKS-Dev-Budget",
  "BudgetLimit": {
    "Amount": "200",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
```

### Daily Usage Pattern

**Recommendation for learning/demos**:

```bash
# Morning: Deploy cluster
terraform apply -var-file=terraform.tfvars -auto-approve

# Work/demo during the day
# ...

# Evening: Destroy cluster
terraform destroy -var-file=terraform.tfvars -auto-approve
```

**Cost**: ~$6-7/day vs ~$200/month

---

## 🎤 Interview Demo Guide

### 5-Minute Demo Script

```bash
# 1. Show Current State (30 seconds)
kubectl get pods -l app=eks-demo-app
kubectl port-forward svc/eks-demo-app 8080:80 &
curl http://localhost:8080/api/info

# 2. Make Code Change (1 minute)
cd sample-app
cat server.js
echo 'console.log("Interview demo!");' >> server.js

# 3. Commit and Push (30 seconds)
git add sample-app/server.js
git commit -m "Demo: Add logging for interview"
git push origin main

# 4. Show GitHub Actions (1 minute)
# Open browser: https://github.com/Kartheepan1991/eks-setup-terraform/actions
# Point out: Test → Build → Push → Update Manifest jobs

# 5. Show Flux Reconciliation (1 minute)
flux get kustomizations --watch
# Shows: Reconciling... → Applied

# 6. Watch Rolling Update (1 minute)
kubectl get pods -l app=eks-demo-app -w
# Shows: New pods starting, old pods terminating

# 7. Verify New Version (30 seconds)
curl http://localhost:8080/
# Point out updated version or changes
```

### Interview Talking Points

#### Architecture

- **"Built production-ready EKS infrastructure using Terraform modules"**
  - VPC with public/private subnets across 2 AZs
  - NAT gateways for private subnet internet access
  - Managed node groups with autoscaling
  - Security groups following least-privilege principle

#### CI/CD

- **"Implemented complete GitOps workflow with GitHub Actions and Flux CD"**
  - GitHub Actions handles CI: test, build, push to ECR
  - Flux CD handles CD: watches Git, applies to cluster
  - Total pipeline time: 5-6 minutes commit-to-production
  - Automated testing gates production deployments

#### Kubernetes

- **"Configured zero-downtime deployments with health probes"**
  - Rolling updates with maxUnavailable: 0
  - Liveness and readiness probes
  - Resource requests/limits for stability
  - Horizontal pod autoscaling capability

#### Security

- **"Followed container security best practices"**
  - Multi-stage Docker builds (reduced image size 70%)
  - Non-root containers (UID 1001)
  - ECR vulnerability scanning enabled
  - Security contexts on pods
  - IAM roles for service accounts (IRSA)

#### GitOps

- **"Git as single source of truth for infrastructure and applications"**
  - Infrastructure changes via Terraform
  - Application deployments via Flux
  - Audit trail through Git commits
  - Easy rollback with Git revert

### Key Metrics to Mention

- **Deployment Speed**: 5-6 minutes from commit to production
- **Uptime**: Zero-downtime deployments
- **Image Size**: 70% smaller with multi-stage builds
- **Cost**: Optimized to ~$170-200/month for dev
- **Recovery Time**: Flux auto-heals within 1 minute

### Questions to Expect

**Q: Why Flux instead of ArgoCD?**  
A: Flux is lightweight, GitOps-native, and integrates seamlessly with GitHub. It's pull-based (more secure), has automatic image updates, and is CNCF graduated project.

**Q: How do you handle secrets?**  
A: Currently using GitHub Secrets for CI/CD. For production, I'd use AWS Secrets Manager or Sealed Secrets with Flux, plus IRSA for pod-level AWS access.

**Q: What about monitoring?**  
A: This demo focuses on infrastructure and CI/CD. Next steps would be Prometheus/Grafana for metrics, EFK stack for logging, and Jaeger for tracing.

**Q: How do you handle multiple environments?**  
A: Terraform workspace separation (dev/staging/prod), separate tfvars files, and Flux Kustomize overlays for environment-specific configs.

**Q: What's your disaster recovery strategy?**  
A: Terraform state in S3 with versioning, Git history for rollbacks, EKS automated backups, and multi-AZ deployment for HA.

---

## 🧹 Cleanup

### Destroy All Resources

```bash
# 1. Delete Kubernetes resources first (optional)
kubectl delete -f app/

# 2. Uninstall Flux (optional)
flux uninstall --silent

# 3. Destroy Terraform infrastructure
cd terraform/environments/dev
terraform destroy -var-file=terraform.tfvars -auto-approve

# This removes:
# - EKS cluster and node groups
# - VPC, subnets, NAT gateways
# - Security groups
# - IAM roles and policies
```

### Delete ECR Repository

```bash
# Delete all images and repository
aws ecr delete-repository \
  --repository-name eks-demo-app \
  --force \
  --region ap-southeast-1
```

### Verify Cleanup

```bash
# Check EKS clusters
aws eks list-clusters --region ap-southeast-1

# Check VPCs
aws ec2 describe-vpcs --region ap-southeast-1 | grep eks-demo

# Check ECR repositories
aws ecr describe-repositories --region ap-southeast-1
```

### Estimated Time

- Kubernetes resource deletion: ~2 minutes
- Terraform destroy: ~10-15 minutes
- Total cleanup: ~15-20 minutes

---

## 🤝 Contributing

This project is designed for learning and demonstration. Feel free to:

- Fork and experiment
- Add features (monitoring, service mesh, etc.)
- Improve documentation
- Share feedback via issues

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👤 Author

**Kartheepan**

- GitHub: [@Kartheepan1991](https://github.com/Kartheepan1991)
- Repository: [eks-setup-terraform](https://github.com/Kartheepan1991/eks-setup-terraform)

---

## 🔗 Additional Resources

### Documentation
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Flux CD Documentation](https://fluxcd.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Tutorials
- [EKS Workshop](https://www.eksworkshop.com/)
- [Terraform Tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [GitOps with Flux](https://fluxcd.io/flux/get-started/)

---

**Happy Learning! 🚀**

*Last Updated: November 2025*

---

## Quick Command Reference

```bash
# Terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform destroy -var-file=terraform.tfvars

# kubectl
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl logs -f <pod-name>
kubectl describe pod <pod-name>

# Flux
flux check
flux get all
flux get kustomizations --watch
flux reconcile kustomization <name> --with-source

# AWS
aws eks update-kubeconfig --region ap-southeast-1 --name <cluster-name>
aws eks list-clusters
aws ecr describe-repositories

# Docker (Local)
docker build -t eks-demo-app:local sample-app/
docker run -p 3000:3000 eks-demo-app:local
curl http://localhost:3000/health
```

---

*This project demonstrates a complete end-to-end DevOps workflow suitable for production environments, interviews, and portfolio showcases.*

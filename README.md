# AWS EKS Infrastructure with Terraform & GitOps

Production-ready AWS EKS cluster with Terraform IaC, Flux CD GitOps, and automated CI/CD pipeline.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-blue)](https://kubernetes.io/)

---

## 🎯 Overview

End-to-end DevOps project demonstrating Infrastructure as Code, containerization, CI/CD automation, and GitOps deployment on AWS EKS.

**Tech Stack:** Terraform | AWS EKS | Kubernetes | Flux CD | GitHub Actions | Docker | Node.js

**Key Features:**
- Modular Terraform infrastructure (VPC, EKS, IAM)
- Automated CI/CD pipeline with testing and container scanning
- GitOps deployment using Flux CD
- Zero-downtime rolling updates
- Multi-AZ high availability

---

## 🏗️ Architecture

```
┌───────────────────────────────────────────────────────────────────┐
│                     AWS Cloud (ap-southeast-1)                    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ VPC (10.0.0.0/16)                                           │ │
│  │                                                             │ │
│  │  ┌──────────────┐              ┌──────────────┐            │ │
│  │  │ Public A     │              │ Public B     │            │ │
│  │  │ NAT Gateway  │              │ NAT Gateway  │            │ │
│  │  └──────┬───────┘              └──────┬───────┘            │ │
│  │         │                             │                    │ │
│  │  ┌──────▼───────┐              ┌──────▼───────┐            │ │
│  │  │ Private A    │              │ Private B    │            │ │
│  │  │              │              │              │            │ │
│  │  │ ┌──────────┐ │              │ ┌──────────┐ │            │ │
│  │  │ │EKS Worker│ │              │ │EKS Worker│ │            │ │
│  │  │ │t3.small  │ │              │ │t3.small  │ │            │ │
│  │  │ └──────────┘ │              │ └──────────┘ │            │ │
│  │  └──────────────┘              └──────────────┘            │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐  │ │
│  │  │     EKS Control Plane (v1.31) - AWS Managed          │  │ │
│  │  └──────────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘

                            CI/CD Pipeline
┌──────────┐   ┌──────────────┐   ┌─────────┐   ┌──────────┐
│  GitHub  │──▶│GitHub Actions│──▶│ AWS ECR │◀─▶│ Flux CD  │
│  (Code)  │   │(Test & Build)│   │(Images) │   │(GitOps)  │
└──────────┘   └──────────────┘   └─────────┘   └────┬─────┘
                                                      │
                                                      ▼
                                              ┌──────────────┐
                                              │ EKS Cluster  │
                                              │ (Production) │
                                              └──────────────┘
```

**Deployment Flow:**
1. Developer pushes code → GitHub
2. GitHub Actions → Test → Build → Push to ECR → Update manifest
3. Flux CD → Detects change → Deploys to EKS (Rolling Update)
4. Live in ~5-6 minutes with zero downtime

---

## 📁 Project Structure

```
eks-terraform-project/
├── terraform/
│   ├── modules/
│   │   ├── vpc/              # VPC, subnets, NAT, IGW
│   │   └── eks/              # EKS cluster, nodes, IAM
│   └── environments/dev/     # Environment config
│
├── sample-app/               # Node.js application
│   ├── server.js
│   ├── Dockerfile
│   └── server.test.js
│
├── app/                      # K8s manifests (Flux deploys)
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── flux/                     # GitOps configuration
│   └── flux-bootstrap.yaml
│
└── .github/workflows/
    └── ci-cd.yml             # CI/CD pipeline
```

---

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Flux CLI
- GitHub account

### 1. Deploy Infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply -auto-approve
```

### 2. Configure kubectl

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev
kubectl get nodes
```

### 3. Setup GitHub Secrets

In GitHub repo: `Settings → Secrets and variables → Actions`

Add:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`: `ap-southeast-1`
- `EKS_CLUSTER_NAME`: `eks-demo-kartheepan-apse1-dev`
- `ECR_REPOSITORY`: `eks-demo-app`

### 4. Bootstrap Flux CD

```bash
export GITHUB_TOKEN=<your-github-token>

flux bootstrap github \
  --owner=Kartheepan1991 \
  --repository=eks-setup-terraform \
  --branch=main \
  --path=flux \
  --personal

# Verify
flux check
kubectl get pods -n flux-system
```

### 5. Deploy Application

Flux automatically deploys from `app/` directory.

```bash
# Watch deployment
kubectl get deployments -w

# Test application
kubectl port-forward svc/eks-demo-app 8080:80
curl http://localhost:8080/health
```

---

## ⚙️ Configuration

### Terraform Variables

**File:** `terraform/environments/dev/terraform.tfvars`

```hcl
project_name       = "eks-demo-kartheepan-apse1"
environment        = "dev"
region             = "ap-southeast-1"
vpc_cidr           = "10.0.0.0/16"
cluster_version    = "1.31"
enable_nat_gateway = true

node_groups = {
  general = {
    instance_types = ["t3.small"]
    desired_size   = 1
    min_size       = 1
    max_size       = 3
    capacity_type  = "ON_DEMAND"  # or "SPOT"
    disk_size      = 20
  }
}
```

### Cost Optimization

**Monthly Cost Estimate:**
- EKS Control Plane: ~$73
- Worker Nodes (2x t3.small): ~$30
- NAT Gateways (2x): ~$64
- **Total: ~$175/month**

**To Reduce Costs:**
1. Set `enable_nat_gateway = false` → Save $64/month
2. Use `capacity_type = "SPOT"` → Save ~70% on nodes
3. Scale down: `desired_size = 0`
4. Destroy when not in use: `terraform destroy`

---

## 🔍 Troubleshooting

### View Logs

```bash
# Application logs
kubectl logs -f deployment/eks-demo-app

# Flux logs
kubectl logs -n flux-system deploy/kustomization-controller -f

# Check pod status
kubectl describe pod <pod-name>
```

### Common Issues

**Nodes not joining cluster:**
```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```

**ImagePullBackOff:**
```bash
aws ecr describe-repositories --repository-names eks-demo-app
kubectl describe pod <pod-name>
```

**Flux not syncing:**
```bash
flux get sources git
flux reconcile kustomization eks-demo-kustomization --with-source
```

---

## 🧹 Cleanup

```bash
# Destroy infrastructure
cd terraform/environments/dev
terraform destroy -auto-approve

# Delete ECR repository
aws ecr delete-repository --repository-name eks-demo-app --force
```

---

## 📖 What You've Built

✅ **Infrastructure as Code:** Modular Terraform (VPC, EKS, IAM)  
✅ **Container Orchestration:** Kubernetes with health checks  
✅ **CI/CD Automation:** GitHub Actions pipeline  
✅ **GitOps:** Flux CD declarative deployment  
✅ **Production Practices:** Rolling updates, resource limits, security  
✅ **AWS Services:** EKS, ECR, VPC, IAM, CloudWatch

**Perfect for:** DevOps interviews, portfolio, learning Kubernetes/AWS

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 👤 Author

**Kartheepan**  
GitHub: [@Kartheepan1991](https://github.com/Kartheepan1991)  
Repository: [eks-setup-terraform](https://github.com/Kartheepan1991/eks-setup-terraform)

---

## 🔗 Resources

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Flux CD Documentation](https://fluxcd.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

**Last Updated:** November 2025

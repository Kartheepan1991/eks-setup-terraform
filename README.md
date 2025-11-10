# AWS EKS Infrastructure with Terraform & GitOps

Complete end-to-end DevOps pipeline: Infrastructure as Code → CI/CD → GitOps → Production Deployment

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-blue)](https://kubernetes.io/)

---

## 🎯 What This Project Demonstrates

**Complete DevOps pipeline from code to production:**

✅ **Infrastructure as Code** - Terraform modules for VPC, EKS, IAM  
✅ **Containerization** - Multi-stage Docker builds with security best practices  
✅ **CI/CD Automation** - GitHub Actions (test → build → push → deploy)  
✅ **GitOps Deployment** - Flux CD syncing from Git  
✅ **Production Features** - Zero-downtime rolling updates, health checks, auto-scaling  
✅ **External Access** - NGINX Ingress with AWS Network LoadBalancer  

**Tech Stack:** Terraform | AWS EKS | Kubernetes | Flux CD | GitHub Actions | Docker | NGINX | Node.js

---

## 🏗️ Architecture

### Infrastructure Layer
```
┌─────────────────────────────────────────────────────────────┐
│                  AWS Cloud (ap-southeast-1)                 │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ VPC (10.0.0.0/16)                                      │ │
│  │                                                         │ │
│  │  Public Subnets (2 AZs)         Private Subnets (2 AZs)│ │
│  │  ├─ NAT Gateway A                ├─ EKS Worker Nodes   │ │
│  │  └─ NAT Gateway B                └─ t3.small instances │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │ EKS Control Plane (v1.31) - Managed by AWS       │  │ │
│  │  └──────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### CI/CD Pipeline Flow
```
Developer Commits Code
        ↓
GitHub Repository (feature branch)
        ↓
GitHub Actions Workflow Triggered
        ↓
    ┌───────────────────────────────┐
    │ 1. Run Tests (Jest)           │
    │ 2. Build Docker Image         │
    │ 3. Push to Amazon ECR         │
    │ 4. Update K8s Manifest (Git)  │
    └───────────────────────────────┘
        ↓
Flux CD Detects Manifest Change (1min sync)
        ↓
Pulls New Image from ECR
        ↓
Rolling Update in EKS (Zero Downtime)
        ↓
Application Live via NGINX Ingress + AWS LoadBalancer
```

### Traffic Flow
```
Internet
   ↓
AWS Network LoadBalancer
   ↓
NGINX Ingress Controller
   ↓
Kubernetes Service
   ↓
Application Pods (2 replicas)
```
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


---

## 📁 Project Structure

```
eks-terraform-project/
├── terraform/environments/dev/
│   ├── main.tf              # Calls VPC + EKS modules
│   ├── terraform.tfvars     # Configuration values
│   └── variables.tf
│
├── sample-app/              # Node.js application source
│   ├── server.js
│   ├── Dockerfile           # Multi-stage build
│   └── server.test.js       # Jest tests
│
├── app/                     # Kubernetes manifests
│   ├── deployment.yaml      # App deployment
│   ├── service.yaml         # ClusterIP service
│   └── ingress.yaml         # NGINX ingress
│
├── flux/                    # Flux CD configuration
│   ├── flux-bootstrap.yaml  # GitOps setup
│   └── nginx-ingress-helmrelease.yaml  # NGINX via Helm
│
└── .github/workflows/
    ├── ci-cd.yml            # CI/CD pipeline
    └── flux-bootstrap.yaml  # Flux bootstrap workflow
```

---

## � Complete Deployment Steps

### Step 1: Deploy EKS Infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply -auto-approve
```

**Creates:**
- VPC with public/private subnets across 2 AZs
- NAT Gateways for private subnet internet access
- EKS cluster (v1.31) with managed control plane
- EKS node group (t3.small, min=1, max=3)
- IAM roles and security groups

**Time:** ~15 minutes

### Step 2: Configure kubectl

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name eks-demo-kartheepan-apse1-dev
kubectl get nodes
```

### Step 3: Setup GitHub Secrets

Go to: `GitHub repo → Settings → Secrets and variables → Actions`

Add these secrets:
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- `AWS_REGION` - `ap-southeast-1`
- `EKS_CLUSTER_NAME` - `eks-demo-kartheepan-apse1-dev`
- `ECR_REPOSITORY` - `eks-demo-app`
- `FLUX_GITHUB_TOKEN` - GitHub Personal Access Token (with `repo` + `workflow` scopes)

### Step 4: Bootstrap Flux CD

**Via GitHub Actions Workflow:**

1. Go to: `Actions → Flux Bootstrap to EKS`
2. Click "Run workflow"
3. Select your branch
4. Wait ~3-5 minutes

**Or manually:**
```bash
export GITHUB_TOKEN=<your-github-token>

flux bootstrap github \
  --owner=Kartheepan1991 \
  --repository=eks-setup-terraform \
  --branch=feature/eks-infrastructure-setup \
  --path=./flux \
  --personal
```

**Verify:**
```bash
flux check
kubectl get pods -n flux-system
```

### Step 5: Trigger CI/CD Pipeline

Make a change to trigger the pipeline:

```bash
cd sample-app
echo "// Trigger build" >> server.js
git add .
git commit -m "Trigger CI/CD pipeline"
git push
```

**Pipeline runs automatically:**
1. ✅ Run tests (Jest)
2. ✅ Build Docker image
3. ✅ Push to Amazon ECR
4. ✅ Update deployment.yaml with new image tag
5. ✅ Flux detects change and deploys

**Time:** ~3-5 minutes

### Step 6: Install NGINX Ingress (Optional)

Flux automatically deploys NGINX Ingress from `flux/nginx-ingress-helmrelease.yaml`

**Or manually:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml
```

**Wait for LoadBalancer:**
```bash
kubectl get svc -n ingress-nginx
```

### Step 7: Access Your Application

**Get LoadBalancer URL:**
```bash
kubectl get ingress eks-demo-app-ingress
```

**Test in browser:**
```
http://<loadbalancer-url>/
```

**Or via kubectl port-forward:**
```bash
kubectl port-forward svc/eks-demo-app 8080:80
curl http://localhost:8080/
```

---

## ⚙️ Configuration

### Terraform Variables

**File:** `terraform/environments/dev/terraform.tfvars`

```hcl
project_name       = "eks-demo-kartheepan-apse1"
region             = "ap-southeast-1"
cluster_version    = "1.31"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]

node_groups = {
  general = {
    instance_types = ["t3.small"]
    desired_size   = 1
    min_size       = 1
    max_size       = 3
    capacity_type  = "ON_DEMAND"  # or "SPOT" for cost savings
  }
}
```

### Cost Optimization

**Monthly Cost Estimate:**
- EKS Control Plane: ~$73
- Worker Nodes (1x t3.small): ~$15
- NAT Gateways (2x): ~$64
- **Total: ~$155/month**

**To reduce costs:**
- Set `capacity_type = "SPOT"` (save ~70%)
- Scale to 0 when not in use: `desired_size = 0`
- Use single NAT gateway (reduces HA)
- Destroy infrastructure: `terraform destroy`

---

## � Monitoring & Verification

### Check Application Status

```bash
# Pods
kubectl get pods -l app=eks-demo-app

# Service
kubectl get svc eks-demo-app

# Ingress
kubectl get ingress

# Logs
kubectl logs -f deployment/eks-demo-app
```

### Check Flux Sync Status

```bash
# Overall status
flux get all

# Git repository sync
flux get sources git

# Kustomizations
flux get kustomizations

# Force reconciliation
flux reconcile kustomization eks-demo-kustomization --with-source
```

### Application Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check
- `GET /api/info` - Application metadata

---

## 🧹 Cleanup

### Destroy Everything

```bash
# Delete Flux
flux uninstall

# Destroy EKS cluster and infrastructure
cd terraform/environments/dev
terraform destroy -auto-approve

# Delete ECR repository
aws ecr delete-repository --repository-name eks-demo-app --force
```

**Important:** This stops all AWS charges.

---

## 📖 What You've Built

✅ **Production-grade EKS infrastructure** with Terraform modules  
✅ **Complete CI/CD pipeline** with automated testing and deployment  
✅ **GitOps workflow** with Flux CD  
✅ **Containerized application** with multi-stage Docker builds  
✅ **External access** via NGINX Ingress and AWS LoadBalancer  
✅ **Zero-downtime deployments** with rolling updates  
✅ **Production features** - Health checks, resource limits, autoscaling  

**Perfect for:** DevOps portfolios, interviews, learning Kubernetes/AWS

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

## 👤 Author

**Kartheepan**  
GitHub: [@Kartheepan1991](https://github.com/Kartheepan1991)

---

**Last Updated:** November 2025

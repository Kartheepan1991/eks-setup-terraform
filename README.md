# EKS Terraform Project

This project creates a production-ready Amazon EKS (Elastic Kubernetes Service) cluster using Terraform modules with proper state management. It's designed for learning Kubernetes for CKA exam preparation while following best practices for cloud engineering.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Public AZ-A   │  │   Public AZ-B   │  │ Public AZ-C  │ │
│  │  10.0.101.0/24  │  │  10.0.102.0/24  │  │10.0.103.0/24 │ │
│  │                 │  │                 │  │              │ │
│  │  ┌──────────┐   │  │  ┌──────────┐   │  │ ┌──────────┐ │ │
│  │  │    NAT   │   │  │  │    NAT   │   │  │ │    NAT   │ │ │
│  │  │ Gateway  │   │  │  │ Gateway  │   │  │ │ Gateway  │ │ │
│  │  └──────────┘   │  │  └──────────┘   │  │ └──────────┘ │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Private AZ-A   │  │  Private AZ-B   │  │ Private AZ-C │ │
│  │  10.0.1.0/24    │  │  10.0.2.0/24    │  │ 10.0.3.0/24  │ │
│  │                 │  │                 │  │              │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │┌─────────────┐│ │
│  │ │EKS Worker   │ │  │ │EKS Worker   │ │  ││EKS Worker   ││ │
│  │ │Nodes        │ │  │ │Nodes        │ │  ││Nodes        ││ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │└─────────────┘│ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                    │
                    ▼
              ┌─────────────┐
              │ EKS Control │
              │    Plane    │
              │  (Managed)  │
              └─────────────┘
```

## 📁 Project Structure

```
eks-terraform-project/
├── backend.tf                    # S3 backend configuration
├── scripts/
│   └── setup-backend.sh         # Script to create S3 bucket and DynamoDB table
├── modules/
│   ├── vpc/                     # VPC module for networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks/                     # EKS module for cluster creation
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   └── dev/                     # Development environment
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── scripts/
    ├── setup-backend.sh         # Backend infrastructure setup
    ├── deploy.sh               # Deployment script
    └── cleanup.sh              # Cleanup script
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **kubectl** installed for cluster management

### Step 1: Setup Backend Infrastructure

```bash
# Run the backend setup script
./scripts/setup-backend.sh

# Update backend.tf with the output values
```

### Step 2: Configure Backend

Update `backend.tf` with the S3 bucket name and DynamoDB table from the setup script output.

### Step 3: Deploy the Infrastructure

```bash
# Navigate to the dev environment
cd environments/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### Step 4: Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name eks-learning-dev

# Verify cluster access
kubectl get nodes
```

## 🧩 Modules Explained

### VPC Module (`modules/vpc/`)

Creates a production-ready VPC with:
- **Public subnets** for load balancers and NAT gateways
- **Private subnets** for EKS worker nodes
- **NAT gateways** for outbound internet access from private subnets
- **VPC endpoints** for S3 to reduce data transfer costs
- **Proper tagging** for EKS resource discovery

**Key Features:**
- Multi-AZ deployment for high availability
- Automatic subnet CIDR calculation
- EKS-specific tags for load balancer subnet discovery
- VPC endpoints for cost optimization

### EKS Module (`modules/eks/`)

Creates a secure EKS cluster with:
- **Managed node groups** with auto-scaling
- **OIDC identity provider** for IRSA (IAM Roles for Service Accounts)
- **CloudWatch logging** for cluster audit and API logs
- **Security groups** with minimal required access
- **Multiple node groups** (on-demand and spot instances)

**Key Features:**
- Production-ready IAM roles and policies
- Cluster autoscaler support
- Both on-demand and spot instance node groups
- Comprehensive logging and monitoring

## 🔧 Configuration Options

### Node Groups

The project creates two node groups by default:

1. **General Node Group**
   - On-demand instances (t3.medium)
   - 2 desired, 1-4 min-max capacity
   - For production workloads

2. **Spot Node Group**
   - Spot instances (t3.medium, t3.large)
   - 1 desired, 0-3 min-max capacity
   - For cost-effective non-critical workloads
   - Includes taint for spot instances

### Customization

Modify `environments/dev/variables.tf` to customize:
- Instance types and sizes
- Node group configurations
- Network CIDR blocks
- Kubernetes version
- Resource tags

## 🛡️ Security Best Practices

1. **Network Security**
   - Private subnets for worker nodes
   - Security groups with minimal access
   - VPC endpoints to reduce internet traffic

2. **IAM Security**
   - Least privilege IAM roles
   - OIDC provider for service account integration
   - No hardcoded credentials

3. **Cluster Security**
   - Private API endpoint option
   - Audit logging enabled
   - Encryption at rest and in transit

## 📊 State Management

This project uses Terraform remote state with:
- **S3 bucket** for state storage with versioning and encryption
- **DynamoDB table** for state locking to prevent concurrent modifications
- **Backend encryption** for security

## 🎯 Learning Objectives for CKA

This setup helps you practice:

1. **Cluster Management**
   - Understanding EKS architecture
   - Node management and scaling
   - Cluster networking

2. **Networking**
   - Pod-to-pod communication
   - Service networking
   - Ingress controllers

3. **Security**
   - RBAC configuration
   - Service accounts and IRSA
   - Network policies

4. **Troubleshooting**
   - Cluster debugging
   - Log analysis
   - Performance monitoring

## 📝 Common kubectl Commands

```bash
# Cluster information
kubectl cluster-info
kubectl get nodes
kubectl describe nodes

# Workload management
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
kubectl get deployments --all-namespaces

# Troubleshooting
kubectl logs <pod-name>
kubectl describe pod <pod-name>
kubectl top nodes
kubectl top pods
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
cd environments/dev
terraform destroy

# Clean up backend infrastructure (optional)
./scripts/cleanup.sh
```

## 📚 Additional Resources

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [CKA Exam Curriculum](https://github.com/cncf/curriculum)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Contributing

This project is designed for learning. Feel free to:
- Experiment with different configurations
- Add additional node groups
- Implement monitoring solutions
- Practice with different Kubernetes workloads

---

**Happy Learning! 🚀**
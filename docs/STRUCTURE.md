# Repository Structure Guide

This document explains the folder structure and purpose of each directory in this demo project.

## Directory Structure

```
/
├── terraform/                    # Infrastructure as Code
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── eks/                  # EKS cluster module
│   │   │   ├── main.tf           # EKS cluster, IAM, OIDC provider
│   │   │   ├── variables.tf     # Module input variables
│   │   │   └── outputs.tf       # Module outputs
│   │   └── vpc/                  # VPC networking module
│   │       ├── main.tf           # VPC, subnets, route tables, NAT
│   │       ├── variables.tf     # Module input variables
│   │       └── outputs.tf       # Module outputs
│   └── environments/             # Environment-specific configurations
│       └── dev/                  # Development environment
│           ├── main.tf           # Calls modules with dev-specific values
│           ├── variables.tf     # Environment variables
│           ├── terraform.tfvars # Variable values (tracked in git)
│           └── outputs.tf       # Environment outputs
├── flux/                         # Flux CD manifests for GitOps automation
├── helm-charts/                  # Helm charts for deploying applications and services
├── app/                          # Source code for the sample application
├── scripts/                      # Shell scripts for setup, deployment, and cleanup
├── docs/                         # Documentation, architecture diagrams, and guides
└── .github/workflows/            # CI/CD pipelines (Terraform validation, Flux bootstrap)
```

## Module Design

- **terraform/modules/eks**: Creates EKS cluster, IAM roles, security groups, and OIDC provider
- **terraform/modules/vpc**: Creates VPC, public/private subnets, internet gateway, NAT gateway, and route tables
- **terraform/environments/dev**: Calls the modules with development-specific configuration

## Best Practices

- Keep all related code in one repo for clarity and reproducibility
- Modularize Terraform code for reusability across environments
- Track non-sensitive configuration files (like terraform.tfvars) in git for CI/CD
- Store secrets in GitHub Secrets or AWS Secrets Manager, never in code
- Document every step for reviewers and clients

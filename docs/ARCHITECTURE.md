# Architecture Overview

## Components
- **Terraform**: Provisions AWS EKS, VPC, IAM, and networking.
- **Flux CD**: Enables GitOps for continuous delivery.
- **Helm**: Manages application deployments as charts.
- **Sample App**: Demonstrates real-world deployment.

## Flow
1. Terraform provisions the cluster and networking.
2. Flux CD is installed and bootstrapped.
3. Helm charts are deployed via Flux.
4. Sample app runs in EKS, managed by GitOps.

## Diagrams
- [Add diagrams here as needed]

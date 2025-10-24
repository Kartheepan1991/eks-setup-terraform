# Repository Structure Guide

This document explains the folder structure and purpose of each directory in this demo project.

- `terraform/`: Infrastructure as Code for AWS EKS, VPC, IAM, etc.
- `flux/`: Flux CD manifests for GitOps automation.
- `helm-charts/`: Helm charts for deploying applications and services.
- `app/`: Source code for the sample application.
- `scripts/`: Shell scripts for setup, deployment, and cleanup.
- `docs/`: Documentation, architecture diagrams, and guides.

## Best Practices
- Keep all related code in one repo for clarity and reproducibility.
- Modularize as the project grows, but start with a single root for demos.
- Document every step for reviewers and clients.

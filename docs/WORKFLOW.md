# End-to-End Workflow

## 1. Provision Infrastructure
- Use Terraform (`terraform/`) to create EKS, VPC, IAM roles, and networking.

## 2. Bootstrap GitOps
- Install Flux CD using manifests in `flux/`.
- Connect Flux to this repo for automated deployments.

## 3. Deploy Applications
- Use Helm charts in `helm-charts/` to deploy the sample app from `app/`.
- Manage releases and rollbacks via Helm and Flux.

## 4. Automation & Cleanup
- Use scripts in `scripts/` for setup, deployment, and resource cleanup.

## 5. Documentation
- Refer to `docs/` and `README.md` for architecture, cost management, and usage.

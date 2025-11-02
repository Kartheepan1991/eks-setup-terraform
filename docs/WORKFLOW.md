# End-to-End Workflow

## 1. Provision Infrastructure

### Using Terraform Modules

Navigate to the development environment and run Terraform:

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

This creates:
- VPC with public and private subnets across 2 availability zones
- EKS cluster with managed node groups
- IAM roles and policies for EKS
- Security groups
- OIDC provider for service accounts

**Time estimate**: 10-15 minutes for cluster creation

### Configure kubectl

After the cluster is created, configure kubectl to connect:

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name eks-learning-dev
kubectl get nodes
```

## 2. Bootstrap GitOps
- Install Flux CD using manifests in `flux/`.
- Connect Flux to this repo for automated deployments.

## 3. Deploy Applications
- Use Helm charts in `helm-charts/` to deploy the sample app from `app/`.
- Manage releases and rollbacks via Helm and Flux.

## 4. Automation & Cleanup

### Using Automation Scripts

Use scripts in `scripts/` for deployment and cleanup tasks.

### Destroying Resources

When you're done with the cluster, destroy all resources to avoid ongoing costs:

```bash
cd terraform/environments/dev
terraform destroy
```

**Important**: Always destroy resources when not in use to minimize AWS costs.

## 5. CI/CD Integration

### Terraform CI Workflow

- Workflow automatically validates Terraform on pull requests
- Runs in GitHub Actions with 15-minute timeout
- Uses secrets for AWS credentials (never stored in code)
- Only triggers on PR events to save Actions minutes

### Configuration Files

- `terraform.tfvars` is tracked in git (contains only non-sensitive config)
- AWS credentials are stored as GitHub Secrets
- Workflow uses `-input=false` to prevent interactive prompts

## 5. Documentation
- Refer to `docs/` and `README.md` for architecture, cost management, and usage.

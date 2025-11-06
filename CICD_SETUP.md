# CI/CD Pipeline Setup Guide

## Quick Start

### Prerequisites
- AWS Account with ECR access
- GitHub repository
- EKS cluster running
- Flux CD installed

### Step 1: Configure AWS Credentials

Create an IAM user for CI/CD:

```bash
# Create IAM policy
aws iam create-policy \
  --policy-name EKS-CICD-Policy \
  --policy-document file://iam-policy.json

# Create IAM user
aws iam create-user --user-name github-actions-cicd

# Attach policy to user
aws iam attach-user-policy \
  --user-name github-actions-cicd \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT:policy/EKS-CICD-Policy

# Create access keys
aws iam create-access-key --user-name github-actions-cicd
```

**IAM Policy** (`iam-policy.json`):
```json
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
```

### Step 2: Add GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID`: From Step 1
- `AWS_SECRET_ACCESS_KEY`: From Step 1

### Step 3: Update ECR Registry URL

Update the image URL in `app/deployment.yaml` with your AWS account ID:

```bash
# Get your AWS account ID
aws sts get-caller-identity --query Account --output text

# Update deployment.yaml
sed -i 's/311719319684/<YOUR_ACCOUNT_ID>/g' app/deployment.yaml
```

### Step 4: Test Locally

```bash
# Build application
cd sample-app
npm install
npm test

# Build Docker image
docker build -t eks-demo-app:local .

# Run locally
docker run -p 3000:3000 eks-demo-app:local

# Test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
```

### Step 5: Deploy to EKS

```bash
# Ensure cluster is running
kubectl get nodes

# Install Flux (if not already installed)
flux bootstrap github \
  --owner=Kartheepan1991 \
  --repository=eks-setup-terraform \
  --branch=main \
  --path=flux \
  --personal

# Verify Flux is running
flux check
kubectl get pods -n flux-system
```

### Step 6: Push Code to Trigger Pipeline

```bash
# Make a change to the application
echo "// Test change" >> sample-app/server.js

# Commit and push
git add .
git commit -m "Trigger CI/CD pipeline"
git push origin main

# Watch GitHub Actions
# Go to: https://github.com/Kartheepan1991/eks-setup-terraform/actions

# Watch Flux reconciliation
flux get sources git
flux get kustomizations --watch

# Watch deployment
kubectl get deployments -w
kubectl get pods -w
```

### Step 7: Verify Deployment

```bash
# Check deployment status
kubectl get deployment eks-demo-app
kubectl get pods -l app=eks-demo-app

# Check service
kubectl get svc eks-demo-app

# Test application
kubectl port-forward svc/eks-demo-app 8080:80

# In another terminal
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/api/info
```

---

## Pipeline Workflow

### 1. Developer Pushes Code
```bash
git add sample-app/
git commit -m "Add new feature"
git push origin main
```

### 2. GitHub Actions Runs (4-5 minutes)
- ✅ Tests pass
- ✅ Docker image builds
- ✅ Image pushed to ECR
- ✅ Manifest updated

### 3. Flux Detects Change (~1 minute)
- ✅ Pulls new image
- ✅ Rolling update
- ✅ Health checks pass

### 4. Application Updated (Total: ~5-6 minutes)
```bash
kubectl get pods
# NAME                             READY   STATUS    RESTARTS   AGE
# eks-demo-app-xyz123-abc          1/1     Running   0          30s
# eks-demo-app-xyz123-def          1/1     Running   0          45s
```

---

## Monitoring

### GitHub Actions
- View: https://github.com/Kartheepan1991/eks-setup-terraform/actions
- Logs available for each step
- Email notifications on failure

### Flux CD
```bash
# Check reconciliation status
flux get sources git
flux get kustomizations

# View logs
kubectl logs -n flux-system deploy/source-controller -f
kubectl logs -n flux-system deploy/kustomization-controller -f
```

### Application Logs
```bash
# Stream application logs
kubectl logs -f deployment/eks-demo-app

# Last 100 lines
kubectl logs deployment/eks-demo-app --tail=100

# Logs from all pods
kubectl logs -l app=eks-demo-app --all-containers=true -f
```

---

## Troubleshooting

### Pipeline Not Triggering
```bash
# Check GitHub Actions is enabled
# Repository → Settings → Actions → Allow all actions

# Verify workflow file syntax
cd .github/workflows
cat ci-cd.yml
```

### Image Push Fails
```bash
# Test AWS credentials locally
aws ecr get-login-password --region ap-southeast-1

# Create ECR repository manually if needed
aws ecr create-repository \
  --repository-name eks-demo-app \
  --image-scanning-configuration scanOnPush=true \
  --region ap-southeast-1
```

### Flux Not Deploying
```bash
# Check Flux can access repository
flux get sources git

# Reconcile manually
flux reconcile source git flux-system
flux reconcile kustomization flux-system --with-source

# Check Flux logs for errors
kubectl logs -n flux-system deploy/kustomization-controller | tail -50
```

### Pods ImagePullBackOff
```bash
# Check image exists in ECR
aws ecr describe-images \
  --repository-name eks-demo-app \
  --region ap-southeast-1

# Verify pod can pull from ECR
kubectl describe pod <pod-name>

# Check service account permissions
kubectl get sa default -o yaml
```

### Application Not Responding
```bash
# Check pod status
kubectl get pods -l app=eks-demo-app
kubectl describe pod <pod-name>

# Check logs for errors
kubectl logs <pod-name>

# Verify service endpoints
kubectl get endpoints eks-demo-app

# Test from within cluster
kubectl run debug --rm -it --image=curlimages/curl -- sh
curl http://eks-demo-app/health
```

---

## Commands Cheat Sheet

### Pipeline Status
```bash
# GitHub Actions (in browser)
https://github.com/<owner>/<repo>/actions

# Flux status
flux get all

# Deployment status
kubectl get deployment eks-demo-app
kubectl rollout status deployment/eks-demo-app
```

### Force Deployment
```bash
# Restart pods (rolling restart)
kubectl rollout restart deployment/eks-demo-app

# Force Flux reconciliation
flux reconcile kustomization flux-system --with-source
```

### Rollback
```bash
# Check rollout history
kubectl rollout history deployment/eks-demo-app

# Rollback to previous version
kubectl rollout undo deployment/eks-demo-app

# Rollback to specific revision
kubectl rollout undo deployment/eks-demo-app --to-revision=2
```

### Clean Up
```bash
# Delete application
kubectl delete -f app/

# Delete ECR repository
aws ecr delete-repository \
  --repository-name eks-demo-app \
  --force \
  --region ap-southeast-1

# Uninstall Flux
flux uninstall
```

---

## Interview Demo Script

### Quick Demo (5 minutes)

```bash
# 1. Show current application
kubectl get pods -l app=eks-demo-app
kubectl port-forward svc/eks-demo-app 8080:80 &
curl http://localhost:8080/api/info

# 2. Make a code change
cd sample-app
echo "console.log('Demo change');" >> server.js
git add .
git commit -m "Demo: Add logging"
git push origin main

# 3. Show GitHub Actions (open in browser)
# Point to: Actions tab → Watch workflow run

# 4. Show Flux watching
flux get kustomizations --watch

# 5. Watch pods update
kubectl get pods -l app=eks-demo-app -w

# 6. Verify new version deployed
curl http://localhost:8080/
# Show updated response/version
```

### Talking Points
- "This demonstrates a complete GitOps workflow"
- "Code push triggers automated testing and building"
- "Flux ensures cluster state matches Git"
- "Zero-downtime rolling updates"
- "Total deployment time: ~5 minutes"

---

## Next Steps

1. ✅ Add more test coverage
2. ✅ Implement staging environment
3. ✅ Add Prometheus monitoring
4. ✅ Set up alerting with AlertManager
5. ✅ Add canary deployments with Flagger

---

**For detailed architecture and concepts**, see [CICD_PIPELINE.md](./CICD_PIPELINE.md)

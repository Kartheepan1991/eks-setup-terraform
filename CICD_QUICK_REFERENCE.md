# CI/CD Quick Reference

## Pipeline Overview
```
Push Code → GitHub Actions (Test+Build+Push) → Update Manifest → Flux Deploy → EKS
Total: ~5-6 minutes
```

## GitHub Actions Jobs
1. **test** - Run Jest unit tests
2. **build-and-push** - Build Docker image, push to ECR
3. **update-manifest** - Update deployment.yaml with new image tag
4. **notify** - Send deployment status notification

## Flux CD Components
- **GitRepository**: Watches this repo for changes (every 1min)
- **Kustomization**: Applies manifests from `app/` directory
- **Reconciliation**: Auto-deploys when manifest changes detected

## Application Endpoints
- `GET /` - Welcome message + version info
- `GET /health` - Health check (used by K8s probes)
- `GET /api/info` - Application metadata

## Local Development
```bash
# Install dependencies
cd sample-app && npm install

# Run tests
npm test

# Build Docker image
docker build -t eks-demo-app:local .

# Run container
docker run -p 3000:3000 eks-demo-app:local

# Test locally
curl http://localhost:3000/
curl http://localhost:3000/health
```

## Deployment Commands
```bash
# Watch GitHub Actions
https://github.com/Kartheepan1991/eks-setup-terraform/actions

# Watch Flux reconciliation
flux get sources git
flux get kustomizations --watch

# Watch deployment
kubectl get deployments -w
kubectl get pods -l app=eks-demo-app -w

# Force reconciliation
flux reconcile kustomization flux-system --with-source

# Check application
kubectl port-forward svc/eks-demo-app 8080:80
curl http://localhost:8080/health
```

## Troubleshooting
```bash
# Check pipeline status
flux get all

# View Flux logs
kubectl logs -n flux-system deploy/kustomization-controller -f

# Check pod status
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Rollback deployment
kubectl rollout undo deployment/eks-demo-app

# View rollout history
kubectl rollout history deployment/eks-demo-app
```

## Required Secrets (GitHub)
- `AWS_ACCESS_KEY_ID` - IAM user with ECR permissions
- `AWS_SECRET_ACCESS_KEY` - IAM secret key

## IAM Permissions Required
```json
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
    "ecr:CreateRepository"
  ],
  "Resource": "*"
}
```

## Demo Workflow
```bash
# 1. Make code change
echo "// Demo change" >> sample-app/server.js

# 2. Commit and push
git add sample-app/
git commit -m "Demo: Add feature"
git push origin main

# 3. Watch in GitHub Actions (browser)
# 4. Watch Flux reconcile
flux get kustomizations --watch

# 5. Verify new pods
kubectl get pods -l app=eks-demo-app

# 6. Test application
kubectl port-forward svc/eks-demo-app 8080:80
curl http://localhost:8080/api/info
```

## Key Metrics
- **CI Time**: ~4-5 minutes (test + build + push)
- **CD Time**: ~1-2 minutes (Flux reconciliation + rolling update)
- **Total**: ~5-6 minutes from commit to production
- **Downtime**: 0 seconds (rolling updates with maxUnavailable: 0)

## Interview Talking Points
- ✅ GitOps with Flux CD for declarative deployments
- ✅ Automated testing gates production deployments
- ✅ Zero-downtime rolling updates
- ✅ Container security (non-root, vulnerability scanning)
- ✅ Infrastructure as Code (Terraform + GitOps)
- ✅ 5-minute commit-to-production pipeline

## Architecture Diagram Location
See `CICD_PIPELINE.md` for complete ASCII art diagram

## Full Documentation
- **CICD_PIPELINE.md** - Complete architecture, concepts, interview guide
- **CICD_SETUP.md** - Step-by-step setup instructions
- **README.md** - Project overview with CI/CD section

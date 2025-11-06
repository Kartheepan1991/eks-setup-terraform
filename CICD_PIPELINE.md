# CI/CD Pipeline Documentation

## Architecture Overview

This project implements a **complete CI/CD pipeline** combining **GitHub Actions** for Continuous Integration and **Flux CD** for Continuous Deployment on AWS EKS.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CI/CD PIPELINE FLOW                            │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│              │      │              │      │              │
│  Developer   │─────▶│   GitHub     │─────▶│  GitHub      │
│  Push Code   │      │  Repository  │      │  Actions     │
│              │      │              │      │   (CI)       │
└──────────────┘      └──────────────┘      └──────┬───────┘
                                                    │
                                                    │ Triggers on:
                                                    │ - Push to main
                                                    │ - PR creation
                                                    │
                            ┌───────────────────────▼────────────────────┐
                            │                                             │
                            │        GitHub Actions Workflow              │
                            │                                             │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  1. RUN TESTS                       │   │
                            │  │     • npm install                   │   │
                            │  │     • npm test (Jest)               │   │
                            │  │     • Upload coverage               │   │
                            │  └─────────────────────────────────────┘   │
                            │                 │                           │
                            │                 ▼                           │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  2. BUILD DOCKER IMAGE              │   │
                            │  │     • Configure AWS credentials     │   │
                            │  │     • Login to ECR                  │   │
                            │  │     • Build multi-stage image       │   │
                            │  │     • Tag: sha + latest             │   │
                            │  └─────────────────────────────────────┘   │
                            │                 │                           │
                            │                 ▼                           │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  3. PUSH TO ECR                     │   │
                            │  │     • Push image to Amazon ECR      │   │
                            │  │     • Scan for vulnerabilities      │   │
                            │  └─────────────────────────────────────┘   │
                            │                 │                           │
                            │                 ▼                           │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  4. UPDATE MANIFEST                 │   │
                            │  │     • Update deployment.yaml        │   │
                            │  │     • Commit & push changes         │   │
                            │  └─────────────────────────────────────┘   │
                            │                                             │
                            └─────────────────────┬───────────────────────┘
                                                  │
                                                  │ Manifest updated
                                                  │
                            ┌─────────────────────▼───────────────────────┐
                            │                                             │
                            │           FLUX CD (GitOps)                  │
                            │                                             │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  1. WATCH REPOSITORY                │   │
                            │  │     • Poll every 1 minute           │   │
                            │  │     • Detect manifest changes       │   │
                            │  └─────────────────────────────────────┘   │
                            │                 │                           │
                            │                 ▼                           │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  2. RECONCILE STATE                 │   │
                            │  │     • Pull new image from ECR       │   │
                            │  │     • Apply Kubernetes manifests    │   │
                            │  │     • Rolling update deployment     │   │
                            │  └─────────────────────────────────────┘   │
                            │                 │                           │
                            │                 ▼                           │
                            │  ┌─────────────────────────────────────┐   │
                            │  │  3. HEALTH CHECK                    │   │
                            │  │     • Verify pod readiness          │   │
                            │  │     • Monitor deployment status     │   │
                            │  └─────────────────────────────────────┘   │
                            │                                             │
                            └─────────────────────┬───────────────────────┘
                                                  │
                                                  ▼
                            ┌─────────────────────────────────────────────┐
                            │                                             │
                            │         AWS EKS CLUSTER                     │
                            │                                             │
                            │  ┌───────────┐  ┌───────────┐              │
                            │  │   Pod 1   │  │   Pod 2   │              │
                            │  │  (v2.0)   │  │  (v2.0)   │              │
                            │  └───────────┘  └───────────┘              │
                            │         │              │                    │
                            │         └──────┬───────┘                    │
                            │                ▼                            │
                            │        ┌───────────────┐                    │
                            │        │   Service     │                    │
                            │        └───────┬───────┘                    │
                            │                ▼                            │
                            │        ┌───────────────┐                    │
                            │        │   Ingress     │                    │
                            │        └───────────────┘                    │
                            │                                             │
                            └─────────────────────────────────────────────┘
```

---

## Pipeline Components

### 1. GitHub Actions (CI)

**File**: `.github/workflows/ci-cd.yml`

#### Jobs:

1. **Test Job**
   - Runs on every push and PR
   - Executes unit tests with Jest
   - Uploads coverage reports to Codecov
   - Gates deployment (must pass for deployment to proceed)

2. **Build and Push Job**
   - Triggers only on push to `main` branch
   - Authenticates with AWS ECR
   - Builds multi-stage Docker image
   - Tags with: `sha`, `branch name`, `latest`
   - Pushes to Amazon ECR
   - Enables vulnerability scanning

3. **Update Manifest Job**
   - Updates `app/deployment.yaml` with new image tag
   - Commits changes back to repository
   - Includes `[skip ci]` to prevent infinite loops

4. **Notify Job**
   - Reports pipeline status
   - Can integrate with Slack/Teams/Discord

---

### 2. Flux CD (GitOps Continuous Deployment)

**Directory**: `flux/`

#### Components:

- **GitRepository**: Watches this repository for changes
- **Kustomization**: Applies Kubernetes manifests from `app/` directory
- **Reconciliation**: Polls every 1 minute for changes
- **Automated Rollback**: Reverts failed deployments automatically

#### How Flux Works:

1. **Watches Git Repository**: Monitors for manifest changes
2. **Detects Changes**: Identifies updated image tags in `deployment.yaml`
3. **Pulls New Image**: Fetches from ECR registry
4. **Applies Changes**: Updates Kubernetes resources
5. **Validates Health**: Checks readiness/liveness probes
6. **Reports Status**: Updates status in Git (via Flux status API)

---

## Application Structure

### Sample Application (`sample-app/`)

- **Language**: Node.js (Express)
- **Purpose**: Demo REST API with health checks
- **Endpoints**:
  - `GET /` - Welcome message
  - `GET /health` - Health check (liveness/readiness)
  - `GET /api/info` - Application information

### Docker Image

- **Multi-stage build** for smaller image size
- **Non-root user** for security
- **Health checks** built into image
- **Alpine Linux** base (minimal footprint)

---

## Deployment Flow

### Step-by-Step Process:

```bash
# Developer workflow
git add sample-app/server.js
git commit -m "Add new feature"
git push origin main

# GitHub Actions (Automatic)
1. Tests run → ✅ Pass
2. Docker image builds → eks-demo-app:abc123
3. Image pushed to ECR → 311719319684.dkr.ecr.ap-southeast-1.amazonaws.com/eks-demo-app:abc123
4. deployment.yaml updated → image: ...eks-demo-app:abc123
5. Changes committed → [skip ci]

# Flux CD (Automatic - within 1 minute)
1. Detects manifest change
2. Pulls new image from ECR
3. Rolling update: Pod 1 → v2.0, Pod 2 → v2.0
4. Health checks pass → Deployment complete
```

### Zero-Downtime Deployment:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Create 1 new pod before terminating old
    maxUnavailable: 0  # Keep all pods running during update
```

---

## Security Best Practices

### 1. Container Security
- ✅ Non-root user (UID 1001)
- ✅ Read-only filesystem where possible
- ✅ Multi-stage builds (no build tools in final image)
- ✅ Alpine Linux (smaller attack surface)

### 2. Image Scanning
- ✅ ECR vulnerability scanning enabled
- ✅ Scan on push automatically

### 3. Kubernetes Security
- ✅ Resource limits (CPU/Memory)
- ✅ Security contexts
- ✅ Health probes (liveness/readiness)
- ✅ Network policies (future enhancement)

### 4. Secrets Management
- ✅ GitHub Secrets for AWS credentials
- ✅ No hardcoded secrets in code
- ✅ IAM roles for service accounts (IRSA) - recommended

---

## Required GitHub Secrets

Configure these in GitHub repository settings:

```bash
AWS_ACCESS_KEY_ID        # IAM user with ECR permissions
AWS_SECRET_ACCESS_KEY    # IAM user secret key
```

### IAM Policy for CI/CD:

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
        "ecr:DescribeRepositories"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Monitoring and Observability

### Pipeline Monitoring:

1. **GitHub Actions**:
   - View workflow runs: `Actions` tab
   - Real-time logs
   - Success/failure notifications

2. **Flux CD**:
   ```bash
   # Check Flux status
   flux get sources git
   flux get kustomizations
   
   # View reconciliation logs
   kubectl logs -n flux-system deploy/source-controller
   kubectl logs -n flux-system deploy/kustomization-controller
   ```

3. **Application Health**:
   ```bash
   # Check deployment
   kubectl get deployments
   kubectl describe deployment eks-demo-app
   
   # Check pods
   kubectl get pods
   kubectl logs -f <pod-name>
   
   # Test health endpoint
   kubectl port-forward svc/eks-demo-app 8080:80
   curl http://localhost:8080/health
   ```

---

## Troubleshooting

### Pipeline Fails at Test Stage
```bash
# Run tests locally
cd sample-app
npm install
npm test
```

### Image Push Fails
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Test ECR login manually
aws ecr get-login-password --region ap-southeast-1 | \
  docker login --username AWS --password-stdin \
  311719319684.dkr.ecr.ap-southeast-1.amazonaws.com
```

### Flux Not Deploying
```bash
# Check Flux reconciliation
flux get sources git
flux reconcile source git flux-system

# Force reconciliation
flux reconcile kustomization flux-system --with-source
```

### Pods Not Starting
```bash
# Check image pull issues
kubectl describe pod <pod-name>

# Verify image exists in ECR
aws ecr describe-images --repository-name eks-demo-app --region ap-southeast-1
```

---

## Performance Metrics

### CI/CD Pipeline Timing:

| Stage | Duration | Description |
|-------|----------|-------------|
| Test | ~30s | npm install + test execution |
| Build | ~2-3min | Multi-stage Docker build |
| Push | ~1min | Upload to ECR |
| Manifest Update | ~10s | Commit and push changes |
| **Total CI** | **~4-5min** | From push to ECR |
| Flux Reconciliation | ~1min | Detection + deployment |
| **End-to-End** | **~5-6min** | Code → Production |

---

## Interview Talking Points

### For DevOps Engineer Interviews:

1. **CI/CD Strategy**:
   - "Implemented GitOps using Flux CD for declarative deployments"
   - "Separated CI (GitHub Actions) from CD (Flux) for better separation of concerns"
   - "Achieved ~5 minute deployment time from commit to production"

2. **Container Best Practices**:
   - "Multi-stage Docker builds reduce image size by 70%"
   - "Non-root containers for security compliance"
   - "Automated vulnerability scanning with ECR"

3. **Kubernetes Expertise**:
   - "Zero-downtime rolling updates with maxUnavailable: 0"
   - "Health probes ensure traffic only routes to healthy pods"
   - "Resource limits prevent noisy neighbor issues"

4. **GitOps Benefits**:
   - "Git as single source of truth for infrastructure and applications"
   - "Automated reconciliation reduces manual intervention"
   - "Audit trail via Git commits for compliance"

5. **AWS Integration**:
   - "Leveraged ECR for secure container registry"
   - "IAM roles for least-privilege access"
   - "EKS for managed Kubernetes control plane"

---

## Next Steps / Enhancements

### Future Improvements:

1. **Advanced Deployment Strategies**:
   - [ ] Canary deployments with Flagger
   - [ ] Blue-Green deployments
   - [ ] Progressive delivery

2. **Observability**:
   - [ ] Prometheus + Grafana for metrics
   - [ ] ELK/EFK stack for logging
   - [ ] Jaeger for distributed tracing

3. **Security Enhancements**:
   - [ ] IRSA (IAM Roles for Service Accounts)
   - [ ] OPA/Gatekeeper for policy enforcement
   - [ ] Network policies for pod isolation

4. **Testing**:
   - [ ] Integration tests in pipeline
   - [ ] Load testing with k6
   - [ ] Chaos engineering with Chaos Mesh

5. **Multi-Environment**:
   - [ ] Separate dev/staging/prod environments
   - [ ] Environment-specific configurations
   - [ ] Promotion workflows

---

## Cost Optimization

### Pipeline Costs:

- **GitHub Actions**: Free for public repos, 2000 min/month for private
- **ECR Storage**: ~$0.10/GB/month
- **Data Transfer**: Minimal (in-region)
- **EKS**: ~$73/month (control plane) + worker nodes

### Cost-Saving Tips:

1. Delete old ECR images (lifecycle policies)
2. Use spot instances for worker nodes
3. Right-size pod resource requests
4. Enable cluster autoscaling

---

## References

- [Flux Documentation](https://fluxcd.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)

---

**Author**: Kartheepan  
**Last Updated**: November 2025  
**Repository**: https://github.com/Kartheepan1991/eks-setup-terraform

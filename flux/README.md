# Flux CD Configuration

This directory contains Flux CD configurations for GitOps deployment.

## Structure

```
flux/
├── flux-bootstrap.yaml          # Main Flux configuration
└── helm-releases/               # Helm chart deployments
    └── nginx-ingress.yaml       # Nginx Ingress Controller
```

## Components

### 1. GitRepository Source
- **Name**: `eks-demo-repo`
- **URL**: https://github.com/Kartheepan1991/eks-setup-terraform
- **Branch**: main
- **Sync Interval**: 1 minute

### 2. Kustomization
- **Name**: `eks-demo-kustomization`
- **Path**: `./app`
- **Prune**: true (removes deleted resources)
- **Interval**: 10 minutes

Deploys all Kubernetes manifests from the `app/` directory:
- deployment.yaml (eks-demo-app)
- service.yaml
- ingress.yaml

### 3. Nginx Ingress Controller (Optional)
If using the Helm chart deployment, Flux will also manage the Nginx Ingress Controller.

## How It Works

1. **Flux watches the Git repository** for changes every 1 minute
2. **When changes detected** in `app/` directory:
   - Pulls new manifests
   - Applies them to the cluster
   - Performs rolling updates
3. **If deployment fails**, Flux can automatically rollback
4. **Prune**: Removes resources deleted from Git

## Bootstrap Flux

```bash
# Install Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Bootstrap Flux with GitHub
flux bootstrap github \
  --owner=Kartheepan1991 \
  --repository=eks-setup-terraform \
  --branch=main \
  --path=flux \
  --personal \
  --token-auth

# Verify installation
flux check
kubectl get pods -n flux-system
```

## Monitor Flux

```bash
# Check all Flux resources
flux get all

# Watch GitRepository sync
flux get sources git --watch

# Watch Kustomization
flux get kustomizations --watch

# View Flux logs
kubectl logs -n flux-system deploy/source-controller -f
kubectl logs -n flux-system deploy/kustomization-controller -f
```

## Force Reconciliation

```bash
# Force sync from Git
flux reconcile source git eks-demo-repo

# Force apply manifests
flux reconcile kustomization eks-demo-kustomization --with-source
```

## CI/CD Integration

Flux works seamlessly with the GitHub Actions CI/CD pipeline:

1. **GitHub Actions** builds Docker image and updates `app/deployment.yaml`
2. **Flux detects** the manifest change within 1 minute
3. **Flux applies** the updated deployment to EKS
4. **Kubernetes** performs rolling update with zero-downtime

See `CICD_PIPELINE.md` for complete flow.

## Troubleshooting

### Flux not syncing
```bash
# Check Flux status
flux get sources git
flux get kustomizations

# View logs for errors
kubectl logs -n flux-system deploy/kustomization-controller | tail -50
```

### Deployment not updating
```bash
# Force reconciliation
flux reconcile kustomization eks-demo-kustomization --with-source

# Check if manifest changed
kubectl get deployment eks-demo-app -o yaml | grep image:
```

### Access denied errors
```bash
# Verify Flux can access GitHub
flux get sources git
# Should show: GitRepository/eks-demo-repo ready

# If using private repo, ensure deploy key is configured
```

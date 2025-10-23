# Cost Management Guide for EKS Cluster

## 💰 Current Daily Costs

With NAT Gateway enabled (2 AZs):
- **EKS Control Plane:** $2.40/day
- **Worker Node (t3.small):** $0.50/day
- **EBS Storage (20GB):** $0.08/day
- **NAT Gateway (2):** $3.00/day
- **Data Transfer:** ~$0.05/day
- **TOTAL:** ~$6.03/day (~$181/month)

## 🎯 Cost Optimization Strategies

### Option 1: Delete Entire Cluster (Recommended)
**Saves:** ~$6.03/day | **Cost:** $0/day

```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform destroy
```

**Recreate when needed:**
```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform apply
aws eks update-kubeconfig --region ap-southeast-1 --name kartheepan-eks-dev
```

**Time:** 15-20 minutes to recreate

---

### Option 2: Delete Node Group Only
**Saves:** $0.50/day | **Keeps:** Cluster running

```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform destroy -target=module.eks.aws_eks_node_group.main["general"]
```

**Recreate nodes:**
```bash
terraform apply
```

---

## 📋 Quick Commands

### Stop Everything (Save $6/day)
```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform destroy -auto-approve
```

### Start for Practice
```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform apply -auto-approve
aws eks update-kubeconfig --region ap-southeast-1 --name kartheepan-eks-dev
kubectl get nodes
```

---

## 📊 Cost Comparison

| Scenario | Daily Cost | Monthly Cost |
|----------|-----------|--------------|
| **Always Running** | $6.03 | ~$181 |
| **Practice 2h/day** | $0.50* | ~$15 |
| **Fully Stopped** | $0.00 | ~$0 |

*Assumes destroy/recreate daily

---

## 💡 Recommended Workflow

**When you finish practice:**
```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform destroy
```

**When you want to practice:**
```bash
cd ~/my-projects/eks-terraform-project/environments/dev
terraform apply
aws eks update-kubeconfig --region ap-southeast-1 --name kartheepan-eks-dev
```

Your state is safe in S3, so you can recreate anytime! 🚀

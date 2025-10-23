# 🚀 Building Production-Ready EKS Cluster with Terraform

I'm excited to share my journey of deploying a production-grade Amazon EKS cluster using Infrastructure as Code (Terraform) as part of my CKA (Certified Kubernetes Administrator) exam preparation! 

## 🎯 Project Objectives
- Learn Kubernetes and EKS administration
- Practice Infrastructure as Code with Terraform
- Implement AWS best practices for cloud infrastructure
- Gain hands-on experience with container orchestration

## 🏗️ Architecture Implemented
✅ **EKS Cluster (v1.28)** in AWS Singapore region (ap-southeast-1)
✅ **Multi-AZ VPC** with 2 availability zones for high availability
✅ **Private & Public Subnets** with proper network segmentation
✅ **NAT Gateways** for secure internet access from private subnets
✅ **Managed Node Group** with t3.small instances
✅ **S3 Backend** for Terraform state management with DynamoDB locking
✅ **Modular Terraform Code** for reusability and maintainability

## 💡 Key Challenges & Solutions

### Challenge 1: Single AZ Limitation
**Problem:** Initially configured with a single availability zone to minimize costs.
**Error:** `InvalidParameterException: Subnets specified must be in at least two different AZs`
**Solution:** AWS EKS requires minimum 2 availability zones for control plane high availability. Updated configuration to use ap-southeast-1a and ap-southeast-1b.
**Learning:** Always consider AWS service requirements over cost optimization - some architectural decisions are mandatory for security and reliability.

### Challenge 2: Node Group Connectivity Failure
**Problem:** Worker nodes failed to join the cluster with error: `NodeCreationFailure: Instances failed to join the kubernetes cluster`
**Root Cause:** Nodes in private subnets without NAT Gateway couldn't reach internet to:
- Download container images from Amazon ECR
- Communicate with EKS control plane
- Pull Kubernetes components
**Solution:** Enabled NAT Gateway in public subnets to provide internet access for private subnet resources.
**Learning:** Private subnet instances require NAT Gateway or VPC endpoints for outbound connectivity - this is critical for EKS node bootstrapping.

### Challenge 3: State Management
**Problem:** Need for collaborative infrastructure management and state locking.
**Solution:** Implemented remote state backend using:
- S3 bucket for state storage with encryption
- DynamoDB table for state locking
- Proper IAM permissions for secure access
**Learning:** Remote state management is essential for team collaboration and prevents concurrent modification issues.

## 🛠️ Technologies Used
- **AWS EKS** - Managed Kubernetes service
- **Terraform** - Infrastructure as Code (IaC)
- **AWS VPC** - Networking and security
- **S3 & DynamoDB** - State management
- **kubectl** - Kubernetes CLI

## 📊 Infrastructure Details
- **Region:** ap-southeast-1 (Singapore)
- **Availability Zones:** 2 (ap-southeast-1a, ap-southeast-1b)
- **VPC CIDR:** 10.0.0.0/16
- **Node Count:** 1 t3.small instance
- **Kubernetes Version:** 1.28
- **Estimated Cost:** ~$6.03/day (with 2 NAT Gateways)

## 🎓 Key Takeaways
1. **High Availability First:** AWS enforces multi-AZ for critical services like EKS
2. **Network Architecture Matters:** Understanding public vs private subnets and NAT requirements is crucial
3. **Cost vs Functionality:** Some AWS services require specific configurations that impact costs
4. **Modular IaC:** Well-structured Terraform modules make infrastructure maintainable and reusable
5. **State Management:** Remote backends are non-negotiable for production environments

## 🔗 Repository
GitHub: https://github.com/Kartheepan1991/eks-setup-terraform

## 📝 Next Steps
- Deploy sample applications for CKA practice
- Implement cluster autoscaling
- Set up monitoring with Prometheus and Grafana
- Practice CKA exam scenarios

This hands-on experience has deepened my understanding of Kubernetes, AWS networking, and infrastructure automation. Ready to tackle more complex cloud-native challenges! 💪

#Kubernetes #AWS #EKS #Terraform #DevOps #CloudComputing #IaC #CKA #ContainerOrchestration #CloudArchitecture #LearningInPublic

---
📌 Feel free to reach out if you're facing similar challenges or want to discuss Kubernetes and AWS!

# Development Environment Outputs
# These outputs provide important information about the created infrastructure

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

# EKS Cluster Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "node_groups" {
  description = "Information about EKS managed node groups"
  value       = module.eks.node_groups
}

# Configuration commands for local setup
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

output "get_nodes" {
  description = "Command to get cluster nodes"
  value       = "kubectl get nodes"
}

output "get_pods" {
  description = "Command to get all pods"
  value       = "kubectl get pods --all-namespaces"
}

# AWS CLI commands for cluster info
output "describe_cluster" {
  description = "AWS CLI command to describe the cluster"
  value       = "aws eks describe-cluster --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

output "list_node_groups" {
  description = "AWS CLI command to list node groups"
  value       = "aws eks list-nodegroups --region ${var.aws_region} --cluster-name ${module.eks.cluster_id}"
}
# EKS Module Main Configuration
# Creates EKS cluster with managed node groups and necessary IAM roles

locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "eks"
    }
  )
}

# Data sources for IAM policies
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-cluster-role"
    }
  )
}

# Attach required policies to cluster role
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# EKS Node Group IAM Role
resource "aws_iam_role" "node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
  # ...existing code continues...
}

# EKS Cluster Security Group
resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-eks-cluster-sg" })
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [aws_security_group.cluster_sg.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
  }

  enabled_cluster_log_types = var.enable_cluster_log_types

  tags = local.common_tags
}

# OIDC Provider for Service Accounts
data "tls_certificate" "cluster_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = local.common_tags
}

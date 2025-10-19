# EKS Module Outputs
# These outputs provide essential information about the EKS cluster

output "cluster_id" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "Platform version for the EKS cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster_sg.id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = aws_iam_openid_connect_provider.cluster_oidc.arn
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster_role.arn
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = aws_iam_role.node_role.arn
}

output "node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value = {
    for k, v in aws_eks_node_group.main : k => {
      arn               = v.arn
      status            = v.status
      capacity_type     = v.capacity_type
      instance_types    = v.instance_types
      ami_type          = v.ami_type
      node_group_name   = v.node_group_name
      scaling_config    = v.scaling_config
      remote_access     = v.remote_access
    }
  }
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = aws_cloudwatch_log_group.cluster_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of cloudwatch log group created"
  value       = aws_cloudwatch_log_group.cluster_logs.arn
}

# Outputs for kubectl configuration
output "kubectl_config" {
  description = "kubectl config file contents for this EKS cluster"
  value = {
    apiVersion      = "v1"
    clusters = [{
      cluster = {
        certificate-authority-data = aws_eks_cluster.main.certificate_authority[0].data
        server                     = aws_eks_cluster.main.endpoint
      }
      name = aws_eks_cluster.main.arn
    }]
    contexts = [{
      context = {
        cluster = aws_eks_cluster.main.arn
        user    = aws_eks_cluster.main.arn
      }
      name = aws_eks_cluster.main.arn
    }]
    current-context = aws_eks_cluster.main.arn
    kind            = "Config"
    preferences     = {}
    users = [{
      name = aws_eks_cluster.main.arn
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          command    = "aws"
          args = [
            "eks",
            "get-token",
            "--cluster-name",
            aws_eks_cluster.main.name
          ]
        }
      }
    }]
  }
  sensitive = true
}
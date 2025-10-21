# Development Environment Variables
# This file defines all variables for the dev environment

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eks-learning"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-2a"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "node_groups" {
  description = "EKS managed node group configurations"
  type = map(object({
    desired_capacity    = number
    max_capacity       = number
    min_capacity       = number
    instance_types     = list(string)
    capacity_type      = string
    disk_size          = number
    ami_type           = string
    labels             = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    general = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1
      instance_types   = ["t3.small"]
      capacity_type    = "ON_DEMAND"
      disk_size        = 20
      ami_type         = "AL2_x86_64"
      labels = {
        role = "general"
        environment = "dev"
      }
      taints = []
    }
  }
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler tags"
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this to your IP for better security
}

# Common tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "eks-learning"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "cloud-engineer"
    Purpose     = "CKA-exam-preparation"
  }
}
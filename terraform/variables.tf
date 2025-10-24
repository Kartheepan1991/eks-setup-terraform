# Development Environment Variables
# This file defines all variables for the dev environment

variable "aws_region" {
	description = "AWS region for all resources"
	type        = string
	default     = "ap-southeast-1"
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
	default     = ["ap-southeast-1a", "ap-southeast-1b"]
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
}

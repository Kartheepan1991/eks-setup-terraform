# EKS Module Variables
# This module creates an EKS cluster with managed node groups

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "worker_subnet_ids" {
  description = "List of subnet IDs for worker nodes (typically private subnets)"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_cluster_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_days" {
  description = "Number of days to retain cluster logs"
  type        = number
  default     = 7
}

# Node Group Variables
# Map of node group definitions to create managed node groups
variable "node_groups" {
  description = "Map of node group definitions to create managed node groups"
  type = map(object({
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    instance_types   = list(string)
    labels           = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    additional_tags = map(string)
  }))
  default = {}
}

# Tags to apply to resources created by this module
variable "tags" {
  description = "Tags to apply to resources created by this module"
  type        = map(string)
  default     = {}
}
# ...existing code continues...

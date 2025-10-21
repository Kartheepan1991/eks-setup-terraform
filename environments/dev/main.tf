# Development Environment Main Configuration
# This file creates the EKS cluster using our custom modules

# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Local values for consistent naming
locals {
  cluster_name = "${var.project_name}-${var.environment}"
  vpc_name     = "${var.project_name}-${var.environment}-vpc"
}

# Create VPC using our custom module
module "vpc" {
  source = "../../modules/vpc"

  vpc_name               = local.vpc_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  enable_nat_gateway    = var.enable_nat_gateway
  enable_dns_hostnames  = true
  enable_dns_support    = true

  # Calculate subnet CIDRs automatically for single zone
  private_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 1)
  ]
  
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 101)
  ]

  tags = var.common_tags
}

# Create EKS cluster using our custom module
module "eks" {
  source = "../../modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.cluster_subnet_ids
  worker_subnet_ids   = module.vpc.worker_subnet_ids

  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  enable_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  log_retention_days       = 7

  node_groups               = var.node_groups
  enable_cluster_autoscaler = var.enable_cluster_autoscaler

  tags = var.common_tags

  depends_on = [module.vpc]
}
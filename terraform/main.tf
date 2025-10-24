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
	source = "../modules/vpc"

	vpc_name               = local.vpc_name
	vpc_cidr              = var.vpc_cidr
	availability_zones    = var.availability_zones
	enable_nat_gateway    = var.enable_nat_gateway
	enable_dns_hostnames  = true
	enable_dns_support    = true

	# Calculate subnet CIDRs automatically for 2 zones (minimum for EKS)
	private_subnet_cidrs = [
		cidrsubnet(var.vpc_cidr, 8, 1),
		cidrsubnet(var.vpc_cidr, 8, 2)
	]
  
	public_subnet_cidrs = [
		cidrsubnet(var.vpc_cidr, 8, 101),
		cidrsubnet(var.vpc_cidr, 8, 102)
	]

	tags = var.common_tags
}

# Create EKS cluster using our custom module
module "eks" {
	source = "../modules/eks"
	# ...rest of the module configuration...
}

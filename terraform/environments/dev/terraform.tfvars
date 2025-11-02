# Example Terraform variables file for dev environment
# Copy this file to terraform.tfvars and customize the values

aws_region = "ap-southeast-1"
environment = "dev"
project_name = "eks-learning"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
enable_nat_gateway = true
cluster_version = "1.31"
endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Replace with your IP: ["YOUR_IP/32"]

node_groups = {
  general = {
    desired_capacity = 2
    max_capacity     = 4
    min_capacity     = 1
    instance_types   = ["t3.medium"]
    capacity_type    = "ON_DEMAND"
    disk_size        = 20
    ami_type         = "AL2_x86_64"
    labels = {
      role = "general"
      environment = "dev"
    }
    taints = []
    additional_tags = {
      Name        = "eks-general-node"
      Environment = "dev"
    }
  }
  spot = {
    desired_capacity = 1
    max_capacity     = 3
    min_capacity     = 0
    instance_types   = ["t3.medium", "t3.large"]
    capacity_type    = "SPOT"
    disk_size        = 20
    ami_type         = "AL2_x86_64"
    labels = {
      role = "spot"
      environment = "dev"
    }
    taints = [{
      key    = "spot"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
    additional_tags = {
      Name        = "eks-spot-node"
      Environment = "dev"
    }
  }
}

# Backend configuration for Terraform state management
# This file should be customized after running setup-backend.sh

terraform {
  backend "s3" {
    # Replace these values with the output from setup-backend.sh
    bucket         = "my-terraform-state-eks-1761190037"
    key            = "environments/dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
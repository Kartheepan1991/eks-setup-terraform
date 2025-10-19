# Backend configuration for Terraform state management
# This file should be customized after running setup-backend.sh

terraform {
  backend "s3" {
    # Replace these values with the output from setup-backend.sh
    bucket         = "your-terraform-state-bucket-name"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
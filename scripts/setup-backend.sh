#!/bin/bash

# Setup script for Terraform backend infrastructure
# This creates the S3 bucket and DynamoDB table for state management

set -e

# Variables - Customize these for your environment
BUCKET_NAME="my-terraform-state-eks-$(date +%s)"
DYNAMODB_TABLE="terraform-state-lock"
REGION="eu-west-2"

echo "Setting up Terraform backend infrastructure..."
echo "Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "Region: $REGION"

# Create S3 bucket for state storage
echo "Creating S3 bucket for Terraform state..."
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

# Enable versioning on the bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
echo "Enabling server-side encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
echo "Configuring S3 bucket to block public access..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
        BlockPublicAcls=true,\
        IgnorePublicAcls=true,\
        BlockPublicPolicy=true,\
        RestrictPublicBuckets=true

# Create DynamoDB table for state locking
echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $REGION

# Wait for table to be active
echo "Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists --table-name $DYNAMODB_TABLE --region $REGION

echo ""
echo "Backend infrastructure created successfully!"
echo ""
echo "Add the following backend configuration to your Terraform files:"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"environments/\${var.environment}/terraform.tfstate\""
echo "    region         = \"$REGION\""
echo "    dynamodb_table = \"$DYNAMODB_TABLE\""
echo "    encrypt        = true"
echo "  }"
echo "}"
echo ""
echo "Save this information:"
echo "BUCKET_NAME=$BUCKET_NAME"
echo "DYNAMODB_TABLE=$DYNAMODB_TABLE"
echo "REGION=$REGION"
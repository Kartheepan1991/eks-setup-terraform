#!/bin/bash

# Cleanup script for EKS Terraform project
# This script safely destroys the infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-dev}
PROJECT_ROOT=$(pwd)
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

echo -e "${RED}🧹 EKS Terraform Cleanup Script${NC}"
echo -e "${RED}===============================${NC}"
echo ""

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}❌ Environment directory '$ENV_DIR' does not exist${NC}"
    echo -e "${YELLOW}Available environments:${NC}"
    ls -la environments/ 2>/dev/null || echo "No environments found"
    exit 1
fi

# Function to display warning
display_warning() {
    echo -e "${RED}⚠️  WARNING: This will destroy all infrastructure for environment '$ENVIRONMENT'${NC}"
    echo -e "${RED}This includes:${NC}"
    echo -e "${RED}  - EKS Cluster and all running workloads${NC}"
    echo -e "${RED}  - VPC and all networking components${NC}"
    echo -e "${RED}  - NAT Gateways (which may have costs)${NC}"
    echo -e "${RED}  - CloudWatch Log Groups${NC}"
    echo -e "${RED}  - All associated AWS resources${NC}"
    echo ""
    echo -e "${YELLOW}This action cannot be undone!${NC}"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check if AWS CLI is installed and configured
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed${NC}"
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform is not installed${NC}"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}❌ AWS credentials not configured${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites met${NC}"
    echo ""
}

# Function to backup important data
backup_data() {
    echo -e "${BLUE}💾 Creating backup of Terraform state and outputs...${NC}"
    
    cd "$ENV_DIR"
    
    # Create backup directory
    BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d_%H%M%S)_${ENVIRONMENT}"
    mkdir -p "$BACKUP_DIR"
    
    # Backup Terraform outputs
    if terraform output > "$BACKUP_DIR/terraform_outputs.txt" 2>/dev/null; then
        echo -e "${GREEN}✅ Terraform outputs backed up${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not backup Terraform outputs${NC}"
    fi
    
    # Backup kubeconfig if it exists
    if kubectl config current-context &> /dev/null; then
        CURRENT_CONTEXT=$(kubectl config current-context)
        if [[ "$CURRENT_CONTEXT" == *"$ENVIRONMENT"* ]]; then
            kubectl config view --raw > "$BACKUP_DIR/kubeconfig_backup.yaml" 2>/dev/null || true
            echo -e "${GREEN}✅ Kubeconfig backed up${NC}"
        fi
    fi
    
    echo -e "${GREEN}✅ Backup created at: $BACKUP_DIR${NC}"
    echo ""
}

# Function to check for running workloads
check_workloads() {
    echo -e "${BLUE}🔍 Checking for running workloads...${NC}"
    
    cd "$ENV_DIR"
    
    # Get cluster name
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
    
    if [ -n "$CLUSTER_NAME" ] && kubectl config current-context &> /dev/null; then
        CURRENT_CONTEXT=$(kubectl config current-context)
        if [[ "$CURRENT_CONTEXT" == *"$CLUSTER_NAME"* ]]; then
            echo -e "${YELLOW}📊 Current running workloads:${NC}"
            kubectl get deployments --all-namespaces 2>/dev/null || true
            kubectl get services --all-namespaces 2>/dev/null || true
            echo ""
            
            # Check for LoadBalancer services
            LB_SERVICES=$(kubectl get services --all-namespaces -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].metadata.name}' 2>/dev/null || echo "")
            if [ -n "$LB_SERVICES" ]; then
                echo -e "${YELLOW}⚠️  LoadBalancer services found: $LB_SERVICES${NC}"
                echo -e "${YELLOW}   These will be deleted and may take time to clean up${NC}"
                echo ""
            fi
        fi
    fi
}

# Function to destroy infrastructure
destroy_infrastructure() {
    echo -e "${RED}🗑️  Destroying infrastructure...${NC}"
    
    cd "$ENV_DIR"
    
    # Initialize Terraform (in case it wasn't already)
    terraform init
    
    # Plan destruction
    echo -e "${YELLOW}📋 Creating destruction plan...${NC}"
    terraform plan -destroy -out=destroy.tfplan
    echo ""
    
    # Final confirmation
    echo -e "${RED}🚨 FINAL CONFIRMATION${NC}"
    echo -e "${RED}Are you absolutely sure you want to destroy the infrastructure?${NC}"
    echo -e "${YELLOW}Type 'yes' to confirm destruction: ${NC}"
    read -r response
    
    if [ "$response" != "yes" ]; then
        echo -e "${YELLOW}🚫 Destruction cancelled${NC}"
        rm -f destroy.tfplan
        exit 0
    fi
    
    # Apply destruction
    echo -e "${RED}💥 Destroying infrastructure...${NC}"
    terraform apply destroy.tfplan
    
    # Clean up plan file
    rm -f destroy.tfplan
    
    echo -e "${GREEN}✅ Infrastructure destroyed successfully!${NC}"
    echo ""
}

# Function to clean up kubectl context
cleanup_kubectl() {
    echo -e "${BLUE}🧹 Cleaning up kubectl context...${NC}"
    
    # Remove the cluster from kubeconfig
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
    if [ -n "$CLUSTER_NAME" ]; then
        kubectl config delete-context "$CLUSTER_NAME" 2>/dev/null || true
        kubectl config delete-cluster "$CLUSTER_NAME" 2>/dev/null || true
        kubectl config unset "users.$CLUSTER_NAME" 2>/dev/null || true
        echo -e "${GREEN}✅ kubectl context cleaned up${NC}"
    fi
    echo ""
}

# Function to clean up backend (optional)
cleanup_backend() {
    echo -e "${YELLOW}🗑️  Do you want to clean up the Terraform backend (S3 bucket and DynamoDB table)?${NC}"
    echo -e "${YELLOW}   This will affect ALL environments using this backend!${NC}"
    echo -e "${YELLOW}   Type 'yes' to also clean up backend: ${NC}"
    read -r response
    
    if [ "$response" = "yes" ]; then
        echo -e "${RED}🧹 Cleaning up backend infrastructure...${NC}"
        
        # Extract backend configuration
        BUCKET_NAME=$(grep 'bucket.*=' "$PROJECT_ROOT/backend.tf" | sed 's/.*"\(.*\)".*/\1/' | head -1)
        DYNAMODB_TABLE=$(grep 'dynamodb_table.*=' "$PROJECT_ROOT/backend.tf" | sed 's/.*"\(.*\)".*/\1/' | head -1)
        AWS_REGION=$(grep 'region.*=' "$PROJECT_ROOT/backend.tf" | sed 's/.*"\(.*\)".*/\1/' | head -1)
        
        if [ -n "$BUCKET_NAME" ] && [ -n "$DYNAMODB_TABLE" ]; then
            # Delete S3 bucket (first empty it)
            echo -e "${YELLOW}Emptying and deleting S3 bucket: $BUCKET_NAME${NC}"
            aws s3 rm "s3://$BUCKET_NAME" --recursive --region "$AWS_REGION" 2>/dev/null || true
            aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" 2>/dev/null || true
            
            # Delete DynamoDB table
            echo -e "${YELLOW}Deleting DynamoDB table: $DYNAMODB_TABLE${NC}"
            aws dynamodb delete-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" 2>/dev/null || true
            
            echo -e "${GREEN}✅ Backend infrastructure cleaned up${NC}"
        else
            echo -e "${RED}❌ Could not determine backend configuration${NC}"
        fi
    fi
    echo ""
}

# Main execution
main() {
    display_warning
    
    # Get confirmation to proceed
    echo -e "${YELLOW}Do you want to proceed with cleanup? (y/N): ${NC}"
    read -r proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🚫 Cleanup cancelled${NC}"
        exit 0
    fi
    echo ""
    
    check_prerequisites
    backup_data
    check_workloads
    destroy_infrastructure
    cleanup_kubectl
    cleanup_backend
    
    echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo "✅ Infrastructure destroyed"
    echo "✅ kubectl context cleaned up"
    echo "✅ Backup created in backups/ directory"
    echo ""
    echo -e "${YELLOW}Note: Some AWS resources may take a few minutes to be fully deleted${NC}"
    echo ""
}

# Run main function
main "$@"
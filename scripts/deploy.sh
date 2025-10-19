#!/bin/bash

# Deployment script for EKS Terraform project
# This script automates the deployment process

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

echo -e "${BLUE}🚀 EKS Terraform Deployment Script${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo -e "${RED}❌ Environment directory '$ENV_DIR' does not exist${NC}"
    echo -e "${YELLOW}Available environments:${NC}"
    ls -la environments/
    exit 1
fi

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
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo -e "${YELLOW}⚠️  kubectl is not installed. You'll need it to manage the cluster${NC}"
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}❌ AWS credentials not configured${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
    echo ""
}

# Function to setup backend
setup_backend() {
    echo -e "${BLUE}🏗️  Setting up Terraform backend...${NC}"
    
    if [ ! -f "$PROJECT_ROOT/backend.tf" ]; then
        echo -e "${RED}❌ backend.tf not found${NC}"
        exit 1
    fi
    
    # Check if backend is configured
    if grep -q "your-terraform-state-bucket-name" "$PROJECT_ROOT/backend.tf"; then
        echo -e "${YELLOW}⚠️  Backend not configured. Please run setup-backend.sh first${NC}"
        echo -e "${YELLOW}   or manually update backend.tf with your S3 bucket details${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Backend configuration found${NC}"
    echo ""
}

# Function to deploy infrastructure
deploy_infrastructure() {
    echo -e "${BLUE}🏗️  Deploying infrastructure for environment: $ENVIRONMENT${NC}"
    
    cd "$ENV_DIR"
    
    # Initialize Terraform
    echo -e "${YELLOW}📦 Initializing Terraform...${NC}"
    terraform init
    echo ""
    
    # Validate configuration
    echo -e "${YELLOW}🔍 Validating Terraform configuration...${NC}"
    terraform validate
    echo ""
    
    # Plan deployment
    echo -e "${YELLOW}📋 Creating deployment plan...${NC}"
    terraform plan -out=tfplan
    echo ""
    
    # Ask for confirmation
    echo -e "${YELLOW}❓ Do you want to apply this plan? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🚫 Deployment cancelled${NC}"
        rm -f tfplan
        exit 0
    fi
    
    # Apply the plan
    echo -e "${YELLOW}🚀 Applying Terraform configuration...${NC}"
    terraform apply tfplan
    
    # Clean up plan file
    rm -f tfplan
    
    echo -e "${GREEN}✅ Infrastructure deployed successfully!${NC}"
    echo ""
}

# Function to configure kubectl
configure_kubectl() {
    echo -e "${BLUE}⚙️  Configuring kubectl...${NC}"
    
    cd "$ENV_DIR"
    
    # Get cluster name and region from Terraform outputs
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
    AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || grep 'default.*=.*".*"' variables.tf | grep -o '"[^"]*"' | tr -d '"' | head -1)
    
    if [ -z "$CLUSTER_NAME" ]; then
        echo -e "${RED}❌ Could not get cluster name from Terraform outputs${NC}"
        return 1
    fi
    
    if [ -z "$AWS_REGION" ]; then
        AWS_REGION="us-west-2"
        echo -e "${YELLOW}⚠️  Could not determine region, using default: $AWS_REGION${NC}"
    fi
    
    # Update kubeconfig
    echo -e "${YELLOW}📝 Updating kubeconfig...${NC}"
    aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
    
    # Test cluster access
    echo -e "${YELLOW}🧪 Testing cluster access...${NC}"
    if kubectl get nodes &> /dev/null; then
        echo -e "${GREEN}✅ kubectl configured successfully!${NC}"
        echo ""
        echo -e "${GREEN}🎉 Cluster nodes:${NC}"
        kubectl get nodes
    else
        echo -e "${RED}❌ Failed to access cluster${NC}"
        return 1
    fi
    
    echo ""
}

# Function to display useful information
display_info() {
    echo -e "${BLUE}📊 Deployment Information${NC}"
    echo -e "${BLUE}========================${NC}"
    
    cd "$ENV_DIR"
    
    echo -e "${GREEN}Cluster Details:${NC}"
    terraform output cluster_name 2>/dev/null && echo ""
    terraform output cluster_endpoint 2>/dev/null && echo ""
    terraform output cluster_version 2>/dev/null && echo ""
    
    echo -e "${GREEN}Useful Commands:${NC}"
    echo -e "${YELLOW}  # Get cluster information${NC}"
    echo "  kubectl cluster-info"
    echo ""
    echo -e "${YELLOW}  # Get all nodes${NC}"
    echo "  kubectl get nodes"
    echo ""
    echo -e "${YELLOW}  # Get all pods${NC}"
    echo "  kubectl get pods --all-namespaces"
    echo ""
    echo -e "${YELLOW}  # Deploy a test application${NC}"
    echo "  kubectl create deployment nginx --image=nginx"
    echo "  kubectl expose deployment nginx --port=80 --type=LoadBalancer"
    echo ""
    
    # Show terraform outputs
    echo -e "${GREEN}All Terraform Outputs:${NC}"
    terraform output
}

# Main execution
main() {
    echo -e "${GREEN}Starting deployment for environment: $ENVIRONMENT${NC}"
    echo ""
    
    check_prerequisites
    setup_backend
    deploy_infrastructure
    
    if command -v kubectl &> /dev/null; then
        configure_kubectl
    else
        echo -e "${YELLOW}⚠️  kubectl not found. Please install it and run:${NC}"
        echo -e "${YELLOW}   aws eks update-kubeconfig --region <region> --name <cluster-name>${NC}"
        echo ""
    fi
    
    display_info
    
    echo ""
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo -e "${GREEN}Your EKS cluster is ready for use.${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Explore the cluster with kubectl commands"
    echo "2. Deploy sample applications"
    echo "3. Practice CKA exam scenarios"
    echo "4. Set up monitoring and logging"
    echo ""
}

# Run main function
main "$@"
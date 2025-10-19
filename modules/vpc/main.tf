# VPC Module Main Configuration
# Creates a production-ready VPC for EKS with public and private subnets

# Local values for consistent tagging and naming
locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "vpc"
    }
  )
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    local.common_tags,
    {
      Name = var.vpc_name
      # These tags are required for EKS
      "kubernetes.io/cluster/${var.vpc_name}-cluster" = "shared"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

# Create public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-public-${var.availability_zones[count.index]}"
      Type = "public"
      # EKS requires these tags for load balancer subnet discovery
      "kubernetes.io/cluster/${var.vpc_name}-cluster" = "shared"
      "kubernetes.io/role/elb"                        = "1"
    }
  )
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-private-${var.availability_zones[count.index]}"
      Type = "private"
      # EKS requires these tags for load balancer subnet discovery
      "kubernetes.io/cluster/${var.vpc_name}-cluster" = "shared"
      "kubernetes.io/role/internal-elb"               = "1"
    }
  )
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-nat-gateway-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-public-rt"
      Type = "public"
    }
  )
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create route tables for private subnets
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  # Only create routes to NAT Gateway if NAT Gateway is enabled
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-private-rt-${count.index + 1}"
      Type = "private"
    }
  )
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPN Gateway (optional)
resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-vpn-gateway"
    }
  )
}

# VPC Endpoint for S3 (recommended for EKS)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc_name}-s3-endpoint"
    }
  )
}

# Associate VPC endpoint with route tables
resource "aws_vpc_endpoint_route_table_association" "s3_public" {
  route_table_id  = aws_route_table.public.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  count = length(aws_route_table.private)

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# Data source for current AWS region
data "aws_region" "current" {}
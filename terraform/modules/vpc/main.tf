# VPC Module Main Configuration
# Creates a production-ready VPC for EKS with public and private subnets

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
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
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
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                    = "1"
    }
  )
  # ...existing code continues...
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
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb" = "1"
      }
    )
  }

# NAT Gateway and EIP (if enabled)
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]
  tags = local.common_tags
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]
  tags          = local.common_tags
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-public-rt" })
}

# Private route tables
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.vpc_name}-private-rt-${count.index}" })
}

# Route for public subnets to access internet via Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Routes for private subnets to access internet via NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

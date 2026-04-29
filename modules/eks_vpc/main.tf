terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
  }
}

# Spoke VPC

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.spoke_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-eks-vpc"
  }
}

# Spoke Subnets

resource "aws_subnet" "spoke_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, 1 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name = "${var.name}-eks-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Spoke VPC Attach to Egress Service VPC via TGW

resource "ciscomcd_spoke_vpc" "spoke_to_service" {
  service_vpc_id = var.service_vpc_id
  spoke_vpc_id   = aws_vpc.eks_vpc.id
}

# Spoke VPC route table

resource "aws_route_table" "spoke_route_table" {
  depends_on = [ciscomcd_spoke_vpc.spoke_to_service]
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.aws_tgw_id
  }

  tags = {
    Name = "${var.name}-eks-route-table"
  }
}

# Spoke Route Association

resource "aws_route_table_association" "spoke_rt_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.spoke_subnet[count.index].id
  route_table_id = aws_route_table.spoke_route_table.id
}



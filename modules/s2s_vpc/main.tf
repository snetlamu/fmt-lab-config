terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    sccfm = {
      source = "CiscoDevNet/sccfm"
      version = "0.2.5"
    }
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "2.0.0-rc7"
    }
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
  }
}

######################################
# VPCs
######################################

# VPC
resource "aws_vpc" "ftd_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.name}-s2s-vpc"
  }
}

# Management Subnet
resource "aws_subnet" "mgmt_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.mgmt_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.name}-s2s-mgt-subnet"
  }
}

# Diag Subnet
resource "aws_subnet" "diag_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.diag_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.name}-s2s-diag-subnet"
  }
}

# Outside Subnet
resource "aws_subnet" "outside_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.outside_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.name}-s2s-outside-subnet"
  }
}

# Inside Subnet
resource "aws_subnet" "inside_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.inside_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.name}-s2s-inside-subnet"
  }
}

#############################################
# Security Groups
#############################################

# Security Group to Allow HTTP and HTTPS Ingress
resource "aws_security_group" "ftd_sg" {
  name        = "FTD Outside SG"
  description = "Allow traffic for ingress"
  vpc_id      = aws_vpc.ftd_vpc.id

  # Ingress rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.dcloud_cidrs # Allows HTTP from any IP address
  }

  # Ingress rule for HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.dcloud_cidrs # Allows HTTPS from any IP address
  }

  # Ingress rules (inbound traffic)
  # UDP 500 for IKE (Internet Key Exchange)
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = var.dcloud_cidrs
    description = "Allow IKE (UDP 500) from on-premises"
  }

  # UDP 4500 for NAT-T (NAT Traversal)
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = var.dcloud_cidrs
    description = "Allow NAT-T (UDP 4500) from on-premises"
  }

  # IP Protocol 50 for ESP (Encapsulating Security Payload)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "50" # ESP protocol number
    cidr_blocks = var.dcloud_cidrs
    description = "Allow ESP (Protocol 50) from on-premises"
  }

  # IP Protocol 51 for AH (Authentication Header) - Less common but included for completeness
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "51" # AH protocol number
    cidr_blocks = var.dcloud_cidrs
    description = "Allow AH (Protocol 51) from on-premises"
  }

  # Egress rule (allowing all outbound traffic, as in your original example)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allows outbound to any IP address
  }

  tags = {
    Name = "${var.name}-s2s Public HTTP/HTTPS"
  }
}

resource "aws_security_group" "ftd_mgmt" {
  name        = "ftd_mgmt_sg"
  description = "Security group for FTD management SSH access"
  vpc_id      = aws_vpc.ftd_vpc.id

  ingress {
    description      = "ftd mgmt"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.public_access_cidrs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # Allows all protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Security Group to Allow All
resource "aws_security_group" "allow_all" {
  name        = "Allow All"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.ftd_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-s2s Public Allow"
  }
}

################################################
# AWS Interface and IP address assignments
################################################

# FTD Mgmt Interface
resource "aws_network_interface" "ftdmgmt" {
  description   = "ftd1-mgmt"
  subnet_id     = aws_subnet.mgmt_subnet.id
  private_ips   = [var.ftd_mgmt_ip]
  tags = {
    Name = "${var.name}-s2s FTD Mgmt"
  }
}

# FTD Diag Interface
resource "aws_network_interface" "ftddiag" {
  description = "ftd-diag"
  subnet_id   = aws_subnet.diag_subnet.id
  tags = {
    Name = "${var.name}-s2s FTD Diag"
  }
}

# FTD Outside Interface
resource "aws_network_interface" "ftdoutside" {
  description = "ftd1-outside"
  subnet_id   = aws_subnet.outside_subnet.id
  private_ips = [var.ftd_outside_ip]
  source_dest_check = false
  tags = {
    Name = "${var.name}-s2s FTD Outside"
  }
}

# FTD Inside Interface
resource "aws_network_interface" "ftdinside" {
  description = "ftd01-inside"
  subnet_id   = aws_subnet.inside_subnet.id
  private_ips = [var.ftd_inside_ip]
  source_dest_check = false
  tags = {
    Name = "${var.name}-s2s FTD Inside"
  }
}

# Attach Security Group to FTD Mgmt Interface
resource "aws_network_interface_sg_attachment" "ftd_mgmt_attachment" {
  depends_on           = [aws_network_interface.ftdmgmt]
  security_group_id    = aws_security_group.ftd_mgmt.id
  network_interface_id = aws_network_interface.ftdmgmt.id
}

# Attach Security Group to FTD Outside Interface
resource "aws_network_interface_sg_attachment" "ftd_outside_attachment" {
  depends_on           = [aws_network_interface.ftdoutside]
  security_group_id    = aws_security_group.ftd_sg.id
  network_interface_id = aws_network_interface.ftdoutside.id
}

# Attach Security Group to FTD Inside Interface
resource "aws_network_interface_sg_attachment" "ftd_inside_attachment" {
  depends_on           = [aws_network_interface.ftdinside]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.ftdinside.id
}

#########################################################
# Routing
#########################################################

# Internet gateway
resource "aws_internet_gateway" "int_gw" {
  vpc_id = aws_vpc.ftd_vpc.id
  tags = {
    Name = "${var.name}-s2s-IGW"
  }
}

# Spoke VPC Attach to Egress Service VPC via TGW

resource "ciscomcd_spoke_vpc" "spoke_to_service" {
  service_vpc_id = var.service_vpc_id
  spoke_vpc_id   = aws_vpc.ftd_vpc.id
}

# Outside Route Table
resource "aws_route_table" "ftd_outside_route" {
  vpc_id = aws_vpc.ftd_vpc.id

  tags = {
    Name = "${var.name}-s2s Outside network Routing table"
  }
}

# Inside Route Table
resource "aws_route_table" "ftd_inside_route" {
  vpc_id = aws_vpc.ftd_vpc.id

  tags = {
    Name = "${var.name}-s2s Inside network Routing table"
  }
}

# Default Route for Outside Route Table to Internet GW
resource "aws_route" "ext_default_route" {
  route_table_id         = aws_route_table.ftd_outside_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.int_gw.id
}

# Default Route for Inside Route Table to FTD Inside Interface
resource "aws_route" "inside_default_route" {
#  depends_on              = [aws_instance.ftdv]
  route_table_id          = aws_route_table.ftd_inside_route.id
  destination_cidr_block  = "0.0.0.0/0"
  network_interface_id    = aws_network_interface.ftdinside.id
}

# Default Route for Inside Route Table to FTD Inside Interface
resource "aws_route" "inside_tgw_route" {
  depends_on              = [ciscomcd_spoke_vpc.spoke_to_service]
  route_table_id          = aws_route_table.ftd_inside_route.id
  destination_cidr_block  = "10.0.0.0/8"
  transit_gateway_id      = var.aws_tgw_id
}

# Associate the Outside Subnet to the Outside Route Table
resource "aws_route_table_association" "outside_association" {
  subnet_id      = aws_subnet.outside_subnet.id
  route_table_id = aws_route_table.ftd_outside_route.id
}

# Associate the Mgmt Subnet to the Outside Route Table
resource "aws_route_table_association" "mgmt_association" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.ftd_outside_route.id
}

# Associate the Inside Subnet to the Inside Route Table
resource "aws_route_table_association" "inside_association" {
  subnet_id      = aws_subnet.inside_subnet.id
  route_table_id = aws_route_table.ftd_inside_route.id
}

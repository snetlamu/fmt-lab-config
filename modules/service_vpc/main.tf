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

# Data Sources
# Fetch the cloud account details from Cisco MCD
data "ciscomcd_cloud_account" "account_name" {
  name = var.ciscomcd_account
}

# Service VPC
# Create a service VPC in the specified AWS region
resource "ciscomcd_service_vpc" "service-vpc" {
  name                = "${var.name}-service-vpc"
  csp_account_name    = data.ciscomcd_cloud_account.account_name.name
  region              = var.aws_region
  cidr                = var.vpc_cidr
  availability_zones  = var.aws_availability_zones
  transit_gateway_id  = var.aws_tgw_id
  use_nat_gateway     = true
}



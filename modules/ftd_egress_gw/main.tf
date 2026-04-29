terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
  }
}

# Egress Gateway
resource "ciscomcd_ftdv_gateway" "egress-gateway" {
  name                  = "${var.name}-ftdv-egress-gw"
  description           = "${var.name} FTDv Egress Gateway"
  csp_account_name      = var.ciscomcd_account
  region                = var.aws_region
  vpc_id                = var.service_vpc_id
  instance_type         = var.ftd_instance_type
  aws_iam_role_firewall = var.aws_iam_role
  ssh_key_pair          = var.aws_key_name
  ftdv_version          = "7.7.0"
  ftdv_policy_id        = var.egress_policy_id
  ftdv_password         = var.ftd_password
  ftdv_license_model    = "MULTICLOUD_DEFENSE"
}

data "ciscomcd_cloud_account" "aws" {
  name = var.ciscomcd_account
}

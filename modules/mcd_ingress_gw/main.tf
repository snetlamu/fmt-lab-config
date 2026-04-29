terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
  }
}

# Ingress Gateway
# Create an ingress gateway in the service VPC
resource "ciscomcd_gateway" "ingress-gateway" {
  name                = "${var.name}-ingress-gateway"
  csp_account_name    = var.csp_account_name
  instance_type       = var.gw_instance_type
  mode                = "HUB"
  policy_rule_set_id  = var.ingress_policy_id
  min_instances       = var.min_instances
  max_instances       = var.max_instances
  health_check_port   = 65534
  region              = var.aws_region
  vpc_id              = var.service_vpc_id
  aws_iam_role_firewall = var.aws_iam_role
  gateway_image       = var.gw_image
  ssh_key_pair        = var.aws_key_name
  security_type       = "INGRESS"

  settings {
    name  = "controller.gateway.assign_public_ip"
    value = "true"
  }
  settings {
    name  = "gateway.aws.ebs.encryption.key.default"
    value = "true"
  }
  settings {
    name  = "gateway.snat_mode"
    value = "0"
  }
}
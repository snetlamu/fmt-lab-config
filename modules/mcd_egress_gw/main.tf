terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
  }
}

resource "ciscomcd_gateway" "aws_hub_gw1" {
  name                   = "${var.name}-egress-gateway"
  description            = "fmt-lab"
  csp_account_name       = var.csp_account_name
  instance_type          = var.gw_instance_type
  gateway_image          = var.gw_image
  gateway_state          = "ACTIVE"
  mode                   = "HUB"
  security_type          = "EGRESS"
  policy_rule_set_id     = ciscomcd_policy_rule_set.hmf-outbound.id
  ssh_key_pair           = var.aws_key_name
  aws_iam_role_firewall  = var.aws_iam_role
  region                 = var.aws_region
  vpc_id                 = var.service_vpc_id
  aws_gateway_lb         = true
}

resource "ciscomcd_policy_rule_set" "hmf-outbound" {
	name = "${var.name}_ingress_policy"
}

resource "ciscomcd_policy_rules" "hmf-outbound_rules" {
	rule_set_id = ciscomcd_policy_rule_set.hmf-outbound.id
	rule {
		name = "outbound"
		action = "Allow Log"
		state = "ENABLED"
		service = 2
		source = 1
		packet_capture_enabled = false
		send_deny_reset = false
		type = "Forwarding"
		destination = 1
	}
}


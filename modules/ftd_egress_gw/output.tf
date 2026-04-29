output "egress_gateway_id" {
  description = "The ID of the Cisco MCD FTDv Egress Gateway"
  value       = ciscomcd_ftdv_gateway.egress-gateway.id
}

output "egress_gateway_name" {
  description = "The name of the Cisco MCD FTDv Egress Gateway"
  value       = ciscomcd_ftdv_gateway.egress-gateway.name
}

output "egress_gateway_csp_account_name" {
  description = "The CSP account name associated with the FTDv Egress Gateway"
  value       = ciscomcd_ftdv_gateway.egress-gateway.csp_account_name
}

output "egress_gateway_region" {
  description = "The AWS region where the FTDv Egress Gateway is deployed"
  value       = ciscomcd_ftdv_gateway.egress-gateway.region
}

output "egress_gateway_vpc_id" {
  description = "The VPC ID where the FTDv Egress Gateway is deployed"
  value       = ciscomcd_ftdv_gateway.egress-gateway.vpc_id
}

output "ciscomcd_account" {
  value = data.ciscomcd_cloud_account.aws.name
}
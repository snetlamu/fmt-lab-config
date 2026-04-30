# output "ftd_egress_policy_id" {
#   description = "The ID of the FTD Egress Access Control Policy"
#   value       = fmc_access_control_policy.ftd_egress_policy.id
# }

# output "ftd_egress_policy_name" {
#   description = "The name of the FTD Egress Access Control Policy"
#   value       = fmc_access_control_policy.ftd_egress_policy.name
# }

output "mcd_ingress_policy_id" {
  description = "The ID of the Cisco MCD Ingress Policy Rule Set"
  value       = ciscomcd_policy_rule_set.mcd_ingress_policy.id
}

output "mcd_ingress_policy_name" {
  description = "The name of the Cisco MCD Ingress Policy Rule Set"
  value       = ciscomcd_policy_rule_set.mcd_ingress_policy.name
}

# output "ftd_s2s_policy_id" {
#   description = "The ID of the FTD S2S Access Control Policy"
#   value       = fmc_access_control_policy.ftd_s2s_policy.id
# }

# output "ftd_s2s_policy_name" {
#   description = "The name of the FTD S2S Access Control Policy"
#   value       = fmc_access_control_policy.ftd_s2s_policy.name
# }

# output "dcloud-pod-hq-ftdv_policy_name" {
#   value = fmc_access_control_policy.fmc_access_policy[0].name
# }
#
# output "dcloud-pod-hq-ftdv_policy_id" {
#   value = fmc_access_control_policy.fmc_access_policy[0].id
# }
#
# output "dcloud-pod-branch-ftdv_policy_name" {
#   value = fmc_access_control_policy.fmc_access_policy[1].name
# }
#
# output "dcloud-pod-branch-ftdv_policy_id" {
#   value = fmc_access_control_policy.fmc_access_policy[1].id
# }


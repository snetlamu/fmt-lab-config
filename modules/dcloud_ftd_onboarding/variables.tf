variable "name" {
  type = string
}

variable "ftd_ips" {
  type        = list(string)
  description = "IPs of the FTDs"
}

variable "device_name" {
  type        = list(string)
  description = "Names of the FTD devices"
}

# variable "dcloud-pod-hq-ftdv_policy_name" {
#   type = string
# }
#
# variable "dcloud-pod-branch-ftdv_policy_name" {
#   type = string
# }


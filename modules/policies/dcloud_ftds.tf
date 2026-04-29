# resource "fmc_access_control_policy" "fmc_access_policy" {
#   count          = length(var.ftd_ips)
#   name           = "${var.device_name[count.index]} Firewall Policy"
#   default_action = "PERMIT"
# }
# Data Sources
data "fmc_network" "any-ipv4" {
  name = "any-ipv4"
}

# resource "fmc_access_control_policy" "ftd_egress_policy" {
#   name                              = "${var.name}_egress_policy"
#   description                       = "${var.name} Egress Access Control Policy"
#   default_action                    = "PERMIT"
#   default_action_log_begin          = true
#   default_action_log_end            = false
#   default_action_send_events_to_fmc = true
#   manage_categories                 = true
# }
#
# resource "fmc_access_rule" "egress" {
#   access_control_policy_id = fmc_access_control_policy.ftd_egress_policy.id
#   action                   = "ALLOW"
#   name                     = "outbound"
#   source_network_objects = [
#     {
#       id   = data.fmc_network.any-ipv4.id
#       type = "Network"
#     }
#   ]
#   log_begin           = false
#   log_end             = true
#   send_events_to_fmc  = true
# }

resource "fmc_access_control_policy" "ftd_egress_policy" {
  name                              = "${var.name}_egress_policy"
  description                       = "${var.name} Egress Access Control Policy"
  default_action                    = "BLOCK"
  default_action_log_begin          = true
  default_action_log_end            = false
  default_action_send_events_to_fmc = true
  manage_rules = true
  rules = [
    {
      action = "ALLOW"
      name   = "Outbound"
      source_network_objects = [
        {
          id   = data.fmc_network.any-ipv4.id
          type = "Network"
        }
      ]
      destination_network_objects = [
        {
          id   = data.fmc_network.any-ipv4.id
          type = "Network"
        }
      ]
      log_begin = false
      log_end   = true
      send_events_to_fmc   = true
    }
  ]
}
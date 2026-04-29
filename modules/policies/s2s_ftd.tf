# Secure Firewall S2s Policy
resource "fmc_access_control_policy" "ftd_s2s_policy" {
  name                              = "${var.name}_s2s_policy"
  description                       = "${var.name} s2s Access Control Policy"
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

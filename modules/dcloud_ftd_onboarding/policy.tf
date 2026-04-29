# resource "fmc_access_control_policy" "dcloud-pod-hq-ftdv" {
#   name                              = "${var.name}-dcloud-pod-hq-ftdv-policy"
#   description                       = "${var.name}-dcloud-pod-hq-ftdv-policy"
#   default_action                    = "BLOCK"
#   default_action_log_begin          = true
#   default_action_log_end            = false
#   default_action_send_events_to_fmc = true
#   manage_rules = true
#   rules = [
#     {
#       section = "mandatory"
#       action  = "ALLOW"
#       name    = "allow_branch_to_hq"
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#       log_begin           = false
#       log_end             = true
#       send_events_to_fmc  = true
#       intrusion_policy_id = data.fmc_intrusion_policy.balanced.id
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_hq_to_dc"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_zones = [
#         {
#           id = fmc_security_zone.hq-lan1x.id
#         },
#         {
#           id = fmc_security_zone.hq-lan2x.id
#         },
#         {
#           id = fmc_security_zone.tunnelx.id
#         }
#       ]
#       destination_zones = [
#         {
#           id = fmc_security_zone.hq-lan1x.id
#         },
#         {
#           id = fmc_security_zone.hq-lan2x.id
#         },
#         {
#           id = fmc_security_zone.tunnelx.id
#         }
#       ]
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_dcloud_to_aws"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_network_objects = [
#         {
#           id   = fmc_network.aws-eks1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.aws-eks2.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.aws-s2s-inside.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-network.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.aws-eks1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.aws-eks2.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.aws-s2s-inside.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-network.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_branch_to_dc"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_dia_outbound"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#       source_zones = [
#         {
#           id = fmc_security_zone.hq-lan1x.id
#         },
#         {
#           id = fmc_security_zone.hq-lan2x.id
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_branch_to_hq"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_zones = [
#         {
#           id = fmc_security_zone.inside.id
#         },
#         {
#           id = fmc_security_zone.sdwanx.id
#         }
#       ]
#       destination_zones = [
#         {
#           id = fmc_security_zone.inside.id
#         },
#         {
#           id = fmc_security_zone.sdwanx.id
#         }
#       ]
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_branch_to_dc"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_dia_outbound"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         }
#       ]
#     }
#   ]
#
# }

##################################

# {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_branch_to_hq2"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_zones = [
#         {
#           id = fmc_security_zone.inside.id
#         },
#         {
#           id = fmc_security_zone.sdwanx.id
#         }
#       ]
#       destination_zones = [
#         {
#           id = fmc_security_zone.inside.id
#         },
#         {
#           id = fmc_security_zone.sdwanx.id
#         }
#       ]
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan1.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-pod-hq-lan2.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_branch_to_dc"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       intrusion_policy_id      = data.fmc_intrusion_policy.balanced.id
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         }
#       ]
#       destination_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         },
#         {
#           id   = fmc_network.dcloud-dc-lan.id
#           type = "Network"
#         }
#       ]
#     },
#     {
#       section                  = "mandatory"
#       action                   = "ALLOW"
#       name                     = "allow_dia_outbound"
#       log_begin                = true
#       log_end                  = false
#       send_events_to_fmc       = true
#       source_network_objects = [
#         {
#           id   = fmc_network.dcloud-pod-branch-lan.id
#           type = "Network"
#         }
#       ]
#     }
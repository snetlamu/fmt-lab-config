terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "2.0.0-rc7"
    }
    sccfm = {
      source = "CiscoDevNet/sccfm"
      version = "0.2.5"
    }
  }
}



################################################################################
# Device Onboarding
################################################################################

# resource "fmc_access_control_policy" "fmc_access_policy" {
#   count          = length(var.ftd_ips)
#   name           = "${var.device_name[count.index]} Firewall Policy"
#   default_action = "PERMIT"
# }


################################################################################
# Device Onboarding - Configuring Serially due to Timeouts
################################################################################


resource "sccfm_ftd_device" "ngfws" {
  count = length(var.device_name)
  name               = var.device_name[count.index]
  licenses           = ["BASE", "MALWARE", "THREAT", "URLFilter"]
  virtual            = true
  performance_tier   = "FTDv"
  access_policy_name = "Default Access Control Policy" #var.dcloud-pod-hq-ftdv_policy_name


  lifecycle {
    ignore_changes = [
      access_policy_name
    ]
  }
}

resource "null_resource" "ngfws_onboarding_script" {
  count = length(var.device_name)
  triggers = {
    generated_command = sccfm_ftd_device.ngfws[count.index].generated_command
    host_ip           = var.ftd_ips[count.index]
  }

  provisioner "local-exec" {
    command     = "python3 sccfm.py --host ${self.triggers.host_ip} --username admin --password Cisco@123 --gen_command '${self.triggers.generated_command}'"
    working_dir = "${path.module}/scripts/device-onboarding"
  }
}

resource "sccfm_ftd_device_onboarding" "ngfws_onboarding" {
  count      = length(var.device_name)
  depends_on = [null_resource.ngfws_onboarding_script]
  ftd_uid    = sccfm_ftd_device.ngfws[count.index].id
}

# resource "time_sleep" "wait_for_hq_onboarding" {
#   depends_on      = [sccfm_ftd_device_onboarding.hq_onboarding]
#   create_duration = "2m"
# }

# resource "sccfm_ftd_device" "branch_ngfw" {
#   depends_on = [sccfm_ftd_device_onboarding.hq_onboarding]
#   name               = var.device_name[1]
#   licenses           = ["BASE", "MALWARE", "THREAT", "URLFilter"]
#   virtual            = true
#   performance_tier   = "FTDv10"
#   access_policy_name = fmc_access_control_policy.dcloud-pod-branch-ftdv.name


#   lifecycle {
#     ignore_changes = [
#       access_policy_name
#     ]
#   }
# }

# resource "null_resource" "branch_onboarding_script" {
#   triggers = {
#     generated_command = sccfm_ftd_device.branch_ngfw.generated_command
#     host_ip           = var.ftd_ips[1]
#   }

#   provisioner "local-exec" {
#     command     = "python3 sccfm.py --host ${self.triggers.host_ip} --username admin --password C1sco12345 --gen_command '${self.triggers.generated_command}'"
#     working_dir = "${path.module}/scripts/device-onboarding"
#   }
# }

# resource "sccfm_ftd_device_onboarding" "branch_onboarding" {
#   depends_on = [null_resource.branch_onboarding_script, sccfm_ftd_device.branch_ngfw]
#   ftd_uid    = sccfm_ftd_device.branch_ngfw.id
# }

# resource "time_sleep" "wait_for_branch_onboarding" {
#   depends_on      = [sccfm_ftd_device_onboarding.branch_onboarding]
#   create_duration = "2m"
# }

# ################################################################################################
# # Devices Data Sources
# ################################################################################################
# data "fmc_device" "devices" {
#   depends_on = [time_sleep.wait_for_branch_onboarding, time_sleep.wait_for_hq_onboarding]
#   count      = length(var.ftd_ips)
#   name       = var.device_name[count.index]
# }

# data "fmc_intrusion_policy" "balanced" {
#   name = "Balanced Security and Connectivity"
# }

# data "fmc_network" "any-ipv4" {
#   name = "any-ipv4"
# }


# ################################################################################################
# # Security Zones
# ################################################################################################

# resource "fmc_security_zone" "aws-tunnelx" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-aws-tunnel"
#   interface_type = "ROUTED"
# }

# resource "fmc_security_zone" "hq-lan1x" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-hq-lan1"
#   interface_type = "ROUTED"
# }

# resource "fmc_security_zone" "hq-lan2x" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-hq-lan2"
#   interface_type = "ROUTED"
# }

# resource "fmc_security_zone" "sdwanx" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-sdwan"
#   interface_type = "ROUTED"
# }

# resource "fmc_security_zone" "tunnelx" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-tunnel"
#   interface_type = "ROUTED"
# }

# resource "fmc_security_zone" "inside" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-inside"
#   interface_type = "ROUTED"
# }

# resource "fmc_security_zone" "outside" {
#   #depends_on = [data.fmc_device.devices]
#   name           = "${var.name}-outside"
#   interface_type = "ROUTED"
# }

# # data "fmc_security_zone" "outside" {
# #   name          = "${var.name}-outside"
# # }
# #
# # data "fmc_security_zone" "inside" {
# #   name          = "${var.name}-inside"
# # }

# ################################################################################################
# # HQ Firewall Physical Interfaces
# ################################################################################################

# # Outside Interface
# resource "fmc_device_physical_interface" "hq_g0_0" {
#   device_id                = data.fmc_device.devices[0].id
#   name                     = "GigabitEthernet0/0"
#   logical_name             = "outside"
#   description              = "PHY-Interface G0/0"
#   mode                     = "NONE"
#   enabled                  = true
#   security_zone_id         = fmc_security_zone.outside.id
#   ipv4_static_address      = "198.18.128.131"
#   ipv4_static_netmask      = "18"
#   enable_sgt_propagate     = true
#   ip_based_monitoring      = true
#   ip_based_monitoring_type = "AUTO"
# }


# # HQ LAN 1
# resource "fmc_device_physical_interface" "hq_g0_1" {
#   device_id                = data.fmc_device.devices[0].id
#   name                     = "GigabitEthernet0/1"
#   logical_name             = "hq-lan1"
#   description              = "PHY-Interface G0/1"
#   mode                     = "NONE"
#   enabled                  = true
#   security_zone_id         = fmc_security_zone.hq-lan1x.id
#   ipv4_static_address      = "198.18.22.1"
#   ipv4_static_netmask      = "24"
#   enable_sgt_propagate     = true
#   ip_based_monitoring      = true
#   ip_based_monitoring_type = "AUTO"
# }

# # HQ LAN 2
# resource "fmc_device_physical_interface" "hq_g0_2" {
#   device_id                = data.fmc_device.devices[0].id
#   name                     = "GigabitEthernet0/2"
#   logical_name             = "hq-lan2"
#   description              = "PHY-Interface G0/2"
#   mode                     = "NONE"
#   enabled                  = true
#   security_zone_id         = fmc_security_zone.hq-lan2x.id
#   ipv4_static_address      = "198.18.7.1"
#   ipv4_static_netmask      = "24"
#   enable_sgt_propagate     = false
#   ip_based_monitoring      = true
#   ip_based_monitoring_type = "AUTO"
# }



# ################################################################################################
# # DC Firewall VTI Interfaces
# ################################################################################################

# # VTI Interface Resources (these will be imported via the deploy script)
# resource "fmc_device_vti_interface" "dc-svti" {
#   device_id                         = data.fmc_device.devices[0].id
#   tunnel_type                       = "STATIC"
#   logical_name                      = "dc-svti"
#   enabled                           = true
#   description                       = "Static VTI to DC"
#   security_zone_id                  = fmc_security_zone.tunnelx.id
#   priority                          = 0
#   tunnel_id                         = 1
#   tunnel_source_interface_id        = fmc_device_physical_interface.hq_g0_0.id
#   tunnel_source_interface_name      = "GigabitEthernet0/0"
#   tunnel_mode                       = "ipv4"
#   ipv4_address                      = "169.254.10.1"
#   ipv4_netmask                      = "30"
#   ip_based_monitoring               = false
#   http_based_application_monitoring = true
# }

# resource "fmc_device_vti_interface" "aws-svti" {
#   device_id                         = data.fmc_device.devices[0].id
#   tunnel_type                       = "STATIC"
#   logical_name                      = "aws-svti"
#   enabled                           = true
#   description                       = "Static VTI to AWS"
#   security_zone_id                  = fmc_security_zone.aws-tunnelx.id
#   priority                          = 0
#   tunnel_id                         = 2
#   tunnel_source_interface_id        = fmc_device_physical_interface.hq_g0_0.id
#   tunnel_source_interface_name      = "GigabitEthernet0/0"
#   tunnel_mode                       = "ipv4"
#   ipv4_address                      = "169.254.2.2"
#   ipv4_netmask                      = "24"
#   ip_based_monitoring               = false
#   http_based_application_monitoring = true
# }

# ################################################################################################
# # DC Firewall Routing
# ################################################################################################

# resource "fmc_device_ipv4_static_route" "aws" {
#   device_id              = data.fmc_device.devices[0].id
#   interface_logical_name = fmc_device_vti_interface.aws-svti.logical_name
#   interface_id           = fmc_device_vti_interface.aws-svti.id
#   destination_networks = [
#     {
#       id = fmc_network.aws-eks2.id
#     },
#     {
#       id = fmc_network.aws-eks1.id
#     },
#     {
#       id = fmc_network.aws-s2s-inside.id
#     }
#   ]
#   #metric               = 1
#   gateway_host_literal = "169.254.2.1"
# }

# resource "fmc_device_ipv4_static_route" "inet_gw" {
#   device_id              = data.fmc_device.devices[0].id
#   interface_logical_name = fmc_device_physical_interface.hq_g0_0.logical_name
#   interface_id           = fmc_device_physical_interface.hq_g0_0.id
#   destination_networks = [
#     {
#       id = data.fmc_network.any-ipv4.id
#     }
#   ]
#   #metric               = 1
#   gateway_host_literal = "198.18.128.1"
# }

# resource "fmc_device_ipv4_static_route" "dc-svti" {
#   device_id              = data.fmc_device.devices[0].id
#   interface_logical_name = fmc_device_vti_interface.dc-svti.logical_name
#   interface_id           = fmc_device_vti_interface.dc-svti.id
#   destination_networks = [
#     {
#       id = fmc_network.dcloud-dc-lan.id
#     }
#   ]
#   #metric               = 1
#   gateway_host_literal = "169.254.10.2"
# }

# ################################################################################################
# # Branch Firewall Physical Interfaces
# ################################################################################################

# # Outside Interface
# resource "fmc_device_physical_interface" "branch_g0_0" {
#   device_id                = data.fmc_device.devices[1].id
#   name                     = "GigabitEthernet0/0"
#   logical_name             = "outside"
#   description              = "PHY-Interface G0/0"
#   mode                     = "NONE"
#   enabled                  = true
#   security_zone_id         = fmc_security_zone.outside.id
#   ipv4_static_address      = "198.18.128.130"
#   ipv4_static_netmask      = "18"
#   enable_sgt_propagate     = true
#   ip_based_monitoring      = true
#   ip_based_monitoring_type = "AUTO"
# }

# # Branch LAN 1
# resource "fmc_device_physical_interface" "branch_g0_1" {
#   device_id                = data.fmc_device.devices[1].id
#   name                     = "GigabitEthernet0/1"
#   logical_name             = "branch-lan"
#   description              = "PHY-Interface G0/1"
#   mode                     = "NONE"
#   enabled                  = true
#   security_zone_id         = fmc_security_zone.inside.id
#   ipv4_static_address      = "198.18.14.1"
#   ipv4_static_netmask      = "24"
#   enable_sgt_propagate     = true
#   ip_based_monitoring      = true
#   ip_based_monitoring_type = "AUTO"
# }


# ################################################################################################
# # Branch Firewall Routes
# ################################################################################################
# resource "fmc_device_ipv4_static_route" "inet_gw2" {
#   device_id              = data.fmc_device.devices[1].id
#   interface_logical_name = fmc_device_physical_interface.branch_g0_0.logical_name
#   interface_id           = fmc_device_physical_interface.branch_g0_0.id
#   destination_networks = [
#     {
#       id = data.fmc_network.any-ipv4.id
#     }
#   ]
#   #metric               = 1
#   gateway_host_literal = "198.18.128.1"
# }


# ################################################################################################
# # Objects
# ################################################################################################

# resource "fmc_host" "dcloud-inet_gw" {
#   name        = "dcloud_internet_gateway"
#   description = "dlcoud internet gateway"
#   ip          = "198.18.128.1"
#   overridable = true
# }

# resource "fmc_network" "dcloud-pod-hq-lan2" {
#   name        = "dcloud-pod-hq-lan2"
#   description = "dcloud-pod-hq-lan2"
#   prefix      = "198.18.7.0/24"
#   overridable = true
# }

# resource "fmc_network" "dcloud-pod-hq-lan1" {
#   name        = "dcloud-pod-hq-lan1"
#   description = "dcloud-pod-hq-lan1"
#   prefix      = "198.18.22.0/24"
#   overridable = true
# }

# resource "fmc_network" "dcloud-pod-branch-lan" {
#   name        = "dcloud-pod-branch-lan"
#   description = "dcloud-pod-branch-lan"
#   prefix      = "198.18.14.0/24"
#   overridable = true
# }

# resource "fmc_network" "aws-s2s-inside" {
#   name        = "aws-s2s-inside"
#   description = "aws-s2s-inside"
#   prefix      = "172.16.3.0/24"
#   overridable = true
# }

# resource "fmc_network" "aws-eks1" {
#   name        = "aws-eks1"
#   description = "aws-eks1"
#   prefix      = "10.2.1.0/24"
#   overridable = true
# }

# resource "fmc_network" "aws-eks2" {
#   name        = "aws-eks2"
#   description = "aws-eks2"
#   prefix      = "10.2.2.0/24"
#   overridable = true
# }

# resource "fmc_host" "dcloud-tunnel-ip" {
#   name        = "dcloud-tunnel-ip"
#   description = "dcloud-tunnel-ip"
#   ip          = "169.254.10.1"
#   overridable = true
# }

# resource "fmc_network" "dcloud-dc-lan" {
#   name        = "dcloud-dc-lan"
#   description = "dcloud-dc-lan"
#   prefix      = "198.18.11.0/24 "
#   overridable = true
# }

# resource "fmc_network" "dcloud-network" {
#   name        = "dcloud-network"
#   description = "dcloud-network"
#   prefix      = "198.18.0.0/26"
#   overridable = true
# }

# ################################################################################################
# # dCloud HQ Firewall Access Policy
# ################################################################################################

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
#     }
#   ]
# }

# ################################################################################################
# # dCloud Branch Firewall Access Policy
# ################################################################################################

# resource "fmc_access_control_policy" "dcloud-pod-branch-ftdv" {
#   name                              = "${var.name}-dcloud-pod-branch-ftdv-policy"
#   description                       = "${var.name}-dcloud-pod-branch-ftdv-policy"
#   default_action                    = "BLOCK"
#   default_action_log_begin          = true
#   default_action_log_end            = false
#   default_action_send_events_to_fmc = true
#   manage_rules = true
#   rules = [
#     {
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
#   ]
# }



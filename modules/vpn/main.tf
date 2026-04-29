terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "2.0.0-rc7"
    }
  }
}

resource "fmc_vpn_s2s" "hq2dc" {
  name             = "hq_to_dc_vpn"
  route_based      = true
  network_topology = "POINT_TO_POINT"
  ikev1            = false
  ikev2            = true
}

resource "fmc_vpn_s2s_endpoints" "dcloud_hq_ftd" {
  vpn_s2s_id = fmc_vpn_s2s.hq2dc.id
  items = {
    dcloud-pod-hq-ftdv = {
      allow_incoming_ikev2_routes = true
      connection_type             = "BIDIRECTIONAL"
      device_id                   = var.dcloud-pod-hq_device_id
      extranet_device             = false
      interface_id                = var.dc_svti_id
      nat_traversal               = true
      peer_type                   = "PEER"
      reverse_route_injection     = false
      send_vti_ip_to_peer         = false
    }
  }
}

resource "fmc_vpn_s2s_endpoints" "dcloud_dc-ftd" {
  vpn_s2s_id = fmc_vpn_s2s.hq2dc.id
  items = {
    dcloud-pod-hq-ftdv = {
      allow_incoming_ikev2_routes = true
      connection_type             = "ORIGINATE_ONLY"
      extranet_device             = true
      extranet_dynamic_ip         = false
      extranet_ip_address         = "198.18.128.254"
      nat_traversal               = true
      peer_type                   = "PEER"
      reverse_route_injection     = false
    }
  }
  depends_on = [fmc_vpn_s2s_ike_settings.hq2dc]
}

resource "fmc_vpn_s2s_ike_settings" "hq2dc" {
  vpn_s2s_id                  = fmc_vpn_s2s.hq2dc.id
  ikev2_authentication_type   = "MANUAL_PRE_SHARED_KEY"
  ikev2_manual_pre_shared_key = "C1sco12345"
}

resource "fmc_vpn_s2s_ipsec_settings" "hq2dc" {
  vpn_s2s_id      = fmc_vpn_s2s.hq2dc.id
  crypto_map_type = "STATIC"
  ikev2_mode      = "TUNNEL"
}
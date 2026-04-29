terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    sccfm = {
      source = "CiscoDevNet/sccfm"
      version = "0.2.5"
    }
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "2.0.0-rc7"
    }
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
  }
}

##################################################
# FTDv and FMCv Instances
##################################################

# Register FTD to FMC
resource "sccfm_ftd_device" "ftd1" {
  name = "${var.name}-S2S-FTDv"
  licenses = [
    "BASE",
    "MALWARE",
    "URLFilter",
    "THREAT"
  ]
  virtual = true
  access_policy_name = var.access_control_policy_name
  performance_tier = "FTDv30"
}

# Query the ASW Marketplace for FTD AMI
data "aws_ami" "ftdv" {
  owners      = ["aws-marketplace"]

 filter {
    name   = "name"
    values = ["${var.FTD_version}*"]
  }

  filter {
    name   = "product-code"
    values = ["a8sxy6easi2zumgtyr564z6y7"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Deploy FTD Instance in AWS
resource "aws_instance" "ftdv" {
  ami                 = data.aws_ami.ftdv.id
  instance_type       = var.ftd_size
  key_name            = var.aws_key_name
  availability_zone   = var.aws_az
  # Assign FTD interfaces to AWS interfaces
  primary_network_interface {
    network_interface_id = var.ftdmgmt_id
    #device_index         = 0
  }

  # Bootstrap Hostname, Password and Mgmt Config
  user_data = <<-EOT
  {
   "EULA": "accept",
   "AdminPassword":"${var.ftd_pass}",
   "Hostname":"${var.name}-S2S-FTDv",
   "ManageLocally":"No",
   "FmcIp":"${sccfm_ftd_device.ftd1.hostname}",
   "FmcRegKey":"${sccfm_ftd_device.ftd1.reg_key}",
   "FmcNatId":"${sccfm_ftd_device.ftd1.nat_id}",
   "IPv4Mode": "dhcp",
   "IPv6Mode": "disabled"
  }
  EOT

  tags = {
    Name = "${var.name}-s2s_FTD"
  }
  depends_on = [sccfm_ftd_device.ftd1]
}

resource "aws_network_interface_attachment" "ftddiag" {
  instance_id          = aws_instance.ftdv.id
  network_interface_id = var.ftddiag_id
  device_index         = 1
}
resource "aws_network_interface_attachment" "ftdoutside" {
  instance_id          = aws_instance.ftdv.id
  network_interface_id = var.ftdoutside_id
  device_index         = 2
}
resource "aws_network_interface_attachment" "ftdinside" {
  instance_id          = aws_instance.ftdv.id
  network_interface_id = var.ftdinside_id
  device_index         = 3
}

# FTD Mgmt Elastic IP
resource "aws_eip" "ftdmgmt-EIP" {
  depends_on = [aws_instance.ftdv]
  tags = {
    "Name" = "${var.name}-s2s FTD Management IP"
  }
}

# FTD Outside Elastic IP
resource "aws_eip" "ftdoutside-EIP" {
  #s2s_vpc   = true
  depends_on = [aws_instance.ftdv]
  tags = {
    "Name" = "${var.name}-s2s FTD outside IP"
  }
}

# Associate FTD Mgmt Interface to External IP
resource "aws_eip_association" "ftd-mgmt-ip-assocation" {
  network_interface_id = var.ftdmgmt_id
  allocation_id        = aws_eip.ftdmgmt-EIP.id
}

# Associate FTD Outside Interface to External IP
resource "aws_eip_association" "ftd-outside-ip-association" {
    network_interface_id = var.ftdoutside_id
    allocation_id        = aws_eip.ftdoutside-EIP.id
}

# FTD registration
# need to make sure the FTDv has finished provisioning before registration — this can be resolved by a custom AMI (container)
resource "null_resource" "wait_for_ftdv_to_finish_booting" {
  # If an IP changes, these scripts will run again
  triggers = {
    nodes_ips = var.ftd_mgmt_ip == "" ? var.ftdmgmt_private_ip : var.ftd_mgmt_ip
  }

  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/wait_for_ftdv.sh ${aws_eip.ftdmgmt-EIP.public_dns}"

  }

  depends_on = [aws_instance.ftdv]
}

resource "sccfm_ftd_device_onboarding" "ftd1" {
  ftd_uid = sccfm_ftd_device.ftd1.id
  depends_on = [null_resource.wait_for_ftdv_to_finish_booting]
}


# Get FTD Device ID
data "fmc_device" "ftd" {
  name = "${var.name}-S2S-FTDv"
  depends_on = [sccfm_ftd_device_onboarding.ftd1]
}

resource "fmc_security_zone" "inside" {
  name           = "${var.name}-inside"
  interface_type = "ROUTED"
}

resource "fmc_security_zone" "outside" {
  name           = "${var.name}-outside"
  interface_type = "ROUTED"
}

resource "fmc_security_zone" "dvti" {
  name           = "${var.name}-DVTI"
  interface_type = "ROUTED"
}

# Create Outside Interface
resource "fmc_device_physical_interface" "outside" {
  device_id              = data.fmc_device.ftd.id
  logical_name           = "outside"
  description            = "External interface of ftd"
  mode                   = "NONE"
  security_zone_id       = fmc_security_zone.outside.id
  name                   = "TenGigabitEthernet0/0"
  enabled                = true
  ipv4_dhcp_obtain_route = true
  ipv4_dhcp_route_metric = 1
}

# Create Insisde Interface
resource "fmc_device_physical_interface" "inside" {
  device_id              = data.fmc_device.ftd.id
  logical_name           = "inside"
  description            = "Internal interface of ftd"
  mode                   = "NONE"
  security_zone_id       = fmc_security_zone.inside.id
  name                   = "TenGigabitEthernet0/1"
  enabled                = true
  ipv4_dhcp_obtain_route = true
  ipv4_dhcp_route_metric = 1
}

resource "fmc_device_loopback_interface" "loopback" {
  device_id           = data.fmc_device.ftd.id
  logical_name        = "VPN"
  enabled             = true
  loopback_id         = 1
  description         = "S2S to dcloud"
  ipv4_static_address = "169.254.2.1"
  ipv4_static_netmask = "24"
}

resource "fmc_device_vti_interface" "vpn_vti" {
  device_id                         = data.fmc_device.ftd.id
  tunnel_type                       = "DYNAMIC"
  logical_name                      = "dcloud"
  enabled                           = true
  description                       = "DVTI"
  security_zone_id                  = fmc_security_zone.dvti.id
  priority                          = 0
  tunnel_id                         = 2
  tunnel_source_interface_id        = fmc_device_physical_interface.outside.id
  tunnel_source_interface_name      = fmc_device_physical_interface.outside.name
  tunnel_mode                       = "ipv4"
  http_based_application_monitoring = true
  borrow_ip_interface_id            = fmc_device_loopback_interface.loopback.id
  borrow_ip_interface_name          = fmc_device_loopback_interface.loopback.name
}

# data "fmc_device_vti_interface" "example" {
#   name      = "Virtual-Template2"
#   device_id = data.fmc_device.ftd.id
# }
#
# output "vti_interface" {
#   value = data.fmc_device_vti_interface.example
# }
# AWS Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                       = "${var.name} Transit Gateway"
  default_route_table_association   = "disable"
  default_route_table_propagation   = "disable"
  tags = {
    Name = "${var.name}-tgw"
  }
}

module "policies" {
  source      = "./modules/policies"
  name        = var.name
  device_name = var.dcloud_device_name
  ftd_ips     = var.dcloud_ftd_ips
}

# Service VPC Module
module "service_vpc" {
  source     = "./modules/service_vpc"
  # Module variables
  name                    = var.name
  aws_region              = var.aws_region
  aws_availability_zones  = var.aws_availability_zones
  aws_tgw_id              = aws_ec2_transit_gateway.tgw.id
  ciscomcd_account        = var.ciscomcd_account
  vpc_cidr                = var.service_vpc_cidr
}

module "mcd_egress_gw" {
  source = "./modules/mcd_egress_gw"
  aws_iam_role      = var.ciscomcd_aws_iam_role
  aws_key_name      = var.aws_key_name
  aws_region        = var.aws_region
  csp_account_name  = var.ciscomcd_account
  gw_image          = var.gw_image
  gw_instance_type  = var.gw_instance_type
  name              = var.name
  max_instances     = 1
  min_instances     = 3
  service_vpc_id    = module.service_vpc.service_vpc_id
}

# module "ftd_egress_gw" {
#   depends_on = [module.service_vpc]
#   source = "./modules/ftd_egress_gw"
#   # Module Variables
#   aws_iam_role      = var.ciscomcd_aws_iam_role
#   aws_key_name      = var.aws_key_name
#   aws_region        = var.aws_region
#   ciscomcd_account  = var.ciscomcd_account
#   egress_policy_id  = module.policies.ftd_egress_policy_id
#   ftd_instance_type = var.ftd_instance_type
#   ftd_password      = var.ftd_password
#   name              = var.name
#   service_vpc_id    = module.service_vpc.service_vpc_id
# }

# MCD Ingress Gateway
module "mcd_ingress_gw" {
  depends_on = [module.service_vpc]
  source     = "./modules/mcd_ingress_gw"
  # Module Variables
  aws_iam_role      = var.ciscomcd_aws_iam_role
  aws_key_name      = var.aws_key_name
  aws_region        = var.aws_region
  gw_image          = var.gw_image
  gw_instance_type  = var.gw_instance_type
  ingress_policy_id = module.policies.mcd_ingress_policy_id
  max_instances     = 3
  min_instances     = 1
  name              = var.name
  csp_account_name  = var.ciscomcd_account
  service_vpc_id    = module.service_vpc.service_vpc_id
}

# module "eks_vpc" {
#   depends_on = [module.service_vpc]
#   source     = "./modules/eks_vpc"
#   # Module Variables
#   name                   = var.name
#   aws_availability_zones = var.aws_availability_zones
#   aws_tgw_id             = aws_ec2_transit_gateway.tgw.id
#   spoke_vpc_cidr         = var.eks_vpc_cidr
#   service_vpc_id         = module.service_vpc.service_vpc_id
# }

# module "s2s_vpc" {
#   depends_on = [module.service_vpc]
#   source     = "./modules/s2s_vpc"
#   # Module Variables
#   name                        = var.name
#   aws_tgw_id                  = aws_ec2_transit_gateway.tgw.id
#   service_vpc_id              = module.service_vpc.service_vpc_id
#   aws_az                      = "us-east-1a"
#   public_access_cidrs         = var.public_access_cidrs
#   dcloud_cidrs                = var.dcloud_cidrs
# }

# module "s2s_ftd" {
#   depends_on = [module.s2s_vpc]
#   source = "./modules/s2s_ftd"
#   FTD_version = "ftdv-7.7*"
#   aws_az                     = "us-east-1a"
#   access_control_policy_id   = module.policies.ftd_s2s_policy_id
#   access_control_policy_name = module.policies.ftd_s2s_policy_name
#   aws_key_name               = var.aws_key_name
#   ftd_pass                   = var.ftd_password
#   ftddiag_id                 = module.s2s_vpc.ftddiag_network_interface_id
#   ftdinside_id               = module.s2s_vpc.ftdinside_network_interface_id
#   ftdmgmt_id                 = module.s2s_vpc.ftdmgmt_network_interface_id
#   ftdmgmt_private_ip         = module.s2s_vpc.ftdmgmt_private_ips
#   ftdoutside_id              = module.s2s_vpc.ftdoutside_network_interface_id
#   name                       = var.name
# }

# module "s2s_ec2" {
#   depends_on = [module.s2s_vpc]
#   source = "./modules/s2s_ec2"
#   # Module Variables
#   inside_subnet_id = module.s2s_vpc.inside_subnet_id
#   key_name         = var.aws_key_name
#   name             = var.name
#   private_ip       = var.s2s_ec2_private_ip
#   sg_id            = module.s2s_vpc.allow_all_sg_id
# }

module "dcloud_ftd_onboarding" {
  source = "./modules/dcloud_ftd_onboarding"
  # dcloud-pod-branch-ftdv_policy_name = module.policies.dcloud-pod-branch-ftdv_policy_name
  # dcloud-pod-hq-ftdv_policy_name     = module.policies.dcloud-pod-hq-ftdv_policy_name
  device_name = var.dcloud_device_name
  ftd_ips     = var.dcloud_ftd_ips
  name        = var.name
}

# module "vpn" {
#   depends_on = [module.dcloud_ftd_onboarding]
#   source = "./modules/vpn"
#   dc_svti_id              = module.dcloud_ftd_onboarding.dc-svti_id
#   dcloud-pod-hq_device_id = module.dcloud_ftd_onboarding.hq_ftd_device_id
# }

# module "eks_cluster" {
#   #depends_on = [module.ftd_egress_gw]
#   source = "./modules/eks_cluster"
#   aws_region       = var.aws_region
#   name             = var.name
#   spoke_subnet_ids = module.eks_vpc.spoke_subnet_ids
#   spoke_vpc_id     = module.eks_vpc.spoke_vpc_id
# }

# resource "fmc_device_deploy" "dcloud" {
#   ignore_warning  = true
#   device_id_list  = [module.dcloud_ftd_onboarding.devices[0].id, module.dcloud_ftd_onboarding.devices[1].id]
#   deployment_note = "Terraform initiated deployment"
#   depends_on = [module.dcloud_ftd_onboarding,module.s2s_vpc, module.eks_cluster]
# }



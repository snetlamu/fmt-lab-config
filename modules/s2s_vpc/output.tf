output "s2s_vpc_id" {
  description = "The ID of the FTD VPC"
  value       = aws_vpc.ftd_vpc.id
}

output "s2s_vpc_cidr_block" {
  description = "The CIDR block of the FTD VPC"
  value       = aws_vpc.ftd_vpc.cidr_block
}

output "mgmt_subnet_id" {
  description = "The ID of the Management Subnet"
  value       = aws_subnet.mgmt_subnet.id
}

output "mgmt_subnet_cidr_block" {
  description = "The CIDR block of the Management Subnet"
  value       = aws_subnet.mgmt_subnet.cidr_block
}

output "diag_subnet_id" {
  description = "The ID of the Diag Subnet"
  value       = aws_subnet.diag_subnet.id
}

output "diag_subnet_cidr_block" {
  description = "The CIDR block of the Diag Subnet"
  value       = aws_subnet.diag_subnet.cidr_block
}

output "outside_subnet_id" {
  description = "The ID of the Outside Subnet"
  value       = aws_subnet.outside_subnet.id
}

output "outside_subnet_cidr_block" {
  description = "The CIDR block of the Outside Subnet"
  value       = aws_subnet.outside_subnet.cidr_block
}

output "inside_subnet_id" {
  description = "The ID of the Inside Subnet"
  value       = aws_subnet.inside_subnet.id
}

output "inside_subnet_cidr_block" {
  description = "The CIDR block of the Inside Subnet"
  value       = aws_subnet.inside_subnet.cidr_block
}

output "ftd_sg_id" {
  description = "The ID of the FTD Outside Security Group"
  value       = aws_security_group.ftd_sg.id
}

output "ftd_sg_name" {
  description = "The name of the FTD Outside Security Group"
  value       = aws_security_group.ftd_sg.name
}

output "ftd_mgmt_sg_id" {
  description = "The ID of the FTD Management Security Group"
  value       = aws_security_group.ftd_mgmt.id
}

output "ftd_mgmt_sg_name" {
  description = "The name of the FTD Management Security Group"
  value       = aws_security_group.ftd_mgmt.name
}

output "allow_all_sg_id" {
  description = "The ID of the 'Allow All' Security Group"
  value       = aws_security_group.allow_all.id
}

output "allow_all_sg_name" {
  description = "The name of the 'Allow All' Security Group"
  value       = aws_security_group.allow_all.name
}

output "ftdmgmt_network_interface_id" {
  description = "The ID of the FTD Management Network Interface"
  value       = aws_network_interface.ftdmgmt.id
}

output "ftdmgmt_private_ips" {
  description = "The private IP addresses of the FTD Management Network Interface"
  value       = aws_network_interface.ftdmgmt.private_ip
}

output "ftddiag_network_interface_id" {
  description = "The ID of the FTD Diag Network Interface"
  value       = aws_network_interface.ftddiag.id
}

output "ftdoutside_network_interface_id" {
  description = "The ID of the FTD Outside Network Interface"
  value       = aws_network_interface.ftdoutside.id
}

output "ftdoutside_private_ips" {
  description = "The private IP addresses of the FTD Outside Network Interface"
  value       = aws_network_interface.ftdoutside.private_ips
}

output "ftdinside_network_interface_id" {
  description = "The ID of the FTD Inside Network Interface"
  value       = aws_network_interface.ftdinside.id
}

output "ftdinside_private_ips" {
  description = "The private IP addresses of the FTD Inside Network Interface"
  value       = aws_network_interface.ftdinside.private_ips
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.int_gw.id
}

output "spoke_to_service_vpc_id" {
  description = "The ID of the Cisco MCD Spoke VPC attachment to Service VPC"
  value       = ciscomcd_spoke_vpc.spoke_to_service.id
}

output "ftd_outside_route_table_id" {
  description = "The ID of the FTD Outside Route Table"
  value       = aws_route_table.ftd_outside_route.id
}

output "ftd_inside_route_table_id" {
  description = "The ID of the FTD Inside Route Table"
  value       = aws_route_table.ftd_inside_route.id
}

output "ext_default_route_id" {
  description = "The ID of the external default route in the Outside Route Table"
  value       = aws_route.ext_default_route.id
}

output "inside_default_route_id" {
  description = "The ID of the inside default route in the Inside Route Table"
  value       = aws_route.inside_default_route.id
}

output "inside_tgw_route_id" {
  description = "The ID of the inside TGW route in the Inside Route Table"
  value       = aws_route.inside_tgw_route.id
}

# Environment

variable "name" {
  type = string
}

variable "aws_availability_zones" {
  type = list(string)
}

variable "aws_tgw_id" {
  description = "root module - resource aws_ec2_transit_gateway.tgw.id"
}

variable "spoke_vpc_cidr" {
  type = string
}

## Multicloud Defense ##
variable "service_vpc_id" {
  description = "service_vpc module - resource ciscomcd_service_vpc.service-vpc.id"
}


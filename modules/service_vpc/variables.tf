# Environment Variables

# The name prefix for resources
variable "name" {
  type = string
}

# The AWS region where resources will be deployed
variable "aws_region" {
  type = string
}

# List of availability zones in the specified AWS region
variable "aws_availability_zones" {
  type = list(string)
}

# The ID of the AWS Transit Gateway
variable "aws_tgw_id" {}

# # The name of the AWS SSH key pair to use for instances
# variable "aws_key_name" {
#   type = string
# }

# Multicloud Defense Variables

# The Cisco Multicloud Defense account name
variable "ciscomcd_account" {
  type = string
}

# # The IAM role for the AWS firewall
# variable "aws_iam_role" {
#   type = string
# }


# The CIDR block for the VPC
variable "vpc_cidr" {
  type = string
}

# variable "ftd_instance_type" {
#   type = string
# }
#
# variable "ftd_password" {
#   type = string
# }


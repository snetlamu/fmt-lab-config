# The name prefix for resources
variable "name" {
  type = string
}

# The Cisco Multicloud Defense account name
variable "ciscomcd_account" {
  type = string
}

variable "service_vpc_id" {
  type = string
  description = "Service VPC ID"
}

# The AWS region where resources will be deployed
variable "aws_region" {
  type = string
}

variable "ftd_instance_type" {
  type = string
}

# The IAM role for the AWS firewall
variable "aws_iam_role" {
  type = string
}

# The name of the AWS SSH key pair to use for instances
variable "aws_key_name" {
  type = string
}

variable "egress_policy_id" {
  type = string
  description = "Multicloud Defense Egress Policy Name"
}

variable "ftd_password" {
  type = string
}
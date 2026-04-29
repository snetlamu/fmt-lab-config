variable "csp_account_name" {
  type = string
  description = "MCD Account Name"
}

variable "name" {
  type = string
}

variable "service_vpc_id" {
  type = string
  description = "Service VPC ID"
}

# The instance type for the gateway
variable "gw_instance_type" {
  type = string
}


# The minimum number of instances for the gateway
variable "min_instances" {
  type = number
}

# The maximum number of instances for the gateway
variable "max_instances" {
  type = number
}

# The AWS region where resources will be deployed
variable "aws_region" {
  type = string
}

# The IAM role for the AWS firewall
variable "aws_iam_role" {
  type = string
}

# The image ID for the gateway
variable "gw_image" {
  type = string
}

# The name of the AWS SSH key pair to use for instances
variable "aws_key_name" {
  type = string
}
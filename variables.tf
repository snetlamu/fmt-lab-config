variable "api_key_filename" {
  type = string
}
# AWS
variable "aws_access_key" {
  type = string
}
variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_availability_zones" {
  type = list(string)
}

variable "aws_key_name" {
  type = string
}

# Security Cloud Control

variable "scc_token" {
  type = string
}

variable "cdFMC" {
  type = string
}

# Multicloud Defense
variable "ciscomcd_account" {
  type = string
  description = "Multicloud Defense Account"
}
variable "ciscomcd_aws_iam_role" {
  type = string
  description = "IAM Role for Cisco Multicloud Defense in AWS"
}

variable "gw_instance_type" {
  type = string
  description = "Gateway Instance Type"
}
variable "gw_image" {
  type = string
  description = "Gateway Image ID"
}
variable "ftd_instance_type" {
  type = string
  description = "Instance type ex: AWS_C5_XLARGE"
}
# variable "ftdv_instance_size" {
#   type = string
# }
variable "ftd_password" {
  type = string
  description = "password for cdFMC registration"
}

variable "service_vpc_cidr" {
  type = string
  description = "CIDR Block for the Service VPC"
}

variable "aws_min_instances" {
  type = number
  description = "Minimum Number of Gateway Instances"
}
variable "aws_max_instances" {
  type = number
  description = "Maximum Number of Gateway Instances"
}

# S2S VPC
variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "dcloud_cidrs" {
  type = list(string)
  description = "dCloud subnets that need access to AWS"
}

variable "public_access_cidrs" {
  type = list(string)
}

variable "s2s_ec2_private_ip" {
  type = string
  default = "172.16.3.20"
}

# dCloud
variable "dcloud_ftd_ips" {
  type        = list(string)
  description = "IPs of the FTDs"
}

variable "dcloud_device_name" {
  type        = list(string)
  description = "Names of the FTD devices"
}

# Environment Variables

variable "name" {
  type = string
  description = "name tagged to all resources"
}
variable "name" {
  description = "Name of the lab environment"
  type = string
}

variable "aws_az" {
  type = string
  default = "us-east-1a"
}

# variable "int_gw" {
#   type = string
# }

variable "aws_key_name" {
  type = string
}

variable "ftdmgmt_id" {
  type = string
}

variable "ftddiag_id" {
  type = string
}

variable "ftdoutside_id" {
  type = string
}

variable "ftdinside_id" {
  type = string
}

variable "ftdmgmt_private_ip" {
  type = string
}

variable "ftd_mgmt_ip" {
  type = string
  default = "172.16.0.10"
}

variable "FTD_version" {
  type = string
  #default = "ftdv-7.3.0"
}

variable "ftd_pass" {
  description = "FMC Password"
  type = string
  sensitive = true
}

variable "ftd_size" {
  type = string
  default = "c5.xlarge"
}

variable "access_control_policy_name" {
  type = string
  description = "FTD Access Control Policy"
}

variable "access_control_policy_id" {
  type = string
  description = "FTD Access Control Policy"
}

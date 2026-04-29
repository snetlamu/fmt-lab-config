variable "name" {
  description = "Name of the lab environment"
  type = string
}

variable "aws_tgw_id" {
  type = string
}

variable "service_vpc_id" {
  type = string
}

variable "aws_az" {
  type = string
  default = "us-east-1a"
}


variable "vpc_cidr" {
  type = string
  default = "172.16.0.0/16"
}

variable "mgmt_subnet" {
  type = string
  default = "172.16.0.0/24"
}

variable "ftd_mgmt_ip" {
  type = string
  default = "172.16.0.10"
}


variable "outside_subnet" {
  type = string
  default = "172.16.2.0/24"
}

variable "ftd_outside_ip" {
  type = string
  default = "172.16.2.10"
}

variable "inside_subnet" {
  type = string
  default = "172.16.3.0/24"
}

variable "ftd_inside_ip" {
  type = string
  default = "172.16.3.10"
}

variable "diag_subnet" {
  type = string
  default = "172.16.1.0/24"
}


variable "public_access_cidrs" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "dcloud_cidrs" {
  type = list(string)
  description = "dCloud subnets that need access to AWS"
}

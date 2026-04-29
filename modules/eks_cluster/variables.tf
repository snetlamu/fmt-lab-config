
# EKS Cluster
variable "aws_region" {
  type = string
}
variable "spoke_vpc_id" {
  type = string
}
variable "spoke_subnet_ids" {
}

variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

# Environment
variable "name" {
  type = string
}


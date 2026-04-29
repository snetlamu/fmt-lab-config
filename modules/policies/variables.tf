variable "name" {
  type = string
}

variable "ftd_ips" {
  type        = list(string)
  description = "IPs of the FTDs"
}

variable "device_name" {
  type        = list(string)
  description = "Names of the FTD devices"
}
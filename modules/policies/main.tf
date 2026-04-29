terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "25.8.1"
    }
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "2.0.0-rc7"
    }
    sccfm = {
      source = "CiscoDevNet/sccfm"
      version = "0.2.5"
    }
  }
}
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
    # kubernetes = {
    #   source = "hashicorp/kubernetes"
    #   version = "2.38.0"
    # }
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "ciscomcd" {
  api_key_file = file(var.api_key_filename)
}

provider "fmc" {
  token = var.scc_token
  url = "https://${var.cdFMC}"
}

provider "sccfm" {
  api_token = var.scc_token
  base_url = "https://www.defenseorchestrator.com"
}

# provider "kubernetes" {
#   host                   = module.eks_cluster.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
#   token                  = module.eks_cluster.eks_auth_token
#   # config_path            = "~/.kube/config"
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks_cluster.eks_cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
#     token                  = module.eks_cluster.eks_auth_token
#     # config_path            = "~/.kube/config"
#   }
# }







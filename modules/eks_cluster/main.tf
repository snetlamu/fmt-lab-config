terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name               = "hmf-lab"
  kubernetes_version = "1.33"


  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = true

  # List of CIDR blocks which can access the Amazon EKS public API server endpoint
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.spoke_vpc_id
  subnet_ids = var.spoke_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    eks_node = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Name = "hmf-lab"
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
  depends_on = [module.eks]
}

# resource "null_resource" "update-kubeconfig" {
#   provisioner "local-exec" {
#     command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
#     #command = "kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/latest/download/stripped-down-crds.yaml"
#   }
#   depends_on = [time_sleep.wait_30_seconds]
# }
#
# resource "null_resource" "prometheus" {
#   provisioner "local-exec" {
#     #command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
#     command = "kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/latest/download/stripped-down-crds.yaml"
#   }
#   depends_on = [null_resource.update-kubeconfig]
# }

module "prometheous" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.21.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_kube_prometheus_stack = true
  enable_metrics_server        = true

  tags = {
    cluster = data.aws_eks_cluster.eks.name
  }

  depends_on = [time_sleep.wait_30_seconds]
}

resource "helm_release" "cilium" {
  name        = "cilium"
  description = "A Helm chart to deploy cilium"
  namespace   = "kube-system"
  chart       = "cilium"
  version     = "1.18.4"
  repository  = "https://helm.isovalent.com"
  wait        = false

  # pass the cluster_endpoint to the helm values so that we can configure kube-proxy replacement.
  set {
    name  = "k8sServiceHost"
    value = trimprefix(module.eks.cluster_endpoint, "https://")
  }
  set {
    name  = "cluster.name"
    value = module.eks.cluster_name
  }
  set {
    name  = "cluster.id"
    value = 0
  }
  values = [file("${path.module}/cilium-enterprise-values.yaml")]

  depends_on = [module.prometheous]
}

# add the other wanted features.
module "enable_others" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.21.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = var.spoke_vpc_id
      }
    ]
  }

  tags = {
    cluster = data.aws_eks_cluster.eks.name
  }

  depends_on = [helm_release.cilium]
}

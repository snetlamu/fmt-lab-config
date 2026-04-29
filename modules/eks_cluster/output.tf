output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_auth_token" {
  value = data.aws_eks_cluster_auth.eks_auth.token
}
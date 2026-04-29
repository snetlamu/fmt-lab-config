
output "spoke_vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "spoke_subnet_ids" {
  value =  aws_subnet.spoke_subnet[*].id
}
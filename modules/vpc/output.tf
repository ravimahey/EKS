output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_subnets_ids" {
  value = module.public_subnets.subnet_ids
}
output "private_subnet_ids" {
  value = module.private_subnets.subnet_ids
}
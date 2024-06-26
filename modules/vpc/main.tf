
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_prefix}-vpc"
  }
}

module "public_subnets" {
  source         = "./subnet"
  cluster_prefix = var.cluster_prefix
  vpc_id         = aws_vpc.vpc.id
  subnet_type    = "public"
  cidr           = var.cidr
  subnet_bits    = var.subnet_bits
  offset         = 0
}

module "private_subnets" {
  source         = "./subnet"
  cluster_prefix = var.cluster_prefix
  vpc_id         = aws_vpc.vpc.id
  subnet_type    = "private"
  cidr           = var.cidr
  subnet_bits    = var.subnet_bits
  offset          = 1
}

module "storage_subnets" {
  source         = "./subnet"
  cluster_prefix = var.cluster_prefix
  vpc_id         = aws_vpc.vpc.id
  subnet_type    = "storage"
  cidr           = var.cidr
  subnet_bits    = var.subnet_bits
  offset         = 2
}


module "internet_gateway" {
  source         = "./gateway"
  cluster_prefix = var.cluster_prefix
  vpc_id         = aws_vpc.vpc.id
  gateway_type   = "internet"
}

module "nat_gateway" {
  source         = "./gateway"
  cluster_prefix = var.cluster_prefix
  vpc_id         = aws_vpc.vpc.id
  gateway_type   = "nat"
  subnet_id = module.public_subnets.subnet_ids[0]
}

output "gwi" {
  value =  module.internet_gateway.internet_gateway_id
}

module "public_route_table" {
  source           = "./route_table"
  cluster_prefix   = var.cluster_prefix
  vpc_id           = aws_vpc.vpc.id
  subnet_ids       = module.public_subnets.subnet_ids
  route_table_type = "public"
  internet_gateway_id = module.internet_gateway.internet_gateway_id

}

module "private_route_table" {
  source           = "./route_table"
  cluster_prefix   = var.cluster_prefix
  vpc_id           = aws_vpc.vpc.id
  subnet_ids       = module.private_subnets.subnet_ids
  route_table_type = "private"
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

module "storage_route_table" {
  source           = "./route_table"
  cluster_prefix   = var.cluster_prefix
  vpc_id           = aws_vpc.vpc.id
  subnet_ids       = module.storage_subnets.subnet_ids
  route_table_type = "private"
  nat_gateway_id   =  module.nat_gateway.nat_gateway_id
}


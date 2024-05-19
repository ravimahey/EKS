
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

module "private_subnet" {
  source         = "./subnet"
  cluster_prefix = var.cluster_prefix
  vpc_id         = aws_vpc.vpc.id
  subnet_type    = "private"
  cidr           = var.cidr
  subnet_bits    = var.subnet_bits
  offset          = 1
}

module "storage_subnet" {
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
}

module "public_route_table" {
  source           = "./route_table"
  cluster_prefix   = var.cluster_prefix
  vpc_id           = aws_vpc.vpc.id
  subnet_ids       = module.public_subnet.subnet_ids
  route_table_type = "public"
}

module "private_route_table" {
  source           = "./route_table"
  cluster_prefix   = var.cluster_prefix
  vpc_id           = aws_vpc.vpc.id
  subnet_ids       = module.private_subnet.subnet_ids
  route_table_type = "private"
}

module "storage_route_table" {
  source           = "./route_table"
  cluster_prefix   = var.cluster_prefix
  vpc_id           = aws_vpc.vpc.id
  subnet_ids       = module.storage_subnet
  route_table_type = "private"
}


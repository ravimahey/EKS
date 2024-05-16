# AWS Availability Zones
data "aws_availability_zones" "available_zones" {}

locals {
  offset = length(data.aws_availability_zones.available_zones.names)
}

#  This code creates an AWS VPC (Virtual Private Cloud) with the specified CIDR block, enabling DNS support and hostnames. It also assigns tags to the VPC for identification.  #
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_prefix}-vpc"
  }
}

#  This code creates AWS public subnets within a VPC, each associated with a unique CIDR block and availability zone, and tagged for identification. #
resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.vpc,
  ]
  count             = length(data.aws_availability_zones.available_zones.names)
  cidr_block        = cidrsubnet(var.cidr, var.subnet_bits, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name       = "${var.cluster_prefix}-public-subnet-${count.index + 1}"
    Visibility = "Public"
  }
}


#   This code creates AWS private subnets within a VPC, each associated with a unique CIDR block and availability zone, and tagged for identification as private subnets.  #
resource "aws_subnet" "private" {
  depends_on = [
    aws_vpc.vpc
  ]
  count             = length(data.aws_availability_zones.available_zones.names)
  cidr_block        = cidrsubnet(var.cidr, var.subnet_bits, local.offset + count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name       = "${var.cluster_prefix}-private-subnet-${count.index + 1}"
    Visibility = "Private"
  }
}

#   This code creates AWS private subnets within a VPC, each associated with a unique CIDR block and availability zone, and tagged for identification as private subnets.  #
resource "aws_subnet" "storage" {
  depends_on = [
    aws_vpc.vpc
  ]
  count             = length(data.aws_availability_zones.available_zones.names)
  cidr_block        = cidrsubnet(var.cidr, var.subnet_bits, 2 * local.offset + count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name       = "${var.cluster_prefix}-storage-subnet-${count.index + 1}"
    Visibility = "Private"
  }
}




# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public
  ]

  # VPC in which it has to be created!
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.cluster_prefix}-igw"
  }
}


# Creating an Route Table for the public subnet!
resource "aws_route_table" "public_rt" {
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.igw
  ]

  # VPC ID
  vpc_id = aws_vpc.vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_prefix}-public-rt"
  }
}


# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "public_igw_associations" {

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.public,
    aws_route_table.public_rt
  ]
  count = length(data.aws_availability_zones.available_zones.names)
  # Public Subnet ID
  subnet_id = aws_subnet.public[count.index].id
  #  Route Table ID
  route_table_id = aws_route_table.public_rt.id
}





# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "nat_gw_ip" {
  tags = {
    Name = "${var.cluster_prefix}-ip"
  }
}


# Creating a NAT Gateway!
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_ip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.cluster_prefix}-nat"
  }
}


# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "private_rt" {
  depends_on = [aws_nat_gateway.nat_gw]
  vpc_id     = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.cluster_prefix}-private-rt"
  }
}


resource "aws_route_table_association" "nat_gw_associations" {
  depends_on     = [aws_route_table.private_rt]
  count          = length(data.aws_availability_zones.available_zones.names)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

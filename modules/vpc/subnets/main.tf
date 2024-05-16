
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.available_zones.names)
  cidr_block        = cidrsubnet(var.cidr, var.subnet_bits, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name       = "${var.cluster_prefix}-public-subnet-${count.index + 1}"
    Visibility = "Public"
  }
}
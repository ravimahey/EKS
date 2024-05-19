resource "aws_internet_gateway" "this" {
  count = var.gateway_type == "internet" ? 1 : 0

  vpc_id = var.vpc_id

  tags = {
      Name = "${var.cluster_prefix}-${var.gateway_type}-gateway"
    }
}

resource "aws_eip" "nat" {
  count = var.gateway_type == "nat" ? 1 : 0
  
  tags = {
    Name = "${var.cluster_prefix}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.gateway_type == "nat" ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = var.subnet_id

  tags = {
      Name = "${var.cluster_prefix}-nat-gateway"
    }
}

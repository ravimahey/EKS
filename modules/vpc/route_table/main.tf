resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.route_table_type == "public" ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.internet_gateway_id
    }
  }

  dynamic "route" {
    for_each = var.route_table_type == "private" ? [1] : []
    content {
      cidr_block   = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_id
    }
  }

  tags = {
    Name = "${var.cluster_prefix}-${var.route_table_type}-rt"
  }
}

resource "aws_route_table_association" "this" {
  count          = length(var.subnet_ids)
  subnet_id      = element(var.subnet_ids, count.index)
  route_table_id = aws_route_table.this.id
}

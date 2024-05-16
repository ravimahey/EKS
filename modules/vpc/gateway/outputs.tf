output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = var.gateway_type == "internet" ? aws_internet_gateway.this[0].id : null
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = var.gateway_type == "nat" ? aws_nat_gateway.this[0].id : null
}

output "nat_gateway_eip" {
  description = "The Elastic IP of the NAT Gateway"
  value       = var.gateway_type == "nat" ? aws_eip.nat[0].public_ip : null
}

variable "cluster_prefix" {
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "gateway_type" {
  description = "Type of gateway: nat or internet"
  type        = string
  validation {
    condition     = contains(["nat", "internet"], var.gateway_type)
    error_message = "gateway_type must be either 'nat' or 'internet'."
  }
}

variable "subnet_id" {
  description = "The ID of the subnet in which to place the NAT Gateway (required if NAT Gateway)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the gateway"
  type        = map(string)
  default     = {}
}

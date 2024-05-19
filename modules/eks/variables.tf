# Terraform Variables
variable "cluster_prefix" {
  description = "To apply generic naming to EKS Cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS Cluster"
  type        = string
  default     = "1.29"
}

variable "eks_cluster_enabled_log_types" {
  description = "List of Control Plane Logging options to enable"
  type        = list(any)
  default     = ["api", "audit"]
}

variable "eks_cluster_log_retention_in_days" {
  description = "Cloudwatch log events retention period in days for EKS Cluster"
  type        = number
  default     = 7
}

variable "eks_cluster_service_ipv4_cidr" {
  description = "EKS Cluster - Kubernetes Service IP address range"
  type        = string
  default     = "10.43.0.0/16"
}

variable "eks_cluster_create_timeout" {
  description = "Average wait time in minutes for the EKS Cluster to be created"
  type        = string
  default     = "30m"
}

variable "eks_cluster_delete_timeout" {
  description = "Average wait time in minutes for the EKS Cluster to be deleted"
  type        = string
  default     = "15m"
}

variable "eks_cluster_update_timeout" {
  description = "Average wait time in minutes for the EKS Cluster to be updated"
  type        = string
  default     = "60m"
}

variable "private_subnet_ids" {
  type = list(string)
}
# Example terraform.tfvars

cluster_prefix = "fabulate"
region         = "ap-southeast-2"

cidr        = "10.0.0.0/16"
subnet_bits = 4

kubernetes_version                = "1.29"
eks_cluster_enabled_log_types     = ["api", "audit"]
eks_cluster_log_retention_in_days = 7
eks_cluster_service_ipv4_cidr     = "10.43.0.0/16"
eks_cluster_create_timeout        = "30m"
eks_cluster_delete_timeout        = "15m"
eks_cluster_update_timeout        = "60m"




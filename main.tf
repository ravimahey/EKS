module "vpc" {
  source = "./modules/vpc"
  cluster_prefix = "${var.cluster_prefix}-test"
  cidr = var.cidr
  subnet_bits = var.subnet_bits
}

module "eks" {
  source = "./modules/eks"
  cluster_prefix = "${var.cluster_prefix}-test"
  kubernetes_version = var.kubernetes_version

  private_subnet_ids = module.vpc.private_subnet_ids

  eks_cluster_enabled_log_types = var.eks_cluster_enabled_log_types
}
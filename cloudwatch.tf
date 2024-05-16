resource "aws_cloudwatch_log_group" "eks_cluster_cloudwatch_log_group" {
  count             = length(var.eks_cluster_enabled_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${var.cluster_prefix}-cluster"
  retention_in_days = var.eks_cluster_log_retention_in_days

  tags = {
    Name        = "${var.cluster_prefix}-cloudwatch"
    Environment = "all-environments"
  }
}

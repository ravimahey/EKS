data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
    ]
  }
}

data "aws_iam_policy_document" "eks_cluster_elb_service_link_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddresses"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
}

resource "aws_iam_policy" "eks_cluster_elb_service_link_policy" {
  name   = "${var.cluster_prefix}-eks-cluster-elb-service-link-policy"
  policy = data.aws_iam_policy_document.eks_cluster_elb_service_link_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_elb_service_link_policy_attachment" {
  policy_arn = aws_iam_policy.eks_cluster_elb_service_link_policy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_prefix}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }
  kubernetes_network_config {
    service_ipv4_cidr = var.eks_cluster_service_ipv4_cidr
  }

  timeouts {
    create = var.eks_cluster_create_timeout
    delete = var.eks_cluster_delete_timeout
    update = var.eks_cluster_update_timeout
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller_policy,
    aws_cloudwatch_log_group.eks_cluster_cloudwatch_log_group
  ]

  tags = {
    Name        = "${var.cluster_prefix}-cluster"
    Environment = "all-environment"
  }
}

resource "aws_cloudwatch_log_group" "eks_cluster_cloudwatch_log_group" {
  count             = length(var.eks_cluster_enabled_log_types) > 0 ? 1 : 0
  name              = "/aws/eks/${var.cluster_prefix}-cluster"
  retention_in_days = var.eks_cluster_log_retention_in_days

  tags = {
    Name        = "${var.cluster_prefix}-cloudwatch"
    Environment = "all-environments"
  }
}

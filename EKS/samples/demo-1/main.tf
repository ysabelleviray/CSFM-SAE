# EKS configuration with ALB, IAM, S3, Secrets Manager, and Cloudwatch

# AWS Provider
provider "aws" {
  region = "us-west-2"
}

# VPC Module for Networking
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.vpc_name
  cidr   = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

# EKS IAM Role and Policies
module "iam_eks_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  role_name   = var.eks_role_name

  cluster_service_accounts = var.cluster_service_accounts

  tags = var.eks_role_tags

  role_policy_arns = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }
}

# EKS Cluster Module
module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnet_ids        = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id

  eks_managed_node_groups = var.eks_managed_node_groups
  fargate_profiles = var.fargate_profiles
}

# IAM Role Policy Attachment for ALB
resource "aws_iam_role_policy_attachment" "alb_policy_attachment" {
  policy_arn = aws_iam_policy.alb_policy.arn
  role       = module.eks.eks_managed_node_groups["eks_nodes"].iam_role_name
}

# Application Load Balancer (ALB)
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  name   = var.alb_name
  internal = false
  load_balancer_type = "application"
  security_groups = [module.vpc.default_security_group_id]
  subnets         = module.vpc.public_subnets
  enable_deletion_protection = false

  target_groups = var.target_groups
}

# IAM Policy for ALB to Interact with EC2 and EKS
resource "aws_iam_policy" "alb_policy" {
  name        = var.alb_policy_name
  description = "IAM policy for ALB to interact with EKS worker nodes"
  policy      = jsonencode(var.alb_policy_document)
}

# S3 Bucket for Storing Logs
resource "aws_s3_bucket" "eks_logs" {
  bucket = var.eks_logs_bucket_name

  tags = var.eks_logs_bucket_tags
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "eks_logs_acl" {
  bucket = aws_s3_bucket.eks_logs.id
  acl    = "private"
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "eks_logs_versioning" {
  bucket = aws_s3_bucket.eks_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Secrets Manager for Storing Database Credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.db_credentials_name
  description = var.db_credentials_description
}

# Store the actual secret value using aws_secretsmanager_secret_version
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode(var.db_credentials_values)
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks_logs_group" {
  name = var.eks_logs_group_name
}

# CloudWatch Metric Alarm for Monitoring EKS Cluster Health
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name                = "high-cpu-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EKS"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This alarm triggers if CPU usage exceeds 80% for 2 consecutive periods"
  dimensions = {
    ClusterName = module.eks.cluster_name
  }

  actions_enabled = true
}

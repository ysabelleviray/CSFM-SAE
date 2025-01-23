output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "load_balancer_dns" {
  value = module.alb.dns_name
}

output "s3_bucket" {
  value = aws_s3_bucket.eks_logs.bucket
}

output "secrets_manager_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.eks_logs_group.name
}

 # EKS Cluster Outputs
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "load_balancer_controller_role_arn" {
  description = "IAM Role ARN for the ALB controller"
  value       = module.lb_role.iam_role_arn
}

output "load_balancer_controller_service_account_name" {
  description = "Service Account Name for the ALB controller"
  value       = kubernetes_service_account.service-account.metadata[0].name
}

output "alb_controller_helm_release" {
  description = "Helm release for the AWS Load Balancer Controller"
  value       = helm_release.alb-controller.name
}

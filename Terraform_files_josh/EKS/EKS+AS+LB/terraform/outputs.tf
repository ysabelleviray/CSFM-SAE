output "cluster_name" {
    description = "The name of the EKS cluster"
    value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
    description = "The endpoint for the EKS Kubernetes API"
    value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_certificate_authority_data" {
    description = "The base64 encoded certificate data required to communicate with the cluster"
    value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
    description = "The security group IDs attached to the EKS cluster"
    value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_role_arn" {
    description = "The ARN of the IAM role associated with the EKS node group"
    value       = aws_iam_role.node_group_role.arn
}

output "node_group_instance_profile_arn" {
    description = "The ARN of the instance profile associated with the EKS node group"
    value       = aws_iam_instance_profile.node_group_instance_profile.arn
}

output "node_group_security_group_id" {
    description = "The security group ID attached to the EKS node group"
    value       = aws_security_group.node_group_sg.id
}
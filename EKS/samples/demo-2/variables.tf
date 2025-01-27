# AWS Region
variable "main-region" {
  description = "The AWS region where resources will be created"
  default     = "us-east-2"
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be created"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

# EKS Configuration
variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "tf-cluster"
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  default     = "1.27"
}

# Managed Node Group Configuration
variable "env_name" {
  description = "The environment name for naming conventions"
  default     = "dev"
}

# ALB Controller Configuration
variable "alb_controller_version" {
  description = "Version of the ALB controller to be used"
  default     = "v2.3.0"
}
